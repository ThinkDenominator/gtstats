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
  digits = 2
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

## Value

A `gt_twobytwo` object.

## Examples

``` r
crosstabs(mtcars, row = am, col = vs)
#> <div id="bxetcdawau" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#bxetcdawau table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #bxetcdawau thead, #bxetcdawau tbody, #bxetcdawau tfoot, #bxetcdawau tr, #bxetcdawau td, #bxetcdawau th {
#>   border-style: none;
#> }
#> 
#> #bxetcdawau p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #bxetcdawau .gt_table {
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
#> #bxetcdawau .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #bxetcdawau .gt_title {
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
#> #bxetcdawau .gt_subtitle {
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
#> #bxetcdawau .gt_heading {
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
#> #bxetcdawau .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bxetcdawau .gt_col_headings {
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
#> #bxetcdawau .gt_col_heading {
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
#> #bxetcdawau .gt_column_spanner_outer {
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
#> #bxetcdawau .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #bxetcdawau .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #bxetcdawau .gt_column_spanner {
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
#> #bxetcdawau .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #bxetcdawau .gt_group_heading {
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
#> #bxetcdawau .gt_empty_group_heading {
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
#> #bxetcdawau .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #bxetcdawau .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #bxetcdawau .gt_row {
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
#> #bxetcdawau .gt_stub {
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
#> #bxetcdawau .gt_stub_row_group {
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
#> #bxetcdawau .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #bxetcdawau .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #bxetcdawau .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bxetcdawau .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #bxetcdawau .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #bxetcdawau .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bxetcdawau .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bxetcdawau .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #bxetcdawau .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bxetcdawau .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #bxetcdawau .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bxetcdawau .gt_footnotes {
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
#> #bxetcdawau .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bxetcdawau .gt_sourcenotes {
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
#> #bxetcdawau .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bxetcdawau .gt_left {
#>   text-align: left;
#> }
#> 
#> #bxetcdawau .gt_center {
#>   text-align: center;
#> }
#> 
#> #bxetcdawau .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #bxetcdawau .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #bxetcdawau .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #bxetcdawau .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #bxetcdawau .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #bxetcdawau .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #bxetcdawau .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #bxetcdawau .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #bxetcdawau .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #bxetcdawau .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #bxetcdawau .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #bxetcdawau .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #bxetcdawau .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #bxetcdawau div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="am">am</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="a0">0</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="a1">1</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Total">Total</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="am" class="gt_row gt_left">0</td>
#> <td headers="0" class="gt_row gt_right"><span class='gt_from_md'>12<br>66.67%</span></td>
#> <td headers="1" class="gt_row gt_right"><span class='gt_from_md'>7<br>50.00%</span></td>
#> <td headers="Total" class="gt_row gt_right"><span class='gt_from_md'>19<br>59.38%</span></td></tr>
#>     <tr><td headers="am" class="gt_row gt_left">1</td>
#> <td headers="0" class="gt_row gt_right"><span class='gt_from_md'>6<br>33.33%</span></td>
#> <td headers="1" class="gt_row gt_right"><span class='gt_from_md'>7<br>50.00%</span></td>
#> <td headers="Total" class="gt_row gt_right"><span class='gt_from_md'>13<br>40.62%</span></td></tr>
#>     <tr><td headers="am" class="gt_row gt_left">Total</td>
#> <td headers="0" class="gt_row gt_right"><span class='gt_from_md'>18<br>100.00%</span></td>
#> <td headers="1" class="gt_row gt_right"><span class='gt_from_md'>14<br>100.00%</span></td>
#> <td headers="Total" class="gt_row gt_right"><span class='gt_from_md'>32<br>100.00%</span></td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="4">Cells are n (column %). Chi-square test with Yates correction, p = 0.556; Cramer's V = 0.10.</td>
#>     </tr>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="4">RR 1.46 (0.67–3.17); OR 2.00 (0.48–8.40); RD 17.00 pp (-16.15–45.98 pp)</td>
#>     </tr>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="4">Exposure: am; exposed = 1, unexposed = 0. Event: vs = 1. Complete pairs: N = 32.</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
```
