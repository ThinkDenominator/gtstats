# Convert an already summarised data frame into a publication table

Wrap a data frame or tibble containing values that have already been
calculated so it can be rendered, styled, and exported with gtstats. No
descriptive statistics, confidence intervals, or p-values are calculated
or checked by this function.

## Usage

``` r
as_stats_table(data, notes = NULL)
```

## Arguments

- data:

  A data frame or tibble containing one row per intended table row.

- notes:

  Optional character vector of explanatory notes to display below the
  table.

## Value

A `gt_data_table` object. Use
[`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md),
[`to_flextable()`](https://gtstats.thinkdenominator.com/reference/to_flextable.md),
[`to_gt()`](https://gtstats.thinkdenominator.com/reference/to_gt.md), or
[`save_output()`](https://gtstats.thinkdenominator.com/reference/save_output.md)
to present or export it.

## Details

Use
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md)
instead when each row represents a participant or observation and
descriptive statistics still need to be calculated. Use
[`epi_table()`](https://gtstats.thinkdenominator.com/reference/epi_table.md)
when events and denominators need to be calculated from a line list or
aggregate outbreak/surveillance data.

## Examples

``` r
summarised <- mtcars |>
  dplyr::summarise(
    Cars = dplyr::n(),
    `Mean mpg` = mean(mpg),
    `Mean weight` = mean(wt)
  )

table <- as_stats_table(
  summarised,
  notes = "Values were calculated before table formatting."
)
customise_table(table, title = "Vehicle summary")


.cl-72e3bb98{}.cl-72db7dde{font-family:'DejaVu Sans';font-size:10pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-72db7df2{font-family:'DejaVu Sans';font-size:8pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-72df969e{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:3pt;padding-top:3pt;padding-left:3pt;padding-right:3pt;line-height: 1;background-color:transparent;}.cl-72dfbcd2{width:0.558in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0.75pt solid rgba(166, 166, 166, 1.00);border-left: 0.75pt solid rgba(166, 166, 166, 1.00);border-right: 0.75pt solid rgba(166, 166, 166, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-72dfbce6{width:1.028in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0.75pt solid rgba(166, 166, 166, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-72dfbce7{width:1.219in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0.75pt solid rgba(166, 166, 166, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0.75pt solid rgba(166, 166, 166, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-72dfbcf0{width:0.558in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0.75pt solid rgba(166, 166, 166, 1.00);border-left: 0.75pt solid rgba(166, 166, 166, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-72dfbcf1{width:0.558in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(166, 166, 166, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-72dfbcfa{width:1.028in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-72dfbcfb{width:1.219in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0.75pt solid rgba(166, 166, 166, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-72dfbcfc{width:0.558in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(166, 166, 166, 1.00);border-right: 0.75pt solid rgba(166, 166, 166, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-72dfbd04{width:1.028in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-72dfbd05{width:1.219in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0.75pt solid rgba(166, 166, 166, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Vehicle summary
```
