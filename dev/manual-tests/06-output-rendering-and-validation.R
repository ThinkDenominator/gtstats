## Manual real-time test: outputs, rendering, plots and validation
## Package: gtstats 1.0.0
##
## Purpose:
## Exercise all public exploration outputs, correlation methods, plot branches,
## gt themes, flextable conversion and common validation messages.


## 0. Setup -------------------------------------------------------------------

## During development: devtools::load_all(".")
library(gtstats)

output_data <- mtcars
output_data$am <- factor(
  output_data$am,
  levels = c(0, 1),
  labels = c("Automatic", "Manual")
)
output_data$vs <- factor(
  output_data$vs,
  levels = c(0, 1),
  labels = c("V-shaped", "Straight")
)
output_data$cyl <- factor(output_data$cyl, ordered = TRUE)
output_data$mpg[c(2, 7)] <- NA
attr(output_data$mpg, "label") <- "Fuel economy (mpg)"
attr(output_data$wt, "label") <- "Vehicle weight (1000 lb)"
attr(output_data$am, "label") <- "Transmission"


## 1. describe_data(): concise overview and output routes ---------------------

## Default output prints as a complete publication-ready gt table.
describe_compact <- describe_data(
  output_data,
  output = "table"
)

## Selected variables retain the same seven-column user-facing structure.
describe_selected <- describe_data(
  output_data,
  vars = c("mpg", "wt", "am", "cyl"),
  output = "table"
)

## Tibble route is intended for programmatic inspection.
describe_tibble <- describe_data(
  output_data,
  vars = c("mpg", "wt", "am"),
  output = "tibble"
)

## Possible ordinal variables receive * in the main table with an explanatory
## footnote; ordered factors are labelled ordinal directly.
stopifnot(is.ordered(output_data$cyl))
describe_ordinal_candidates <- describe_data(
  output_data,
  vars = c("cyl", "gear"),
  output = "table"
)

describe_compact
describe_selected
describe_tibble
describe_ordinal_candidates
describe_selected$summary
describe_selected$issues
describe_selected$notes
tbl_stats(describe_selected, title = "Concise data overview")


## 2. summary_table(): direct publication table -------------------------------

## With no `vars`, every variable other than `by` is included.
summary_recommended <- summary_table(
  output_data,
  by = am,
  include = c(mpg, wt, cyl, vs),
  overall = "last",
  missing = "ifany"
)

## Select continuous and categorical variables together. There is no need to
## call the function separately by variable type.
summary_mean <- summary_table(
  output_data,
  include = c(mpg, wt, am, cyl),
  statistic = "mean_sd",
  missing = "no"
)

summary_median <- summary_table(
  output_data,
  include = c(mpg, wt),
  statistic = "median_iqr",
  missing = "always"
)

## Different continuous summaries can be selected in the same call.
summary_both <- summary_table(
  output_data,
  include = c(mpg, wt, cyl),
  by = am,
  statistic = c(mpg = "mean_sd", wt = "median_iqr")
)

## Categorical display, denominator, precision, CIs, labels and overall
## placement use the same options as summary_table().
summary_percent_ci <- summary_table(
  output_data,
  include = c(am, vs, cyl),
  categorical = "percent",
  ci = TRUE,
  digits = c(continuous = 1, percent = 0, ci = 1),
  label = c(am = "Transmission", vs = "Engine shape")
)

summary_recommended
summary_mean
summary_median
summary_both
summary_percent_ci

## Function-options guide: test the most useful display combinations shown on
## pkgdown. These examples are deliberately short enough to copy, adapt, and
## share with collaborators.
summary_visible_denominator <- summary_table(
  output_data,
  by = am,
  include = c(mpg, vs),
  overall = "last",
  statistic = "mean_ci",
  categorical = "n_over_N_percent",
  percent = "column",
  digits = c(continuous = 1, percent = 0, ci = 1)
)

summary_mixed_statistics <- summary_table(
  output_data,
  by = am,
  include = c(mpg, wt, vs),
  statistic = c(mpg = "mean_sd", wt = "median_iqr"),
  categorical = "percent",
  percent = "row",
  missing = "always"
)

summary_visible_denominator
summary_mixed_statistics

## PEER REVIEW NOTES:
## - The pkgdown article "Function options" explains every exported function
##   in one place; check that each option table remains accurate after API work.
## - For publication tables, choose the display before adding inferential
##   layers: statistic/categorical/percent/digits/missing control presentation;
##   add_p() controls only the comparison column.

