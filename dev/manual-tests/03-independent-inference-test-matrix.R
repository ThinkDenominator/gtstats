## Manual real-time test: independent inferential test matrix
## Package: gtstats 1.0.0
##
## Purpose:
## Exercise every independent-group inferential test and automatic-selection
## branch. Run section by section and inspect $inferential, $method and $notes.
##
## Effect-size expectations when `effect_size = TRUE`:
## - t/Welch: Hedges' g with a large-sample CI; direction is first group minus
##   second group.
## - Wilcoxon rank-sum: rank-biserial r without an invented CI.
## - ANOVA/Welch ANOVA: omega-squared; Welch is explicitly labelled an
##   approximation.
## - Kruskal-Wallis: epsilon-squared.
## - categorical tables: Cramer's V, which has magnitude but no direction.
## Conventional magnitude labels live in `$inferential`; they are deliberately
## absent from the publication table because they are not clinical thresholds.


## 0. Setup -------------------------------------------------------------------

## During development: devtools::load_all(".")
library(gtstats)


## 1. Two groups: automatic Welch t-test --------------------------------------

## Indication: compare means from two independent groups.
## Default/check: distribution guidance is on; Welch does not require equal
## variances.
## `diagnostics_stats()` also shows observed SDs, variances and their largest/
## smallest ratios. These are descriptive context only, not a variance-test
## gatekeeper and not an input to automatic test selection.
## Assumptions to confirm: independent participants, no dominating outliers,
## and a meaningful continuous outcome.
## Expected: "Welch t-test".
symmetric_data <- data.frame(
  group = factor(rep(c("Control", "Treatment"), each = 30)),
  score = c(seq(80, 109), seq(85, 114))
)

assess_distribution(symmetric_data, by= group)
auto_welch <- compare_groups(
  symmetric_data,
  variable = score,
  group = group
)

auto_welch
auto_welch$inferential
auto_welch$method
auto_welch$assumptions
auto_welch$diagnostics
diagnostics_stats(auto_welch)
auto_welch$notes

## FEEDBACK: Is it clear why Welch, rather than Student t-test, is the default?
## Do the observed-spread diagnostics make clear that there is no pass/fail
## variance rule before Welch is used?


## 2. Explicit Student t-test -------------------------------------------------

## Indication: compare two means when equal variances are justified in advance.
## Check: gtstats validates the variable/group structure but does not prove equal
## variances.
## Expected: "Student t-test".
student_t <- compare_groups(
  symmetric_data,
  variable = score,
  group = group,
  test = "t_test",
  effect_size = TRUE
)

student_t
student_t$inferential
student_t$notes


## 3. Explicit Welch t-test ---------------------------------------------------

## Indication: compare two independent means without assuming equal variances.
## Expected: Welch test, mean difference with CI and Hedges' g with CI.
welch_t <- compare_groups(
  symmetric_data,
  variable = score,
  group = group,
  test = "welch_t",
  effect_size = TRUE,
  conf.level = 0.90
)

welch_t
welch_t$inferential
tbl_stats(welch_t, title = "Explicit Welch t-test with 90% CI")


## 4. Automatic Wilcoxon rank-sum --------------------------------------------

## Indication: compare ranks across two independent groups when the continuous
## outcome is clearly skewed or ordinal.
## Default/check: distribution guidance detects the extreme right tail.
## Assumptions to confirm: independent observations. Similar distribution
## shapes are required if interpreting the result specifically as a median shift.
## Expected: "Wilcoxon rank-sum test" and rank-biserial correlation in [-1, 1].
skewed_data <- data.frame(
  group = factor(rep(c("Control", "Treatment"), each = 25)),
  days = c(1:24, 180, 2:25, 240)
)

assess_distribution(skewed_data)
auto_wilcox <- compare_groups(
  skewed_data,
  variable = days,
  group = group,
  effect_size = TRUE
)

auto_wilcox
auto_wilcox$inferential
auto_wilcox$notes


## 5. Explicit Wilcoxon override ----------------------------------------------

