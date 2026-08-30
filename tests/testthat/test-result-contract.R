test_that("analytical results expose the shared result contract", {
  rate_data <- data.frame(events = c(1, 2), time = c(10, 12))
  objects <- list(
    compare_groups(mtcars, variable = mpg, group = am),
    effect_size(mtcars, variable = mpg, group = am),
    correlation(mtcars, x = mpg, y = wt),
    proportion_stats(mtcars, var = vs),
    rate_stats(rate_data, event = events, time = time),
    crosstabs(mtcars, row = am, col = vs)
  )

  for (object in objects) {
    expect_s3_class(object, "gtstats")
    expect_true(all(c(
      "inputs", "table", "method", "assumptions",
      "diagnostics", "denominators", "notes", "call"
    ) %in% names(object)))
    expect_s3_class(object$assumptions, "tbl_df")
    expect_s3_class(object$diagnostics, "tbl_df")
    expect_s3_class(object$denominators, "tbl_df")
    expect_true(all(
      c("assumption", "status", "result", "detail") %in%
        names(object$assumptions)
    ))
    expect_true(all(
      c("check", "result", "value", "threshold", "detail") %in%
        names(object$diagnostics)
    ))
    expect_true(all(
      c(
        "variable", "group", "n_total", "n_nonmissing", "n_missing",
        "numerator", "denominator", "rule"
      ) %in% names(object$denominators)
    ))
  }
})

test_that("descriptive inspection objects use purpose-specific contracts", {
  overview <- describe_data(mtcars)
  distribution <- assess_distribution(mtcars, vars = "mpg")

  expect_true(all(c("summary", "issues", "ordinal", "table", "inputs", "notes") %in%
                    names(overview)))
  expect_false(any(c("assumptions", "diagnostics", "denominators") %in%
                     names(overview)))
  expect_true(all(c("summary", "table", "inputs", "notes") %in%
                    names(distribution)))
  expect_false(any(c("assumptions", "diagnostics", "denominators") %in%
                     names(distribution)))
})

test_that("summary table builder retains structured inferential metadata", {
  result <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, vs)) |>
    add_p()

  expect_s3_class(result$assumptions, "tbl_df")
  expect_s3_class(result$diagnostics, "tbl_df")
  expect_true("variable" %in% names(result$assumptions))
  expect_true("variable" %in% names(result$diagnostics))
  expect_true(all(c("mpg", "vs") %in% result$assumptions$variable))
  expect_true(all(c("mpg", "vs") %in% result$denominators$variable))
})

test_that("inspection helpers return tibble and gt routes", {
  result <- compare_groups(mtcars, variable = vs, group = am)

  expect_s3_class(assumptions_stats(result), "gt_tbl")
  expect_named(
    assumptions_stats(result, format = "tibble"),
    c("Variable", "Check before reporting", "Action", "Details")
  )
  expect_true("status" %in% names(assumptions_stats(result, format = "tibble", view = "audit")))
  expect_s3_class(diagnostics_stats(result), "gt_tbl")
  expect_s3_class(denominators_stats(result), "gt_tbl")
  expect_true(all(c("Check", "Observed value", "Interpretation") %in%
    names(diagnostics_stats(result, format = "tibble"))))
  expect_true(all(diagnostics_stats(result, format = "tibble")$Variable == "vs"))
  expect_true(all(assumptions_stats(result, format = "tibble")$Variable == "vs"))
  expect_true(all(c("Used in analysis", "Missing / excluded", "Rule") %in%
    names(denominators_stats(result, format = "tibble"))))
  expect_true("check" %in% names(diagnostics_stats(result, format = "tibble", view = "audit")))
  expect_true("n_nonmissing" %in% names(denominators_stats(result, format = "tibble", view = "audit")))
  expect_s3_class(assumptions_stats(result, format = "table"), "gt_tbl")
  expect_s3_class(diagnostics_stats(result, format = "table"), "gt_tbl")
  expect_s3_class(denominators_stats(result, format = "table"), "gt_tbl")
})

test_that("inspection helpers reject unsupported objects", {
  expect_error(assumptions_stats(mtcars), "gtstats")
  expect_error(diagnostics_stats(mtcars), "gtstats")
  expect_error(denominators_stats(mtcars), "gtstats")
})
