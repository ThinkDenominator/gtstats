# Birth-weight case study: from data to Table 1

## From raw clinical codes to a report-ready table

This case study shows the intended gtstats workflow. A maternity team
wants to describe participants by low-birth-weight outcome, understand
the continuous variables, and produce a Table 1. The example uses the
labelled birth-weight teaching dataset included with gtstats.

### 1. Prepare readable data

``` r

library(gtstats)
data("birthwt", package = "gtstats")
birthwt_data <- birthwt
```

The built-in data keep the original code names but supply readable
variable labels and factors. `antenatal_visits` is explicitly ordered;
numeric clinical codes are not silently treated as ordinal merely
because their values are ordered.

### 2. Start with the data, not a test

``` r

overview <- describe_data(birthwt_data)
to_flextable(overview)
```

| Variable | Type | Complete | Unique | Overview | Range / levels |
|----|----|----|----|----|----|
| Birth-weight outcome \[low\] | binary | 189/189 (100.0%) | 2 | Normal birth weight 130 (68.8%); Low birth weight 59 (31.2%) | Normal birth weight, Low birth weight |
| Maternal age (years) \[age\] | continuous | 189/189 (100.0%) | 24 | Mean 23.24 (SD 5.30); median 23.00 | 14.00 to 45.00 |
| Maternal weight (lb) \[lwt\] | continuous | 189/189 (100.0%) | 75 | Mean 129.81 (SD 30.58); median 121.00 | 80.00 to 250.00 |
| Maternal race \[race\] | categorical | 189/189 (100.0%) | 3 | White 96 (50.8%); Other 67 (35.4%); Black 26 (13.8%) | White, Black, Other |
| Smoking during pregnancy \[smoke\] | binary | 189/189 (100.0%) | 2 | No 115 (60.8%); Yes 74 (39.2%) | No, Yes |
| Previous premature labours \[ptl\] | categorical\* | 189/189 (100.0%) | 4 | 0 159 (84.1%); 1 24 (12.7%); 2 5 ( 2.6%) | 0, 1, 2, 3 |
| Hypertension \[ht\] | binary | 189/189 (100.0%) | 2 | No 177 (93.7%); Yes 12 ( 6.3%) | No, Yes |
| Uterine irritability \[ui\] | binary | 189/189 (100.0%) | 2 | No 161 (85.2%); Yes 28 (14.8%) | No, Yes |
| First-trimester visits \[ftv\] | continuous | 189/189 (100.0%) | 6 | Mean 0.79 (SD 1.06); median 0.00 | 0.00 to 6.00 |
| Birth weight (g) \[bwt\] | continuous | 189/189 (100.0%) | 131 | Mean 2944.59 (SD 729.21); median 2977.00 | 709.00 to 4990.00 |
| Previous premature labour \[previous_preterm\] | binary | 189/189 (100.0%) | 2 | No 159 (84.1%); Yes 30 (15.9%) | No, Yes |
| First-trimester visits \[antenatal_visits\] | ordinal | 189/189 (100.0%) | 3 | None 100 (52.9%); One 47 (24.9%); Two or more 42 (22.2%) | None, One, Two or more |
| One row is shown per selected variable. |  |  |  |  |  |
| Potential data-quality findings and interpretation prompts are stored in \`\$issues\`. |  |  |  |  |  |
| \* Possible ordinal or count-coded variable; confirm the intended meaning and order from the data dictionary or clinical context. |  |  |  |  |  |

``` r

overview$issues
#> # A tibble: 2 × 5
#>   variable label                      issue          why_flagged suggested_check
#>   <chr>    <chr>                      <chr>          <chr>       <chr>          
#> 1 ptl      Previous premature labours Sparse catego… At least o… Confirm coding…
#> 2 ftv      First-trimester visits     Low-cardinali… Only 6 dis… Confirm whethe…
```

[`describe_data()`](https://gtstats.thinkdenominator.com/reference/describe_data.md)
is the first pass. It reports type, completeness, levels or range, and a
short type-specific overview. It does not decide a statistical test.

### 3. Assess selected continuous variables

``` r