## Expected: explicit choices take precedence over automatic selection.
explicit_wilcox <- compare_groups(
  symmetric_data,
  variable = score,
  group = group,
  test = "wilcox",
  effect_size = TRUE
)

explicit_wilcox$inferential


## 6. Three groups: automatic Welch ANOVA -------------------------------------

## Indication: compare means across 3+ independent groups.
## Default/check: approximately symmetric outcome -> Welch ANOVA.
## Assumptions to confirm: independent observations and acceptable residual
## shape. Equal variances are not required.
## Expected: "Welch ANOVA" and approximate omega-squared.
three_group_data <- data.frame(
  clinic = factor(rep(c("North", "Central", "South"), each = 25)),
  score = c(seq(70, 94), seq(75, 99), seq(80, 104))
)
assess_distribution(three_group_data)
auto_welch_anova <- compare_groups(
  three_group_data,
  variable = score,
  group = clinic,
  effect_size = TRUE
)

auto_welch_anova
auto_welch_anova$inferential
auto_welch_anova$notes


## 7. Explicit classical ANOVA ------------------------------------------------

## Indication: compare 3+ means when similar group variances are defensible.
## Check: gtstats runs classical ANOVA but cannot confirm residual normality,
## independence or homoscedasticity from the call alone.
## Expected: "ANOVA" and omega-squared.
classic_anova <- compare_groups(
  three_group_data,
  variable = score,
  group = clinic,
  test = "anova",
  effect_size = TRUE
)

classic_anova
classic_anova$inferential
classic_anova$notes


## 8. Explicit Welch ANOVA ----------------------------------------------------

explicit_welch_anova <- compare_groups(
  three_group_data,
  variable = score,
  group = clinic,
  test = "welch_anova",
  effect_size = TRUE
)

explicit_welch_anova$inferential


## 9. Automatic Kruskal-Wallis ------------------------------------------------

## Indication: rank-based comparison across 3+ independent groups.
## Default/check: at least one group is clearly skewed.
## Assumptions to confirm: independence and similar distribution shapes for a
## location-shift interpretation.
## Expected: "Kruskal-Wallis test" and epsilon-squared.
skewed_three_group <- data.frame(
  clinic = factor(rep(c("North", "Central", "South"), each = 20)),
  days = c(1:19, 200, 2:20, 260, 3:21, 320)
)

auto_kruskal <- compare_groups(
  skewed_three_group,
  variable = days,
  group = clinic,
  effect_size = TRUE
)

auto_kruskal
auto_kruskal$inferential
auto_kruskal$notes


## 10. Explicit Kruskal-Wallis ------------------------------------------------

explicit_kruskal <- compare_groups(
  three_group_data,
  variable = score,
  group = clinic,
  test = "kruskal",
  effect_size = TRUE
)

explicit_kruskal$inferential


## 11. Automatic chi-square ---------------------------------------------------

## Indication: association between independent categorical variables.
## Default/check: expected cell counts are calculated; all must be >= 5 for
## automatic chi-square.
## Assumptions to confirm: one row per independent participant and mutually
## exclusive categories.
## Expected: "Chi-square test"; inspect the expected-count matrix.
categorical_large <- data.frame(
  arm = factor(rep(c("Control", "Treatment"), each = 100)),
  response = factor(c(
    rep("No", 60), rep("Yes", 40),
    rep("No", 45), rep("Yes", 55)
  ))
)
auto_chisq <- compare_groups(
  categorical_large,
  variable = response,
  group = arm,
  effect_size = TRUE
)

auto_chisq
auto_chisq$inferential
auto_chisq$method$expected_counts
auto_chisq$assumptions
auto_chisq$diagnostics
auto_chisq$notes


## 12. Automatic Fisher exact -------------------------------------------------

## Indication: categorical association with sparse expected counts.
## Default/check: any expected count below 5 switches automatic selection to
## Fisher's exact test.
## Expected: "Fisher's exact test" and minimum expected count in $notes.
categorical_sparse <- data.frame(
  arm = factor(c(rep("Control", 12), rep("Treatment", 8))),
  response = factor(c(rep("No", 11), "Yes", rep("No", 4), rep("Yes", 4)))
)

