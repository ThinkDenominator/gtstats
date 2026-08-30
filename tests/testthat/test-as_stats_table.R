test_that("as_stats_table preserves already calculated values", {
  calculated <- data.frame(
    Group = c("A", "B"),
    N = c(12L, 18L),
    `Mean (SD)` = c("4.2 (1.1)", "5.0 (1.3)"),
    check.names = FALSE
  )

  result <- as_stats_table(calculated, notes = "Calculated upstream.")

  expect_s3_class(result, "gt_data_table")
  expect_s3_class(result, "gtstats")
  expect_identical(as.data.frame(result$table), calculated)
  expect_identical(result$notes, "Calculated upstream.")
  expect_s3_class(to_flextable(result), "flextable")
  expect_s3_class(to_gt(result), "gt_tbl")
  expect_s3_class(customise_table(result, title = "Calculated table"), "flextable")
})

test_that("as_stats_table validates displayable table data", {
  expect_error(as_stats_table(1:3), "data frame or tibble")
  expect_error(as_stats_table(data.frame()), "at least one column")
  expect_error(as_stats_table(data.frame(x = numeric())), "at least one row")

  duplicate <- data.frame(a = 1, b = 2)
  names(duplicate) <- c("value", "value")
  expect_error(as_stats_table(duplicate), "unique, non-empty")

  nested <- data.frame(id = 1)
  nested$details <- list(data.frame(value = 1))
  expect_error(as_stats_table(nested), "list or nested")
  expect_error(as_stats_table(data.frame(x = 1), notes = NA_character_), "notes")
})

test_that("add_ci calculates explicit aggregate-data intervals", {
  aggregate <- data.frame(
    Group = c("A", "B"),
    Events = c(8, 14),
    Total = c(40, 50),
    PersonYears = c(420, 510),
    Mean = c(10, 12),
    SD = c(2, 3),
    N = c(30, 35),
    Estimate = c(0.4, 0.6),
    SE = c(0.1, 0.12)
  )

  proportion <- as_stats_table(aggregate) |>
    add_ci(type = "proportion", numerator = Events, denominator = Total)
  rate <- as_stats_table(aggregate) |>
    add_ci(
      type = "rate", numerator = Events, denominator = PersonYears,
      multiplier = 1000, digits = 2
    )
  mean_ci <- as_stats_table(aggregate) |>
    add_ci(type = "mean", estimate = Mean, sd = SD, n = N)
  normal <- as_stats_table(aggregate) |>
    add_ci(type = "normal", estimate = Estimate, se = SE)

  expect_true("95% CI" %in% names(proportion$table))
  expect_match(proportion$table$`95% CI`, "%", fixed = TRUE)
  expect_identical(rate$ci$method, "exact_poisson")
  expect_identical(mean_ci$ci$method, "t")
  expect_identical(normal$ci$method, "normal")
  expect_true(all(nzchar(rate$table$`95% CI`)))
  expect_true(all(nzchar(mean_ci$table$`95% CI`)))
  expect_true(all(nzchar(normal$table$`95% CI`)))
})

test_that("aggregate confidence intervals reject insufficient or invalid inputs", {
  aggregate <- data.frame(events = c(2, 8), total = c(10, 5))
  table <- as_stats_table(aggregate)

  expect_error(add_ci(table), "supply `type")
  expect_error(
    add_ci(table, type = "proportion", numerator = events),
    "requires"
  )
  expect_error(
    add_ci(table, type = "proportion", numerator = events, denominator = total),
    "0 <= numerator <= denominator"
  )
  expect_error(
    add_ci(table, type = "rate", numerator = missing, denominator = total),
    "was not found"
  )
})
