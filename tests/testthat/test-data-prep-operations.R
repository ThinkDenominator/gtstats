test_that("internal data-prep operations are safe and report their effects", {
  data <- data.frame(age = c(20, 30, 999), sex = c("M", "F", "Unknown"), stringsAsFactors = FALSE)

  renamed <- gtstats:::gt_dp_rename(data, "age", "age_years")
  expect_true("age_years" %in% names(renamed))
  expect_error(gtstats:::gt_dp_rename(data, "age", "sex"), "already exists")

  recoded <- gtstats:::gt_dp_recode(data, "sex", c("M", "F"), c("Male", "Female"))
  expect_equal(recoded$sex[1:2], c("Male", "Female"))
  expect_equal(attr(recoded, "gt_dp_affected"), 2)

  missing <- gtstats:::gt_dp_define_missing(data, "age", "999")
  expect_true(is.na(missing$age[[3L]]))
  expect_equal(attr(missing, "gt_dp_affected"), 1)

  data_with_na <- data
  data_with_na$sex[[2L]] <- NA_character_
  shown_missing <- gtstats:::gt_dp_show_missing(data_with_na, "sex", "Missing")
  expect_true(is.factor(shown_missing$sex))
  expect_equal(as.character(shown_missing$sex[[2L]]), "Missing")
  expect_equal(attr(shown_missing, "gt_dp_affected"), 1)
  expect_error(gtstats:::gt_dp_show_missing(data, "sex", "Missing"), "no missing values")

  ordered <- gtstats:::gt_dp_set_type(data, "sex", "ordered", c("F", "M", "Unknown"))
  expect_true(is.ordered(ordered$sex))
  expect_equal(levels(ordered$sex), c("F", "M", "Unknown"))
  expect_error(gtstats:::gt_dp_set_type(data, "sex", "numeric"), "cannot safely")

  reduced <- gtstats:::gt_dp_keep_variables(data, c("age", "sex"))
  expect_identical(names(reduced), c("age", "sex"))

  filtered <- gtstats:::gt_dp_filter(data, "age", ">=", "25")
  expect_equal(nrow(filtered), 2L)
  expect_equal(unname(attr(filtered, "gt_dp_filter_counts")["before"]), 3L)

  transformed <- gtstats:::gt_dp_transform_arithmetic(data, "age", "age_plus_one", "+", 1)
  expect_equal(transformed$age_plus_one[[1L]], 21)
  body_data <- data.frame(weight_kg = c(70, 80), height_m = c(1.75, 1.80))
  bmi <- gtstats:::gt_dp_calculate(body_data, "weight_kg", "bmi", "ratio_power", number = 2, second = "height_m")
  expect_equal(round(bmi$bmi[[1L]], 1), 22.9)
  total <- gtstats:::gt_dp_calculate(body_data, "weight_kg", "combined", "two_variables", operator = "+", second = "height_m")
  expect_equal(total$combined[[1L]], 71.75)
  indicator <- gtstats:::gt_dp_transform_arithmetic(data, "age", "age_25_or_older", ">=", 25)
  expect_identical(indicator$age_25_or_older, c(FALSE, TRUE, TRUE))
  conditional <- gtstats:::gt_dp_transform_case_when(
    data, "age_group", "age", ">=", "25", "Older", "Younger"
  )
  expect_equal(conditional$age_group[1:2], c("Younger", "Older"))
})

