test_that("add_rate() adds a rate row to ungrouped descriptive table", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    denom = c(10, 12, 8, 9, 11, 7)
  )

  res <- summary_table(df, mode = "rate") |>
    add_rate(event = event, time = denom, label = "Event rate", multiplier = 1000)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(res$table$Variable == "Event rate"))
  expect_true("Value" %in% names(res$table))
  expect_true("rate" %in% res$components)
  expect_true(any(grepl("Rates per 1,000", res$footnotes, fixed = TRUE)))
})

test_that("add_rate() adds a rate row to grouped descriptive table", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    denom = c(10, 12, 8, 9, 11, 7),
    arm = c("A", "A", "A", "B", "B", "B")
  )

  res <- summary_table(df, by = arm, mode = "rate") |>
    add_rate(event = event, time = denom, label = "Event rate", multiplier = 1000)

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

  res <- summary_table(df, by = arm, overall = TRUE, mode = "rate") |>
    add_rate(event = event, time = denom, label = "Event rate", multiplier = 1000)

  expect_s3_class(res, "gt_desc_table")
  expect_true("Overall" %in% names(res$table))
  expect_true(any(res$table$Variable == "Event rate"))
})

test_that("add_rate() works with character variable names", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    denom = c(10, 12, 8, 9, 11, 7)
  )

  res <- summary_table(df, mode = "rate") |>
    add_rate(event = "event", time = "denom", label = "Event rate", multiplier = 1000)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(res$table$Variable == "Event rate"))
})

test_that("add_rate() supports ci = FALSE", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    denom = c(10, 12, 8, 9, 11, 7)
  )

  res <- summary_table(df, mode = "rate") |>
    add_rate(
      event = event,
      time = denom,
      label = "Event rate",
      multiplier = 1000,
      ci = FALSE
    )

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(res$table$Variable == "Event rate"))
  expect_true(any(grepl("complete event-time pairs", res$footnotes)))
})

test_that("add_rate() marks a zero-time rate as not estimable", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(0, 0, 0)
  )

  res <- summary_table(df, mode = "rate") |>
    add_rate(event = event, time = denom, label = "Event rate", multiplier = 1000)

  expect_s3_class(res, "gt_desc_table")
  expect_identical(res$table$Value, "—")
  expect_identical(
    res$diagnostics$result[res$diagnostics$check == "Accumulated person-time"],
    "not_estimable"
  )
  expect_true(any(grepl("not estimable", res$footnotes, fixed = TRUE)))
})

test_that("add_rate() cannot be combined with summary component", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(10, 12, 8),
    grp = c("A", "A", "B")
  )

  res <- summary_table(df, by = grp) |>
    add_summary(vars = c(event))

  expect_error(
    add_rate(res, event = event, time = denom, label = "Event rate"),
    regexp = "mode = \"rate\""
  )
})

test_that("add_rate() cannot be combined with proportion component", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(10, 12, 8),
    grp = c("A", "A", "B")
  )

  res <- summary_table(df, by = grp) |>
    add_proportion(var = event)

  expect_error(
    add_rate(res, event = event, time = denom, label = "Event rate"),
    regexp = "mode = \"rate\""
  )
})

test_that("add_rate() errors if x is not gt_desc_table", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(10, 12, 8)
  )

  expect_error(
    add_rate(df, event = event, time = denom, label = "Event rate"),
    regexp = "gt_desc_table"
  )
})

test_that("add_rate() errors for invalid multiplier", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(10, 12, 8)
  )

  res <- summary_table(df, mode = "rate")

  expect_error(
    add_rate(res, event = event, time = denom, label = "Event rate", multiplier = 0),
    regexp = "`multiplier` must be a single positive number"
  )
})

test_that("add_rate() errors for invalid conf.level", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(10, 12, 8)
  )

  res <- summary_table(df, mode = "rate")

  expect_error(
    add_rate(res, event = event, time = denom, label = "Event rate", conf.level = 1),
    regexp = "`conf.level` must be a single number between 0 and 1"
  )
})