## Inspect the underlying display rows or export through common routes.
summary_recommended$table
tbl_stats(summary_recommended)
to_flextable(summary_recommended)

## PEER REVIEW NOTES:
## - Does summary_table(data, include = ...) feel like a useful direct default?
## - Is it clear that omitting `include` enables advanced step-by-step building?
## - Are mixed variable types handled without extra work?
## - Are statistic, percentage, CI and missingness options easy to discover?


## 3. assess_distribution(): grouped/ungrouped and optional Shapiro -----------

distribution_compact <- assess_distribution(
  output_data,
  vars = c("mpg", "wt"),
  output = "table"
)

distribution_full <- assess_distribution(
  output_data,
  vars = c("mpg", "wt"),
  by = am,
  skew_cutoff = 1,
  min_n = 3,
  output = "table"
)

distribution_without_shapiro <- assess_distribution(
  output_data,
  vars = c("mpg", "wt"),
  normality_test = FALSE,
  output = "tibble"
)

distribution_compact
distribution_full
distribution_full$summary
distribution_full$recommendations
distribution_full$notes
distribution_without_shapiro
tbl_stats(distribution_full, title = "Grouped distribution checks")

## Visual diagnostics are opt-in. They complement, rather than replace,
## numerical diagnostics. Each selected variable has histogram, density,
## Q-Q and box plots; grouped plots are faceted by group where appropriate.
distribution_with_plots <- assess_distribution(
  output_data,
  vars = c("mpg", "wt"),
  by = am,
  plots = TRUE
)
distribution_with_plots$plots$mpg$histogram
distribution_with_plots$plots$mpg$qq


## 4. Correlation: auto, Pearson and Spearman ---------------------------------

## PURPOSE
## Assess the direction and size of association between two continuous
## variables. This is not a test of agreement and does not establish causation.
##
## DEFAULT BEHAVIOUR
## - Printing the result displays a concise publication-ready gt table.
## - `method = "auto"` uses Pearson when both marginal distributions have
##   absolute sample skewness < 1; otherwise it uses Spearman.
## - The saved diagnostics show both skewness values, the exact selection rule,
##   and the number of complete finite pairs. A manual method is labelled as a
##   user choice rather than an automatic decision.
## - Auto-selection is only a pragmatic starting point. It cannot inspect
##   whether the relationship is linear/monotonic or whether observations are
##   independent.
##
## ASSUMPTIONS TO CONFIRM
## - Both methods: independent observation pairs.
## - Pearson: an approximately linear relationship.
## - Spearman: an approximately monotonic relationship.
## - Both methods: no single observation dominates the result.
## Inspect a scatterplot before interpreting either coefficient.
##
## PUBLICATION OUTPUT
## - Pearson includes its confidence interval from stats::cor.test().
## - Spearman does not display a confidence interval because base R does not
##   provide one; gtstats does not silently substitute an approximation.
## - Method is a column footnote, not an extra visible column.
## - Diagnostic and interpretation detail remains in `$summary`, `$method`,
##   `$assumptions`, and `$diagnostics`.
correlation_auto <- correlation(
  output_data,
  x = mpg,
  y = wt,
  method = "auto"
)

correlation_pearson <- correlation(
  output_data,
  x = mpg,
  y = wt,
  method = "pearson",
  conf.level = 0.90
)

correlation_spearman <- correlation(
  output_data,
  x = mpg,
  y = wt,
  method = "spearman"
)

correlation_auto
correlation_auto$table
correlation_auto$summary
correlation_auto$method
correlation_auto$assumptions
correlation_auto$diagnostics
correlation_auto$denominators
correlation_auto$notes
correlation_pearson
correlation_pearson$table
correlation_spearman
correlation_spearman$table

## EXPECTED REVIEW
## - Pearson has "Correlation (90% CI)" in this example.
## - Spearman has "Correlation" and no blank CI column.
## - Changing `digits` controls the coefficient, CI and p-value display.
correlation_digits <- correlation(
  output_data,
  x = mpg,
  y = wt,
  method = "pearson",
  digits = 3
)
correlation_digits

## COMPLETE-PAIR HANDLING
correlation_missing_data <- output_data
correlation_missing_data$mpg[c(1, 3)] <- NA_real_
correlation_missing_data$wt[c(2, 3)] <- NA_real_
correlation_complete_pairs <- correlation(
  correlation_missing_data,
  x = mpg,
  y = wt
)
correlation_complete_pairs
correlation_complete_pairs$denominators

