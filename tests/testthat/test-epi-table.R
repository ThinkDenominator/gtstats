test_that("epi_table line-list route uses explicit non-missing denominators", {
  data <- data.frame(
    outcome = factor(c("No", "Yes", "Yes", NA), levels = c("No", "Yes")),
    ward = factor(c("A", "A", "B", "B"), levels = c("B", "A"))
  )
  result <- epi_table(data, outcomes = outcome, by = ward, event = "Yes", measure = "attack_rate")
  expect_s3_class(result, "gt_epi_table")
  expect_equal(result$summary$group, c("B", "A"))
  expect_equal(result$summary$cases, c(1, 1))
  expect_equal(result$summary$denominator, c(1, 2))
  expect_true(all(is.finite(result$summary$conf_low)))
})

test_that("epi_table supports multiple line-list outcomes and named events", {
  data <- data.frame(a = c("No", "Yes", "Yes"), b = c(0, 1, 0))
  result <- epi_table(data, outcomes = c(a, b), event = c(a = "Yes", b = "1"))
  expect_equal(result$summary$cases, c(2, 1))
  expect_equal(result$summary$denominator, c(3, 3))
})

test_that("epi_table aggregate route validates numerator and denominator", {
  data <- data.frame(ward = c("A", "B"), cases = c(12, 7), population = c(80, 65))
  result <- epi_table(data, numerator = cases, denominator = population, by = ward,
    label = "Influenza", measure = "attack_rate", p_value = TRUE, effects = "all")
  expect_equal(result$summary$estimate, 100 * data$cases / data$population)
  expect_equal(nrow(result$effects), 3L)
  expect_true(is.finite(result$p_values$p_value))
  expect_error(epi_table(transform(data, cases = c(90, 7)), numerator = cases, denominator = population), "must not exceed")
  expect_error(epi_table(transform(data, population = c(0, 65)), numerator = cases, denominator = population), "positive")
})

test_that("epi_table incidence rates use exact Poisson intervals", {
  data <- data.frame(site = c("A", "B"), events = c(5, 9), time = c(1200, 1800))
  result <- epi_table(data, numerator = events, denominator = time, by = site,
    label = "Infection", measure = "incidence_rate", multiplier = 1000,
    p_value = TRUE, effects = "all")
  expect_equal(result$summary$estimate, c(5 / 1200, 9 / 1800) * 1000)
  expect_equal(result$effects$measure, "IRR")
  expect_match(result$notes[[1]], "exact Poisson")
})

test_that("epi_table refuses ambiguous and case-only inputs", {
  data <- data.frame(case = rep("Yes", 4), n = 1:4, d = 5:8)
  expect_error(epi_table(data), "No epidemiology ingredients")
  expect_error(epi_table(data, outcomes = case, numerator = n, denominator = d), "Choose one data structure")
  expect_error(epi_table(data, outcomes = case, event = "Yes", measure = "attack_rate"), "does not contain both event and non-event")
})

test_that("epi_table renders and exports through the shared contracts", {
  data <- data.frame(outcome = c("No", "Yes", "Yes"))
  result <- epi_table(data, outcomes = outcome, event = "Yes")
  expect_s3_class(to_flextable(result), "flextable")
  expect_s3_class(to_gt(result), "gt_tbl")
  expect_s3_class(epi_table(data, outcomes = outcome, event = "Yes", format = "tibble"), "tbl_df")
  expect_s3_class(denominators_stats(result, format = "tibble"), "tbl_df")
})
