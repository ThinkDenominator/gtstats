## Manual real-time test: birthweight descriptive and inferential case study
## Package: gtstats 1.0.0
##
## Story:
## A maternity team wants to describe mothers in a low-birth-weight study,
## understand the distribution of continuous variables, compare clinical
## characteristics by birth-weight outcome, and prepare a publication table.
##
## How to use:
## Run this script section by section. Do not source the whole file blindly.
## Inspect each printed object and rendered table. Comments marked FEEDBACK
## identify places where comments from peer reviewers are especially useful.


## 0. Setup -------------------------------------------------------------------

## During package development, run from the package root:
## devtools::load_all(".")
##
## After installing the package, use:
## library(gtstats)
library(gtstats)


## 1. Load the maintained teaching dataset ------------------------------------

## Built-in data are labelled and prepared for teaching. No extra package or
## code-conversion step is required.
data("birthwt", package = "gtstats")
birthwt_source <- "gtstats::birthwt"

birthwt_source
dim(birthwt)
names(birthwt)
head(birthwt)


## 2. Prepare the clinical dataset --------------------------------------------

## Keep the original numeric birth weight for distribution checks and
## continuous comparisons; readable factors and labels are already supplied.
birthwt_data <- birthwt

## Safety check: the analyst explicitly declared this variable ordered.
## If this fails, rerun the preparation block before interpreting the overview.

## 3. Inspect the data before analysis ----------------------------------------

## Question:
## Are variable types, missingness and suggested summaries easy to understand?
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

## FEEDBACK:
## - Are the variable types described in beginner-friendly language?
## - Does `$issues` explain why each finding was flagged and what to check?


## 4. Understand continuous-variable distributions ---------------------------

## Shape bands and the interpretation of Shapiro-Wilk are stated in the
## table footnotes. Diagnostics remain separate by outcome group, but the
## recommendation is made once per variable so Table 1 can use a consistent
## summary across groups. The function deliberately does not choose an
## inferential test.
birthwt_distribution <- assess_distribution(
  birthwt_data,
  vars = c("age", "lwt"),
  by = low
)

birthwt_distribution
birthwt_distribution$summary
birthwt_distribution$recommendations
# Both ungrouped and grouped calls show detailed diagnostics and suggested
# presentation in one table. With `by`, every group-level diagnostic is shown;
# the shared suggestion appears once beside the first group row so Table 1 can
# use one consistent summary. Shapiro-Wilk is supporting information, not a
# normality verdict or test selector.
birthwt_distribution$table
birthwt_distribution$inputs
birthwt_distribution$notes

tbl_stats(
  birthwt_distribution,
  title = "Distribution assessment by birth-weight outcome"
)

## `low` is derived from birth weight, so assessing birth weight within its
## own threshold-defined groups would create truncated distributions by design.
## Assess birth weight overall instead.
birthwt_distribution_bwt <- assess_distribution(
  birthwt_data,
  vars = "bwt"
)
birthwt_distribution_bwt

## Optional visual checks complement skewness and Shapiro-Wilk. They are
## returned as ordinary ggplot objects for inspection or further styling.
birthwt_distribution_plots <- assess_distribution(
  birthwt_data,
  vars = c("age", "lwt"),
  by = low,
  plots = TRUE
)
birthwt_distribution_plots$plots$age$histogram
birthwt_distribution_plots$plots$age$qq
## FEEDBACK:
## - Does this answer "mean (SD) or median (IQR)?" clearly?
## - Is the suggested presentation appropriately cautious?


## 4b. Understand variation across outcome groups ---------------------------

## This is a descriptive diagnostic, not a variance-test gatekeeper. It shows
## group SDs and variances, plus the largest/smallest SD and variance ratios.
## Welch methods do not require equal variances, so use this to understand the
## data rather than to mechanically choose Student versus Welch tests.
birthwt_variance <- assess_variance(
  birthwt_data,
  vars = c("age", "lwt", "bwt"),
  by = low
)

birthwt_variance
birthwt_variance$summary
birthwt_variance$diagnostics
birthwt_variance$notes

tbl_stats(
  birthwt_variance,
  title = "Variation in continuous characteristics by birth-weight outcome"
)

## FEEDBACK:
## - Are SD and variance ratios understandable without implying a pass/fail test?
## - Does the Welch caveat make the relationship to later group comparisons clear?


