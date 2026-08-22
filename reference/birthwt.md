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
summary_table(birthwt, by = low, include = c(age, lwt, smoke), overall = TRUE)
```
