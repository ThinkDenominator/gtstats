test_that("crosstabs() creates a publication-ready 2x2 table", {
  result <- crosstabs(mtcars, row = am, col = vs)

  expect_s3_class(result, "gt_twobytwo")
  expect_true(all(c("am", "0", "1", "Total") %in% names(result$table)))
  expect_equal(nrow(result$table), 3L)
  expect_match(result$table[["0"]][[1]], "%")
  expect_true(is.data.frame(result$epi))
  expect_true(all(c("Risk ratio", "Odds ratio", "Risk difference") %in% result$epi$Measure))
  expect_true(any(result$assumptions$assumption == "Correct exposure and event direction"))
  expect_true(any(result$diagnostics$check == "Zero cells"))
  expect_false(is.null(result$inputs$row_level))
  expect_false(is.null(result$inputs$col_level))
  expect_false(any(grepl("Complete pairs", result$notes, fixed = TRUE)))
  expect_true(any(grepl("Complete observations: N = 32", result$notes, fixed = TRUE)))
  expect_true(all(diagnostics_stats(result, format = "tibble")$Variable == "vs"))
})

test_that("crosstabs() supports row, column, total, and combined percentages", {
  row_only <- crosstabs(mtcars, row = cyl, col = am, percent = "row")
  both <- crosstabs(mtcars, row = cyl, col = am, percent = c("row", "column"))
  overall <- crosstabs(mtcars, row = cyl, col = am, percent = "total")

  expect_match(row_only$table[["0"]][[1]], "%")
  expect_match(both$table[["0"]][[1]], "Row.*Col")
  expect_match(overall$table[["0"]][[1]], "%")
})

test_that("crosstabs() supports 3x2 and 3x3 tables", {
  three_by_two <- crosstabs(mtcars, row = cyl, col = am)
  three_by_three <- crosstabs(mtcars, row = cyl, col = gear)

  expect_equal(nrow(three_by_two$counts), 3L)
  expect_equal(ncol(three_by_two$counts), 2L)
  expect_null(three_by_two$epi)
  expect_equal(nrow(three_by_three$counts), 3L)
  expect_equal(ncol(three_by_three$counts), 3L)
  expect_true(is.finite(three_by_three$method$cramers_v))
})

test_that("crosstabs() selects an appropriate association test", {
  sparse <- data.frame(
    row = factor(c(rep("A", 8), rep("B", 4), rep("C", 3))),
    col = factor(c(rep("No", 7), "Yes", rep("No", 5), rep("Yes", 2)))
  )
  result <- crosstabs(sparse, row, col)

  expect_true(result$method$sparse)
  expect_match(result$method$association_test, "Fisher")
  expect_true(result$method$fisher_simulated)
})

test_that("crosstabs() keeps 2x2 direction explicit", {
  result <- crosstabs(
    mtcars, row = am, col = vs,
    row_level = "1", col_level = "1", measures = c("risk", "rr", "rd")
  )

  expect_identical(result$inputs$row_level, "1")
  expect_identical(result$inputs$col_level, "1")
  expect_true(all(c("Risk", "Risk ratio", "Risk difference") %in% result$epi$Measure))
  expect_match(result$method$selection_rule, "expected cell")
})

test_that("crosstabs() displays requested 2x2 measures in the rendered output", {
  result <- crosstabs(mtcars, row = am, col = vs, measures = "or")

  expect_identical(result$epi$Measure, "Odds ratio")
  expect_true(any(grepl("OR ", result$notes, fixed = TRUE)))
  expect_true(any(grepl("Exposure:", result$notes, fixed = TRUE)))
  expect_s3_class(tbl_stats(result), "gt_tbl")
})

test_that("crosstabs() omits test wording cleanly when tests are disabled", {
  result <- crosstabs(
    mtcars,
    row = am,
    col = vs,
    measures = "or",
    test = "none"
  )

  expect_match(result$notes[[1L]], "Cells are n ", fixed = TRUE)
  expect_match(result$notes[[1L]], "Cramer's V", fixed = TRUE)
  expect_false(grepl("None", result$notes[[1L]], fixed = TRUE))
  expect_false(grepl("\\.Cramer's", result$notes[[1L]]))
})

test_that("crosstabs() retains zero-cell diagnostics and correction details", {
  dat <- data.frame(
    exposure = factor(rep(c("No", "Yes"), each = 10)),
    outcome = factor(c(rep("No", 10), rep(c("No", "Yes"), c(5, 5))))
  )
  result <- crosstabs(dat, exposure, outcome)

  zero_row <- result$diagnostics[result$diagnostics$check == "Zero cells", ]
  expect_identical(zero_row$result, "present")
  expect_match(zero_row$detail, "Haldane-Anscombe")
  expect_true(any(grepl("Zero cell:", result$notes, fixed = TRUE)))
  expect_identical(result$method$zero_cell_correction, "haldane_anscombe")
})

test_that("crosstabs() validates categorical structure", {
  expect_error(crosstabs(mtcars, missing, vs), "columns in `data`")
  expect_error(crosstabs(mtcars, am, am), "must be different")
  expect_error(crosstabs(mtcars, cyl, am, row_level = "4"), "only for a binary 2x2")
  expect_error(crosstabs(mtcars, cyl, am, percent = "bad"), "percent")
  expect_error(crosstabs(mtcars, cyl, am, percent = c("none", "row")), "cannot be combined")
})

test_that("crosstabs() displays blank category values safely", {
  dat <- data.frame(
    exposure = factor(c("", "", "Exposed", "Exposed")),
    outcome = factor(c("No", "Yes", "No", "Yes"))
  )

  result <- crosstabs(dat, exposure, outcome)

  expect_s3_class(result, "gt_twobytwo")
  expect_true("(blank)" %in% result$table[[1L]])
})

test_that("crosstabs() renders and exports", {
  result <- crosstabs(mtcars, cyl, gear, percent = c("row", "column"))
  expect_s3_class(tbl_stats(result), "gt_tbl")
  expect_s3_class(to_flextable(result), "flextable")
})
