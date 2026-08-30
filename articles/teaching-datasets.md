# Teaching datasets

## Built-in teaching datasets

gtstats includes five labelled datasets. They make tutorials, classroom
material, peer feedback, and reproducible examples work without another
package. They are examples for learning, not data for clinical
decision-making.

``` r

data(
  "birthwt", "trial_data", "paired_data", "outbreak_data",
  "surveillance_data", package = "gtstats"
)
```

| Dataset | Design | Main teaching use | Automatic branches demonstrated |
|----|----|----|----|
| `birthwt` | Real observational low-birth-weight study; 189 births | Table 1, data understanding, binary and multi-level categorical data, 2x2 epidemiology | Welch t / Wilcoxon, chi-square / Fisher, RR/OR/RD |
| `trial_data` | Synthetic three-arm trial; 180 participants | Independent groups, ordinal outcomes, correlation, rates | Welch ANOVA, Kruskal-Wallis, chi-square, Fisher exact |
| `paired_data` | Synthetic long-format follow-up; 90 complete pairs | Before/after or matched analysis | paired t-test, Wilcoxon signed-rank, McNemar |
| `outbreak_data` | Real CDC Oswego foodborne-outbreak line list; 75 interviews | Attack rates from individual-level exposure and illness data | line-list [`epi_table()`](https://gtstats.thinkdenominator.com/reference/epi_table.md) route, Fisher/chi-square, RR/OR/RD |
| `surveillance_data` | Real archived CDC weekly hospital surveillance; 808 health service areas | Rates from aggregate counts and population denominators | aggregate [`epi_table()`](https://gtstats.thinkdenominator.com/reference/epi_table.md) route and exact Poisson CIs |

### `birthwt`: real clinical teaching data

`birthwt` is a labelled, analysis-ready version of the low birth weight
data reported by Hosmer and Lemeshow. It has readable factors for
outcome, smoking, hypertension, uterine irritability, maternal race, and
prior premature labour. `antenatal_visits` is explicitly ordinal.
Original numeric measures such as maternal age, maternal weight, and
birth weight remain numeric.

``` r

describe_data(birthwt)

summary_table(
  birthwt,
  by = low,
  include = c(age, lwt, race, smoke, previous_preterm),
  overall = TRUE
) |>
  add_p()

crosstabs(birthwt, row = smoke, col = low, percent = c("row", "column"))
```

### `trial_data`: independent groups and rates

The synthetic trial has three treatment arms. Its variables were
designed for teaching rather than to mimic a specific disease:
`change_score` is approximately symmetric, `hospital_days` is
right-skewed, `response` is ordinal, and `rare_event` produces sparse
cells. It also contains correlated biomarkers and person-time with
infection-event counts.

``` r

# Parametric three-group example
compare_groups(trial_data, variable = change_score, group = arm)

# Non-parametric three-group example
compare_groups(trial_data, variable = hospital_days, group = arm)

# Sparse categorical example
compare_groups(trial_data, variable = rare_event, group = arm)

correlation(trial_data, x = biomarker_a, y = biomarker_b)
rate_stats(
  trial_data, event = infection_events, time = followup_years,
  by = arm, time_label = "person-years"
)
```

### `paired_data`: repeated measurements

`paired_data` is in long format: each `id` has a Baseline and Follow-up
row. Use `paired = TRUE` and supply `id`. Its continuous variables
deliberately demonstrate both paired parametric and rank-based choices;
the binary symptom variable demonstrates McNemar’s test.

``` r

compare_groups(
  paired_data, variable = pain_score, group = visit,
  paired = TRUE, id = id
)

compare_groups(
  paired_data, variable = days_off_work, group = visit,
  paired = TRUE, id = id
)

compare_groups(
  paired_data, variable = symptom_present, group = visit,
  paired = TRUE, id = id
)
```

### `outbreak_data`: line-list outbreak analysis

`outbreak_data` contains the 75 interview records from CDC’s classic
Oswego church-supper investigation. The observations are unchanged;
gtstats only uses beginner-friendly variable names, `Yes`/`No` factors,
and labels. This example estimates illness attack rates among people who
did and did not eat vanilla ice cream, with an association test and 2x2
effect estimates.

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

### `surveillance_data`: aggregate surveillance rates

`surveillance_data` is an archived CDC extract for the report dated 12
January 2024. Each row is one health service area with an admission
count and population denominator. Two areas have insufficient admission
data; remove those rows explicitly before calculating rates. Because
`admission_level` is derived from the published rate, this teaching
example is descriptive and does not request a p-value.

``` r

complete_surveillance <- subset(surveillance_data, !is.na(admissions))

epi_table(
  complete_surveillance,
  numerator = admissions,
  denominator = population,
  label = admission_level,
  measure = "incidence_rate",
  multiplier = 100000
)
```

The result is a weekly hospital-admission rate per 100,000 population.
These archived provisional data demonstrate the workflow; they must not
be presented as current surveillance.

### Provenance and reuse

Both real epidemiology datasets are traceable to CDC. The surveillance
metadata identifies the source as a US Government work. CDC states that
most agency material is public domain, while requiring attribution and a
non-endorsement statement. CDC supplied the source material and does not
endorse gtstats; the original material is available without charge from
CDC. See the package dataset help pages for source links and the exact
transformations.

### Transparency note

The synthetic dataset structures are fixed and tested. If the automatic
test selection changes unexpectedly, it is a package regression—not a
random data change. Inspect `result$method$selection_rule`,
`diagnostics_stats(result)`, and `denominators_stats(result)` to see the
decision behind any example.