## VISUAL COMPANION
## Minimal output: observations, automatically aligned trend, axis labels and
## complete-pair N. Correlation details are deliberately opt-in.
correlation_plot_auto <- plot_correlation(
  output_data,
  x = mpg,
  y = wt
)
correlation_plot_auto

## Pearson selects a linear trend and can show its coefficient, CI and p-value.
correlation_plot_pearson <- plot_correlation(
  output_data,
  x = mpg,
  y = wt,
  method = "pearson",
  show_correlation = TRUE
)
correlation_plot_pearson

## Spearman selects a smooth trend. Its caption does not invent a CI.
correlation_plot_spearman <- plot_correlation(
  output_data,
  x = mpg,
  y = wt,
  method = "spearman",
  show_correlation = TRUE
)
correlation_plot_spearman

## Explicit visual choices remain available without changing the analysis:
## observations only, no confidence band, custom labels/colours, and ordinary
## ggplot2 additions.
plot_correlation(
  output_data,
  x = mpg,
  y = wt,
  trend = "none",
  caption = "Exploratory figure"
)
plot_correlation(
  output_data,
  x = mpg,
  y = wt,
  trend = "linear",
  show_ci = FALSE,
  point_color = "#2F5597",
  line_color = "#C55A11",
  xlab = "Fuel economy",
  ylab = "Vehicle weight"
)

## COMPLETE-PAIR HANDLING: the displayed N should match the analysis.
plot_correlation(
  correlation_missing_data,
  x = mpg,
  y = wt,
  show_correlation = TRUE
)


## 4A. Comparison output contract --------------------------------------------

## Printing opens the publication-ready gt table. The concise source tibble and
## detailed inferential results remain available for programming and review.
comparison_output <- compare_groups(
  output_data,
  variable = "mpg",
  group = "am"
)
comparison_output
comparison_output$table
comparison_output$inferential

## PROPORTION DISPLAY OPTIONS
proportion_default <- proportion_stats(output_data, var = "vs", by = "am")
proportion_percent <- proportion_stats(
  output_data,
  var = "vs",
  by = "am",
  display = "percent"
)
proportion_fraction <- proportion_stats(
  output_data,
  var = "vs",
  by = "am",
  display = "n_over_N_percent",
  ci_method = "exact",
  digits = 2
)
proportion_default
proportion_percent
proportion_fraction

rate_route_data <- data.frame(
  events = c(1, 0, 2, 1),
  person_time = c(10, 12, 9, 11)
)
rate_default <- rate_stats(
  rate_route_data,
  event = "events",
  time = "person_time"
)
rate_custom_unit <- rate_stats(
  rate_route_data,
  event = "events",
  time = "person_time",
  multiplier = 100,
  time_label = "person-years",
  digits = 2
)
rate_default
rate_custom_unit

twobytwo_default <- crosstabs(
  output_data,
  row = "am",
  col = "vs"
)
twobytwo_odds_only <- crosstabs(
  output_data,
  row = "am",
  col = "vs",
  measures = c("risk", "or"),
  test = "none"
)
twobytwo_default
twobytwo_odds_only


## 5. Plot branches -----------------------------------------------------------

## Expected: continuous outcome -> boxplot, optional points and test caption.
continuous_plot <- plot_compare(
  output_data,
  outcome = mpg,
  by = am,
  type = "auto",
  show_points = TRUE,
  show_p = TRUE,
  title = "Fuel economy by transmission"
)

continuous_plot_no_jitter <- plot_compare(
  output_data,
  outcome = mpg,
  by = am,
  type = "box",
  show_points = FALSE,
  show_p = FALSE
)

## Expected: non-finite continuous values are excluded from both the plotted
## group N and an optional p-value annotation.
nonfinite_plot_data <- output_data
nonfinite_plot_data$mpg[1] <- Inf
nonfinite_plot <- plot_compare(
  nonfinite_plot_data,
  outcome = mpg,
  by = am,
  show_p = TRUE
)

## Expected: categorical outcome -> within-group proportions or raw counts.
categorical_proportion_plot <- plot_compare(
  output_data,
  outcome = vs,
  by = am,
  type = "bar",
  display = "proportion",
  show_p = TRUE
)

