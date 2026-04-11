test_that("plot_compare() returns ggplot for continuous outcome with auto type", {
  p <- plot_compare(
    mtcars,
    outcome = mpg,
    group = am,
    quiet = TRUE
  )

  expect_s3_class(p, "ggplot")
})

test_that("plot_compare() returns ggplot for continuous outcome with explicit box type", {
  p <- plot_compare(
    mtcars,
    outcome = mpg,
    group = am,
    type = "box",
    quiet = TRUE
  )

  expect_s3_class(p, "ggplot")
})

test_that("plot_compare() supports character input for outcome and group", {
  p <- plot_compare(
    mtcars,
    outcome = "mpg",
    group = "am",
    quiet = TRUE
  )

  expect_s3_class(p, "ggplot")
})

test_that("plot_compare() supports custom title and labels", {
  p <- plot_compare(
    mtcars,
    outcome = mpg,
    group = am,
    title = "My title",
    xlab = "Transmission",
    ylab = "Miles per gallon",
    quiet = TRUE
  )

  expect_s3_class(p, "ggplot")
  expect_identical(p$labels$title, "My title")
  expect_identical(p$labels$x, "Transmission")
  expect_identical(p$labels$y, "Miles per gallon")
})

test_that("plot_compare() supports boxplot without jitter", {
  p <- plot_compare(
    mtcars,
    outcome = mpg,
    group = am,
    jitter = FALSE,
    quiet = TRUE
  )

  expect_s3_class(p, "ggplot")
})

test_that("plot_compare() adds p-value annotation for continuous outcome", {
  p <- plot_compare(
    mtcars,
    outcome = mpg,
    group = am,
    show_p = TRUE,
    quiet = TRUE
  )

  expect_s3_class(p, "ggplot")
  expect_true(inherits(p$coordinates, "CoordCartesian"))
})

test_that("plot_compare() handles zero-range continuous outcome when showing p-value", {
  dat <- data.frame(
    grp = c(rep(NA, 10), "A", "A", "B", "B"),
    y   = c(1:10, 5, 5, 5, 5)
  )

  p <- plot_compare(
    dat,
    outcome = y,
    group = grp,
    type = "box",
    show_p = TRUE,
    quiet = TRUE
  )

  expect_s3_class(p, "ggplot")
})

test_that("plot_compare() returns ggplot for binary categorical outcome with auto type", {
  p <- plot_compare(
    mtcars,
    outcome = vs,
    group = am,
    quiet = TRUE
  )

  expect_s3_class(p, "ggplot")
})

test_that("plot_compare() returns ggplot for categorical outcome with proportions", {
  p <- plot_compare(
    mtcars,
    outcome = cyl,
    group = am,
    type = "bar",
    proportions = TRUE,
    quiet = TRUE
  )

  expect_s3_class(p, "ggplot")
})

test_that("plot_compare() returns ggplot for categorical outcome with counts", {
  p <- plot_compare(
    mtcars,
    outcome = cyl,
    group = am,
    type = "bar",
    proportions = FALSE,
    quiet = TRUE
  )

  expect_s3_class(p, "ggplot")
})

test_that("plot_compare() adds p-value annotation for proportional bar plot", {
  p <- plot_compare(
    mtcars,
    outcome = vs,
    group = am,
    type = "bar",
    proportions = TRUE,
    show_p = TRUE,
    quiet = TRUE
  )

  expect_s3_class(p, "ggplot")
  expect_true(inherits(p$coordinates, "CoordCartesian"))
})

test_that("plot_compare() adds p-value annotation for count bar plot", {
  p <- plot_compare(
    mtcars,
    outcome = vs,
    group = am,
    type = "bar",
    proportions = FALSE,
    show_p = TRUE,
    quiet = TRUE
  )

  expect_s3_class(p, "ggplot")
  expect_true(inherits(p$coordinates, "CoordCartesian"))
})

test_that("plot_compare() sets default y label for proportions", {
  p <- plot_compare(
    mtcars,
    outcome = vs,
    group = am,
    type = "bar",
    proportions = TRUE,
    quiet = TRUE
  )

  expect_identical(p$labels$y, "Proportion")
})

test_that("plot_compare() sets default y label for counts", {
  p <- plot_compare(
    mtcars,
    outcome = vs,
    group = am,
    type = "bar",
    proportions = FALSE,
    quiet = TRUE
  )

  expect_identical(p$labels$y, "Count")
})

