test_that("plot_compare() uses the minimal continuous interface", {
  p <- plot_compare(mtcars, variable = mpg, group = am)

  expect_s3_class(p, "ggplot")
  expect_equal(attr(p, "source"), "plot_compare")
  expect_equal(attr(p, "plot_type"), "box")
  expect_equal(length(p$layers), 2L)
  expect_match(p$scales$get_scales("x")$labels[["0"]], "N = 19")
})

test_that("plot_compare() accepts character variable names", {
  p <- plot_compare(mtcars, variable = "mpg", group = "am")

  expect_s3_class(p, "ggplot")
})

test_that("continuous plots support labels, palette, size, and hidden points", {
  p <- plot_compare(
    mtcars,
    variable = mpg,
    group = am,
    show_points = FALSE,
    palette = c("#111111", "#999999"),
    base_size = 12,
    title = "Fuel economy",
    caption = "Complete observations",
    xlab = "Transmission",
    ylab = "Miles per gallon"
  )

  expect_equal(length(p$layers), 1L)
  expect_identical(p$labels$title, "Fuel economy")
  expect_identical(p$labels$caption, "Complete observations")
  expect_identical(p$labels$x, "Transmission")
  expect_identical(p$labels$y, "Miles per gallon")
})

test_that("continuous p-value caption identifies the selected test", {
  p <- plot_compare(
    mtcars,
    variable = mpg,
    group = am,
    show_p = TRUE,
    test = "wilcox"
  )

  expect_match(p$labels$caption, "Wilcoxon rank-sum test")
  expect_match(p$labels$caption, "p")
})

test_that("plot_compare() forwards var_equal to the auto comparison", {
  p <- plot_compare(
    mtcars, variable = mpg, group = am, show_p = TRUE,
    var_equal = TRUE
  )
  expect_match(p$labels$caption, "Student t-test")
  expect_error(
    plot_compare(mtcars, variable = mpg, group = am, var_equal = "yes"),
    "var_equal"
  )
})

test_that("a user caption is retained with the test annotation", {
  p <- plot_compare(
    mtcars,
    variable = mpg,
    group = am,
    show_p = TRUE,
    caption = "Primary analysis"
  )

  expect_match(p$labels$caption, "^Primary analysis \\| ")
})

test_that("categorical auto plot shows proportions and complete-case Ns", {
  p <- plot_compare(mtcars, variable = vs, group = am)

  expect_s3_class(p, "ggplot")
  expect_equal(attr(p, "plot_type"), "bar")
  expect_identical(p$labels$y, "Proportion")
  expect_match(p$scales$get_scales("x")$labels[["0"]], "N = 19")
  expect_equal(p$scales$get_scales("y")$labels(c(0, 0.5, 1)),
               c("0%", "50%", "100%"))
})

test_that("categorical plots support counts and custom legend", {
  p <- plot_compare(
    mtcars,
    variable = vs,
    group = am,
    display = "count",
    legend_title = "Engine",
    palette = c("#336699", "#CC6633")
  )

  expect_identical(p$labels$y, "Count")
  expect_identical(p$labels$fill, "Engine")
})

test_that("categorical p-value caption uses compare_groups()", {
  p <- plot_compare(
    mtcars,
    variable = vs,
    group = am,
    show_p = TRUE,
    test = "chisq"
  )

  expect_match(p$labels$caption, "Chi-square test")
})

test_that("ordinal plots preserve declared level order", {
  dat <- data.frame(
    arm = factor(rep(c("A", "B"), each = 5)),
    response = ordered(
      c("None", "Mild", "Mild", "Severe", "None",
        "Mild", "Severe", "Severe", "None", "Mild"),
      levels = c("None", "Mild", "Severe")
    )
  )

  p <- plot_compare(dat, variable = response, group = arm)

  expect_equal(attr(p, "plot_type"), "ordinal_bar")
  expect_identical(levels(p$data$outcome), c("None", "Mild", "Severe"))
})

test_that("paired continuous plots retain complete pairs only", {
  dat <- data.frame(
    id = rep(1:6, 2),
    visit = factor(rep(c("Before", "After"), each = 6)),
    score = c(8, 11, 10, 13, 9, 14, 10, 12, 13, 15, NA, 18)
  )

  p <- plot_compare(
    dat,
    variable = score,
    group = visit,
    paired = TRUE,
    id = id
  )

  expect_s3_class(p, "ggplot")
  expect_equal(attr(p, "plot_type"), "paired")
  expect_equal(length(unique(p$data$id)), 5L)
  expect_match(p$scales$get_scales("x")$labels[["Before"]], "N = 5")
})

