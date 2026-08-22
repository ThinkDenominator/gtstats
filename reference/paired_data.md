# Paired follow-up teaching data

Simulated long-format data for paired analyses. Each participant has a
Baseline and Follow-up record. `pain_score` supports a paired t-test
example, `days_off_work` is skewed for a signed-rank example, and
`symptom_present` supports McNemar's test.

## Usage

``` r
paired_data
```

## Format

A data frame with 180 rows (90 complete pairs) and 5 variables: `id`,
`visit`, `pain_score`, `days_off_work`, and `symptom_present`.

## Examples

``` r
compare_groups(
  paired_data, variable = pain_score, group = visit,
  paired = TRUE, id = id
)
compare_groups(
  paired_data, variable = symptom_present, group = visit,
  paired = TRUE, id = id
)
```
