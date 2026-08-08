test_that("add_summary() adds summary rows to ungrouped descriptive table", {
  res <- summary_table(mtcars) |>
    add_summary(vars = c(mpg, wt))

  expect_s3_class(res, "gt_desc_table")
  expect_true(all(c("Variable", "Level", "Value") %in% names(res$table)))
  expect_true(any(res$table$Variable %in% c("mpg", "wt")))
  expect_true("summary" %in% res$components)
})

test_that("add_summary() adds summary rows to grouped descriptive table", {
  res <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt, cyl))

  expect_s3_class(res, "gt_desc_table")
  expect_true(all(c("Variable", "Level", "am = 1", "am = 0") %in% names(res$table)))
  expect_true(any(res$table$Variable %in% c("mpg", "wt", "cyl")))
})

test_that("add_summary() adds overall column when requested", {
  res <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt))

  expect_s3_class(res, "gt_desc_table")
  expect_true("Overall" %in% names(res$table))
  expect_true(all(c("am = 1", "am = 0") %in% names(res$table)))
})

test_that("add_summary() works with single bare variable", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = mpg)

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(res$table$Variable == "mpg"))
})

test_that("add_summary() works with bare c() variables", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt, cyl))

  expect_s3_class(res, "gt_desc_table")
  expect_true(all(c("mpg", "wt", "cyl") %in% unique(res$table$Variable)))
})

test_that("add_summary() works with character vector variables", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c("mpg", "wt", "cyl"))

  expect_s3_class(res, "gt_desc_table")
  expect_true(all(c("mpg", "wt", "cyl") %in% unique(res$table$Variable)))
})

test_that("add_summary() supports mean_sd format", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg), continuous_format = "mean_sd")

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("mean \\(SD\\)", res$footnotes, ignore.case = TRUE)))
})

test_that("add_summary() supports mean_ci format", {
  res <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = mpg, continuous_format = "mean_ci")

  expected <- mean(mtcars$mpg) + c(-1, 1) *
    stats::qt(0.975, df = nrow(mtcars) - 1) *
    stats::sd(mtcars$mpg) / sqrt(nrow(mtcars))

  expect_match(res$table[["am = 1"]][[1L]], "95% CI")
  expect_match(res$table[["am = 0"]][[1L]], "95% CI")
  expect_true(any(grepl("mean \\(95% CI\\)", res$footnotes)))
  expect_equal(
    res$table$Overall[[1L]],
    paste0("20.1 (95% CI ", sprintf("%.1f", expected[[1L]]), "–",
           sprintf("%.1f", expected[[2L]]), ")")
  )
})

test_that("add_summary() supports median_iqr format", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg), continuous_format = "median_iqr")

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("median \\(IQR\\)", res$footnotes, ignore.case = TRUE)))
})

test_that("add_summary() supports recommended format", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg), continuous_format = "recommended")

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("as appropriate", res$footnotes, ignore.case = TRUE)))
})

test_that("add_summary() supports both format", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg), continuous_format = "both")

  expect_s3_class(res, "gt_desc_table")
  expect_true(any(grepl("mean \\(SD\\) and median \\(IQR\\)", res$footnotes, ignore.case = TRUE)))
})

test_that("add_summary() supports per-variable continuous statistics", {
  res <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_summary(
      vars = c(mpg, wt),
      statistic = c(mpg = "mean_sd", wt = "median_iqr")
    )

  expect_equal(unname(res$summary_statistics["mpg"]), "mean_sd")
  expect_equal(unname(res$summary_statistics["wt"]), "median_iqr")
  expect_true(all(c("mpg", "wt") %in% res$table$Variable))
})

test_that("add_summary() can append a new variable in a later call", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = mpg) |>
    add_summary(vars = wt)

  expect_true(all(c("mpg", "wt") %in% res$table$Variable))
})

test_that("add_summary() can be followed by tbl_stats()", {
  gt_obj <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt, cyl)) |>
    tbl_stats()

  expect_s3_class(gt_obj, "gt_tbl")
})

