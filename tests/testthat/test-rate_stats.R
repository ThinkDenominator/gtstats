test_that("rate_stats() works without grouping", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    ptime = c(10, 12, 8, 9, 11, 7)
  )

  res <- rate_stats(df, event = event, time = ptime)

  expect_s3_class(res, "gt_rate")
  expect_true(is.list(res))
  expect_true(all(c("summary", "table", "inputs", "notes") %in% names(res)))
  expect_equal(nrow(res$table), 1)
  expect_true(any(grepl("Poisson process", res$notes)))
  expect_true(any(grepl("person-time", res$notes)))
})

test_that("rate_stats() works with grouping", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    ptime = c(10, 12, 8, 9, 11, 7),
    arm = c("A", "A", "A", "B", "B", "B")
  )

  res <- rate_stats(df, event = event, time = ptime, by = arm)

  expect_s3_class(res, "gt_rate")
  expect_equal(res$inputs$by, "arm")
  expect_equal(nrow(res$table), 2)
})

test_that("rate_stats() accepts character input", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    ptime = c(10, 12, 8, 9, 11, 7),
    arm = c("A", "A", "A", "B", "B", "B")
  )

  res <- rate_stats(df, event = "event", time = "ptime", by = "arm")

  expect_s3_class(res, "gt_rate")
  expect_equal(res$inputs$event, "event")
  expect_equal(res$inputs$time, "ptime")
  expect_equal(res$inputs$by, "arm")
})

test_that("rate_stats() returns formatted rate strings", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    ptime = c(10, 12, 8, 9, 11, 7)
  )

  res <- rate_stats(df, event = event, time = ptime)

  rate_column <- names(res$table)[ncol(res$table)]
  expect_match(rate_column, "Rate per 1,000", fixed = TRUE)
  expect_true(any(grepl("\\(", res$table[[rate_column]])))
})

test_that("rate_stats() grouped output includes Group column", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    ptime = c(10, 12, 8, 9, 11, 7),
    arm = c("A", "A", "A", "B", "B", "B")
  )

  res <- rate_stats(df, event = event, time = ptime, by = arm)

  expect_true("Group" %in% names(res$table))
})

test_that("rate_stats() respects multiplier", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    ptime = c(10, 12, 8, 9, 11, 7)
  )

  res1 <- rate_stats(df, event = event, time = ptime, multiplier = 1000)
  res2 <- rate_stats(df, event = event, time = ptime, multiplier = 100)

  expect_s3_class(res1, "gt_rate")
  expect_s3_class(res2, "gt_rate")
  expect_false(identical(
    res1$table[[ncol(res1$table)]],
    res2$table[[ncol(res2$table)]]
  ))
})

test_that("tbl_stats() works on rate_stats output", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    ptime = c(10, 12, 8, 9, 11, 7),
    arm = c("A", "A", "A", "B", "B", "B")
  )

  gt_obj <- rate_stats(df, event = event, time = ptime, by = arm) |>
    tbl_stats()

  expect_s3_class(gt_obj, "gt_tbl")
})

test_that("to_flextable() works on rate_stats output", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    ptime = c(10, 12, 8, 9, 11, 7),
    arm = c("A", "A", "A", "B", "B", "B")
  )

  ft <- rate_stats(df, event = event, time = ptime, by = arm) |>
    to_flextable()

  expect_s3_class(ft, "flextable")
})

test_that("rate_stats() errors for missing event variable", {
  df <- data.frame(
    event = c(1, 0, 1),
    ptime = c(10, 12, 8)
  )

  expect_error(
    rate_stats(df, event = not_a_var, time = ptime),
    regexp = "not found"
  )
})

test_that("rate_stats() errors for missing time variable", {
  df <- data.frame(
    event = c(1, 0, 1),
    ptime = c(10, 12, 8)
  )

  expect_error(
    rate_stats(df, event = event, time = not_a_var),
    regexp = "not found"
  )
})

