# Function map

## Choose by task

| Question | Start with | Use next when needed |
|----|----|----|
| What is in my dataset? | [`describe_data()`](https://gtstats.thinkdenominator.com/reference/describe_data.md) | [`assess_distribution()`](https://gtstats.thinkdenominator.com/reference/assess_distribution.md) and [`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md) for selected continuous variables |
| How do I describe participants by group? | [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md) | [`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md), [`add_total()`](https://gtstats.thinkdenominator.com/reference/add_total.md), or [`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md) only when justified |
| Do groups differ for one variable? | [`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md) | [`effect_size()`](https://gtstats.thinkdenominator.com/reference/effect_size.md) for magnitude; audit helpers for review |
| Are two continuous variables associated? | [`correlation()`](https://gtstats.thinkdenominator.com/reference/correlation.md) | [`plot_correlation()`](https://gtstats.thinkdenominator.com/reference/plot_correlation.md) |
| What is a proportion or rate? | [`proportion_stats()`](https://gtstats.thinkdenominator.com/reference/proportion_stats.md) or [`rate_stats()`](https://gtstats.thinkdenominator.com/reference/rate_stats.md) | — |
| What are RR, OR, and risk difference? | [`crosstabs()`](https://gtstats.thinkdenominator.com/reference/crosstabs.md) | — |
| How do I change the finished table? | [`tbl_stats()`](https://gtstats.thinkdenominator.com/reference/tbl_stats.md) | [`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md), [`to_flextable()`](https://gtstats.thinkdenominator.com/reference/to_flextable.md), [`save_output()`](https://gtstats.thinkdenominator.com/reference/save_output.md) |

### The core distinction

[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md)
describes **many variables** for a descriptive table.
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md)
tests **one variable** across one group variable.
[`assess_distribution()`](https://gtstats.thinkdenominator.com/reference/assess_distribution.md)
describes the empirical shape of selected continuous variables, not an
inferential test choice.

[`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md)
describes group SDs, variances, and spread ratios for selected
continuous variables. It is diagnostic only: Welch methods do not
require equal variances, and the function does not select an inferential
test.

### Objects remain inspectable

Every main function returns an object containing the data behind the
display. The default print method is the publication-ready table.
Components such as `$summary`, `$inferential`, `$recommendations`, and
`$notes` are available for programming and review; they are not extra
steps required for routine use.

``` r

result <- compare_groups(mtcars, variable = mpg, group = am)
result$inferential
diagnostics_stats(result)
```

### A minimal decision tree

``` text
Raw dataset
  └─ describe_data()
      ├─ assess_distribution()  → how to present selected continuous variables
      ├─ assess_variance()      → how observed spread differs across groups
      ├─ summary_table()        → Table 1 / participant characteristics
      └─ compare_groups()       → one inferential question
```

The [Start
here](https://gtstats.thinkdenominator.com/articles/getting-started.md)
article explains the minimal workflow; the [birth-weight case
study](https://gtstats.thinkdenominator.com/articles/birthweight-case-study.md)
applies it end to end. [Missing data and
denominators](https://gtstats.thinkdenominator.com/articles/missing-data-denominators.md)
explains how every analysis population and displayed percentage is
formed.

For a compact, user-facing table of arguments and defaults for every
exported function, see [Function
options](https://gtstats.thinkdenominator.com/articles/function-options.md).

For the complete and auditable `test = "auto"` decision table—including
Welch versus Student/ANOVA, marked-skew rank routes, sparse categorical
tables, and paired/repeated methods—see [Inferential tests and
assumptions](https://gtstats.thinkdenominator.com/articles/inferential-tests.md).
