test_that("compare_groups() works for 2-group continuous outcome with default auto test", {
  res <- compare_groups(mtcars, outcome = mpg, group = am)

  expect_s3_class(res, "gt_compare")
  expect_true(is.list(res))
  expect_true(all(c("descriptives", "inferential", "table", "inputs", "notes") %in% names(res)))

  expect_equal(res$inputs$outcome, "mpg")
  expect_equal(res$inputs$group, "am")
  expect_equal(res$inferential$test_used[1], "Welch t-test")
  expect_true(is.numeric(res$inferential$p_value[1]))
  expect_equal(nrow(res$table), 1)
})

test_that("compare_groups() accepts character input", {
  res <- compare_groups(mtcars, outcome = "mpg", group = "am")

  expect_s3_class(res, "gt_compare")
  expect_equal(res$inputs$outcome, "mpg")
  expect_equal(res$inputs$group, "am")
})

test_that("compare_groups() supports Student t-test", {
  res <- compare_groups(mtcars, outcome = mpg, group = am, test = "t_test")

  expect_equal(res$inferential$test_used[1], "Student t-test")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() supports Wilcoxon rank-sum test", {
  res <- compare_groups(mtcars, outcome = mpg, group = am, test = "wilcox")

  expect_equal(res$inferential$test_used[1], "Wilcoxon rank-sum test")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() supports ANOVA for multi-group continuous outcome", {
  res <- compare_groups(mtcars, outcome = mpg, group = cyl)

  expect_equal(res$inferential$test_used[1], "ANOVA")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() supports Kruskal-Wallis for multi-group continuous outcome", {
  res <- compare_groups(mtcars, outcome = mpg, group = cyl, test = "kruskal")

  expect_equal(res$inferential$test_used[1], "Kruskal-Wallis test")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() supports Chi-square test for categorical outcome", {
  res <- compare_groups(mtcars, outcome = vs, group = am, test = "chisq")

  expect_equal(res$inferential$test_used[1], "Chi-square test")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() supports Fisher's exact test for categorical outcome", {
  res <- compare_groups(mtcars, outcome = vs, group = am, test = "fisher")

  expect_equal(res$inferential$test_used[1], "Fisher's exact test")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() supports paired t-test", {
  dat <- data.frame(
    period = c("before", "before", "before", "before",
               "after",  "after",  "after",  "after"),
    score = c(10, 12, 9, 11, 13, 16, 11, 15)
  )

  res <- compare_groups(dat, outcome = score, group = period, paired = TRUE, test = "t_test")

  expect_equal(res$inferential$test_used[1], "Paired t-test")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() supports Wilcoxon signed-rank test", {
  dat <- data.frame(
    period = c("before", "before", "before", "before",
               "after",  "after",  "after",  "after"),
    score = c(10, 12, 9, 11, 13, 16, 11, 15)
  )

  res <- compare_groups(dat, outcome = score, group = period, paired = TRUE, test = "wilcox")

  expect_equal(res$inferential$test_used[1], "Wilcoxon signed-rank test")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() supports McNemar test for paired binary outcome", {
  dat <- data.frame(
    treatment = c("before", "before", "before", "before",
                  "after",  "after",  "after",  "after"),
    status = c(0, 1, 0, 1, 1, 1, 0, 0)
  )

  res <- compare_groups(dat, outcome = status, group = treatment, paired = TRUE, test = "mcnemar")

  expect_equal(res$inferential$test_used[1], "McNemar test")
  expect_true(is.numeric(res$inferential$p_value[1]))
})

test_that("compare_groups() errors when group is continuous", {
  expect_error(
    compare_groups(mtcars, outcome = mpg, group = wt),
    "`group` should be a categorical, binary, or ordinal variable."
  )
})

test_that("compare_groups() errors when outcome and group are the same", {
  expect_error(
    compare_groups(mtcars, outcome = mpg, group = mpg),
    "`outcome` and `group` must be different variables."
  )
})

test_that("compare_groups() errors for invalid variable names", {
  expect_error(
    compare_groups(mtcars, outcome = not_a_var, group = am),
    "`outcome` was not found in `data`."
  )

  expect_error(
    compare_groups(mtcars, outcome = mpg, group = not_a_var),
    "`group` was not found in `data`."
  )
})
test_that("compare_groups() returns Cohen's d for two-group continuous comparison", {
  res <- compare_groups(
    mtcars,
    outcome = mpg,
    group = am,
    effect_size = TRUE
  )

  expect_s3_class(res, "gt_compare")
  expect_true("effect_size" %in% names(res$inferential))
  expect_true("effect_size_type" %in% names(res$inferential))
  expect_true("effect_size_interpretation" %in% names(res$inferential))

  expect_false(is.na(res$inferential$effect_size[1]))
  expect_equal(res$inferential$effect_size_type[1], "Cohen's d")
  expect_true(res$inferential$effect_size_interpretation[1] %in%
                c("Negligible", "Small", "Medium", "Large", "Very large"))
})

