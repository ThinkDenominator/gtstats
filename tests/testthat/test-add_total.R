test_that("add_total() adds total row to ungrouped descriptive table", {
  res <- summary_table(mtcars) |>
    add_total()

  expect_s3_class(res, "gtstats_summary")
  expect_true(any(res$table$Variable == "Total (N)"))
  expect_true("Value" %in% names(res$table))
  expect_true(any(res$table$Value == as.character(nrow(mtcars))))
  expect_true("total" %in% res$components)
  expect_true(any(grepl("Totals represent the number of observations", res$footnotes)))
})

test_that("add_total() adds total row to grouped descriptive table", {
  res <- summary_table(mtcars, by = am) |>
    add_total()

  expect_s3_class(res, "gtstats_summary")
  expect_true(any(res$table$Variable == "Total (N)"))
  expect_true(all(c("am = 1", "am = 0") %in% names(res$table)))

  idx <- which(res$table$Variable == "Total (N)")
  expect_true(length(idx) == 1)
  expect_equal(res$table$`am = 1`[idx], as.character(sum(mtcars$am == 1, na.rm = TRUE)))
  expect_equal(res$table$`am = 0`[idx], as.character(sum(mtcars$am == 0, na.rm = TRUE)))
})

test_that("add_total() adds total row to grouped descriptive table with overall", {
  res <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_total()

  expect_s3_class(res, "gtstats_summary")
  expect_true("Overall" %in% names(res$table))
  idx <- which(res$table$Variable == "Total (N)")
  expect_true(length(idx) == 1)
  expect_equal(res$table$Overall[idx], as.character(nrow(mtcars)))
})

test_that("add_total() supports custom label", {
  res <- summary_table(mtcars, by = am) |>
    add_total(label = "Total participants")

  expect_s3_class(res, "gtstats_summary")
  expect_true(any(res$table$Variable == "Total participants"))
})

test_that("add_total() can place the total row first", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    add_total(position = "first")

  expect_equal(res$table$Variable[[1]], "Total (N)")
})

test_that("add_total() works after summary rows are added", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    add_total()

  expect_s3_class(res, "gtstats_summary")
  expect_true(any(res$table$Variable == "Total (N)"))
})

test_that("add_total() works when table is initially empty", {
  res <- summary_table(mtcars, by = am) |>
    add_total()

  expect_s3_class(res, "gtstats_summary")
  expect_equal(nrow(res$table), 1)
  expect_true(any(res$table$Variable == "Total (N)"))
})

test_that("add_total() can be followed by to_gt()", {
  gt_obj <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt)) |>
    add_total() |>
    to_gt()

  expect_s3_class(gt_obj, "gt_tbl")
})

test_that("add_total() errors if x is not gtstats_summary", {
  expect_error(
    add_total(mtcars),
    regexp = "gtstats_summary"
  )
})

test_that("add_total() works on an empty summary builder", {
  res <- summary_table(mtcars, by = am)
  result <- add_total(res)
  expect_true("total" %in% result$components)
})

test_that("add_total() errors for invalid label", {
  res <- summary_table(mtcars, by = am)

  expect_error(
    add_total(res, label = c("a", "b")),
    regexp = "`label` must be a single non-empty character string"
  )
  expect_error(
    add_total(res, label = ""),
    regexp = "`label` must be a single non-empty character string"
  )
})

test_that("add_total() prevents duplicate cohort total rows", {
  res <- summary_table(mtcars, by = am) |>
    add_total()

  expect_error(
    add_total(res),
    "already been added"
  )
})
