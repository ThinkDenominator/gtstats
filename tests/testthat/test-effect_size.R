test_that(".compute_effect_size() returns Cohen's d for Student t-test", {
  x1 <- c(10, 12, 14, 16)
  x2 <- c(8, 9, 10, 11)

  out <- .compute_effect_size(
    x1 = x1,
    x2 = x2,
    test_used = "Student t-test"
  )

  expect_true(is.numeric(out))
  expect_length(out, 1)
  expect_false(is.na(out))
})

test_that(".compute_effect_size() returns Cohen's d for Welch t-test", {
  x1 <- c(20, 22, 24, 26)
  x2 <- c(10, 11, 12, 13)

  out <- .compute_effect_size(
    x1 = x1,
    x2 = x2,
    test_used = "Welch t-test"
  )

  expect_true(is.numeric(out))
  expect_length(out, 1)
  expect_false(is.na(out))
})

test_that(".compute_effect_size() returns paired Cohen's d for Paired t-test", {
  x1 <- c(12, 15, 16, 20)
  x2 <- c(10, 12, 14, 17)

  out <- .compute_effect_size(
    x1 = x1,
    x2 = x2,
    test_used = "Paired t-test"
  )

  expect_true(is.numeric(out))
  expect_length(out, 1)
  expect_false(is.na(out))
})

test_that(".compute_effect_size() returns NA for Paired t-test when x1 or x2 missing", {
  expect_true(is.na(.compute_effect_size(
    x1 = NULL,
    x2 = c(1, 2),
    test_used = "Paired t-test"
  )))

  expect_true(is.na(.compute_effect_size(
    x1 = c(1, 2),
    x2 = NULL,
    test_used = "Paired t-test"
  )))
})

test_that(".compute_effect_size() returns NA for Paired t-test when too few non-missing differences", {
  x1 <- c(1, NA)
  x2 <- c(0, NA)

  out <- .compute_effect_size(
    x1 = x1,
    x2 = x2,
    test_used = "Paired t-test"
  )

  expect_true(is.na(out))
})

test_that(".compute_effect_size() returns NA for Paired t-test when sd of differences is zero", {
  x1 <- c(5, 6, 7)
  x2 <- c(4, 5, 6)

  out <- .compute_effect_size(
    x1 = x1,
    x2 = x2,
    test_used = "Paired t-test"
  )

  expect_true(is.na(out))
})

test_that(".compute_effect_size() returns NA when x1 or x2 missing for independent t-tests", {
  expect_true(is.na(.compute_effect_size(
    x1 = NULL,
    x2 = c(1, 2, 3),
    test_used = "Student t-test"
  )))

  expect_true(is.na(.compute_effect_size(
    x1 = c(1, 2, 3),
    x2 = NULL,
    test_used = "Welch t-test"
  )))
})

test_that(".compute_effect_size() removes missing values for independent t-tests", {
  x1 <- c(10, 12, NA, 14, 16)
  x2 <- c(8, 9, 10, NA, 11)

  out <- .compute_effect_size(
    x1 = x1,
    x2 = x2,
    test_used = "Student t-test"
  )

  expect_false(is.na(out))
})

test_that(".compute_effect_size() returns NA when too few values for independent t-tests", {
  out1 <- .compute_effect_size(
    x1 = c(1),
    x2 = c(2, 3),
    test_used = "Student t-test"
  )

  out2 <- .compute_effect_size(
    x1 = c(1, 2),
    x2 = c(3),
    test_used = "Welch t-test"
  )

  expect_true(is.na(out1))
  expect_true(is.na(out2))
})

test_that(".compute_effect_size() returns NA when sd is missing or pooled sd is zero", {
  out <- .compute_effect_size(
    x1 = c(5, 5, 5),
    x2 = c(5, 5, 5),
    test_used = "Student t-test"
  )

  expect_true(is.na(out))
})

