test_that("compare_groups() works for 2-group continuous outcome with default auto test", {
  res <- compare_groups(mtcars, variable = mpg, group = am)

  expect_s3_class(res, "gt_compare")
  expect_true(is.list(res))
  expect_true(all(c("descriptives", "inferential", "table", "inputs", "notes") %in% names(res)))

  expect_equal(res$inputs$variable, "mpg")
  expect_equal(res$inputs$group, "am")
  expect_equal(res$inferential$test_used[1], "Welch t-test")
  expect_true(is.numeric(res$inferential$p_value[1]))
  expect_equal(nrow(res$table), 1)
  expect_match(res$method$selection_rule, "Two-group continuous outcome")
  expect_equal(res$method$test_requested, "auto")
  expect_equal(res$method$test_selected, "Welch t-test")
  expect_true(any(res$diagnostics$check == "Automatic test selection"))
  expect_true(any(res$diagnostics$check == "Observed group spread"))
  expect_true(any(grepl(
    "Welch t-test and Welch ANOVA do not require equal variances",
    res$diagnostics$detail,
    fixed = TRUE
  )))
  expect_true(is.list(res$method$selection_inputs$observed_group_spread))
})

test_that("compare_groups() accepts character input", {
  res <- compare_groups(mtcars, variable = "mpg", group = "am")

  expect_s3_class(res, "gt_compare")
  expect_equal(res$inputs$variable, "mpg")
  expect_equal(res$inputs$group, "am")
})

test_that("compare_groups() creates a concise continuous publication table", {
  res <- compare_groups(mtcars, variable = mpg, group = am)

  expect_equal(nrow(res$table), 1L)
  expect_true(all(c("Variable", "p-value") %in% names(res$table)))
  expect_equal(sum(grepl("\nN = ", names(res$table), fixed = TRUE)), 2L)
  expect_true(any(grepl("Mean difference", names(res$table), fixed = TRUE)))
  expect_false(any(c(
    "Test", "Statistic", "Interpretation",
    "Effect size type", "Effect size interpretation"
  ) %in% names(res$table)))
})

test_that("compare_groups() creates a concise categorical publication table", {
  data <- mtcars
  data$am <- factor(data$am)
  data$vs <- factor(data$vs)
  res <- compare_groups(data, variable = vs, group = am)

  expect_equal(nrow(res$table), nlevels(data$vs))
  expect_true(all(c("Variable", "Level", "p-value") %in% names(res$table)))
  expect_equal(sum(grepl("\nN = ", names(res$table), fixed = TRUE)), 2L)
  expect_false(any(c("Test", "Statistic", "Interpretation") %in%
                     names(res$table)))
  expect_false(any(res$diagnostics$check == "Observed group spread"))
})

test_that("compare_groups() treats ordered outcomes as ordinal", {
  data <- data.frame(
    arm = factor(rep(c("Control", "Treatment"), each = 12)),
    response = ordered(
      c(rep(c("None", "Mild", "Moderate"), 4),
        rep(c("Mild", "Moderate", "Severe"), 4)),
      levels = c("None", "Mild", "Moderate", "Severe")
    )
  )

  res <- compare_groups(data, response, group = arm)

  expect_equal(res$method$outcome_type, "ordinal")
  expect_equal(res$inferential$test_used, "Wilcoxon rank-sum test")
  expect_equal(res$table$Level, levels(data$response))
})

test_that("compare_groups() rejects the retired public arguments", {
  expect_error(
    compare_groups(mtcars, mpg, group = am, normality_check = FALSE),
    "Unused arguments"
  )
  expect_error(
    compare_groups(mtcars, mpg, group = am, var_equal = TRUE),
    "Unused arguments"
  )
  expect_error(
    compare_groups(mtcars, vs, group = am, correction = FALSE),
    "Unused arguments"
  )
  expect_error(
    compare_groups(mtcars, outcome = mpg, by = am),
    "Unused arguments"
  )
})

test_that("compare_groups() supports Student t-test", {
  res <- compare_groups(mtcars, variable = mpg, group = am, test = "t_test")

  expect_equal(res$inferential$test_used[1], "Student t-test")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() supports Wilcoxon rank-sum test", {
  res <- compare_groups(mtcars, variable = mpg, group = am, test = "wilcox")

  expect_equal(res$inferential$test_used[1], "Wilcoxon rank-sum test")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() defaults to Welch ANOVA for multi-group continuous outcome", {
  res <- compare_groups(mtcars, variable = mpg, group = cyl)

  expect_equal(res$inferential$test_used[1], "Welch ANOVA")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() supports explicit classical ANOVA", {
  res <- compare_groups(
    mtcars,
    variable = mpg,
    group = cyl,
    test = "anova"
  )

  expect_equal(res$inferential$test_used[1], "ANOVA")
  expect_match(res$inferential$method_detail[1], "Residual df")
})

