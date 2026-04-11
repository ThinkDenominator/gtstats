test_that("add_proportion() adds proportion row to ungrouped descriptive table", {
  res <- descriptive_table(mtcars) |>
    add_proportion(var = vs)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("^vs", res$table$Variable)))
  expect_true("Value" %in% names(res$table))
  expect_true("proportion" %in% res$components)
  expect_true(any(grepl("Proportions are shown as %", res$footnotes)))
})

test_that("add_proportion() adds proportion row to grouped descriptive table", {
  res <- descriptive_table(mtcars, by = am) |>
    add_proportion(var = vs)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("^vs", res$table$Variable)))
  expect_true(all(c("am = 1", "am = 0") %in% names(res$table)))
})

test_that("add_proportion() adds proportion row to grouped table with overall", {
  res <- descriptive_table(mtcars, by = am, overall = TRUE) |>
    add_proportion(var = vs)

  expect_s3_class(res, "gt_desc_table")
  expect_true("Overall" %in% names(res$table))
  expect_true(any(grepl("^vs", res$table$Variable)))
})

test_that("add_proportion() accepts character variable name", {
  res <- descriptive_table(mtcars, by = am) |>
    add_proportion(var = "vs")

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("^vs", res$table$Variable)))
})

test_that("add_proportion() supports explicit level", {
  res <- descriptive_table(mtcars, by = am) |>
    add_proportion(var = vs, level = "1")

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("\\(1\\)", res$table$Variable)))
})

test_that("add_proportion() supports custom label", {
  res <- descriptive_table(mtcars, by = am) |>
    add_proportion(var = vs, label = "Engine shape")

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("^Engine shape", res$table$Variable)))
})

test_that("add_proportion() supports ci = FALSE", {
  res <- descriptive_table(mtcars, by = am) |>
    add_proportion(var = vs, ci = FALSE)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("Proportions are shown as %\\.", res$footnotes)))
})

test_that("add_proportion() works for categorical variable", {
  res <- descriptive_table(mtcars, by = am) |>
    add_proportion(var = cyl)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("^cyl", res$table$Variable)))
})

test_that("add_proportion() chooses level automatically for binary variable", {
  res <- descriptive_table(mtcars, by = am) |>
    add_proportion(var = vs)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("\\(", res$table$Variable)))
})

test_that("add_proportion() can be followed by tbl_stats()", {
  gt_obj <- descriptive_table(mtcars, by = am, overall = TRUE) |>
    add_proportion(var = vs) |>
    tbl_stats()

  expect_s3_class(gt_obj, "gt_tbl")
})

test_that("add_proportion() errors if x is not gt_desc_table", {
  expect_error(
    add_proportion(mtcars, var = vs),
    regexp = "gt_desc_table"
  )
})

test_that("add_proportion() errors in non-summary mode", {
  res <- descriptive_table(mtcars, by = am, mode = "rate")

  expect_error(
    add_proportion(res, var = vs),
    regexp = "mode = \"summary\""
  )
})

test_that("add_proportion() errors if variable is missing", {
  res <- descriptive_table(mtcars, by = am)

  expect_error(
    add_proportion(res, var = not_a_var),
    regexp = "`var` was not found"
  )
})

test_that("add_proportion() errors for continuous variable", {
  res <- descriptive_table(mtcars, by = am)

  expect_error(
    add_proportion(res, var = mpg),
    regexp = "supports binary, categorical, or ordinal variables"
  )
})

test_that("add_proportion() errors when requested level is absent", {
  res <- descriptive_table(mtcars, by = am)

  expect_error(
    add_proportion(res, var = vs, level = "not_a_level"),
    regexp = "`level` was not found"
  )
})

test_that("add_proportion() errors when variable has no non-missing values", {
  df <- data.frame(
    x = c(NA, NA, NA),
    grp = c("a", "a", "b")
  )

  res <- descriptive_table(df, by = grp)

  expect_error(
    add_proportion(res, var = x),
    regexp = "has no non-missing values"
  )
})
