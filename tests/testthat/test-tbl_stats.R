test_that("tbl_stats() works on basic descriptive table", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    tbl_stats()

  expect_s3_class(res, "gt_tbl")
})

test_that("tbl_stats() works with proportions", {
  res <- summary_table(mtcars, by = am) |>
    add_proportion(var = vs) |>
    tbl_stats()

  expect_s3_class(res, "gt_tbl")
})

test_that("tbl_stats() works with totals", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = mpg) |>
    add_total() |>
    tbl_stats()

  expect_s3_class(res, "gt_tbl")
})

test_that("tbl_stats() works with p-values", {
  obj <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    add_p()

  expect_true("p-value" %in% names(obj$table))

  res <- tbl_stats(obj)
  expect_s3_class(res, "gt_tbl")
})

test_that("publication tables exclude analyst audit instructions", {
  obj <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_total(position = "first") |>
    add_summary(vars = c(mpg, wt, cyl)) |>
    add_proportion(var = vs) |>
    add_p()

  rendered <- tbl_stats(obj)
  footnote_text <- paste(rendered[["_footnotes"]]$footnotes, collapse = " ")
  source_text <- paste(unlist(rendered[["_source_notes"]]), collapse = " ")

  expect_match(
    footnote_text,
    "Continuous data are (mean \\(SD\\)|median \\(IQR\\))"
  )
  expect_match(footnote_text, "Welch|Wilcoxon|Chi-square|Fisher")
  expect_match(footnote_text, "range after the semicolon")
  expect_false(grepl("denominators_stats", footnote_text, fixed = TRUE))
  expect_false(grepl("assumptions_stats", footnote_text, fixed = TRUE))
  expect_false(grepl("diagnostics_stats", footnote_text, fixed = TRUE))
  expect_false(grepl("denominators_stats", source_text, fixed = TRUE))
  expect_length(unique(rendered[["_footnotes"]]$footnotes), 2L)
})

test_that("non-standard percentage denominators remain reader-facing", {
  rendered <- summary_table(mtcars, by = am) |>
    add_summary(vars = cyl, percent = "row") |>
    tbl_stats()

  footnote_text <- paste(rendered[["_footnotes"]]$footnotes, collapse = " ")
  expect_match(footnote_text, "row denominators")
})

test_that("publication footnotes describe only statistics present in the table", {
  categorical <- summary_table(mtcars, include = c(cyl, vs)) |>
    tbl_stats()
  continuous <- summary_table(mtcars, include = c(mpg, wt)) |>
    tbl_stats()

  categorical_notes <- paste(
    categorical[["_footnotes"]]$footnotes, collapse = " "
  )
  continuous_notes <- paste(
    continuous[["_footnotes"]]$footnotes, collapse = " "
  )

  expect_match(categorical_notes, "Categorical data are n \\(%)")
  expect_false(grepl("Continuous data", categorical_notes, fixed = TRUE))
  expect_match(
    continuous_notes,
    "Continuous data are (mean \\(SD\\)|median \\(IQR\\))"
  )
  expect_false(grepl("Categorical data", continuous_notes, fixed = TRUE))
})

test_that("mixed continuous summaries name their displayed variables", {
  dat <- mtcars
  attr(dat$mpg, "label") <- "Fuel economy"
  attr(dat$wt, "label") <- "Vehicle weight"
  rendered <- summary_table(
    dat,
    by = am,
    include = c(mpg, wt, cyl),
    statistic = c(mpg = "mean_sd", wt = "median_iqr")
  ) |>
    tbl_stats()
  footnote_text <- paste(rendered[["_footnotes"]]$footnotes, collapse = " ")

  expect_match(
    footnote_text,
    "Fuel economy: mean \\(SD\\); Vehicle weight: median \\(IQR\\)"
  )
  expect_false(grepl("stated summary statistics", footnote_text, fixed = TRUE))
})

test_that("tbl_stats() works with overall column", {
  res <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt)) |>
    tbl_stats()

  expect_s3_class(res, "gt_tbl")
})

test_that("descriptive headers show cohort denominators", {
  data <- mtcars
  data$am <- factor(
    data$am,
    levels = c(0, 1),
    labels = c("Automatic", "Manual")
  )
  rendered <- summary_table(data, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, cyl)) |>
    tbl_stats()

  boxhead <- rendered[["_boxhead"]]
  labels <- stats::setNames(boxhead$column_label, boxhead$var)

  expect_match(as.character(labels[["Overall"]]), "Overall.*N = 32")
  expect_match(
    as.character(labels[["am = Automatic"]]),
    "Automatic.*N = 19"
  )
  expect_match(
    as.character(labels[["am = Manual"]]),
    "Manual.*N = 13"
  )
  expect_false(grepl("am =", as.character(labels[["am = Automatic"]])))

  footnotes <- rendered[["_footnotes"]]
  summary_columns <- c("Overall", "am = Automatic", "am = Manual")
  expect_setequal(footnotes$colname, summary_columns)
  expect_false(any(footnotes$colname == "p-value" &
                     grepl("Continuous summaries", footnotes$footnotes)))
})

test_that("ungrouped descriptive headers show overall denominator", {
  rendered <- summary_table(mtcars) |>
    add_summary(vars = mpg) |>
    tbl_stats()

  boxhead <- rendered[["_boxhead"]]
  value_label <- boxhead$column_label[boxhead$var == "Value"]
  expect_match(as.character(value_label), "Overall.*N = 32")
})

test_that("tbl_stats() errors if no table present", {
  res <- summary_table(mtcars, by = am)

  expect_error(
    tbl_stats(res),
    regexp = "no rows yet"
  )
})

test_that("inspection tables have no automatic title or subtitle", {
  overview <- tbl_stats(describe_data(mtcars))
  distribution <- tbl_stats(assess_distribution(mtcars, vars = "mpg"))
  variance <- tbl_stats(assess_variance(mtcars, vars = "mpg", by = am))

  expect_null(overview[["_heading"]]$title)
  expect_null(overview[["_heading"]]$subtitle)
  expect_null(distribution[["_heading"]]$title)
  expect_null(distribution[["_heading"]]$subtitle)
  expect_null(variance[["_heading"]]$title)
  expect_null(variance[["_heading"]]$subtitle)
})
