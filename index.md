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
| Assess | [`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md) | Group SDs, variances, spread ratios, and median-centred Levene support |
| Describe | [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md) | Publication-ready participant-characteristics table |
| Present calculated results | [`as_stats_table()`](https://gtstats.thinkdenominator.com/reference/as_stats_table.md) | Value-preserving publication table for an already summarised data frame |
| Compare | [`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md) | One focused group comparison with a clearly identified test and automatic-selection rule |
| Audit | [`assumptions_stats()`](https://gtstats.thinkdenominator.com/reference/assumptions_stats.md), [`diagnostics_stats()`](https://gtstats.thinkdenominator.com/reference/diagnostics_stats.md), [`denominators_stats()`](https://gtstats.thinkdenominator.com/reference/denominators_stats.md) | Transparent decisions and analysis population |
| Export | [`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md), [`to_gt()`](https://gtstats.thinkdenominator.com/reference/to_gt.md), [`save_output()`](https://gtstats.thinkdenominator.com/reference/save_output.md) | A modifiable, report-ready table |
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

customise_table()  
save_output()

## Why it exists

Statistics packages often make a user choose between an oversimplified
default and a highly technical workflow. `gtstats` is designed to bridge
that gap:

- publication-ready tables are the default, not an extra formatting
  task;
- automatic test selection is visible and can always be overridden;
- Welch methods are the conservative default for suitable independent
  continuous comparisons; `var_equal = TRUE` is available when equal
  variances are prespecified and justified, not inferred from a variance
  test;
- distribution, variance, assumptions, and denominators are inspectable;
- the table builder offers simple defaults with optional layers of
  control.

The automatic algorithm is documented in full: marked skewness—not a
Shapiro-Wilk p-value alone—triggers rank-based continuous tests; sparse
categorical tables use Fisher’s exact test when an expected count is
below 1 or more than 20% are below 5; and paired/repeated designs use
their dedicated methods. See the [inferential tests and assumptions
guide](https://gtstats.thinkdenominator.com/articles/inferential-tests.html).

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

gtstats includes five labelled datasets, so examples work without
installing other packages:

``` r

data(
  "birthwt", "trial_data", "paired_data", "outbreak_data",
  "surveillance_data", package = "gtstats"
)
```

- `birthwt`: real low-birth-weight clinical data for descriptive tables,
  independent comparisons, and epidemiology.
- `trial_data`: a three-arm synthetic trial for Welch ANOVA,
  Kruskal-Wallis, chi-square, Fisher exact, correlations, and rates.
- `paired_data`: long-format paired follow-up data for paired t-tests,
  Wilcoxon signed-rank, and McNemar tests.
- `outbreak_data`: the real CDC Oswego foodborne-outbreak line list for
  attack rates and 2x2 epidemiology.
- `surveillance_data`: an archived CDC weekly hospital-admission extract
  for aggregate counts, population denominators, and rates per 100,000.

## Prefer a guided interface?

The package remains code-first, but a Shiny companion is available when
you prefer to learn by clicking through the workflow. It includes all
five teaching datasets, data from the current R environment, CSV/Excel
upload, a working data dictionary, distribution and variance checks, a
layer-by-layer summary table, outbreak and surveillance tables, focused
group comparisons, correlations and crosstabs. Tables can be downloaded
as Word, HTML, PDF, or RTF, and every analysis has copyable and
downloadable R code. Excel import uses the optional `rio` package.

``` r

install.packages("shiny") # once, if needed
install.packages("rio")   # once, only for Excel files
gtstats_app() # opens in the RStudio Viewer when available
```

The interface is intentionally a guide rather than a black box: use the
code shown beside each result in an R script or Quarto document to keep
the final analysis reproducible.

The app keeps three table routes separate. Choose **Summary table** for
raw participant-level data, **Epi table** when events and denominators
still need calculation, and **Current data are final calculated
results** in **Customise table** only when every supplied row and value
should be preserved exactly through
[`as_stats_table()`](https://gtstats.thinkdenominator.com/reference/as_stats_table.md).

## Five-minute workflow

``` r

data("birthwt", package = "gtstats")

overview <- describe_data(birthwt)

distribution <- assess_distribution(birthwt, vars = c(age, lwt), by = low)
variance <- assess_variance(birthwt, vars = c(age, lwt), by = low)
# Use `test = "none"` for descriptive spreads only, or `test = "bartlett"`
# when the stronger normal-distribution assumption is justified.

table_one <- summary_table(
  birthwt,
  by = low,
  include = c(age, lwt, race, smoke),
  overall = "last",
  layout = "separate"
) |>
  add_ci(vars = c(age, race)) |>
  add_p()

# Optional categorical-only presentation with distinct n and % columns
categorical_table <- summary_table(
  birthwt,
  by = low,
  include = c(race, smoke),
  categorical_layout = "separate"
)

# Optional compact binary presentation: one clinically relevant event per row
compact_binary_table <- summary_table(
  birthwt,
  by = low,
  include = c(smoke, ht, race),
  show_dichotomous = "single_row",
  value = c(smoke = "Yes", ht = "Yes")
)

# Missing values are excluded from categorical percentage denominators by
# default. Use this explicit option only when Missing is itself a reported
# category and should contribute to 100%.
missing_as_category <- summary_table(
  birthwt,
  include = c(race, smoke),
  missing = "as_category"
)

comparison <- compare_groups(birthwt, variable = lwt, group = low)
comparison$method$selection_rule
diagnostics_stats(comparison)
```

Each object prints as a publication-ready `flextable`, ready for Word
and PowerPoint. Use
[`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md)
to finish its appearance. Use
[`to_gt()`](https://gtstats.thinkdenominator.com/reference/to_gt.md)
only when an HTML-focused `gt` table is specifically required.

``` r

table_one |>
  customise_table(
    theme = "journal",
    title = "Table 1. Maternal characteristics",
    spanning_header = list(
      "Birth-weight groups" = c(
        "low = Normal birth weight",
        "low = Low birth weight"
      )
    ),
    borders = "horizontal",
    pvalue_style = "threshold"
  ) |>
  save_output("table-1.docx")

# Explicit HTML/gt route
to_gt(table_one, title = "Table 1. Maternal characteristics")
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

## Publication tables and console output

Core statistical functions produce a publication-ready table by default.
In a terminal, automated test, or plain-text workflow, request a real
tibble:

``` r

compare_groups(birthwt_data, variable = age, group = low)

compare_groups(
  birthwt_data,
  variable = age,
  group = low,
  format = "tibble"
)
```

The same `format = "table"` or `format = "tibble"` choice is available
for data description, distribution and variance assessment, effect
sizes, correlations, proportions, rates, and cross-tabulations. A
summary-table builder stays composable in either format, so
[`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md) and
other layers still work before the completed tibble is printed.

## Function map

| Workflow | Functions |
|----|----|
| Understand | [`describe_data()`](https://gtstats.thinkdenominator.com/reference/describe_data.md), [`assess_distribution()`](https://gtstats.thinkdenominator.com/reference/assess_distribution.md), [`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md) |
| Build Table 1 | [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md), [`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md), [`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md), [`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md), [`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md), [`add_total()`](https://gtstats.thinkdenominator.com/reference/add_total.md), [`add_row()`](https://gtstats.thinkdenominator.com/reference/add_row.md) |
| Compare | [`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md), [`effect_size()`](https://gtstats.thinkdenominator.com/reference/effect_size.md), [`correlation()`](https://gtstats.thinkdenominator.com/reference/correlation.md) |
| Outbreak and surveillance tables | [`epi_table()`](https://gtstats.thinkdenominator.com/reference/epi_table.md) |
| Format an already calculated data frame | [`as_stats_table()`](https://gtstats.thinkdenominator.com/reference/as_stats_table.md) |
| Focused epidemiology calculations | [`proportion_stats()`](https://gtstats.thinkdenominator.com/reference/proportion_stats.md), [`rate_stats()`](https://gtstats.thinkdenominator.com/reference/rate_stats.md), [`crosstabs()`](https://gtstats.thinkdenominator.com/reference/crosstabs.md) |
| Inspect decisions | [`assumptions_stats()`](https://gtstats.thinkdenominator.com/reference/assumptions_stats.md), [`diagnostics_stats()`](https://gtstats.thinkdenominator.com/reference/diagnostics_stats.md), [`denominators_stats()`](https://gtstats.thinkdenominator.com/reference/denominators_stats.md) |
| Visualise | [`plot_compare()`](https://gtstats.thinkdenominator.com/reference/plot_compare.md), [`plot_correlation()`](https://gtstats.thinkdenominator.com/reference/plot_correlation.md) |
| Guided interface | [`gtstats_app()`](https://gtstats.thinkdenominator.com/reference/gtstats_app.md) |
| Polish and export | [`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md), [`to_flextable()`](https://gtstats.thinkdenominator.com/reference/to_flextable.md), [`to_gt()`](https://gtstats.thinkdenominator.com/reference/to_gt.md), [`save_output()`](https://gtstats.thinkdenominator.com/reference/save_output.md) |

[`correlation()`](https://gtstats.thinkdenominator.com/reference/correlation.md)
handles both a prespecified pair and an exploratory matrix. The matrix
retains pair-specific denominators and p-values in `$summary`, while
[`plot_correlation()`](https://gtstats.thinkdenominator.com/reference/plot_correlation.md)
provides a labelled coefficient heatmap.

``` r

correlation(mtcars, vars = c(mpg, disp, hp, wt)) |>
  plot_correlation()
```

## Citation

If `gtstats` contributes to your analysis, tables, teaching, or
publication, please cite:

> Polani R, Kaviprawin M, Sakthivel M, Eliyas SK, Krishnamoorthy Y
> (2026). *gtstats: Beginner-Friendly Statistics and Publication-Ready
> Tables*. R package version 1.0.0.
> <https://gtstats.thinkdenominator.com/>.

R returns the authoritative citation and BibTeX entry installed with the
package:

``` r

citation("gtstats")
toBibtex(citation("gtstats"))
```

The pkgdown **Citing gtstats** article provides a copy-ready BibTeX
record and reproducibility guidance. The reserved Zenodo DOI will be
added here after its record is published and the DOI resolves publicly.