distribution <- assess_distribution(
  birthwt_data,
  vars = c(age, lwt),
  by = low
)
to_flextable(distribution)
```

| Variable | Group | n | Skewness | Shape | Suggested presentation | Shapiro p |
|----|----|----|----|----|----|----|
| Maternal age (years) | Normal birth weight | 130 | 0.74 | Some right asymmetry | Review mean (SD) and median (IQR) | \<0.001 |
|  | Low birth weight | 59 | 0.29 | Little/no asymmetry |  | 0.521 |
| Maternal weight (lb) | Normal birth weight | 130 | 1.42 | Marked right skew | Median (IQR) preferred | \<0.001 |
|  | Low birth weight | 59 | 1.06 | Marked right skew |  | \<0.001 |
| Shape categories use absolute sample skewness: little/no asymmetry \< 0.50; some asymmetry 0.50 to \< 1.00; marked skew \>= 1.00. They are descriptive guidance, not formal classifications. |  |  |  |  |  |  |
| Shapiro-Wilk is sensitive to sample size. Interpretation should consider skewness, graphical assessment, sample size and subject-matter knowledge. |  |  |  |  |  |  |
| Suggested summaries are intended for descriptive reporting only and should not be used alone to determine inferential statistical methods. |  |  |  |  |  |  |
| For grouped data, the suggested presentation applies to all groups of each variable. |  |  |  |  |  |  |

``` r

distribution$recommendations
#> # A tibble: 2 × 5
#>   variable label                overall_recommendation            reason  review
#>   <chr>    <chr>                <chr>                             <chr>   <chr> 
#> 1 age      Maternal age (years) Review mean (SD) and median (IQR) Some a… Inspe…
#> 2 lwt      Maternal weight (lb) Median (IQR) preferred            Marked… Inspe…
```

The first table retains group-specific diagnostics. The recommendation
table gives one reporting approach per variable, so the same summary can
be used across Table 1 groups. Shapiro-Wilk is supporting information,
not a rule for choosing an inferential test. Use `plots = TRUE` when a
histogram, density, Q-Q plot, and boxplot are useful.

[`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md)
provides the related spread diagnostic. It reports group SDs, variances,
and ratios without using a variance test to gatekeep Welch methods.

``` r

variance <- assess_variance(birthwt_data, vars = c(age, lwt), by = low)
to_flextable(variance)
```

| Variable | Normal birth weight | Low birth weight | Observed SD ratio | Observed variance ratio | Levene p | Interpretation |
|----|----|----|----|----|----|----|
| Maternal age (years) | n = 130; SD = 5.58; variance = 31.19 | n = 59; SD = 4.51; variance = 20.35 | 1.24 | 1.53 | 0.102 | Levene found no clear evidence of different spreads; this does not prove equal variances. |
| Maternal weight (lb) | n = 130; SD = 31.72; variance = 1006.41 | n = 59; SD = 26.56; variance = 705.40 | 1.19 | 1.43 | 0.476 | Levene found no clear evidence of different spreads; this does not prove equal variances. |
| SD and variance ratios are the largest group value divided by the smallest group value. They describe observed spread; they are not pass/fail tests. |  |  |  |  |  |  |
| For independent groups, Welch t-tests and Welch ANOVA do not require equal variances. \`assess_variance()\` does not select an inferential test and does not assess pairing or repeated-measures sphericity. |  |  |  |  |  |  |
| The displayed Levene test is median-centred (Brown-Forsythe). It is supporting information only: its p-value neither proves equal variances nor selects an inferential test. |  |  |  |  |  |  |
| Interpret spread alongside sample size, distributional shape, outliers, missingness, and the study design. |  |  |  |  |  |  |

### 4. Build Table 1

``` r

table_one <- summary_table(
  birthwt_data,
  by = low,
  include = c(age, lwt, race, smoke, ht, ui,
              previous_preterm, antenatal_visits),
  overall = "first"
) |>
  add_p()