## 5. Build a publication table -----------------------------------------------

## Beginner route: select continuous, categorical, binary and ordinal
## variables together. Their types and suitable summaries are detected
## automatically. Cohort denominators are displayed in the column headers.
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

## FEEDBACK:
## - Is the default table already publication-ready?
## - Which styling arguments feel essential, unnecessary or missing?


## 7. Standalone group comparisons -------------------------------------------

## Continuous outcome:
## Is maternal weight distributed differently by birth-weight outcome?
weight_comparison <- compare_groups(
  birthwt_data,
  variable = lwt,
  group = low,
  test = "auto",
  effect_size = TRUE
)

weight_comparison
weight_comparison$descriptives
weight_comparison$inferential
weight_comparison$inferential[, c(
  "effect_size", "effect_size_type",
  "effect_conf_low", "effect_conf_high"
)]
weight_comparison$method
## `selection_rule` states the exact `test = "auto"` rule applied; the
## diagnostics table shows the values used to make that decision.
weight_comparison$method$selection_rule
weight_comparison$method$selection_inputs
diagnostics_stats(weight_comparison)
weight_comparison$notes
tbl_stats(weight_comparison, title = "Maternal weight comparison")

## Categorical outcome:
## Is smoking associated with low birth weight?
smoking_comparison <- compare_groups(
  birthwt_data,
  variable = smoke,
  group = low,
  test = "auto",
  effect_size = TRUE
)

smoking_comparison
smoking_comparison$inferential
smoking_comparison$method$selection_rule
smoking_comparison$method$selection_inputs
diagnostics_stats(smoking_comparison)
## Cramer's V is an omnibus, non-directional association measure. For risk
## ratio, odds ratio or risk difference, use crosstabs().
tbl_stats(smoking_comparison, title = "Smoking and birth-weight outcome")

## Visual inspection of both comparisons.
plot_compare(
  birthwt_data,
  outcome = lwt,
  by = low,
  show_p = TRUE,
  title = "Maternal weight by birth-weight outcome"
)

plot_compare(
  birthwt_data,
  outcome = smoke,
  by = low,
  type = "bar",
  display = "proportion",
  show_p = TRUE,
  title = "Smoking by birth-weight outcome"
)

## FEEDBACK:
## - Is the automatically selected test transparent?
## - Are the effect-size label and interpretation helpful?


## 8. Correlation -------------------------------------------------------------

## Question:
## Is maternal weight associated with infant birth weight?
## Printing gives the publication-ready table. Review `$method`, `$assumptions`
## and `$diagnostics` to understand and verify the automatic method choice.
birthweight_correlation <- correlation(
  birthwt_data,
  x = lwt,
  y = bwt,
  method = "auto"
)

birthweight_correlation
birthweight_correlation$table
birthweight_correlation$summary
birthweight_correlation$method
birthweight_correlation$assumptions
birthweight_correlation$diagnostics
birthweight_correlation$denominators
tbl_stats(
  birthweight_correlation,
  title = "Maternal and infant weight correlation"
)

## Visual companion: the minimal plot reports complete-pair N. Set
## `show_correlation = TRUE` when the coefficient and p-value belong on the
## figure. The method and coefficient match `birthweight_correlation`.
birthweight_correlation_plot <- plot_correlation(
  birthwt_data,
  x = lwt,
  y = bwt
)
birthweight_correlation_plot

plot_correlation(
  birthwt_data,
  x = lwt,
  y = bwt,
  method = "auto",
  show_correlation = TRUE,
  title = "Maternal and infant weight"
)

## FEEDBACK:
## - Is the scatterplot readable without a title?
## - Is complete-pair N enough by default?
## - Is the optional correlation caption concise enough for publication?


## 9. Optional export ---------------------------------------------------------

## Uncomment after choosing an output folder.
## save_output(birthwt_paper, "birthweight-summary.html")
## save_output(
##   plot_compare(birthwt_data, outcome = lwt, by = low),
##   "birthweight-comparison.png"
## )


## 10. Peer-review prompts ----------------------------------------------------

## Please record:
## 1. Which function or argument was unclear?
## 2. Which output was difficult to interpret?
## 3. Which default would you change?
## 4. Which additional row or statistic did you expect in summary_table()?
## 5. Did any function produce an error or surprising result?
## 6. Would you use this workflow without reading detailed documentation?
