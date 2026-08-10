# gtstats

R package for clinical, epidemiological, and public-health analysis

Understand your data, build a publication-ready Table 1, and answer
focused statistical questions without hand-formatting every output.

[Start the
workflow](https://gtstats.thinkdenominator.com/articles/getting-started.html)
[View the case
study](https://gtstats.thinkdenominator.com/articles/birthweight-case-study.html)

## Publication-ready descriptive and inferential statistics

`gtstats` helps students, researchers, and public-health analysts move
from a new dataset to clear descriptive results, focused comparisons,
and a publication-ready Table 1. It keeps the R syntax approachable
while retaining the underlying results, denominators, assumptions, and
automatic decisions for review.

| Stage | Start with | What you get |
|----|----|----|
| Understand | [`describe_data()`](https://gtstats.thinkdenominator.com/reference/describe_data.md) | Variable type, completeness, levels/range, and concise data overview |
| Assess | [`assess_distribution()`](https://gtstats.thinkdenominator.com/reference/assess_distribution.md) | Distribution diagnostics and descriptive guidance for continuous variables |
| Assess | [`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md) | Group SDs, variances, and descriptive spread ratios |
| Describe | [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md) | Publication-ready participant-characteristics table |
| Compare | [`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md) | One focused group comparison with a clearly identified test and automatic-selection rule |
| Audit | [`assumptions_stats()`](https://gtstats.thinkdenominator.com/reference/assumptions_stats.md), [`diagnostics_stats()`](https://gtstats.thinkdenominator.com/reference/diagnostics_stats.md), [`denominators_stats()`](https://gtstats.thinkdenominator.com/reference/denominators_stats.md) | Transparent decisions and analysis population |
| Export | [`tbl_stats()`](https://gtstats.thinkdenominator.com/reference/tbl_stats.md), [`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md), [`save_output()`](https://gtstats.thinkdenominator.com/reference/save_output.md) | A modifiable, report-ready table |
| Guided | [`gtstats_app()`](https://gtstats.thinkdenominator.com/reference/gtstats_app.md) | A point-and-click companion that generates the matching R code |

Understand

describe_data()  
assess_distribution()

Describe

summary_table()  
add\_\*()

Compare

compare_groups()  
correlation()

Report

tbl_stats()  
save_output()

## Why it exists

Statistics packages often make a user choose between an oversimplified
default and a highly technical workflow. `gtstats` is designed to bridge
that gap:

- publication-ready tables are the default, not an extra formatting
  task;
- automatic test selection is visible and can always be overridden;
- distribution, variance, assumptions, and denominators are inspectable;
- the table builder offers simple defaults with optional layers of
  control.

`gtstats` uses established R statistical engines such as `stats`,
`dplyr`, `ggplot2`, `gt`, and `flextable`; it provides a coherent
teaching and reporting workflow around them.

## Install

``` r

# Development version until gtstats is available on CRAN
remotes::install_github("ThinkDenominator/gtstats")
library(gtstats)
```

## Built-in teaching data

gtstats includes three labelled datasets, so examples work without
installing other packages:

``` r

data("birthwt", "trial_data", "paired_data", package = "gtstats")
```

- `birthwt`: real low-birth-weight clinical data for descriptive tables,
  independent comparisons, and epidemiology.
- `trial_data`: a three-arm synthetic trial for Welch ANOVA,
  Kruskal-Wallis, chi-square, Fisher exact, correlations, and rates.
- `paired_data`: long-format paired follow-up data for paired t-tests,
  Wilcoxon signed-rank, and McNemar tests.

## Prefer a guided interface?

The package remains code-first, but a Shiny companion is available when
you prefer to learn by clicking through the workflow. It includes the
three teaching datasets, CSV/Excel upload, a working data dictionary,
distribution and variance checks, Table 1, focused group comparisons,
crosstabs, Word/HTML/PDF/RTF table downloads, an in-session history, and
copyable or downloadable R code for every analysis. Excel import uses
the optional `rio` package.

``` r

install.packages("shiny") # once, if needed
install.packages("rio")   # once, only for Excel files
gtstats_app() # opens in the RStudio Viewer when available
```

The interface is intentionally a guide rather than a black box: use the
code shown beside each result in an R script or Quarto document to keep
the final analysis reproducible.

## Five-minute workflow

``` r

data("birthwt", package = "gtstats")

overview <- describe_data(birthwt)

distribution <- assess_distribution(birthwt, vars = c(age, lwt), by = low)
variance <- assess_variance(birthwt, vars = c(age, lwt), by = low)

table_one <- summary_table(
  birthwt,
  by = low,
  include = c(age, lwt, race, smoke),
  overall = "last"
) |>
  add_p()

comparison <- compare_groups(birthwt, variable = lwt, group = low)
comparison$method$selection_rule
diagnostics_stats(comparison)
```

Each object prints as a publication-ready table.
[`tbl_stats()`](https://gtstats.thinkdenominator.com/reference/tbl_stats.md)
is optional: use it when you want to add a title, customise the
appearance, or export a `gt` table.

``` r

table_one |>
  tbl_stats(title = "Table 1. Vehicle characteristics") |>
  customise_table(theme = "journal") |>
  save_output("table-1.docx")
```

## Browse by task

| Task | Start here |
|----|----|
| First workflow | [Getting started](https://gtstats.thinkdenominator.com/articles/getting-started.html) |
| Complete worked example | [Birth-weight case study](https://gtstats.thinkdenominator.com/articles/birthweight-case-study.html) |
| Build Table 1 | [Descriptive tables](https://gtstats.thinkdenominator.com/articles/descriptive-tables.html) |
| Select and interpret comparisons | [Inferential tests and assumptions](https://gtstats.thinkdenominator.com/articles/inferential-tests.html) |
| Missingness and denominators | [Missing data and denominators](https://gtstats.thinkdenominator.com/articles/missing-data-denominators.html) |
| Confidence intervals and 2x2 tables | [Epidemiology helpers](https://gtstats.thinkdenominator.com/articles/epi-helpers.html) |
| Every argument and default | [Function options](https://gtstats.thinkdenominator.com/articles/function-options.html) |
| All functions | [Reference index](https://gtstats.thinkdenominator.com/reference/index.html) |

## Function map

| Workflow | Functions |
|----|----|
| Understand | [`describe_data()`](https://gtstats.thinkdenominator.com/reference/describe_data.md), [`assess_distribution()`](https://gtstats.thinkdenominator.com/reference/assess_distribution.md), [`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md) |
| Build Table 1 | [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md), [`add_summary()`](https://gtstats.thinkdenominator.com/reference/add_summary.md), [`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md), [`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md), [`add_total()`](https://gtstats.thinkdenominator.com/reference/add_total.md), [`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md), [`add_row()`](https://gtstats.thinkdenominator.com/reference/add_row.md) |
| Compare | [`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md), [`effect_size()`](https://gtstats.thinkdenominator.com/reference/effect_size.md), [`correlation()`](https://gtstats.thinkdenominator.com/reference/correlation.md) |
| Epidemiology | [`proportion_stats()`](https://gtstats.thinkdenominator.com/reference/proportion_stats.md), [`rate_stats()`](https://gtstats.thinkdenominator.com/reference/rate_stats.md), [`crosstabs()`](https://gtstats.thinkdenominator.com/reference/crosstabs.md) |
| Inspect decisions | [`assumptions_stats()`](https://gtstats.thinkdenominator.com/reference/assumptions_stats.md), [`diagnostics_stats()`](https://gtstats.thinkdenominator.com/reference/diagnostics_stats.md), [`denominators_stats()`](https://gtstats.thinkdenominator.com/reference/denominators_stats.md) |
| Visualise | [`plot_compare()`](https://gtstats.thinkdenominator.com/reference/plot_compare.md), [`plot_correlation()`](https://gtstats.thinkdenominator.com/reference/plot_correlation.md) |
| Guided interface | [`gtstats_app()`](https://gtstats.thinkdenominator.com/reference/gtstats_app.md) |
| Polish and export | [`tbl_stats()`](https://gtstats.thinkdenominator.com/reference/tbl_stats.md), [`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md), [`to_flextable()`](https://gtstats.thinkdenominator.com/reference/to_flextable.md), [`save_output()`](https://gtstats.thinkdenominator.com/reference/save_output.md) |

## Citation

Until the package is on CRAN or has a DOI, use the package citation
generated by R:

``` r

citation("gtstats")
```