test_that(".compute_effect_size() returns rank-biserial correlation for Wilcoxon rank-sum test", {
  x1 <- c(10, 11, 12, 13)
  x2 <- c(1, 2, 3, 4)

  out <- .compute_effect_size(
    x1 = x1,
    x2 = x2,
    test_used = "Wilcoxon rank-sum test"
  )

  expect_true(is.numeric(out))
  expect_length(out, 1)
  expect_false(is.na(out))
})

test_that(".compute_effect_size() returns NA for Wilcoxon rank-sum when x1 or x2 missing", {
  expect_true(is.na(.compute_effect_size(
    x1 = NULL,
    x2 = c(1, 2),
    test_used = "Wilcoxon rank-sum test"
  )))

  expect_true(is.na(.compute_effect_size(
    x1 = c(1, 2),
    x2 = NULL,
    test_used = "Wilcoxon rank-sum test"
  )))
})

test_that(".compute_effect_size() returns NA for Wilcoxon rank-sum when one group empty after NA removal", {
  out <- .compute_effect_size(
    x1 = c(NA, NA),
    x2 = c(1, 2),
    test_used = "Wilcoxon rank-sum test"
  )

  expect_true(is.na(out))
})

test_that(".compute_effect_size() returns matched rank-biserial correlation for Wilcoxon signed-rank test", {
  x1 <- c(12, 14, 16, 18)
  x2 <- c(10, 13, 14, 17)

  out <- .compute_effect_size(
    x1 = x1,
    x2 = x2,
    test_used = "Wilcoxon signed-rank test"
  )

  expect_true(is.numeric(out))
  expect_length(out, 1)
  expect_false(is.na(out))
})

test_that(".compute_effect_size() returns NA for Wilcoxon signed-rank when x1 or x2 missing", {
  expect_true(is.na(.compute_effect_size(
    x1 = NULL,
    x2 = c(1, 2),
    test_used = "Wilcoxon signed-rank test"
  )))

  expect_true(is.na(.compute_effect_size(
    x1 = c(1, 2),
    x2 = NULL,
    test_used = "Wilcoxon signed-rank test"
  )))
})

test_that(".compute_effect_size() returns NA for Wilcoxon signed-rank when all differences are zero", {
  x1 <- c(5, 5, 5)
  x2 <- c(5, 5, 5)

  out <- .compute_effect_size(
    x1 = x1,
    x2 = x2,
    test_used = "Wilcoxon signed-rank test"
  )

  expect_true(is.na(out))
})

test_that(".compute_effect_size() returns Cramer's V for Chi-square test", {
  tab <- matrix(c(10, 20, 30, 40), nrow = 2)

  out <- .compute_effect_size(
    tab = tab,
    test_used = "Chi-square test"
  )

  expect_true(is.numeric(out))
  expect_length(out, 1)
  expect_false(is.na(out))
})

test_that(".compute_effect_size() returns Cramer's V for Fisher's exact test", {
  tab <- matrix(c(10, 20, 30, 40), nrow = 2)

  out <- .compute_effect_size(
    tab = tab,
    test_used = "Fisher's exact test"
  )

  expect_true(is.numeric(out))
  expect_length(out, 1)
  expect_false(is.na(out))
})

test_that(".compute_effect_size() returns NA for categorical effect size when tab missing", {
  expect_true(is.na(.compute_effect_size(
    tab = NULL,
    test_used = "Chi-square test"
  )))

  expect_true(is.na(.compute_effect_size(
    tab = NULL,
    test_used = "Fisher's exact test"
  )))
})

test_that(".compute_effect_size() returns NA when chi-square computation fails or table invalid", {
  out1 <- .compute_effect_size(
    tab = matrix(c(1, 2, 3), nrow = 1),
    test_used = "Chi-square test"
  )

  out2 <- .compute_effect_size(
    tab = matrix(c(0, 0, 0, 0), nrow = 2),
    test_used = "Fisher's exact test"
  )

  expect_true(is.na(out1))
  expect_true(is.na(out2))
})

test_that(".compute_effect_size() returns NA for unsupported test names", {
  out <- .compute_effect_size(
    x1 = c(1, 2, 3),
    x2 = c(4, 5, 6),
    test_used = "Not a real test"
  )

  expect_true(is.na(out))
})

