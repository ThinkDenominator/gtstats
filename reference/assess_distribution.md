# Assess the empirical distribution of continuous variables

Assess the empirical distribution of continuous numeric variables to
support descriptive reporting. The function describes missingness,
finite sample size, skewness, and (optionally) Shapiro-Wilk results. It
provides guidance about presenting a variable; it does **not** select an
inferential test.

## Usage

``` r
assess_distribution(
  data,
  vars = NULL,
  by = NULL,
  normality_test = TRUE,
  skew_cutoff = 1,
  min_n = 3,
  plots = FALSE,
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

  Optional grouping variable, supplied as a bare name or character
  string. Factors, characters, logical variables, binary variables, and
  ordinal variables are supported.

- normality_test:

  Logical; run Shapiro-Wilk when 3 to 5000 finite observations are
  available. Default is `TRUE`.

- skew_cutoff:

  Positive absolute-skewness threshold for marked skew.

- min_n:

  Minimum finite observations required for a shape assessment.

- plots:

  Logical; create histogram, density, Q-Q, and box plots. Plots are
  stored in `$plots` (or `attr(result, "plots")` for tibble output).

- digits:

  Number of decimal places.

- output:

  Either `"table"` (the default) or `"tibble"`.

## Value

With `output = "table"`, a `gt_distribution` object that prints as a
publication-ready table. `$summary` contains group-level diagnostics and
`$recommendations` contains one descriptive recommendation per variable.
With `output = "tibble"`, the group-level summary tibble is returned.

## Details

When `by` is supplied, diagnostics are calculated within every group and
one consistent, variable-level recommendation is also returned in
`$recommendations`. Shapiro-Wilk is supporting information only: it is
sensitive to sample size and never determines the recommendation by
itself.

## Examples

``` r
assess_distribution(mtcars, vars = c(mpg, wt))
#> <div id="dsuvupsnnt" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#dsuvupsnnt table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #dsuvupsnnt thead, #dsuvupsnnt tbody, #dsuvupsnnt tfoot, #dsuvupsnnt tr, #dsuvupsnnt td, #dsuvupsnnt th {
#>   border-style: none;
#> }
#> 
#> #dsuvupsnnt p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #dsuvupsnnt .gt_table {
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
#> #dsuvupsnnt .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #dsuvupsnnt .gt_title {
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
#> #dsuvupsnnt .gt_subtitle {
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
#> #dsuvupsnnt .gt_heading {
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
#> #dsuvupsnnt .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #dsuvupsnnt .gt_col_headings {
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
#> #dsuvupsnnt .gt_col_heading {
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
#> #dsuvupsnnt .gt_column_spanner_outer {
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
#> #dsuvupsnnt .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #dsuvupsnnt .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #dsuvupsnnt .gt_column_spanner {
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
#> #dsuvupsnnt .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #dsuvupsnnt .gt_group_heading {
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
#> #dsuvupsnnt .gt_empty_group_heading {
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
#> #dsuvupsnnt .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #dsuvupsnnt .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #dsuvupsnnt .gt_row {
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
#> #dsuvupsnnt .gt_stub {
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
#> #dsuvupsnnt .gt_stub_row_group {
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
#> #dsuvupsnnt .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #dsuvupsnnt .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #dsuvupsnnt .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #dsuvupsnnt .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #dsuvupsnnt .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #dsuvupsnnt .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #dsuvupsnnt .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #dsuvupsnnt .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #dsuvupsnnt .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #dsuvupsnnt .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #dsuvupsnnt .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #dsuvupsnnt .gt_footnotes {
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
#> #dsuvupsnnt .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #dsuvupsnnt .gt_sourcenotes {
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
#> #dsuvupsnnt .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #dsuvupsnnt .gt_left {
#>   text-align: left;
#> }
#> 
#> #dsuvupsnnt .gt_center {
#>   text-align: center;
#> }
#> 
#> #dsuvupsnnt .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #dsuvupsnnt .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #dsuvupsnnt .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #dsuvupsnnt .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #dsuvupsnnt .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #dsuvupsnnt .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #dsuvupsnnt .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #dsuvupsnnt .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #dsuvupsnnt .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #dsuvupsnnt .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #dsuvupsnnt .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #dsuvupsnnt .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #dsuvupsnnt .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #dsuvupsnnt div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variable">Variable</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n">n</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Skewness">Skewness</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Shape">Shape<span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Suggested-presentation">Suggested presentation<span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Shapiro-p">Shapiro p<span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>3</sup></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Variable" class="gt_row gt_left">mpg</td>
#> <td headers="n" class="gt_row gt_right">32</td>
#> <td headers="Skewness" class="gt_row gt_right">0.61</td>
#> <td headers="Shape" class="gt_row gt_left">Some right asymmetry</td>
#> <td headers="Suggested presentation" class="gt_row gt_left">Review mean (SD) and median (IQR)</td>
#> <td headers="Shapiro p" class="gt_row gt_right">0.123</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">wt</td>
#> <td headers="n" class="gt_row gt_right">32</td>
#> <td headers="Skewness" class="gt_row gt_right">0.42</td>
#> <td headers="Shape" class="gt_row gt_left">Little/no asymmetry</td>
#> <td headers="Suggested presentation" class="gt_row gt_left">Mean (SD) reasonable</td>
#> <td headers="Shapiro p" class="gt_row gt_right">0.093</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="6"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> Shape categories use absolute sample skewness: little/no asymmetry &lt; 0.50; some asymmetry 0.50 to &lt; 1.00; marked skew &gt;= 1.00. They are descriptive guidance, not formal classifications.</td>
#>     </tr>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="6"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span> Suggested summaries are intended for descriptive reporting only and should not be used alone to determine inferential statistical methods.</td>
#>     </tr>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="6"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>3</sup></span> Shapiro-Wilk is sensitive to sample size. Interpretation should consider skewness, graphical assessment, sample size and subject-matter knowledge.</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
assess_distribution(mtcars, vars = c(mpg, wt), by = am)
#> <div id="yufggzfelh" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#yufggzfelh table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #yufggzfelh thead, #yufggzfelh tbody, #yufggzfelh tfoot, #yufggzfelh tr, #yufggzfelh td, #yufggzfelh th {
#>   border-style: none;
#> }
#> 
#> #yufggzfelh p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #yufggzfelh .gt_table {
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
#> #yufggzfelh .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #yufggzfelh .gt_title {
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
#> #yufggzfelh .gt_subtitle {
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
#> #yufggzfelh .gt_heading {
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
#> #yufggzfelh .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #yufggzfelh .gt_col_headings {
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
#> #yufggzfelh .gt_col_heading {
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
#> #yufggzfelh .gt_column_spanner_outer {
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
#> #yufggzfelh .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #yufggzfelh .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #yufggzfelh .gt_column_spanner {
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
#> #yufggzfelh .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #yufggzfelh .gt_group_heading {
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
#> #yufggzfelh .gt_empty_group_heading {
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
#> #yufggzfelh .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #yufggzfelh .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #yufggzfelh .gt_row {
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
#> #yufggzfelh .gt_stub {
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
#> #yufggzfelh .gt_stub_row_group {
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
#> #yufggzfelh .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #yufggzfelh .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #yufggzfelh .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #yufggzfelh .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #yufggzfelh .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #yufggzfelh .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #yufggzfelh .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #yufggzfelh .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #yufggzfelh .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #yufggzfelh .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #yufggzfelh .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #yufggzfelh .gt_footnotes {
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
#> #yufggzfelh .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #yufggzfelh .gt_sourcenotes {
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
#> #yufggzfelh .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #yufggzfelh .gt_left {
#>   text-align: left;
#> }
#> 
#> #yufggzfelh .gt_center {
#>   text-align: center;
#> }
#> 
#> #yufggzfelh .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #yufggzfelh .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #yufggzfelh .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #yufggzfelh .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #yufggzfelh .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #yufggzfelh .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #yufggzfelh .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #yufggzfelh .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #yufggzfelh .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #yufggzfelh .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #yufggzfelh .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #yufggzfelh .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #yufggzfelh .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #yufggzfelh div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variable">Variable</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Group">Group</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n">n</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Skewness">Skewness</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Shape">Shape<span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Suggested-presentation">Suggested presentation<span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Shapiro-p">Shapiro p<span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>3</sup></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Variable" class="gt_row gt_left">mpg</td>
#> <td headers="Group" class="gt_row gt_right">1</td>
#> <td headers="n" class="gt_row gt_right">13</td>
#> <td headers="Skewness" class="gt_row gt_right">0.05</td>
#> <td headers="Shape" class="gt_row gt_left">Little/no asymmetry</td>
#> <td headers="Suggested presentation" class="gt_row gt_left">Mean (SD) reasonable</td>
#> <td headers="Shapiro p" class="gt_row gt_right">0.536</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Group" class="gt_row gt_right">0</td>
#> <td headers="n" class="gt_row gt_right">19</td>
#> <td headers="Skewness" class="gt_row gt_right">0.01</td>
#> <td headers="Shape" class="gt_row gt_left">Little/no asymmetry</td>
#> <td headers="Suggested presentation" class="gt_row gt_left"></td>
#> <td headers="Shapiro p" class="gt_row gt_right">0.899</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">wt</td>
#> <td headers="Group" class="gt_row gt_right">1</td>
#> <td headers="n" class="gt_row gt_right">13</td>
#> <td headers="Skewness" class="gt_row gt_right">0.21</td>
#> <td headers="Shape" class="gt_row gt_left">Little/no asymmetry</td>
#> <td headers="Suggested presentation" class="gt_row gt_left">Review mean (SD) and median (IQR)</td>
#> <td headers="Shapiro p" class="gt_row gt_right">0.909</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Group" class="gt_row gt_right">0</td>
#> <td headers="n" class="gt_row gt_right">19</td>
#> <td headers="Skewness" class="gt_row gt_right">0.98</td>
#> <td headers="Shape" class="gt_row gt_left">Some right asymmetry</td>
#> <td headers="Suggested presentation" class="gt_row gt_left"></td>
#> <td headers="Shapiro p" class="gt_row gt_right">0.003</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="7"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> Shape categories use absolute sample skewness: little/no asymmetry &lt; 0.50; some asymmetry 0.50 to &lt; 1.00; marked skew &gt;= 1.00. They are descriptive guidance, not formal classifications.</td>
#>     </tr>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="7"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span> Suggested summaries are intended for descriptive reporting only and should not be used alone to determine inferential statistical methods. For grouped data, the suggested presentation applies to all groups of each variable.</td>
#>     </tr>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="7"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>3</sup></span> Shapiro-Wilk is sensitive to sample size. Interpretation should consider skewness, graphical assessment, sample size and subject-matter knowledge.</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
assess_distribution(mtcars, vars = "mpg", normality_test = FALSE)
#> <div id="kpkbjkhrvv" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#kpkbjkhrvv table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #kpkbjkhrvv thead, #kpkbjkhrvv tbody, #kpkbjkhrvv tfoot, #kpkbjkhrvv tr, #kpkbjkhrvv td, #kpkbjkhrvv th {
#>   border-style: none;
#> }
#> 
#> #kpkbjkhrvv p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #kpkbjkhrvv .gt_table {
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
#> #kpkbjkhrvv .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #kpkbjkhrvv .gt_title {
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
#> #kpkbjkhrvv .gt_subtitle {
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
#> #kpkbjkhrvv .gt_heading {
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
#> #kpkbjkhrvv .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #kpkbjkhrvv .gt_col_headings {
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
#> #kpkbjkhrvv .gt_col_heading {
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
#> #kpkbjkhrvv .gt_column_spanner_outer {
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
#> #kpkbjkhrvv .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #kpkbjkhrvv .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #kpkbjkhrvv .gt_column_spanner {
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
#> #kpkbjkhrvv .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #kpkbjkhrvv .gt_group_heading {
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
#> #kpkbjkhrvv .gt_empty_group_heading {
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
#> #kpkbjkhrvv .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #kpkbjkhrvv .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #kpkbjkhrvv .gt_row {
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
#> #kpkbjkhrvv .gt_stub {
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
#> #kpkbjkhrvv .gt_stub_row_group {
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
#> #kpkbjkhrvv .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #kpkbjkhrvv .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #kpkbjkhrvv .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #kpkbjkhrvv .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #kpkbjkhrvv .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #kpkbjkhrvv .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #kpkbjkhrvv .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #kpkbjkhrvv .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #kpkbjkhrvv .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #kpkbjkhrvv .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #kpkbjkhrvv .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #kpkbjkhrvv .gt_footnotes {
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
#> #kpkbjkhrvv .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #kpkbjkhrvv .gt_sourcenotes {
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
#> #kpkbjkhrvv .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #kpkbjkhrvv .gt_left {
#>   text-align: left;
#> }
#> 
#> #kpkbjkhrvv .gt_center {
#>   text-align: center;
#> }
#> 
#> #kpkbjkhrvv .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #kpkbjkhrvv .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #kpkbjkhrvv .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #kpkbjkhrvv .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #kpkbjkhrvv .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #kpkbjkhrvv .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #kpkbjkhrvv .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #kpkbjkhrvv .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #kpkbjkhrvv .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #kpkbjkhrvv .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #kpkbjkhrvv .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #kpkbjkhrvv .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #kpkbjkhrvv .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #kpkbjkhrvv div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variable">Variable</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n">n</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Skewness">Skewness</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Shape">Shape<span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Suggested-presentation">Suggested presentation<span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Variable" class="gt_row gt_left">mpg</td>
#> <td headers="n" class="gt_row gt_right">32</td>
#> <td headers="Skewness" class="gt_row gt_right">0.61</td>
#> <td headers="Shape" class="gt_row gt_left">Some right asymmetry</td>
#> <td headers="Suggested presentation" class="gt_row gt_left">Review mean (SD) and median (IQR)</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="5"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> Shape categories use absolute sample skewness: little/no asymmetry &lt; 0.50; some asymmetry 0.50 to &lt; 1.00; marked skew &gt;= 1.00. They are descriptive guidance, not formal classifications.</td>
#>     </tr>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="5"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>2</sup></span> Suggested summaries are intended for descriptive reporting only and should not be used alone to determine inferential statistical methods.</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
assess_distribution(mtcars, vars = c("mpg", "wt"), plots = TRUE)$plots
#> $mpg
#> $mpg$histogram

#> 
#> $mpg$density

#> 
#> $mpg$qq

#> 
#> $mpg$boxplot

#> 
#> 
#> $wt
#> $wt$histogram

#> 
#> $wt$density

#> 
#> $wt$qq

#> 
#> $wt$boxplot

#> 
#> 
```
