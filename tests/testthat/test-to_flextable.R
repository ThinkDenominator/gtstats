test_that("to_flextable() converts descriptive table object", {
  obj <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() works with overall column", {
  obj <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt, cyl)) |>
    add_proportion(var = vs) |>
    add_total() |>
    add_p()

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() works for proportion_stats output", {
  obj <- proportion_stats(mtcars, var = vs, by = am)

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() works for rate_stats output", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    ptime = c(10, 12, 8, 9, 11, 7),
    arm = c("A", "A", "A", "B", "B", "B")
  )

  obj <- rate_stats(df, event = event, time = ptime, by = arm)

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() works for crosstabs() output", {
  obj <- crosstabs(mtcars, row = am, col = vs)

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
  body_values <- unlist(ft$body$dataset, use.names = FALSE)
  expect_false(any(grepl("<br>", body_values, fixed = TRUE)))
  expect_true(any(grepl("\n", body_values, fixed = TRUE)))
})

test_that("to_flextable() works for a direct summary_table output", {
  obj <- summary_table(mtcars, by = am, include = c(mpg, wt))

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("summary flextables display one label per categorical block", {
  data <- mtcars
  data$am <- factor(data$am, labels = c("Automatic", "Manual"))
  data$cyl <- factor(data$cyl)

  obj <- summary_table(
    data,
    by = am,
    include = c(mpg, cyl),
    overall = "last"
  )
  ft <- to_flextable(obj)

  rendered <- ft$body$dataset
  expect_equal(
    rendered$Characteristic,
    c("mpg", "cyl", "4", "6", "8")
  )
  cyl_rows <- which(obj$table$Variable == "cyl")
  expect_equal(obj$table$Variable[cyl_rows], rep("cyl", 3L))
  header_html <- as.character(flextable::htmltools_value(ft))
  expect_false(grepl(">Level<", header_html, fixed = TRUE))
  expect_true(grepl("Characteristic", header_html, fixed = TRUE))
})

test_that("publication padding becomes compact as tables grow", {
  expect_equal(gtstats:::.publication_auto_padding(10), 3)
  expect_equal(gtstats:::.publication_auto_padding(11), 2)
  expect_equal(gtstats:::.publication_auto_padding(25), 2)
  expect_equal(gtstats:::.publication_auto_padding(26), 1)
})

test_that("to_flextable() includes notes when present", {
  obj <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    add_p()

  expect_true(length(c(obj$notes, obj$footnotes, obj$pvalue_method_footnotes)) > 0)

  ft <- to_flextable(obj)

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() supports Office presentation options", {
  obj <- summary_table(mtcars, by = am, include = c(mpg, wt))

  ft <- to_flextable(
    obj,
    font_size = 9,
    font = "Arial",
    autofit = FALSE,
    show_footnotes = FALSE
  )

  expect_s3_class(ft, "flextable")
})

test_that("to_flextable() validates presentation options", {
  obj <- summary_table(mtcars, by = am, include = c(mpg, wt))

  expect_error(to_flextable(obj, font_size = 0), "positive")
  expect_error(to_flextable(obj, font = ""), "font")
  expect_error(to_flextable(obj, autofit = NA), "autofit")
  expect_error(to_flextable(obj, show_footnotes = 1), "show_footnotes")
})

test_that("to_flextable() errors when given gt table instead of GTstats object", {
  gt_obj <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    tbl_stats()

  expect_error(
    to_flextable(gt_obj),
    regexp = "tbl_stats"
  )
})

test_that("to_flextable() errors for invalid input without table", {
  expect_error(
    to_flextable(mtcars),
    regexp = "must be a gtstats object"
  )
})
test_that("flextable publication footnotes use the compact house size", {
  result <- summary_table(mtcars, include = c(mpg, cyl))
  ft <- to_flextable(result, font_size = 12)
  expect_true(all(ft$footer$styles$text$font.size$data == 8))
})

test_that("flextable identifies adjusted p-values and paired exclusions", {
  adjusted <- summary_table(mtcars, by = am, include = c(mpg, cyl)) |>
    add_p(p_adjust = "holm") |>
    to_flextable()
  adjusted_notes <- paste(adjusted$footer$dataset[[1L]], collapse = " ")
  expect_match(adjusted_notes, "holm multiplicity adjustment")

  paired_data <- data.frame(
    id = rep(1:4, each = 2),
    visit = rep(c("Baseline", "Follow-up"), 4),
    score = c(10, 11, 20, NA, 30, 32, 40, 43)
  )
  paired <- summary_table(
    paired_data, by = visit, include = score
  ) |>
    add_p(paired = TRUE, id = id) |>
    to_flextable()
  paired_notes <- paste(paired$footer$dataset[[1L]], collapse = " ")
  expect_match(paired_notes, "3 complete pairs")
  expect_match(paired_notes, "1 excluded")
})
