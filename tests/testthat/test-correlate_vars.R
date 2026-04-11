test_that("correlate_vars() works with default settings", {
  res <- correlate_vars(mtcars, x = mpg, y = wt)

  expect_s3_class(res, "gt_correlation")
  expect_true(is.list(res))
  expect_true(all(c("summary", "table", "inputs", "notes") %in% names(res)))
  expect_equal(nrow(res$table), 1)
})

test_that("correlate_vars() accepts character input", {
  res <- correlate_vars(mtcars, x = "mpg", y = "wt")

  expect_s3_class(res, "gt_correlation")
  expect_equal(res$inputs$x, "mpg")
  expect_equal(res$inputs$y, "wt")
})

test_that("correlate_vars() returns Pearson correlation when requested", {
  res <- correlate_vars(mtcars, x = mpg, y = wt, method = "pearson")

  expect_s3_class(res, "gt_correlation")
  expect_true(grepl("Pearson", res$table$Method[1]))
})

test_that("correlate_vars() returns Spearman correlation when requested", {
  res <- correlate_vars(mtcars, x = mpg, y = wt, method = "spearman")

  expect_s3_class(res, "gt_correlation")
  expect_true(grepl("Spearman", res$table$Method[1]))
})

test_that("correlate_vars() returns formatted correlation output", {
  res <- correlate_vars(mtcars, x = mpg, y = wt)

  expect_true(all(c(
    "X", "Y", "Method", "n", "Correlation",
    "95% CI", "p-value", "Strength", "Direction", "Interpretation"
  ) %in% names(res$table)))
})

test_that("correlate_vars() returns negative direction for mpg and wt", {
  res <- correlate_vars(mtcars, x = mpg, y = wt)

  expect_true(res$table$Direction[1] %in% c("Negative", "Positive", "None"))
  expect_equal(res$table$Direction[1], "Negative")
})

test_that("correlate_vars() returns strength label", {
  res <- correlate_vars(mtcars, x = mpg, y = wt)

  expect_true(nzchar(res$table$Strength[1]))
})

test_that("tbl_stats() works on correlate_vars output", {
  gt_obj <- correlate_vars(mtcars, x = mpg, y = wt) |>
    tbl_stats()

  expect_s3_class(gt_obj, "gt_tbl")
})

test_that("to_flextable() works on correlate_vars output", {
  ft <- correlate_vars(mtcars, x = mpg, y = wt) |>
    to_flextable()

  expect_s3_class(ft, "flextable")
})

test_that("correlate_vars() errors when x is missing from data", {
  expect_error(
    correlate_vars(mtcars, x = not_a_var, y = wt),
    regexp = "not found"
  )
})

test_that("correlate_vars() errors when y is missing from data", {
  expect_error(
    correlate_vars(mtcars, x = mpg, y = not_a_var),
    regexp = "not found"
  )
})

test_that("correlate_vars() errors when x and y are the same", {
  expect_error(
    correlate_vars(mtcars, x = mpg, y = mpg),
    regexp = "must be different"
  )
})

test_that("correlate_vars() errors when a variable is non-continuous", {
  expect_error(
    correlate_vars(mtcars, x = mpg, y = am),
    regexp = "continuous"
  )
})
