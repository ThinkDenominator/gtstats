# Add an event-rate row

Add an event rate to a rate-mode table created with
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md).
Event counts and accumulated time are calculated from complete
event-time pairs only. Event counts and time values must be finite.
Exact Poisson confidence intervals are shown by default. A row with zero
accumulated time is retained as `\u2014` and recorded as not estimable
in the audit.

## Usage

``` r
add_rate(
  x,
  event,
  time,
  label = NULL,
  multiplier = 1000,
  time_label = NULL,
  ci = TRUE,
  conf.level = 0.95,
  digits = 1
)
```

## Arguments

- x:

  A rate-mode `gt_desc_table` created with
  [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md).

- event:

  Non-negative integer event count, supplied as a bare name or character
  string. Logical values are accepted as binary event indicators.

- time:

  Non-negative numeric person-time or exposure-time variable.

- label:

  Optional row label.

- multiplier:

  Positive rate multiplier. Default is `1000`.

- time_label:

  Optional readable time unit such as `"person-years"` or
  `"catheter-days"`. Defaults to `"person-time"`.

- ci:

  Logical; display an exact Poisson confidence interval.

- conf.level:

  Confidence level.

- digits:

  Number of decimal places.

## Value

The updated `gt_desc_table`.

## Details

`add_rate()` cannot be combined with summary-style components in the
same builder because rate denominators have a different meaning.

## Examples

``` r
summary_table(mtcars, by = am, overall = TRUE, mode = "rate") |>
  add_rate(
    event = carb,
    time = cyl,
    label = "Carburettor rate",
    multiplier = 1000
  )
#> <div id="dbirslsqjl" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#dbirslsqjl table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #dbirslsqjl thead, #dbirslsqjl tbody, #dbirslsqjl tfoot, #dbirslsqjl tr, #dbirslsqjl td, #dbirslsqjl th {
#>   border-style: none;
#> }
#> 
#> #dbirslsqjl p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #dbirslsqjl .gt_table {
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
#> #dbirslsqjl .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #dbirslsqjl .gt_title {
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
#> #dbirslsqjl .gt_subtitle {
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
#> #dbirslsqjl .gt_heading {
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
#> #dbirslsqjl .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #dbirslsqjl .gt_col_headings {
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
#> #dbirslsqjl .gt_col_heading {
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
#> #dbirslsqjl .gt_column_spanner_outer {
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
#> #dbirslsqjl .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #dbirslsqjl .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #dbirslsqjl .gt_column_spanner {
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
#> #dbirslsqjl .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #dbirslsqjl .gt_group_heading {
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
#> #dbirslsqjl .gt_empty_group_heading {
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
#> #dbirslsqjl .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #dbirslsqjl .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #dbirslsqjl .gt_row {
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
#> #dbirslsqjl .gt_stub {
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
#> #dbirslsqjl .gt_stub_row_group {
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
#> #dbirslsqjl .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #dbirslsqjl .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #dbirslsqjl .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #dbirslsqjl .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #dbirslsqjl .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #dbirslsqjl .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #dbirslsqjl .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #dbirslsqjl .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #dbirslsqjl .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #dbirslsqjl .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #dbirslsqjl .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #dbirslsqjl .gt_footnotes {
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
#> #dbirslsqjl .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #dbirslsqjl .gt_sourcenotes {
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
#> #dbirslsqjl .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #dbirslsqjl .gt_left {
#>   text-align: left;
#> }
#> 
#> #dbirslsqjl .gt_center {
#>   text-align: center;
#> }
#> 
#> #dbirslsqjl .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #dbirslsqjl .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #dbirslsqjl .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #dbirslsqjl .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #dbirslsqjl .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #dbirslsqjl .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #dbirslsqjl .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #dbirslsqjl .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #dbirslsqjl .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #dbirslsqjl .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #dbirslsqjl .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #dbirslsqjl .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #dbirslsqjl .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #dbirslsqjl div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
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
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">Carburettor rate</td>
#> <td headers="Level" class="gt_row gt_left"></td>
#> <td headers="Overall" class="gt_row gt_right">454.5 (365.5–558.7)</td>
#> <td headers="am = 1" class="gt_row gt_right">575.8 (407.4–790.3)</td>
#> <td headers="am = 0" class="gt_row gt_right">393.9 (294.2–516.6)</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="5"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> Rates per 1,000 person-time use complete event-time pairs and 95% exact Poisson confidence intervals.</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
```
