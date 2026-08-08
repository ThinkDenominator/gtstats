test_that("to_flextable() converts descriptive table object", {
  obj <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() works with overall column", {
  obj <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt, cyl)) |>
    add_proportion(var = vs) |>
    add_total() |>
    add_p()

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() works for proportion_stats output", {
  obj <- proportion_stats(mtcars, var = vs, by = am)

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

test_that("to_flextable() works for crosstabs() output", {
  obj <- crosstabs(mtcars, row = am, col = vs)

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() works for a direct summary_table output", {
  obj <- summary_table(mtcars, by = am, include = c(mpg, wt))

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() includes notes when present", {
  obj <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    add_p()

  expect_true(length(c(obj$notes, obj$footnotes, obj$pvalue_method_footnotes)) > 0)

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() supports Office presentation options", {
  obj <- summary_table(mtcars, by = am, include = c(mpg, wt))

  ft <- to_flextable(
    obj,
    font_size = 9,
    font = "Arial",
    autofit = FALSE,
    show_footnotes = FALSE
  )

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() validates presentation options", {
  obj <- summary_table(mtcars, by = am, include = c(mpg, wt))

  expect_error(to_flextable(obj, font_size = 0), "positive")
  expect_error(to_flextable(obj, font = ""), "font")
  expect_error(to_flextable(obj, autofit = NA), "autofit")
  expect_error(to_flextable(obj, show_footnotes = 1), "show_footnotes")
})

test_that("to_flextable() errors when given gt table instead of GTstats object", {
  gt_obj <- summary_table(mtcars, by = am) |>
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