test_that("Data Prep group rules support numeric ranges and protect empty groups", {
  data <- data.frame(age = c(18, 35, 36, 65, 66, NA), group = c("a", "b", "a", "b", "a", "b"))

  expect_identical(
    gtstats:::gt_dp_condition(data, "age", ">=", "65"),
    c(FALSE, FALSE, FALSE, TRUE, TRUE, NA)
  )
  expect_identical(
    gtstats:::gt_dp_condition(data, "age", "<=", "35"),
    c(TRUE, TRUE, FALSE, FALSE, FALSE, NA)
  )
  expect_identical(
    gtstats:::gt_dp_condition(data, "age", "between", "36", "65"),
    c(FALSE, FALSE, TRUE, TRUE, FALSE, NA)
  )
  expect_identical(
    gtstats:::gt_dp_condition(data, "age", "outside", "36", "65"),
    c(TRUE, TRUE, FALSE, FALSE, TRUE, NA)
  )
  expect_error(gtstats:::gt_dp_condition(data, "age", "between", "65", "36"), "lower bound")
  expect_error(gtstats:::gt_dp_condition(data, "age", "outside", "36", ""), "finite numeric")
  expect_error(gtstats:::gt_dp_condition(data, "group", "between", "1", "2"), "only with numeric")

  grouped <- gtstats:::gt_dp_transform_case_when(
    data, "age_band", c("age", "age"), c("<=", "between"), c("35", "36"),
    c("Young", "Middle-aged"), "Older", c("", "65")
  )
  expect_identical(grouped$age_band[1:5], c("Young", "Young", "Middle-aged", "Middle-aged", "Older"))
  expect_equal(as.integer(attr(grouped, "gt_dp_group_counts")), c(2L, 2L, 2L))

  first_match <- gtstats:::gt_dp_transform_case_when(
    data.frame(age = c(10, 30, 70)), "band", c("age", "age"), c(">=", ">="),
    c("65", "18"), c("Older", "Adult"), "Younger", c("", "")
  )
  expect_identical(first_match$band, c("Younger", "Adult", "Older"))

  expect_error(
    gtstats:::gt_dp_transform_case_when(data, "empty_band", "age", ">", "100", "Never", "Everyone else"),
    "zero observations"
  )
})

test_that("Data Prep direct actions expose working transform and filter routes", {
  skip_if_not_installed("shiny")
  source_data <- shiny::reactiveVal(data.frame(
    age = c(16, 20, 70),
    consent = c("No", "Yes", "Yes"),
    stringsAsFactors = FALSE
  ))

  shiny::testServer(gtstats:::mod_data_prep_server, args = list(source_data = source_data), {
    session$flushReact()

    session$setInputs(menu_recode = 1)
    session$flushReact()
    session$setInputs(
      variable = "consent",
      recode_to_1 = "No",
      recode_to_2 = "Yes",
      recode_ordered = FALSE,
      apply = 1
    )
    session$flushReact()
    expect_true(is.factor(session$returned$working_data()$consent))
    expect_false(is.ordered(session$returned$working_data()$consent))

    session$setInputs(menu_calculation = 1)
    session$flushReact()
    session$setInputs(
      transform_source = "age",
      calculation_mode = "single",
      transform_operator = "+",
      transform_number = 1,
      transform_new = "age_plus_one",
      apply = 2
    )
    session$flushReact()
    expect_equal(session$returned$working_data()$age_plus_one, c(17, 21, 71))

    session$setInputs(menu_groups = 1)
    session$flushReact()
    session$setInputs(
      group_variable = "age",
      group_count = "2",
      rule_op_1 = ">=",
      rule_value_1 = "65",
      rule_result_1 = "Older adult",
      rule_default = "Younger adult",
      transform_new = "age_group",
      apply = 3
    )
    session$flushReact()
    expect_identical(session$returned$working_data()$age_group, c("Younger adult", "Younger adult", "Older adult"))

    session$setInputs(
      group_count = "3",
      rule_op_1 = "<",
      rule_value_1 = "18",
      rule_result_1 = "Under 18",
      rule_op_2 = ">=",
      rule_value_2 = "65",
      rule_result_2 = "65 or older",
      rule_default = "18 to 64",
      transform_new = "age_group_3",
      apply = 4
    )
    session$flushReact()
    expect_identical(session$returned$working_data()$age_group_3, c("Under 18", "18 to 64", "65 or older"))

    session$setInputs(menu_type = 1)
    session$flushReact()
    session$setInputs(
      variable = "consent",
      variable_type = "ordered",
      type_rank_1 = "1",
      type_rank_2 = "2",
      apply = 5
    )
    session$flushReact()
    expect_true(is.ordered(session$returned$working_data()$consent))

    session$setInputs(menu_keep = 1)
    session$flushReact()
    session$setInputs(keep_vars = c("age", "consent"), apply = 6)
    session$flushReact()
    expect_identical(names(session$returned$working_data()), c("age", "consent"))

    session$setInputs(menu_filter = 1)
    session$flushReact()
    session$setInputs(
      variable1 = "age",
      operator1 = ">=",
      value1 = "18",
      filter_second = TRUE
    )
    session$flushReact()
    session$setInputs(
      variable2 = "consent",
      operator2 = "==",
      value2 = "Yes",
      connector = "AND",
      apply = 7
    )
    session$flushReact()
    expect_equal(session$returned$working_data()$age, c(20, 70))
  })
})
