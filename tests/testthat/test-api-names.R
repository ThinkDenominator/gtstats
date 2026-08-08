test_that("proportion_stats() provides the finalized proportion API", {
  result <- proportion_stats(mtcars, var = vs, by = am)

  expect_s3_class(result, "gt_prop")
  expect_equal(result$inputs$data_name, "mtcars")
  expect_equal(result$inputs$var, "vs")
  expect_equal(result$inputs$by, "am")
  expect_identical(result$call[[1L]], quote(proportion_stats))
})

test_that("crosstabs() provides the finalized two-by-two API", {
  result <- crosstabs(mtcars, row = am, col = vs)

  expect_s3_class(result, "gt_twobytwo")
  expect_equal(result$inputs$data_name, "mtcars")
  expect_equal(result$inputs$row, "am")
  expect_equal(result$inputs$col, "vs")
  expect_identical(result$call[[1L]], quote(crosstabs))
})

test_that("customise_table() provides the finalized styling API", {
  table <- summary_table(mtcars) |>
    add_summary(vars = mpg) |>
    tbl_stats()

  result <- customise_table(table, title = "Test table")
  expect_s3_class(result, "gt_tbl")
})

test_that("customise_table() accepts an unrendered result", {
  result <- summary_table(mtcars, include = c(mpg, wt))

  styled <- customise_table(
    result,
    theme = "journal",
    title = "Vehicle characteristics",
    font = "Arial",
    width = 90,
    row_striping = TRUE
  )

  expect_s3_class(styled, "gt_tbl")
})

test_that("customise_table() validates its public inputs", {
  result <- summary_table(mtcars, include = mpg)

  expect_error(
    customise_table(result, width = 101),
    "percentage between 0 and 100"
  )
  expect_error(
    customise_table(result, font = ""),
    "single non-empty font name"
  )
  expect_error(
    customise_table(mtcars),
    "gtstats result or a rendered gt table"
  )
})

test_that("gtstats exports do not conflict with gtregression exports", {
  gtregression_exports <- c(
    "check_collinearity", "check_convergence", "check_ph", "cox_reg",
    "descriptive_table", "dissect", "forest_df", "forest_reg",
    "identify_confounder", "interaction_models", "km_plot",
    "km_risk_table", "logrank_test", "mediation_analysis",
    "merge_tables", "modify_table", "multi_reg", "plot_mediation",
    "plot_model_fit", "plot_reg", "plot_reg_combine", "plot_surv_fit",
    "rmst_table", "save_docx", "save_plot", "save_table",
    "select_models", "stratified_multi_reg", "stratified_uni_reg",
    "surv_model_compare", "surv_predict", "surv_reg", "survival_prob",
    "survival_quantiles", "survival_summary", "uni_reg"
  )

  expect_length(
    intersect(getNamespaceExports("gtstats"), gtregression_exports),
    0L
  )
})

test_that("only finalized conflict-free public names are exported", {
  exports <- sort(getNamespaceExports("gtstats"))
  finalized_api <- sort(c(
    "add_row", "add_p", "add_proportion", "add_rate",
    "add_summary", "add_total", "assess_distribution", "assess_variance",
    "assumptions_stats", "compare_groups", "correlation",
    "customise_table", "denominators_stats", "describe_data",
    "diagnostics_stats", "effect_size", "plot_compare",
    "plot_correlation", "proportion_stats", "rate_stats",
    "save_output",
    "summary_table", "tbl_stats", "to_flextable", "crosstabs"
  ))

  expect_identical(exports, finalized_api)
  expect_false(any(c(
    "prop_ci",
    "twobytwo_table",
    "twobytwo_stats",
    "style_table",
    "check_distribution",
    "descriptive_table",
    "summary_stats",
    "correlate_vars",
    "add_custom_row"
  ) %in% exports))
})