test_that("compare_groups() supports explicit Welch ANOVA", {
  res <- compare_groups(
    mtcars,
    variable = mpg,
    group = cyl,
    test = "welch_anova"
  )

  expect_equal(res$inferential$test_used[1], "Welch ANOVA")
  expect_match(res$inferential$method_detail[1], "Unequal variances")
})

test_that("compare_groups() supports Kruskal-Wallis for multi-group continuous outcome", {
  res <- compare_groups(mtcars, variable = mpg, group = cyl, test = "kruskal")

  expect_equal(res$inferential$test_used[1], "Kruskal-Wallis test")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() supports Chi-square test for categorical outcome", {
  res <- compare_groups(mtcars, variable = vs, group = am, test = "chisq")

  expect_equal(res$inferential$test_used[1], "Chi-square test")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() supports Fisher's exact test for categorical outcome", {
  res <- compare_groups(mtcars, variable = vs, group = am, test = "fisher")

  expect_equal(res$inferential$test_used[1], "Fisher's exact test")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("categorical comparisons expose expected-count checks and assumptions", {
  res <- compare_groups(mtcars, variable = vs, group = am)

  expect_true(is.matrix(res$method$expected_counts))
  expect_true(any(grepl("Minimum expected cell count", res$notes)))
  expect_true(any(grepl("independent observations", res$notes)))
  expect_match(res$method$selection_rule, "expected cell count")
  expect_true(any(res$diagnostics$check == "Automatic test selection"))
})

test_that("compare_groups() supports paired t-test", {
  dat <- data.frame(
    id = rep(1:4, 2),
    period = c("before", "before", "before", "before",
               "after",  "after",  "after",  "after"),
    score = c(10, 12, 9, 11, 13, 16, 11, 15)
  )

  res <- compare_groups(
    dat, variable = score, group = period, paired = TRUE, id = id,
    test = "t_test"
  )

  expect_equal(res$inferential$test_used[1], "Paired t-test")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() supports Wilcoxon signed-rank test", {
  dat <- data.frame(
    id = rep(1:4, 2),
    period = c("before", "before", "before", "before",
               "after",  "after",  "after",  "after"),
    score = c(10, 12, 9, 11, 13, 16, 11, 15)
  )

  res <- compare_groups(
    dat, variable = score, group = period, paired = TRUE, id = id,
    test = "wilcox"
  )

  expect_equal(res$inferential$test_used[1], "Wilcoxon signed-rank test")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() supports McNemar test for paired binary outcome", {
  dat <- data.frame(
    id = rep(1:4, 2),
    treatment = c("before", "before", "before", "before",
                  "after",  "after",  "after",  "after"),
    status = c(0, 1, 0, 1, 1, 1, 0, 0)
  )

  res <- compare_groups(
    dat, variable = status, group = treatment, paired = TRUE, id = id,
    test = "mcnemar"
  )

  expect_equal(res$inferential$test_used[1], "McNemar test")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() errors when group is continuous", {
  expect_error(
    compare_groups(mtcars, variable = mpg, group = wt),
    "`group` should be a categorical, binary, or ordinal variable."
  )
})

test_that("compare_groups() uses distribution assessment when requested", {
  dat <- data.frame(
    group = rep(c("a", "b"), each = 20),
    outcome = c(seq_len(19), 200, seq_len(19), 250)
  )

  res <- compare_groups(
    dat,
    outcome,
    group,
    test = "auto"
  )

  expect_equal(res$inferential$test_used, "Wilcoxon rank-sum test")
})

test_that("compare_groups() uses distribution guidance by default", {
  dat <- data.frame(
    group = rep(c("a", "b"), each = 20),
    outcome = c(seq_len(19), 200, seq_len(19), 250)
  )

  res <- compare_groups(dat, outcome, group)

  expect_equal(res$inferential$test_used, "Wilcoxon rank-sum test")
  expect_true(any(grepl("distribution guidance", res$notes)))
})

test_that("paired automatic selection assesses within-pair differences", {
  id <- seq_len(20)
  baseline <- exp(seq(0, 4, length.out = 20))
  differences <- rep(c(-2, -1, 0, 1, 2), 4)
  dat <- data.frame(
    id = rep(id, 2),
    period = rep(c("before", "after"), each = 20),
    score = c(baseline, baseline + differences)
  )

  res <- compare_groups(
    dat,
    variable = score,
    group = period,
    paired = TRUE,
    id = id
  )

  expect_equal(res$inferential$test_used, "Paired t-test")
  expect_true(any(grepl("within-pair differences", res$notes)))
})

test_that("compare_groups() labels a configurable confidence interval", {
  res <- compare_groups(
    mtcars,
    variable = mpg,
    group = am,
    conf.level = 0.90
  )

  expect_true(any(grepl("90% CI", names(res$table), fixed = TRUE)))
})

test_that("compare_groups() requires an id for paired analyses", {
  dat <- data.frame(
    period = rep(c("before", "after"), each = 3),
    score = 1:6
  )

  expect_error(
    compare_groups(dat, score, period, paired = TRUE),
    "`id` is required"
  )
})

test_that("compare_groups() aligns paired observations by id", {
  dat <- data.frame(
    id = c(1, 2, 3, 3, 1, 2),
    period = rep(c("before", "after"), each = 3),
    score = c(10, 20, 30, 34, 12, 23)
  )

  res <- compare_groups(
    dat, score, period, paired = TRUE, id = id, test = "t_test"
  )

  expect_true(any(grepl("3 complete pairs", res$notes)))
})

test_that("compare_groups() errors when outcome and group are the same", {
  expect_error(
    compare_groups(mtcars, variable = mpg, group = mpg),
    "`variable` and `group` must be different variables."
  )
})

test_that("compare_groups() errors for invalid variable names", {
  expect_error(
    compare_groups(mtcars, variable = not_a_var, group = am),
    "`variable` was not found in `data`."
  )

  expect_error(
    compare_groups(mtcars, variable = mpg, group = not_a_var),
    "`group` was not found in `data`."
  )
})
test_that("compare_groups() returns Hedges' g with a confidence interval", {
  res <- compare_groups(
    mtcars,
    variable = mpg,
    group = am,
    effect_size = TRUE
  )

  expect_s3_class(res, "gt_compare")
  expect_true("effect_size" %in% names(res$inferential))
  expect_true("effect_size_type" %in% names(res$inferential))
  expect_true("effect_size_interpretation" %in% names(res$inferential))

  expect_false(is.na(res$inferential$effect_size[1]))
  expect_equal(res$inferential$effect_size_type[1], "Hedges' g")
  expect_equal(res$inferential$effect_size_symbol[1], "g")
  expect_false(is.na(res$inferential$effect_conf_low[1]))
  expect_false(is.na(res$inferential$effect_conf_high[1]))
  expect_lt(
    res$inferential$effect_conf_low[1],
    res$inferential$effect_size[1]
  )
  expect_gt(
    res$inferential$effect_conf_high[1],
    res$inferential$effect_size[1]
  )
  expect_true(res$inferential$effect_size_interpretation[1] %in%
                c("Negligible", "Small", "Medium", "Large", "Very large"))
})

test_that("compare_groups() returns Cramer's V for categorical comparison", {
  res <- compare_groups(
    mtcars,
    variable = vs,
    group = am,
    effect_size = TRUE
  )

  expect_s3_class(res, "gt_compare")
  expect_false(is.na(res$inferential$effect_size[1]))
  expect_equal(res$inferential$effect_size_type[1], "Cramer's V")
  expect_equal(res$inferential$effect_size_symbol[1], "V")
  expect_true(is.na(res$inferential$effect_conf_low[1]))
  expect_true(is.na(res$inferential$effect_conf_high[1]))
  expect_true(res$inferential$effect_size_interpretation[1] %in%
                c("Negligible", "Small", "Medium", "Large"))
})

test_that("compare_groups() leaves effect size as NA when effect_size = FALSE", {
  res <- compare_groups(
    mtcars,
    variable = mpg,
    group = am,
    effect_size = FALSE
  )

  expect_true(is.na(res$inferential$effect_size[1]))
  expect_true(is.na(res$inferential$effect_size_type[1]))
  expect_true(is.na(res$inferential$effect_size_interpretation[1]))
  expect_true(is.na(res$inferential$effect_conf_low[1]))
  expect_true(is.na(res$inferential$effect_conf_high[1]))
})

test_that("compare_groups() includes effect size columns in summary table when requested", {
  res <- compare_groups(
    mtcars,
    variable = mpg,
    group = am,
    effect_size = TRUE
  )

  expect_true("Effect size (95% CI)" %in% names(res$table))
  expect_match(res$table[["Effect size (95% CI)"]], "^g =")
})

test_that("compare_groups() supports effect size for Wilcoxon rank-sum test", {
  res <- compare_groups(
    mtcars,
    variable = mpg,
    group = am,
    test = "wilcox",
    effect_size = TRUE
  )

  expect_false(is.na(res$inferential$effect_size[1]))
  expect_lte(abs(res$inferential$effect_size[1]), 1)
  expect_equal(res$inferential$effect_size_type[1], "Rank-biserial correlation")
  expect_equal(res$inferential$effect_size_symbol[1], "r")
  expect_true(is.na(res$inferential$effect_conf_low[1]))
  expect_true(res$inferential$effect_size_interpretation[1] %in%
                c("Negligible", "Small", "Medium", "Large"))
})

test_that("compare_groups() supports effect size for paired t-test", {
  dat <- data.frame(
    id = rep(1:4, 2),
    period = c("before", "before", "before", "before",
               "after",  "after",  "after",  "after"),
    score  = c(10, 12, 9, 11, 13, 16, 11, 15)
  )

  res <- compare_groups(
    dat,
    variable = score,
    group = period,
    paired = TRUE,
    id = id,
    test = "t_test",
    effect_size = TRUE
  )

  expect_false(is.na(res$inferential$effect_size[1]))
  expect_equal(res$inferential$effect_size_type[1], "Paired Hedges' g")
  expect_false(is.na(res$inferential$effect_conf_low[1]))
  expect_false(is.na(res$inferential$effect_conf_high[1]))
  expect_true(res$inferential$effect_size_interpretation[1] %in%
                c("Negligible", "Small", "Medium", "Large", "Very large"))
})

test_that("compare_groups() supports effect size for paired Wilcoxon test", {
  dat <- data.frame(
    id = rep(1:4, 2),
    period = c("before", "before", "before", "before",
               "after",  "after",  "after",  "after"),
    score  = c(10, 12, 9, 11, 13, 16, 11, 15)
  )

  res <- compare_groups(
    dat,
    variable = score,
    group = period,
    paired = TRUE,
    id = id,
    test = "wilcox",
    effect_size = TRUE
  )

  expect_false(is.na(res$inferential$effect_size[1]))
  expect_equal(res$inferential$effect_size_type[1], "Matched rank-biserial correlation")
  expect_equal(res$inferential$effect_size_symbol[1], "r")
  expect_true(res$inferential$effect_size_interpretation[1] %in%
                c("Negligible", "Small", "Medium", "Large"))
})

test_that("compare_groups() supports multi-group effect sizes", {
  res1 <- compare_groups(
    mtcars,
    variable = mpg,
    group = cyl,
    test = "anova",
    effect_size = TRUE
  )

  res2 <- compare_groups(
    mtcars,
    variable = mpg,
    group = cyl,
    test = "kruskal",
    effect_size = TRUE
  )

  expect_false(is.na(res1$inferential$effect_size[1]))
  expect_match(res1$inferential$effect_size_type[1], "Omega-squared")
  expect_gte(res1$inferential$effect_size[1], 0)
  expect_lte(res1$inferential$effect_size[1], 1)

  expect_false(is.na(res2$inferential$effect_size[1]))
  expect_equal(res2$inferential$effect_size_type[1], "Epsilon-squared")
  expect_gte(res2$inferential$effect_size[1], 0)
  expect_lte(res2$inferential$effect_size[1], 1)
})

test_that("compare_groups() returns epsilon-squared for multi-level ordinal outcome", {
  dat <- data.frame(
    arm = factor(rep(c("A", "B", "C"), each = 12)),
    response = ordered(
      rep(c("None", "Mild", "Severe"), each = 12),
      levels = c("None", "Mild", "Severe")
    )
  )

  res <- compare_groups(
    dat,
    variable = response,
    group = arm,
    effect_size = TRUE
  )

  expect_equal(res$inferential$test_used, "Kruskal-Wallis test")
  expect_equal(res$inferential$effect_size_type, "Epsilon-squared")
  expect_gte(res$inferential$effect_size, 0)
  expect_lte(res$inferential$effect_size, 1)
})
