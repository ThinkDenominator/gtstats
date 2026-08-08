## Manual real-time test: summary-table builder combinations
## Package: gtstats 1.0.0
##
## Purpose:
## Exercise every supported table structure and add_*() component combination.
## Rate mode is intentionally separate because event rates and Table 1 rows
## answer different questions.


## 0. Setup -------------------------------------------------------------------

## During development: devtools::load_all(".")
library(gtstats)

builder_data <- mtcars
builder_data$am <- factor(
  builder_data$am,
  levels = c(0, 1),
  labels = c("Automatic", "Manual")
)
builder_data$vs <- factor(
  builder_data$vs,
  levels = c(0, 1),
  labels = c("V-shaped", "Straight")
)
builder_data$cyl <- factor(builder_data$cyl)
attr(builder_data$mpg, "label") <- "Fuel economy (mpg)"
attr(builder_data$wt, "label") <- "Vehicle weight (1000 lb)"
attr(builder_data$am, "label") <- "Transmission"
attr(builder_data$vs, "label") <- "Engine configuration"
attr(builder_data$cyl, "label") <- "Cylinders"


## 1. Ungrouped summary -------------------------------------------------------

## Indication: describe one sample without comparisons.
## Expected columns: Variable, Level, Value.
ungrouped <- summary_table(
  builder_data,
  include = c(mpg, wt, cyl, vs)
)

ungrouped
ungrouped$table


## 2. Grouped summary without overall ----------------------------------------

## Indication: describe variables separately within transmission groups.
## Expected: one column per group and no Overall column.
grouped <- summary_table(
  builder_data,
  by = am,
  include = c(mpg, wt, cyl, vs)
)

grouped
grouped$table


## 3. Grouped summary with overall -------------------------------------------

## Expected: Overall plus both transmission columns.
grouped_overall <- summary_table(
  builder_data,
  by = am,
  include = c(mpg, wt, cyl, vs),
  overall = TRUE
)

grouped_overall


## 4. One-call publication customisation --------------------------------------

## Question:
## Can a user change the common journal requirements without abandoning the
## simple summary_table() route?

## Mixed types with no decimal places in percentages.
simple_zero_percent <- summary_table(
  builder_data,
  by = am,
  include = c(mpg, wt, cyl, vs),
  overall = TRUE,
  digits = c(continuous = 1, percent = 0)
)

## Two decimal places throughout.
simple_two_digits <- summary_table(
  builder_data,
  by = am,
  include = c(mpg, wt, cyl, vs),
  overall = TRUE,
  digits = 2
)

## Counts only and percentages only.
simple_counts <- summary_table(
  builder_data,
  by = am,
  include = c(cyl, vs),
  categorical = "n"
)
simple_percentages <- summary_table(
  builder_data,
  by = am,
  include = c(cyl, vs),
  categorical = "percent",
  digits = c(percent = 0)
)

## Overall can appear after the groups.
simple_overall_last <- summary_table(
  builder_data,
  by = am,
  include = c(mpg, wt, cyl, vs),
  overall = "last"
)

## Descriptive confidence intervals do not require p-values or a by variable.
simple_ci_without_p <- summary_table(
  builder_data,
  include = c(cyl, vs),
  categorical = "percent",
  ci = TRUE,
  conf.level = 0.95,
  digits = c(percent = 1, ci = 1)
)

## Inline labels and per-variable continuous summaries.
simple_labels_statistics <- summary_table(
  builder_data,
  by = am,
  include = c(mpg, wt, cyl),
  statistic = c(mpg = "mean_sd", wt = "median_iqr"),
  label = c(
    mpg = "Fuel economy",
    wt = "Vehicle weight",
    cyl = "Number of cylinders"
  )
)

simple_zero_percent
simple_two_digits
simple_counts
simple_percentages
simple_overall_last
simple_ci_without_p
simple_labels_statistics

## Inspect:
## - percentage precision must not change continuous precision;
## - count-only output must contain no percent signs;
## - percentage-only output must contain no leading counts;
## - confidence intervals must appear without a p-value column;
## - Overall must genuinely be the last displayed data column.


## 5. All continuous summary formats -----------------------------------------

## "recommended": mean/SD or median/IQR according to distribution guidance.
recommended_summary <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_summary(
    vars = c(mpg, wt),
    continuous_format = "recommended"
  )

## "mean_sd": force mean (SD).
mean_sd_summary <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_summary(
    vars = c(mpg, wt),
    continuous_format = "mean_sd"
  )

## "median_iqr": force median (IQR).
median_iqr_summary <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_summary(
    vars = c(mpg, wt),
    continuous_format = "median_iqr"
  )

## "both": display mean (SD) and median (IQR).
both_summary <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_summary(
    vars = c(mpg, wt),
    continuous_format = "both"
  )

recommended_summary
mean_sd_summary
median_iqr_summary
both_summary


## 5A. Every categorical denominator -----------------------------------------

