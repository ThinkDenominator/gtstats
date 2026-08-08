test_that("built-in teaching datasets load and retain their teaching structure", {
  data("birthwt", "trial_data", "paired_data", package = "gtstats")

  expect_s3_class(birthwt, "data.frame")
  expect_equal(nrow(birthwt), 189L)
  expect_true(is.factor(birthwt$low))
  expect_true(is.ordered(birthwt$antenatal_visits))

  expect_equal(nrow(trial_data), 180L)
  expect_equal(nlevels(trial_data$arm), 3L)
  expect_true(is.ordered(trial_data$response))

  expect_equal(nrow(paired_data), 180L)
  expect_true(all(table(paired_data$id) == 2L))
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
