# Assess variation of continuous variables across groups

Describe the spread of continuous numeric variables within groups. This
is a diagnostic companion to
[`assess_distribution()`](https://gtstats.thinkdenominator.com/reference/assess_distribution.md)
and is intended to make variation visible before a group comparison is
interpreted.

## Usage

``` r
assess_variance(
  data,
  vars = NULL,
  by,
  digits = 2,
  output = c("table", "tibble")
)
```

## Arguments

- data:

  A data frame.

- vars:

  Continuous numeric variables to assess. Bare names or a character
  vector are accepted. When omitted, all detected continuous variables
  are assessed. Categorical, ordinal, logical, date-time, and binary
  variables are rejected when explicitly selected.

- by:

  Grouping variable, supplied as a bare name or character string. It
  must be categorical, binary, logical, or ordinal and contain at least
  two observed groups.

- digits:

  Number of decimal places.

- output:

  Either `"table"` (the default) or `"tibble"`.

## Value

With `output = "table"`, a `gt_variance` object that prints as a
publication-ready table. `$summary` contains all group-level values and
repeated variable-level diagnostics. With `output = "tibble"`, the
detailed summary tibble is returned.

## Details

`assess_variance()` reports group sample sizes, standard deviations,
variances, and the ratio of the largest to the smallest group SD and
variance. These ratios are descriptive diagnostics, not pass/fail tests.
The function deliberately does not run a variance hypothesis test by
default, and it does not choose an inferential test. In particular,
Welch t-tests and Welch ANOVA do not require equal variances.

## Examples

``` r
assess_variance(mtcars, vars = c(mpg, wt), by = am)
#> <div id="qeoelfyoqa" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#qeoelfyoqa table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #qeoelfyoqa thead, #qeoelfyoqa tbody, #qeoelfyoqa tfoot, #qeoelfyoqa tr, #qeoelfyoqa td, #qeoelfyoqa th {
#>   border-style: none;
#> }
#> 
#> #qeoelfyoqa p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #qeoelfyoqa .gt_table {
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
#> #qeoelfyoqa .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #qeoelfyoqa .gt_title {
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
#> #qeoelfyoqa .gt_subtitle {
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
#> #qeoelfyoqa .gt_heading {
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
#> #qeoelfyoqa .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qeoelfyoqa .gt_col_headings {
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
#> #qeoelfyoqa .gt_col_heading {
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
#> #qeoelfyoqa .gt_column_spanner_outer {
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
#> #qeoelfyoqa .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #qeoelfyoqa .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #qeoelfyoqa .gt_column_spanner {
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
#> #qeoelfyoqa .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #qeoelfyoqa .gt_group_heading {
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
#> #qeoelfyoqa .gt_empty_group_heading {
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
#> #qeoelfyoqa .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #qeoelfyoqa .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #qeoelfyoqa .gt_row {
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
#> #qeoelfyoqa .gt_stub {
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
#> #qeoelfyoqa .gt_stub_row_group {
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
#> #qeoelfyoqa .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #qeoelfyoqa .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #qeoelfyoqa .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qeoelfyoqa .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #qeoelfyoqa .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #qeoelfyoqa .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qeoelfyoqa .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qeoelfyoqa .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #qeoelfyoqa .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qeoelfyoqa .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #qeoelfyoqa .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #qeoelfyoqa .gt_footnotes {
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
#> #qeoelfyoqa .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qeoelfyoqa .gt_sourcenotes {
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
#> #qeoelfyoqa .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #qeoelfyoqa .gt_left {
#>   text-align: left;
#> }
#> 
#> #qeoelfyoqa .gt_center {
#>   text-align: center;
#> }
#> 
#> #qeoelfyoqa .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #qeoelfyoqa .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #qeoelfyoqa .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #qeoelfyoqa .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #qeoelfyoqa .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #qeoelfyoqa .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #qeoelfyoqa .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #qeoelfyoqa .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #qeoelfyoqa .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #qeoelfyoqa .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #qeoelfyoqa .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #qeoelfyoqa .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #qeoelfyoqa .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #qeoelfyoqa div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variable">Variable</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Group">Group</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n">n</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="SD">SD</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variance">Variance</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="SD-ratio">SD ratio<span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variance-ratio">Variance ratio</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Interpretation">Interpretation<span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Variable" class="gt_row gt_left">mpg</td>
#> <td headers="Group" class="gt_row gt_right">1</td>
#> <td headers="n" class="gt_row gt_right">13</td>
#> <td headers="SD" class="gt_row gt_right">6.17</td>
#> <td headers="Variance" class="gt_row gt_right">38.03</td>
#> <td headers="SD ratio" class="gt_row gt_right">1.61</td>
#> <td headers="Variance ratio" class="gt_row gt_right">2.59</td>
#> <td headers="Interpretation" class="gt_row gt_left">Descriptive spread shown; Welch methods do not require equal variances.</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Group" class="gt_row gt_right">0</td>
#> <td headers="n" class="gt_row gt_right">19</td>
#> <td headers="SD" class="gt_row gt_right">3.83</td>
#> <td headers="Variance" class="gt_row gt_right">14.70</td>
#> <td headers="SD ratio" class="gt_row gt_right">NA</td>
#> <td headers="Variance ratio" class="gt_row gt_right">NA</td>
#> <td headers="Interpretation" class="gt_row gt_left"></td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">wt</td>
#> <td headers="Group" class="gt_row gt_right">1</td>
#> <td headers="n" class="gt_row gt_right">13</td>
#> <td headers="SD" class="gt_row gt_right">0.62</td>
#> <td headers="Variance" class="gt_row gt_right">0.38</td>
#> <td headers="SD ratio" class="gt_row gt_right">1.26</td>
#> <td headers="Variance ratio" class="gt_row gt_right">1.59</td>
#> <td headers="Interpretation" class="gt_row gt_left">Descriptive spread shown; Welch methods do not require equal variances.</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Group" class="gt_row gt_right">0</td>
#> <td headers="n" class="gt_row gt_right">19</td>
#> <td headers="SD" class="gt_row gt_right">0.78</td>
#> <td headers="Variance" class="gt_row gt_right">0.60</td>
#> <td headers="SD ratio" class="gt_row gt_right">NA</td>
#> <td headers="Variance ratio" class="gt_row gt_right">NA</td>
#> <td headers="Interpretation" class="gt_row gt_left"></td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="8"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> SD and variance ratios are the largest group value divided by the smallest group value. They describe observed spread; they are not pass/fail tests.</td>
#>     </tr>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="8"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span> Welch t-tests and Welch ANOVA do not require equal variances. `assess_variance()` does not select an inferential test. Interpret spread alongside sample size, distributional shape, outliers, missingness, and the study design.</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
assess_variance(mtcars, vars = "mpg", by = am, digits = 1)
#> <div id="itrxpwwkzg" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#itrxpwwkzg table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #itrxpwwkzg thead, #itrxpwwkzg tbody, #itrxpwwkzg tfoot, #itrxpwwkzg tr, #itrxpwwkzg td, #itrxpwwkzg th {
#>   border-style: none;
#> }
#> 
#> #itrxpwwkzg p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #itrxpwwkzg .gt_table {
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
#> #itrxpwwkzg .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #itrxpwwkzg .gt_title {
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
#> #itrxpwwkzg .gt_subtitle {
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
#> #itrxpwwkzg .gt_heading {
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
#> #itrxpwwkzg .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #itrxpwwkzg .gt_col_headings {
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
#> #itrxpwwkzg .gt_col_heading {
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
#> #itrxpwwkzg .gt_column_spanner_outer {
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
#> #itrxpwwkzg .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #itrxpwwkzg .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #itrxpwwkzg .gt_column_spanner {
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
#> #itrxpwwkzg .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #itrxpwwkzg .gt_group_heading {
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
#> #itrxpwwkzg .gt_empty_group_heading {
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
#> #itrxpwwkzg .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #itrxpwwkzg .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #itrxpwwkzg .gt_row {
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
#> #itrxpwwkzg .gt_stub {
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
#> #itrxpwwkzg .gt_stub_row_group {
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
#> #itrxpwwkzg .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #itrxpwwkzg .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #itrxpwwkzg .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #itrxpwwkzg .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #itrxpwwkzg .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #itrxpwwkzg .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #itrxpwwkzg .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #itrxpwwkzg .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #itrxpwwkzg .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #itrxpwwkzg .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #itrxpwwkzg .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #itrxpwwkzg .gt_footnotes {
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
#> #itrxpwwkzg .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #itrxpwwkzg .gt_sourcenotes {
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
#> #itrxpwwkzg .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #itrxpwwkzg .gt_left {
#>   text-align: left;
#> }
#> 
#> #itrxpwwkzg .gt_center {
#>   text-align: center;
#> }
#> 
#> #itrxpwwkzg .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #itrxpwwkzg .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #itrxpwwkzg .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #itrxpwwkzg .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #itrxpwwkzg .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #itrxpwwkzg .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #itrxpwwkzg .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #itrxpwwkzg .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #itrxpwwkzg .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #itrxpwwkzg .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #itrxpwwkzg .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #itrxpwwkzg .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #itrxpwwkzg .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #itrxpwwkzg div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variable">Variable</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Group">Group</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n">n</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="SD">SD</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variance">Variance</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="SD-ratio">SD ratio<span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variance-ratio">Variance ratio</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Interpretation">Interpretation<span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Variable" class="gt_row gt_left">mpg</td>
#> <td headers="Group" class="gt_row gt_right">1</td>
#> <td headers="n" class="gt_row gt_right">13</td>
#> <td headers="SD" class="gt_row gt_right">6.2</td>
#> <td headers="Variance" class="gt_row gt_right">38.0</td>
#> <td headers="SD ratio" class="gt_row gt_right">1.6</td>
#> <td headers="Variance ratio" class="gt_row gt_right">2.6</td>
#> <td headers="Interpretation" class="gt_row gt_left">Descriptive spread shown; Welch methods do not require equal variances.</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Group" class="gt_row gt_right">0</td>
#> <td headers="n" class="gt_row gt_right">19</td>
#> <td headers="SD" class="gt_row gt_right">3.8</td>
#> <td headers="Variance" class="gt_row gt_right">14.7</td>
#> <td headers="SD ratio" class="gt_row gt_right">NA</td>
#> <td headers="Variance ratio" class="gt_row gt_right">NA</td>
#> <td headers="Interpretation" class="gt_row gt_left"></td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="8"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> SD and variance ratios are the largest group value divided by the smallest group value. They describe observed spread; they are not pass/fail tests.</td>
#>     </tr>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="8"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span> Welch t-tests and Welch ANOVA do not require equal variances. `assess_variance()` does not select an inferential test. Interpret spread alongside sample size, distributional shape, outliers, missingness, and the study design.</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
```
