test_that("twobytwo_table() works with default settings", {
  res <- twobytwo_table(mtcars, exposure = am, outcome = vs)

  expect_s3_class(res, "gt_twobytwo")
  expect_true(is.list(res))
  expect_true(all(c("summary", "table", "inputs", "notes") %in% names(res)))
  expect_equal(nrow(res$table), 8)
})

test_that("twobytwo_table() accepts character input", {
  res <- twobytwo_table(mtcars, exposure = "am", outcome = "vs")

  expect_s3_class(res, "gt_twobytwo")
  expect_equal(res$inputs$exposure, "am")
  expect_equal(res$inputs$outcome, "vs")
})

test_that("twobytwo_table() includes expected measure labels", {
  res <- twobytwo_table(mtcars, exposure = am, outcome = vs)

  expect_true(all(c(
    "Risk in exposed",
    "Risk in unexposed",
    "Risk ratio",
    "Odds ratio",
    "Risk difference",
    "P-value"
  ) %in% res$table$Measure))
})

test_that("twobytwo_table() supports subset of measures", {
  res <- twobytwo_table(
    mtcars,
    exposure = am,
    outcome = vs,
    measures = c("risk", "rr")
  )

  expect_s3_class(res, "gt_twobytwo")
  expect_true("Risk in exposed" %in% res$table$Measure)
  expect_true("Risk in unexposed" %in% res$table$Measure)
  expect_true("Risk ratio" %in% res$table$Measure)
  expect_false("Odds ratio" %in% res$table$Measure)
  expect_false("Risk difference" %in% res$table$Measure)
})

test_that("twobytwo_table() supports explicit levels", {
  res <- twobytwo_table(
    mtcars,
    exposure = am,
    outcome = vs,
    exposed_level = "1",
    outcome_level = "1"
  )

  expect_s3_class(res, "gt_twobytwo")
  expect_equal(res$inputs$exposed_level, "1")
  expect_equal(res$inputs$outcome_level, "1")
})

test_that("twobytwo_table() supports Fisher's exact test", {
  res <- twobytwo_table(
    mtcars,
    exposure = am,
    outcome = vs,
    test = "fisher"
  )

  expect_s3_class(res, "gt_twobytwo")
  expect_true(any(grepl("P-value", res$table$Measure)))
  expect_true(any(grepl("Fisher", res$notes)))
})

test_that("twobytwo_table() supports Chi-square test", {
  res <- twobytwo_table(
    mtcars,
    exposure = am,
    outcome = vs,
    test = "chisq"
  )

  expect_s3_class(res, "gt_twobytwo")
  expect_true(any(grepl("Chi-square", res$notes)))
})

test_that("twobytwo_table() auto chooses a valid p-value test", {
  res <- twobytwo_table(mtcars, exposure = am, outcome = vs, test = "auto")

  expect_s3_class(res, "gt_twobytwo")
  expect_true(any(grepl("P-value", res$table$Measure)))
  expect_true(any(grepl("test", res$notes, ignore.case = TRUE)))
})

test_that("twobytwo_table() returns formatted values", {
  res <- twobytwo_table(mtcars, exposure = am, outcome = vs)

  expect_true(all(c("Measure", "Value") %in% names(res$table)))
  expect_true(any(grepl("%", res$table$Value)))
  expect_true(any(grepl("\\(", res$table$Value)))
})

test_that("twobytwo_table() errors when exposure is not binary", {
  expect_error(
    twobytwo_table(mtcars, exposure = cyl, outcome = vs),
    regexp = "exactly 2 non-missing levels"
  )
})

test_that("twobytwo_table() errors when outcome is not binary", {
  expect_error(
    twobytwo_table(mtcars, exposure = am, outcome = cyl),
    regexp = "exactly 2 non-missing levels"
  )
})

test_that("twobytwo_table() errors for invalid exposure name", {
  expect_error(
    twobytwo_table(mtcars, exposure = not_a_var, outcome = vs),
    regexp = "`exposure` was not found"
  )
})

test_that("twobytwo_table() errors for invalid outcome name", {
  expect_error(
    twobytwo_table(mtcars, exposure = am, outcome = not_a_var),
    regexp = "`outcome` was not found"
  )
})

test_that("twobytwo_table() errors when exposure and outcome are the same", {
  expect_error(
    twobytwo_table(mtcars, exposure = am, outcome = am),
    regexp = "must be different variables"
  )
})

test_that("tbl_stats() works on twobytwo_table output", {
  gt_obj <- twobytwo_table(mtcars, exposure = am, outcome = vs) |>
    tbl_stats()

  expect_s3_class(gt_obj, "gt_tbl")
})

test_that("to_flextable() works on twobytwo_table output", {
  ft <- twobytwo_table(mtcars, exposure = am, outcome = vs) |>
    to_flextable()

  expect_s3_class(ft, "flextable")
})
