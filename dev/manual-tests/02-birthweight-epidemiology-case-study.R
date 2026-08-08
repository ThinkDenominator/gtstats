## Manual real-time test: birthweight epidemiology case study
## Package: gtstats 1.0.0
##
## Story:
## A maternity team wants absolute risks and comparative measures for smoking
## and low birth weight. This script reviews the focused epidemiology functions
## and the separate rate-table builder.
##
## How to use:
## Run this script section by section and inspect every returned component.
## Comments marked FEEDBACK identify useful peer-review questions.


## 0. Setup -------------------------------------------------------------------

## During package development:
## devtools::load_all(".")
library(gtstats)
library(dplyr)
data("birthwt", package = "gtstats")
birthwt_data <- birthwt
birthwt_source <- "gtstats::birthwt"


## 1. Proportion with confidence interval ------------------------------------

## Question:
## What proportion of births had low birth weight, overall and by smoking?
low_birthweight_risk <- proportion_stats(
  birthwt_data,
  var = low,
  level = "Low birth weight",
  by = smoke
)

low_birthweight_risk
low_birthweight_risk$summary
low_birthweight_risk$inputs
low_birthweight_risk$assumptions
low_birthweight_risk$diagnostics
low_birthweight_risk$denominators
low_birthweight_risk$notes

tbl_stats(
  low_birthweight_risk,
  title = "Risk of low birth weight by smoking",
  subtitle = birthwt_source
)

## Overall risk without grouping.
proportion_stats(
  birthwt_data,
  var = low,
  level = "Low birth weight"
)

## DISPLAY OPTIONS
## `n_percent` is the publication default: event count and percentage, with
## Wilson 95% CI. `N` remains a separate denominator column.
proportion_stats(
  birthwt_data,
  var = low,
  by = smoke,
  level = "Low birth weight",
  display = "n_percent"
)

## Percentage only. Useful when counts are reported elsewhere.
proportion_stats(
  birthwt_data,
  var = low,
  by = smoke,
  level = "Low birth weight",
  display = "percent",
  digits = 2
)

## Explicit event/denominator display and exact binomial intervals.
proportion_stats(
  birthwt_data,
  var = low,
  by = smoke,
  level = "Low birth weight",
  display = "n_over_N_percent",
  ci_method = "exact"
)

## AUTOMATIC EVENT SELECTION
## When `level` is omitted, inspect `$inputs$level` and the table footnote.
## Explicitly name the event for final clinical reporting.
automatic_event <- proportion_stats(birthwt_data, var = low, by = smoke)
automatic_event
automatic_event$inputs$level

## BUILDER ALIGNMENT
## The same CI and display choices work inside summary_table().
summary_table(birthwt_data, by = smoke, overall = "first") |>
  add_proportion(
    var = low,
    #level = "Low birth weight",
    display = "n_over_N_percent",
    ci_method = "wilson"
  )

## ROBUST EDGE CASES
edge_proportions <- data.frame(
  event = factor(c("No", "No", "Yes", "Yes", NA)),
  group = factor(c("No events", "No events", "All events", "All events", "Missing"))
)
proportion_stats(
  edge_proportions,
  var = event,
  by = group,
  level = "Yes"
)

## FEEDBACK:
## - Is "proportion_stats" an understandable function name?
## - Are count, denominator, percentage and confidence interval all visible?
## - Is `n_percent` the right default?
## - Is the selected event level sufficiently prominent?
## - Would you choose Wilson or exact intervals for routine reporting?


## 2. Two-by-two measures -----------------------------------------------------

## Question:
## How much higher is low-birth-weight risk among mothers who smoked?
smoking_twobytwo <- crosstabs(
  birthwt_data,
  row = smoke,
  col = low,
  row_level = "Yes",
  col_level = "Low birth weight"
)

smoking_twobytwo
smoking_twobytwo$summary
smoking_twobytwo$inputs
smoking_twobytwo$method
smoking_twobytwo$assumptions
smoking_twobytwo$diagnostics
smoking_twobytwo$denominators
smoking_twobytwo$notes

## Confirm the actual exposed/event levels even when they are chosen
## automatically. The audit also retains expected counts and zero-cell details
## without adding them to the publication table.
smoking_twobytwo$inputs$row_level
smoking_twobytwo$inputs$col_level
diagnostics_stats(smoking_twobytwo)