column_percent <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_summary(vars = c(cyl, vs), percent = "column")

row_percent <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_summary(vars = c(cyl, vs), percent = "row")

overall_percent <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_summary(vars = c(cyl, vs), percent = "overall")

count_only <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_summary(vars = c(cyl, vs), percent = "none")

column_percent
row_percent
overall_percent
count_only

## The audit is deliberately more detailed than the publication table.
## For categorical rows it now records Variable + Level + Group, so the
## `denominator` column is the exact denominator behind each displayed cell.
## In particular, a row percentage has the same level-specific denominator in
## every group; an overall percentage has the same variable denominator in
## every group.
denominators_stats(column_percent)
denominators_stats(row_percent)
denominators_stats(overall_percent)


## 4B. Missing rows: if present, always and never -----------------------------

missing_data <- builder_data
missing_data$mpg[c(1, 4)] <- NA

missing_ifany <- summary_table(missing_data, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, vs), missing = "ifany")

missing_always <- summary_table(missing_data, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, vs), missing = "always")

missing_never <- summary_table(missing_data, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, vs), missing = "no")

missing_ifany
missing_always
missing_never


## 5. Per-variable statistics and repeated additions -------------------------

## Expected: mpg and wt use different formats; cyl is appended later.
mixed_summary <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_summary(
    vars = c(mpg, wt),
    statistic = c(
      mpg = "mean_sd",
      wt = "median_iqr"
    )
  ) |>
  add_summary(vars = cyl)

mixed_summary
mixed_summary$summary_statistics


## 6. Total first and total last ----------------------------------------------

total_first <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, vs)) |>
  add_total(label = "Vehicles, N", position = "first")

total_last <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, vs)) |>
  add_total(label = "Vehicles, N", position = "last")

total_first
total_last


## 7. Highlighted proportion with and without CI ------------------------------

## Indication: add one clinically/analytically important category as a new row.
## This does not replace the ordinary categorical rows from add_summary().
proportion_ci <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_summary(vars = vs) |>
  add_proportion(
    var = vs,
    level = "Straight",
    label = "Straight-engine prevalence",
    ci = TRUE
  )

proportion_no_ci <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_proportion(
    var = vs,
    level = "Straight",
    label = "Straight-engine prevalence",
    ci = FALSE
  )

proportion_ci
proportion_no_ci


## 8. Custom rows in every structure -----------------------------------------

custom_ungrouped <- summary_table(builder_data) |>
  add_summary(vars = mpg) |>
  add_row(
    label = "Data source",
    values = "Motor Trend road tests"
  )

custom_grouped <- summary_table(builder_data, by = am) |>
  add_summary(vars = mpg) |>
  add_row(
    label = "Review status",
    values = c(
      "am = Automatic" = "Complete",
      "am = Manual" = "Complete"
    )
  )

custom_overall <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_summary(vars = mpg) |>
  add_row(
    label = "Study period",
    overall = "1973–1974",
    values = c(
      "am = Automatic" = "1973–1974",
      "am = Manual" = "1973–1974"
    )
  )

custom_ungrouped
custom_grouped
custom_overall


## 9. Automatic and explicit p-values -----------------------------------------

automatic_p <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, wt, cyl, vs)) |>
  add_p()

explicit_p <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, wt, cyl, vs)) |>
  add_p(
    method = list(
      mpg = "welch_t",
      wt = "wilcox",
      cyl = "fisher",
      vs = "chisq"
    ),
    normality_check = FALSE,
    correction = FALSE
  )

automatic_p
automatic_p$pvalue_method_footnotes
automatic_p$assumption_notes
## Inspect the variable-specific auto decisions outside the publication table.
## Expected: continuous variables include observed group spread as descriptive
## context; it does not change the Welch-based parametric default.
diagnostics_stats(automatic_p)
explicit_p
explicit_p$pvalue_method_footnotes

adjusted_p <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, wt, cyl, vs)) |>
  add_p(p_adjust = "BH")

adjusted_p
adjusted_p$p_values
adjusted_p$assumptions
adjusted_p$diagnostics


## 10. Complete Table 1 combination ------------------------------------------

complete_table <- summary_table(builder_data, by = am, overall = TRUE) |>
  add_total(label = "Vehicles, N", position = "first") |>
  add_summary(
    vars = c(mpg, wt),
    statistic = c(mpg = "mean_sd", wt = "median_iqr")
  ) |>
  add_summary(vars = c(cyl, vs)) |>
  add_proportion(
    var = vs,
    level = "Straight",
    label = "Straight-engine prevalence"
  ) |>
  add_row(
    label = "Data source",
    overall = "Motor Trend",
    values = c(
      "am = Automatic" = "Motor Trend",
      "am = Manual" = "Motor Trend"
    )
  ) |>
  add_p()

complete_table
complete_table$table
tbl_stats(complete_table, title = "Complete summary-table workflow")


## 11. Rate mode: ungrouped, grouped and overall ------------------------------

