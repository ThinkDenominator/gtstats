test_that("standalone analyses support publication and console formats", {
  expect_s3_class(describe_data(mtcars), "gt_describe")
  expect_s3_class(describe_data(mtcars, format = "tibble"), "tbl_df")
  expect_s3_class(describe_data(mtcars, output = "tibble"), "tbl_df")

  expect_s3_class(
    assess_distribution(mtcars, vars = mpg, format = "tibble"),
    "tbl_df"
  )
  expect_s3_class(
    assess_variance(mtcars, vars = mpg, by = am, format = "tibble"),
    "tbl_df"
  )
  expect_s3_class(compare_groups(mtcars, mpg, am, format = "tibble"), "tbl_df")
  expect_s3_class(effect_size(mtcars, mpg, am, format = "tibble"), "tbl_df")
  expect_s3_class(correlation(mtcars, mpg, wt, format = "tibble"), "tbl_df")
  expect_s3_class(
    correlation(mtcars, vars = c(mpg, wt, hp), format = "tibble"),
    "tbl_df"
  )
  expect_s3_class(proportion_stats(mtcars, vs, format = "tibble"), "tbl_df")
  console_crosstab <- crosstabs(mtcars, am, vs, format = "tibble")
  expect_s3_class(console_crosstab, "tbl_df")
  expect_false(any(grepl("<br>", unlist(console_crosstab), fixed = TRUE)))
  expect_false(any(grepl("\n", unlist(console_crosstab), fixed = TRUE)))
  expect_true(any(grepl("^[0-9]+ \\([^)]*%\\)$", unlist(console_crosstab))))

  rate_data <- data.frame(event = c(1, 0, 1), time = c(10, 12, 8))
  expect_s3_class(
    rate_stats(rate_data, event, time, format = "tibble"),
    "tbl_df"
  )
})

test_that("summary builder remains composable in console format", {
  x <- summary_table(
    mtcars,
    by = am,
    include = c(mpg, cyl),
    overall = TRUE,
    format = "tibble"
  ) |>
    add_p()

  expect_s3_class(x, "gt_desc_table")
  expect_identical(x$format, "tibble")
  expect_s3_class(x$table, "tbl_df")
  expect_output(print(x), "# A tibble")
})

test_that("invalid formats fail clearly", {
  expect_error(describe_data(mtcars, format = "html"), "arg")
  expect_error(compare_groups(mtcars, mpg, am, format = "html"), "arg")
  expect_error(summary_table(mtcars, format = "html"), "arg")
})

test_that("audit helpers use the same table and console contract", {
  x <- compare_groups(mtcars, mpg, am)

  expect_s3_class(assumptions_stats(x), "gt_tbl")
  expect_s3_class(diagnostics_stats(x), "gt_tbl")
  expect_s3_class(denominators_stats(x), "gt_tbl")
  expect_s3_class(assumptions_stats(x, format = "tibble"), "tbl_df")
  expect_s3_class(diagnostics_stats(x, format = "tibble"), "tbl_df")
  expect_s3_class(denominators_stats(x, format = "tibble"), "tbl_df")
})
