## Manual real-time test: paired inferential test matrix
## Package: gtstats 1.0.0
##
## Purpose:
## Exercise every paired-data branch, including identifier alignment,
## distribution checks on within-pair differences and expected validation errors.
##
## Effect-size expectations:
## - Paired t-test: paired Hedges' g with a large-sample CI.
## - Signed-rank test: matched rank-biserial r without an invented CI.
## - Direction is the first displayed occasion minus the second.
## - McNemar has no default effect size; use a dedicated paired-binary measure
##   only when the clinical estimand has been specified.


## 0. Setup -------------------------------------------------------------------

## During development: devtools::load_all(".")
library(gtstats)


## 1. Paired t-test selected automatically ------------------------------------

## Indication: compare two continuous measurements from the same participants.
## Default/check: gtstats aligns records by id. Distribution guidance is applied
## to within-pair differences, not to each occasion separately.
## Assumptions to confirm: pairs are correct, participants are independent of
## one another, and differences have no dominating outliers.
## Expected: "Paired t-test", paired Hedges' g with CI, and the number of
## complete pairs in $notes.
participant_id <- seq_len(20)
baseline <- exp(seq(0, 4, length.out = 20))
change <- rep(c(-2, -1, 0, 1, 2), 4)

paired_symmetric <- data.frame(
  participant_id = rep(participant_id, 2),
  visit = factor(
    rep(c("Baseline", "Follow-up"), each = 20),
    levels = c("Baseline", "Follow-up")
  ),
  score = c(baseline, baseline + change)
)

paired_t_auto <- compare_groups(
  paired_symmetric,
  variable = score,
  group = visit,
  paired = TRUE,
  id = participant_id,
  effect_size = TRUE
)

paired_t_auto
paired_t_auto$inferential
paired_t_auto$assumptions
paired_t_auto$diagnostics
paired_t_auto$notes


## 2. Explicit paired t-test --------------------------------------------------

paired_t_explicit <- compare_groups(
  paired_symmetric,
  variable = score,
  group = visit,
  paired = TRUE,
  id = participant_id,
  test = "t_test",
  effect_size = TRUE,
  conf.level = 0.90
)

paired_t_explicit$inferential
tbl_stats(paired_t_explicit, title = "Explicit paired t-test")


## 3. Automatic Wilcoxon signed-rank -----------------------------------------

## Indication: paired continuous/ordinal measurements with skewed differences.
## Default/check: one extreme within-person change makes the difference
## distribution skewed.
## Assumptions to confirm: correct pairing and roughly symmetric non-zero
## differences for the conventional signed-rank interpretation.
## Expected: "Wilcoxon signed-rank test".
skewed_change <- c(rep(0:3, length.out = 19), 100)
paired_skewed <- paired_symmetric
paired_skewed$score[paired_skewed$visit == "Follow-up"] <-
  baseline + skewed_change

paired_wilcox_auto <- compare_groups(
  paired_skewed,
  variable = score,
  group = visit,
  paired = TRUE,
  id = participant_id,
  effect_size = TRUE
)

paired_wilcox_auto
paired_wilcox_auto$inferential
paired_wilcox_auto$notes


## 4. Explicit signed-rank test ----------------------------------------------

paired_wilcox_explicit <- compare_groups(
  paired_symmetric,
  variable = score,
  group = visit,
  paired = TRUE,
  id = participant_id,
  test = "wilcox",
  effect_size = TRUE
)

paired_wilcox_explicit$inferential


## 5. Paired binary outcome: automatic McNemar -------------------------------

## Indication: compare paired binary proportions before and after.
## Default/check: gtstats aligns binary outcomes by participant id and builds
## the paired 2x2 table.
## Assumptions to confirm: the same participants and the same binary definition
## are used at both occasions.
## Expected: "McNemar test".
paired_binary <- data.frame(
  participant_id = rep(seq_len(30), 2),
  visit = factor(
    rep(c("Baseline", "Follow-up"), each = 30),
    levels = c("Baseline", "Follow-up")
  ),
  positive = factor(c(
    rep(c("No", "Yes"), c(20, 10)),
    rep(c("No", "Yes"), c(14, 16))
  ), levels = c("No", "Yes"))
)

