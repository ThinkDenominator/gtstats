# Package index

## Teaching datasets

Built-in, labelled datasets for reproducible learning and examples.

- [`birthwt`](https://gtstats.thinkdenominator.com/reference/birthwt.md)
  : Low birth weight data
- [`trial_data`](https://gtstats.thinkdenominator.com/reference/trial_data.md)
  : Three-arm clinical trial teaching data
- [`paired_data`](https://gtstats.thinkdenominator.com/reference/paired_data.md)
  : Paired follow-up teaching data
- [`outbreak_data`](https://gtstats.thinkdenominator.com/reference/outbreak_data.md)
  : Oswego foodborne-outbreak line list
- [`surveillance_data`](https://gtstats.thinkdenominator.com/reference/surveillance_data.md)
  : Archived weekly US hospital-admission surveillance data

## Guided interface

A point-and-click companion that generates reproducible gtstats code.

- [`gtstats_app()`](https://gtstats.thinkdenominator.com/reference/gtstats_app.md)
  : Launch the gtstats graphical interface

## 

Understand the data

Understand variable types, missing data, and distributions before
analysis.

- [`describe_data()`](https://gtstats.thinkdenominator.com/reference/describe_data.md)
  : Understand a dataset before analysis
- [`assess_distribution()`](https://gtstats.thinkdenominator.com/reference/assess_distribution.md)
  : Assess the empirical distribution of continuous variables
- [`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md)
  : Assess variation of continuous variables across groups

## 

Describe and compare

Test whether groups differ and quantify associations.

- [`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md)
  : Compare groups using common inferential tests
- [`effect_size()`](https://gtstats.thinkdenominator.com/reference/effect_size.md)
  : Estimate an effect size
- [`correlation()`](https://gtstats.thinkdenominator.com/reference/correlation.md)
  : Correlation analysis for one pair or several continuous variables

## 

Inspect decisions

Inspect assumptions, diagnostic checks, and every analysis denominator.

- [`assumptions_stats()`](https://gtstats.thinkdenominator.com/reference/assumptions_stats.md)
  : Inspect statistical assumptions
- [`diagnostics_stats()`](https://gtstats.thinkdenominator.com/reference/diagnostics_stats.md)
  : Inspect statistical diagnostics
- [`denominators_stats()`](https://gtstats.thinkdenominator.com/reference/denominators_stats.md)
  : Inspect statistical denominators

## Plots

Visualise group comparisons and statistical outputs.

- [`plot_compare()`](https://gtstats.thinkdenominator.com/reference/plot_compare.md)
  : Plot a group comparison
- [`plot_correlation()`](https://gtstats.thinkdenominator.com/reference/plot_correlation.md)
  : Plot the relationship between two continuous variables

## Epidemiology

Proportions with Wilson score confidence intervals by default (exact
binomial optional), event rates with exact Poisson confidence intervals,
and 2x2 tables with RR, OR, and RD.

- [`epi_table()`](https://gtstats.thinkdenominator.com/reference/epi_table.md)
  : Outbreak and surveillance summary table
- [`proportion_stats()`](https://gtstats.thinkdenominator.com/reference/proportion_stats.md)
  : Proportion statistics
- [`rate_stats()`](https://gtstats.thinkdenominator.com/reference/rate_stats.md)
  : Incidence rate with exact Poisson confidence interval
- [`crosstabs()`](https://gtstats.thinkdenominator.com/reference/crosstabs.md)
  : Cross-tabulations with optional 2x2 epidemiological measures

## Build a descriptive table

Build the descriptive foundation, then add confidence intervals,
comparisons, or specialist rows only when required.

- [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md)
  : Create a summary table builder
- [`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md)
  : Add confidence intervals to a summary table
- [`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md) :
  Add p-values to a descriptive table
- [`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md)
  : Add a proportion row to a descriptive table
- [`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md)
  : Add an event-rate row
- [`add_total()`](https://gtstats.thinkdenominator.com/reference/add_total.md)
  : Add total counts to a descriptive table
- [`add_row()`](https://gtstats.thinkdenominator.com/reference/add_row.md)
  : Add a custom row to a descriptive table
- [`add_summary()`](https://gtstats.thinkdenominator.com/reference/add_summary.md)
  : Add summary rows to a descriptive table

## Render, style, and export

Preserve already calculated tables, render as flextable by default,
apply publication styling, export to Office, or opt into gt for HTML.

- [`as_stats_table()`](https://gtstats.thinkdenominator.com/reference/as_stats_table.md)
  : Convert an already summarised data frame into a publication table
- [`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md)
  : Customize a gtstats table
- [`to_flextable()`](https://gtstats.thinkdenominator.com/reference/to_flextable.md)
  : Convert a gtstats object to flextable
- [`to_gt()`](https://gtstats.thinkdenominator.com/reference/to_gt.md) :
  Convert a gtstats result to a gt table
- [`save_output()`](https://gtstats.thinkdenominator.com/reference/save_output.md)
  : Save a gtstats table or plot

## Print methods

S3 print methods called automatically when printing gtstats objects to
the console.

- [`print(`*`<gt_compare>`*`)`](https://gtstats.thinkdenominator.com/reference/print.gt_compare.md)
  : Print a gtstats compare object
- [`print(`*`<gt_correlation>`*`)`](https://gtstats.thinkdenominator.com/reference/print.gt_correlation.md)
  : Print a gtstats correlation object
- [`print(`*`<gt_data_table>`*`)`](https://gtstats.thinkdenominator.com/reference/print.gt_data_table.md)
  : Print an already summarised gtstats table
- [`print(`*`<gt_describe>`*`)`](https://gtstats.thinkdenominator.com/reference/print.gt_describe.md)
  : Print a gtstats describe object
- [`print(`*`<gt_distribution>`*`)`](https://gtstats.thinkdenominator.com/reference/print.gt_distribution.md)
  : Print a gtstats distribution object
- [`print(`*`<gt_effect>`*`)`](https://gtstats.thinkdenominator.com/reference/print.gt_effect.md)
  : Print a gtstats effect-size object
- [`print(`*`<gt_epi_table>`*`)`](https://gtstats.thinkdenominator.com/reference/print.gt_epi_table.md)
  : Print an outbreak and surveillance table
- [`print(`*`<gt_prop>`*`)`](https://gtstats.thinkdenominator.com/reference/print.gt_prop.md)
  : Print a gtstats proportion object
- [`print(`*`<gt_rate>`*`)`](https://gtstats.thinkdenominator.com/reference/print.gt_rate.md)
  : Print a gtstats rate object
- [`print(`*`<gt_twobytwo>`*`)`](https://gtstats.thinkdenominator.com/reference/print.gt_twobytwo.md)
  : Print a gtstats 2x2 table object
- [`print(`*`<gt_variance>`*`)`](https://gtstats.thinkdenominator.com/reference/print.gt_variance.md)
  : Print a gtstats variance object
- [`print(`*`<gtstats_summary>`*`)`](https://gtstats.thinkdenominator.com/reference/print.gtstats_summary.md)
  : Print a descriptive table