tbl_stats(
  smoking_twobytwo,
  title = "Smoking and low birth weight"
)

## General cross-tabs: the same function supports 3x2 and 3x3 tables.
## Default cells are n (column %), which is useful for comparing the
## composition of outcome groups. Totals are included automatically.
crosstabs(birthwt_data, row = race, col = low)

## A row percentage answers a different question: within each race, what
## proportion had low birth weight? Both denominators can be displayed for
## exploratory work or supplementary material.
crosstabs(birthwt_data, row = race, col = ptl, percent = "row")
crosstabs(
  birthwt_data,
  row = race,
  col = ptl,
  percent = c("row", "column")
)

## The default is intentionally concise: risk, risk ratio and risk difference.
## Request an odds ratio only when it answers the study question, for example
## in a case-control analysis where risks cannot be estimated from the sample.
crosstabs(
  birthwt_data,
  row = smoke,
  col = low,
  row_level = "Yes",
  col_level = "Low birth weight",
  measures = "or",
  test = "none"
)

## Exact binomial risk intervals are available when a reporting standard
## requires them; Wilson intervals are the recommended routine default.
crosstabs(
  birthwt_data,
  row = smoke,
  col = low,
  row_level = "Yes",
  col_level = "Low birth weight",
  risk_ci = "exact"
)

## Reversing the requested levels reverses the scientific contrast. This is a
## useful manual check that the displayed group labels and effect direction
## remain transparent.
crosstabs(
  birthwt_data,
  row = smoke,
  col = low,
  row_level = "No",
  col_level = "Normal birth weight"
)

## Sparse cells should make test = "auto" select Fisher's exact test.
sparse_twobytwo <- data.frame(
  exposure = factor(c(rep("No", 20), rep("Yes", 8)),
                    levels = c("No", "Yes")),
  outcome = factor(c(rep("No", 19), "Yes", rep("No", 4), rep("Yes", 4)),
                   levels = c("No", "Yes"))
)
crosstabs(sparse_twobytwo, exposure, outcome)

## A zero cell should trigger the named Haldane-Anscombe correction for ratio
## measures, and the correction should be disclosed in the table footnote.
zero_cell_twobytwo <- data.frame(
  row = factor(rep(c("No", "Yes"), each = 10),
                    levels = c("No", "Yes")),
  col = factor(c(rep("No", 10), rep(c("No", "Yes"), c(5, 5))),
                   levels = c("No", "Yes"))
)
crosstabs(
  zero_cell_twobytwo,
  row,
  col,
  measures = c("risk", "rr", "or", "rd")
)

## With correction disabled, a ratio may be zero or infinite and its
## log-scale confidence interval may be unavailable.
crosstabs(
  zero_cell_twobytwo,
  row,
  col,
  measures = c("rr", "or"),
  zero_correction = "none"
)

## Only rows with both exposure and outcome observed enter the 2 x 2 table.
missing_pair_twobytwo <- sparse_twobytwo
missing_pair_twobytwo$exposure[1] <- NA
missing_pair_twobytwo$outcome[2] <- NA
crosstabs(missing_pair_twobytwo, exposure, outcome)

## FEEDBACK:
## - Are exposed and outcome reference levels sufficiently explicit?
## - Is risk difference understandable in percentage points?
## - Is the compact default preferable to showing the odds ratio routinely?
## - Does the sparse-table output clearly identify Fisher's exact test?
## - Is the zero-cell correction disclosure concise but sufficient?


## 3. Add a highlighted proportion to the summary table ----------------------

## This demonstrates that add_proportion() adds a new row; it does not replace
## the ordinary categorical summary rows created by add_summary().
smoking_summary <- summary_table(
  birthwt_data,
  by = smoke,
  overall = TRUE
) |>
  add_total(label = "Participants, N", position = "first") |>
  add_summary(vars = low) |>
  add_proportion(
    var = low,
    level = "Low birth weight",
    label = "Low-birth-weight risk",
    ci = TRUE
  ) |>
  add_p()

smoking_summary
smoking_summary$table
smoking_summary$pvalue_method_footnotes
smoking_summary$assumption_notes
tbl_stats(
  smoking_summary,
  title = "Low-birth-weight risk by smoking status"
)

