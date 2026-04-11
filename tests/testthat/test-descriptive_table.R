test_that("descriptive_table() creates base object", {
  res <- descriptive_table(mtcars, by = am)

  expect_s3_class(res, "gt_desc_table")
  expect_true(is.list(res))
  expect_true("data" %in% names(res))
  expect_equal(res$by, "am")
})

test_that("descriptive_table() works without grouping", {
  res <- descriptive_table(mtcars)

  expect_s3_class(res, "gt_desc_table")
  expect_null(res$by)
})
test_that("add_summary() adds continuous variables", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  expect_true(nrow(res$table) > 0)
  expect_true(any(res$table$Variable %in% c("mpg", "wt")))
})

test_that("add_proportion() adds categorical variables", {
  res <- descriptive_table(mtcars, by = am) |>
    add_proportion(var = vs)

  expect_true(nrow(res$table) > 0)
  expect_true(any(grepl("vs", res$table$Variable, fixed = TRUE)))
})

test_that("add_total() adds total row", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = mpg) |>
    add_total()

  expect_true(any(res$table$Variable %in% c("Total", "Total (N)", "Total participants")))
})

test_that("pipeline works end-to-end", {
  res <- descriptive_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt)) |>
    add_proportion(var = vs) |>
    add_total()

  expect_s3_class(res, "gt_desc_table")
  expect_true("Overall" %in% names(res$table))
  expect_true(nrow(res$table) > 0)
})

test_that("tbl_stats() returns formatted table", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    tbl_stats()

  expect_s3_class(res, "gt_tbl")
})

test_that("descriptive_table() errors for invalid data", {
  expect_error(
    descriptive_table("not_a_df"),
    "data.frame"
  )
})

test_that("add_summary() errors for missing variable", {
  res <- descriptive_table(mtcars, by = am)

  expect_error(
    add_summary(res, vars = c(not_a_var)),
    "not found"
  )
})

test_that("add_proportion() errors for missing variable", {
  res <- descriptive_table(mtcars, by = am)

  expect_error(
    add_proportion(res, var = not_a_var),
    "not found"
  )
})
