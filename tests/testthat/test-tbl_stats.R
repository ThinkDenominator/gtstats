test_that("tbl_stats() works on basic descriptive table", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    tbl_stats()

  expect_s3_class(res, "gt_tbl")
})

test_that("tbl_stats() works with proportions", {
  res <- descriptive_table(mtcars, by = am) |>
    add_proportion(var = vs) |>
    tbl_stats()

  expect_s3_class(res, "gt_tbl")
})

test_that("tbl_stats() works with totals", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = mpg) |>
    add_total() |>
    tbl_stats()

  expect_s3_class(res, "gt_tbl")
})

test_that("tbl_stats() works with p-values", {
  obj <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    add_p()

  expect_true("p-value" %in% names(obj$table))

  res <- tbl_stats(obj)
  expect_s3_class(res, "gt_tbl")
})

test_that("tbl_stats() works with overall column", {
  res <- descriptive_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt)) |>
    tbl_stats()

  expect_s3_class(res, "gt_tbl")
})

test_that("tbl_stats() errors if no table present", {
  res <- descriptive_table(mtcars, by = am)

  expect_error(
    tbl_stats(res),
    regexp = "no rows yet"
  )
})
