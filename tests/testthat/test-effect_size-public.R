test_that("effect_size() selects Hedges' g for two continuous groups", {
  res <- effect_size(mtcars, variable = mpg, group = am)

  expect_s3_class(res, "gt_effect")
  expect_s3_class(res, "gtstats")
  expect_identical(res$summary$measure, "Hedges' g")
  expect_identical(res$table$Contrast, "am: 0 \u2212 1")
  expect_true(is.finite(res$summary$estimate))
  expect_true(is.finite(res$summary$conf_low))
  expect_true(is.finite(res$summary$conf_high))
  expect_named(
    res$table,
    c("Measure", "Contrast", "Estimate", "95% CI")
  )
})

test_that("effect_size() selects an omnibus measure for multiple groups", {
  res <- effect_size(mtcars, variable = mpg, group = cyl)

  expect_match(res$summary$measure, "Omega-squared")
  expect_gte(res$summary$estimate, 0)
  expect_lte(res$summary$estimate, 1)
  expect_identical(res$table$Contrast, "\u2014")
})

test_that("effect_size() selects Cramer's V for categorical association", {
  res <- effect_size(mtcars, variable = vs, group = am)

  expect_identical(res$summary$measure, "Cramer's V")
  expect_gte(res$summary$estimate, 0)
  expect_lte(res$summary$estimate, 1)
  expect_false(any(grepl(
    "Risk ratio|Odds ratio|Risk difference",
    res$table$Measure
  )))
})

test_that("effect_size() supports explicit non-parametric measures", {
  rank <- effect_size(
    mtcars,
    variable = mpg,
    group = am,
    method = "rank_biserial"
  )
  epsilon <- effect_size(
    mtcars,
    variable = mpg,
    group = cyl,
    method = "epsilon_squared"
  )

  expect_identical(
    rank$summary$measure,
    "Rank-biserial correlation"
  )
  expect_gte(rank$summary$estimate, -1)
  expect_lte(rank$summary$estimate, 1)
  expect_identical(epsilon$summary$measure, "Epsilon-squared")
  expect_gte(epsilon$summary$estimate, 0)
  expect_lte(epsilon$summary$estimate, 1)
})

test_that("effect_size() uses categorical association for an independent ordinal outcome", {
  dat <- data.frame(
    group = factor(rep(c("A", "B"), each = 6)),
    response = ordered(c(1, 1, 2, 2, 3, 3, 2, 3, 3, 4, 4, 5))
  )

  res <- effect_size(dat, response, group)

  expect_identical(
    res$summary$measure,
    "Cramer's V"
  )
  expect_identical(res$table$Contrast, "\u2014")

  rank_res <- effect_size(dat, response, group, method = "rank_biserial")
  expect_identical(rank_res$summary$measure, "Rank-biserial correlation")
  expect_identical(rank_res$table$Contrast, "group: A \u2212 B")
})

test_that("effect_size() supports paired Hedges' g and complete pairs", {
  dat <- data.frame(
    id = rep(seq_len(8), each = 2),
    visit = factor(rep(c("Before", "After"), 8),
                   levels = c("Before", "After")),
    score = c(
      10, 12, 11, 14, 9, 11, 13, 15,
      8, 10, 12, 13, 14, 17, 9, 12
    )
  )
  dat$score[[2L]] <- NA_real_

  res <- effect_size(
    dat,
    variable = score,
    group = visit,
    paired = TRUE,
    id = id,
    method = "hedges_g"
  )

  expect_identical(res$summary$measure, "Paired Hedges' g")
  expect_identical(res$table$Contrast, "visit: Before \u2212 After")
  expect_true(is.finite(res$summary$estimate))
  expect_true(nrow(res$denominators) > 0L)
})

test_that("effect_size() preserves factor order for effect direction", {
  dat <- data.frame(
    group = factor(rep(c("Control", "Treatment"), each = 5),
                   levels = c("Control", "Treatment")),
    value = c(1, 2, 2, 3, 3, 4, 5, 5, 6, 7)
  )

  res <- effect_size(dat, value, group)

  expect_identical(res$table$Contrast, "group: Control \u2212 Treatment")
  expect_lt(res$summary$estimate, 0)
  expect_match(res$notes[[1L]], "positive values.*Control")
  expect_true(any(grepl(
    "Approximate large-sample normal interval", res$notes, fixed = TRUE
  )))
})

test_that("conventional magnitude labels are optional and qualified", {
  default <- effect_size(mtcars, mpg, am)
  labelled <- effect_size(
    mtcars,
    mpg,
    am,
    interpretation = TRUE
  )

  expect_false("Conventional magnitude" %in% names(default$table))
  expect_true("Conventional magnitude" %in% names(labelled$table))
  expect_true(any(grepl(
    "not thresholds for clinical importance",
    labelled$notes,
    fixed = TRUE
  )))
})

test_that("effect_size() validates incompatible requests", {
  expect_error(
    effect_size(mtcars, mpg, cyl, method = "hedges_g"),
    "continuous outcome and 2 groups"
  )
  expect_error(
    effect_size(mtcars, mpg, am, method = "cramers_v"),
    "categorical outcome"
  )
  expect_error(
    effect_size(mtcars, vs, am, method = "rank_biserial"),
    "numeric outcome and 2 groups"
  )
  expect_error(
    effect_size(mtcars, mpg, am, paired = TRUE),
    "`id`"
  )
})

test_that("effect_size objects render and follow the result contract", {
  res <- effect_size(mtcars, mpg, am)

  expect_s3_class(tbl_stats(res), "gt_tbl")
  expect_s3_class(to_flextable(res), "flextable")
  expect_true(all(c(
    "summary", "table", "inputs", "method", "assumptions",
    "diagnostics", "denominators", "notes", "call"
  ) %in% names(res)))
  capture.output(out <- print(res))
  expect_identical(out, res)
})