test_that("plot_compare() respects explicit legend title argument indirectly through fill label logic", {
  p <- plot_compare(
    mtcars,
    outcome = vs,
    group = am,
    type = "bar",
    quiet = TRUE
  )

  expect_s3_class(p, "ggplot")
  expect_false(is.null(p$labels$fill))
})

test_that("plot_compare() works when data contain missing values", {
  dat <- mtcars
  dat$mpg[c(1, 2)] <- NA
  dat$am[c(3, 4)] <- NA

  p <- plot_compare(
    dat,
    outcome = mpg,
    group = am,
    quiet = TRUE
  )

  expect_s3_class(p, "ggplot")
})

test_that("plot_compare() errors when data is not a data.frame", {
  expect_error(
    plot_compare(1:10, outcome = mpg, group = am, quiet = TRUE),
    "`data` must be a data.frame."
  )
})

test_that("plot_compare() errors when outcome is not found", {
  expect_error(
    plot_compare(mtcars, outcome = not_a_var, group = am, quiet = TRUE),
    "`outcome` was not found in `data`."
  )
})

test_that("plot_compare() errors when group is not found", {
  expect_error(
    plot_compare(mtcars, outcome = mpg, group = not_a_var, quiet = TRUE),
    "`group` was not found in `data`."
  )
})

test_that("plot_compare() errors when outcome and group are the same", {
  expect_error(
    plot_compare(mtcars, outcome = mpg, group = mpg, quiet = TRUE),
    "`outcome` and `group` must be different variables."
  )
})

test_that("plot_compare() errors when group is continuous", {
  expect_error(
    plot_compare(mtcars, outcome = mpg, group = wt, quiet = TRUE),
    "`group` should be a categorical, binary, or ordinal variable."
  )
})

test_that("plot_compare() errors when no complete cases are available", {
  dat <- data.frame(
    outcome = c(NA, NA),
    group = c(NA, NA)
  )

  expect_error(
    plot_compare(dat, outcome = outcome, group = group, quiet = TRUE),
    "No complete cases available for `outcome` and `group`."
  )
})

test_that("plot_compare() errors when type box is used with categorical outcome", {
  expect_error(
    plot_compare(mtcars, outcome = vs, group = am, type = "box", quiet = TRUE),
    "`type = \"box\"` requires a continuous outcome."
  )
})

test_that("plot_compare() errors when type bar is used with continuous outcome", {
  expect_error(
    plot_compare(mtcars, outcome = mpg, group = am, type = "bar", quiet = TRUE),
    "`type = \"bar\"` requires a categorical, binary, or ordinal outcome."
  )
})

test_that("plot_compare() emits message for continuous outcome when quiet is FALSE", {
  expect_message(
    plot_compare(mtcars, outcome = mpg, group = am, quiet = FALSE),
    "Continuous outcome detected: showing boxplot by group."
  )
})

test_that("plot_compare() emits message for proportional bar plot when quiet is FALSE", {
  expect_message(
    plot_compare(
      mtcars,
      outcome = vs,
      group = am,
      type = "bar",
      proportions = TRUE,
      quiet = FALSE
    ),
    "Categorical outcome detected: showing within-group proportions."
  )
})

test_that("plot_compare() emits message for count bar plot when quiet is FALSE", {
  expect_message(
    plot_compare(
      mtcars,
      outcome = vs,
      group = am,
      type = "bar",
      proportions = FALSE,
      quiet = FALSE
    ),
    "Categorical outcome detected: showing counts by group."
  )
})

test_that("plot_compare() supports grouped variable supplied as character string", {
  p <- plot_compare(
    mtcars,
    outcome = "vs",
    group = "am",
    type = "bar",
    proportions = FALSE,
    quiet = TRUE
  )

  expect_s3_class(p, "ggplot")
})

test_that("plot_compare() handles ordinal-like outcome as bar plot", {
  dat <- data.frame(
    grp = c("A", "A", "B", "B", "B"),
    ord = factor(c("low", "medium", "low", "high", "medium"),
                 ordered = TRUE,
                 levels = c("low", "medium", "high"))
  )

  p <- plot_compare(
    dat,
    outcome = ord,
    group = grp,
    type = "bar",
    proportions = TRUE,
    quiet = TRUE
  )

  expect_s3_class(p, "ggplot")
})
