# Estimate an effect size

Quantify the magnitude of a group difference or association without
adding the full hypothesis-test output produced by
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md).
For directional two-group measures, the Contrast column names the
grouping variable and reports first group minus second group. Factor
order is therefore meaningful. Cramer's V and omnibus measures have no
direction.

## Usage

``` r
effect_size(
  data,
  outcome,
  by,
  method = c("auto", "hedges_g", "rank_biserial", "omega_squared", "epsilon_squared",
    "cramers_v"),
  paired = FALSE,
  id = NULL,
  conf.level = 0.95,
  interpretation = FALSE,
  digits = 2
)
```

## Arguments

- data:

  A data frame.

- outcome:

  Outcome variable.

- by:

  Grouping variable.

- method:

  Effect-size method: `"auto"`, `"hedges_g"`, `"rank_biserial"`,
  `"omega_squared"`, `"epsilon_squared"`, or `"cramers_v"`.

- paired:

  Logical; whether the two-group comparison is paired.

- id:

  Pair or participant identifier required when `paired = TRUE`.

- conf.level:

  Confidence level for supported intervals.

- interpretation:

  Logical; display a conventional magnitude label. These labels are
  generic teaching aids and are not clinical importance thresholds.

- digits:

  Number of decimal places.

## Value

A publication-ready `gt_effect` object containing `summary`, `table`,
`inputs`, `method`, `assumptions`, `diagnostics`, `denominators`, and
`notes`.

## Details

The default `method = "auto"` selects one measure from the outcome and
comparison structure:

- Hedges' g for two-group parametric comparisons

- rank-biserial correlation for two-group rank comparisons

- omega-squared for comparisons involving more than two continuous
  groups

- epsilon-squared when a multi-group rank method is requested

- Cramer's V for categorical associations

