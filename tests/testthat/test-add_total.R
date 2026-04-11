test_that("add_total() adds total row to ungrouped descriptive table", {
  res <- descriptive_table(mtcars) |>
    add_total()

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(res$table$Variable == "Total (N)"))
  expect_true("Value" %in% names(res$table))
  expect_true(any(res$table$Value == as.character(nrow(mtcars))))
  expect_true("total" %in% res$components)
  expect_true(any(grepl("Totals represent the number of observations", res$footnotes)))
})

test_that("add_total() adds total row to grouped descriptive table", {
  res <- descriptive_table(mtcars, by = am) |>
    add_total()

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(res$table$Variable == "Total (N)"))
  expect_true(all(c("am = 1", "am = 0") %in% names(res$table)))

  idx <- which(res$table$Variable == "Total (N)")
  expect_true(length(idx) == 1)
  expect_equal(res$table$`am = 1`[idx], as.character(sum(mtcars$am == 1, na.rm = TRUE)))
  expect_equal(res$table$`am = 0`[idx], as.character(sum(mtcars$am == 0, na.rm = TRUE)))
})

test_that("add_total() adds total row to grouped descriptive table with overall", {
  res <- descriptive_table(mtcars, by = am, overall = TRUE) |>
    add_total()

  expect_s3_class(res, "gt_desc_table")
  expect_true("Overall" %in% names(res$table))
  idx <- which(res$table$Variable == "Total (N)")
  expect_true(length(idx) == 1)
  expect_equal(res$table$Overall[idx], as.character(nrow(mtcars)))
})

test_that("add_total() supports custom label", {
  res <- descriptive_table(mtcars, by = am) |>
    add_total(label = "Total participants")

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(res$table$Variable == "Total participants"))
})

test_that("add_total() works after summary rows are added", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    add_total()

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(res$table$Variable == "Total (N)"))
})

test_that("add_total() works when table is initially empty", {
  res <- descriptive_table(mtcars, by = am) |>
    add_total()

  expect_s3_class(res, "gt_desc_table")
  expect_equal(nrow(res$table), 1)
  expect_true(any(res$table$Variable == "Total (N)"))
})

test_that("add_total() can be followed by tbl_stats()", {
  gt_obj <- descriptive_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt)) |>
    add_total() |>
    tbl_stats()

  expect_s3_class(gt_obj, "gt_tbl")
})

test_that("add_total() errors if x is not gt_desc_table", {
  expect_error(
    add_total(mtcars),
    regexp = "gt_desc_table"
  )
})

test_that("add_total() errors in non-summary mode", {
  res <- descriptive_table(mtcars, by = am, mode = "rate")

  expect_error(
    add_total(res),
    regexp = "mode = \"summary\""
  )
})

test_that("add_total() errors for invalid label", {
  res <- descriptive_table(mtcars, by = am)

  expect_error(
    add_total(res, label = c("a", "b")),
    regexp = "`label` must be a single character string"
  )
})
