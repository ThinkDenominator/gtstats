# gtstats next-version log

Development version: `1.0.0.9000`

This file records requests and decisions for the release after CRAN
1.0.0. Items remain **planned** until implementation, tests,
documentation, and manual review are complete. Shipped changes belong in
`NEWS.md` without the Planned label.

## Median confidence intervals

Status: **planned**  
Source: team feedback after CRAN 1.0.0

### User need

Users can currently report `median (IQR)`, but
[`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md)
deliberately skips median-only continuous summaries. Users should be
able to request a confidence interval for the population median without
confusing it with an IQR or a t-based confidence interval for a mean.

### Proposed public behaviour

- `summary_table(..., statistic = "median_iqr") |> add_ci()` adds a
  confidence interval for the median.
- Targeted selection through `add_ci(vars = ...)` follows the same
  behaviour.
- Compact tables keep `median (IQR)` as the descriptive summary and add
  the median confidence interval using the existing CI layout rules.
- Separate-layout tables use an explicitly labelled confidence-interval
  column.
- Result metadata and footnotes name the median-CI method and confidence
  level.
- Missing values are excluded consistently with the existing
  continuous-summary denominator policy, and the non-missing sample size
  remains auditable.

### Method decision required before implementation

Select and document one defensible default:

1.  a distribution-free interval based on sample order statistics; or
2.  a bootstrap interval with explicit replicate count, random-seed
    behaviour, and reproducibility guarantees.

The implementation must not use the mean’s t interval for a median. If
an order-statistic interval is selected, the code and notes must handle
small samples, ties, and attainable coverage transparently. If bootstrap
is selected, the API must avoid silently changing the user’s
random-number state.

### Required coverage

- ungrouped and grouped continuous summaries;
- compact and separate layouts;
- global and variable-specific
  [`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md)
  selection;
- confidence levels other than 95%;
- missing values, ties, constant data, and small samples;
- rendering through both
  [`to_flextable()`](https://gtstats.thinkdenominator.com/reference/to_flextable.md)
  and
  [`to_gt()`](https://gtstats.thinkdenominator.com/reference/to_gt.md);
- GUI selection and generated R code;
- function reference, summary-table article, app manual, and manual test
  script;
- agreement with an independently calculated reference result.

### Completion rule

Move this item from Planned to the release changes in `NEWS.md` only
after the API, statistical method, tests, GUI, documentation, and manual
outputs agree.
