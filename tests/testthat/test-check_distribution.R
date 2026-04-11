test_that("check_distribution() works without grouping", {
  res <- check_distribution(mtcars)

  expect_s3_class(res, "gt_distribution")
  expect_true(is.list(res))
  expect_true(all(c("summary", "table", "inputs", "notes") %in% names(res)))
  expect_true(nrow(res$table) > 0)
})

test_that("check_distribution() works with grouping", {
  res <- check_distribution(mtcars, by = am)

  expect_s3_class(res, "gt_distribution")
  expect_equal(res$inputs$by, "am")
  expect_true(nrow(res$table) > 0)
})

test_that("check_distribution() accepts character grouping variable", {
  res <- check_distribution(mtcars, by = "am")

  expect_s3_class(res, "gt_distribution")
  expect_equal(res$inputs$by, "am")
})

test_that("check_distribution() works with selected variables", {
  res <- check_distribution(mtcars, vars = c("mpg", "wt"))

  expect_s3_class(res, "gt_distribution")
  expect_true(all(unique(res$summary$variable) %in% c("mpg", "wt")))
})

test_that("check_distribution() returns expected output columns", {
  res <- check_distribution(mtcars, vars = c("mpg", "wt"))

  expect_true("Variable" %in% names(res$table))
  expect_true(any(grepl("Skew", names(res$table), ignore.case = TRUE)))
  expect_true(any(grepl("Distribution", names(res$table), ignore.case = TRUE)))
})

test_that("check_distribution() supports grouped output", {
  res <- check_distribution(mtcars, vars = c("mpg"), by = am)

  expect_s3_class(res, "gt_distribution")
  expect_true(nrow(res$table) >= 1)
})

test_that("tbl_stats() works on check_distribution output", {
  gt_obj <- check_distribution(mtcars, vars = c("mpg", "wt")) |>
    tbl_stats()

  expect_s3_class(gt_obj, "gt_tbl")
})

test_that("to_flextable() works on check_distribution output", {
  ft <- check_distribution(mtcars, vars = c("mpg", "wt")) |>
    to_flextable()

  expect_s3_class(ft, "flextable")
})

test_that("check_distribution() errors when by is continuous", {
  expect_error(
    check_distribution(mtcars, by = mpg),
    regexp = "categorical|binary|ordinal"
  )
})

test_that("check_distribution() errors when vars are missing", {
  expect_error(
    check_distribution(mtcars, vars = c("mpg", "not_a_var")),
    regexp = "not found"
  )
})

test_that("check_distribution() errors when by is missing", {
  expect_error(
    check_distribution(mtcars, by = not_a_var),
    regexp = "not found"
  )
})