auto_fisher <- compare_groups(
  categorical_sparse,
  variable = response,
  group = arm,
  effect_size = TRUE
)

auto_fisher
auto_fisher$inferential
auto_fisher$method$expected_counts
auto_fisher$notes


## 13. Explicit categorical-test overrides -----------------------------------

chisq_corrected <- compare_groups(
  categorical_large,
  variable = response,
  group = arm,
  test = "chisq"
)

fisher_explicit <- compare_groups(
  categorical_large,
  variable = response,
  group = arm,
  test = "fisher"
)

chisq_corrected$inferential
fisher_explicit$inferential

## FEEDBACK: Are the expected-count rule and override sufficiently
## visible to a beginner?


## 14. add_p() mirrors the same selection matrix ------------------------------

combined_data <- data.frame(
  group = categorical_large$arm,
  symmetric = c(seq(70, 169), seq(75, 174)),
  skewed = c(1:99, 600, 2:100, 800),
  response = categorical_large$response
)

automatic_table <- summary_table(combined_data, by = group, overall = TRUE) |>
  add_summary(vars = c(symmetric, skewed, response)) |>
  add_p()

automatic_table
automatic_table$pvalue_method_footnotes
automatic_table$assumption_notes

explicit_table <- summary_table(combined_data, by = group) |>
  add_summary(vars = c(symmetric, skewed, response)) |>
  add_p(
    method = c(
      symmetric = "t_test",
      skewed = "wilcox",
      response = "fisher"
    ),
    normality_check = FALSE,
    correction = FALSE
  )

explicit_table$pvalue_method_footnotes


## 15. Standalone effect sizes ------------------------------------------------

## Question: how large is the observed difference, without repeating the full
## hypothesis-test table?
## Expected: two-group contrasts name the grouping variable and use first group
## minus second group. Positive Hedges' g/rank-biserial values therefore point
## to the first group; Cramer's V and omnibus measures have no direction.
effect_two_group <- effect_size(
  symmetric_data,
  outcome = score,
  by = group
)

## Explicit rank-based measure when a stochastic-ordering effect is wanted.
effect_rank <- effect_size(
  skewed_data,
  outcome = days,
  by = group,
  method = "rank_biserial"
)

## More than two groups: automatic omega-squared or explicit epsilon-squared.
effect_multiple_groups <- effect_size(
  three_group_data,
  outcome = score,
  by = clinic
)
effect_multiple_rank <- effect_size(
  skewed_three_group,
  outcome = days,
  by = clinic,
  method = "epsilon_squared"
)

## Categorical association: Cramer's V. RR, OR and RD deliberately remain in
## crosstabs(), where exposure and event direction are explicit.
effect_categorical <- effect_size(
  categorical_large,
  outcome = response,
  by = arm
)

## Conventional magnitude wording is opt-in and explicitly qualified.
effect_with_label <- effect_size(
  symmetric_data,
  outcome = score,
  by = group,
  interpretation = TRUE
)

effect_two_group
effect_two_group$summary
effect_two_group$inputs
effect_two_group$assumptions
effect_two_group$diagnostics
effect_two_group$denominators
effect_two_group$notes
effect_rank
effect_multiple_groups
effect_multiple_rank
effect_categorical
effect_with_label

## Expected validation errors: the method must fit the data structure.
try(effect_size(
  three_group_data,
  score,
  clinic,
  method = "hedges_g"
))
try(effect_size(
  symmetric_data,
  score,
  group,
  method = "cramers_v"
))

## FEEDBACK:
## - Is Measure / Contrast / Estimate / CI sufficient for publication?
## - Is the direction of two-group effects unambiguous?
## - Is it clear why categorical risk measures are not duplicated here?
## - Should conventional magnitude labels remain opt-in?


## 16. Reviewer notes ---------------------------------------------------------

## Confirm:
## 1. Every result states the selected test and why it was selected.
## 2. Expected counts are visible for categorical automatic selection.
## 3. Rank-based tests do not claim automatically to be tests of medians.
## 4. Welch tests are the parametric defaults.
## 5. Explicit choices override automatic guidance.
## 6. Independence is described as a study-design assumption, not a data check.
