test_that("built-in teaching datasets load and retain their teaching structure", {
  data(
    "birthwt", "trial_data", "paired_data", "outbreak_data",
    "surveillance_data", package = "gtstats"
  )

  expect_s3_class(birthwt, "data.frame")
  expect_equal(nrow(birthwt), 189L)
  expect_true(is.factor(birthwt$low))
  expect_true(is.ordered(birthwt$antenatal_visits))

  expect_equal(nrow(trial_data), 180L)
  expect_equal(nlevels(trial_data$arm), 3L)
  expect_true(is.ordered(trial_data$response))

  expect_equal(nrow(paired_data), 180L)
  expect_true(all(table(paired_data$id) == 2L))

  expect_equal(dim(outbreak_data), c(75L, 21L))
  expect_identical(levels(outbreak_data$ill), c("No", "Yes"))
  expect_equal(as.vector(table(outbreak_data$ill)), c(29L, 46L))

  expect_equal(dim(surveillance_data), c(808L, 9L))
  expect_true(inherits(surveillance_data$report_date, "Date"))
  expect_equal(sum(is.na(surveillance_data$admissions)), 2L)
  expect_false(anyDuplicated(surveillance_data$health_service_area_id) > 0L)
})

test_that("real CDC teaching data exercise both epi_table routes", {
  data("outbreak_data", "surveillance_data", package = "gtstats")

  outbreak <- epi_table(
    outbreak_data, outcomes = ill, by = vanilla_ice_cream,
    event = "Yes", measure = "attack_rate", p_value = TRUE, effects = "all"
  )
  expect_equal(outbreak$summary$cases, c(3, 43))
  expect_equal(outbreak$summary$denominator, c(21, 54))
  expect_equal(sort(outbreak$effects$measure), c("OR", "RD", "RR"))

  complete_surveillance <- subset(surveillance_data, !is.na(admissions))
  surveillance <- epi_table(
    complete_surveillance,
    numerator = admissions,
    denominator = population,
    label = admission_level,
    measure = "incidence_rate",
    multiplier = 100000
  )
  expect_equal(sum(surveillance$summary$cases), 35138)
  expect_equal(sum(surveillance$summary$denominator), 331741338)
  expect_true(all(is.finite(surveillance$summary$estimate)))
})

test_that("synthetic datasets retain their intended automatic-test examples", {
  data("trial_data", "paired_data", package = "gtstats")

  expect_identical(
    compare_groups(trial_data, variable = change_score, group = arm)$inferential$test_used[[1]],
    "Welch ANOVA"
  )
  expect_identical(
    compare_groups(trial_data, variable = hospital_days, group = arm)$inferential$test_used[[1]],
    "Kruskal-Wallis test"
  )
  expect_identical(
    compare_groups(paired_data, variable = days_off_work, group = visit, paired = TRUE, id = id)$inferential$test_used[[1]],
    "Wilcoxon signed-rank test"
  )
})
