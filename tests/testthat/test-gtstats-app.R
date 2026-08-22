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
  expect_match(app_text, "Create visual distribution diagnostics", fixed = TRUE)
  expect_match(app_text, "Q-Q plot", fixed = TRUE)
  expect_match(app_text, "Choose one view at a time", fixed = TRUE)
  expect_match(app_text, 'id = "understand_results_tab"', fixed = TRUE)
  expect_match(app_text, "download_plot_strip(\"distribution_plot\")", fixed = TRUE)
  expect_match(app_text, "download_strip(\"comparison_diagnostics\")", fixed = TRUE)
  expect_match(app_text, "download_strip(\"history\")", fixed = TRUE)
  expect_match(app_text, "Repeated measurements from the same participant", fixed = TRUE)
  expect_match(app_text, "Create comparison plot", fixed = TRUE)
  expect_match(app_text, "download_plot_strip(\"comparison_plot\")", fixed = TRUE)
  expect_match(app_text, "Cochran's Q test", fixed = TRUE)
  expect_match(app_text, "Summary table", fixed = TRUE)
  expect_match(app_text, "Summary-statistic overrides", fixed = TRUE)
  expect_match(app_text, "Default for continuous variables", fixed = TRUE)
  expect_match(app_text, "P-value test overrides", fixed = TRUE)
  expect_match(app_text, "Unlisted continuous variables use Recommended", fixed = TRUE)
  expect_match(app_text, "Build the foundation", fixed = TRUE)
  expect_match(app_text, "Choose how values are shown", fixed = TRUE)
  expect_match(app_text, "Add confidence intervals", fixed = TRUE)
  expect_match(app_text, "All eligible variables", fixed = TRUE)
  expect_match(app_text, "Add specialist ingredients", fixed = TRUE)
  expect_match(app_text, "Add statistical comparisons", fixed = TRUE)
  expect_match(app_text, "Advanced Auto-test settings", fixed = TRUE)
  expect_match(app_text, "Finish the appearance", fixed = TRUE)
  expect_match(app_text, "Customise table", fixed = TRUE)
  expect_match(app_text, "Refine your summary table", fixed = TRUE)
  expect_match(app_text, "most recently created Summary table", fixed = TRUE)
  expect_match(app_text, "Variable or row labels", fixed = TRUE)
  expect_match(app_text, "Spanning header", fixed = TRUE)
  expect_match(app_text, "Additional footnotes", fixed = TRUE)
  expect_match(app_text, "P-value display", fixed = TRUE)
  expect_match(app_text, 'pptx = "pptx"', fixed = TRUE)
  expect_match(app_text, "download_strip(\"customised\")", fixed = TRUE)
  expect_match(app_text, "Complete R script", fixed = TRUE)
  expect_match(app_text, "Correlation matrix", fixed = TRUE)
  expect_match(app_text, "Upper triangle (longest row first)", fixed = TRUE)
  expect_match(app_text, "Coefficient + adjusted p-value + pairwise n", fixed = TRUE)
  expect_match(app_text, "download_plot_strip(\"correlation_plot\")", fixed = TRUE)
  expect_match(app_text, "Tidy CSV", fixed = TRUE)
  expect_match(app_text, "Advanced matrix options", fixed = TRUE)
  expect_match(app_text, "Advanced plot appearance", fixed = TRUE)
  expect_match(app_text, "Negative-correlation colour", fixed = TRUE)
  expect_match(app_text, "Pairwise denominators differ", fixed = TRUE)
  expect_match(app_text, "Reset options", fixed = TRUE)
  prep_text <- paste(deparse(body(gtstats:::mod_data_prep_ui)), collapse = "\n")
  expect_match(prep_text, "Set display label", fixed = TRUE)
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
      distribution_plots = TRUE, distribution_plot_variable = "age",
      distribution_plot_type = "qq", distribution_shapiro = TRUE,
      distribution_skew_cutoff = 1, distribution_min_n = 3,
      distribution_digits = 2,
      run_distribution = 1
    )
    session$flushReact()
    expect_s3_class(diagnostic_result(), "gt_distribution")
    expect_s3_class(distribution_plot_result(), "ggplot")
    expect_match(understand_code(), "plots = TRUE", fixed = TRUE)

    session$setInputs(
      table_vars = c("age", "smoke"), table_group = "low",
      table_overall = "first", table_categorical = "n_percent",
      table_percent = "column",
      table_missing = "ifany", table_digits = 1, table_p = TRUE,
      table_stat_overrides = "age = mean_sd",
      table_test_overrides = "age = welch_t\nsmoke = fisher",
      table_theme = "journal",
      table_title = "Characteristics", table_subtitle = "GUI test",
      table_bold_labels = TRUE, table_footnotes = TRUE,
      table_striping = TRUE, table_font_size = 13, run_table = 1
    )
    session$flushReact()
    expect_s3_class(table_result(), "gt_desc_table")
    expect_s3_class(summary_display_result(), "gt_tbl")
    expect_identical(unname(table_result()$summary_statistics[["age"]]), "mean_sd")
    expect_true(all(c("Welch t-test", "Fisher's exact test") %in% table_result()$p_values$test))
    expect_match(summary_code(), '"age" = "mean_sd"', fixed = TRUE)
    expect_match(summary_code(), 'add_p(method = c(', fixed = TRUE)
    expect_match(summary_code(), 'customise_table(theme = "journal"', fixed = TRUE)
    expect_match(summary_code(), '"age" = "mean_sd"', fixed = TRUE)
    expect_s3_class(customised_display_result(), "gt_desc_table")

    session$setInputs(
      compare_variable = "age", compare_group = "low", compare_test = "auto",
      compare_effect = FALSE, compare_make_plot = TRUE,
      compare_plot_type = "auto", compare_plot_display = "proportion",
      compare_plot_points = TRUE, compare_plot_p = TRUE,
      compare_plot_size = 14, run_compare = 1
    )
    session$flushReact()
    expect_s3_class(comparison_result(), "gt_compare")
    expect_s3_class(comparison_diagnostics_result(), "gt_tbl")
    expect_s3_class(comparison_assumptions_result(), "gt_tbl")
    expect_s3_class(comparison_denominators_result(), "gt_tbl")
    expect_s3_class(comparison_plot_result(), "ggplot")
    expect_match(comparison_full_code(), "plot_compare", fixed = TRUE)

    session$setInputs(
      correlation_mode = "matrix",
      correlation_vars = c("age", "lwt", "bwt"),
      correlation_method = "auto", correlation_triangle = "upper",
      correlation_order = "alphabetical", correlation_diagonal = FALSE,
      correlation_display = "estimate_p_n", correlation_adjust = "holm",
      correlation_shade = TRUE, correlation_plot_values = TRUE,
      correlation_digits = 2, correlation_title = "Birth-weight correlations",
      correlation_caption = "Teaching example", correlation_plot_size = 15,
      correlation_conf_level = 0.95,
      correlation_low_color = "#355C7D", correlation_mid_color = "#FFFFFF",
      correlation_high_color = "#C06C5B",
      run_correlation = 1
    )
    session$flushReact()
    expect_s3_class(correlation_result(), "gt_correlation_matrix")
    expect_s3_class(correlation_plot_result(), "ggplot")
    expect_s3_class(correlation_diagnostics_result(), "gt_tbl")
    expect_s3_class(correlation_assumptions_result(), "gt_tbl")
    expect_s3_class(correlation_denominators_result(), "gt_tbl")
    expect_identical(correlation_result()$inputs$triangle, "upper")
    expect_false(correlation_result()$inputs$show_diagonal)
    expect_match(correlation_code(), 'display = "estimate_p_n"', fixed = TRUE)
    expect_match(correlation_code(), "plot_correlation", fixed = TRUE)
    expect_match(correlation_code(), 'low_color = "#355C7D"', fixed = TRUE)
    expect_match(correlation_code(), "base_size = 15", fixed = TRUE)
    expect_match(
      paste(unlist(output$correlation_selection_note), collapse = " "),
      "3 continuous variables selected", fixed = TRUE
    )

    session$setInputs(
      cross_row = "smoke", cross_col = "low", cross_percent = "column",
      cross_test = "auto", run_cross = 1
    )
    session$flushReact()
    expect_s3_class(crosstab_result(), "gt_twobytwo")

    session$setInputs(
      custom_theme = "journal",
      custom_title = "Peer-reviewed characteristics",
      custom_subtitle = "Custom GUI table",
      custom_col_labels = "Overall = All participants",
      custom_row_labels = "age = Maternal age",
      custom_level_labels = "Yes = Present\nNo = Absent",
      custom_source_note = "Prepared for review.",
      custom_bold_labels = TRUE, custom_footnotes = TRUE,
      custom_striping = TRUE, custom_font_size = 13,
      custom_hide_cols = "", run_customise = 1
    )
    session$flushReact()
    expect_s3_class(customised_result(), "gt_tbl")
    expect_match(customised_code(), "completed_table <- summary_table", fixed = TRUE)
    expect_match(customised_code(), 'theme = "journal"', fixed = TRUE)
    expect_match(customised_code(), '"age" = "Maternal age"', fixed = TRUE)
    expect_match(complete_script(), "summary_table", fixed = TRUE)
    expect_match(complete_script(), "compare_groups", fixed = TRUE)
    expect_match(complete_script(), "crosstabs", fixed = TRUE)
    expect_match(complete_script(), "correlation_result <- correlation", fixed = TRUE)
    expect_match(complete_script(), "Characteristics", fixed = TRUE)
    expect_match(complete_script(), "customised_table <- customise_table", fixed = TRUE)

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

