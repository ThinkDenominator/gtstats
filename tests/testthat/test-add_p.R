test_that("add_p() adds p-values with default auto method", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt, cyl)) |>
    add_p()

  expect_s3_class(res, "gt_desc_table")
  expect_true("p-value" %in% names(res$table))
  expect_true(any(res$table$`p-value` != ""))
  expect_true("p_value" %in% res$components)
  expect_true(length(res$pvalue_method_footnotes) >= 1)
})

test_that("add_p() works with named method vector", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt, cyl)) |>
    add_p(method = c(mpg = "welch_t", wt = "wilcox", cyl = "chisq"))

  expect_s3_class(res, "gt_desc_table")
  expect_true("p-value" %in% names(res$table))
  expect_true(any(grepl("<|[0-9]", res$table$`p-value`)))
  expect_true(any(grepl("Welch t-test", res$pvalue_method_footnotes)))
  expect_true(any(grepl("Wilcoxon rank-sum test", res$pvalue_method_footnotes)))
  expect_true(any(grepl("Chi-square test", res$pvalue_method_footnotes)))
})

test_that("add_p() supports paired t-test", {
  dat <- data.frame(
    period = c("before", "before", "before", "before",
               "after",  "after",  "after",  "after"),
    score = c(10, 12, 9, 11, 13, 16, 11, 15)
  )

  res <- descriptive_table(dat, by = period) |>
    add_summary(vars = c(score)) |>
    add_p(paired = TRUE, method = "t_test")

  expect_true("p-value" %in% names(res$table))
  expect_true(any(res$table$`p-value` != ""))
  expect_true(any(grepl("Paired t-test", res$pvalue_method_footnotes)))
})

test_that("add_p() supports paired Wilcoxon signed-rank test", {
  dat <- data.frame(
    period = c("before", "before", "before", "before",
               "after",  "after",  "after",  "after"),
    score = c(10, 12, 9, 11, 13, 16, 11, 15)
  )

  res <- descriptive_table(dat, by = period) |>
    add_summary(vars = c(score)) |>
    add_p(paired = TRUE, method = "wilcox")

  expect_true("p-value" %in% names(res$table))
  expect_true(any(res$table$`p-value` != ""))
  expect_true(any(grepl("Wilcoxon signed-rank test", res$pvalue_method_footnotes)))
})

test_that("add_p() skips total rows when assigning p-values", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    add_total() |>
    add_p()

  total_row <- which(res$table$Variable %in% c("Total", "Total (N)", "Total participants"))
  expect_true(length(total_row) >= 1)
  expect_true(all(res$table$`p-value`[total_row] == ""))
})

test_that("add_p() places p-values only on first row of each variable block", {
  res <- descriptive_table(mtcars, by = am) |>
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
  res <- descriptive_table(mtcars) |>
    add_summary(vars = c(mpg, wt))

  expect_error(
    add_p(res),
    regexp = "requires a grouping variable"
  )
})

test_that("add_p() errors if no rows have been added", {
  res <- descriptive_table(mtcars, by = am)

  expect_error(
    add_p(res),
    regexp = "No rows have been added yet"
  )
})

test_that("add_p() errors for unsupported single method", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg))

  expect_error(
    add_p(res, method = "not_a_test"),
    regexp = "Unsupported `method`"
  )
})

test_that("add_p() errors for unsupported named method", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg))

  expect_error(
    add_p(res, method = c(mpg = "not_a_test")),
    regexp = "Unsupported `method`"
  )
})

test_that("add_p() accepts list method input", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, cyl)) |>
    add_p(method = list(mpg = "welch_t", cyl = "fisher"))

  expect_true(any(grepl("Welch t-test", res$pvalue_method_footnotes)))
  expect_true(any(grepl("Fisher's exact test", res$pvalue_method_footnotes)))
})

test_that("add_p() works with overall column present", {
  res <- descriptive_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt, cyl)) |>
    add_proportion(var = vs) |>
    add_total() |>
    add_p()

  expect_s3_class(res, "gt_desc_table")
  expect_true("Overall" %in% names(res$table))
  expect_true("p-value" %in% names(res$table))
  expect_true(any(res$table$`p-value` != ""))
})