test_that(".interpret_effect_size() returns NA when value or type is missing", {
  expect_true(is.na(.interpret_effect_size(
    value = NA_real_,
    type = "Cohen's d"
  )))

  expect_true(is.na(.interpret_effect_size(
    value = 0.4,
    type = NA_character_
  )))
})

test_that(".interpret_effect_size() classifies Cohen's d correctly", {
  expect_identical(.interpret_effect_size(0.10, "Cohen's d"), "Negligible")
  expect_identical(.interpret_effect_size(0.30, "Cohen's d"), "Small")
  expect_identical(.interpret_effect_size(0.60, "Cohen's d"), "Medium")
  expect_identical(.interpret_effect_size(1.00, "Cohen's d"), "Large")
  expect_identical(.interpret_effect_size(1.50, "Cohen's d"), "Very large")
})

test_that(".interpret_effect_size() uses absolute value for Cohen's d", {
  expect_identical(.interpret_effect_size(-0.10, "Cohen's d"), "Negligible")
  expect_identical(.interpret_effect_size(-0.30, "Cohen's d"), "Small")
  expect_identical(.interpret_effect_size(-0.60, "Cohen's d"), "Medium")
  expect_identical(.interpret_effect_size(-1.00, "Cohen's d"), "Large")
  expect_identical(.interpret_effect_size(-1.50, "Cohen's d"), "Very large")
})

test_that(".interpret_effect_size() classifies rank-biserial correctly", {
  expect_identical(.interpret_effect_size(0.05, "Rank-biserial correlation"), "Negligible")
  expect_identical(.interpret_effect_size(0.20, "Rank-biserial correlation"), "Small")
  expect_identical(.interpret_effect_size(0.40, "Rank-biserial correlation"), "Medium")
  expect_identical(.interpret_effect_size(0.70, "Rank-biserial correlation"), "Large")
})

test_that(".interpret_effect_size() classifies matched rank-biserial correctly", {
  expect_identical(.interpret_effect_size(0.05, "Matched rank-biserial correlation"), "Negligible")
  expect_identical(.interpret_effect_size(0.20, "Matched rank-biserial correlation"), "Small")
  expect_identical(.interpret_effect_size(0.40, "Matched rank-biserial correlation"), "Medium")
  expect_identical(.interpret_effect_size(0.70, "Matched rank-biserial correlation"), "Large")
})

test_that(".interpret_effect_size() uses absolute value for rank-biserial types", {
  expect_identical(.interpret_effect_size(-0.05, "Rank-biserial correlation"), "Negligible")
  expect_identical(.interpret_effect_size(-0.20, "Matched rank-biserial correlation"), "Small")
  expect_identical(.interpret_effect_size(-0.40, "Rank-biserial correlation"), "Medium")
  expect_identical(.interpret_effect_size(-0.70, "Matched rank-biserial correlation"), "Large")
})

test_that(".interpret_effect_size() classifies Cramer's V correctly", {
  expect_identical(.interpret_effect_size(0.05, "Cramer's V"), "Negligible")
  expect_identical(.interpret_effect_size(0.20, "Cramer's V"), "Small")
  expect_identical(.interpret_effect_size(0.40, "Cramer's V"), "Medium")
  expect_identical(.interpret_effect_size(0.70, "Cramer's V"), "Large")
})

test_that(".interpret_effect_size() uses absolute value for Cramer's V", {
  expect_identical(.interpret_effect_size(-0.05, "Cramer's V"), "Negligible")
  expect_identical(.interpret_effect_size(-0.20, "Cramer's V"), "Small")
  expect_identical(.interpret_effect_size(-0.40, "Cramer's V"), "Medium")
  expect_identical(.interpret_effect_size(-0.70, "Cramer's V"), "Large")
})

test_that(".interpret_effect_size() returns NA for unsupported type", {
  out <- .interpret_effect_size(0.5, "Unknown effect size")

  expect_true(is.na(out))
})