test_that("add_rate() errors for invalid digits", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(10, 12, 8)
  )

  res <- summary_table(df, mode = "rate")

  expect_error(
    add_rate(res, event = event, time = denom, label = "Event rate", digits = -1),
    regexp = "non-negative whole number"
  )
})

test_that("add_rate() errors for missing event variable", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(10, 12, 8)
  )

  res <- summary_table(df, mode = "rate")

  expect_error(
    add_rate(res, event = not_a_var, time = denom, label = "Event rate"),
    regexp = "`event` was not found"
  )
})

test_that("add_rate() errors for missing time variable", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c(10, 12, 8)
  )

  res <- summary_table(df, mode = "rate")

  expect_error(
    add_rate(res, event = event, time = not_a_var, label = "Event rate"),
    regexp = "`time` was not found"
  )
})

test_that("add_rate() errors if event is non-numeric", {
  df <- data.frame(
    event = c("a", "b", "c"),
    denom = c(10, 12, 8)
  )

  res <- summary_table(df, mode = "rate")

  expect_error(
    add_rate(res, event = event, time = denom, label = "Event rate"),
    regexp = "`event` must be numeric"
  )
})

test_that("add_rate() errors if time is non-numeric", {
  df <- data.frame(
    event = c(1, 0, 1),
    denom = c("a", "b", "c")
  )

  res <- summary_table(df, mode = "rate")

  expect_error(
    add_rate(res, event = event, time = denom, label = "Event rate"),
    regexp = "`time` must be numeric"
  )
})

test_that("tbl_stats() works after add_rate()", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    denom = c(10, 12, 8, 9, 11, 7),
    arm = c("A", "A", "A", "B", "B", "B")
  )

  gt_obj <- summary_table(df, by = arm, overall = TRUE, mode = "rate") |>
    add_rate(event = event, time = denom, label = "Event rate", multiplier = 1000) |>
    tbl_stats()

  expect_s3_class(gt_obj, "gt_tbl")
})

test_that("add_rate() uses complete event-time pairs", {
  dat <- data.frame(
    event = c(1, 2, NA, 4),
    time = c(10, NA, 30, 40)
  )
  result <- summary_table(dat, mode = "rate") |>
    add_rate(event, time, multiplier = 100)

  expect_equal(result$denominators$numerator, 5)
  expect_equal(result$denominators$denominator, 50)
  expect_equal(result$denominators$n_nonmissing, 2)
  expect_equal(result$denominators$n_missing, 2)
})

test_that("add_rate() supports logical events and readable time units", {
  dat <- data.frame(
    event = c(TRUE, FALSE, TRUE),
    time = c(1.2, 0.8, 1.0)
  )
  result <- summary_table(dat, mode = "rate") |>
    add_rate(event, time, multiplier = 100, time_label = "person-years")

  expect_match(result$table$Variable, "person-years", fixed = TRUE)
  expect_match(result$footnotes, "person-years", fixed = TRUE)
})

test_that("add_rate() rejects invalid counts and time", {
  fractional <- data.frame(event = c(0.5, 1), time = c(1, 2))
  negative_event <- data.frame(event = c(-1, 1), time = c(1, 2))
  negative_time <- data.frame(event = c(0, 1), time = c(-1, 2))

  expect_error(
    summary_table(fractional, mode = "rate") |>
      add_rate(event, time),
    "integer counts"
  )
  expect_error(
    summary_table(negative_event, mode = "rate") |>
      add_rate(event, time),
    "negative"
  )
  expect_error(
    summary_table(negative_time, mode = "rate") |>
      add_rate(event, time),
    "negative"
  )
})

test_that("add_rate() rejects non-finite event counts and time", {
  nonfinite_event <- data.frame(event = c(1, Inf), time = c(1, 2))
  nonfinite_time <- data.frame(event = c(1, 0), time = c(1, Inf))

  expect_error(
    summary_table(nonfinite_event, mode = "rate") |> add_rate(event, time),
    "event.*finite"
  )
  expect_error(
    summary_table(nonfinite_time, mode = "rate") |> add_rate(event, time),
    "time.*finite"
  )
})
