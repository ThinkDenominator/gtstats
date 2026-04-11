test_that("print.gt_describe() returns invisibly and prints expected text", {
  obj <- describe_data(mtcars)

  expect_output(
    out <- print(obj),
    regexp = "GTstats: Dataset overview"
  )
  expect_identical(out, obj)
})

test_that("print.gt_summary() returns invisibly and prints expected text", {
  obj <- summary_stats(mtcars, by = am)

  expect_output(
    out <- print(obj),
    regexp = "GTstats: Summary statistics"
  )
  expect_identical(out, obj)
})

test_that("print.gt_distribution() returns invisibly and prints expected text", {
  obj <- check_distribution(mtcars, vars = c("mpg", "wt"))

  expect_output(
    out <- print(obj),
    regexp = "GTstats: Distribution check"
  )
  expect_identical(out, obj)
})

test_that("print.gt_compare() returns invisibly and prints expected text", {
  obj <- compare_groups(mtcars, outcome = mpg, group = am)

  expect_output(
    out <- print(obj),
    regexp = "GTstats: Group comparison"
  )
  expect_identical(out, obj)
})

test_that("print.gt_correlation() returns invisibly and prints expected text", {
  obj <- correlate_vars(mtcars, x = mpg, y = wt)

  expect_output(
    out <- print(obj),
    regexp = "GTstats: Correlation analysis"
  )
  expect_identical(out, obj)
})

test_that("print.gt_desc_table() works when table is empty", {
  obj <- descriptive_table(mtcars, by = am)

  expect_output(
    out <- print(obj),
    regexp = "No rows have been added yet"
  )
  expect_identical(out, obj)
})

test_that("print.gt_desc_table() works when table has rows", {
  obj <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  expect_output(
    out <- print(obj),
    regexp = "GTstats: Descriptive table builder"
  )
  expect_identical(out, obj)
})

test_that("print.gt_prop() returns invisibly and prints expected text", {
  obj <- prop_ci(mtcars, var = vs, by = am)

  expect_output(
    out <- print(obj),
    regexp = "GTstats: Proportion with confidence interval"
  )
  expect_identical(out, obj)
})

test_that("print.gt_rate() returns invisibly and prints expected text", {
  df <- data.frame(
    event = c(1, 0, 1, 0, 1, 1),
    ptime = c(10, 12, 8, 9, 11, 7),
    arm = c("A", "A", "A", "B", "B", "B")
  )

  obj <- rate_stats(df, event = event, time = ptime, by = arm)

  expect_output(
    out <- print(obj),
    regexp = "GTstats: Rate with confidence interval"
  )
  expect_identical(out, obj)
})

test_that("print.gt_twobytwo() returns invisibly and prints expected text", {
  obj <- twobytwo_table(mtcars, exposure = am, outcome = vs)

  expect_output(
    out <- print(obj),
    regexp = "GTstats: 2x2 epidemiology table"
  )
  expect_identical(out, obj)
})

test_that("print.gt_summary() handles long tables", {
  obj <- summary_stats(mtcars)

  expect_output(
    print(obj),
    regexp = "Showing first 10 rows only|Showing first 10 variables only"
  )
})

test_that("print.gt_compare() prints inferential section", {
  obj <- compare_groups(mtcars, outcome = mpg, group = am)

  expect_output(
    print(obj),
    regexp = "Inferential result"
  )
})

test_that("print methods mention tbl_stats helper where appropriate", {
  obj1 <- summary_stats(mtcars)
  obj2 <- descriptive_table(mtcars, by = am) |> add_summary(vars = c(mpg))

  expect_output(print(obj1), regexp = "Use tbl_stats\\(x\\) for a formatted table")
  expect_output(print(obj2), regexp = "Use tbl_stats\\(x\\) for a formatted table")
})
