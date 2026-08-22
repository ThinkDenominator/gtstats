# Changelog

## gtstats 1.0.0

- Added `show_dichotomous = "single_row"` with optional named `value`
  choices to
  [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md)
  and
  [`add_summary()`](https://gtstats.thinkdenominator.com/reference/add_summary.md).
  This matches gtregression and gives conventional one-event-per-row
  binary summaries without changing full-variable inference.

- Reduced publication footnote type in flextable and gt output, and
  exposed the binary display and advanced styling choices in the gtstats
  app.

- Made publication output Office-first: supported results now print as
  `flextable` objects by default.
  [`to_gt()`](https://gtstats.thinkdenominator.com/reference/to_gt.md)
  provides an explicit HTML-focused route, while
  [`tbl_stats()`](https://gtstats.thinkdenominator.com/reference/tbl_stats.md)
  remains as a compatibility alias.
  [`save_output()`](https://gtstats.thinkdenominator.com/reference/save_output.md)
  now accepts raw gtstats results, flextables and gt tables and supports
  PPTX.

- Extended
  [`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md)
  with spanning headers, additional or suppressed footnotes,
  journal-ready border and density controls, named column widths, and
  configurable p-value styling. Its default engine is now `"flextable"`;
  use `engine = "gt"` when that output is required.

- Continuous summary overrides now support a global fallback plus
  exceptions, for example
  `statistic = c(continuous = "mean_sd", lwt = "median_iqr")`. The
  deliberate variable-selection model is retained: an empty builder now
  directs beginners to `include = c(age, sex, bmi)` or
  `include = everything()`.

- Redesigned the Summary table workflow as a progressive, layer-by-layer
  API.
  [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md)
  builds the descriptive foundation; the new
  [`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md)
  layer adds confidence intervals globally or to selected variables;
  [`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
  adds comparisons; and specialist rows remain explicit optional
  ingredients. The Shiny app now mirrors the same sequence and generates
  the corresponding reproducible pipeline.

- Simplified
  [`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md)
  defaults so its display, layout, confidence settings and precision
  inherit from the parent table. It is now documented as a
  selected-event highlight rather than the route for adding CIs to
  ordinary categorical summaries.

- Tightened summary-table presentation: missing-value rows now remain
  inside the correct variable block and are emitted once per variable. A
  requested `layout = "separate"` no longer creates empty CI columns
  before a CI layer is added. Compact cells and separate-column headers
  avoid repeating the confidence level; the level and interval method
  are stated once in the publication footnote.

- Separate CI layouts now use context-aware estimate headers (`n (%)`,
  `Mean (SD)`, `Median (IQR)`, or `Summary`) and an explicit
  confidence-level header such as `95% CI`. Categorical-only tables
  without intervals can use `categorical_layout = "separate"` to display
  n and % in distinct columns.

- Redesigned the GUI Summary workspace as a recipe. Users can now build
  an ordinary summary or rate table and add total, selected-proportion,
  rate, custom-row and p-value ingredients with their relevant options.
  Compact and separate-column layouts are available at table creation,
  and generated code reproduces the complete builder pipeline.

- Simplified
  [`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md)
  footnotes in summary tables. Publication output no longer repeats the
  selected event or explains internal
  [`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
  behavior; when confidence intervals are shown, only their level and
  method are noted.

- Completed the GUI plotting workflow. Distribution assessments now
  expose histogram, density, Q-Q and boxplot diagnostics; group
  comparisons expose
  [`plot_compare()`](https://gtstats.thinkdenominator.com/reference/plot_compare.md)
  controls; and correlation plots expose labels, confidence level,
  typography and colour controls. Every plot is downloadable as PNG or
  PDF and represented in the generated reproducible R code.

- Added a dedicated **Customise table** workspace immediately after
  Summary table in
  [`gtstats_app()`](https://gtstats.thinkdenominator.com/reference/gtstats_app.md),
  matching the post-processing workflow in the gtregression app. The
  latest Summary table is carried forward and displayed automatically.
  Users can relabel columns, rows and levels, change titles, notes and
  styling, hide columns, download the result, and copy reproducible
  [`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md)
  code without altering the underlying statistics.

- `crosstabs(format = "tibble")` now returns plain console-friendly
  cells such as `86 (66.15%)` instead of HTML line-break markup. The
  default publication table retains its stacked cell layout.

- [`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
  now accepts tidy-select `include`, allowing variables to remain in a
  descriptive table without receiving an inappropriate p-value. The GUI
  exposes the same control as **Do not test** and reproduces it in
  generated R code. Birth-weight examples now avoid testing `bwt`
  against the category derived from `bwt`.

- Finalised the pre-CRAN comparison API:
  [`effect_size()`](https://gtstats.thinkdenominator.com/reference/effect_size.md)
  and
  [`plot_compare()`](https://gtstats.thinkdenominator.com/reference/plot_compare.md)
  now use `variable` and `group`, matching
  [`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md).
  [`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
  now calls its marked-skewness option `distribution_check`, replacing
  the misleading `normality_check` name.

- Automatic `"recommended"` continuous summaries are now resolved once
  per variable across all displayed groups, preventing a Table 1 from
  mixing mean (SD) and median (IQR) for the same variable. Categorical
  confidence intervals now use Wilson intervals by default, with
  `ci_method = "exact"` available.

- Simulated Fisher exact tests for larger contingency tables are
  reproducible by default via `fisher_seed = 1049` and preserve the
  caller’s RNG state.

- Repeated-measures ANOVA now reports a Greenhouse-Geisser-corrected
  p-value and diagnostics.
  [`plot_compare()`](https://gtstats.thinkdenominator.com/reference/plot_compare.md)
  now supports repeated continuous and paired categorical displays and
  exposes the same repeated-test choices as
  [`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md).

- Redesigned
  [`gtstats_app()`](https://gtstats.thinkdenominator.com/reference/gtstats_app.md)
  around a safer end-to-end workflow. Original data now remain the
  active analysis dataset until prepared data are explicitly chosen;
  Data Prep can set publication display labels; and Table 1 is now named
  Summary table. The summary builder provides per-variable descriptive
  and inferential choices, live table styling, matching export output,
  and copy/download access to both analysis code and the complete
  session script.

- Replaced the Summary table’s expanding per-variable dropdown grid with
  two validated override editors. Unlisted continuous variables use
  Recommended; unlisted tests use Auto. Users enter only exceptions as
  `variable = option`, can use `none` to suppress a test, receive live
  validation and examples, and obtain matching named-vector R code.

- Organised the app’s Summary table controls into four numbered
  sections: contents, summaries, statistical comparisons, and
  appearance. Advanced Auto settings and cosmetic options are collapsed
  until needed. `mean_ci` cells now show the estimate and interval
  without repeating “95% CI” in every cell; the confidence level remains
  clearly defined in the relevant footnote.

- Extended
  [`correlation()`](https://gtstats.thinkdenominator.com/reference/correlation.md)
  with a multi-variable matrix route via `vars`. Matrix output uses one
  transparent Pearson or Spearman method throughout, retains pairwise
  denominators and adjusted p-values in tidy `$summary`, and supports
  lower, upper or full publication layouts.
  [`plot_correlation()`](https://gtstats.thinkdenominator.com/reference/plot_correlation.md)
  now visualises these results as a labelled coefficient heatmap.

- Correlation matrices can now preserve input order, sort labels
  alphabetically, or use correlation-based clustering; users can hide
  the diagonal and include pairwise n alone or alongside adjusted
  p-values in each cell. Matrix heatmaps inherit the selected triangle
  and diagonal settings.

- The app now includes a complete Correlation workspace for pair and
  matrix analyses, with checkbox variable selection, matrix layout and
  ordering, cell-content and multiplicity controls, table/heatmap
  previews, Audit tabs, downloadable tables and plots, and reproducible
  analysis/plot code. It also provides tidy CSV export, a
  selected-variable counter, large-matrix guidance, a visible warning
  when pairwise denominators differ, collapsible advanced controls, and
  a reset-to-defaults action.

- Redesigned standalone
  [`proportion_stats()`](https://gtstats.thinkdenominator.com/reference/proportion_stats.md)
  publication tables. Group values are now spanning headers with
  separate estimate and confidence-interval columns, while `$summary`
  remains a tidy long-form result. The compact row added by
  [`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md)
  is unchanged.

- Redesigned standalone
  [`rate_stats()`](https://gtstats.thinkdenominator.com/reference/rate_stats.md)
  publication tables to use group spanners with separate Events,
  accumulated time, Rate and confidence-interval columns. `$summary`
  remains tidy and
  [`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md)
  remains unchanged.

- Corrected independent 2 x 2 audit wording from “complete pairs” to
  “complete observations”, and ensured
  [`diagnostics_stats()`](https://gtstats.thinkdenominator.com/reference/diagnostics_stats.md)
  identifies the crosstab outcome instead of displaying a missing
  variable name.

- Automatic continuous comparisons now reserve rank-based methods for
  marked skewness. Shapiro-Wilk and mild asymmetry remain supporting
  information, so
  [`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md)
  and
  [`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
  consistently use Welch methods for the birth-weight example’s maternal
  age.

- [`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md)
  now displays `test = "levene"` by default, implemented as the
  median-centred Brown-Forsythe modification. It is supporting
  information and never changes automatic test selection.

- Restored variance to the visible
  [`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md)
  output: every group cell now shows n, SD, and variance, with both
  observed SD and variance ratios shown in the publication table. No
  additional argument is required.

- Paired comparison output now labels the estimate as a mean within-pair
  difference and reports exclusions caused by incomplete or non-unique
  pairs. Paired publication tables now identify the complete-pair
  denominator; McNemar/Cochran’s Q notes are binary-specific; and
  Friedman fails clearly when there is no within-participant variation
  instead of printing `NA`.

- [`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md)
  now explicitly states that its spread diagnostics do not assess
  pairing or repeated-measures sphericity. Its interpretation no longer
  implies that Welch methods resolve repeated-measures assumptions.

- [`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md)
  now preserves an explicitly supplied publication label exactly and
  explains why
  [`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
  does not duplicate the full-variable p-value on a selected-event row.

- [`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md)
  now has a public `var_equal` argument. The default remains `FALSE`,
  retaining Welch t-tests and Welch ANOVA for suitable independent
  continuous automatic comparisons. Set `var_equal = TRUE` only for a
  prespecified equal-variance assumption; it selects Student’s t-test or
  classical ANOVA and is never inferred using a variance hypothesis
  test.

- [`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
  and `plot_compare(show_p = TRUE)` now forward `var_equal` to the same
  comparison engine, so their selected methods remain consistent.

- [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md),
  [`add_summary()`](https://gtstats.thinkdenominator.com/reference/add_summary.md),
  [`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md),
  and
  [`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md)
  now support `layout = "separate"`, which places estimates and
  confidence intervals in child columns beneath each cohort header. The
  backward-compatible `"compact"` layout remains the default.

- Standardised the public result-output contract. Core analytical
  functions now accept `format = "table"` (the publication-ready
  default) or `format = "tibble"` for plain console output. The earlier
  `output` argument remains a compatibility alias on
  [`describe_data()`](https://gtstats.thinkdenominator.com/reference/describe_data.md),
  [`assess_distribution()`](https://gtstats.thinkdenominator.com/reference/assess_distribution.md),
  and
  [`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md).
  The assumptions, diagnostics, and denominator inspection helpers now
  follow the same publication-table default and `format = "tibble"`
  console route.

- Corrected the paired manual case study to use
  `summary_table(by = visit)` and added an explicit console example for
  variance diagnostics.