categorical_count_plot <- plot_compare(
  output_data,
  outcome = vs,
  by = am,
  type = "bar",
  display = "count",
  show_p = FALSE
)

## Expected: paired continuous data -> connected participant observations,
## complete-pair N in both axis labels, and a paired-test caption.
paired_plot_data <- data.frame(
  participant_id = rep(seq_len(8), 2),
  visit = factor(
    rep(c("Before", "After"), each = 8),
    levels = c("Before", "After")
  ),
  score = c(
    8, 11, 10, 13, 9, 14, 12, 16,
    10, 12, 13, 14, 12, 15, 16, 19
  )
)
paired_plot <- plot_compare(
  paired_plot_data,
  outcome = score,
  by = visit,
  paired = TRUE,
  id = participant_id,
  show_p = TRUE,
  test = "t_test"
)

## Expected: an ordered outcome keeps its declared order in the legend.
ordinal_plot_data <- data.frame(
  arm = factor(rep(c("Control", "Intervention"), each = 6)),
  response = ordered(
    c(
      "None", "None", "Mild", "Mild", "Severe", "None",
      "None", "Mild", "Mild", "Severe", "Severe", "Mild"
    ),
    levels = c("None", "Mild", "Severe")
  )
)
ordinal_plot <- plot_compare(
  ordinal_plot_data,
  outcome = response,
  by = arm,
  display = "proportion"
)

continuous_plot
continuous_plot_no_jitter
nonfinite_plot
categorical_proportion_plot
categorical_count_plot
paired_plot
ordinal_plot


## 6. Render every supported object class -------------------------------------

## Current compare_groups() usage is explicit: supply the variable with
## `variable =` and the grouping variable with `group =`.
## Keeping these names in shared scripts makes the analytical question clear
## and avoids relying on positional argument order.

objects_to_render <- list(
  describe = describe_selected,
  summary = summary_both,
  distribution = distribution_full,
  comparison = compare_groups(output_data, variable = mpg, group = am),
  effect = effect_size(output_data, outcome = mpg, by = am),
  correlation = correlation_auto,
  proportion = proportion_stats(output_data, vs, by = am),
  rate = rate_stats(
    data.frame(events = c(1, 2), time = c(10, 20)),
    event = events,
    time = time
  ),
  twobytwo = crosstabs(output_data, am, vs),
  builder = summary_table(output_data, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt, vs)) |>
    add_p()
)

rendered_objects <- lapply(
  names(objects_to_render),
  function(object_name) {
    tbl_stats(
      objects_to_render[[object_name]],
      title = paste("Rendered", object_name, "object")
    )
  }
)
names(rendered_objects) <- names(objects_to_render)

rendered_objects

## Audit helpers work consistently for every analytical object.
assumptions_stats(objects_to_render$comparison)
diagnostics_stats(objects_to_render$comparison)
denominators_stats(objects_to_render$comparison)
denominators_stats(objects_to_render$proportion, output = "gt")


## 7. Every visual theme ------------------------------------------------------

base_gt <- tbl_stats(
  objects_to_render$builder,
  title = "Theme comparison"
)

theme_default <- customise_table(base_gt, theme = "default")
theme_journal <- customise_table(base_gt, theme = "journal")
theme_classic <- customise_table(base_gt, theme = "classic")
theme_minimal <- customise_table(base_gt, theme = "minimal")
theme_compact <- customise_table(base_gt, theme = "compact")

theme_default
theme_journal
theme_classic
theme_minimal
theme_compact

## The simplest route accepts the analytical result directly: users do not
## need to remember to call tbl_stats() first.
theme_from_result <- customise_table(
  objects_to_render$builder,
  theme = "journal",
  font = "Arial",
  font_size = 11,
  width = 90,
  row_striping = TRUE,
  show_footnotes = FALSE
)
theme_from_result

## Detailed styling combination.
custom_gt <- customise_table(
  base_gt,
  theme = "journal",
  title = "Custom publication table",
  subtitle = "Manual rendering review",
  source_note = "Source: mtcars teaching data",
  col_labels = c(
    "am = Automatic" = "Automatic",
    "am = Manual" = "Manual"
  ),
  row_labels = c(
    "Fuel economy (mpg)" = "Fuel economy"
  ),
  align = list(
    left = c("Variable", "Level"),
    center = "p-value"
  ),
  bold_cols = "Variable",
  italic_cols = "Level",
  font_size = 12,
  row_striping = TRUE,
  accent_color = "#1F4E79",
  stripe_color = "#F2F6FA"
)

