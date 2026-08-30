test_that("assess_distribution() returns descriptive diagnostics", {
  res <- assess_distribution(mtcars, vars = c(mpg, wt))

  expect_s3_class(res, "gt_distribution")
  expect_true(all(c(
    "variable", "label", "n", "missing", "non_finite", "skewness",
    "shape", "group_guidance", "shapiro_p", "shapiro_note",
    "overall_recommendation"
  ) %in% names(res$summary)))
  expect_true(all(c("Variable", "Shape", "Suggested presentation", "Shapiro p") %in%
    names(res$table)))
  expect_false("Missing" %in% names(res$table))
  expect_false("Non-finite" %in% names(res$table))
  expect_match(res$table$`Suggested presentation`[[1L]], "mean|median", ignore.case = TRUE)
  expect_true(all(c("shape", "shapiro", "recommendation") %in% names(res$notes)))
  expect_true(all(c("label", "overall_recommendation", "reason", "review") %in%
    names(res$recommendations)))
  expect_match(res$notes[["recommendation"]], "inferential statistical methods")
})

test_that("assess_distribution() defaults to detected continuous variables", {
  res <- assess_distribution(mtcars)
  expect_true(nrow(res$summary) > 0L)
  expect_true(all(vapply(
    res$summary$variable,
    function(variable) identical(gtstats:::.detect_type(mtcars[[variable]]), "continuous"),
    logical(1)
  )))
})

test_that("assess_distribution() rejects non-continuous selected variables", {
  data <- transform(mtcars,
    sex = factor(rep(c("Female", "Male"), length.out = nrow(mtcars))),
    assessment_date = as.Date("2020-01-01") + seq_len(nrow(mtcars))
  )
  expect_error(assess_distribution(data, vars = sex), 'Variable "sex" is binary')
  expect_error(assess_distribution(data, vars = am), 'Variable "am" is binary')
  expect_error(assess_distribution(data, vars = assessment_date), 'Variable "assessment_date" is date')
})

test_that("assess_distribution() supports permitted grouping variables", {
  data <- transform(mtcars,
    character_group = rep(c("Control", "Treatment"), length.out = nrow(mtcars)),
    logical_group = rep(c(TRUE, FALSE), length.out = nrow(mtcars))
  )
  character <- assess_distribution(data, vars = mpg, by = character_group)
  logical <- assess_distribution(data, vars = mpg, by = logical_group)

  expect_equal(sort(unique(character$summary$group)), c("Control", "Treatment"))
  expect_equal(sort(unique(logical$summary$group)), c("FALSE", "TRUE"))
  expect_error(assess_distribution(data, vars = mpg, by = wt), "grouping variable")
})

test_that("grouped diagnostics retain per-group results and one recommendation", {
  data <- data.frame(
    group = rep(c("Control", "Treatment"), each = 30),
    outcome = c(seq(-2, 2, length.out = 30), c(rep(0, 29), 100))
  )
  res <- assess_distribution(data, vars = outcome, by = group)

  expect_equal(nrow(res$summary), 2L)
  expect_equal(nrow(res$recommendations), 1L)
  expect_match(res$recommendations$overall_recommendation, "Median")
  expect_true(nzchar(res$table$Variable[[1L]]))
  expect_identical(res$table$Variable[[2L]], "")
  expect_true("Suggested presentation" %in% names(res$table))
  expect_true(nzchar(res$table$`Suggested presentation`[[1L]]))
  expect_identical(res$table$`Suggested presentation`[[2L]], "")
  expect_true(nzchar(res$recommendations$reason))
  expect_true(nzchar(res$recommendations$review))
})

test_that("Shapiro-Wilk is supporting information only", {
  res <- assess_distribution(mtcars, vars = mpg)
  disabled <- assess_distribution(mtcars, vars = mpg, normality_test = FALSE)

  expect_false(is.na(res$summary$shapiro_p))
  expect_true("Shapiro p" %in% names(res$table))
  expect_false("Shapiro p" %in% names(disabled$table))
  expect_match(res$notes[["shapiro"]], "sensitive to sample size")
  expect_false(grepl("Shapiro", res$recommendations$overall_recommendation))
})

test_that("shape bands are explicit and direction is retained", {
  data <- data.frame(
    right = c(rep(0, 18), 0.1, 100),
    left = c(-100, -0.1, rep(0, 18))
  )
  res <- assess_distribution(data, vars = c(right, left), skew_cutoff = 1)

  expect_equal(res$summary$shape, c("Marked right skew", "Marked left skew"))
  expect_match(res$notes[["shape"]], "little/no asymmetry < 0.50")
  expect_match(res$notes[["shape"]], "marked skew >= 1.00")
})

test_that("assess_distribution() handles data-quality edge cases", {
  data <- data.frame(
    all_missing = c(NA_real_, NaN, NA_real_, NA_real_, NA_real_),
    constant = rep(4, 5),
    few = c(1.1, 2.2, 3.3, NA_real_, NA_real_),
    non_finite = c(1.1, 2.2, Inf, -Inf, NA_real_)
  )
  res <- assess_distribution(data, vars = c(all_missing, constant, few, non_finite), min_n = 4)

  expect_equal(res$summary$shape[[1L]], "All values missing or non-finite")
  expect_equal(res$summary$shape[[2L]], "Constant (zero variance)")
  expect_equal(res$summary$shape[[3L]], "Insufficient observations")
  expect_equal(res$summary$non_finite[[4L]], 2L)
  expect_equal(res$summary$n[[4L]], 2L)
  expect_true(all(c("Missing", "Non-finite") %in% names(res$table)))
})

test_that("assess_distribution() creates optional visual diagnostics", {
  res <- assess_distribution(mtcars, vars = mpg, by = am, plots = TRUE)
  expect_named(res$plots$mpg, c("histogram", "density", "qq", "boxplot"))
  expect_s3_class(res$plots$mpg$histogram, "ggplot")

  tibble_result <- assess_distribution(mtcars, vars = mpg, plots = TRUE, format = "tibble")
  expect_s3_class(attr(tibble_result, "plots")$mpg$qq, "ggplot")
  expect_true(is.data.frame(attr(tibble_result, "recommendations")))
})

test_that("assess_distribution() validates inputs and supported routes", {
  expect_error(assess_distribution(mtcars, vars = "not_a_var"), "not found")
  expect_error(assess_distribution(mtcars, skew_cutoff = 0), "skew_cutoff")
  expect_error(assess_distribution(mtcars, min_n = 2), "min_n")
  expect_error(assess_distribution(mtcars, plots = NA), "plots")

  res <- assess_distribution(mtcars, vars = c(mpg, wt))
  expect_s3_class(to_gt(res), "gt_tbl")
  expect_s3_class(to_flextable(res), "flextable")
  expect_s3_class(assess_distribution(mtcars, vars = mpg, format = "tibble"), "tbl_df")
})
