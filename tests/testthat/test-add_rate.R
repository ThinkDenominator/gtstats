test_that("add_rate() adds a rate row to ungrouped descriptive table", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    denom = c(10, 12, 8, 9, 11, 7)
  )

  res <- descriptive_table(df) |>
    add_rate(events = event, denom = denom, label = "Event rate", multiplier = 1000)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(res$table$Variable == "Event rate"))
  expect_true("Value" %in% names(res$table))
  expect_true("rate" %in% res$components)
  expect_true(any(grepl("Rates are shown per 1000", res$footnotes)))
})

test_that("add_rate() adds a rate row to grouped descriptive table", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    denom = c(10, 12, 8, 9, 11, 7),
    arm = c("A", "A", "A", "B", "B", "B")
  )

  res <- descriptive_table(df, by = arm) |>
    add_rate(events = event, denom = denom, label = "Event rate", multiplier = 1000)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(res$table$Variable == "Event rate"))
  expect_true(all(c("arm = A", "arm = B") %in% names(res$table)))
})

test_that("add_rate() adds a rate row to grouped descriptive table with overall", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    denom = c(10, 12, 8, 9, 11, 7),
    arm = c("A", "A", "A", "B", "B", "B")
  )

  res <- descriptive_table(df, by = arm, overall = TRUE) |>
    add_rate(events = event, denom = denom, label = "Event rate", multiplier = 1000)

  expect_s3_class(res, "gt_desc_table")
  expect_true("Overall" %in% names(res$table))
  expect_true(any(res$table$Variable == "Event rate"))
})

test_that("add_rate() works with character variable names", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    denom = c(10, 12, 8, 9, 11, 7)
  )

  res <- descriptive_table(df) |>
    add_rate(events = "event", denom = "denom", label = "Event rate", multiplier = 1000)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(res$table$Variable == "Event rate"))
})

test_that("add_rate() supports ci = FALSE", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    denom = c(10, 12, 8, 9, 11, 7)
  )

  res <- descriptive_table(df) |>
    add_rate(
      events = event,
      denom = denom,
      label = "Event rate",
      multiplier = 1000,
      ci = FALSE
    )

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(res$table$Variable == "Event rate"))
  expect_true(any(grepl("Rates are shown per 1000\\.", res$footnotes)))
})

test_that("add_rate() returns NA display when denominator is zero", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(0, 0, 0)
  )

  res <- descriptive_table(df) |>
    add_rate(events = event, denom = denom, label = "Event rate", multiplier = 1000)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(is.na(res$table$Value) | res$table$Value == "NA"))
})

test_that("add_rate() cannot be combined with summary component", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(10, 12, 8),
    grp = c("A", "A", "B")
  )

  res <- descriptive_table(df, by = grp) |>
    add_summary(vars = c(event))

  expect_error(
    add_rate(res, events = event, denom = denom, label = "Event rate"),
    regexp = "cannot be combined"
  )
})

test_that("add_rate() cannot be combined with proportion component", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(10, 12, 8),
    grp = c("A", "A", "B")
  )

  res <- descriptive_table(df, by = grp) |>
    add_proportion(var = event)

  expect_error(
    add_rate(res, events = event, denom = denom, label = "Event rate"),
    regexp = "cannot be combined"
  )
})

test_that("add_rate() errors if x is not gt_desc_table", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(10, 12, 8)
  )

  expect_error(
    add_rate(df, events = event, denom = denom, label = "Event rate"),
    regexp = "gt_desc_table"
  )
})

test_that("add_rate() errors for invalid multiplier", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(10, 12, 8)
  )

  res <- descriptive_table(df)

  expect_error(
    add_rate(res, events = event, denom = denom, label = "Event rate", multiplier = 0),
    regexp = "`multiplier` must be a single positive number"
  )
})

test_that("add_rate() errors for invalid conf.level", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(10, 12, 8)
  )

  res <- descriptive_table(df)

  expect_error(
    add_rate(res, events = event, denom = denom, label = "Event rate", conf.level = 1),
    regexp = "`conf.level` must be a single number between 0 and 1"
  )
})

test_that("add_rate() errors for invalid digits", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(10, 12, 8)
  )

  res <- descriptive_table(df)

  expect_error(
    add_rate(res, events = event, denom = denom, label = "Event rate", digits = -1),
    regexp = "`digits` must be a single non-negative number"
  )
})

test_that("add_rate() errors for missing events variable", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(10, 12, 8)
  )

  res <- descriptive_table(df)

  expect_error(
    add_rate(res, events = not_a_var, denom = denom, label = "Event rate"),
    regexp = "`events` was not found"
  )
})

test_that("add_rate() errors for missing denom variable", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(10, 12, 8)
  )

  res <- descriptive_table(df)

  expect_error(
    add_rate(res, events = event, denom = not_a_var, label = "Event rate"),
    regexp = "`denom` was not found"
  )
})

test_that("add_rate() errors if events is non-numeric", {
  df <- data.frame(
    event = c("a", "b", "c"),
    denom = c(10, 12, 8)
  )

  res <- descriptive_table(df)

  expect_error(
    add_rate(res, events = event, denom = denom, label = "Event rate"),
    regexp = "`events` must be numeric"
  )
})

test_that("add_rate() errors if denom is non-numeric", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c("a", "b", "c")
  )

  res <- descriptive_table(df)

  expect_error(
    add_rate(res, events = event, denom = denom, label = "Event rate"),
    regexp = "`denom` must be numeric"
  )
})

test_that("tbl_stats() works after add_rate()", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    denom = c(10, 12, 8, 9, 11, 7),
    arm = c("A", "A", "A", "B", "B", "B")
  )

  gt_obj <- descriptive_table(df, by = arm, overall = TRUE) |>
    add_rate(events = event, denom = denom, label = "Event rate", multiplier = 1000) |>
    tbl_stats()

  expect_s3_class(gt_obj, "gt_tbl")
})
