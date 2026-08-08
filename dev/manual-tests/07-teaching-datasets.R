## Manual real-time test: built-in teaching datasets
## Package: gtstats
##
## Purpose:
## Confirm that the three datasets load without optional dependencies and that
## their intended automatic-test branches remain stable. Run after
## devtools::load_all(".") during development, or library(gtstats) after install.

library(gtstats)

## 1. Load every built-in dataset ------------------------------------------------

data("birthwt", "trial_data", "paired_data", package = "gtstats")

str(birthwt)
str(trial_data)
str(paired_data)

stopifnot(
  nrow(birthwt) == 189L,
  nrow(trial_data) == 180L,
  nrow(paired_data) == 180L,
  is.ordered(birthwt$antenatal_visits),
  is.ordered(trial_data$response),
  all(table(paired_data$id) == 2L)
)

## 2. birthwt: real clinical Table 1 and a 2x2 epidemiology example ------------

describe_data(birthwt)

summary_table(
  birthwt,
  by = low,
  include = c(age, lwt, race, smoke, previous_preterm),
  overall = TRUE
) |>
  add_p()

crosstabs(birthwt, row = smoke, col = low, percent = c("row", "column"))

## 3. trial_data: independent parametric, rank, categorical and rate examples --

## Approximately symmetric continuous outcome across three arms: Welch ANOVA.
trial_parametric <- compare_groups(
  trial_data, variable = change_score, group = arm
)

## Right-skewed continuous outcome across three arms: Kruskal-Wallis.
trial_nonparametric <- compare_groups(
  trial_data, variable = hospital_days, group = arm
)

## Sparse binary outcome: Fisher exact test.
trial_sparse <- compare_groups(trial_data, variable = rare_event, group = arm)

## Ordered outcome: Kruskal-Wallis.
trial_ordinal <- compare_groups(trial_data, variable = response, group = arm)

## Correlation and person-time rate examples.
correlation(trial_data, x = biomarker_a, y = biomarker_b)
rate_stats(
  trial_data, event = infection_events, time = followup_years,
  by = arm, time_label = "person-years"
)

trial_parametric
trial_nonparametric
trial_sparse
trial_ordinal

stopifnot(
  trial_parametric$inferential$test_used[[1]] == "Welch ANOVA",
  trial_nonparametric$inferential$test_used[[1]] == "Kruskal-Wallis test",
  trial_sparse$inferential$test_used[[1]] == "Fisher's exact test",
  trial_ordinal$inferential$test_used[[1]] == "Kruskal-Wallis test"
)

## 4. paired_data: paired parametric, rank and categorical examples ------------

paired_parametric <- compare_groups(
  paired_data, variable = pain_score, group = visit, paired = TRUE, id = id
)
paired_nonparametric <- compare_groups(
  paired_data, variable = days_off_work, group = visit, paired = TRUE, id = id
)
paired_binary <- compare_groups(
  paired_data, variable = symptom_present, group = visit, paired = TRUE, id = id
)

paired_parametric
paired_nonparametric
paired_binary

stopifnot(
  paired_parametric$inferential$test_used[[1]] == "Paired t-test",
  paired_nonparametric$inferential$test_used[[1]] == "Wilcoxon signed-rank test",
  paired_binary$inferential$test_used[[1]] == "McNemar test"
)

## FEEDBACK:
## - Does each dataset make its intended teaching branch obvious?
## - Are the variable names and labels clinically understandable?
## - Would a learner know when to use real birthwt versus synthetic trial_data
##   or paired_data?
