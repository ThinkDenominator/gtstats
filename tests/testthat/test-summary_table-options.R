test_that("summary_table() keeps beginner defaults", {
  data <- mtcars
  data$am <- factor(data$am)
  data$cyl <- factor(data$cyl)

  res <- summary_table(
    data,
    by = am,
    include = c(mpg, cyl),
    overall = TRUE
  )

  expect_true(grepl("\\d+\\.\\d \\(", res$table$Overall[[1L]]))
  expect_true(any(grepl("\\d+ \\(\\d+\\.\\d%\\)", res$table$Overall)))
  expect_false(any(grepl("CI", unlist(res$table), fixed = TRUE)))
})

test_that("summary_table() accepts include = everything()", {
  data <- mtcars
  data$am <- factor(data$am)

  res <- summary_table(data, by = am, include = everything())

  expect_setequal(
    names(res$summary_statistics),
    setdiff(names(data), "am")
  )
  expect_false("am" %in% names(res$summary_statistics))
})

test_that("summary_table() supports named precision controls", {
  data <- mtcars
  data$am <- factor(data$am)
  data$cyl <- factor(data$cyl)

  res <- summary_table(
    data,
    by = am,
    include = c(mpg, cyl),
    overall = TRUE,
    digits = c(continuous = 2, percent = 0, ci = 2),
    ci = TRUE
  )

  expect_match(res$table$Overall[[1L]], "\\d+\\.\\d{2} \\(")
  expect_true(any(grepl("\\(\\d+%\\); \\d+\\.\\d{2}", res$table$Overall)))
  expect_false(any(grepl("95% CI", res$table$Overall, fixed = TRUE)))
})

test_that("summary_table() supports all categorical displays", {
  data <- mtcars
  data$am <- factor(data$am)
  data$cyl <- factor(data$cyl)

  n_pct <- summary_table(data, by = am, include = cyl)
  counts <- summary_table(
    data, by = am, include = cyl, categorical = "n"
  )
  percentages <- summary_table(
    data, by = am, include = cyl, categorical = "percent", digits = 0
  )
  fractions <- summary_table(
    data, by = am, include = cyl, categorical = "n_over_N_percent"
  )

  value_col <- setdiff(names(n_pct$table), c("Variable", "Level"))[[1L]]
  expect_match(n_pct$table[[value_col]][[1L]], "^\\d+ \\(\\d+\\.\\d%\\)$")
  expect_match(counts$table[[value_col]][[1L]], "^\\d+$")
  expect_match(percentages$table[[value_col]][[1L]], "^\\d+%$")
  expect_match(fractions$table[[value_col]][[1L]], "^\\d+/\\d+ \\(\\d+\\.\\d%\\)$")
})

test_that("summary_table() supports mean_ci without p-values", {
  data <- mtcars
  data$am <- factor(data$am)

  res <- summary_table(
    data,
    by = am,
    include = mpg,
    statistic = "mean_ci",
    conf.level = 0.90,
    digits = c(continuous = 1, ci = 2)
  )

  expect_false("p-value" %in% names(res$table))
  value_columns <- setdiff(names(res$table), c("Variable", "Level"))
  expect_false(any(grepl("90% CI", unlist(res$table[value_columns]), fixed = TRUE)))
  expect_true(all(grepl(
    "^[-0-9.]+ \\([-0-9.]+–[-0-9.]+\\)$",
    unlist(res$table[value_columns])
  )))
  expect_true(any(grepl("mean \\(90% CI\\)", res$footnotes)))
  expect_false(any(grepl("Categorical", res$footnotes, fixed = TRUE)))
  expect_false(any(grepl("Missing-value", res$footnotes, fixed = TRUE)))
})

test_that("summary_table() supports percentage denominators", {
  data <- mtcars
  data$am <- factor(data$am)
  data$cyl <- factor(data$cyl)

  column <- summary_table(
    data, by = am, include = cyl, percent = "column"
  )
  row <- summary_table(
    data, by = am, include = cyl, percent = "row"
  )
  overall <- summary_table(
    data, by = am, include = cyl, percent = "overall"
  )

  expect_equal(column$method$percentage_denominator, "column")
  expect_equal(row$method$percentage_denominator, "row")
  expect_equal(overall$method$percentage_denominator, "overall")
  expect_false(identical(column$table, row$table))
  expect_false(identical(column$table, overall$table))
})

