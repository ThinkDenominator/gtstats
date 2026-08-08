# gtstats 1.0.0 API freeze audit

Date: 29 July 2026

## Decision

The public API is frozen at 24 exported functions. No exported name overlaps
with the current `gtregression` namespace. Internal implementation functions
are deliberately not user-facing.

## Public workflow

| Stage | Recommended function | Purpose |
|---|---|---|
| Understand data | `describe_data()` | Types, completeness, cardinality and concise variable overview |
| Assess shape | `assess_distribution()` | Skewness, Shapiro-Wilk and descriptive-presentation guidance |
| Descriptive Table 1 | `summary_table()` + `add_*()` | Direct or incremental publication-table builder |
| Compare groups | `compare_groups()` | Inferential group comparison with transparent test selection |
| Quantify magnitude | `effect_size()` | Standalone effect-size estimate |
| Correlation | `correlation()` | Pearson or Spearman association |
| Epidemiology | `proportion_stats()`, `rate_stats()`, `crosstabs()` | Proportions, rates and categorical cross-tabs; 2×2 measures when applicable |
| Visualise | `plot_compare()`, `plot_correlation()` | Focused statistical plots |
| Inspect decisions | `assumptions_stats()`, `diagnostics_stats()`, `denominators_stats()` | Analyst-facing audit information |
| Present | `tbl_stats()`, `customise_table()`, `to_flextable()` | gt and Office-ready tables |
| Save | `save_output()` | Table and plot export |

## API principles

- A bare variable name or a single character name is accepted consistently.
- `by` always means the grouping variable.
- `conf.level` controls confidence levels and `digits` controls display
  precision.
- Analytical functions return a `gtstats` object that prints as a concise
  publication-ready table.
- Detailed assumptions, diagnostics and denominators remain available without
  cluttering the default publication output.
- `summary_table()` is the single route for direct and incremental descriptive
  tables.
- `overall` accepts `FALSE`, `TRUE`, `"first"` or `"last"`.
- Automatic statistical choices are documented and can be overridden where
  that is analytically defensible.

## Removed before release

- `descriptive_table()` — conflicted with `gtregression`; use
  `summary_table()`.
- `check_distribution()` — replaced by `assess_distribution()`.
- Public `prop_ci()` and `twobytwo_table()` names — replaced by
  `proportion_stats()` and `crosstabs()`.
- `summary_stats()` — consolidated into `summary_table()`.
- Public `style_table()`, `save_table()` and `save_plot()` names — replaced by
  conflict-free presentation names.
- No-op `quiet` arguments from `describe_data()` and
  `assess_distribution()`.
- The duplicated `tests/manual/manual-summary-table.R`; its scenarios are
  covered more completely in `dev/manual-tests/`.

## Verification gates

- The exact export list is locked in `test-api-names.R`.
- Export conflicts are checked against the current `gtregression` API.
- Automated tests cover statistical branches, validation and result contracts.
- Six real-time manual scripts cover the maintained birthweight data, the
  complete inference matrix, builder combinations and presentation routes.
- `R CMD check` and the pkgdown build must pass before release.

## Remaining release work

No further function redesign is recommended before peer review. Remaining work
should be limited to bug fixes, clearer wording, peer feedback and formal CRAN
submission checks.
