test_that("print.gt_describe() returns the object invisibly", {
  obj <- describe_data(mtcars)

  out <- print(obj)
  expect_identical(out, obj)
})

test_that("summary_table() prints through the publication-ready builder", {
  obj <- summary_table(mtcars, by = am, include = c(mpg, wt))

  capture.output(out <- print(obj))
  expect_identical(out, obj)
})

test_that("print.gt_distribution() returns the object invisibly", {
  obj <- assess_distribution(mtcars, vars = c("mpg", "wt"))

  out <- print(obj)
  expect_identical(out, obj)
})

test_that("print.gt_variance() returns the object invisibly", {
  obj <- assess_variance(mtcars, vars = c("mpg", "wt"), by = am)

  out <- print(obj)
  expect_identical(out, obj)
})

test_that("print.gt_compare() returns invisibly and renders the table", {
  obj <- compare_groups(mtcars, variable = mpg, group = am)

  capture.output(out <- print(obj))
  expect_identical(out, obj)
})

test_that("print.gt_correlation() returns invisibly and renders the table", {
  obj <- correlation(mtcars, x = mpg, y = wt)

  capture.output(out <- print(obj))
  expect_identical(out, obj)
})

test_that("print.gtstats_summary() works when table is empty", {
  obj <- summary_table(mtcars, by = am)

  expect_output(
    out <- print(obj),
    regexp = "No variables have been selected"
  )
  expect_identical(out, obj)
})

test_that("print.gtstats_summary() works when table has rows", {
  obj <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  capture.output(out <- print(obj))
  expect_identical(out, obj)
})

test_that("print.gt_prop() returns invisibly and prints a gt table", {
  obj <- proportion_stats(mtcars, var = vs, by = am)

  expect_output(
    out <- print(obj),
    regexp = "flextable object"
  )
  expect_identical(out, obj)
})

test_that("print.gt_rate() returns invisibly and prints a gt table", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    ptime = c(10, 12, 8, 9, 11, 7),
    arm = c("A", "A", "A", "B", "B", "B")
  )

  obj <- rate_stats(df, event = event, time = ptime, by = arm)

  expect_output(
    out <- print(obj),
    regexp = "flextable object"
  )
  expect_identical(out, obj)
})

test_that("print.gt_twobytwo() returns invisibly and prints a gt table", {
  obj <- crosstabs(mtcars, row = am, col = vs)

  expect_output(
    out <- print(obj),
    regexp = "flextable object"
  )
  expect_identical(out, obj)
})

test_that("print.gt_compare() has a publication-ready gt representation", {
  obj <- compare_groups(mtcars, variable = mpg, group = am)
  expect_s3_class(to_gt(obj), "gt_tbl")
})

test_that("direct and incremental summary tables both render", {
  obj1 <- summary_table(mtcars, include = c(mpg, wt))
  obj2 <- summary_table(mtcars, by = am) |> add_summary(vars = c(mpg))

  capture.output(out1 <- print(obj1))
  expect_identical(out1, obj1)
  capture.output(out <- print(obj2))
  expect_identical(out, obj2)
})