test_that("summary_table() audits the denominator used for each categorical cell", {
  data <- data.frame(
    arm = factor(c("Control", "Control", "Treatment", "Treatment", "Treatment")),
    response = factor(c("No", "Yes", "Yes", "Yes", NA))
  )

  column <- summary_table(data, by = arm, include = response, percent = "column")
  row <- summary_table(data, by = arm, include = response, percent = "row")
  overall <- summary_table(data, by = arm, include = response, percent = "overall")

  row_yes <- row$denominators[
    row$denominators$variable == "response" &
      row$denominators$level == "Yes",
  ]
  column_yes <- column$denominators[
    column$denominators$variable == "response" &
      column$denominators$level == "Yes",
  ]
  overall_yes <- overall$denominators[
    overall$denominators$variable == "response" &
      overall$denominators$level == "Yes",
  ]

  expect_true("level" %in% names(row$denominators))
  expect_equal(row_yes$denominator, c(3, 3))
  expect_equal(column_yes$denominator, c(2, 2))
  expect_equal(overall_yes$denominator, c(4, 4))
})

test_that("summary_table() positions overall first or last", {
  data <- mtcars
  data$am <- factor(data$am)

  first <- summary_table(
    data, by = am, include = mpg, overall = "first"
  )
  last <- summary_table(
    data, by = am, include = mpg, overall = "last"
  )

  expect_equal(names(first$table)[[3L]], "Overall")
  expect_equal(tail(names(last$table), 1L), "Overall")
})

test_that("recommended continuous summaries use one format across all columns", {
  data <- data.frame(
    arm = factor(rep(c("A", "B"), each = 10)),
    value = c(rep(c(-2, -1, 0, 1, 2), 2), rep(1, 9), 100)
  )

  result <- summary_table(
    data,
    by = arm,
    include = value,
    overall = TRUE,
    statistic = "recommended"
  )

  expect_identical(unname(result$summary_statistics[["value"]]), "median_iqr")
  expect_identical(
    unname(result$summary_statistics_requested[["value"]]),
    "recommended"
  )
  expect_true(all(grepl("–", unlist(result$table[1, 3:5]), fixed = TRUE)))

  explicit <- summary_table(
    data,
    by = arm,
    include = value,
    overall = TRUE,
    statistic = "mean_sd"
  )
  expect_identical(unname(explicit$summary_statistics[["value"]]), "mean_sd")
})

test_that("summary_table() exposes Wilson and exact categorical CI methods", {
  data <- data.frame(outcome = factor(c(rep("No", 7), rep("Yes", 3))))
  wilson <- summary_table(data, include = outcome, ci = TRUE)
  exact <- summary_table(
    data, include = outcome, ci = TRUE, ci_method = "exact"
  )

  expect_identical(wilson$ci_method, "wilson")
  expect_identical(exact$ci_method, "exact")
  expect_false(identical(wilson$table$Value, exact$table$Value))
  expect_true(any(grepl("Wilson score", wilson$footnotes, fixed = TRUE)))
  expect_true(any(grepl("exact binomial", exact$footnotes, fixed = TRUE)))
})

test_that("summary_table() validates the combined overall setting", {
  data <- mtcars
  data$am <- factor(data$am)

  shorthand <- summary_table(
    data, by = am, include = mpg, overall = TRUE
  )
  omitted <- summary_table(
    data, by = am, include = mpg, overall = FALSE
  )

  expect_identical(shorthand$overall_position, "first")
  expect_true(shorthand$overall)
  expect_false(omitted$overall)
  expect_false("Overall" %in% names(omitted$table))
  expect_error(
    summary_table(data, by = am, include = mpg, overall = "middle"),
    'FALSE, TRUE, "first", or "last"',
    fixed = TRUE
  )
})