test_that("paired p-value uses the paired test", {
  dat <- data.frame(
    id = rep(1:8, 2),
    visit = factor(rep(c("Before", "After"), each = 8)),
    score = c(8, 11, 10, 13, 9, 14, 12, 16,
              10, 12, 13, 14, 12, 15, 16, 19)
  )

  p <- plot_compare(
    dat,
    variable = score,
    group = visit,
    paired = TRUE,
    id = id,
    show_p = TRUE,
    test = "t_test"
  )

  expect_match(p$labels$caption, "Paired t-test")
})

test_that("missing observations are reflected in displayed denominators", {
  dat <- mtcars
  dat$mpg[c(1, 2)] <- NA_real_
  dat$am[c(3, 4)] <- NA_real_

  p <- plot_compare(dat, variable = mpg, group = am)
  labels <- unname(unlist(p$scales$get_scales("x")$labels))

  expect_true(any(grepl("N = 18", labels)))
  expect_true(any(grepl("N = 10", labels)))
})

test_that("non-finite continuous observations are excluded consistently", {
  dat <- mtcars
  dat$mpg[1] <- Inf

  p <- plot_compare(dat, variable = mpg, group = am, show_p = TRUE)
  labels <- unname(unlist(p$scales$get_scales("x")$labels))

  expect_true(any(grepl("N = 12", labels)))
  expect_match(p$labels$caption, "p")
})

test_that("plot_compare() validates data and variable structure", {
  expect_error(
    plot_compare(1:10, variable = mpg, group = am),
    "`data` must be a data.frame."
  )
  expect_error(
    plot_compare(mtcars, variable = absent, group = am),
    "`absent` was not found"
  )
  expect_error(
    plot_compare(mtcars, variable = mpg, group = absent),
    "`absent` was not found"
  )
  expect_error(
    plot_compare(mtcars, variable = mpg, group = mpg),
    "must be different"
  )
  expect_error(
    plot_compare(mtcars, variable = mpg, group = wt),
    "categorical"
  )
})

test_that("plot_compare() validates plot choices", {
  expect_error(
    plot_compare(mtcars, variable = vs, group = am, type = "box"),
    "continuous outcome"
  )
  expect_error(
    plot_compare(mtcars, variable = mpg, group = am, type = "bar"),
    "categorical"
  )
  expect_error(
    plot_compare(mtcars, variable = mpg, group = am, palette = "red"),
    "palette"
  )
  expect_error(
    plot_compare(mtcars, variable = mpg, group = am, base_size = 0),
    "base_size"
  )
})

test_that("paired plotting validates IDs and supports categorical outcomes", {
  paired <- data.frame(
    id = rep(1:3, 2),
    visit = rep(c("Before", "After"), each = 3),
    score = 1:6,
    result = factor(rep(c("No", "Yes"), 3))
  )

  expect_error(
    plot_compare(paired, score, visit, paired = TRUE),
    "`id` is required"
  )
  expect_s3_class(
    plot_compare(paired, result, visit, paired = TRUE, id = id),
    "ggplot"
  )

  duplicated_data <- rbind(paired, paired[1, ])
  expect_error(
    plot_compare(
      duplicated_data,
      score,
      visit,
      paired = TRUE,
      id = id
    ),
    "at most one observation"
  )
})

test_that("retired plotting arguments are rejected", {
  expect_error(
    plot_compare(mtcars, mpg, by = am),
    "unused argument"
  )
  expect_error(
    plot_compare(mtcars, mpg, am, quiet = TRUE),
    "unused argument"
  )
  expect_error(
    plot_compare(mtcars, mpg, am, jitter = FALSE),
    "unused argument"
  )
  expect_error(
    plot_compare(mtcars, vs, am, proportions = FALSE),
    "unused argument"
  )
})

test_that("plot_compare supports paired categorical and repeated continuous data", {
  categorical <- data.frame(
    id = rep(1:12, each = 3),
    visit = factor(rep(c("Baseline", "Month 1", "Month 3"), 12),
                   levels = c("Baseline", "Month 1", "Month 3")),
    response = factor(rep(c("No", "Yes"), 18))
  )
  p_cat <- plot_compare(categorical, response, visit, paired = TRUE,
                        id = id, show_p = TRUE, test = "cochran_q")
  expect_s3_class(p_cat, "ggplot")

  continuous <- transform(
    categorical,
    score = rep(1:12, each = 3) + rep(c(0, 1, 2), 12)
  )
  p_cont <- plot_compare(continuous, score, visit, paired = TRUE,
                         id = id, show_p = TRUE, test = "rm_anova")
  expect_s3_class(p_cont, "ggplot")
})
