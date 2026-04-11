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

  expect_true("Rate" %in% names(res$table))
  expect_true(any(grepl("\\(", res$table$Rate)))
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
  expect_false(identical(res1$table$Rate, res2$table$Rate))
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
  expect_true(is.na(res$table$Rate[1]) || identical(res$table$Rate[1], "NA"))
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
