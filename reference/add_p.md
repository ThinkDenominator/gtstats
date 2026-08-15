# Add p-values to a descriptive table

Add a p-value column to a descriptive table by comparing each displayed
variable across the grouping variable. P-values are calculated using
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md)
and inserted once per variable, with optional superscript markers
indicating which statistical test was used.

## Usage

``` r
add_p(
  x,
  method = "auto",
  paired = FALSE,
  id = NULL,
  normality_check = TRUE,
  var_equal = FALSE,
  correction = TRUE,
  p_adjust = c("none", setdiff(stats::p.adjust.methods, "none")),
  digits = 3
)
```

## Arguments

- x:

  A `gt_desc_table` object created with
  [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md).

- method:

  Statistical test to use. Either a single method string, or a named
  character vector/list specifying methods for individual variables.
  Names may match either displayed variable labels or underlying
  variable names.

- paired:

  Logical; whether comparisons should be treated as paired.

- id:

  Pair or participant identifier required when `paired = TRUE`.

- normality_check:

  Logical; when `method = "auto"`, use distribution guidance to choose
  parametric or rank-based tests. This guidance is based on skewness;
  Shapiro-Wilk is supporting information only. For paired analyses the
  check is applied to within-pair differences.

- var_equal:

  Logical; for independent, non-skewed continuous comparisons in
  `method = "auto"`, use Student's t-test or classical ANOVA. The
  default `FALSE` uses Welch methods. This is a user-specified
  assumption, not a variance test, and does not affect paired,
  categorical, ordinal, or rank-based comparisons.

- correction:

  Logical; apply continuity correction to chi-square and McNemar tests
  where applicable.

- p_adjust:

  Multiplicity adjustment applied across displayed variable tests. One
  of [stats::p.adjust.methods](https://rdrr.io/r/stats/p.adjust.html);
  default `"none"`.

- digits:

  Number of decimal places used when formatting p-values.

## Value

An updated `gt_desc_table` object with a `p-value` column added.

## Details

This function works only for descriptive tables created in
`mode = "summary"` and requires a grouping variable supplied via
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md).

Supported methods include:

- `"auto"`

- `"welch_t"`

- `"t_test"`

- `"wilcox"`

- `"anova"`

- `"welch_anova"`

- `"kruskal"`

- `"chisq"`

- `"fisher"`

- `"mcnemar"`

You may also provide a named character vector or named list to specify
different methods for individual variables.

### Automatic selection and audit trail

With `method = "auto"`, `add_p()` delegates each comparison to
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md)
using the same fixed selection policy: Welch t-test or Welch ANOVA by
default when distribution guidance does not flag skewness; Student's
t-test or classical ANOVA when `var_equal = TRUE`; rank-based tests when
skewness is flagged; and chi-square or Fisher's exact test according to
expected cell counts. Shapiro-Wilk is supporting information only and
does not itself select a test.

The publication table contains only the p-value and compact test
markers. The full per-variable audit trail is retained in
`$assumptions`, `$diagnostics`, `$p_values`, and `$denominators`. In
particular, `diagnostics_stats(x)` records automatic selection,
distribution guidance, expected cell counts where relevant, and observed
group spread for independent continuous comparisons. Observed spread is
descriptive context, not a variance-test gatekeeper; Welch methods do
not require equal variances.

## Examples

