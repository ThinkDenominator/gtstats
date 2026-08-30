test_that("describe_data() returns a compact first-look object", {
  res <- describe_data(mtcars)

  expect_s3_class(res, "gt_describe")
  expect_identical(
    names(res$summary),
    c(
      "variable", "label", "type", "complete", "n_unique",
      "overview", "range_levels"
    )
  )
  expect_identical(ncol(res$summary), 7L)
  expect_identical(nrow(res$summary), ncol(mtcars))
  expect_identical(ncol(res$table), 6L)
  expect_false("Name" %in% names(res$table))
  expect_true("Variable" %in% names(res$table))
  expect_true(all(c("summary", "issues", "ordinal", "table", "inputs", "notes") %in%
                    names(res)))
})

test_that("describe_data() has no distribution or inferential overlap", {
  res <- describe_data(mtcars, vars = c("mpg", "cyl", "am"))

  forbidden <- c(
    "skewness", "shapiro_p", "distribution", "suggested_test",
    "suggested_plot", "recommended_summary", "guidance"
  )
  expect_length(intersect(names(res$summary), forbidden), 0L)
  expect_true(grepl("^Mean .*median", res$summary$overview[[1L]]))
})

test_that("describe_data() gives type-specific categorical previews", {
  data <- data.frame(
    outcome = factor(c("No", "Yes", "No", "No")),
    group = factor(c("A", "B", "C", "A"))
  )
  res <- describe_data(data)

  expect_equal(res$summary$type, c("binary", "categorical"))
  expect_match(res$summary$overview[[1L]], "No 3 \\(75.0%\\)")
  expect_match(res$summary$range_levels[[2L]], "A, B, C")
})

test_that("describe_data() consolidates completeness", {
  data <- data.frame(x = c(1, 2, NA, 4))
  res <- describe_data(data)

  expect_equal(res$summary$complete, "3/4 (75.0%)")
  expect_false(any(c(
    "n_total", "n_nonmissing", "n_missing", "pct_missing", "complete_rate"
  ) %in% names(res$summary)))
  expect_true(any(grepl("missing", res$issues$issue, ignore.case = TRUE)))
})

test_that("describe_data() returns only actionable rows in issues", {
  data <- data.frame(
    ok = c(1.2, 2.3, 3.4, 4.5, 5.6, 6.7),
    constant = rep("same", 6),
    incomplete = c(1, NA, NA, 4, NA, 6)
  )
  res <- describe_data(data)

  expect_true(all(c(
    "variable", "label", "issue", "why_flagged", "suggested_check"
  ) %in% names(res$issues)))
  expect_true(all(c("constant", "incomplete") %in% res$issues$variable))
  expect_false("ok" %in% res$issues$variable)
})

test_that("describe_data() respects labels and ordered factors", {
  data <- data.frame(stage = ordered(c("I", "II", "III")))
  attr(data$stage, "label") <- "Disease stage"
  res <- describe_data(data)

  expect_equal(res$summary$label, "Disease stage")
  expect_equal(res$table$Variable, "Disease stage [stage]")
  expect_equal(res$summary$type, "ordinal")
  expect_equal(res$ordinal$classification, "Confirmed ordinal")
})

test_that("describe_data() respects defined factor level order", {
  data <- data.frame(
    race = factor(
      c("Black", "Other", "White", "White"),
      levels = c("White", "Black", "Other")
    ),
    irritability = factor(
      c("Yes", "No", "No", "Yes"),
      levels = c("No", "Yes")
    ),
    visits = ordered(
      c("Two or more", "None", "One", "None"),
      levels = c("None", "One", "Two or more")
    )
  )

  res <- describe_data(data)

  expect_equal(
    res$summary$range_levels,
    c(
      "White, Black, Other",
      "No, Yes",
      "None, One, Two or more"
    )
  )
})

test_that("character levels retain first-seen order", {
  data <- data.frame(x = c("second", "first", "third", "first"))
  res <- describe_data(data)

  expect_equal(res$summary$range_levels, "second, first, third")
})

test_that("describe_data() lists plausible ordinal candidates", {
  data <- data.frame(
    visits = factor(
      c("None", "One", "Two or more", "None"),
      levels = c("None", "One", "Two or more")
    ),
    code = c(0L, 1L, 2L, 3L),
    race = factor(
      c("White", "Black", "Other", "White"),
      levels = c("White", "Black", "Other")
    )
  )
  res <- describe_data(data)

  expect_true(all(c("visits", "code") %in% res$ordinal$variable))
  expect_false("race" %in% res$ordinal$variable)
  expect_equal(
    res$ordinal$classification[res$ordinal$variable == "visits"],
    "Possible ordinal"
  )
  expect_equal(
    res$ordinal$classification[res$ordinal$variable == "code"],
    "Possible ordinal or count"
  )
  expect_true(all(grepl(
    "\\*$",
    res$table$Type[res$summary$variable %in% c("visits", "code")]
  )))
  expect_false(grepl("\\*$", res$table$Type[res$summary$variable == "race"]))
  expect_match(paste(res$notes, collapse = " "), "Possible ordinal")
})

test_that("describe_data() validates inputs", {
  expect_error(describe_data(mtcars, vars = "not_a_var"), "not found")
  expect_error(describe_data(mtcars, digits = -1), "`digits`")
})

test_that("describe_data() renders through supported routes", {
  res <- describe_data(mtcars, vars = c("mpg", "wt", "am"))
  expect_s3_class(to_gt(res), "gt_tbl")
  expect_s3_class(to_flextable(res), "flextable")
})

test_that("describe_data() returns a tibble when requested", {
  res <- describe_data(mtcars, vars = c("mpg", "am"), format = "tibble")
  expect_s3_class(res, "tbl_df")
  expect_identical(ncol(res), 7L)
})
