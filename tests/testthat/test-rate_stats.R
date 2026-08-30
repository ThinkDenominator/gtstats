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
  expect_equal(nrow(res$table), 1)
  expect_equal(ncol(res$table), 9)
  expect_equal(nrow(res$summary), 2)
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

  expect_true("Rate per 1,000" %in% names(res$table))
  expect_true("95% CI" %in% names(res$table))
  expect_false(any(grepl("\\(", res$table[["Rate per 1,000"]])))
  expect_true(any(grepl("–", res$table[["95% CI"]], fixed = TRUE)))
})

test_that("rate_stats() grouped publication output uses group column blocks", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    ptime = c(10, 12, 8, 9, 11, 7),
    arm = c("A", "A", "A", "B", "B", "B")
  )

  res <- rate_stats(df, event = event, time = ptime, by = arm)

  expect_identical(names(res$table), c(
    "Event",
    "group_1_events", "group_1_time", "group_1_rate", "group_1_ci",
    "group_2_events", "group_2_time", "group_2_rate", "group_2_ci"
  ))
  expect_identical(res$method$display_columns$group, res$summary$group)
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
  expect_false(identical(res1$table[["Rate per 1,000"]], res2$table[["Rate per 100"]]))
})

test_that("to_gt() works on rate_stats output", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    ptime = c(10, 12, 8, 9, 11, 7),
    arm = c("A", "A", "A", "B", "B", "B")
  )

  result <- rate_stats(df, event = event, time = ptime, by = arm)
  gt_obj <- to_gt(result)

  expect_s3_class(gt_obj, "gt_tbl")
  expect_identical(
    as.character(unlist(gt_obj[["_spanners"]]$spanner_label)),
    result$summary$group
  )
  expect_identical(
    as.character(gt_obj[["_boxhead"]]$column_label[-1L]),
    rep(c("Events", "Person-time", "Rate per 1,000", "95% CI"), 2L)
  )
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

  expect_identical(result$summary$group, c("A", "B"))
  expect_identical(result$method$display_columns$group, c("A", "B"))
  rendered <- to_gt(result)
  expect_true("Person-years" %in% rendered[["_boxhead"]]$column_label)
  expect_true("Rate per 1,000" %in% rendered[["_boxhead"]]$column_label)
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
