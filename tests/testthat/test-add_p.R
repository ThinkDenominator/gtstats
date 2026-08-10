test_that("add_p() adds p-values with default auto method", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt, cyl)) |>
    add_p()

  expect_s3_class(res, "gt_desc_table")
  expect_true("p-value" %in% names(res$table))
  expect_true(any(res$table$`p-value` != ""))
  expect_true("p_value" %in% res$components)
  expect_true(length(res$pvalue_method_footnotes) >= 1)
  expect_true(any(grepl("distribution guidance: yes", res$assumption_notes)))
  expect_true(any(res$diagnostics$check == "Automatic test selection"))
  expect_true(any(res$diagnostics$check == "Observed group spread"))
  expect_true(all(c("variable", "check", "result", "value") %in%
    names(res$diagnostics)))
})

test_that("add_p() uses distribution-aware automatic selection by default", {
  dat <- data.frame(
    group = rep(c("A", "B"), each = 20),
    value = c(seq_len(19), 500, seq_len(19), 600)
  )

  res <- summary_table(dat, by = group) |>
    add_summary(vars = value) |>
    add_p()

  expect_true(any(grepl("Wilcoxon", res$pvalue_method_footnotes)))
  expect_true(any(
    res$diagnostics$variable == "value" &
      res$diagnostics$check == "Distribution guidance"
  ))
})

test_that("add_p() supports Welch ANOVA for more than two groups", {
  dat <- data.frame(
    group = factor(rep(c("A", "B", "C"), each = 10)),
    value = c(1:10, 2:11, 3:12)
  )

  res <- summary_table(dat, by = group) |>
    add_summary(vars = value) |>
    add_p(normality_check = FALSE)

  expect_true(any(grepl("Welch ANOVA", res$pvalue_method_footnotes)))
})

test_that("add_p() forwards var_equal through two- and multi-group auto routes", {
  two_group <- summary_table(mtcars, by = am) |>
    add_summary(vars = mpg) |>
    add_p(normality_check = FALSE, var_equal = TRUE)
  multi_group <- summary_table(mtcars, by = cyl) |>
    add_summary(vars = mpg) |>
    add_p(normality_check = FALSE, var_equal = TRUE)

  expect_true(any(grepl("Student t-test", two_group$pvalue_method_footnotes)))
  expect_true(any(grepl("ANOVA", multi_group$pvalue_method_footnotes)))
})

test_that("add_p() works with named method vector", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt, cyl)) |>
    add_p(method = c(mpg = "welch_t", wt = "wilcox", cyl = "chisq"))

  expect_s3_class(res, "gt_desc_table")
  expect_true("p-value" %in% names(res$table))
  expect_true(any(grepl("<|[0-9]", res$table$`p-value`)))
  expect_true(any(grepl("Welch t-test", res$pvalue_method_footnotes)))
  expect_true(any(grepl("Wilcoxon rank-sum test", res$pvalue_method_footnotes)))
  expect_true(any(grepl("Chi-square test", res$pvalue_method_footnotes)))
})

test_that("add_p() safely resolves methods when variable labels are used", {
  dat <- mtcars
  attr(dat$mpg, "label") <- "Fuel economy"

  res <- summary_table(dat, by = am) |>
    add_summary(vars = mpg) |>
    add_p(method = c(mpg = "welch_t"))

  expect_true(any(res$table$`p-value` != ""))
  expect_true(any(grepl("Welch t-test", res$pvalue_method_footnotes)))
})

