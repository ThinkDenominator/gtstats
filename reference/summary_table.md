# Create a summary table builder

Create a publication-ready summary table, or initialise one that can be
built step by step using helper functions such as
[`add_summary()`](https://gtstats.thinkdenominator.com/reference/add_summary.md),
[`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md),
[`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md),
[`add_total()`](https://gtstats.thinkdenominator.com/reference/add_total.md),
and
[`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md).

## Usage

``` r
summary_table(
  data,
  by = NULL,
  include = NULL,
  mode = c("summary", "rate"),
  overall = FALSE,
  statistic = "recommended",
  categorical = c("n_percent", "n_over_N_percent", "n", "percent"),
  percent = c("column", "row", "overall"),
  digits = 1,
  missing = c("ifany", "always", "no"),
  ci = FALSE,
  conf.level = 0.95,
  label = NULL
)
```

## Arguments

- data:

  A data.frame.

- by:

  Optional grouping variable. Can be supplied as a bare name or as a
  character string. The grouping variable must be categorical, binary,
  or ordinal.

- include:

  Optional variables to summarise immediately. Supply bare names, such
  as `c(age, sex, bmi)`, or a character vector. Mixed variable types can
  be selected together. When omitted, an empty advanced builder is
  returned.

- mode:

  Table mode. One of `"summary"` or `"rate"`.

- overall:

  Overall-column setting. Use `FALSE` to omit it, `"first"` to place it
  before the grouped columns, or `"last"` to place it after them. `TRUE`
  is accepted as a shorthand for `"first"`.

- statistic:

  Continuous summary format: `"recommended"`, `"mean_sd"`, `"mean_ci"`,
  `"median_iqr"`, or `"both"`. A single value applies to all continuous
  variables; a named vector can override individual variables.

- categorical:

  Categorical display: `"n_percent"`, `"n_over_N_percent"`, `"n"`, or
  `"percent"`.

- percent:

  Percentage denominator: `"column"`, `"row"`, or `"overall"`.

- digits:

  One number applied throughout, or a named numeric vector using
  `continuous`, `percent`, and `ci`.

- missing:

  Missing-row display: `"ifany"`, `"always"`, or `"no"`.

- ci:

  Logical; include confidence intervals for categorical proportions.

- conf.level:

  Confidence level for categorical proportion intervals.

- label:

  Optional named character vector overriding variable labels.

## Value

A `gt_desc_table` object containing the source data, structural
settings, and placeholders for table components.

## Details

For the usual Table 1 workflow, select all variables together with
`include`. Continuous, binary, categorical, and ordinal variables are
detected automatically and added using beginner-friendly defaults. There
is no need to add continuous and categorical variables separately.

When `include = NULL`, an empty builder is returned for advanced
incremental workflows using
[`add_summary()`](https://gtstats.thinkdenominator.com/reference/add_summary.md)
and the other `add_*()` helpers. Printing a completed object
automatically displays a publication-ready `gt` table; call
[`tbl_stats()`](https://gtstats.thinkdenominator.com/reference/tbl_stats.md)
only when explicit rendering control is required.

Two modes are supported:

- `"summary"` for baseline tables and descriptive summaries

- `"rate"` for rate-based tables using
  [`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md)

A grouping variable may be supplied to create one column per group. An
optional `overall` column can also be requested for later use.

## Examples

``` r
summary_table(
  mtcars,
  by = am,
  include = c(mpg, wt, cyl, vs),
  overall = TRUE
)
#> <div id="fqwotjpdoz" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#fqwotjpdoz table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #fqwotjpdoz thead, #fqwotjpdoz tbody, #fqwotjpdoz tfoot, #fqwotjpdoz tr, #fqwotjpdoz td, #fqwotjpdoz th {
#>   border-style: none;
#> }
#> 
#> #fqwotjpdoz p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #fqwotjpdoz .gt_table {
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
#> #fqwotjpdoz .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #fqwotjpdoz .gt_title {
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
#> #fqwotjpdoz .gt_subtitle {
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
#> #fqwotjpdoz .gt_heading {
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
#> #fqwotjpdoz .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #fqwotjpdoz .gt_col_headings {
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
#> #fqwotjpdoz .gt_col_heading {
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
#> #fqwotjpdoz .gt_column_spanner_outer {
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
#> #fqwotjpdoz .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #fqwotjpdoz .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #fqwotjpdoz .gt_column_spanner {
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
#> #fqwotjpdoz .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #fqwotjpdoz .gt_group_heading {
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
#> #fqwotjpdoz .gt_empty_group_heading {
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
#> #fqwotjpdoz .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #fqwotjpdoz .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #fqwotjpdoz .gt_row {
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
#> #fqwotjpdoz .gt_stub {
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
#> #fqwotjpdoz .gt_stub_row_group {
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
#> #fqwotjpdoz .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #fqwotjpdoz .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #fqwotjpdoz .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #fqwotjpdoz .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #fqwotjpdoz .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #fqwotjpdoz .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #fqwotjpdoz .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #fqwotjpdoz .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #fqwotjpdoz .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #fqwotjpdoz .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #fqwotjpdoz .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #fqwotjpdoz .gt_footnotes {
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
#> #fqwotjpdoz .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #fqwotjpdoz .gt_sourcenotes {
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
#> #fqwotjpdoz .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #fqwotjpdoz .gt_left {
#>   text-align: left;
#> }
#> 
#> #fqwotjpdoz .gt_center {
#>   text-align: center;
#> }
#> 
#> #fqwotjpdoz .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #fqwotjpdoz .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #fqwotjpdoz .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #fqwotjpdoz .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #fqwotjpdoz .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #fqwotjpdoz .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #fqwotjpdoz .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #fqwotjpdoz .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #fqwotjpdoz .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #fqwotjpdoz .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #fqwotjpdoz .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #fqwotjpdoz .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #fqwotjpdoz .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #fqwotjpdoz div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variable">Variable</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Level"></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Overall"><span class='gt_from_md'>Overall<br />
#> N = 32</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="am-=-1"><span class='gt_from_md'>1<br />
#> N = 13</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="am-=-0"><span class='gt_from_md'>0<br />
#> N = 19</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">mpg</td>
#> <td headers="Level" class="gt_row gt_left"></td>
#> <td headers="Overall" class="gt_row gt_right">20.1 (6.0)</td>
#> <td headers="am = 1" class="gt_row gt_right">24.4 (6.2)</td>
#> <td headers="am = 0" class="gt_row gt_right">17.1 (3.8)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">wt</td>
#> <td headers="Level" class="gt_row gt_left"></td>
#> <td headers="Overall" class="gt_row gt_right">3.2 (1.0)</td>
#> <td headers="am = 1" class="gt_row gt_right">2.4 (0.6)</td>
#> <td headers="am = 0" class="gt_row gt_right">3.8 (0.8)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">cyl</td>
#> <td headers="Level" class="gt_row gt_left">  4</td>
#> <td headers="Overall" class="gt_row gt_right">11 (34.4%)</td>
#> <td headers="am = 1" class="gt_row gt_right">8 (61.5%)</td>
#> <td headers="am = 0" class="gt_row gt_right">3 (15.8%)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  6</td>
#> <td headers="Overall" class="gt_row gt_right">7 (21.9%)</td>
#> <td headers="am = 1" class="gt_row gt_right">3 (23.1%)</td>
#> <td headers="am = 0" class="gt_row gt_right">4 (21.1%)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  8</td>
#> <td headers="Overall" class="gt_row gt_right">14 (43.8%)</td>
#> <td headers="am = 1" class="gt_row gt_right">2 (15.4%)</td>
#> <td headers="am = 0" class="gt_row gt_right">12 (63.2%)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">vs</td>
#> <td headers="Level" class="gt_row gt_left">  0</td>
#> <td headers="Overall" class="gt_row gt_right">18 (56.2%)</td>
#> <td headers="am = 1" class="gt_row gt_right">6 (46.2%)</td>
#> <td headers="am = 0" class="gt_row gt_right">12 (63.2%)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  1</td>
#> <td headers="Overall" class="gt_row gt_right">14 (43.8%)</td>
#> <td headers="am = 1" class="gt_row gt_right">7 (53.8%)</td>
#> <td headers="am = 0" class="gt_row gt_right">7 (36.8%)</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="5"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> Continuous data are mean (SD) or median (IQR). Categorical data are n (%).</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>

summary_table(
  mtcars,
  by = am,
  include = c(mpg, wt, cyl, vs),
  overall = TRUE
) |>
  add_p()
#> <div id="grysckzhrc" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#grysckzhrc table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #grysckzhrc thead, #grysckzhrc tbody, #grysckzhrc tfoot, #grysckzhrc tr, #grysckzhrc td, #grysckzhrc th {
#>   border-style: none;
#> }
#> 
#> #grysckzhrc p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #grysckzhrc .gt_table {
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
#> #grysckzhrc .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #grysckzhrc .gt_title {
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
#> #grysckzhrc .gt_subtitle {
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
#> #grysckzhrc .gt_heading {
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
#> #grysckzhrc .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #grysckzhrc .gt_col_headings {
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
#> #grysckzhrc .gt_col_heading {
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
#> #grysckzhrc .gt_column_spanner_outer {
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
#> #grysckzhrc .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #grysckzhrc .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #grysckzhrc .gt_column_spanner {
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
#> #grysckzhrc .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #grysckzhrc .gt_group_heading {
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
#> #grysckzhrc .gt_empty_group_heading {
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
#> #grysckzhrc .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #grysckzhrc .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #grysckzhrc .gt_row {
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
#> #grysckzhrc .gt_stub {
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
#> #grysckzhrc .gt_stub_row_group {
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
#> #grysckzhrc .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #grysckzhrc .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #grysckzhrc .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #grysckzhrc .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #grysckzhrc .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #grysckzhrc .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #grysckzhrc .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #grysckzhrc .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #grysckzhrc .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #grysckzhrc .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #grysckzhrc .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #grysckzhrc .gt_footnotes {
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
#> #grysckzhrc .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #grysckzhrc .gt_sourcenotes {
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
#> #grysckzhrc .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #grysckzhrc .gt_left {
#>   text-align: left;
#> }
#> 
#> #grysckzhrc .gt_center {
#>   text-align: center;
#> }
#> 
#> #grysckzhrc .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #grysckzhrc .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #grysckzhrc .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #grysckzhrc .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #grysckzhrc .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #grysckzhrc .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #grysckzhrc .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #grysckzhrc .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #grysckzhrc .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #grysckzhrc .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #grysckzhrc .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #grysckzhrc .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #grysckzhrc .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #grysckzhrc div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variable">Variable</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Level"></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Overall"><span class='gt_from_md'>Overall<br />
#> N = 32</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
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
#> <td headers="Overall" class="gt_row gt_right">20.1 (6.0)</td>
#> <td headers="am = 1" class="gt_row gt_right">24.4 (6.2)</td>
#> <td headers="am = 0" class="gt_row gt_right">17.1 (3.8)</td>
#> <td headers="p-value" class="gt_row gt_right">0.001ᵃ</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">wt</td>
#> <td headers="Level" class="gt_row gt_left"></td>
#> <td headers="Overall" class="gt_row gt_right">3.2 (1.0)</td>
#> <td headers="am = 1" class="gt_row gt_right">2.4 (0.6)</td>
#> <td headers="am = 0" class="gt_row gt_right">3.8 (0.8)</td>
#> <td headers="p-value" class="gt_row gt_right">&lt;0.001ᵇ</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">cyl</td>
#> <td headers="Level" class="gt_row gt_left">  4</td>
#> <td headers="Overall" class="gt_row gt_right">11 (34.4%)</td>
#> <td headers="am = 1" class="gt_row gt_right">8 (61.5%)</td>
#> <td headers="am = 0" class="gt_row gt_right">3 (15.8%)</td>
#> <td headers="p-value" class="gt_row gt_right">0.008ᶜ</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  6</td>
#> <td headers="Overall" class="gt_row gt_right">7 (21.9%)</td>
#> <td headers="am = 1" class="gt_row gt_right">3 (23.1%)</td>
#> <td headers="am = 0" class="gt_row gt_right">4 (21.1%)</td>
#> <td headers="p-value" class="gt_row gt_right"></td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  8</td>
#> <td headers="Overall" class="gt_row gt_right">14 (43.8%)</td>
#> <td headers="am = 1" class="gt_row gt_right">2 (15.4%)</td>
#> <td headers="am = 0" class="gt_row gt_right">12 (63.2%)</td>
#> <td headers="p-value" class="gt_row gt_right"></td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">vs</td>
#> <td headers="Level" class="gt_row gt_left">  0</td>
#> <td headers="Overall" class="gt_row gt_right">18 (56.2%)</td>
#> <td headers="am = 1" class="gt_row gt_right">6 (46.2%)</td>
#> <td headers="am = 0" class="gt_row gt_right">12 (63.2%)</td>
#> <td headers="p-value" class="gt_row gt_right">0.556ᵈ</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  1</td>
#> <td headers="Overall" class="gt_row gt_right">14 (43.8%)</td>
#> <td headers="am = 1" class="gt_row gt_right">7 (53.8%)</td>
#> <td headers="am = 0" class="gt_row gt_right">7 (36.8%)</td>
#> <td headers="p-value" class="gt_row gt_right"></td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="6"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> Continuous data are mean (SD) or median (IQR). Categorical data are n (%).</td>
#>     </tr>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="6"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span> ᵃ Welch t-test; ᵇ Wilcoxon rank-sum test; ᶜ Fisher's exact test (Monte Carlo p-value); ᵈ Chi-square test</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>

# Percentages without decimals and Overall displayed last
summary_table(
  mtcars,
  by = am,
  include = c(mpg, wt, cyl, vs),
  overall = "last",
  digits = c(continuous = 1, percent = 0)
)
#> <div id="vkmlhsjbfd" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#vkmlhsjbfd table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #vkmlhsjbfd thead, #vkmlhsjbfd tbody, #vkmlhsjbfd tfoot, #vkmlhsjbfd tr, #vkmlhsjbfd td, #vkmlhsjbfd th {
#>   border-style: none;
#> }
#> 
#> #vkmlhsjbfd p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #vkmlhsjbfd .gt_table {
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
#> #vkmlhsjbfd .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #vkmlhsjbfd .gt_title {
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
#> #vkmlhsjbfd .gt_subtitle {
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
#> #vkmlhsjbfd .gt_heading {
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
#> #vkmlhsjbfd .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #vkmlhsjbfd .gt_col_headings {
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
#> #vkmlhsjbfd .gt_col_heading {
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
#> #vkmlhsjbfd .gt_column_spanner_outer {
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
#> #vkmlhsjbfd .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #vkmlhsjbfd .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #vkmlhsjbfd .gt_column_spanner {
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
#> #vkmlhsjbfd .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #vkmlhsjbfd .gt_group_heading {
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
#> #vkmlhsjbfd .gt_empty_group_heading {
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
#> #vkmlhsjbfd .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #vkmlhsjbfd .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #vkmlhsjbfd .gt_row {
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
#> #vkmlhsjbfd .gt_stub {
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
#> #vkmlhsjbfd .gt_stub_row_group {
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
#> #vkmlhsjbfd .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #vkmlhsjbfd .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #vkmlhsjbfd .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #vkmlhsjbfd .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #vkmlhsjbfd .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #vkmlhsjbfd .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #vkmlhsjbfd .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #vkmlhsjbfd .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #vkmlhsjbfd .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #vkmlhsjbfd .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #vkmlhsjbfd .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #vkmlhsjbfd .gt_footnotes {
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
#> #vkmlhsjbfd .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #vkmlhsjbfd .gt_sourcenotes {
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
#> #vkmlhsjbfd .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #vkmlhsjbfd .gt_left {
#>   text-align: left;
#> }
#> 
#> #vkmlhsjbfd .gt_center {
#>   text-align: center;
#> }
#> 
#> #vkmlhsjbfd .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #vkmlhsjbfd .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #vkmlhsjbfd .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #vkmlhsjbfd .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #vkmlhsjbfd .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #vkmlhsjbfd .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #vkmlhsjbfd .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #vkmlhsjbfd .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #vkmlhsjbfd .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #vkmlhsjbfd .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #vkmlhsjbfd .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #vkmlhsjbfd .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #vkmlhsjbfd .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #vkmlhsjbfd div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
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
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Overall"><span class='gt_from_md'>Overall<br />
#> N = 32</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">mpg</td>
#> <td headers="Level" class="gt_row gt_left"></td>
#> <td headers="am = 1" class="gt_row gt_right">24.4 (6.2)</td>
#> <td headers="am = 0" class="gt_row gt_right">17.1 (3.8)</td>
#> <td headers="Overall" class="gt_row gt_right">20.1 (6.0)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">wt</td>
#> <td headers="Level" class="gt_row gt_left"></td>
#> <td headers="am = 1" class="gt_row gt_right">2.4 (0.6)</td>
#> <td headers="am = 0" class="gt_row gt_right">3.8 (0.8)</td>
#> <td headers="Overall" class="gt_row gt_right">3.2 (1.0)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">cyl</td>
#> <td headers="Level" class="gt_row gt_left">  4</td>
#> <td headers="am = 1" class="gt_row gt_right">8 (62%)</td>
#> <td headers="am = 0" class="gt_row gt_right">3 (16%)</td>
#> <td headers="Overall" class="gt_row gt_right">11 (34%)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  6</td>
#> <td headers="am = 1" class="gt_row gt_right">3 (23%)</td>
#> <td headers="am = 0" class="gt_row gt_right">4 (21%)</td>
#> <td headers="Overall" class="gt_row gt_right">7 (22%)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  8</td>
#> <td headers="am = 1" class="gt_row gt_right">2 (15%)</td>
#> <td headers="am = 0" class="gt_row gt_right">12 (63%)</td>
#> <td headers="Overall" class="gt_row gt_right">14 (44%)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">vs</td>
#> <td headers="Level" class="gt_row gt_left">  0</td>
#> <td headers="am = 1" class="gt_row gt_right">6 (46%)</td>
#> <td headers="am = 0" class="gt_row gt_right">12 (63%)</td>
#> <td headers="Overall" class="gt_row gt_right">18 (56%)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  1</td>
#> <td headers="am = 1" class="gt_row gt_right">7 (54%)</td>
#> <td headers="am = 0" class="gt_row gt_right">7 (37%)</td>
#> <td headers="Overall" class="gt_row gt_right">14 (44%)</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="5"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> Continuous data are mean (SD) or median (IQR). Categorical data are n (%).</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>

# Ungrouped descriptive proportions with confidence intervals
summary_table(
  mtcars,
  include = c(cyl, vs),
  categorical = "percent",
  ci = TRUE
)
#> <div id="rfyopdbfbq" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#rfyopdbfbq table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #rfyopdbfbq thead, #rfyopdbfbq tbody, #rfyopdbfbq tfoot, #rfyopdbfbq tr, #rfyopdbfbq td, #rfyopdbfbq th {
#>   border-style: none;
#> }
#> 
#> #rfyopdbfbq p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #rfyopdbfbq .gt_table {
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
#> #rfyopdbfbq .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #rfyopdbfbq .gt_title {
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
#> #rfyopdbfbq .gt_subtitle {
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
#> #rfyopdbfbq .gt_heading {
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
#> #rfyopdbfbq .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #rfyopdbfbq .gt_col_headings {
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
#> #rfyopdbfbq .gt_col_heading {
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
#> #rfyopdbfbq .gt_column_spanner_outer {
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
#> #rfyopdbfbq .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #rfyopdbfbq .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #rfyopdbfbq .gt_column_spanner {
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
#> #rfyopdbfbq .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #rfyopdbfbq .gt_group_heading {
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
#> #rfyopdbfbq .gt_empty_group_heading {
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
#> #rfyopdbfbq .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #rfyopdbfbq .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #rfyopdbfbq .gt_row {
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
#> #rfyopdbfbq .gt_stub {
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
#> #rfyopdbfbq .gt_stub_row_group {
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
#> #rfyopdbfbq .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #rfyopdbfbq .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #rfyopdbfbq .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #rfyopdbfbq .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #rfyopdbfbq .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #rfyopdbfbq .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #rfyopdbfbq .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #rfyopdbfbq .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #rfyopdbfbq .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #rfyopdbfbq .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #rfyopdbfbq .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #rfyopdbfbq .gt_footnotes {
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
#> #rfyopdbfbq .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #rfyopdbfbq .gt_sourcenotes {
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
#> #rfyopdbfbq .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #rfyopdbfbq .gt_left {
#>   text-align: left;
#> }
#> 
#> #rfyopdbfbq .gt_center {
#>   text-align: center;
#> }
#> 
#> #rfyopdbfbq .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #rfyopdbfbq .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #rfyopdbfbq .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #rfyopdbfbq .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #rfyopdbfbq .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #rfyopdbfbq .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #rfyopdbfbq .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #rfyopdbfbq .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #rfyopdbfbq .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #rfyopdbfbq .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #rfyopdbfbq .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #rfyopdbfbq .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #rfyopdbfbq .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #rfyopdbfbq div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variable">Variable</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Level"></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Value"><span class='gt_from_md'>Overall<br />
#> N = 32</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">cyl</td>
#> <td headers="Level" class="gt_row gt_left">  4</td>
#> <td headers="Value" class="gt_row gt_right">34.4% (95% CI 18.6–53.2)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  6</td>
#> <td headers="Value" class="gt_row gt_right">21.9% (95% CI 9.3–40.0)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  8</td>
#> <td headers="Value" class="gt_row gt_right">43.8% (95% CI 26.4–62.3)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">vs</td>
#> <td headers="Level" class="gt_row gt_left">  0</td>
#> <td headers="Value" class="gt_row gt_right">56.2% (95% CI 37.7–73.6)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  1</td>
#> <td headers="Value" class="gt_row gt_right">43.8% (95% CI 26.4–62.3)</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="3"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> Categorical data are percentages. Categorical proportions include 95% exact binomial CIs.</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>

# Advanced incremental construction
summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(
    vars = c(mpg, wt),
    statistic = c(mpg = "mean_sd", wt = "median_iqr")
  )
#> <div id="ykwpatwcof" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#ykwpatwcof table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #ykwpatwcof thead, #ykwpatwcof tbody, #ykwpatwcof tfoot, #ykwpatwcof tr, #ykwpatwcof td, #ykwpatwcof th {
#>   border-style: none;
#> }
#> 
#> #ykwpatwcof p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #ykwpatwcof .gt_table {
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
#> #ykwpatwcof .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #ykwpatwcof .gt_title {
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
#> #ykwpatwcof .gt_subtitle {
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
#> #ykwpatwcof .gt_heading {
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
#> #ykwpatwcof .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #ykwpatwcof .gt_col_headings {
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
#> #ykwpatwcof .gt_col_heading {
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
#> #ykwpatwcof .gt_column_spanner_outer {
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
#> #ykwpatwcof .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #ykwpatwcof .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #ykwpatwcof .gt_column_spanner {
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
#> #ykwpatwcof .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #ykwpatwcof .gt_group_heading {
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
#> #ykwpatwcof .gt_empty_group_heading {
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
#> #ykwpatwcof .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #ykwpatwcof .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #ykwpatwcof .gt_row {
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
#> #ykwpatwcof .gt_stub {
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
#> #ykwpatwcof .gt_stub_row_group {
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
#> #ykwpatwcof .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #ykwpatwcof .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #ykwpatwcof .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #ykwpatwcof .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #ykwpatwcof .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #ykwpatwcof .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #ykwpatwcof .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #ykwpatwcof .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #ykwpatwcof .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #ykwpatwcof .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #ykwpatwcof .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #ykwpatwcof .gt_footnotes {
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
#> #ykwpatwcof .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #ykwpatwcof .gt_sourcenotes {
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
#> #ykwpatwcof .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #ykwpatwcof .gt_left {
#>   text-align: left;
#> }
#> 
#> #ykwpatwcof .gt_center {
#>   text-align: center;
#> }
#> 
#> #ykwpatwcof .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #ykwpatwcof .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #ykwpatwcof .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #ykwpatwcof .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #ykwpatwcof .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #ykwpatwcof .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #ykwpatwcof .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #ykwpatwcof .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #ykwpatwcof .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #ykwpatwcof .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #ykwpatwcof .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #ykwpatwcof .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #ykwpatwcof .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #ykwpatwcof div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variable">Variable</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Level"></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Overall"><span class='gt_from_md'>Overall<br />
#> N = 32</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="am-=-1"><span class='gt_from_md'>1<br />
#> N = 13</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="am-=-0"><span class='gt_from_md'>0<br />
#> N = 19</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">mpg</td>
#> <td headers="Level" class="gt_row gt_left"></td>
#> <td headers="Overall" class="gt_row gt_right">20.1 (6.0)</td>
#> <td headers="am = 1" class="gt_row gt_right">24.4 (6.2)</td>
#> <td headers="am = 0" class="gt_row gt_right">17.1 (3.8)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">wt</td>
#> <td headers="Level" class="gt_row gt_left"></td>
#> <td headers="Overall" class="gt_row gt_right">3.3 (2.6–3.6)</td>
#> <td headers="am = 1" class="gt_row gt_right">2.3 (1.9–2.8)</td>
#> <td headers="am = 0" class="gt_row gt_right">3.5 (3.4–3.8)</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="5"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> Continuous data: mpg: mean (SD); wt: median (IQR).</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
```
