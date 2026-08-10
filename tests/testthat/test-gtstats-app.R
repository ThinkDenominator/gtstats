test_that("the Shiny app is bundled with gtstats", {
  expect_true(file.exists(system.file("shiny", "app.R", package = "gtstats")))
  expect_true(is.function(gtstats_app))

  app_text <- paste(readLines(system.file("shiny", "app.R", package = "gtstats")), collapse = "\n")
  expect_match(app_text, "Select variables to summarise", fixed = TRUE)
  expect_match(app_text, "Data dictionary", fixed = TRUE)
  expect_match(app_text, "Download .R", fixed = TRUE)
  expect_match(app_text, "Upload a CSV or Excel file", fixed = TRUE)
})

test_that("the GUI runs the core birth-weight workflow", {
  skip_if_not_installed("shiny")

  app_environment <- new.env(parent = globalenv())
  source(system.file("shiny", "app.R", package = "gtstats"),
    local = app_environment)

  shiny::testServer(app_environment$server, {
    session$setInputs(data_source = "birthwt")
    session$flushReact()
    expect_equal(nrow(selected_data()), 189L)

    session$setInputs(run_describe = 1)
    session$flushReact()
    expect_s3_class(described(), "gt_describe")

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

    session$setInputs(
      cross_row = "smoke", cross_col = "low", cross_percent = "column",
      cross_test = "auto", run_cross = 1
    )
    session$flushReact()
    expect_s3_class(crosstab_result(), "gt_twobytwo")
  })
})