test_that("summary-table override editors validate concise user input", {
  skip_if_not_installed("shiny")

  app_environment <- new.env(parent = globalenv())
  source(system.file("shiny", "app.R", package = "gtstats"),
    local = app_environment)

  selected <- c("age", "smoke")
  types <- c(age = "continuous", smoke = "binary")
  summary_allowed <- list(
    continuous = c("recommended", "mean_sd", "mean_ci", "median_iqr", "both"),
    binary = character()
  )
  test_allowed <- list(
    continuous = c("auto", "none", "welch_t", "t_test", "wilcox"),
    binary = c("auto", "none", "chisq", "fisher")
  )

  parsed_summary <- app_environment$parse_override_lines(
    "age = mean_sd", selected, types, summary_allowed, "summary statistic"
  )
  expect_identical(parsed_summary$values, c(age = "mean_sd"))
  expect_length(parsed_summary$errors, 0L)

  parsed_tests <- app_environment$parse_override_lines(
    "age = welch_t\nsmoke = none", selected, types, test_allowed, "test"
  )
  expect_identical(parsed_tests$values, c(age = "welch_t", smoke = "none"))
  expect_length(parsed_tests$errors, 0L)

  invalid <- app_environment$parse_override_lines(
    "weight = mean_sd\nsmoke = wilcox\nage = made_up",
    selected, types, summary_allowed, "summary statistic"
  )
  expect_length(invalid$errors, 3L)

  duplicated <- app_environment$parse_override_lines(
    "age = mean_sd\nage = median_iqr",
    selected, types, summary_allowed, "summary statistic"
  )
  expect_match(duplicated$errors, "listed more than once", fixed = TRUE)
})

