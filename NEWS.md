# gtstats 1.0.0

* Completed the GUI plotting workflow. Distribution assessments now expose
  histogram, density, Q-Q and boxplot diagnostics; group comparisons expose
  `plot_compare()` controls; and correlation plots expose labels, confidence
  level, typography and colour controls. Every plot is downloadable as PNG or
  PDF and represented in the generated reproducible R code.

* Added a dedicated **Customise table** workspace immediately after Summary
  table in `gtstats_app()`, matching the post-processing workflow in the
  gtregression app. The latest Summary table is carried forward and displayed
  automatically. Users can relabel columns, rows and levels, change titles,
  notes and styling, hide columns, download the result, and copy reproducible
  `customise_table()` code without altering the underlying statistics.

* `crosstabs(format = "tibble")` now returns plain console-friendly cells such
  as `86 (66.15%)` instead of HTML line-break markup. The default publication
  table retains its stacked cell layout.

* `add_p()` now accepts tidy-select `include`, allowing variables to remain in
  a descriptive table without receiving an inappropriate p-value. The GUI
  exposes the same control as **Do not test** and reproduces it in generated R
  code. Birth-weight examples now avoid testing `bwt` against the category
  derived from `bwt`.

* Finalised the pre-CRAN comparison API: `effect_size()` and `plot_compare()`
  now use `variable` and `group`, matching `compare_groups()`. `add_p()` now
  calls its marked-skewness option `distribution_check`, replacing the
  misleading `normality_check` name.
* Automatic `"recommended"` continuous summaries are now resolved once per
  variable across all displayed groups, preventing a Table 1 from mixing mean
  (SD) and median (IQR) for the same variable. Categorical confidence intervals
  now use Wilson intervals by default, with `ci_method = "exact"` available.
* Simulated Fisher exact tests for larger contingency tables are reproducible
  by default via `fisher_seed = 1049` and preserve the caller's RNG state.
* Repeated-measures ANOVA now reports a Greenhouse-Geisser-corrected p-value and
  diagnostics. `plot_compare()` now supports repeated continuous and paired
  categorical displays and exposes the same repeated-test choices as
  `compare_groups()`.

* Redesigned `gtstats_app()` around a safer end-to-end workflow. Original data
  now remain the active analysis dataset until prepared data are explicitly
  chosen; Data Prep can set publication display labels; and Table 1 is now
  named Summary table. The summary builder provides per-variable descriptive
  and inferential choices, live table styling, matching export output, and
  copy/download access to both analysis code and the complete session script.
* Replaced the Summary table's expanding per-variable dropdown grid with two
  validated override editors. Unlisted continuous variables use Recommended;
  unlisted tests use Auto. Users enter only exceptions as `variable = option`,
  can use `none` to suppress a test, receive live validation and examples, and
  obtain matching named-vector R code.
* Organised the app's Summary table controls into four numbered sections:
  contents, summaries, statistical comparisons, and appearance. Advanced Auto
  settings and cosmetic options are collapsed until needed. `mean_ci` cells
  now show the estimate and interval without repeating "95% CI" in every cell;
  the confidence level remains clearly defined in the relevant footnote.

* Extended `correlation()` with a multi-variable matrix route via `vars`.
  Matrix output uses one transparent Pearson or Spearman method throughout,
  retains pairwise denominators and adjusted p-values in tidy `$summary`, and
  supports lower, upper or full publication layouts. `plot_correlation()` now
  visualises these results as a labelled coefficient heatmap.
* Correlation matrices can now preserve input order, sort labels
  alphabetically, or use correlation-based clustering; users can hide the
  diagonal and include pairwise n alone or alongside adjusted p-values in each
  cell. Matrix heatmaps inherit the selected triangle and diagonal settings.
* The app now includes a complete Correlation workspace for pair and matrix
  analyses, with checkbox variable selection, matrix layout and ordering,
  cell-content and multiplicity controls, table/heatmap previews, Audit tabs,
  downloadable tables and plots, and reproducible analysis/plot code.
  It also provides tidy CSV export, a selected-variable counter, large-matrix
  guidance, a visible warning when pairwise denominators differ, collapsible
  advanced controls, and a reset-to-defaults action.

* Redesigned standalone `proportion_stats()` publication tables. Group values
  are now spanning headers with separate estimate and confidence-interval
  columns, while `$summary` remains a tidy long-form result. The compact row
  added by `add_proportion()` is unchanged.

* Redesigned standalone `rate_stats()` publication tables to use group
  spanners with separate Events, accumulated time, Rate and confidence-interval
  columns. `$summary` remains tidy and `add_rate()` remains unchanged.

* Corrected independent 2 x 2 audit wording from "complete pairs" to
  "complete observations", and ensured `diagnostics_stats()` identifies the
  crosstab outcome instead of displaying a missing variable name.

* Automatic continuous comparisons now reserve rank-based methods for marked
  skewness. Shapiro-Wilk and mild asymmetry remain supporting information, so
  `compare_groups()` and `add_p()` consistently use Welch methods for the
  birth-weight example's maternal age.
* `assess_variance()` now displays `test = "levene"` by default, implemented
  as the median-centred Brown-Forsythe modification. It is supporting
  information and never changes automatic test selection.
* Restored variance to the visible `assess_variance()` output: every group cell
  now shows n, SD, and variance, with both observed SD and variance ratios shown
  in the publication table. No additional argument is required.
* Paired comparison output now labels the estimate as a mean within-pair
  difference and reports exclusions caused by incomplete or non-unique pairs.
  Paired publication tables now identify the complete-pair denominator;
  McNemar/Cochran's Q notes are binary-specific; and Friedman fails clearly
  when there is no within-participant variation instead of printing `NA`.
* `assess_variance()` now explicitly states that its spread diagnostics do not
  assess pairing or repeated-measures sphericity. Its interpretation no longer
  implies that Welch methods resolve repeated-measures assumptions.
* `add_proportion()` now preserves an explicitly supplied publication label
  exactly and explains why `add_p()` does not duplicate the full-variable
  p-value on a selected-event row.

* `compare_groups()` now has a public `var_equal` argument. The default remains
  `FALSE`, retaining Welch t-tests and Welch ANOVA for suitable independent
  continuous automatic comparisons. Set `var_equal = TRUE` only for a
  prespecified equal-variance assumption; it selects Student's t-test or
  classical ANOVA and is never inferred using a variance hypothesis test.
* `add_p()` and `plot_compare(show_p = TRUE)` now forward `var_equal` to the
  same comparison engine, so their selected methods remain consistent.
- `summary_table()`, `add_summary()`, `add_proportion()`, and `add_rate()` now
  support `layout = "separate"`, which places estimates and confidence
  intervals in child columns beneath each cohort header. The backward-compatible
  `"compact"` layout remains the default.
* Standardised the public result-output contract. Core analytical functions
  now accept `format = "table"` (the publication-ready default) or
  `format = "tibble"` for plain console output. The earlier `output` argument
  remains a compatibility alias on `describe_data()`,
  `assess_distribution()`, and `assess_variance()`.
  The assumptions, diagnostics, and denominator inspection helpers now follow
  the same publication-table default and `format = "tibble"` console route.
* Corrected the paired manual case study to use `summary_table(by = visit)` and
  added an explicit console example for variance diagnostics.
