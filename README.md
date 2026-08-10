
<!-- README.md is generated from README.Rmd. -->

<div class="gs-hero">

<p class="gs-kicker">

R package for clinical, epidemiological, and public-health analysis
</p>

<h1>

gtstats
</h1>

<p>

Understand your data, build a publication-ready Table 1, and answer
focused statistical questions without hand-formatting every output.
</p>

<p>

<a class="gs-button" href="https://gtstats.thinkdenominator.com/articles/getting-started.html">Start
the workflow</a>
<a class="gs-button gs-button-secondary" href="https://gtstats.thinkdenominator.com/articles/birthweight-case-study.html">View
the case study</a>
</p>

</div>

<!-- badges: start -->

[![R-CMD-check](https://github.com/ThinkDenominator/gtstats/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ThinkDenominator/gtstats/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/ThinkDenominator/gtstats/actions/workflows/pkgdown.yaml/badge.svg)](https://gtstats.thinkdenominator.com/)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.md)
[![R: \>=
4.1](https://img.shields.io/badge/R-%3E%3D4.1-276DC3?logo=r)](https://www.r-project.org/)

<!-- badges: end -->

## Publication-ready descriptive and inferential statistics

`gtstats` helps students, researchers, and public-health analysts move
from a new dataset to clear descriptive results, focused comparisons,
and a publication-ready Table 1. It keeps the R syntax approachable
while retaining the underlying results, denominators, assumptions, and
automatic decisions for review.

| Stage | Start with | What you get |
|----|----|----|
| Understand | `describe_data()` | Variable type, completeness, levels/range, and concise data overview |
| Assess | `assess_distribution()` | Distribution diagnostics and descriptive guidance for continuous variables |
| Assess | `assess_variance()` | Group SDs, variances, and descriptive spread ratios |
| Describe | `summary_table()` | Publication-ready participant-characteristics table |
| Compare | `compare_groups()` | One focused group comparison with a clearly identified test and automatic-selection rule |
| Audit | `assumptions_stats()`, `diagnostics_stats()`, `denominators_stats()` | Transparent decisions and analysis population |
| Export | `tbl_stats()`, `customise_table()`, `save_output()` | A modifiable, report-ready table |
| Guided | `gtstats_app()` | A point-and-click companion that generates the matching R code |

<div class="gs-strip">

<div class="gs-strip-item">

<p class="gs-strip-label">

Understand
</p>

<p class="gs-strip-fns">

describe_data()<br>assess_distribution()
</p>

</div>

<div class="gs-strip-item">

<p class="gs-strip-label">

Describe
</p>

<p class="gs-strip-fns">

summary_table()<br>add\_\*()
</p>

</div>

<div class="gs-strip-item">

<p class="gs-strip-label">

Compare
</p>

<p class="gs-strip-fns">

compare_groups()<br>correlation()
</p>

</div>

<div class="gs-strip-item">

<p class="gs-strip-label">

Report
</p>

<p class="gs-strip-fns">

tbl_stats()<br>save_output()
</p>

</div>

</div>

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

Each object prints as a publication-ready table. `tbl_stats()` is
optional: use it when you want to add a title, customise the appearance,
or export a `gt` table.

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
| Understand | `describe_data()`, `assess_distribution()`, `assess_variance()` |
| Build Table 1 | `summary_table()`, `add_summary()`, `add_proportion()`, `add_rate()`, `add_total()`, `add_p()`, `add_row()` |
| Compare | `compare_groups()`, `effect_size()`, `correlation()` |
| Epidemiology | `proportion_stats()`, `rate_stats()`, `crosstabs()` |
| Inspect decisions | `assumptions_stats()`, `diagnostics_stats()`, `denominators_stats()` |
| Visualise | `plot_compare()`, `plot_correlation()` |
| Guided interface | `gtstats_app()` |
| Polish and export | `tbl_stats()`, `customise_table()`, `to_flextable()`, `save_output()` |

## Citation

Until the package is on CRAN or has a DOI, use the package citation
generated by R:

``` r
citation("gtstats")
```
