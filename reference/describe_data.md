# Understand a dataset before analysis

Create a concise, clinically oriented first look at a dataset. One row
is returned per variable, combining its label, detected type,
completeness, cardinality, a type-specific overview, and range or
levels. Potential data-quality findings are kept separately in
`$issues`.

## Usage

``` r
describe_data(
  data,
  vars = NULL,
  digits = 2,
  format = c("table", "tibble"),
  output = NULL
)
```

## Arguments

- data:

  A data.frame.

- vars:

  Optional character vector of variables. Default is all variables.

- digits:

  Number of decimal places in concise numeric summaries.

- format:

  Output format: `"table"` (default) or `"tibble"`.

- output:

  Compatibility alias for `format`.

## Value

With `format = "table"`, a `gt_describe` object that prints as a
publication-ready table. `$summary` is the concise variable overview and
`$issues` contains only findings requiring review. With
`format = "tibble"`, the concise summary tibble is returned directly.

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
#> <div id="evvaghsmzz" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#evvaghsmzz table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #evvaghsmzz thead, #evvaghsmzz tbody, #evvaghsmzz tfoot, #evvaghsmzz tr, #evvaghsmzz td, #evvaghsmzz th {
#>   border-style: none;
#> }
#> 
#> #evvaghsmzz p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #evvaghsmzz .gt_table {
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
#> #evvaghsmzz .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #evvaghsmzz .gt_title {
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
#> #evvaghsmzz .gt_subtitle {
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
#> #evvaghsmzz .gt_heading {
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
#> #evvaghsmzz .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #evvaghsmzz .gt_col_headings {
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
#> #evvaghsmzz .gt_col_heading {
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
#> #evvaghsmzz .gt_column_spanner_outer {
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
#> #evvaghsmzz .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #evvaghsmzz .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #evvaghsmzz .gt_column_spanner {
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
#> #evvaghsmzz .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #evvaghsmzz .gt_group_heading {
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
#> #evvaghsmzz .gt_empty_group_heading {
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
#> #evvaghsmzz .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #evvaghsmzz .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #evvaghsmzz .gt_row {
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
#> #evvaghsmzz .gt_stub {
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
#> #evvaghsmzz .gt_stub_row_group {
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
#> #evvaghsmzz .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #evvaghsmzz .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #evvaghsmzz .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #evvaghsmzz .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #evvaghsmzz .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #evvaghsmzz .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #evvaghsmzz .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #evvaghsmzz .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #evvaghsmzz .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #evvaghsmzz .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #evvaghsmzz .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #evvaghsmzz .gt_footnotes {
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
#> #evvaghsmzz .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #evvaghsmzz .gt_sourcenotes {
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
#> #evvaghsmzz .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #evvaghsmzz .gt_left {
#>   text-align: left;
#> }
#> 
#> #evvaghsmzz .gt_center {
#>   text-align: center;
#> }
#> 
#> #evvaghsmzz .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #evvaghsmzz .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #evvaghsmzz .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #evvaghsmzz .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #evvaghsmzz .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #evvaghsmzz .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #evvaghsmzz .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #evvaghsmzz .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #evvaghsmzz .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #evvaghsmzz .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #evvaghsmzz .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #evvaghsmzz .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #evvaghsmzz .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #evvaghsmzz div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
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
#> <div id="jkjksxdaga" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#jkjksxdaga table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #jkjksxdaga thead, #jkjksxdaga tbody, #jkjksxdaga tfoot, #jkjksxdaga tr, #jkjksxdaga td, #jkjksxdaga th {
#>   border-style: none;
#> }
#> 
#> #jkjksxdaga p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #jkjksxdaga .gt_table {
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
#> #jkjksxdaga .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #jkjksxdaga .gt_title {
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
#> #jkjksxdaga .gt_subtitle {
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
#> #jkjksxdaga .gt_heading {
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
#> #jkjksxdaga .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jkjksxdaga .gt_col_headings {
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
#> #jkjksxdaga .gt_col_heading {
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
#> #jkjksxdaga .gt_column_spanner_outer {
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
#> #jkjksxdaga .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #jkjksxdaga .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #jkjksxdaga .gt_column_spanner {
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
#> #jkjksxdaga .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #jkjksxdaga .gt_group_heading {
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
#> #jkjksxdaga .gt_empty_group_heading {
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
#> #jkjksxdaga .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #jkjksxdaga .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #jkjksxdaga .gt_row {
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
#> #jkjksxdaga .gt_stub {
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
#> #jkjksxdaga .gt_stub_row_group {
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
#> #jkjksxdaga .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #jkjksxdaga .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #jkjksxdaga .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jkjksxdaga .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #jkjksxdaga .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #jkjksxdaga .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jkjksxdaga .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jkjksxdaga .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #jkjksxdaga .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jkjksxdaga .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #jkjksxdaga .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jkjksxdaga .gt_footnotes {
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
#> #jkjksxdaga .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jkjksxdaga .gt_sourcenotes {
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
#> #jkjksxdaga .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jkjksxdaga .gt_left {
#>   text-align: left;
#> }
#> 
#> #jkjksxdaga .gt_center {
#>   text-align: center;
#> }
#> 
#> #jkjksxdaga .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #jkjksxdaga .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #jkjksxdaga .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #jkjksxdaga .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #jkjksxdaga .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #jkjksxdaga .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #jkjksxdaga .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #jkjksxdaga .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #jkjksxdaga .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #jkjksxdaga .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #jkjksxdaga .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #jkjksxdaga .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #jkjksxdaga .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #jkjksxdaga div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
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
