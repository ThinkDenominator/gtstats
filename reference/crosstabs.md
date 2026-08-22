# Cross-tabulations with optional 2x2 epidemiological measures

Create a publication-ready cross-tabulation for any two categorical
variables. Counts, selected row/column/total percentages, and margins
are displayed. For a binary 2x2 table, risks, risk ratios, odds ratios,
and risk differences are additionally available because their direction
is defined. For a 2x2 table, the selected exposed and event levels are
always retained in the result, including when they were chosen
automatically. Association diagnostics, zero-cell handling, and
complete-pair denominators remain in the audit components rather than
cluttering the displayed table.

## Usage

``` r
crosstabs(
  data,
  row,
  col,
  percent = "column",
  totals = TRUE,
  row_level = NULL,
  col_level = NULL,
  measures = c("rr", "or", "rd"),
  conf.level = 0.95,
  risk_ci = c("wilson", "exact"),
  test = c("auto", "none", "chisq", "fisher"),
  zero_correction = c("haldane_anscombe", "none"),
  simulate_B = 10000,
  digits = 2,
  format = c("table", "tibble")
)
```

## Arguments

- data:

  A data frame.

- row:

  Categorical row variable. For a binary 2x2 table, this is the
  exposure/reference axis.

- col:

  Categorical column variable. For a binary 2x2 table, this is the
  outcome/event axis.

- percent:

  Percentages to show in each cell: `"column"` (default), `"row"`,
  `"total"`, or `"none"`. Supply `c("row", "column")` to show more than
  one denominator.

- totals:

  Logical; include row, column, and grand totals.

- row_level:

  Level of `row` treated as exposed. A sensible event-like level is
  selected when omitted; set this explicitly for reporting.

- col_level:

  Level of `col` treated as the event. A sensible event-like level is
  selected when omitted; set this explicitly for reporting.

- measures:

  Measures to display: risk, risk ratio (`"rr"`), odds ratio (`"or"`),
  and/or risk difference (`"rd"`).

- conf.level:

  Confidence level for intervals.

- risk_ci:

  Risk confidence-interval method: `"wilson"` or `"exact"`.

- test:

  Association test: `"auto"`, `"none"`, `"chisq"`, or `"fisher"`.

- zero_correction:

  Zero-cell strategy: `"haldane_anscombe"` or `"none"`.

- simulate_B:

  Number of simulations for the automatic Fisher test in a sparse table
  larger than 2x2.

- digits:

  Number of decimal places.

- format:

  Output format: `"table"` (default) or a plain console `"tibble"`.

## Value

A `gt_twobytwo` object.

## Examples

``` r
crosstabs(mtcars, row = am, col = vs)
```
