#' Low birth weight data
#'
#' A labelled and analysis-ready version of the low birth weight study data.
#' It contains 189 observations and is derived from the dataset distributed in
#' `MASS`, originally reported by Hosmer and Lemeshow. Numeric clinical codes
#' have been converted to readable factors; `antenatal_visits` is an ordered
#' factor and the original numeric variables are retained.
#'
#' @format A data frame with 189 rows and 12 variables:
#' \describe{
#'   \item{low}{Birth-weight outcome: Normal birth weight or Low birth weight.}
#'   \item{age}{Maternal age in years.}
#'   \item{lwt}{Maternal weight in pounds.}
#'   \item{race}{Maternal race.}
#'   \item{smoke}{Smoking during pregnancy.}
#'   \item{ptl}{Number of previous premature labours.}
#'   \item{ht}{History of hypertension.}
#'   \item{ui}{Uterine irritability.}
#'   \item{ftv}{Number of first-trimester physician visits.}
#'   \item{bwt}{Birth weight in grams.}
#'   \item{previous_preterm}{Any previous premature labour.}
#'   \item{antenatal_visits}{Ordered visit category.}
#' }
#' @source Hosmer, D. W. and Lemeshow, S. (1989). *Applied Logistic
#' Regression*. Derived from `MASS::birthwt`.
#' @examples
#' describe_data(birthwt)
#' summary_table(birthwt, by = low, include = c(age, lwt, smoke), overall = TRUE)
"birthwt"

#' Three-arm clinical trial teaching data
#'
#' Simulated data for demonstrating independent-group analyses. The dataset is
#' intentionally constructed to include approximately symmetric continuous
#' outcomes, a right-skewed outcome, an ordinal outcome, common and rare binary
#' outcomes, correlated biomarkers, and person-time with event counts.
#'
#' @format A data frame with 180 rows and 13 variables. `arm` has three groups;
#' `change_score` is approximately symmetric; `hospital_days` is right-skewed;
#' `response` is ordered; `rare_event` is sparse; and `followup_years` with
#' `infection_events` supports rate examples.
#' @examples
#' compare_groups(trial_data, variable = change_score, group = arm)
#' compare_groups(trial_data, variable = hospital_days, group = arm)
#' compare_groups(trial_data, variable = rare_event, group = arm)
"trial_data"

#' Paired follow-up teaching data
#'
#' Simulated long-format data for paired analyses. Each participant has a
#' Baseline and Follow-up record. `pain_score` supports a paired t-test example,
#' `days_off_work` is skewed for a signed-rank example, and `symptom_present`
#' supports McNemar's test.
#'
#' @format A data frame with 180 rows (90 complete pairs) and 5 variables:
#' `id`, `visit`, `pain_score`, `days_off_work`, and `symptom_present`.
#' @examples
#' compare_groups(
#'   paired_data, variable = pain_score, group = visit,
#'   paired = TRUE, id = id
#' )
#' compare_groups(
#'   paired_data, variable = symptom_present, group = visit,
#'   paired = TRUE, id = id
#' )
"paired_data"
