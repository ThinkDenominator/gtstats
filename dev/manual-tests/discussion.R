birthwt_data= data("birthwt", package = "gtstats")

birthwt_overview <- describe_data(birthwt_data)
birthwt_overview
birthwt_overview$summary
birthwt_overview$issues
birthwt_overview$notes
birthwt_overview$table
## Render the overview for HTML/RStudio viewing.
tbl_stats(
  birthwt_overview
)

birthwt_distribution <- assess_distribution(
  birthwt_data,
  vars = c(age, lwt),
  by = low
)
birthwt_distribution
birthwt_distribution$summary
birthwt_distribution$recommendations
birthwt_distribution$table
birthwt_distribution$inputs
birthwt_distribution$notes

birthwt_distribution_bwt <- assess_distribution(
  birthwt_data,
  vars = "bwt"
)
birthwt_distribution_bwt
birthwt_distribution_plots <- assess_distribution(
  birthwt_data,
  vars = c("age", "lwt"),
  by = low,
  plots = TRUE
)
birthwt_distribution_plots$plots$age$histogram
birthwt_distribution_plots$plots$age$qq
birthwt_table <- summary_table(
  birthwt_data,
  by = low,
  include = c(
    age, lwt, bwt, race, smoke, ht, ui,
    previous_preterm, antenatal_visits
  ),
  overall = TRUE
)

birthwt_table

## Optional specialist addition: highlight one clinically important proportion
## with an exact binomial confidence interval. Ordinary categorical summaries
## are already included above and do not require add_proportion().
birthwt_table <- birthwt_table |>
  add_proportion(
    var = smoke,
    level = "Yes",
    label = "Smoking prevalence",
    ci = TRUE
  )

birthwt_table

## Add inferential tests using the beginner-friendly defaults:
## - continuous, 2 groups: Welch t-test when approximately symmetric;
##   otherwise Wilcoxon rank-sum
## - continuous, 3+ groups: Welch ANOVA when approximately symmetric;
##   otherwise Kruskal-Wallis
## - categorical: chi-square when expected counts are adequate;
##   otherwise Fisher's exact test
birthwt_table_before_p <- birthwt_table

birthwt_table <- birthwt_table |>
  add_p()

birthwt_table
birthwt_table$table
birthwt_table$pvalue_method_footnotes
birthwt_table$assumption_notes
birthwt_table$assumptions
birthwt_table$diagnostics
birthwt_table$denominators
birthwt_table$p_values

## Plain-language checklist for routine review. The technical audit remains
## available as `birthwt_table$assumptions` or `view = "audit"`.
assumptions_stats(birthwt_table)
assumptions_stats(birthwt_table, view = "audit")
diagnostics_stats(birthwt_table)
denominators_stats(birthwt_table)
## Use the technical audit view only when you need the stored codes/fields.
diagnostics_stats(birthwt_table, view = "audit")
denominators_stats(birthwt_table, view = "audit")

## AUDIT HELPERS: these are for the analyst, not for the publication table.
## - assumptions_stats(): a plain-language checklist. "Confirm from study
##   design" is not a failure—it marks an assumption that cannot be learned
##   from values alone. Use `view = "audit"` for technical status codes.
## - diagnostics_stats(): values used in automatic decisions (for example,
##   expected counts or distribution checks) and any flags needing review.
## - denominators_stats(): numerator, non-missing denominator and missingness
##   behind every percentage, rate or risk. Use this before reporting results
##   when exclusions or missing data could change interpretation.

## Analysts can override individual choices when the study question or
## prespecified analysis plan requires a particular test.
birthwt_table_explicit <- birthwt_table_before_p |>
  add_p(
    method = c(
      age = "welch_t",
      lwt = "wilcox",
      bwt = "welch_t",
      race = "fisher",
      smoke = "chisq",
      ht = "fisher",
      ui = "chisq",
      previous_preterm = "fisher",
      antenatal_visits = "fisher"
    ),
    normality_check = FALSE
  )

birthwt_table_explicit$pvalue_method_footnotes

## FEEDBACK:
## - Is the one-call mixed-variable selection easy to understand?
## - Are the automatic tests and reasons understandable?
## - Is overriding tests sufficiently explicit?
## - Are the footnotes sufficient to explain the selected tests?


## 6. Render and customise the table ------------------------------------------

birthwt_gt <- birthwt_table |>
  tbl_stats(
    title = "Maternal characteristics by birth-weight outcome",
    subtitle = paste("Teaching data:", birthwt_source)
  )

birthwt_gt

birthwt_paper <- birthwt_gt |>
  customise_table(
    theme = "journal",
    source_note = "Continuous and categorical summaries are shown as labelled.",
    col_labels = c(
      "low = Normal birth weight" = "Normal birth weight",
      "low = Low birth weight" = "Low birth weight"
    ),
    accent_color = "#1F4E79"
  )

birthwt_paper
summary_table(
  birthwt_data,
  by = smoke,
  overall = TRUE
) |>
  add_summary(
    vars = low,
    categorical = "n_percent",
    ci = TRUE,
    conf.level = 0.95
  ) |>
  tbl_stats(
    title = "Birth-weight outcome by smoking status"
  )
summary_table(birthwt_data) |>
  add_summary(
    vars = c(low, race, smoke),
    ci = TRUE
  ) |>
  tbl_stats()
## Question:
## What proportion of births had low birth weight, overall and by smoking?
low_birthweight_risk <- proportion_stats(
  birthwt_data,
  var = low,
  #level = "Low birth weight",
  by = smoke
)

low_birthweight_risk
## Overall risk without grouping.
proportion_stats(
  birthwt_data,
  var = low,
  level = "Low birth weight"
)

