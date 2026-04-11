test_that("summary_stats() works without grouping", {
  res <- summary_stats(mtcars)

  expect_s3_class(res, "gt_summary")
  expect_true(is.list(res))
  expect_true(all(c("summary", "table", "variable_info", "inputs", "notes") %in% names(res)))
  expect_true(nrow(res$table) > 0)
})

test_that("summary_stats() works with grouping", {
  res <- summary_stats(mtcars, by = am)

  expect_s3_class(res, "gt_summary")
  expect_equal(res$inputs$by, "am")
  expect_true(nrow(res$table) > 0)
})

test_that("summary_stats() accepts character grouping variable", {
  res <- summary_stats(mtcars, by = "am")

  expect_s3_class(res, "gt_summary")
  expect_equal(res$inputs$by, "am")
})

test_that("summary_stats() works with selected variables", {
  res <- summary_stats(mtcars, vars = c("mpg", "wt"))

  expect_s3_class(res, "gt_summary")
  expect_true(all(unique(res$summary$variable) %in% c("mpg", "wt")))
})

test_that("summary_stats() supports bare variable selection via add_summary workflow", {
  obj <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  expect_s3_class(obj, "gt_desc_table")
  expect_true(any(obj$table$Variable %in% c("mpg", "wt")))
})

test_that("summary_stats() supports continuous format mean_sd", {
  res <- summary_stats(mtcars, vars = c("mpg"), continuous_format = "mean_sd")

  expect_s3_class(res, "gt_summary")
  expect_true("Summary" %in% names(res$table))
})

test_that("summary_stats() supports continuous format median_iqr", {
  res <- summary_stats(mtcars, vars = c("mpg"), continuous_format = "median_iqr")

  expect_s3_class(res, "gt_summary")
  expect_true("Summary" %in% names(res$table))
})

test_that("summary_stats() supports continuous format recommended", {
  res <- summary_stats(mtcars, vars = c("mpg"), continuous_format = "recommended")

  expect_s3_class(res, "gt_summary")
  expect_true("Summary" %in% names(res$table))
})

test_that("summary_stats() includes grouped columns when by is supplied", {
  res <- summary_stats(mtcars, vars = c("mpg", "wt"), by = am)

  expect_true(any(grepl("^am =", names(res$table))))
})

test_that("summary_stats() handles categorical variables", {
  res <- summary_stats(mtcars, vars = c("cyl"))

  expect_s3_class(res, "gt_summary")
  expect_true(any(res$table$Variable == "cyl"))
  expect_true(any(res$table$Level %in% c("4", "6", "8")))
})

test_that("summary_stats() removes by variable from vars when duplicated", {
  res <- summary_stats(mtcars, vars = c("mpg", "am"), by = am)

  expect_s3_class(res, "gt_summary")
  expect_false(any(res$summary$variable == "am"))
})

test_that("summary_stats() errors when by is continuous", {
  expect_error(
    summary_stats(mtcars, by = mpg),
    regexp = "should be a categorical, binary, or ordinal grouping variable"
  )
})

test_that("summary_stats() errors when by is missing from data", {
  expect_error(
    summary_stats(mtcars, by = not_a_var),
    regexp = "`by` was not found"
  )
})

test_that("summary_stats() errors when vars are missing from data", {
  expect_error(
    summary_stats(mtcars, vars = c("mpg", "not_a_var")),
    regexp = "not found"
  )
})

test_that("tbl_stats() works on summary_stats output", {
  gt_obj <- summary_stats(mtcars, by = am) |>
    tbl_stats()

  expect_s3_class(gt_obj, "gt_tbl")
})

test_that("to_flextable() works on summary_stats output", {
  ft <- summary_stats(mtcars, by = am) |>
    to_flextable()

  expect_s3_class(ft, "flextable")
})