test_that("compare_groups() returns Cramer's V for categorical comparison", {
  res <- compare_groups(
    mtcars,
    outcome = vs,
    group = am,
    effect_size = TRUE
  )

  expect_s3_class(res, "gt_compare")
  expect_false(is.na(res$inferential$effect_size[1]))
  expect_equal(res$inferential$effect_size_type[1], "Cramer's V")
  expect_true(res$inferential$effect_size_interpretation[1] %in%
                c("Negligible", "Small", "Medium", "Large"))
})

test_that("compare_groups() leaves effect size as NA when effect_size = FALSE", {
  res <- compare_groups(
    mtcars,
    outcome = mpg,
    group = am,
    effect_size = FALSE
  )

  expect_true(is.na(res$inferential$effect_size[1]))
  expect_true(is.na(res$inferential$effect_size_type[1]))
  expect_true(is.na(res$inferential$effect_size_interpretation[1]))
})

test_that("compare_groups() includes effect size columns in summary table when requested", {
  res <- compare_groups(
    mtcars,
    outcome = mpg,
    group = am,
    effect_size = TRUE
  )

  expect_true("Effect size" %in% names(res$table))
  expect_true("Effect size type" %in% names(res$table))
  expect_true("Effect size interpretation" %in% names(res$table))
})

test_that("compare_groups() supports effect size for Wilcoxon rank-sum test", {
  res <- compare_groups(
    mtcars,
    outcome = mpg,
    group = am,
    test = "wilcox",
    effect_size = TRUE
  )

  expect_false(is.na(res$inferential$effect_size[1]))
  expect_equal(res$inferential$effect_size_type[1], "Rank-biserial correlation")
  expect_true(res$inferential$effect_size_interpretation[1] %in%
                c("Negligible", "Small", "Medium", "Large"))
})

test_that("compare_groups() supports effect size for paired t-test", {
  dat <- data.frame(
    period = c("before", "before", "before", "before",
               "after",  "after",  "after",  "after"),
    score  = c(10, 12, 9, 11, 13, 16, 11, 15)
  )

  res <- compare_groups(
    dat,
    outcome = score,
    group = period,
    paired = TRUE,
    test = "t_test",
    effect_size = TRUE
  )

  expect_false(is.na(res$inferential$effect_size[1]))
  expect_equal(res$inferential$effect_size_type[1], "Cohen's d")
  expect_true(res$inferential$effect_size_interpretation[1] %in%
                c("Negligible", "Small", "Medium", "Large", "Very large"))
})

test_that("compare_groups() supports effect size for paired Wilcoxon test", {
  dat <- data.frame(
    period = c("before", "before", "before", "before",
               "after",  "after",  "after",  "after"),
    score  = c(10, 12, 9, 11, 13, 16, 11, 15)
  )

  res <- compare_groups(
    dat,
    outcome = score,
    group = period,
    paired = TRUE,
    test = "wilcox",
    effect_size = TRUE
  )

  expect_false(is.na(res$inferential$effect_size[1]))
  expect_equal(res$inferential$effect_size_type[1], "Matched rank-biserial correlation")
  expect_true(res$inferential$effect_size_interpretation[1] %in%
                c("Negligible", "Small", "Medium", "Large"))
})

test_that("compare_groups() keeps unsupported multi-group effect sizes as NA", {
  res1 <- compare_groups(
    mtcars,
    outcome = mpg,
    group = cyl,
    test = "anova",
    effect_size = TRUE
  )

  res2 <- compare_groups(
    mtcars,
    outcome = mpg,
    group = cyl,
    test = "kruskal",
    effect_size = TRUE
  )

  expect_true(is.na(res1$inferential$effect_size[1]))
  expect_true(is.na(res1$inferential$effect_size_type[1]))
  expect_true(is.na(res1$inferential$effect_size_interpretation[1]))

  expect_true(is.na(res2$inferential$effect_size[1]))
  expect_true(is.na(res2$inferential$effect_size_type[1]))
  expect_true(is.na(res2$inferential$effect_size_interpretation[1]))
})
