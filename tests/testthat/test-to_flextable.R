test_that("to_flextable() converts descriptive table object", {
  obj <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() works with overall column", {
  obj <- descriptive_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt, cyl)) |>
    add_proportion(var = vs) |>
    add_total() |>
    add_p()

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() works for prop_ci output", {
  obj <- prop_ci(mtcars, var = vs, by = am)

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() works for rate_stats output", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    ptime = c(10, 12, 8, 9, 11, 7),
    arm = c("A", "A", "A", "B", "B", "B")
  )

  obj <- rate_stats(df, event = event, time = ptime, by = arm)

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() works for twobytwo_table output", {
  obj <- twobytwo_table(mtcars, exposure = am, outcome = vs)

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() works for summary_stats output", {
  obj <- summary_stats(mtcars, by = am)

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() includes notes when present", {
  obj <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    add_p()

  expect_true(length(c(obj$notes, obj$footnotes, obj$pvalue_method_footnotes)) > 0)

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() errors when given gt table instead of GTstats object", {
  gt_obj <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    tbl_stats()

  expect_error(
    to_flextable(gt_obj),
    regexp = "tbl_stats"
  )
})

test_that("to_flextable() errors for invalid input without table", {
  expect_error(
    to_flextable(mtcars),
    regexp = "must be a gtstats object"
  )
})
