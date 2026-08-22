# Three-arm clinical trial teaching data

Simulated data for demonstrating independent-group analyses. The dataset
is intentionally constructed to include approximately symmetric
continuous outcomes, a right-skewed outcome, an ordinal outcome, common
and rare binary outcomes, correlated biomarkers, and person-time with
event counts.

## Usage

``` r
trial_data
```

## Format

A data frame with 180 rows and 13 variables. `arm` has three groups;
`change_score` is approximately symmetric; `hospital_days` is
right-skewed; `response` is ordered; `rare_event` is sparse; and
`followup_years` with `infection_events` supports rate examples.

## Examples

``` r
compare_groups(trial_data, variable = change_score, group = arm)
compare_groups(trial_data, variable = hospital_days, group = arm)
compare_groups(trial_data, variable = rare_event, group = arm)
```