test_that("the GUI recipe builds specialist proportion and rate tables", {
  skip_if_not_installed("shiny")

  app_environment <- new.env(parent = globalenv())
  source(system.file("shiny", "app.R", package = "gtstats"), local = app_environment)

  shiny::testServer(app_environment$server, {
    session$setInputs(data_source = "teaching", teaching_data = "birthwt")
    session$flushReact()
    session$setInputs(
      table_mode = "summary", table_group = "smoke", table_overall = "first",
      table_layout = "separate", table_include_summary = FALSE,
      table_add_total = FALSE, table_add_proportion = TRUE,
      table_prop_var = "low", table_prop_level = "Low birth weight",
      table_prop_settings = "inherit",
      table_prop_display = "n_percent", table_prop_ci = TRUE,
      table_prop_conf = 0.95, table_prop_ci_method = "wilson",
      table_prop_digits = 1, table_add_row = FALSE, table_p = FALSE,
      table_theme = "default", table_bold_labels = TRUE,
      table_footnotes = TRUE, table_striping = FALSE, table_font_size = 14,
      run_table = 1
    )
    session$flushReact()
    expect_s3_class(table_result(), "gt_desc_table")
    expect_identical(table_result()$layout, "separate")
    expect_identical(table_result()$components, "proportion")
    expect_match(summary_code(), 'by = smoke', fixed = TRUE)
    expect_match(summary_code(), 'layout = "separate"', fixed = TRUE)
    expect_match(summary_code(), 'add_proportion(', fixed = TRUE)
    expect_match(summary_code(), 'level = "Low birth weight"', fixed = TRUE)
    expect_false(grepl("display =", summary_code(), fixed = TRUE))
    expect_false(grepl("conf.level =", summary_code(), fixed = TRUE))
    expect_false(grepl("ci_method =", summary_code(), fixed = TRUE))
    expect_silent(parse(text = summary_code()))
    code_env <- list2env(list(data = selected_data()), parent = asNamespace("gtstats"))
    expect_s3_class(eval(parse(text = summary_code()), envir = code_env), "flextable")

    session$setInputs(data_source = "teaching", teaching_data = "trial_data")
    session$flushReact()
    session$setInputs(
      table_mode = "rate", table_group = "arm", table_overall = "first",
      table_layout = "separate", table_rate_event = "infection_events",
      table_rate_time = "followup_years", table_rate_label = "Infection rate",
      table_rate_multiplier = 1000, table_rate_time_label = "person-years",
      table_rate_ci = TRUE, table_rate_conf = 0.95, table_rate_digits = 1,
      table_add_rate = TRUE, table_add_proportion = FALSE,
      table_add_row = FALSE, run_table = 2
    )
    session$flushReact()
    expect_s3_class(table_result(), "gt_desc_table")
    expect_identical(table_result()$mode, "summary")
    expect_true("rate" %in% table_result()$components)
    expect_false(grepl('mode = "rate"', summary_code(), fixed = TRUE))
    expect_match(summary_code(), 'add_rate(', fixed = TRUE)
    expect_silent(parse(text = summary_code()))
    code_env <- list2env(list(data = selected_data()), parent = asNamespace("gtstats"))
    expect_s3_class(eval(parse(text = summary_code()), envir = code_env), "flextable")
  })
})

