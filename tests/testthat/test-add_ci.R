test_that("add_ci() adds intervals to all eligible summaries", {
  result <- summary_table(
    mtcars, by = am, include = c(mpg, cyl), layout = "separate"
  ) |>
    add_ci()

  expect_s3_class(result, "gtstats_summary")
  expect_true("ci" %in% result$components)
  expect_setequal(result$ci_variables, c("mpg", "cyl"))
  expect_true(all(grepl("\\d", result$table$summary_1_ci)))
  expect_true(all(grepl("%$", result$table$summary_1_ci[result$table$Level != ""])))
})

test_that("add_ci() targets selected variables", {
  result <- summary_table(
    mtcars, by = am, include = c(mpg, cyl), layout = "separate"
  ) |>
    add_ci(vars = cyl, conf.level = 0.90, method = "exact")

  expect_identical(result$ci_variables, "cyl")
  mpg_row <- result$table$Variable == "mpg"
  cyl_rows <- result$table$Variable == "cyl"
  expect_true(all(result$table$summary_1_ci[mpg_row] == ""))
  expect_true(all(nzchar(result$table$summary_1_ci[cyl_rows])))
  expect_identical(result$conf.level, 0.90)
  expect_identical(result$ci_method, "exact")
})

test_that("add_ci() supports compact layout", {
  result <- summary_table(mtcars, include = c(mpg, cyl)) |>
    add_ci()

  expect_false(any(grepl("95% CI", result$table$Value, fixed = TRUE)))
  expect_true(all(grepl(";", result$table$Value)))
  expect_match(.builder_publication_note(result), "95% t-based CIs", fixed = TRUE)
  expect_match(.builder_publication_note(result), "95% Wilson score CIs", fixed = TRUE)
})

test_that("separate layout activates only when a CI layer is added", {
  base <- summary_table(
    mtcars, by = am, include = c(mpg, cyl), layout = "separate"
  )

  expect_null(base$display_columns)
  expect_true(all(c("am = 0", "am = 1") %in% names(base$table)))
  expect_false(any(grepl("_ci$", names(base$table))))

  result <- add_ci(base)
  expect_s3_class(result$display_columns, "data.frame")
  expect_true(all(result$display_columns$ci_label == "95% CI"))
  expect_true(all(result$display_columns$ci %in% names(result$table)))
})

test_that("separate CI headers describe the displayed summary honestly", {
  categorical <- summary_table(
    mtcars, by = am, include = c(cyl, vs), layout = "separate"
  ) |> add_ci()
  continuous <- summary_table(
    mtcars, by = am, include = c(mpg, wt), statistic = "mean_sd",
    layout = "separate"
  ) |> add_ci()
  mixed <- summary_table(
    mtcars, by = am, include = c(mpg, cyl), layout = "separate"
  ) |> add_ci()

  expect_true(all(categorical$display_columns$estimate_label == "n (%)"))
  expect_true(all(continuous$display_columns$estimate_label == "Mean (SD)"))
  expect_true(all(mixed$display_columns$estimate_label == "Summary"))
  expect_true(all(mixed$display_columns$ci_label == "95% CI"))
})

test_that("add_ci() skips median-only variables explicitly", {
  result <- summary_table(
    mtcars,
    include = c(mpg, cyl),
    statistic = c(mpg = "median_iqr"),
    layout = "separate"
  ) |>
    add_ci()

  expect_identical(result$ci_variables, "cyl")
  expect_identical(result$ci_skipped, "mpg")
  expect_true(any(grepl("median \\(IQR\\)", result$footnotes, ignore.case = TRUE)))
})

test_that("add_ci() validates selections and repeated use", {
  base <- summary_table(mtcars, include = c(mpg, cyl))
  expect_error(add_ci(base, vars = wt), "not ordinary summaries")
  expect_error(add_ci(base, vars = mpg) |> add_ci(), "already been added")
  expect_error(add_ci(base, conf.level = 1), "between 0 and 1")
})