## Indication: aggregate event counts over an exposure/person-time denominator.
## Rate mode cannot be mixed with summary/proportion/total/p-value components.
rate_data <- data.frame(
  arm = factor(rep(c("Control", "Intervention"), each = 6)),
  events = c(1, 0, 2, 1, 3, 0, 0, 1, 0, 2, 1, 1),
  person_years = c(10, 9, 12, 8, 11, 10, 9, 11, 10, 12, 8, 10)
)

rate_ungrouped <- summary_table(rate_data, mode = "rate") |>
  add_rate(
    event = events,
    time = person_years,
    multiplier = 100,
    ci = TRUE
  )

rate_grouped <- summary_table(rate_data, by = arm, mode = "rate") |>
  add_rate(
    event = events,
    time = person_years,
    label = "Events per 100 person-years",
    multiplier = 100,
    ci = FALSE
  )

rate_overall <- summary_table(
  rate_data,
  by = arm,
  mode = "rate",
  overall = TRUE
) |>
  add_rate(
    event = events,
    time = person_years,
    label = "Events per 100 person-years",
    multiplier = 100,
    ci = TRUE
  )

rate_ungrouped
rate_grouped
rate_overall


## 12. Global presentation choices: visible denominators and mean CI ---------

## Indication: show the denominator in every categorical cell, or report the
## precision of a continuous mean without adding p-values.
## Expected: categorical cells are n/N (%) and mean CI uses a t interval.
denominator_visible <- summary_table(
  builder_data,
  by = am,
  include = c(mpg, cyl),
  statistic = "mean_ci",
  categorical = "n_over_N_percent",
  percent = "column",
  digits = c(continuous = 1, percent = 0, ci = 1),
  overall = "last"
)

denominator_visible
denominator_visible$table
tbl_stats(denominator_visible)

## FEEDBACK: Is n/N (%) immediately understandable and is the mean CI clearly
## distinct from a p-value or a categorical confidence interval?

## All-missing categorical variables remain visible as an em dash, with an
## explicit Missing row. This prevents a variable silently disappearing.
all_missing_categorical <- data.frame(
  arm = factor(rep(c("Control", "Treatment"), each = 3)),
  response = factor(rep(NA_character_, 6), levels = c("No", "Yes"))
)
summary_table(all_missing_categorical, by = arm, overall = TRUE) |>
  add_summary(vars = response)


## 13. Expected builder errors ------------------------------------------------

## Duplicate variable:
## Expected: explains that the variable already exists.
try(
  summary_table(builder_data, by = am) |>
    add_summary(vars = mpg) |>
    add_summary(vars = mpg)
)

## P-value without a grouping variable:
## Expected: add_p() requires summary_table(..., by = ...).
try(
  summary_table(builder_data) |>
    add_summary(vars = mpg) |>
    add_p()
)

## Mixing summary rows into rate mode:
## Expected: mode incompatibility error.
try(
  summary_table(rate_data, mode = "rate") |>
    add_summary(vars = events)
)

## Mixing rate rows with summary components:
## Expected: add_rate() refuses incompatible components.
try(
  summary_table(rate_data) |>
    add_summary(vars = events) |>
    add_rate(event = events, time = person_years)
)


## 14. Missing-data and denominator audit -------------------------------------

## Indication: confirm which observations contribute to percentages, confidence
## intervals and group comparisons before reporting results.
## Expected: categorical percentages use non-missing variable denominators;
## missing rows use all rows in the displayed group; the audit records both.
missing_data <- data.frame(
  arm = factor(c("Control", "Control", "Treatment", "Treatment", "Treatment")),
  age = c(45, NA, 51, 62, 57),
  smoker = factor(c("No", "Yes", NA, "Yes", "No"))
)

missing_table <- summary_table(
  missing_data,
  by = arm,
  include = c(age, smoker),
  percent = "column",
  missing = "ifany",
  overall = TRUE
)

missing_table
denominators_stats(missing_table)
denominators_stats(missing_table, output = "gt")

smoker_proportion <- proportion_stats(
  missing_data,
  smoker,
  by = arm,
  level = "Yes"
)
smoker_proportion
denominators_stats(smoker_proportion)

age_comparison <- compare_groups(missing_data, variable = age, group = arm)
age_comparison
denominators_stats(age_comparison)

## FEEDBACK: Are the different denominators clear from the output and audit?


## 15. Reviewer notes ---------------------------------------------------------

## Confirm:
## 1. Empty builders, incremental additions and completed tables are clear.
## 2. Each continuous format says exactly what is displayed.
## 3. add_proportion() visibly adds a new row rather than replacing categories.
## 4. Total first/last and custom-row placement are predictable.
## 5. Summary and rate modes are clearly separated.
## 6. n/N (%) and mean CI are clear optional global presentation choices.
## 7. Missing-data and denominator audits make the analysis population clear.
## 8. Error messages explain the corrective action.