test_that("the GUI adds confidence intervals as a separate layer", {
  skip_if_not_installed("shiny")

  app_environment <- new.env(parent = globalenv())
  source(system.file("shiny", "app.R", package = "gtstats"), local = app_environment)

  shiny::testServer(app_environment$server, {
    session$setInputs(data_source = "teaching", teaching_data = "birthwt")
    session$flushReact()
    session$setInputs(
      table_mode = "summary", table_group = "low", table_overall = "first",
      table_layout = "separate", table_include_summary = TRUE,
      table_vars = c("age", "race"), table_stat_overrides = "",
      table_categorical = "n_percent", table_percent = "column",
      table_missing = "ifany", table_digits = 1,
      table_ci = TRUE, table_ci_scope = "selected", table_ci_vars = "race",
      table_ci_method = "wilson", table_conf_level = 0.95,
      table_add_total = FALSE, table_add_proportion = FALSE,
      table_add_row = FALSE, table_p = FALSE,
      table_theme = "default", table_bold_labels = TRUE,
      table_footnotes = TRUE, table_striping = FALSE, table_font_size = 14,
      run_table = 1
    )
    session$flushReact()

    expect_s3_class(table_result(), "gt_desc_table")
    expect_identical(table_result()$ci_variables, "race")
    expect_match(summary_code(), "|>\n  add_ci(", fixed = TRUE)
    expect_match(summary_code(), 'vars = c("race")', fixed = TRUE)
    expect_false(grepl("ci = TRUE", sub("\\|>.*", "", summary_code())))
    expect_silent(parse(text = summary_code()))
  })
})

