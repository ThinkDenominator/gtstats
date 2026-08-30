# Oswego foodborne-outbreak line list

A beginner-friendly copy of the 1940 Oswego County church-supper
outbreak line list supplied by the US Centers for Disease Control and
Prevention (CDC) with Epi Info. The 75 interview records are unchanged.
Variable names use snake case, `Y`/`N` values are labelled `Yes`/`No`,
and variable labels have been added.

## Usage

``` r
outbreak_data
```

## Format

A data frame with 75 rows and 21 variables. It contains participant age
and sex, illness status and onset information, meal time, and indicators
for foods and drinks consumed. `ill` is the outcome; food variables such
as `vanilla_ice_cream` can be used as exposures.

## Source

CDC Epi Info teaching data, documented in the [Epi Info 6 User's
Guide](https://stacks.cdc.gov/view/cdc/23189/cdc_23189_DS1.pdf). The
source material is a US Government work available without charge. CDC
does not endorse gtstats. See the CDC [agency materials
policy](https://www.cdc.gov/other/agencymaterials.html).

## Examples

``` r
epi_table(
  outbreak_data,
  outcomes = ill,
  by = vanilla_ice_cream,
  event = "Yes",
  measure = "attack_rate",
  p_value = TRUE,
  effects = "all"
)
```
