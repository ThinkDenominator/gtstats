test_that("plot_correlation() returns a minimal publication plot", {
  p <- plot_correlation(mtcars, x = mpg, y = wt)

  expect_s3_class(p, "ggplot")
  expect_identical(attr(p, "source"), "plot_correlation")
  expect_identical(attr(p, "correlation_method"), "pearson")
  expect_identical(attr(p, "trend"), "linear")
  expect_equal(attr(p, "n_complete"), 32)
  expect_match(p$labels$caption, "Complete pairs: N = 32", fixed = TRUE)
  expect_length(p$layers, 2L)
})

test_that("plot_correlation() accepts character variables and complete pairs", {
  dat <- mtcars
  dat$mpg[c(1, 2)] <- NA_real_
  dat$wt[c(2, 3)] <- NA_real_

  p <- plot_correlation(dat, x = "mpg", y = "wt", trend = "none")

  expect_equal(attr(p, "n_complete"), 29)
  expect_identical(attr(p, "trend"), "none")
  expect_length(p$layers, 1L)
})

test_that("plot_correlation() uses the same finite pairs as correlation()", {
  dat <- mtcars
  dat$mpg[[1L]] <- Inf
  dat$wt[[2L]] <- NaN

  p <- plot_correlation(dat, x = mpg, y = wt, trend = "none")

  expect_equal(attr(p, "n_complete"), 30L)
  expect_equal(nrow(p$data), 30L)
})

test_that("plot_correlation() annotation matches correlation method", {
  pearson <- plot_correlation(
    mtcars,
    x = mpg,
    y = wt,
    method = "pearson",
    show_correlation = TRUE
  )
  spearman <- plot_correlation(
    mtcars,
    x = mpg,
    y = wt,
    method = "spearman",
    show_correlation = TRUE
  )

  expect_match(pearson$labels$caption, "Pearson correlation", fixed = TRUE)
  expect_match(pearson$labels$caption, "95% CI", fixed = TRUE)
  expect_match(pearson$labels$caption, "r = ", fixed = TRUE)
  expect_match(spearman$labels$caption, "Spearman correlation", fixed = TRUE)
  expect_match(spearman$labels$caption, "rho = ", fixed = TRUE)
  expect_false(grepl("CI", spearman$labels$caption, fixed = TRUE))
  expect_identical(attr(spearman, "trend"), "smooth")
})

test_that("plot_correlation() supports explicit visual controls", {
  p <- plot_correlation(
    mtcars,
    x = mpg,
    y = wt,
    trend = "linear",
    show_ci = FALSE,
    point_color = "navy",
    line_color = "orange",
    caption = "Study sample",
    xlab = "X label",
    ylab = "Y label"
  )

  expect_match(p$labels$caption, "Study sample", fixed = TRUE)
  expect_match(p$labels$caption, "Complete pairs", fixed = TRUE)
  expect_identical(p$labels$x, "X label")
  expect_identical(p$labels$y, "Y label")
  expect_false(p$layers[[2L]]$stat_params$se)
})

test_that("plot_correlation() validates its inputs", {
  expect_error(
    plot_correlation(mtcars, x = mpg, y = mpg),
    "must be different"
  )
  expect_error(
    plot_correlation(mtcars, x = mpg, y = am),
    "continuous variables only"
  )
  expect_error(
    plot_correlation(mtcars, x = missing, y = wt),
    "not found"
  )
  expect_error(
    plot_correlation(mtcars, x = mpg, y = wt, show_ci = NA),
    "TRUE or FALSE"
  )
  expect_error(
    plot_correlation(mtcars, x = mpg, y = wt, point_color = ""),
    "single colour"
  )
})
