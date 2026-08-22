test_that("summary_table() creates base object", {
  res <- summary_table(mtcars, by = am)

  expect_s3_class(res, "gt_desc_table")
  expect_true(is.list(res))
  expect_true("data" %in% names(res))
  expect_equal(res$by, "am")
})

test_that("a continuous statistic fallback accepts variable exceptions", {
  result <- summary_table(
    mtcars,
    include = c(mpg, wt, qsec, cyl),
    statistic = c(continuous = "mean_sd", wt = "median_iqr")
  )
  expect_identical(result$summary_statistics[["mpg"]], "mean_sd")
  expect_identical(result$summary_statistics[["qsec"]], "mean_sd")
  expect_identical(result$summary_statistics[["wt"]], "median_iqr")
})

test_that("summary_table() works without grouping", {
  res <- summary_table(mtcars)

  expect_s3_class(res, "gt_desc_table")
  expect_null(res$by)
})

test_that("summary_table() accepts a grouping variable stored as text", {
  grouping_variable <- "am"
  res <- summary_table(mtcars, by = grouping_variable)

  expect_equal(res$by, "am")
})

test_that("summary_table() uses a common gtstats parent class", {
  res <- summary_table(mtcars)

  expect_s3_class(res, "gtstats")
  expect_equal(res$data_name, "mtcars")
})

test_that("summary_table() builds a mixed-type table in one call", {
  data <- mtcars
  data$am <- factor(data$am)
  data$cyl <- factor(data$cyl)

  res <- summary_table(
    data,
    by = am,
    include = c(mpg, wt, cyl),
    overall = TRUE
  )

  expect_s3_class(res, "gt_desc_table")
  expect_true("summary" %in% res$components)
  expect_true("Overall" %in% names(res$table))
  expect_true(any(res$table$Variable == "mpg"))
  expect_true(any(res$table$Variable == "wt"))
  expect_true(any(res$table$Variable == "cyl"))
  expect_s3_class(tbl_stats(res), "gt_tbl")
})

test_that("categorical summaries can separate n and percent columns", {
  data <- mtcars
  data$am <- factor(data$am)
  data$cyl <- factor(data$cyl)
  data$vs <- factor(data$vs)

  result <- summary_table(
    data,
    by = am,
    include = c(cyl, vs),
    overall = TRUE,
    categorical_layout = "separate"
  )

  expect_identical(result$categorical_layout, "separate")
  expect_true(all(result$display_columns$estimate_label == "n"))
  expect_true(all(result$display_columns$ci_label == "%"))
  expect_true(all(grepl("_count$", result$display_columns$estimate)))
  expect_true(all(grepl("_percent$", result$display_columns$ci)))
  expect_match(.builder_publication_note(result), "Categorical data are n and %", fixed = TRUE)
  expect_false(grepl("separate columns", .builder_publication_note(result), fixed = TRUE))
})

test_that("separate n and percent columns reject misleading combinations", {
  data <- mtcars
  data$cyl <- factor(data$cyl)

  expect_error(
    summary_table(data, include = c(mpg, cyl), categorical_layout = "separate"),
    "categorical-only"
  )
  expect_error(
    summary_table(data, include = cyl, categorical_layout = "separate") |> add_ci(),
    "cannot be added"
  )
  expect_error(
    summary_table(data, include = cyl, categorical = "n", categorical_layout = "separate"),
    "require"
  )
})

test_that("summary_table() include supports character vectors and add_p", {
  data <- mtcars
  data$am <- factor(data$am)

  selected <- c("mpg", "wt", "vs")
  res <- summary_table(
    data,
    by = am,
    include = selected,
    overall = TRUE
  ) |>
    add_p()

  expect_true("p-value" %in% names(res$table))
  expect_true(length(res$pvalue_method_footnotes) > 0L)
})

test_that("summary_table() excludes by from include", {
  data <- mtcars
  data$am <- factor(data$am)

  res <- summary_table(data, by = am, include = c(am, mpg))

  expect_true(any(res$table$Variable == "mpg"))
  expect_false(any(res$table$Variable == "am"))
})

test_that("summary_table() validates include mode and selection", {
  data <- mtcars
  data$am <- factor(data$am)

  expect_error(
    summary_table(data, by = am, include = am),
    "at least one variable other than `by`"
  )
  expect_error(
    summary_table(data, include = mpg, mode = "rate"),
    "available only"
  )
})

test_that("summary_table() validates overall", {
  expect_error(
    summary_table(mtcars, overall = "yes"),
    'FALSE, TRUE, "first", or "last"',
    fixed = TRUE
  )
})
test_that("add_summary() adds continuous variables", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  expect_true(nrow(res$table) > 0)
  expect_true(any(res$table$Variable %in% c("mpg", "wt")))
})

test_that("add_proportion() adds categorical variables", {
  res <- summary_table(mtcars, by = am) |>
    add_proportion(var = vs)

  expect_true(nrow(res$table) > 0)
  expect_true(any(grepl("vs", res$table$Variable, fixed = TRUE)))
})

test_that("add_total() adds total row", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = mpg) |>
    add_total()

  expect_true(any(res$table$Variable %in% c("Total", "Total (N)", "Total participants")))
})

test_that("pipeline works end-to-end", {
  res <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt)) |>
    add_proportion(var = vs) |>
    add_total()

  expect_s3_class(res, "gt_desc_table")
  expect_true("Overall" %in% names(res$table))
  expect_true(nrow(res$table) > 0)
})

test_that("tbl_stats() returns formatted table", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    tbl_stats()

  expect_s3_class(res, "gt_tbl")
})

test_that("summary_table() errors for invalid data", {
  expect_error(
    summary_table("not_a_df"),
    "data.frame"
  )
})

test_that("grouped summaries display blank category values safely", {
  dat <- data.frame(
    group = factor(c("", "", "A", "A")),
    outcome = factor(c("No", "Yes", "No", "Yes"))
  )

  result <- summary_table(dat, by = group) |>
    add_proportion(var = outcome, level = "Yes") |>
    add_total()

  expect_s3_class(result, "gt_desc_table")
  expect_true(any(grepl("\\(blank\\)", names(result$table))))
})

test_that("add_summary() errors for missing variable", {
  res <- summary_table(mtcars, by = am)

  expect_error(
    add_summary(res, vars = c(not_a_var)),
    "not found"
  )
})

test_that("add_proportion() errors for missing variable", {
  res <- summary_table(mtcars, by = am)

  expect_error(
    add_proportion(res, var = not_a_var),
    "not found"
  )
})
test_that("summary_table() separates estimates and confidence intervals", {
  result <- summary_table(
    mtcars,
    by = am,
    include = c(mpg, vs),
    overall = TRUE,
    ci = TRUE,
    layout = "separate"
  )

  expect_identical(result$layout, "separate")
  expect_equal(nrow(result$display_columns), 3L)
  expect_true(all(result$display_columns$ci %in% names(result$table)))
  expect_true(any(nzchar(result$table[[result$display_columns$ci[[1L]]]])))
  expect_s3_class(tbl_stats(result), "gt_tbl")
})
