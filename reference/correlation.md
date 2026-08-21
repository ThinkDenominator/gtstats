# Correlation analysis for one pair or several continuous variables

`correlation()` analyses either one prespecified pair (`x` and `y`) or a
correlation matrix (`vars`). Matrix mode uses one method throughout,
retains pairwise sample sizes and inferential results in `$summary`, and
prints a compact publication-ready matrix. Use
[`plot_correlation()`](https://gtstats.thinkdenominator.com/reference/plot_correlation.md)
for a shaded heatmap of a matrix result.

## Usage

``` r
correlation(
  data,
  x = NULL,
  y = NULL,
  method = c("auto", "pearson", "spearman"),
  conf.level = 0.95,
  digits = 2,
  vars = NULL,
  triangle = c("lower", "upper", "full"),
  order = c("input", "alphabetical", "cluster"),
  show_diagonal = TRUE,
  display = c("estimate", "estimate_p", "estimate_n", "estimate_p_n", "estimate_ci"),
  shade = TRUE,
  missing = c("pairwise"),
  adjust = c("none", "holm", "bonferroni", "BH"),
  format = c("table", "tibble")
)
```

## Arguments

- data:

  A data frame.

- x, y:

  Two continuous variables supplied as bare names or character strings.
  Omit these when using `vars`.

- method:

  Correlation method: `"auto"`, `"pearson"`, or `"spearman"`.

- conf.level:

  Confidence level for intervals.

- digits:

  Number of decimal places used for display.

- vars:

  Optional vector of at least two continuous variables, supplied as
  `c(age, weight, outcome)` or a character vector.

- triangle:

  Matrix display: `"lower"`, `"upper"`, or `"full"`.

- order:

  Variable order in matrix mode: `"input"` preserves the order in
  `vars`, `"alphabetical"` orders display labels, and `"cluster"` places
  variables with similar absolute correlation patterns together.

- show_diagonal:

  Logical; show self-correlations on the diagonal.

- display:

  Matrix cell content: correlation `"estimate"`, `"estimate_p"`,
  `"estimate_n"`, `"estimate_p_n"`, or `"estimate_ci"`. Confidence
  intervals unavailable from the selected method are shown as an em dash
  in the tidy result and omitted from the matrix cell.

- shade:

  Logical; apply coefficient-based shading to the publication matrix.
  This affects rendering, not `$summary`.

- missing:

  Matrix missing-data rule. Currently `"pairwise"`: each coefficient
  uses all complete finite observations for that pair.

- adjust:

  Multiplicity adjustment for matrix p-values: `"none"`, `"holm"`,
  `"bonferroni"`, or `"BH"`.

- format:

  Output format: `"table"` (default) or a plain console `"tibble"`.

## Value

A `gt_correlation` object. Matrix results additionally inherit from
`gt_correlation_matrix` and contain a tidy pair-level `$summary`.

## Details

In automatic matrix mode, Pearson correlation is used only when every
selected variable has absolute sample skewness below 1; otherwise
Spearman correlation is used throughout. This is transparent descriptive
guidance, not proof of linearity or monotonicity. Inspect the matrix
heatmap and relevant pairwise plots before interpretation.

## Examples

``` r
correlation(mtcars, x = mpg, y = wt)
#> <div id="jtxhemwkar" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#jtxhemwkar table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #jtxhemwkar thead, #jtxhemwkar tbody, #jtxhemwkar tfoot, #jtxhemwkar tr, #jtxhemwkar td, #jtxhemwkar th {
#>   border-style: none;
#> }
#> 
#> #jtxhemwkar p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #jtxhemwkar .gt_table {
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
#> #jtxhemwkar .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #jtxhemwkar .gt_title {
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
#> #jtxhemwkar .gt_subtitle {
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
#> #jtxhemwkar .gt_heading {
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
#> #jtxhemwkar .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jtxhemwkar .gt_col_headings {
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
#> #jtxhemwkar .gt_col_heading {
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
#> #jtxhemwkar .gt_column_spanner_outer {
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
#> #jtxhemwkar .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #jtxhemwkar .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #jtxhemwkar .gt_column_spanner {
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
#> #jtxhemwkar .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #jtxhemwkar .gt_group_heading {
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
#> #jtxhemwkar .gt_empty_group_heading {
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
#> #jtxhemwkar .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #jtxhemwkar .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #jtxhemwkar .gt_row {
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
#> #jtxhemwkar .gt_stub {
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
#> #jtxhemwkar .gt_stub_row_group {
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
#> #jtxhemwkar .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #jtxhemwkar .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #jtxhemwkar .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jtxhemwkar .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #jtxhemwkar .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #jtxhemwkar .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jtxhemwkar .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jtxhemwkar .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #jtxhemwkar .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jtxhemwkar .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #jtxhemwkar .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jtxhemwkar .gt_footnotes {
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
#> #jtxhemwkar .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jtxhemwkar .gt_sourcenotes {
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
#> #jtxhemwkar .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jtxhemwkar .gt_left {
#>   text-align: left;
#> }
#> 
#> #jtxhemwkar .gt_center {
#>   text-align: center;
#> }
#> 
#> #jtxhemwkar .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #jtxhemwkar .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #jtxhemwkar .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #jtxhemwkar .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #jtxhemwkar .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #jtxhemwkar .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #jtxhemwkar .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #jtxhemwkar .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #jtxhemwkar .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #jtxhemwkar .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #jtxhemwkar .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #jtxhemwkar .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #jtxhemwkar .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #jtxhemwkar div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variables">Variables</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="n">n</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Correlation-(95%-CI)">Correlation (95% CI)<span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="p-value">p-value</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Variables" class="gt_row gt_left">mpg and wt</td>
#> <td headers="n" class="gt_row gt_right">32</td>
#> <td headers="Correlation (95% CI)" class="gt_row gt_left">-0.87 (-0.93 to -0.74)</td>
#> <td headers="p-value" class="gt_row gt_left">&lt;0.01</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="4"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> Pearson correlation</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
correlation(mtcars, vars = c(mpg, disp, hp, wt))
#> <div id="nihsrtesaa" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#nihsrtesaa table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #nihsrtesaa thead, #nihsrtesaa tbody, #nihsrtesaa tfoot, #nihsrtesaa tr, #nihsrtesaa td, #nihsrtesaa th {
#>   border-style: none;
#> }
#> 
#> #nihsrtesaa p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #nihsrtesaa .gt_table {
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
#> #nihsrtesaa .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #nihsrtesaa .gt_title {
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
#> #nihsrtesaa .gt_subtitle {
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
#> #nihsrtesaa .gt_heading {
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
#> #nihsrtesaa .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #nihsrtesaa .gt_col_headings {
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
#> #nihsrtesaa .gt_col_heading {
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
#> #nihsrtesaa .gt_column_spanner_outer {
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
#> #nihsrtesaa .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #nihsrtesaa .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #nihsrtesaa .gt_column_spanner {
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
#> #nihsrtesaa .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #nihsrtesaa .gt_group_heading {
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
#> #nihsrtesaa .gt_empty_group_heading {
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
#> #nihsrtesaa .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #nihsrtesaa .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #nihsrtesaa .gt_row {
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
#> #nihsrtesaa .gt_stub {
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
#> #nihsrtesaa .gt_stub_row_group {
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
#> #nihsrtesaa .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #nihsrtesaa .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #nihsrtesaa .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #nihsrtesaa .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #nihsrtesaa .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #nihsrtesaa .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #nihsrtesaa .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #nihsrtesaa .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #nihsrtesaa .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #nihsrtesaa .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #nihsrtesaa .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #nihsrtesaa .gt_footnotes {
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
#> #nihsrtesaa .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #nihsrtesaa .gt_sourcenotes {
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
#> #nihsrtesaa .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #nihsrtesaa .gt_left {
#>   text-align: left;
#> }
#> 
#> #nihsrtesaa .gt_center {
#>   text-align: center;
#> }
#> 
#> #nihsrtesaa .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #nihsrtesaa .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #nihsrtesaa .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #nihsrtesaa .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #nihsrtesaa .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #nihsrtesaa .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #nihsrtesaa .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #nihsrtesaa .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #nihsrtesaa .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #nihsrtesaa .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #nihsrtesaa .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #nihsrtesaa .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #nihsrtesaa .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #nihsrtesaa div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variable">Variable</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="mpg">mpg</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="disp">disp</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="hp">hp</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="wt">wt</th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Variable" class="gt_row gt_left">mpg</td>
#> <td headers="mpg" class="gt_row gt_right" style="background-color: #F2F2F2;">1.00</td>
#> <td headers="disp" class="gt_row gt_right"></td>
#> <td headers="hp" class="gt_row gt_right"></td>
#> <td headers="wt" class="gt_row gt_right"></td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">disp</td>
#> <td headers="mpg" class="gt_row gt_right" style="background-color: #547591;">-0.85</td>
#> <td headers="disp" class="gt_row gt_right" style="background-color: #F2F2F2;">1.00</td>
#> <td headers="hp" class="gt_row gt_right"></td>
#> <td headers="wt" class="gt_row gt_right"></td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">hp</td>
#> <td headers="mpg" class="gt_row gt_right" style="background-color: #62809A;">-0.78</td>
#> <td headers="disp" class="gt_row gt_right" style="background-color: #CD8B7D;">0.79</td>
#> <td headers="hp" class="gt_row gt_right" style="background-color: #F2F2F2;">1.00</td>
#> <td headers="wt" class="gt_row gt_right"></td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">wt</td>
#> <td headers="mpg" class="gt_row gt_right" style="background-color: #50728E;">-0.87</td>
#> <td headers="disp" class="gt_row gt_right" style="background-color: #C77C6D;">0.89</td>
#> <td headers="hp" class="gt_row gt_right" style="background-color: #D59E93;">0.66</td>
#> <td headers="wt" class="gt_row gt_right" style="background-color: #F2F2F2;">1.00</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="5">All selected variables had absolute sample skewness below 1; Pearson was used throughout.</td>
#>     </tr>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="5">Pairwise complete finite observations are used; pair-specific N and p-values remain in `$summary`.</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
plot_correlation(correlation(mtcars, vars = c(mpg, disp, hp, wt)))
```