test_that("rate_stats() errors for non-numeric time", {
  df <- data.frame(
    event = c(1, 0, 1),
    ptime = c("a", "b", "c")
  )

  expect_error(
    rate_stats(df, event = event, time = ptime),
    regexp = "`time` must be numeric"
  )
})

test_that("rate_stats() errors for negative time", {
  df <- data.frame(
    event = c(1, 0, 1),
    ptime = c(10, -12, 8)
  )

  expect_error(
    rate_stats(df, event = event, time = ptime),
    regexp = "must not contain negative values"
  )
})

test_that("rate_stats() returns NA rate for zero total person-time", {
  df <- data.frame(
    event = c(1, 0, 1),
    ptime = c(0, 0, 0)
  )

  res <- rate_stats(df, event = event, time = ptime)

  expect_s3_class(res, "gt_rate")
  expect_equal(res$table$`Person-time`[1], 0)
  expect_true(is.na(res$table[[ncol(res$table)]][1]))
  expect_identical(
    res$diagnostics$result[res$diagnostics$check == "Accumulated person-time"],
    "not_estimable"
  )
  expect_true(any(grepl("not estimable", res$notes, fixed = TRUE)))
})

test_that("rate_stats() rejects non-finite event and time values", {
  expect_error(
    rate_stats(data.frame(event = c(1, Inf), time = c(1, 2)), event, time),
    "event.*finite"
  )
  expect_error(
    rate_stats(data.frame(event = c(1, 0), time = c(1, Inf)), event, time),
    "time.*finite"
  )
})

test_that("rate_stats() errors for negative events", {
  df <- data.frame(
    event = c(1, -1, 1),
    ptime = c(10, 12, 8)
  )

  expect_error(
    rate_stats(df, event = event, time = ptime),
    regexp = "`event` must not contain negative values"
  )
})
test_that("rate_stats() rejects fractional event counts", {
  dat <- data.frame(events = c(0.5, 1), time = c(10, 12))

  expect_error(
    rate_stats(dat, event = events, time = time),
    "integer counts"
  )
})

test_that("rate_stats() flags proportion-like input", {
  dat <- data.frame(events = c(0, 1, 1), time = c(1, 1, 1))
  result <- rate_stats(dat, event = events, time = time)

  expect_true(any(result$diagnostics$check == "Possible proportion-like input"))
  expect_true(any(result$diagnostics$result == "review"))
})

test_that("rate_stats() respects factor order and custom time label", {
  dat <- data.frame(
    event = c(1, 0, 2, 1),
    time = c(10, 12, 9, 11),
    arm = factor(c("B", "B", "A", "A"), levels = c("A", "B"))
  )
  result <- rate_stats(
    dat,
    event,
    time,
    by = arm,
    time_label = "person-years"
  )

  expect_identical(result$table$Group, c("A", "B"))
  expect_true("Person-years" %in% names(result$table))
  expect_match(names(result$table)[ncol(result$table)], "Rate per 1,000")
  expect_identical(result$inputs$time_label, "person-years")
})

test_that("rate_stats() uses complete event-time pairs", {
  dat <- data.frame(
    event = c(1, 2, NA, 4),
    time = c(10, NA, 30, 40)
  )
  result <- rate_stats(dat, event, time, multiplier = 100)

  expect_equal(result$summary$events, 5)
  expect_equal(result$summary$person_time, 50)
  expect_equal(result$summary$n, 2)
  expect_equal(result$denominators$n_missing, 2)
})

test_that("rate_stats() flags events recorded with zero time", {
  dat <- data.frame(event = c(1, 0, 2), time = c(0, 10, 5))
  result <- rate_stats(dat, event, time)
  diagnostic <- result$diagnostics[
    result$diagnostics$check == "Events recorded with zero time",
  ]

  expect_identical(diagnostic$result, "review")
  expect_equal(as.numeric(diagnostic$value), 1)
})