``` r
summary_table(mtcars, by = am) |>
  add_summary(vars = c(mpg, wt, cyl)) |>
  add_p()
#> <div id="vuroqfkvru" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#vuroqfkvru table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #vuroqfkvru thead, #vuroqfkvru tbody, #vuroqfkvru tfoot, #vuroqfkvru tr, #vuroqfkvru td, #vuroqfkvru th {
#>   border-style: none;
#> }
#> 
#> #vuroqfkvru p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #vuroqfkvru .gt_table {
#>   display: table;
#>   border-collapse: collapse;
#>   line-height: normal;
#>   margin-left: auto;
#>   margin-right: auto;
#>   color: #333333;
#>   font-size: 13px;
#>   font-weight: normal;
#>   font-style: normal;
#>   background-color: #FFFFFF;
#>   width: auto;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #A8A8A8;
#>   border-right-style: none;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #A8A8A8;
#>   border-left-style: none;
#>   border-left-width: 2px;
#>   border-left-color: #D3D3D3;
#> }
#> 
#> #vuroqfkvru .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #vuroqfkvru .gt_title {
#>   color: #333333;
#>   font-size: 125%;
#>   font-weight: initial;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-color: #FFFFFF;
#>   border-bottom-width: 0;
#> }
#> 
#> #vuroqfkvru .gt_subtitle {
#>   color: #333333;
#>   font-size: 85%;
#>   font-weight: initial;
#>   padding-top: 3px;
#>   padding-bottom: 5px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-color: #FFFFFF;
#>   border-top-width: 0;
#> }
#> 
#> #vuroqfkvru .gt_heading {
#>   background-color: #FFFFFF;
#>   text-align: left;
#>   border-bottom-color: #FFFFFF;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #vuroqfkvru .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #vuroqfkvru .gt_col_headings {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #vuroqfkvru .gt_col_heading {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: normal;
#>   text-transform: inherit;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 5px;
#>   padding-bottom: 6px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #vuroqfkvru .gt_column_spanner_outer {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: normal;
#>   text-transform: inherit;
#>   padding-top: 0;
#>   padding-bottom: 0;
#>   padding-left: 4px;
#>   padding-right: 4px;
#> }
#> 
#> #vuroqfkvru .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #vuroqfkvru .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #vuroqfkvru .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 5px;
#>   padding-bottom: 5px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #vuroqfkvru .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #vuroqfkvru .gt_group_heading {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#>   vertical-align: middle;
#>   text-align: left;
#> }
#> 
#> #vuroqfkvru .gt_empty_group_heading {
#>   padding: 0.5px;
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: middle;
#> }
#> 
#> #vuroqfkvru .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #vuroqfkvru .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #vuroqfkvru .gt_row {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   margin: 10px;
#>   border-top-style: solid;
#>   border-top-width: 1px;
#>   border-top-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#>   vertical-align: middle;
#>   overflow-x: hidden;
#> }
#> 
#> #vuroqfkvru .gt_stub {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #vuroqfkvru .gt_stub_row_group {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   vertical-align: top;
#> }
#> 
#> #vuroqfkvru .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #vuroqfkvru .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #vuroqfkvru .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #vuroqfkvru .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #vuroqfkvru .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #vuroqfkvru .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #vuroqfkvru .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #vuroqfkvru .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #vuroqfkvru .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #vuroqfkvru .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #vuroqfkvru .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #vuroqfkvru .gt_footnotes {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   border-bottom-style: none;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 2px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #vuroqfkvru .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #vuroqfkvru .gt_sourcenotes {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   border-bottom-style: none;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 2px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #vuroqfkvru .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #vuroqfkvru .gt_left {
#>   text-align: left;
#> }
#> 
#> #vuroqfkvru .gt_center {
#>   text-align: center;
#> }
#> 
#> #vuroqfkvru .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #vuroqfkvru .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #vuroqfkvru .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #vuroqfkvru .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #vuroqfkvru .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #vuroqfkvru .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #vuroqfkvru .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #vuroqfkvru .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #vuroqfkvru .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #vuroqfkvru .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #vuroqfkvru .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #vuroqfkvru .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #vuroqfkvru .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #vuroqfkvru div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variable">Variable</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Level"></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="am-=-1"><span class='gt_from_md'>1<br />
#> N = 13</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="am-=-0"><span class='gt_from_md'>0<br />
#> N = 19</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="p-value">p-value<span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">mpg</td>
#> <td headers="Level" class="gt_row gt_left"></td>
#> <td headers="am = 1" class="gt_row gt_right">24.4 (6.2)</td>
#> <td headers="am = 0" class="gt_row gt_right">17.1 (3.8)</td>
#> <td headers="p-value" class="gt_row gt_right">0.001ᵃ</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">wt</td>
#> <td headers="Level" class="gt_row gt_left"></td>
#> <td headers="am = 1" class="gt_row gt_right">2.4 (0.6)</td>
#> <td headers="am = 0" class="gt_row gt_right">3.8 (0.8)</td>
#> <td headers="p-value" class="gt_row gt_right">&lt;0.001ᵇ</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">cyl</td>
#> <td headers="Level" class="gt_row gt_left">  4</td>
#> <td headers="am = 1" class="gt_row gt_right">8 (61.5%)</td>
#> <td headers="am = 0" class="gt_row gt_right">3 (15.8%)</td>
#> <td headers="p-value" class="gt_row gt_right">0.009ᶜ</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  6</td>
#> <td headers="am = 1" class="gt_row gt_right">3 (23.1%)</td>
#> <td headers="am = 0" class="gt_row gt_right">4 (21.1%)</td>
#> <td headers="p-value" class="gt_row gt_right"></td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  8</td>
#> <td headers="am = 1" class="gt_row gt_right">2 (15.4%)</td>
#> <td headers="am = 0" class="gt_row gt_right">12 (63.2%)</td>
#> <td headers="p-value" class="gt_row gt_right"></td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="5"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> Continuous data are mean (SD) or median (IQR). Categorical data are n (%).</td>
#>     </tr>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="5"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span> ᵃ Welch t-test; ᵇ Wilcoxon rank-sum test; ᶜ Fisher's exact test (Monte Carlo p-value)</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>

summary_table(mtcars, by = am) |>
  add_summary(vars = c(mpg, wt, cyl)) |>
  add_p(method = c(mpg = "welch_t", wt = "wilcox", cyl = "chisq"))
#> <div id="kcpwlwfjxj" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#kcpwlwfjxj table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #kcpwlwfjxj thead, #kcpwlwfjxj tbody, #kcpwlwfjxj tfoot, #kcpwlwfjxj tr, #kcpwlwfjxj td, #kcpwlwfjxj th {
#>   border-style: none;
#> }
#> 
#> #kcpwlwfjxj p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #kcpwlwfjxj .gt_table {
#>   display: table;
#>   border-collapse: collapse;
#>   line-height: normal;
#>   margin-left: auto;
#>   margin-right: auto;
#>   color: #333333;
#>   font-size: 13px;
#>   font-weight: normal;
#>   font-style: normal;
#>   background-color: #FFFFFF;
#>   width: auto;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #A8A8A8;
#>   border-right-style: none;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #A8A8A8;
#>   border-left-style: none;
#>   border-left-width: 2px;
#>   border-left-color: #D3D3D3;
#> }
#> 
#> #kcpwlwfjxj .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #kcpwlwfjxj .gt_title {
#>   color: #333333;
#>   font-size: 125%;
#>   font-weight: initial;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-color: #FFFFFF;
#>   border-bottom-width: 0;
#> }
#> 
#> #kcpwlwfjxj .gt_subtitle {
#>   color: #333333;
#>   font-size: 85%;
#>   font-weight: initial;
#>   padding-top: 3px;
#>   padding-bottom: 5px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-color: #FFFFFF;
#>   border-top-width: 0;
#> }
#> 
#> #kcpwlwfjxj .gt_heading {
#>   background-color: #FFFFFF;
#>   text-align: left;
#>   border-bottom-color: #FFFFFF;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #kcpwlwfjxj .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #kcpwlwfjxj .gt_col_headings {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #kcpwlwfjxj .gt_col_heading {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: normal;
#>   text-transform: inherit;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 5px;
#>   padding-bottom: 6px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   overflow-x: hidden;
#> }
#> 
#> #kcpwlwfjxj .gt_column_spanner_outer {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: normal;
#>   text-transform: inherit;
#>   padding-top: 0;
#>   padding-bottom: 0;
#>   padding-left: 4px;
#>   padding-right: 4px;
#> }
#> 
#> #kcpwlwfjxj .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #kcpwlwfjxj .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #kcpwlwfjxj .gt_column_spanner {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: bottom;
#>   padding-top: 5px;
#>   padding-bottom: 5px;
#>   overflow-x: hidden;
#>   display: inline-block;
#>   width: 100%;
#> }
#> 
#> #kcpwlwfjxj .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #kcpwlwfjxj .gt_group_heading {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#>   vertical-align: middle;
#>   text-align: left;
#> }
#> 
#> #kcpwlwfjxj .gt_empty_group_heading {
#>   padding: 0.5px;
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   vertical-align: middle;
#> }
#> 
#> #kcpwlwfjxj .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #kcpwlwfjxj .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #kcpwlwfjxj .gt_row {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   margin: 10px;
#>   border-top-style: solid;
#>   border-top-width: 1px;
#>   border-top-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 1px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 1px;
#>   border-right-color: #D3D3D3;
#>   vertical-align: middle;
#>   overflow-x: hidden;
#> }
#> 
#> #kcpwlwfjxj .gt_stub {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #kcpwlwfjxj .gt_stub_row_group {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   font-size: 100%;
#>   font-weight: initial;
#>   text-transform: inherit;
#>   border-right-style: solid;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   vertical-align: top;
#> }
#> 
#> #kcpwlwfjxj .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #kcpwlwfjxj .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #kcpwlwfjxj .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #kcpwlwfjxj .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #kcpwlwfjxj .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #kcpwlwfjxj .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #kcpwlwfjxj .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #kcpwlwfjxj .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #kcpwlwfjxj .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #kcpwlwfjxj .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #kcpwlwfjxj .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #kcpwlwfjxj .gt_footnotes {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   border-bottom-style: none;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 2px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #kcpwlwfjxj .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #kcpwlwfjxj .gt_sourcenotes {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   border-bottom-style: none;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#>   border-left-style: none;
#>   border-left-width: 2px;
#>   border-left-color: #D3D3D3;
#>   border-right-style: none;
#>   border-right-width: 2px;
#>   border-right-color: #D3D3D3;
#> }
#> 
#> #kcpwlwfjxj .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #kcpwlwfjxj .gt_left {
#>   text-align: left;
#> }
#> 
#> #kcpwlwfjxj .gt_center {
#>   text-align: center;
#> }
#> 
#> #kcpwlwfjxj .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #kcpwlwfjxj .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #kcpwlwfjxj .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #kcpwlwfjxj .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #kcpwlwfjxj .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #kcpwlwfjxj .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #kcpwlwfjxj .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #kcpwlwfjxj .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #kcpwlwfjxj .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #kcpwlwfjxj .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #kcpwlwfjxj .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #kcpwlwfjxj .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #kcpwlwfjxj .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #kcpwlwfjxj div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variable">Variable</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Level"></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="am-=-1"><span class='gt_from_md'>1<br />
#> N = 13</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="am-=-0"><span class='gt_from_md'>0<br />
#> N = 19</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="p-value">p-value<span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">mpg</td>
#> <td headers="Level" class="gt_row gt_left"></td>
#> <td headers="am = 1" class="gt_row gt_right">24.4 (6.2)</td>
#> <td headers="am = 0" class="gt_row gt_right">17.1 (3.8)</td>
#> <td headers="p-value" class="gt_row gt_right">0.001ᵃ</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">wt</td>
#> <td headers="Level" class="gt_row gt_left"></td>
#> <td headers="am = 1" class="gt_row gt_right">2.4 (0.6)</td>
#> <td headers="am = 0" class="gt_row gt_right">3.8 (0.8)</td>
#> <td headers="p-value" class="gt_row gt_right">&lt;0.001ᵇ</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">cyl</td>
#> <td headers="Level" class="gt_row gt_left">  4</td>
#> <td headers="am = 1" class="gt_row gt_right">8 (61.5%)</td>
#> <td headers="am = 0" class="gt_row gt_right">3 (15.8%)</td>
#> <td headers="p-value" class="gt_row gt_right">0.013ᶜ</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  6</td>
#> <td headers="am = 1" class="gt_row gt_right">3 (23.1%)</td>
#> <td headers="am = 0" class="gt_row gt_right">4 (21.1%)</td>
#> <td headers="p-value" class="gt_row gt_right"></td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  8</td>
#> <td headers="am = 1" class="gt_row gt_right">2 (15.4%)</td>
#> <td headers="am = 0" class="gt_row gt_right">12 (63.2%)</td>
#> <td headers="p-value" class="gt_row gt_right"></td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="5"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> Continuous data are mean (SD) or median (IQR). Categorical data are n (%).</td>
#>     </tr>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="5"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span> ᵃ Welch t-test; ᵇ Wilcoxon rank-sum test; ᶜ Chi-square test</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
```
