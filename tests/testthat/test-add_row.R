test_that("add_row() adds a row to grouped descriptive table", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    add_row(
      label = "Study period",
      values = c("am = 1" = "2020\u20132024", "am = 0" = "2020\u20132024")
    )

  expect_s3_class(res, "gtstats_summary")
  expect_true(any(res$table$Variable == "Study period"))
  expect_true(any(res$table$`am = 1` == "2020\u20132024"))
  expect_true(any(res$table$`am = 0` == "2020\u20132024"))
  expect_true("custom_row" %in% res$components)
})

test_that("add_row() adds a row to grouped descriptive table with overall", {
  res <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt)) |>
    add_row(
      label = "Study period",
      overall = "2020\u20132024",
      values = c("am = 1" = "2020\u20132024", "am = 0" = "2020\u20132024")
    )

  expect_s3_class(res, "gtstats_summary")
  expect_true(any(res$table$Variable == "Study period"))
  expect_true("Overall" %in% names(res$table))
  expect_true(any(res$table$Overall == "2020\u20132024"))
})

test_that("add_row() adds a row to ungrouped descriptive table", {
  res <- summary_table(mtcars) |>
    add_summary(vars = c(mpg, wt)) |>
    add_row(
      label = "Study period",
      values = "2020\u20132024"
    )

  expect_s3_class(res, "gtstats_summary")
  expect_true(any(res$table$Variable == "Study period"))
  expect_true("Value" %in% names(res$table))
  expect_true(any(res$table$Value == "2020\u20132024"))
})

test_that("add_row() supports level argument", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(cyl)) |>
    add_row(
      label = "Cylinders",
      level = "Other",
      values = c("am = 1" = "0", "am = 0" = "1")
    )

  idx <- which(res$table$Variable == "Cylinders" & res$table$Level == "Other")
  expect_true(length(idx) == 1)
})

test_that("add_row() works when table is initially empty", {
  res <- summary_table(mtcars, by = am) |>
    add_row(
      label = "Study period",
      values = c("am = 1" = "2020\u20132024", "am = 0" = "2020\u20132024")
    )

  expect_s3_class(res, "gtstats_summary")
  expect_equal(nrow(res$table), 1)
  expect_true(all(c("Variable", "Level", "am = 1", "am = 0") %in% names(res$table)))
})

test_that("add_row() accepts list values", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg)) |>
    add_row(
      label = "Study period",
      values = list("am = 1" = "2020\u20132024", "am = 0" = "2020\u20132024")
    )

  expect_true(any(res$table$Variable == "Study period"))
  expect_true(any(res$table$`am = 1` == "2020\u20132024"))
})

test_that("add_row() errors if x is not gtstats_summary", {
  expect_error(
    add_row(mtcars, label = "Study period"),
    regexp = "gtstats_summary"
  )
})

test_that("add_row() errors if label is invalid", {
  res <- summary_table(mtcars, by = am)

  expect_error(
    add_row(res, label = NA_character_),
    regexp = "`label` must be a single non-empty character string"
  )

  expect_error(
    add_row(res, label = c("a", "b")),
    regexp = "`label` must be a single non-empty character string"
  )
  expect_error(
    add_row(res, label = ""),
    regexp = "`label` must be a single non-empty character string"
  )
})

test_that("add_row() rejects values intended for unavailable columns", {
  ungrouped <- summary_table(mtcars)
  overall_only <- summary_table(mtcars, overall = TRUE)

  expect_error(
    add_row(ungrouped, label = "Study period", overall = "2020–2024"),
    "overall.*only"
  )
  expect_error(
    add_row(overall_only, label = "Study period", values = "2020–2024"),
    "Use `overall`"
  )
})

test_that("add_row() validates custom values", {
  grouped <- summary_table(mtcars, by = am)
  ungrouped <- summary_table(mtcars)

  expect_error(
    add_row(grouped, label = "Study period", values = c("am = 1" = "")),
    "must not contain missing or empty"
  )
  expect_error(
    add_row(grouped, label = "Study period", values = c("am = 1" = "x", "am = 1" = "y")),
    "names must be unique"
  )
  expect_error(
    add_row(ungrouped, label = "Study period", values = NA_character_),
    "non-empty, non-missing"
  )
})

test_that("add_row() errors if level is invalid", {
  res <- summary_table(mtcars, by = am)

  expect_error(
    add_row(res, label = "Study period", level = NA_character_),
    regexp = "`level` must be a single non-missing character string"
  )

  expect_error(
    add_row(res, label = "Study period", level = c("a", "b")),
    regexp = "`level` must be a single non-missing character string"
  )
})

test_that("add_row() errors if grouped values are unnamed", {
  res <- summary_table(mtcars, by = am)

  expect_error(
    add_row(res, label = "Study period", values = c("2020\u20132024", "2020\u20132024")),
    regexp = "`values` must be named"
  )
})

test_that("add_row() errors for unknown grouped value names", {
  res <- summary_table(mtcars, by = am)

  expect_error(
    add_row(
      res,
      label = "Study period",
      values = c("wrong_name" = "2020\u20132024")
    ),
    regexp = "Unknown names in `values`"
  )
})

test_that("add_row() errors for multiple values in ungrouped table", {
  res <- summary_table(mtcars)

  expect_error(
    add_row(
      res,
      label = "Study period",
      values = c("2020\u20132024", "2021\u20132025")
    ),
    regexp = "must contain a single value"
  )
})

test_that("to_gt() works after add_row()", {
  gt_obj <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt)) |>
    add_row(
      label = "Study period",
      overall = "2020\u20132024",
      values = c("am = 1" = "2020\u20132024", "am = 0" = "2020\u20132024")
    ) |>
    to_gt()

  expect_s3_class(gt_obj, "gt_tbl")
})