Risk ratios, odds ratios, and risk differences are intentionally not
duplicated here; use
[`crosstabs()`](https://gtstats.thinkdenominator.com/reference/crosstabs.md)
for those epidemiological measures.

## Examples

``` r
effect_size(mtcars, outcome = mpg, by = am)
#> <div id="mzeoiosmpv" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#mzeoiosmpv table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #mzeoiosmpv thead, #mzeoiosmpv tbody, #mzeoiosmpv tfoot, #mzeoiosmpv tr, #mzeoiosmpv td, #mzeoiosmpv th {
#>   border-style: none;
#> }
#> 
#> #mzeoiosmpv p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #mzeoiosmpv .gt_table {
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
#> #mzeoiosmpv .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #mzeoiosmpv .gt_title {
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
#> #mzeoiosmpv .gt_subtitle {
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
#> #mzeoiosmpv .gt_heading {
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
#> #mzeoiosmpv .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #mzeoiosmpv .gt_col_headings {
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
#> #mzeoiosmpv .gt_col_heading {
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
#> #mzeoiosmpv .gt_column_spanner_outer {
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
#> #mzeoiosmpv .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #mzeoiosmpv .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #mzeoiosmpv .gt_column_spanner {
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
#> #mzeoiosmpv .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #mzeoiosmpv .gt_group_heading {
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
#> #mzeoiosmpv .gt_empty_group_heading {
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
#> #mzeoiosmpv .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #mzeoiosmpv .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #mzeoiosmpv .gt_row {
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
#> #mzeoiosmpv .gt_stub {
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
#> #mzeoiosmpv .gt_stub_row_group {
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
#> #mzeoiosmpv .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #mzeoiosmpv .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #mzeoiosmpv .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #mzeoiosmpv .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #mzeoiosmpv .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #mzeoiosmpv .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #mzeoiosmpv .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #mzeoiosmpv .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #mzeoiosmpv .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #mzeoiosmpv .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #mzeoiosmpv .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #mzeoiosmpv .gt_footnotes {
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
#> #mzeoiosmpv .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #mzeoiosmpv .gt_sourcenotes {
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
#> #mzeoiosmpv .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #mzeoiosmpv .gt_left {
#>   text-align: left;
#> }
#> 
#> #mzeoiosmpv .gt_center {
#>   text-align: center;
#> }
#> 
#> #mzeoiosmpv .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #mzeoiosmpv .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #mzeoiosmpv .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #mzeoiosmpv .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #mzeoiosmpv .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #mzeoiosmpv .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #mzeoiosmpv .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #mzeoiosmpv .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #mzeoiosmpv .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #mzeoiosmpv .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #mzeoiosmpv .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #mzeoiosmpv .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #mzeoiosmpv .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #mzeoiosmpv div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Measure">Measure</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Contrast">Contrast</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Estimate">Estimate</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="a95%-CI">95% CI</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Measure" class="gt_row gt_left">Hedges' g</td>
#> <td headers="Contrast" class="gt_row gt_left">am: 0 − 1</td>
#> <td headers="Estimate" class="gt_row gt_right">-1.35</td>
#> <td headers="95% CI" class="gt_row gt_right">-2.18–-0.52</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="4">Direction: positive values indicate higher values or greater rank in 0; negative values indicate higher values or greater rank in 1.</td>
#>     </tr>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="4">95% CI: Approximate large-sample normal interval.</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>

effect_size(
  mtcars,
  outcome = mpg,
  by = am,
  method = "hedges_g",
  interpretation = TRUE
)
#> <div id="mnkoymwvmz" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#mnkoymwvmz table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #mnkoymwvmz thead, #mnkoymwvmz tbody, #mnkoymwvmz tfoot, #mnkoymwvmz tr, #mnkoymwvmz td, #mnkoymwvmz th {
#>   border-style: none;
#> }
#> 
#> #mnkoymwvmz p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #mnkoymwvmz .gt_table {
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
#> #mnkoymwvmz .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #mnkoymwvmz .gt_title {
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
#> #mnkoymwvmz .gt_subtitle {
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
#> #mnkoymwvmz .gt_heading {
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
#> #mnkoymwvmz .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #mnkoymwvmz .gt_col_headings {
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
#> #mnkoymwvmz .gt_col_heading {
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
#> #mnkoymwvmz .gt_column_spanner_outer {
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
#> #mnkoymwvmz .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #mnkoymwvmz .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #mnkoymwvmz .gt_column_spanner {
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
#> #mnkoymwvmz .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #mnkoymwvmz .gt_group_heading {
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
#> #mnkoymwvmz .gt_empty_group_heading {
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
#> #mnkoymwvmz .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #mnkoymwvmz .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #mnkoymwvmz .gt_row {
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
#> #mnkoymwvmz .gt_stub {
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
#> #mnkoymwvmz .gt_stub_row_group {
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
#> #mnkoymwvmz .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #mnkoymwvmz .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #mnkoymwvmz .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #mnkoymwvmz .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #mnkoymwvmz .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #mnkoymwvmz .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #mnkoymwvmz .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #mnkoymwvmz .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #mnkoymwvmz .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #mnkoymwvmz .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #mnkoymwvmz .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #mnkoymwvmz .gt_footnotes {
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
#> #mnkoymwvmz .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #mnkoymwvmz .gt_sourcenotes {
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
#> #mnkoymwvmz .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #mnkoymwvmz .gt_left {
#>   text-align: left;
#> }
#> 
#> #mnkoymwvmz .gt_center {
#>   text-align: center;
#> }
#> 
#> #mnkoymwvmz .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #mnkoymwvmz .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #mnkoymwvmz .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #mnkoymwvmz .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #mnkoymwvmz .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #mnkoymwvmz .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #mnkoymwvmz .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #mnkoymwvmz .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #mnkoymwvmz .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #mnkoymwvmz .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #mnkoymwvmz .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #mnkoymwvmz .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #mnkoymwvmz .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #mnkoymwvmz div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Measure">Measure</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Contrast">Contrast</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Estimate">Estimate</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="a95%-CI">95% CI</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Conventional-magnitude">Conventional magnitude</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Measure" class="gt_row gt_left">Hedges' g</td>
#> <td headers="Contrast" class="gt_row gt_left">am: 0 − 1</td>
#> <td headers="Estimate" class="gt_row gt_right">-1.35</td>
#> <td headers="95% CI" class="gt_row gt_right">-2.18–-0.52</td>
#> <td headers="Conventional magnitude" class="gt_row gt_left">Very large</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="5">Direction: positive values indicate higher values or greater rank in 0; negative values indicate higher values or greater rank in 1.</td>
#>     </tr>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="5">95% CI: Approximate large-sample normal interval.</td>
#>     </tr>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="5">Conventional magnitude labels are generic teaching guides; they are not thresholds for clinical importance.</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
```
