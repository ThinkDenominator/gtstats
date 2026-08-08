# Low birth weight data

A labelled and analysis-ready version of the low birth weight study
data. It contains 189 observations and is derived from the dataset
distributed in `MASS`, originally reported by Hosmer and Lemeshow.
Numeric clinical codes have been converted to readable factors;
`antenatal_visits` is an ordered factor and the original numeric
variables are retained.

## Usage

``` r
birthwt
```

## Format

A data frame with 189 rows and 12 variables:

- low:

  Birth-weight outcome: Normal birth weight or Low birth weight.

- age:

  Maternal age in years.

- lwt:

  Maternal weight in pounds.

- race:

  Maternal race.

- smoke:

  Smoking during pregnancy.

- ptl:

  Number of previous premature labours.

- ht:

  History of hypertension.

- ui:

  Uterine irritability.

- ftv:

  Number of first-trimester physician visits.

- bwt:

  Birth weight in grams.

- previous_preterm:

  Any previous premature labour.

- antenatal_visits:

  Ordered visit category.

## Source

Hosmer, D. W. and Lemeshow, S. (1989). *Applied Logistic Regression*.
Derived from
[`MASS::birthwt`](https://rdrr.io/pkg/MASS/man/birthwt.html).

## Examples

``` r
describe_data(birthwt)
#> <div id="jbjgwtlmpw" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#jbjgwtlmpw table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #jbjgwtlmpw thead, #jbjgwtlmpw tbody, #jbjgwtlmpw tfoot, #jbjgwtlmpw tr, #jbjgwtlmpw td, #jbjgwtlmpw th {
#>   border-style: none;
#> }
#> 
#> #jbjgwtlmpw p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #jbjgwtlmpw .gt_table {
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
#> #jbjgwtlmpw .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #jbjgwtlmpw .gt_title {
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
#> #jbjgwtlmpw .gt_subtitle {
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
#> #jbjgwtlmpw .gt_heading {
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
#> #jbjgwtlmpw .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jbjgwtlmpw .gt_col_headings {
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
#> #jbjgwtlmpw .gt_col_heading {
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
#> #jbjgwtlmpw .gt_column_spanner_outer {
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
#> #jbjgwtlmpw .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #jbjgwtlmpw .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #jbjgwtlmpw .gt_column_spanner {
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
#> #jbjgwtlmpw .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #jbjgwtlmpw .gt_group_heading {
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
#> #jbjgwtlmpw .gt_empty_group_heading {
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
#> #jbjgwtlmpw .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #jbjgwtlmpw .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #jbjgwtlmpw .gt_row {
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
#> #jbjgwtlmpw .gt_stub {
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
#> #jbjgwtlmpw .gt_stub_row_group {
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
#> #jbjgwtlmpw .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #jbjgwtlmpw .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #jbjgwtlmpw .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jbjgwtlmpw .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #jbjgwtlmpw .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #jbjgwtlmpw .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jbjgwtlmpw .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jbjgwtlmpw .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #jbjgwtlmpw .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jbjgwtlmpw .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #jbjgwtlmpw .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #jbjgwtlmpw .gt_footnotes {
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
#> #jbjgwtlmpw .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jbjgwtlmpw .gt_sourcenotes {
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
#> #jbjgwtlmpw .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #jbjgwtlmpw .gt_left {
#>   text-align: left;
#> }
#> 
#> #jbjgwtlmpw .gt_center {
#>   text-align: center;
#> }
#> 
#> #jbjgwtlmpw .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #jbjgwtlmpw .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #jbjgwtlmpw .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #jbjgwtlmpw .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #jbjgwtlmpw .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #jbjgwtlmpw .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #jbjgwtlmpw .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #jbjgwtlmpw .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #jbjgwtlmpw .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #jbjgwtlmpw .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #jbjgwtlmpw .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #jbjgwtlmpw .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #jbjgwtlmpw .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #jbjgwtlmpw div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
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
#>     <tr><td headers="Variable" class="gt_row gt_left">Birth-weight outcome [low]</td>
#> <td headers="Type" class="gt_row gt_left">binary</td>
#> <td headers="Complete" class="gt_row gt_right">189/189 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">2</td>
#> <td headers="Overview" class="gt_row gt_left">Normal birth weight 130 (68.8%); Low birth weight 59 (31.2%)</td>
#> <td headers="Range / levels" class="gt_row gt_left">Normal birth weight, Low birth weight</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">Maternal age (years) [age]</td>
#> <td headers="Type" class="gt_row gt_left">continuous</td>
#> <td headers="Complete" class="gt_row gt_right">189/189 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">24</td>
#> <td headers="Overview" class="gt_row gt_left">Mean 23.24 (SD 5.30); median 23.00</td>
#> <td headers="Range / levels" class="gt_row gt_left">14.00 to 45.00</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">Maternal weight (lb) [lwt]</td>
#> <td headers="Type" class="gt_row gt_left">continuous</td>
#> <td headers="Complete" class="gt_row gt_right">189/189 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">75</td>
#> <td headers="Overview" class="gt_row gt_left">Mean 129.81 (SD 30.58); median 121.00</td>
#> <td headers="Range / levels" class="gt_row gt_left">80.00 to 250.00</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">Maternal race [race]</td>
#> <td headers="Type" class="gt_row gt_left">categorical</td>
#> <td headers="Complete" class="gt_row gt_right">189/189 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">3</td>
#> <td headers="Overview" class="gt_row gt_left">White 96 (50.8%); Other 67 (35.4%); Black 26 (13.8%)</td>
#> <td headers="Range / levels" class="gt_row gt_left">White, Black, Other</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">Smoking during pregnancy [smoke]</td>
#> <td headers="Type" class="gt_row gt_left">binary</td>
#> <td headers="Complete" class="gt_row gt_right">189/189 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">2</td>
#> <td headers="Overview" class="gt_row gt_left">No 115 (60.8%); Yes 74 (39.2%)</td>
#> <td headers="Range / levels" class="gt_row gt_left">No, Yes</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">Previous premature labours [ptl]</td>
#> <td headers="Type" class="gt_row gt_left">categorical*</td>
#> <td headers="Complete" class="gt_row gt_right">189/189 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">4</td>
#> <td headers="Overview" class="gt_row gt_left">0 159 (84.1%); 1 24 (12.7%); 2 5 ( 2.6%)</td>
#> <td headers="Range / levels" class="gt_row gt_left">0, 1, 2, 3</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">Hypertension [ht]</td>
#> <td headers="Type" class="gt_row gt_left">binary</td>
#> <td headers="Complete" class="gt_row gt_right">189/189 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">2</td>
#> <td headers="Overview" class="gt_row gt_left">No 177 (93.7%); Yes 12 ( 6.3%)</td>
#> <td headers="Range / levels" class="gt_row gt_left">No, Yes</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">Uterine irritability [ui]</td>
#> <td headers="Type" class="gt_row gt_left">binary</td>
#> <td headers="Complete" class="gt_row gt_right">189/189 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">2</td>
#> <td headers="Overview" class="gt_row gt_left">No 161 (85.2%); Yes 28 (14.8%)</td>
#> <td headers="Range / levels" class="gt_row gt_left">No, Yes</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">First-trimester visits [ftv]</td>
#> <td headers="Type" class="gt_row gt_left">continuous</td>
#> <td headers="Complete" class="gt_row gt_right">189/189 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">6</td>
#> <td headers="Overview" class="gt_row gt_left">Mean 0.79 (SD 1.06); median 0.00</td>
#> <td headers="Range / levels" class="gt_row gt_left">0.00 to 6.00</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">Birth weight (g) [bwt]</td>
#> <td headers="Type" class="gt_row gt_left">continuous</td>
#> <td headers="Complete" class="gt_row gt_right">189/189 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">131</td>
#> <td headers="Overview" class="gt_row gt_left">Mean 2944.59 (SD 729.21); median 2977.00</td>
#> <td headers="Range / levels" class="gt_row gt_left">709.00 to 4990.00</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">Previous premature labour [previous_preterm]</td>
#> <td headers="Type" class="gt_row gt_left">binary</td>
#> <td headers="Complete" class="gt_row gt_right">189/189 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">2</td>
#> <td headers="Overview" class="gt_row gt_left">No 159 (84.1%); Yes 30 (15.9%)</td>
#> <td headers="Range / levels" class="gt_row gt_left">No, Yes</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left">First-trimester visits [antenatal_visits]</td>
#> <td headers="Type" class="gt_row gt_left">ordinal</td>
#> <td headers="Complete" class="gt_row gt_right">189/189 (100.0%)</td>
#> <td headers="Unique" class="gt_row gt_right">3</td>
#> <td headers="Overview" class="gt_row gt_left">None 100 (52.9%); One 47 (24.9%); Two or more 42 (22.2%)</td>
#> <td headers="Range / levels" class="gt_row gt_left">None, One, Two or more</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_sourcenotes">
#>       <td class="gt_sourcenote" colspan="6">* Possible ordinal or count-coded variable. Confirm the intended meaning and order using the data dictionary or clinical context.</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
summary_table(birthwt, by = low, include = c(age, lwt, smoke), overall = TRUE)
#> <div id="zbijlfmzbb" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
#>   <style>#zbijlfmzbb table {
#>   font-family: system-ui;
#>   -webkit-font-smoothing: antialiased;
#>   -moz-osx-font-smoothing: grayscale;
#> }
#> 
#> #zbijlfmzbb thead, #zbijlfmzbb tbody, #zbijlfmzbb tfoot, #zbijlfmzbb tr, #zbijlfmzbb td, #zbijlfmzbb th {
#>   border-style: none;
#> }
#> 
#> #zbijlfmzbb p {
#>   margin: 0;
#>   padding: 0;
#> }
#> 
#> #zbijlfmzbb .gt_table {
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
#> #zbijlfmzbb .gt_caption {
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#> }
#> 
#> #zbijlfmzbb .gt_title {
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
#> #zbijlfmzbb .gt_subtitle {
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
#> #zbijlfmzbb .gt_heading {
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
#> #zbijlfmzbb .gt_bottom_border {
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #zbijlfmzbb .gt_col_headings {
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
#> #zbijlfmzbb .gt_col_heading {
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
#> #zbijlfmzbb .gt_column_spanner_outer {
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
#> #zbijlfmzbb .gt_column_spanner_outer:first-child {
#>   padding-left: 0;
#> }
#> 
#> #zbijlfmzbb .gt_column_spanner_outer:last-child {
#>   padding-right: 0;
#> }
#> 
#> #zbijlfmzbb .gt_column_spanner {
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
#> #zbijlfmzbb .gt_spanner_row {
#>   border-bottom-style: hidden;
#> }
#> 
#> #zbijlfmzbb .gt_group_heading {
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
#> #zbijlfmzbb .gt_empty_group_heading {
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
#> #zbijlfmzbb .gt_from_md > :first-child {
#>   margin-top: 0;
#> }
#> 
#> #zbijlfmzbb .gt_from_md > :last-child {
#>   margin-bottom: 0;
#> }
#> 
#> #zbijlfmzbb .gt_row {
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
#> #zbijlfmzbb .gt_stub {
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
#> #zbijlfmzbb .gt_stub_row_group {
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
#> #zbijlfmzbb .gt_row_group_first td {
#>   border-top-width: 2px;
#> }
#> 
#> #zbijlfmzbb .gt_row_group_first th {
#>   border-top-width: 2px;
#> }
#> 
#> #zbijlfmzbb .gt_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #zbijlfmzbb .gt_first_summary_row {
#>   border-top-style: solid;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #zbijlfmzbb .gt_first_summary_row.thick {
#>   border-top-width: 2px;
#> }
#> 
#> #zbijlfmzbb .gt_last_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #zbijlfmzbb .gt_grand_summary_row {
#>   color: #333333;
#>   background-color: #FFFFFF;
#>   text-transform: inherit;
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #zbijlfmzbb .gt_first_grand_summary_row {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-top-style: double;
#>   border-top-width: 6px;
#>   border-top-color: #D3D3D3;
#> }
#> 
#> #zbijlfmzbb .gt_last_grand_summary_row_top {
#>   padding-top: 8px;
#>   padding-bottom: 8px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#>   border-bottom-style: double;
#>   border-bottom-width: 6px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #zbijlfmzbb .gt_striped {
#>   background-color: rgba(128, 128, 128, 0.05);
#> }
#> 
#> #zbijlfmzbb .gt_table_body {
#>   border-top-style: solid;
#>   border-top-width: 2px;
#>   border-top-color: #D3D3D3;
#>   border-bottom-style: solid;
#>   border-bottom-width: 2px;
#>   border-bottom-color: #D3D3D3;
#> }
#> 
#> #zbijlfmzbb .gt_footnotes {
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
#> #zbijlfmzbb .gt_footnote {
#>   margin: 0px;
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #zbijlfmzbb .gt_sourcenotes {
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
#> #zbijlfmzbb .gt_sourcenote {
#>   font-size: 90%;
#>   padding-top: 4px;
#>   padding-bottom: 4px;
#>   padding-left: 5px;
#>   padding-right: 5px;
#> }
#> 
#> #zbijlfmzbb .gt_left {
#>   text-align: left;
#> }
#> 
#> #zbijlfmzbb .gt_center {
#>   text-align: center;
#> }
#> 
#> #zbijlfmzbb .gt_right {
#>   text-align: right;
#>   font-variant-numeric: tabular-nums;
#> }
#> 
#> #zbijlfmzbb .gt_font_normal {
#>   font-weight: normal;
#> }
#> 
#> #zbijlfmzbb .gt_font_bold {
#>   font-weight: bold;
#> }
#> 
#> #zbijlfmzbb .gt_font_italic {
#>   font-style: italic;
#> }
#> 
#> #zbijlfmzbb .gt_super {
#>   font-size: 65%;
#> }
#> 
#> #zbijlfmzbb .gt_footnote_marks {
#>   font-size: 75%;
#>   vertical-align: 0.4em;
#>   position: initial;
#> }
#> 
#> #zbijlfmzbb .gt_asterisk {
#>   font-size: 100%;
#>   vertical-align: 0;
#> }
#> 
#> #zbijlfmzbb .gt_indent_1 {
#>   text-indent: 5px;
#> }
#> 
#> #zbijlfmzbb .gt_indent_2 {
#>   text-indent: 10px;
#> }
#> 
#> #zbijlfmzbb .gt_indent_3 {
#>   text-indent: 15px;
#> }
#> 
#> #zbijlfmzbb .gt_indent_4 {
#>   text-indent: 20px;
#> }
#> 
#> #zbijlfmzbb .gt_indent_5 {
#>   text-indent: 25px;
#> }
#> 
#> #zbijlfmzbb .katex-display {
#>   display: inline-flex !important;
#>   margin-bottom: 0.75em !important;
#> }
#> 
#> #zbijlfmzbb div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
#>   height: 0px !important;
#> }
#> </style>
#>   <table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
#>   <thead>
#>     <tr class="gt_col_headings">
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Variable">Variable</th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Level"></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="Overall"><span class='gt_from_md'>Overall<br />
#> N = 189</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="low-=-Normal-birth-weight"><span class='gt_from_md'>Normal birth weight<br />
#> N = 130</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>       <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" style="font-weight: bold;" scope="col" id="low-=-Low-birth-weight"><span class='gt_from_md'>Low birth weight<br />
#> N = 59</span><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span></th>
#>     </tr>
#>   </thead>
#>   <tbody class="gt_table_body">
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">Maternal age (years)</td>
#> <td headers="Level" class="gt_row gt_left"></td>
#> <td headers="Overall" class="gt_row gt_right">23.2 (5.3)</td>
#> <td headers="low = Normal birth weight" class="gt_row gt_right">23.7 (5.6)</td>
#> <td headers="low = Low birth weight" class="gt_row gt_right">22.3 (4.5)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">Maternal weight (lb)</td>
#> <td headers="Level" class="gt_row gt_left"></td>
#> <td headers="Overall" class="gt_row gt_right">121.0 (110.0–140.0)</td>
#> <td headers="low = Normal birth weight" class="gt_row gt_right">123.5 (113.0–147.0)</td>
#> <td headers="low = Low birth weight" class="gt_row gt_right">120.0 (104.0–130.0)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left" style="font-weight: bold;">Smoking during pregnancy</td>
#> <td headers="Level" class="gt_row gt_left">  No</td>
#> <td headers="Overall" class="gt_row gt_right">115 (60.8%)</td>
#> <td headers="low = Normal birth weight" class="gt_row gt_right">86 (66.2%)</td>
#> <td headers="low = Low birth weight" class="gt_row gt_right">29 (49.2%)</td></tr>
#>     <tr><td headers="Variable" class="gt_row gt_left"></td>
#> <td headers="Level" class="gt_row gt_left">  Yes</td>
#> <td headers="Overall" class="gt_row gt_right">74 (39.2%)</td>
#> <td headers="low = Normal birth weight" class="gt_row gt_right">44 (33.8%)</td>
#> <td headers="low = Low birth weight" class="gt_row gt_right">30 (50.8%)</td></tr>
#>   </tbody>
#>   <tfoot>
#>     <tr class="gt_footnotes">
#>       <td class="gt_footnote" colspan="5"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;line-height:0;"><sup>1</sup></span> Continuous data are mean (SD) or median (IQR). Categorical data are n (%).</td>
#>     </tr>
#>   </tfoot>
#> </table>
#> </div>
```
