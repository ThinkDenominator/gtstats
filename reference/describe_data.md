# Understand a dataset before analysis

Create a concise, clinically oriented first look at a dataset. One row
is returned per variable, combining its label, detected type,
completeness, cardinality, a type-specific overview, and range or
levels. Potential data-quality findings are kept separately in
`$issues`.

## Usage

``` r
describe_data(data, vars = NULL, digits = 2, output = c("table", "tibble"))
```

## Arguments

- data:

  A data.frame.

- vars:

  Optional character vector of variables. Default is all variables.

- digits:

  Number of decimal places in concise numeric summaries.

- output:

  Requested output route, retained for consistency with other gtstats
  functions.

## Value

With `output = "table"`, a `gt_describe` object that prints as a
publication-ready table. `$summary` is the concise variable overview and
`$issues` contains only findings requiring review. With
`output = "tibble"`, the concise summary tibble is returned directly.

## Details

`describe_data()` deliberately does not assess distributional
assumptions or recommend inferential tests. Use
[`assess_distribution()`](https://gtstats.thinkdenominator.com/reference/assess_distribution.md)
for the shape of selected continuous variables,
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md)
for detailed descriptive statistics, and
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md)
for inferential comparisons.

## Examples

``` r
describe_data(mtcars)
#> <div id="bvaltgdknp" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#bvaltgdknp table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #bvaltgdknp thead, #bvaltgdknp tbody, #bvaltgdknp tfoot, #bvaltgdknp tr, #bvaltgdknp td, #bvaltgdknp th {
#>   border-style: none;
#> }
#> 
#> #bvaltgdknp p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #bvaltgdknp .gt_table {
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
#> #bvaltgdknp .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #bvaltgdknp .gt_title {
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
#> #bvaltgdknp .gt_subtitle {
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
#> #bvaltgdknp .gt_heading {
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
#> #bvaltgdknp .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bvaltgdknp .gt_col_headings {
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
#> #bvaltgdknp .gt_col_heading {
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
#> #bvaltgdknp .gt_column_spanner_outer {
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
#> #bvaltgdknp .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #bvaltgdknp .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #bvaltgdknp .gt_column_spanner {
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
#> #bvaltgdknp .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #bvaltgdknp .gt_group_heading {
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
#> #bvaltgdknp .gt_empty_group_heading {
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
#> #bvaltgdknp .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #bvaltgdknp .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #bvaltgdknp .gt_row {
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
#> #bvaltgdknp .gt_stub {
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
#> #bvaltgdknp .gt_stub_row_group {
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
#> #bvaltgdknp .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #bvaltgdknp .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #bvaltgdknp .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bvaltgdknp .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #bvaltgdknp .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #bvaltgdknp .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bvaltgdknp .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bvaltgdknp .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #bvaltgdknp .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bvaltgdknp .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #bvaltgdknp .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #bvaltgdknp .gt_footnotes {
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
#> #bvaltgdknp .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bvaltgdknp .gt_sourcenotes {
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
#> #bvaltgdknp .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #bvaltgdknp .gt_left {
#>   text-align: left;
#> }
#> 
#> #bvaltgdknp .gt_center {
#>   text-align: center;
#> }
#> 
#> #bvaltgdknp .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #bvaltgdknp .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #bvaltgdknp .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #bvaltgdknp .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #bvaltgdknp .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #bvaltgdknp .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #bvaltgdknp .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #bvaltgdknp .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #bvaltgdknp .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #bvaltgdknp .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #bvaltgdknp .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #bvaltgdknp .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #bvaltgdknp .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #bvaltgdknp div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variable">Variable</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Type">Type</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Complete">Complete</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Unique">Unique</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Overview">Overview</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Range-/-levels">Range / levels</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Variable" class="gt_row gt_left">mpg</td>
#> <td headers="Type" class="gt_row gt_left">continuous</td>
#> <td headers="Complete" class="gt_row gt_right">32/32 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">25</td>
#> <td headers="Overview" class="gt_row gt_left">Mean 20.09 (SD 6.03); median 19.20</td>
#> <td headers="Range / levels" class="gt_row gt_left">10.40 to 33.90</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">cyl</td>
#> <td headers="Type" class="gt_row gt_left">categorical</td>
#> <td headers="Complete" class="gt_row gt_right">32/32 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">3</td>
#> <td headers="Overview" class="gt_row gt_left">8 14 (43.8%); 4 11 (34.4%); 6 7 (21.9%)</td>
#> <td headers="Range / levels" class="gt_row gt_left">6, 4, 8</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">disp</td>
#> <td headers="Type" class="gt_row gt_left">continuous</td>
#> <td headers="Complete" class="gt_row gt_right">32/32 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">27</td>
#> <td headers="Overview" class="gt_row gt_left">Mean 230.72 (SD 123.94); median 196.30</td>
#> <td headers="Range / levels" class="gt_row gt_left">71.10 to 472.00</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">hp</td>
#> <td headers="Type" class="gt_row gt_left">continuous</td>
#> <td headers="Complete" class="gt_row gt_right">32/32 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">22</td>
#> <td headers="Overview" class="gt_row gt_left">Mean 146.69 (SD 68.56); median 123.00</td>
#> <td headers="Range / levels" class="gt_row gt_left">52.00 to 335.00</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">drat</td>
#> <td headers="Type" class="gt_row gt_left">continuous</td>
#> <td headers="Complete" class="gt_row gt_right">32/32 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">22</td>
#> <td headers="Overview" class="gt_row gt_left">Mean 3.60 (SD 0.53); median 3.70</td>
#> <td headers="Range / levels" class="gt_row gt_left">2.76 to 4.93</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">wt</td>
#> <td headers="Type" class="gt_row gt_left">continuous</td>
#> <td headers="Complete" class="gt_row gt_right">32/32 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">29</td>
#> <td headers="Overview" class="gt_row gt_left">Mean 3.22 (SD 0.98); median 3.33</td>
#> <td headers="Range / levels" class="gt_row gt_left">1.51 to 5.42</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">qsec</td>
#> <td headers="Type" class="gt_row gt_left">continuous</td>
#> <td headers="Complete" class="gt_row gt_right">32/32 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">30</td>
#> <td headers="Overview" class="gt_row gt_left">Mean 17.85 (SD 1.79); median 17.71</td>
#> <td headers="Range / levels" class="gt_row gt_left">14.50 to 22.90</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">vs</td>
#> <td headers="Type" class="gt_row gt_left">binary</td>
#> <td headers="Complete" class="gt_row gt_right">32/32 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">2</td>
#> <td headers="Overview" class="gt_row gt_left">0 18 (56.2%); 1 14 (43.8%)</td>
#> <td headers="Range / levels" class="gt_row gt_left">0, 1</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">am</td>
#> <td headers="Type" class="gt_row gt_left">binary</td>
#> <td headers="Complete" class="gt_row gt_right">32/32 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">2</td>
#> <td headers="Overview" class="gt_row gt_left">0 19 (59.4%); 1 13 (40.6%)</td>
#> <td headers="Range / levels" class="gt_row gt_left">1, 0</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">gear</td>
#> <td headers="Type" class="gt_row gt_left">categorical*</td>
#> <td headers="Complete" class="gt_row gt_right">32/32 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">3</td>
#> <td headers="Overview" class="gt_row gt_left">3 15 (46.9%); 4 12 (37.5%); 5 5 (15.6%)</td>
#> <td headers="Range / levels" class="gt_row gt_left">4, 3, 5</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">carb</td>
#> <td headers="Type" class="gt_row gt_left">continuous</td>
#> <td headers="Complete" class="gt_row gt_right">32/32 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">6</td>
#> <td headers="Overview" class="gt_row gt_left">Mean 2.81 (SD 1.62); median 2.00</td>
#> <td headers="Range / levels" class="gt_row gt_left">1.00 to 8.00</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="6">* Possible ordinal or count-coded variable. Confirm the intended meaning and order using the data dictionary or clinical context.</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
describe_data(mtcars, vars = c("mpg", "cyl", "am"))
#> <div id="gqnkvjkyby" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#gqnkvjkyby table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #gqnkvjkyby thead, #gqnkvjkyby tbody, #gqnkvjkyby tfoot, #gqnkvjkyby tr, #gqnkvjkyby td, #gqnkvjkyby th {
#>   border-style: none;
#> }
#> 
#> #gqnkvjkyby p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #gqnkvjkyby .gt_table {
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
#> #gqnkvjkyby .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #gqnkvjkyby .gt_title {
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
#> #gqnkvjkyby .gt_subtitle {
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
#> #gqnkvjkyby .gt_heading {
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
#> #gqnkvjkyby .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #gqnkvjkyby .gt_col_headings {
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
#> #gqnkvjkyby .gt_col_heading {
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
#> #gqnkvjkyby .gt_column_spanner_outer {
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
#> #gqnkvjkyby .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #gqnkvjkyby .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #gqnkvjkyby .gt_column_spanner {
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
#> #gqnkvjkyby .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #gqnkvjkyby .gt_group_heading {
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
#> #gqnkvjkyby .gt_empty_group_heading {
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
#> #gqnkvjkyby .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #gqnkvjkyby .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #gqnkvjkyby .gt_row {
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
#> #gqnkvjkyby .gt_stub {
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
#> #gqnkvjkyby .gt_stub_row_group {
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
#> #gqnkvjkyby .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #gqnkvjkyby .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #gqnkvjkyby .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #gqnkvjkyby .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #gqnkvjkyby .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #gqnkvjkyby .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #gqnkvjkyby .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #gqnkvjkyby .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #gqnkvjkyby .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #gqnkvjkyby .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #gqnkvjkyby .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #gqnkvjkyby .gt_footnotes {
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
#> #gqnkvjkyby .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #gqnkvjkyby .gt_sourcenotes {
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
#> #gqnkvjkyby .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #gqnkvjkyby .gt_left {
#>   text-align: left;
#> }
#> 
#> #gqnkvjkyby .gt_center {
#>   text-align: center;
#> }
#> 
#> #gqnkvjkyby .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #gqnkvjkyby .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #gqnkvjkyby .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #gqnkvjkyby .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #gqnkvjkyby .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #gqnkvjkyby .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #gqnkvjkyby .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #gqnkvjkyby .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #gqnkvjkyby .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #gqnkvjkyby .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #gqnkvjkyby .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #gqnkvjkyby .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #gqnkvjkyby .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #gqnkvjkyby div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variable">Variable</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Type">Type</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Complete">Complete</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Unique">Unique</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Overview">Overview</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Range-/-levels">Range / levels</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Variable" class="gt_row gt_left">mpg</td>
#> <td headers="Type" class="gt_row gt_left">continuous</td>
#> <td headers="Complete" class="gt_row gt_right">32/32 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">25</td>
#> <td headers="Overview" class="gt_row gt_left">Mean 20.09 (SD 6.03); median 19.20</td>
#> <td headers="Range / levels" class="gt_row gt_left">10.40 to 33.90</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">cyl</td>
#> <td headers="Type" class="gt_row gt_left">categorical</td>
#> <td headers="Complete" class="gt_row gt_right">32/32 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">3</td>
#> <td headers="Overview" class="gt_row gt_left">8 14 (43.8%); 4 11 (34.4%); 6 7 (21.9%)</td>
#> <td headers="Range / levels" class="gt_row gt_left">6, 4, 8</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">am</td>
#> <td headers="Type" class="gt_row gt_left">binary</td>
#> <td headers="Complete" class="gt_row gt_right">32/32 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">2</td>
#> <td headers="Overview" class="gt_row gt_left">0 19 (59.4%); 1 13 (40.6%)</td>
#> <td headers="Range / levels" class="gt_row gt_left">1, 0</td></tr>
#>   </tbody>
#>   
#> </table>
#> </div>
tbl_stats(describe_data(mtcars))


  

Variable
```