## FEEDBACK:
## - Is the additional highlighted row useful or repetitive?
## - Should confidence intervals be optional or shown by default?


## 4. Illustrative rate workflow ---------------------------------------------

## The birthweight study is cross-sectional, so it does not contain genuine
## person-time. The variables below are created only to test the rate API:
## one birth contributes one unit of observation time.
rate_data <- birthwt_data |>
  mutate(
    low_birthweight_events = as.integer(low == "Low birth weight"),
    births_observed = 1
  )

low_birthweight_rate <- rate_stats(
  rate_data,
  event = low_birthweight_events,
  time = births_observed,
  by = smoke,
  multiplier = 100,
  time_label = "births observed"
)

low_birthweight_rate
low_birthweight_rate$summary
low_birthweight_rate$inputs
low_birthweight_rate$notes
tbl_stats(
  low_birthweight_rate,
  title = "Low-birth-weight events per 100 births"
)

## Build a rate table row incrementally. Rate mode is kept separate from the
## summary-table components because rates use event and denominator totals.
low_birthweight_rate_table <- summary_table(
  rate_data,
  by = smoke,
  mode = "rate",
  overall = TRUE
) |>
  add_rate(
    event = low_birthweight_events,
    time = births_observed,
    label = "Low-birth-weight events per 100 births",
    multiplier = 100,
    time_label = "births observed",
    ci = TRUE
  )

low_birthweight_rate_table
low_birthweight_rate_table$table
tbl_stats(
  low_birthweight_rate_table,
  title = "Illustrative rate-builder output"
)

## FEEDBACK:
## - Is the distinction between a proportion and a rate clear?
## - Does mode = "rate" make the builder safer or more complicated?
## - Does the custom time unit make the rate denominator unambiguous?

## TRUE PERSON-TIME EXAMPLE
## Recurrent event counts and unequal follow-up demonstrate the intended use.
person_time_data <- data.frame(
  arm = factor(
    c("Usual care", "Usual care", "Intervention", "Intervention"),
    levels = c("Usual care", "Intervention")
  ),
  admissions = c(3, 1, 1, 0),
  follow_up_years = c(1.8, 2.0, 1.9, 2.0)
)
admission_rate <- rate_stats(
  person_time_data,
  event = admissions,
  time = follow_up_years,
  by = arm,
  multiplier = 100,
  time_label = "person-years"
)
admission_rate
admission_rate$table
admission_rate$denominators
admission_rate$diagnostics

## MISSING PAIRS
## Only records with both event and time are used. Confirm that events and time
## are not summed from different records.
missing_pair_data <- data.frame(
  events = c(1, 2, NA, 4),
  person_years = c(10, NA, 30, 40)
)
missing_pair_rate <- rate_stats(
  missing_pair_data,
  event = events,
  time = person_years,
  multiplier = 100,
  time_label = "person-years"
)
missing_pair_rate
missing_pair_rate$denominators

## ZERO EVENTS AND ZERO TIME
rate_stats(
  data.frame(events = c(0, 0), person_years = c(2, 3)),
  event = events,
  time = person_years,
  time_label = "person-years"
)
zero_time_review <- rate_stats(
  data.frame(events = c(1, 0), person_years = c(0, 2)),
  event = events,
  time = person_years,
  time_label = "person-years"
)
zero_time_review$diagnostics

## A group with no accumulated time is retained, but its rate is not estimable.
zero_total_time <- rate_stats(
  data.frame(events = c(1, 0), person_years = c(0, 0)),
  event = events,
  time = person_years,
  time_label = "person-years"
)
zero_total_time
zero_total_time$diagnostics


## 5. Optional export ---------------------------------------------------------

## Uncomment after choosing an output folder.
## save_output(
##   tbl_stats(smoking_twobytwo, title = "Smoking and low birth weight"),
##   "birthweight-two-by-two.html"
## )


## 6. Peer-review prompts -----------------------------------------------------

## Please record:
## 1. Were exposure, outcome and event levels clear?
## 2. Which epidemiological measure was easiest or hardest to interpret?
## 3. Did the output contain enough raw numbers to verify the calculation?
## 4. Which defaults should change?
## 5. Did any function produce an error or surprising result?
