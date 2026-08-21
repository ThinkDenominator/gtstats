test_that("assess_variance() returns grouped variance diagnostics", {
  res <- assess_variance(mtcars, vars = c(mpg, wt), by = am)

  expect_s3_class(res, "gt_variance")
  expect_true(all(c(
    "variable", "label", "group", "n", "missing", "non_finite", "sd",
    "variance", "sd_ratio", "variance_ratio", "interpretation"
  ) %in% names(res$summary)))
  expect_true(all(c(
    "Variable", "Observed SD ratio", "Observed variance ratio", "Levene p",
    "Interpretation"
  ) %in% names(res$table)))
  expect_true(any(grepl("variance =", unlist(res$table), fixed = TRUE)))
  expect_equal(nrow(res$table), 2L)
  expect_true(is.finite(res$diagnostics$levene_p[[1L]]))
  expect_equal(nrow(res$diagnostics), 2L)
  expect_match(res$notes[["welch"]], "do not require equal variances")
  expect_true(all(res$diagnostics$sd_ratio >= 1, na.rm = TRUE))
  expect_s3_class(tbl_stats(res), "gt_tbl")
  expect_s3_class(to_flextable(res), "flextable")
})

test_that("assess_variance() accepts bare and character variable names", {
  bare <- assess_variance(mtcars, vars = mpg, by = am)
  character <- assess_variance(mtcars, vars = "mpg", by = "am")

  expect_equal(bare$summary$variable, character$summary$variable)
  expect_equal(bare$summary$group, character$summary$group)
  expect_s3_class(
    assess_variance(mtcars, vars = mpg, by = am, output = "tibble"),
    "tbl_df"
  )
})

test_that("assess_variance() reports data-quality and constant-variable cases", {
  dat <- data.frame(
    arm = factor(rep(c("Control", "Treatment"), each = 3)),
    constant = rep(4, 6),
    sparse = c(1.1, NA, NA, 2.2, 3.3, NA),
    non_finite = c(1, Inf, 3, 4, -Inf, NA)
  )
  res <- assess_variance(dat, vars = c(constant, sparse, non_finite), by = arm)

  constant <- res$diagnostics[res$diagnostics$variable == "constant", ]
  sparse <- res$diagnostics[res$diagnostics$variable == "sparse", ]
  non_finite <- res$summary[res$summary$variable == "non_finite", ]
  expect_equal(constant$sd_ratio, 1)
  expect_match(constant$interpretation, "zero observed spread")
  expect_match(sparse$interpretation, "fewer than two groups")
  expect_equal(sum(non_finite$non_finite), 2L)
  expect_true(any(grepl("excluded|not estimable", unlist(res$table), ignore.case = TRUE)))
})

test_that("assess_variance() validates groups and variables", {
  dat <- transform(
    mtcars,
    text_group = rep(c("Control", "Treatment"), length.out = nrow(mtcars)),
    one_group = "All"
  )
  expect_s3_class(assess_variance(dat, vars = mpg, by = text_group), "gt_variance")
  expect_error(assess_variance(mtcars, vars = am, by = vs), "continuous numeric")
  expect_error(assess_variance(mtcars, vars = mpg, by = mpg), "grouping variable")
  expect_error(assess_variance(dat, vars = mpg, by = one_group), "at least two")
  expect_error(assess_variance(mtcars, vars = "not_a_variable", by = am), "not found")
})

test_that("assess_variance() can display Bartlett supporting information", {
  result <- assess_variance(iris, vars = Sepal.Length, by = Species, test = "bartlett")
  expect_true("Bartlett p" %in% names(result$table))
  expect_true(is.finite(result$diagnostics$bartlett_p[[1L]]))
  expect_true(any(grepl("supporting information", result$notes, fixed = TRUE)))
})

test_that("assess_variance() can display median-centred Levene information", {
  result <- assess_variance(
    iris,
    vars = Sepal.Length,
    by = Species,
    test = "levene"
  )
  expect_true("Levene p" %in% names(result$table))
  expect_true(is.finite(result$diagnostics$levene_p[[1L]]))
  expect_equal(result$diagnostics$levene_df1[[1L]], 2)
  expect_match(result$notes[["levene"]], "median-centred")
  expect_match(result$notes[["levene"]], "nor selects", fixed = TRUE)
})
