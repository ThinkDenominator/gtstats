test_that("the Shiny app is bundled with gtstats", {
  expect_true(file.exists(system.file("shiny", "app.R", package = "gtstats")))
  expect_true(is.function(gtstats_app))

  app_text <- paste(readLines(system.file("shiny", "app.R", package = "gtstats")), collapse = "\n")
  expect_match(app_text, "Select variables to summarise", fixed = TRUE)
  expect_match(app_text, "Data dictionary", fixed = TRUE)
  expect_match(app_text, "Download .R", fixed = TRUE)
  expect_match(app_text, "Upload my own data", fixed = TRUE)
  expect_match(app_text, "Stata (.dta)", fixed = TRUE)
  expect_match(app_text, "Supported uploads: CSV", fixed = TRUE)
  expect_match(app_text, "Download complete R script", fixed = TRUE)
  expect_match(app_text, "navbar-toggle", fixed = TRUE)
  expect_match(app_text, "overflow-x: auto", fixed = TRUE)
  expect_match(app_text, "download_strip(\"describe\")", fixed = TRUE)
  expect_match(app_text, "download_strip(\"distribution\")", fixed = TRUE)
  expect_match(app_text, "download_strip(\"comparison_diagnostics\")", fixed = TRUE)
  expect_match(app_text, "download_strip(\"history\")", fixed = TRUE)
  expect_match(app_text, "Repeated measurements from the same participant", fixed = TRUE)
  expect_match(app_text, "Cochran's Q test", fixed = TRUE)
})

test_that("the GUI runs the core birth-weight workflow", {
  skip_if_not_installed("shiny")

  app_environment <- new.env(parent = globalenv())
  source(system.file("shiny", "app.R", package = "gtstats"),
    local = app_environment)

  shiny::testServer(app_environment$server, {
    session$setInputs(data_source = "teaching", teaching_data = "birthwt")
    session$flushReact()
    expect_equal(nrow(selected_data()), 189L)

    session$setInputs(run_describe = 1)
    session$flushReact()
    expect_s3_class(described(), "gt_describe")
    expect_s3_class(data_preview_result(), "gt_tbl")
    expect_s3_class(data_dictionary_result(), "gt_tbl")

    session$setInputs(
      diagnostic_vars = c("age", "lwt"), diagnostic_group = "low",
      run_distribution = 1
    )
    session$flushReact()
    expect_s3_class(diagnostic_result(), "gt_distribution")

    session$setInputs(
      table_vars = c("age", "smoke"), table_group = "low",
      table_overall = "first", table_categorical = "n_percent",
      table_percent = "column", table_statistic = "recommended",
      table_missing = "ifany", table_digits = 1, table_p = FALSE, run_table = 1
    )
    session$flushReact()
    expect_s3_class(table_result(), "gt_desc_table")

    session$setInputs(
      compare_variable = "age", compare_group = "low", compare_test = "auto",
      compare_effect = FALSE, run_compare = 1
    )
    session$flushReact()
    expect_s3_class(comparison_result(), "gt_compare")
    expect_s3_class(comparison_diagnostics_result(), "gt_tbl")
    expect_s3_class(comparison_assumptions_result(), "gt_tbl")
    expect_s3_class(comparison_denominators_result(), "gt_tbl")

    session$setInputs(
      cross_row = "smoke", cross_col = "low", cross_percent = "column",
      cross_test = "auto", run_cross = 1
    )
    session$flushReact()
    expect_s3_class(crosstab_result(), "gt_twobytwo")
    expect_match(complete_script(), "summary_table", fixed = TRUE)
    expect_match(complete_script(), "compare_groups", fixed = TRUE)
    expect_match(complete_script(), "crosstabs", fixed = TRUE)

    session$setInputs(data_source = "teaching", teaching_data = "paired_data")
    session$flushReact()
    session$setInputs(
      compare_variable = "pain_score", compare_group = "visit",
      compare_paired = TRUE, compare_id = "id", compare_test = "auto",
      compare_effect = FALSE, run_compare = 2
    )
    session$flushReact()
    expect_s3_class(comparison_result(), "gt_compare")
    expect_true(comparison_result()$inferential$test_used %in% c("Paired t-test", "Wilcoxon signed-rank test"))
  })
})