test_that("summary_table() provides categorical CIs without p-values", {
  data <- mtcars
  data$am <- factor(data$am)
  data$vs <- factor(data$vs, levels = 0:1, labels = c("V", "Straight"))

  res <- summary_table(
    data,
    include = vs,
    categorical = "percent",
    ci = TRUE,
    conf.level = 0.90,
    digits = c(percent = 1, ci = 2)
  )

  expect_false("p-value" %in% names(res$table))
  expect_false(any(grepl("90% CI", res$table$Value, fixed = TRUE)))
  expect_true(all(grepl(";", res$table$Value, fixed = TRUE)))
  expect_match(.builder_publication_note(res), "90% Wilson score CIs", fixed = TRUE)
  expect_true(all(grepl("%", res$table$Value, fixed = TRUE)))
})

test_that("summary_table() supports label and statistic overrides", {
  data <- mtcars
  data$am <- factor(data$am)

  res <- summary_table(
    data,
    by = am,
    include = c(mpg, wt),
    statistic = c(mpg = "mean_sd", wt = "median_iqr"),
    label = c(mpg = "Mileage", wt = "Weight")
  )

  expect_true(all(c("Mileage", "Weight") %in% res$table$Variable))
  expect_equal(unname(res$summary_statistics[c("mpg", "wt")]),
               c("mean_sd", "median_iqr"))
})

test_that("summary_table() supports missing-row policies", {
  data <- mtcars
  data$am <- factor(data$am)
  data$mpg[c(1, 2)] <- NA

  ifany <- summary_table(data, by = am, include = mpg, missing = "ifany")
  always <- summary_table(data, by = am, include = wt, missing = "always")
  no <- summary_table(data, by = am, include = mpg, missing = "no")

  expect_true(any(ifany$table$Level == "Missing"))
  expect_true(any(always$table$Level == "Missing"))
  expect_false(any(no$table$Level == "Missing"))
})

test_that("summary_table() validates customization arguments", {
  expect_error(
    summary_table(mtcars, include = mpg, digits = c(foo = 1)),
    "named numeric vector"
  )
  expect_error(
    summary_table(mtcars, include = mpg, label = c("Mileage")),
    "named character"
  )
  expect_error(
    summary_table(mtcars, include = mpg, conf.level = 1),
    "between 0 and 1"
  )
  expect_error(
    summary_table(
      mtcars, include = cyl, categorical = "n", ci = TRUE
    ),
    "requires"
  )
})

test_that("categorical CIs handle zero cells and missing values", {
  data <- data.frame(
    group = factor(c("A", "A", "B", "B")),
    outcome = factor(
      c("Yes", "Yes", "No", NA),
      levels = c("No", "Yes")
    )
  )

  res <- summary_table(
    data,
    by = group,
    include = outcome,
    ci = TRUE,
    missing = "ifany"
  )

  expect_true(any(grepl("0 \\(0.0%\\); 0.0–", unlist(res$table))))
  expect_true(any(res$table$Level == "Missing"))
  expect_false(any(grepl("NaN|Inf", unlist(res$table))))
})

test_that("overall position is preserved by optional add-ons", {
  data <- mtcars
  data$am <- factor(data$am)
  data$vs <- factor(data$vs)

  res <- summary_table(
    data,
    by = am,
    include = mpg,
    overall = "last"
  ) |>
    add_total(position = "first") |>
    add_proportion(var = vs, level = "1") |>
    add_row(
      label = "Study period",
      overall = "1973",
      values = c("am = 1" = "1973", "am = 0" = "1973")
    )

  expect_equal(tail(names(res$table), 1L), "Overall")
  expect_true(all(c("total", "proportion", "custom_row") %in% res$components))
})

test_that("rate-only tables honour overall position", {
  data <- data.frame(
    event = c(1, 0, 1, 0),
    time = c(10, 12, 9, 11),
    group = factor(c("A", "A", "B", "B"))
  )

  res <- summary_table(
    data,
    by = group,
    overall = "last",
    mode = "rate"
  ) |>
    add_rate(event = event, time = time, label = "Event rate")

  expect_equal(tail(names(res$table), 1L), "Overall")
  expect_true("rate" %in% res$components)
})