test_that("add_p() preserves clinical labels containing parentheses", {
  dat <- mtcars
  attr(dat$mpg, "label") <- "Fuel economy (mpg)"
  attr(dat$wt, "label") <- "Vehicle weight (1000 lb)"

  res <- summary_table(dat, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    add_p(method = c(mpg = "welch_t", wt = "wilcox"))

  mpg_row <- match("Fuel economy (mpg)", res$table$Variable)
  wt_row <- match("Vehicle weight (1000 lb)", res$table$Variable)

  expect_false(is.na(mpg_row))
  expect_false(is.na(wt_row))
  expect_true(nzchar(res$table$`p-value`[[mpg_row]]))
  expect_true(nzchar(res$table$`p-value`[[wt_row]]))
  expect_true(any(grepl("Welch t-test", res$pvalue_method_footnotes)))
  expect_true(any(grepl("Wilcoxon", res$pvalue_method_footnotes)))
})

test_that("add_p() supports paired t-test", {
  dat <- data.frame(
    id = rep(1:4, 2),
    period = c("before", "before", "before", "before",
               "after",  "after",  "after",  "after"),
    score = c(10, 12, 9, 11, 13, 16, 11, 15)
  )

  res <- summary_table(dat, by = period) |>
    add_summary(vars = c(score)) |>
    add_p(paired = TRUE, id = id, method = "t_test")

  expect_true("p-value" %in% names(res$table))
  expect_true(any(res$table$`p-value` != ""))
  expect_true(any(grepl("Paired t-test", res$pvalue_method_footnotes)))
})

test_that("add_p() supports paired Wilcoxon signed-rank test", {
  dat <- data.frame(
    id = rep(1:4, 2),
    period = c("before", "before", "before", "before",
               "after",  "after",  "after",  "after"),
    score = c(10, 12, 9, 11, 13, 16, 11, 15)
  )

  res <- summary_table(dat, by = period) |>
    add_summary(vars = c(score)) |>
    add_p(paired = TRUE, id = id, method = "wilcox")

  expect_true("p-value" %in% names(res$table))
  expect_true(any(res$table$`p-value` != ""))
  expect_true(any(grepl("Wilcoxon signed-rank test", res$pvalue_method_footnotes)))
})

test_that("add_p() skips total rows when assigning p-values", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    add_total() |>
    add_p()

  total_row <- which(res$table$Variable %in% c("Total", "Total (N)", "Total participants"))
  expect_true(length(total_row) >= 1)
  expect_true(all(res$table$`p-value`[total_row] == ""))
})

test_that("add_p() places p-values only on first row of each variable block", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(cyl)) |>
    add_p()

  cyl_rows <- which(res$table$Variable == "cyl")
  expect_true(length(cyl_rows) >= 1)

  first_nonempty <- cyl_rows[1]
  remaining <- cyl_rows[-1]

  expect_true(res$table$`p-value`[first_nonempty] != "")
  if (length(remaining) > 0) {
    expect_true(all(res$table$`p-value`[remaining] == ""))
  }
})

test_that("add_p() errors if x is not gt_desc_table", {
  expect_error(
    add_p(mtcars),
    regexp = "gt_desc_table"
  )
})

test_that("add_p() errors if no grouping variable is supplied", {
  res <- summary_table(mtcars) |>
    add_summary(vars = c(mpg, wt))

  expect_error(
    add_p(res),
    regexp = "requires a grouping variable"
  )
})

test_that("add_p() errors if no rows have been added", {
  res <- summary_table(mtcars, by = am)

  expect_error(
    add_p(res),
    regexp = "No rows have been added yet"
  )
})

test_that("add_p() errors for unsupported single method", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg))

  expect_error(
    add_p(res, method = "not_a_test"),
    regexp = "Unsupported `method`"
  )
})

test_that("add_p() errors for unsupported named method", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg))

  expect_error(
    add_p(res, method = c(mpg = "not_a_test")),
    regexp = "Unsupported `method`"
  )
})

test_that("add_p() accepts list method input", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, cyl)) |>
    add_p(method = list(mpg = "welch_t", cyl = "fisher"))

  expect_true(any(grepl("Welch t-test", res$pvalue_method_footnotes)))
  expect_true(any(grepl("Fisher's exact test", res$pvalue_method_footnotes)))
})

test_that("add_p() works with overall column present", {
  res <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt, cyl)) |>
    add_proportion(var = vs) |>
    add_total() |>
    add_p()

  expect_s3_class(res, "gt_desc_table")
  expect_true("Overall" %in% names(res$table))
  expect_true("p-value" %in% names(res$table))
  expect_true(any(res$table$`p-value` != ""))
})
test_that("add_p() retains raw and multiplicity-adjusted p-values", {
  result <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt, vs)) |>
    add_p(p_adjust = "BH")

  expect_true(all(c(
    "variable", "test", "p_value", "p_adjusted", "p_adjust_method"
  ) %in% names(result$p_values)))
  expect_true(all(result$p_values$p_adjust_method == "BH"))
  expect_equal(
    result$p_values$p_adjusted,
    stats::p.adjust(result$p_values$p_value, method = "BH")
  )
  expect_true(any(grepl("BH multiplicity", result$assumption_notes)))
})
