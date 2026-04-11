test_that("add_summary() adds summary rows to ungrouped descriptive table", {
  res <- descriptive_table(mtcars) |>
    add_summary(vars = c(mpg, wt))

  expect_s3_class(res, "gt_desc_table")
  expect_true(all(c("Variable", "Level", "Value") %in% names(res$table)))
  expect_true(any(res$table$Variable %in% c("mpg", "wt")))
  expect_true("summary" %in% res$components)
})

test_that("add_summary() adds summary rows to grouped descriptive table", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt, cyl))

  expect_s3_class(res, "gt_desc_table")
  expect_true(all(c("Variable", "Level", "am = 1", "am = 0") %in% names(res$table)))
  expect_true(any(res$table$Variable %in% c("mpg", "wt", "cyl")))
})

test_that("add_summary() adds overall column when requested", {
  res <- descriptive_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt))

  expect_s3_class(res, "gt_desc_table")
  expect_true("Overall" %in% names(res$table))
  expect_true(all(c("am = 1", "am = 0") %in% names(res$table)))
})

test_that("add_summary() works with single bare variable", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = mpg)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(res$table$Variable == "mpg"))
})

test_that("add_summary() works with bare c() variables", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt, cyl))

  expect_s3_class(res, "gt_desc_table")
  expect_true(all(c("mpg", "wt", "cyl") %in% unique(res$table$Variable)))
})

test_that("add_summary() works with character vector variables", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c("mpg", "wt", "cyl"))

  expect_s3_class(res, "gt_desc_table")
  expect_true(all(c("mpg", "wt", "cyl") %in% unique(res$table$Variable)))
})

test_that("add_summary() supports mean_sd format", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg), continuous_format = "mean_sd")

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("mean \\(SD\\)", res$footnotes, ignore.case = TRUE)))
})

test_that("add_summary() supports median_iqr format", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg), continuous_format = "median_iqr")

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("median \\(IQR\\)", res$footnotes, ignore.case = TRUE)))
})

test_that("add_summary() supports recommended format", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg), continuous_format = "recommended")

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("as appropriate", res$footnotes, ignore.case = TRUE)))
})

test_that("add_summary() supports both format", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg), continuous_format = "both")

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("mean \\(SD\\) and median \\(IQR\\)", res$footnotes, ignore.case = TRUE)))
})

test_that("add_summary() can be followed by tbl_stats()", {
  gt_obj <- descriptive_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt, cyl)) |>
    tbl_stats()

  expect_s3_class(gt_obj, "gt_tbl")
})

test_that("add_summary() errors if x is not gt_desc_table", {
  expect_error(
    add_summary(mtcars, vars = c(mpg, wt)),
    regexp = "gt_desc_table"
  )
})

test_that("add_summary() errors in non-summary mode", {
  res <- descriptive_table(mtcars, by = am, mode = "rate")

  expect_error(
    add_summary(res, vars = c(mpg, wt)),
    regexp = "mode = \"summary\""
  )
})

test_that("add_summary() errors for invalid vars specification", {
  res <- descriptive_table(mtcars, by = am)

  expect_error(
    add_summary(res, vars = mean(mpg)),
    regexp = "bare names|character vector"
  )
})

test_that("add_summary() errors when variables are missing", {
  res <- descriptive_table(mtcars, by = am)

  expect_error(
    add_summary(res, vars = c(mpg, not_a_var)),
    regexp = "not found"
  )
})

test_that("add_summary() errors when no new columns can be added", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  expect_error(
    add_summary(res, vars = c(mpg, wt)),
    regexp = "No new columns were added|already exist|incompatible"
  )
})

test_that("add_summary() errors when existing table structure is incompatible", {
  res <- descriptive_table(mtcars, by = am)
  res$table <- tibble::tibble(Bad = "x")

  expect_error(
    add_summary(res, vars = c(mpg)),
    regexp = "not compatible with summary rows"
  )
})