to_flextable(table_one)
```

[TABLE]

This is already a publication-ready flextable. Use
[`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md)
to finish it for Word; use
[`to_gt()`](https://gtstats.thinkdenominator.com/reference/to_gt.md)
only when a gt object is specifically needed.

``` r

table_one |>
  customise_table(
    title = "Participant characteristics by birth-weight outcome",
    theme = "journal"
  ) |>
  save_output("table-1.docx")
```

### 5. Ask a focused inferential question

``` r

weight_comparison <- compare_groups(
  birthwt_data,
  variable = lwt,
  group = low
)
to_flextable(weight_comparison)
```

[TABLE]

``` r


# The exact automatic rule and observed inputs are retained for review.
weight_comparison$method$selection_rule
#> [1] "Two-group continuous outcome: marked skewness flagged in at least one group; selected Wilcoxon rank-sum test."
weight_comparison$method$selection_inputs
#> $distribution_guidance
#> [1] "Skewed; Skewed"
#> 
#> $skewness_flagged
#> [1] TRUE
#> 
#> $groups
#> [1] 2
#> 
#> $paired
#> [1] FALSE
#> 
#> $var_equal
#> [1] FALSE
#> 
#> $variance_assumption_source
#> [1] "User-specified; not inferred from a variance hypothesis test"
#> 
#> $observed_group_spread
#> $observed_group_spread$group_spread
#> # A tibble: 2 × 4
#>   group                   n    sd variance
#>   <chr>               <int> <dbl>    <dbl>
#> 1 Normal birth weight   130  31.7    1006.
#> 2 Low birth weight       59  26.6     705.
#> 
#> $observed_group_spread$sd_ratio
#> [1] 1.194461
#> 
#> $observed_group_spread$variance_ratio
#> [1] 1.426737

assumptions_stats(weight_comparison)
```

| Checks before reporting |  |  |  |
|----|----|----|----|
| Variable | Check before reporting | Action | Details |
| Maternal weight (lb) | Independent observations | Confirm from study design | Confirm from the study design that each observation contributes independently. |
| Maternal weight (lb) | Comparable distribution shapes | Confirm from study design | Required when interpreting the rank-based result specifically as a location or median shift. |

``` r

diagnostics_stats(weight_comparison)
```

| Diagnostics |  |  |  |  |  |
|----|----|----|----|----|----|
| Variable | Check | Result | Observed value | Reference | Interpretation |
| Maternal weight (lb) | Comparison design | independent | Independent observations | Defined by the study design | Independent comparison; confirm independence from the study design. |
| Maternal weight (lb) | Variance assumption | welch default | var_equal = FALSE | User-specified analytical assumption | Welch is the conservative default and does not require equal variances. No variance hypothesis test was used. |
| Maternal weight (lb) | Automatic test selection | Wilcoxon rank-sum test | Skewed; Skewed | No marked group-level skewness flag for parametric default | Two-group continuous outcome: marked skewness flagged in at least one group; selected Wilcoxon rank-sum test. |
| Maternal weight (lb) | Distribution guidance | rank based recommended | Skewed; Skewed | Marked absolute skewness guidance; Shapiro-Wilk is supporting information only | Assessment applied within each group. |
| Maternal weight (lb) | Observed group spread | descriptive context | Normal birth weight (n = 130): SD 31.72; variance 1006.41; Low birth weight (n = 59): SD 26.56; variance 705.40; SD ratio = 1.19; variance ratio = 1.43 | Descriptive diagnostic; no pass/fail threshold | Observed spread is descriptive only; no Levene, Bartlett, or F test was performed. \`var_equal = FALSE\` retains Welch methods as the conservative parametric auto default. |

``` r

denominators_stats(weight_comparison)
```

| Denominator audit |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|
| Variable | Level | Group | Eligible observations | Used in analysis | Missing / excluded | Numerator | Denominator | Rule |
| lwt | NA | low = Normal birth weight | 130 | 130 | 0 | NA | 130 | Non-missing outcome observations within group |
| lwt | NA | low = Low birth weight | 59 | 59 | 0 | NA | 59 | Non-missing outcome observations within group |

[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md)
answers one question at a time. The publication table is the result; the
helper functions expose the assumptions, automatic checks, and analysis
denominators for review. Use
[`effect_size()`](https://gtstats.thinkdenominator.com/reference/effect_size.md)
separately when the magnitude of the difference is the main question.

### What this workflow deliberately avoids

- Selecting a test solely from a normality p-value.
- Recommending a different descriptive summary in each group of the same
  Table 1 variable.
- Treating every numeric code as continuous or ordinal without context.
- Requiring manual formatting before a table can be shared.