mcnemar_auto <- compare_groups(
  paired_binary,
  variable = positive,
  group = visit,
  paired = TRUE,
  id = participant_id
)

mcnemar_auto
mcnemar_auto$inferential
mcnemar_auto$notes


## 6. Explicit McNemar override ----------------------------------------------

mcnemar_corrected <- compare_groups(
  paired_binary,
  variable = positive,
  group = visit,
  paired = TRUE,
  id = participant_id,
  test = "mcnemar"
)

mcnemar_corrected$inferential


## 7. Paired p-values in summary_table() --------------------------------------

paired_table <- summary_table(
  paired_symmetric,
  by = visit,
  overall = TRUE
) |>
  add_summary(vars = score) |>
  add_p(
    paired = TRUE,
    id = participant_id
  )

paired_table
paired_table$pvalue_method_footnotes
paired_table$assumption_notes


## 8. Incomplete pairs --------------------------------------------------------

## Check: only identifiers observed in both groups contribute to a paired test.
## Expected: the notes report 18 complete pairs.
paired_incomplete <- paired_symmetric[
  !(paired_symmetric$participant_id %in% c(3, 17) &
      paired_symmetric$visit == "Follow-up"),
]

incomplete_pairs <- compare_groups(
  paired_incomplete,
  variable = score,
  group = visit,
  paired = TRUE,
  id = participant_id
)

incomplete_pairs
incomplete_pairs$notes


## 9. Expected validation errors ---------------------------------------------

## These calls are intentionally wrapped in try() so reviewers can continue.

## Missing id:
## Expected error: "`id` is required when `paired = TRUE`."
try(
  compare_groups(
    paired_symmetric,
    variable = score,
    group = visit,
    paired = TRUE
  )
)

## Duplicate participant within the same visit:
## Expected error: each id may occur at most once in each group.
paired_duplicate <- rbind(paired_symmetric, paired_symmetric[1, ])
try(
  compare_groups(
    paired_duplicate,
    variable = score,
    group = visit,
    paired = TRUE,
    id = participant_id
  )
)

## More than two paired occasions:
## Expected error: paired analyses require exactly two groups.
paired_three_visits <- rbind(
  paired_symmetric,
  data.frame(
    participant_id = participant_id,
    visit = factor(
      rep("Month 6", 20),
      levels = c("Baseline", "Follow-up", "Month 6")
    ),
    score = baseline + 2
  )
)
paired_three_visits$visit <- factor(as.character(paired_three_visits$visit))
try(
  compare_groups(
    paired_three_visits,
    variable = score,
    group = visit,
    paired = TRUE,
    id = participant_id
  )
)


## 10. Standalone paired effect size ------------------------------------------

## Paired Hedges' g uses complete within-person differences and follows the
## declared factor order: Baseline minus Follow-up.
paired_effect <- effect_size(
  paired_incomplete,
  outcome = score,
  by = visit,
  paired = TRUE,
  id = participant_id,
  method = "hedges_g"
)

paired_effect
paired_effect$summary
paired_effect$denominators
paired_effect$notes

## The matched rank-biserial correlation is available explicitly when the
## paired comparison is rank-based.
paired_rank_effect <- effect_size(
  paired_skewed,
  outcome = score,
  by = visit,
  paired = TRUE,
  id = participant_id,
  method = "rank_biserial"
)
paired_rank_effect

## Expected validation error: paired analyses require an id.
try(effect_size(
  paired_symmetric,
  outcome = score,
  by = visit,
  paired = TRUE
))

## FEEDBACK:
## - Is the number of complete pairs easy to audit?
## - Is the contrast direction clear?
## - Are paired Hedges' g and matched rank-biserial named clearly?


## 11. Reviewer notes ---------------------------------------------------------

## Confirm:
## 1. Pairing is visibly based on id rather than row order.
## 2. The number of complete pairs is reported.
## 3. Automatic distribution guidance refers to within-pair differences.
## 4. McNemar is not confused with an independent chi-square test.
## 5. Validation errors explain exactly how to repair the data.