test_that("the GUI generates separate categorical columns", {
  skip_if_not_installed("shiny")

  app_environment <- new.env(parent = globalenv())
  source(system.file("shiny", "app.R", package = "gtstats"), local = app_environment)

  shiny::testServer(app_environment$server, {
    session$setInputs(data_source = "teaching", teaching_data = "birthwt")
    session$flushReact()
    session$setInputs(
      table_group = "low", table_overall = "first",
      table_layout = "compact", table_include_summary = TRUE,
      table_vars = c("race", "smoke"), table_stat_overrides = "",
      table_categorical = "n_percent", table_categorical_layout = "separate",
      table_percent = "column", table_missing = "ifany", table_digits = 1,
      table_ci = FALSE, table_add_total = FALSE,
      table_add_proportion = FALSE, table_add_rate = FALSE,
      table_add_row = FALSE, table_p = FALSE,
      table_theme = "default", table_bold_labels = TRUE,
      table_footnotes = TRUE, table_striping = FALSE, table_font_size = 14,
      run_table = 1
    )
    session$flushReact()

    expect_identical(table_result()$categorical_layout, "separate")
    expect_true(all(table_result()$display_columns$estimate_label == "n"))
    expect_true(all(table_result()$display_columns$ci_label == "%"))
    expect_match(summary_code(), 'categorical_layout = "separate"', fixed = TRUE)
    expect_silent(parse(text = summary_code()))
  })
})

test_that("the GUI builds compact dichotomous summaries and reproducible code", {
  skip_if_not_installed("shiny")

  app_environment <- new.env(parent = globalenv())
  source(system.file("shiny", "app.R", package = "gtstats"), local = app_environment)

  shiny::testServer(app_environment$server, {
    session$setInputs(data_source = "teaching", teaching_data = "birthwt")
    session$flushReact()
    session$setInputs(
      table_group = "low", table_overall = "first",
      table_layout = "compact", table_include_summary = TRUE,
      table_vars = c("smoke", "ht", "race"), table_stat_overrides = "",
      table_categorical = "n_percent", table_categorical_layout = "combined",
      table_dichotomous = "single_row",
      table_dichotomous_values = "smoke = Yes\nht = Yes",
      table_percent = "column", table_missing = "ifany", table_digits = 1,
      table_ci = FALSE, table_add_total = FALSE,
      table_add_proportion = FALSE, table_add_rate = FALSE,
      table_add_row = FALSE, table_p = FALSE,
      table_theme = "default", table_bold_labels = TRUE,
      table_footnotes = TRUE, table_striping = FALSE, table_font_size = 14,
      run_table = 1
    )
    session$flushReact()

    expect_identical(table_result()$show_dichotomous, "single_row")
    expect_identical(table_result()$dichotomous_values, c(smoke = "Yes", ht = "Yes"))
    expect_equal(sum(table_result()$table$Variable == "Smoking during pregnancy"), 1L)
    expect_match(summary_code(), 'show_dichotomous = "single_row"', fixed = TRUE)
    expect_match(summary_code(), 'value = c("smoke" = "Yes", "ht" = "Yes")', fixed = TRUE)
    expect_silent(parse(text = summary_code()))
  })
})