test_that("add_summary() errors if x is not gt_desc_table", {
  expect_error(
    add_summary(mtcars, vars = c(mpg, wt)),
    regexp = "gt_desc_table"
  )
})

test_that("add_summary() errors in non-summary mode", {
  res <- summary_table(mtcars, by = am, mode = "rate")

  expect_error(
    add_summary(res, vars = c(mpg, wt)),
    regexp = "mode = \"summary\""
  )
})

test_that("add_summary() errors for invalid vars specification", {
  res <- summary_table(mtcars, by = am)

  expect_error(
    add_summary(res, vars = mean(mpg)),
    regexp = "bare names|character vector"
  )
})

test_that("add_summary() errors when variables are missing", {
  res <- summary_table(mtcars, by = am)

  expect_error(
    add_summary(res, vars = c(mpg, not_a_var)),
    regexp = "not found"
  )
})

test_that("add_summary() errors when no new columns can be added", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  expect_error(
    add_summary(res, vars = c(mpg, wt)),
    regexp = "already exist"
  )
})

test_that("add_summary() errors when existing table structure is incompatible", {
  res <- summary_table(mtcars, by = am)
  res$table <- tibble::tibble(Bad = "x")

  expect_error(
    add_summary(res, vars = c(mpg)),
    regexp = "not compatible with summary rows"
  )
})
test_that("add_summary() supports explicit missing rows", {
  dat <- mtcars
  dat$mpg[c(1, 5)] <- NA

  ifany <- summary_table(dat, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, vs), missing = "ifany")
  always <- summary_table(dat, by = am) |>
    add_summary(vars = c(mpg, vs), missing = "always")
  never <- summary_table(dat, by = am) |>
    add_summary(vars = mpg, missing = "no")

  expect_true(any(ifany$table$Variable == "mpg" &
                    ifany$table$Level == "Missing"))
  expect_false(any(ifany$table$Variable == "vs" &
                     ifany$table$Level == "Missing"))
  expect_true(all(c("mpg", "vs") %in%
                    always$table$Variable[always$table$Level == "Missing"]))
  expect_false(any(never$table$Level == "Missing"))
})

test_that("add_summary() reports all-missing categorical variables clearly", {
  dat <- data.frame(
    arm = factor(rep(c("Control", "Treatment"), each = 3)),
    response = factor(rep(NA_character_, 6), levels = c("No", "Yes"))
  )

  grouped <- summary_table(dat, by = arm, overall = TRUE) |>
    add_summary(vars = response)
  ungrouped <- summary_table(dat) |>
    add_summary(vars = response)

  summary_row <- grouped$table[
    grouped$table$Variable == "response" & grouped$table$Level == "",
  ]
  expect_equal(nrow(summary_row), 1)
  expect_true(all(
    summary_row[
      c("Overall", "arm = Control", "arm = Treatment")
    ] == "—"
  ))
  ungrouped_summary_row <- ungrouped$table[
    ungrouped$table$Variable == "response" & ungrouped$table$Level == "",
  ]
  expect_equal(nrow(ungrouped_summary_row), 1)
  expect_identical(
    ungrouped_summary_row$Value,
    "—"
  )
  expect_true(any(ungrouped$table$Level == "Missing"))
})

test_that("add_summary() records categorical denominator choice", {
  result <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = cyl, percent = "row")

  expect_equal(result$percent, "row")
  expect_true(any(grepl("row denominator", result$footnotes)))
})

test_that("add_summary() supports n_over_N_percent categorical display", {
  result <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = cyl, categorical = "n_over_N_percent")

  expect_match(result$table$Overall[[1L]], "^11/32 \\(34.4%\\)$")
  expect_match(result$table[["am = 1"]][[1L]], "^8/13 \\(61.5%\\)$")
  expect_true(any(grepl("n/N", result$footnotes, fixed = TRUE)))
})
