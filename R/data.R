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

#' Oswego foodborne-outbreak line list
#'
#' A beginner-friendly copy of the 1940 Oswego County church-supper outbreak
#' line list supplied by the US Centers for Disease Control and Prevention
#' (CDC) with Epi Info. The 75 interview records are unchanged. Variable names
#' use snake case, `Y`/`N` values are labelled `Yes`/`No`, and variable labels
#' have been added.
#'
#' @format A data frame with 75 rows and 21 variables. It contains participant
#' age and sex, illness status and onset information, meal time, and indicators
#' for foods and drinks consumed. `ill` is the outcome; food variables such as
#' `vanilla_ice_cream` can be used as exposures.
#' @source CDC Epi Info teaching data, documented in the
#' [Epi Info 6 User's Guide](https://stacks.cdc.gov/view/cdc/23189/cdc_23189_DS1.pdf).
#' The source material is a US Government work available without charge. CDC
#' does not endorse gtstats. See the CDC
#' [agency materials policy](https://www.cdc.gov/other/agencymaterials.html).
#' @examples
#' epi_table(
#'   outbreak_data,
#'   outcomes = ill,
#'   by = vanilla_ice_cream,
#'   event = "Yes",
#'   measure = "attack_rate",
#'   p_value = TRUE,
#'   effects = "all"
#' )
"outbreak_data"

#' Archived weekly US hospital-admission surveillance data
#'
#' A teaching extract from CDC's archived weekly United States COVID-19
#' hospital-admission surveillance dataset. It contains one record per health
#' service area for the report dated 12 January 2024. The CDC county file
#' repeats the same area-level metrics for each constituent county; this copy
#' retains one exact metric record per health service area to prevent double
#' counting. Names and labels were simplified, dates were parsed, and the
#' source spelling `Insuficient Data` was corrected in the factor label.
#'
#' @format A data frame with 808 rows and 9 variables:
#' \describe{
#'   \item{health_service_area_id}{CDC health service area identifier.}
#'   \item{population}{Health service area population used as denominator.}
#'   \item{report_date}{CDC report date.}
#'   \item{week_end_date}{End date of the surveillance week.}
#'   \item{mmwr_week}{MMWR epidemiological week.}
#'   \item{mmwr_year}{MMWR year.}
#'   \item{admissions}{Weekly confirmed COVID-19 hospital admissions.}
#'   \item{admissions_per_100k}{CDC-published weekly rate per 100,000.}
#'   \item{admission_level}{CDC admission-level category.}
#' }
#' Two areas have insufficient admission data and therefore missing counts and
#' rates. The archived values are provisional teaching data and should not be
#' used to describe current disease activity.
#' @source CDC, [Weekly United States COVID-19 Hospitalization Metrics by
#' County - ARCHIVED](https://data.cdc.gov/d/akn2-qxic), dataset `akn2-qxic`.
#' The metadata identifies this dataset as `USGOV_WORKS`; it is available
#' without charge. CDC does not endorse gtstats. See the CDC
#' [agency materials policy](https://www.cdc.gov/other/agencymaterials.html).
#' @examples
#' \donttest{
#' complete_surveillance <- subset(surveillance_data, !is.na(admissions))
#' epi_table(
#'   complete_surveillance,
#'   numerator = admissions,
#'   denominator = population,
#'   label = admission_level,
#'   measure = "incidence_rate",
#'   multiplier = 100000
#' )
#' }
"surveillance_data"
