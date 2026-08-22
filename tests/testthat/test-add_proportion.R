test_that("add_proportion() adds proportion row to ungrouped descriptive table", {
  res <- summary_table(mtcars) |>
    add_proportion(var = vs)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("^vs", res$table$Variable)))
  expect_true("Value" %in% names(res$table))
  expect_true("proportion" %in% res$components)
  expect_true(any(grepl("Wilson score", res$footnotes)))
})

test_that("add_proportion() adds proportion row to grouped descriptive table", {
  res <- summary_table(mtcars, by = am) |>
    add_proportion(var = vs)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("^vs", res$table$Variable)))
  expect_true(all(c("am = 1", "am = 0") %in% names(res$table)))
})

test_that("add_proportion() adds proportion row to grouped table with overall", {
  res <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_proportion(var = vs)

  expect_s3_class(res, "gt_desc_table")
  expect_true("Overall" %in% names(res$table))
  expect_true(any(grepl("^vs", res$table$Variable)))
})

test_that("add_proportion() accepts character variable name", {
  res <- summary_table(mtcars, by = am) |>
    add_proportion(var = "vs")

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("^vs", res$table$Variable)))
})

test_that("add_proportion() supports explicit level", {
  res <- summary_table(mtcars, by = am) |>
    add_proportion(var = vs, level = "1")

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("\\(1\\)", res$table$Variable)))
})

test_that("add_proportion() supports custom label", {
  res <- summary_table(mtcars, by = am) |>
    add_proportion(var = vs, label = "Engine shape")

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(res$table$Variable == "Engine shape"))
  expect_false(any(res$table$Variable == "Engine shape (1)"))
  expect_match(res$footnotes, "Confidence intervals: 95% intervals use the Wilson score method", fixed = TRUE)
})

test_that("add_proportion() validates a custom label", {
  builder <- summary_table(mtcars, by = am)

  expect_error(
    add_proportion(builder, var = vs, label = ""),
    "single non-empty"
  )
  expect_error(
    add_proportion(builder, var = vs, label = c("Smoking", "status")),
    "single non-empty"
  )
})

test_that("add_proportion() supports ci = FALSE", {
  res <- summary_table(mtcars, by = am) |>
    add_proportion(var = vs, ci = FALSE)

  expect_s3_class(res, "gt_desc_table")
  expect_false(any(grepl("Selected event", res$footnotes)))
  expect_false(any(grepl("add_p", res$footnotes, fixed = TRUE)))
})

test_that("add_proportion() works for categorical variable", {
  res <- summary_table(mtcars, by = am) |>
    add_proportion(var = cyl)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("^cyl", res$table$Variable)))
})

test_that("add_proportion() chooses level automatically for binary variable", {
  res <- summary_table(mtcars, by = am) |>
    add_proportion(var = vs)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("\\(", res$table$Variable)))
})

test_that("add_proportion() can be followed by tbl_stats()", {
  gt_obj <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_proportion(var = vs) |>
    tbl_stats()

  expect_s3_class(gt_obj, "gt_tbl")
})

test_that("add_proportion() errors if x is not gt_desc_table", {
  expect_error(
    add_proportion(mtcars, var = vs),
    regexp = "gt_desc_table"
  )
})

test_that("add_proportion() errors in non-summary mode", {
  res <- summary_table(mtcars, by = am, mode = "rate")

  expect_error(
    add_proportion(res, var = vs),
    regexp = "mode = \"summary\""
  )
})

test_that("add_proportion() errors if variable is missing", {
  res <- summary_table(mtcars, by = am)

  expect_error(
    add_proportion(res, var = not_a_var),
    regexp = "`var` was not found"
  )
})

test_that("add_proportion() errors for continuous variable", {
  res <- summary_table(mtcars, by = am)

  expect_error(
    add_proportion(res, var = mpg),
    regexp = "supports binary, categorical, or ordinal variables"
  )
})

test_that("add_proportion() errors when requested level is absent", {
  res <- summary_table(mtcars, by = am)

  expect_error(
    add_proportion(res, var = vs, level = "not_a_level"),
    regexp = "`level` was not found"
  )
})

test_that("add_proportion() errors when variable has no non-missing values", {
  df <- data.frame(
    x = c(NA, NA, NA),
    grp = c("a", "a", "b")
  )

  res <- summary_table(df, by = grp)

  expect_error(
    add_proportion(res, var = x),
    regexp = "has no non-missing values"
  )
})

test_that("add_proportion() validates confidence level and digits", {
  builder <- summary_table(mtcars)

  expect_error(
    add_proportion(builder, var = vs, conf.level = 2),
    "between 0 and 1"
  )
  expect_error(
    add_proportion(builder, var = vs, digits = 1.5),
    "whole number"
  )
})

test_that("add_proportion() shares interval and display choices", {
  wilson <- summary_table(mtcars) |>
    add_proportion(vs, ci_method = "wilson", display = "n_percent")
  exact <- summary_table(mtcars) |>
    add_proportion(
      vs,
      ci_method = "exact",
      display = "n_over_N_percent"
    )
  percent <- summary_table(mtcars) |>
    add_proportion(vs, display = "percent", ci = FALSE)

  expect_match(wilson$table$Value, "^14 \\(43.8%\\)")
  expect_match(exact$table$Value, "^14/32 \\(43.8%\\)")
  expect_match(exact$footnotes, "exact binomial")
  expect_false(any(grepl("Selected event", exact$footnotes)))
  expect_identical(percent$table$Value, "43.8%")
})

test_that("add_proportion() supports a separate publication layout", {
  result <- summary_table(
    mtcars, by = am, overall = TRUE, layout = "separate"
  ) |>
    add_proportion(vs, level = "1")

  expect_identical(result$layout, "separate")
  expect_equal(nrow(result$display_columns), 3L)
  expect_true(all(result$display_columns$estimate_label == "n (%)"))
  expect_true(all(grepl("_ci$", result$display_columns$ci)))
  expect_false(any(grepl("95% CI", unlist(result$table), fixed = TRUE)))
  expect_s3_class(tbl_stats(result), "gt_tbl")
})