custom_gt

custom_gt_hidden <- customise_table(
  base_gt,
  theme = "minimal",
  hide_cols = "Level",
  row_striping = FALSE
)

custom_gt_hidden


## 8. Flextable conversion ----------------------------------------------------

## Expected: conversion uses the original gtstats object, before tbl_stats().
builder_flextable <- to_flextable(
  objects_to_render$builder,
  font_size = 9,
  font = "Arial",
  autofit = TRUE,
  show_footnotes = TRUE
)

builder_flextable

## Every analytical object should convert through the same public function.
office_tables <- lapply(
  objects_to_render,
  to_flextable,
  font_size = 9,
  show_footnotes = FALSE
)
office_tables


## 9. Optional save routes ----------------------------------------------------

## Uncomment this complete block to test real file creation. Tables support
## HTML, PNG, PDF, RTF, TeX and DOCX. PNG/PDF table export may require a
## browser or additional system tools. Plots use the formats supported by
## ggplot2's graphics devices, including PNG, PDF, TIFF, JPEG and SVG.
##
## A full filename works without a separate `path` argument. Alternatively,
## use a simple filename plus `path` when that reads more clearly.
## dir.create("manual-output", showWarnings = FALSE)
## table_files <- c(
##   html = "manual-output/summary.html",
##   rtf = "manual-output/summary.rtf",
##   tex = "manual-output/summary.tex",
##   docx = "manual-output/summary.docx"
## )
## saved_tables <- lapply(
##   table_files,
##   function(file) save_output(
##     objects_to_render$builder,
##     filename = file,
##     quiet = FALSE
##   )
## )
## saved_gt_table <- save_output(
##   custom_gt,
##   filename = "styled-summary.html",
##   path = "manual-output"
## )
## saved_plots <- c(
##   png = save_output(
##     continuous_plot,
##     "manual-output/comparison.png",
##     width = 7,
##     height = 5,
##     dpi = 300
##   ),
##   pdf = save_output(
##     continuous_plot,
##     "manual-output/comparison.pdf",
##     width = 7,
##     height = 5
##   ),
##   tiff = save_output(
##     continuous_plot,
##     "manual-output/comparison.tiff",
##     width = 7,
##     height = 5,
##     dpi = 300
##   )
## )
## stopifnot(all(file.exists(unlist(saved_tables))))
## stopifnot(file.exists(saved_gt_table))
## stopifnot(all(file.exists(saved_plots)))


## 10. Expected validation errors --------------------------------------------

## Missing variable:
try(describe_data(output_data, vars = "not_a_variable"))

## Continuous grouping variable:
try(compare_groups(output_data, variable = mpg, group = wt))

## Same correlation variable twice:
try(correlation(output_data, x = mpg, y = mpg))

## Incompatible test and structure:
try(compare_groups(output_data, variable = mpg, group = am, test = "chisq"))

## Invalid 2x2 level:
try(
  crosstabs(
    output_data,
    row = am,
    col = vs,
    row_level = "Not a transmission"
  )
)

## Render unsupported object:
try(tbl_stats(output_data))

## Pass a rendered gt object to to_flextable():
try(to_flextable(base_gt))

## Invalid theme:
try(customise_table(base_gt, theme = "unknown"))

## Invalid presentation controls:
try(customise_table(base_gt, font_size = 0))
try(customise_table(base_gt, width = 120))
try(customise_table(base_gt, row_striping = "yes"))
try(to_flextable(objects_to_render$builder, font = ""))
try(to_flextable(objects_to_render$builder, autofit = NA))

## Invalid export inputs:
try(save_output(objects_to_render$builder, filename = "table.csv"))
try(save_output(base_gt, filename = "not-a-plot.png"))


## 11. Reviewer notes ---------------------------------------------------------

## Confirm:
## 1. The seven-column overview is readable and `$issues` is actionable.
## 2. All object classes render with a consistent visual identity.
## 3. Themes are visibly distinct but retain statistical meaning.
## 4. Correlation notes make the scatterplot requirement clear.
## 5. Continuous and categorical plots choose sensible defaults.
## 6. Validation errors name the incorrect argument and corrective action.
## 7. Direct styling of a result is simpler than manually rendering first.
## 8. Word tables retain readable labels with optional concise footnotes.
## 9. Saved paths point exactly to the requested files.
