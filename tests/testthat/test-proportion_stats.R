test_that("proportion_stats() works without grouping", {
  res <- proportion_stats(mtcars, var = vs)

  expect_s3_class(res, "gt_prop")
  expect_true(is.list(res))
  expect_true(all(c("summary", "table", "inputs", "notes") %in% names(res)))
  expect_equal(nrow(res$table), 1)
  expect_true(any(grepl("does not test differences", res$notes)))
  expect_true(any(grepl("independent", res$notes)))
})

test_that("proportion_stats() works with grouping", {
  res <- proportion_stats(mtcars, var = vs, by = am)

  expect_s3_class(res, "gt_prop")
  expect_equal(res$inputs$by, "am")
  expect_equal(nrow(res$table), 2)
})

test_that("proportion_stats() accepts character input", {
  res <- proportion_stats(mtcars, var = "vs", by = "am")

  expect_s3_class(res, "gt_prop")
  expect_equal(res$inputs$var, "vs")
  expect_equal(res$inputs$by, "am")
})

test_that("proportion_stats() supports explicit level", {
  res <- proportion_stats(mtcars, var = vs, by = am, level = "1")

  expect_s3_class(res, "gt_prop")
  expect_equal(as.character(res$inputs$level), "1")
})

test_that("proportion_stats() validates confidence level consistently", {
  expect_error(
    proportion_stats(mtcars, var = vs, conf.level = 1),
    "between 0 and 1"
  )
})

test_that("proportion_stats() returns formatted proportion strings", {
  res <- proportion_stats(mtcars, var = vs)

  expect_identical(names(res$table), c("Group", "N", "Estimate (95% CI)"))
  expect_true(any(grepl("%", res$table[["Estimate (95% CI)"]])))
  expect_true(any(grepl("–", res$table[["Estimate (95% CI)"]], fixed = TRUE)))
})

test_that("proportion_stats() grouped output includes Group column", {
  res <- proportion_stats(mtcars, var = vs, by = am)

  expect_true("Group" %in% names(res$table))
})

test_that("tbl_stats() works on proportion_stats output", {
  gt_obj <- proportion_stats(mtcars, var = vs, by = am) |>
    tbl_stats()

  expect_s3_class(gt_obj, "gt_tbl")
})

test_that("to_flextable() works on proportion_stats output", {
  ft <- proportion_stats(mtcars, var = vs, by = am) |>
    to_flextable()

  expect_s3_class(ft, "flextable")
})

test_that("proportion_stats() errors for missing variable", {
  expect_error(
    proportion_stats(mtcars, var = not_a_var),
    regexp = "not found"
  )
})

test_that("proportion_stats() errors for missing grouping variable", {
  expect_error(
    proportion_stats(mtcars, var = vs, by = not_a_var),
    regexp = "not found"
  )
})

test_that("proportion_stats() errors for invalid level", {
  expect_error(
    proportion_stats(mtcars, var = vs, level = "not_a_level"),
    regexp = "level"
  )
})

test_that("proportion_stats() uses Wilson intervals by default", {
  res <- proportion_stats(mtcars, var = vs)

  expect_identical(res$inputs$ci_method, "wilson")
  expect_identical(res$method$interval, "Wilson score")
  expect_equal(res$summary$conf_low / 100, 0.2817, tolerance = 0.001)
  expect_match(res$notes[[1L]], "Selected event: vs = 1", fixed = TRUE)
})

test_that("proportion_stats() supports exact intervals", {
  res <- proportion_stats(mtcars, var = vs, ci_method = "exact")
  expected <- stats::binom.test(14, 32)$conf.int

  expect_identical(res$method$interval, "Exact binomial")
  expect_equal(res$summary$conf_low / 100, expected[[1L]])
  expect_equal(res$summary$conf_high / 100, expected[[2L]])
})

test_that("proportion_stats() supports all display choices", {
  n_percent <- proportion_stats(
    mtcars, var = vs, display = "n_percent"
  )
  percent <- proportion_stats(
    mtcars, var = vs, display = "percent"
  )
  fraction <- proportion_stats(
    mtcars, var = vs, display = "n_over_N_percent"
  )

  expect_match(n_percent$table[["Estimate (95% CI)"]], "^14 \\(43.8%\\)")
  expect_match(percent$table[["Estimate (95% CI)"]], "^43.8%")
  expect_match(
    fraction$table[["Estimate (95% CI)"]],
    "^14/32 \\(43.8%\\)"
  )
})

test_that("proportion_stats() handles zero and all events", {
  dat <- data.frame(
    event = factor(c("No", "No", "Yes", "Yes")),
    group = factor(c("zero", "zero", "all", "all"))
  )
  res <- proportion_stats(dat, event, by = group, level = "Yes")

  expect_equal(res$summary$count[res$summary$group == "zero"], 0)
  expect_equal(res$summary$count[res$summary$group == "all"], 2)
  expect_equal(res$summary$proportion[res$summary$group == "zero"], 0)
  expect_equal(res$summary$proportion[res$summary$group == "all"], 100)
  expect_true(all(is.finite(res$summary$conf_low)))
  expect_true(all(is.finite(res$summary$conf_high)))
})

test_that("proportion_stats() uses non-missing outcome denominators", {
  dat <- data.frame(
    event = factor(c("No", "Yes", NA, "Yes")),
    group = factor(c("A", "A", "A", "B"))
  )
  res <- proportion_stats(dat, event, by = group, level = "Yes")

  expect_equal(res$table$N, c(2, 1))
  expect_equal(res$summary$count, c(1, 1))
  expect_equal(res$denominators$n_missing, c(1, 0))
})
