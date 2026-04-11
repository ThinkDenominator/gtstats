test_that("save_table() saves html from a gtstats object to tempdir by default", {
  skip_if_not_installed("gt")

  res <- descriptive_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt, cyl)) |>
    add_proportion(var = vs) |>
    add_total() |>
    add_p()

  file_name <- "gtstats_table_test.html"

  out <- save_table(
    x = res,
    filename = file_name,
    quiet = TRUE
  )

  expect_true(is.character(out))
  expect_length(out, 1)
  expect_true(file.exists(out))
  expect_match(basename(out), "gtstats_table_test[.]html$")
  expect_identical(dirname(out), tempdir())
})

test_that("save_table() saves html from a gt_tbl object", {
  skip_if_not_installed("gt")

  gt_obj <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    tbl_stats()

  out_file <- tempfile(fileext = ".html")

  out <- save_table(
    x = gt_obj,
    filename = basename(out_file),
    path = dirname(out_file),
    quiet = TRUE
  )

  expect_true(file.exists(out))
  expect_identical(normalizePath(out, winslash = "/", mustWork = FALSE),
                   normalizePath(out_file, winslash = "/", mustWork = FALSE))
})

test_that("save_table() saves png with explicit sizing arguments", {
  skip_if_not_installed("gt")

  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  out_file <- tempfile(fileext = ".png")

  out <- save_table(
    x = res,
    filename = basename(out_file),
    path = dirname(out_file),
    zoom = 1.5,
    expand = 5,
    vwidth = 1200,
    vheight = 800,
    quiet = TRUE
  )

  expect_true(file.exists(out))
  expect_identical(tolower(tools::file_ext(out)), "png")
})

test_that("save_table() creates nested directory if needed", {
  skip_if_not_installed("gt")

  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  nested_dir <- file.path(tempdir(), "gtstats_test_nested", "tables")
  out <- save_table(
    x = res,
    filename = "nested_table.html",
    path = nested_dir,
    quiet = TRUE
  )

  expect_true(dir.exists(nested_dir))
  expect_true(file.exists(out))
})

test_that("save_table() passes title and subtitle through tbl_stats()", {
  skip_if_not_installed("gt")

  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  out_file <- tempfile(fileext = ".html")

  out <- save_table(
    x = res,
    filename = basename(out_file),
    path = dirname(out_file),
    title = "My title",
    subtitle = "My subtitle",
    quiet = TRUE
  )

  expect_true(file.exists(out))
})

test_that("save_table() errors for invalid filename", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  expect_error(
    save_table(res, filename = "", quiet = TRUE),
    "`filename` must be a single non-empty character string."
  )
})

test_that("save_table() errors for invalid path", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  expect_error(
    save_table(res, filename = "x.html", path = c("a", "b"), quiet = TRUE),
    "`path` must be NULL or a single non-empty character string."
  )
})

test_that("save_table() errors for unsupported extension", {
  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  expect_error(
    save_table(res, filename = "x.csv", quiet = TRUE),
    "Unsupported table file extension"
  )
})

test_that("save_table() errors for unsupported input", {
  expect_error(
    save_table(mtcars, filename = "x.html", quiet = TRUE),
    regexp = "must be a gtstats object compatible with `tbl_stats()` or a `gt_tbl`",
    fixed = TRUE
  )
})
test_that("save_plot() saves png to tempdir by default", {
  skip_if_not_installed("ggplot2")

  p <- plot_compare(
    mtcars,
    outcome = mpg,
    group = am,
    quiet = TRUE
  )

  out <- save_plot(
    plot = p,
    filename = "gtstats_plot_test.png",
    quiet = TRUE
  )

  expect_true(is.character(out))
  expect_length(out, 1)
  expect_true(file.exists(out))
  expect_match(basename(out), "gtstats_plot_test[.]png$")
  expect_identical(dirname(out), tempdir())
})

test_that("save_plot() saves to explicit path", {
  skip_if_not_installed("ggplot2")

  p <- plot_compare(
    mtcars,
    outcome = mpg,
    group = am,
    quiet = TRUE
  )

  out_file <- tempfile(fileext = ".png")

  out <- save_plot(
    plot = p,
    filename = basename(out_file),
    path = dirname(out_file),
    width = 6,
    height = 4,
    dpi = 200,
    quiet = TRUE
  )

  expect_true(file.exists(out))
  expect_identical(normalizePath(out, winslash = "/", mustWork = FALSE),
                   normalizePath(out_file, winslash = "/", mustWork = FALSE))
})

test_that("save_plot() supports tiff output", {
  skip_if_not_installed("ggplot2")

  p <- plot_compare(
    mtcars,
    outcome = mpg,
    group = am,
    quiet = TRUE
  )

  out_file <- tempfile(fileext = ".tiff")

  out <- save_plot(
    plot = p,
    filename = basename(out_file),
    path = dirname(out_file),
    width = 6,
    height = 4,
    dpi = 300,
    quiet = TRUE
  )

  expect_true(file.exists(out))
  expect_identical(tolower(tools::file_ext(out)), "tiff")
})

test_that("save_plot() creates nested directory if needed", {
  skip_if_not_installed("ggplot2")

  p <- plot_compare(
    mtcars,
    outcome = vs,
    group = am,
    quiet = TRUE
  )

  nested_dir <- file.path(tempdir(), "gtstats_test_nested", "plots")
  out <- save_plot(
    plot = p,
    filename = "nested_plot.png",
    path = nested_dir,
    quiet = TRUE
  )

  expect_true(dir.exists(nested_dir))
  expect_true(file.exists(out))
})

test_that("save_plot() errors for non-ggplot input", {
  expect_error(
    save_plot(plot = mtcars, filename = "x.png", quiet = TRUE),
    "`plot` must be a ggplot object."
  )
})

test_that("save_plot() errors for invalid filename", {
  p <- plot_compare(
    mtcars,
    outcome = mpg,
    group = am,
    quiet = TRUE
  )

  expect_error(
    save_plot(plot = p, filename = "", quiet = TRUE),
    "`filename` must be a single non-empty character string."
  )
})

test_that("save_plot() errors for invalid path", {
  p <- plot_compare(
    mtcars,
    outcome = mpg,
    group = am,
    quiet = TRUE
  )

  expect_error(
    save_plot(plot = p, filename = "x.png", path = c("a", "b"), quiet = TRUE),
    "`path` must be NULL or a single non-empty character string."
  )
})

test_that("save_plot() errors for invalid width, height, and dpi", {
  p <- plot_compare(
    mtcars,
    outcome = mpg,
    group = am,
    quiet = TRUE
  )

  expect_error(
    save_plot(plot = p, filename = "x.png", width = 0, quiet = TRUE),
    "`width` must be a single positive number."
  )

  expect_error(
    save_plot(plot = p, filename = "x.png", height = -1, quiet = TRUE),
    "`height` must be a single positive number."
  )

  expect_error(
    save_plot(plot = p, filename = "x.png", dpi = 0, quiet = TRUE),
    "`dpi` must be a single positive number."
  )
})

test_that("save_table() returns invisible path", {
  skip_if_not_installed("gt")

  res <- descriptive_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  out <- withVisible(
    save_table(res, filename = "invisible_table.html", quiet = TRUE)
  )

  expect_false(out$visible)
  expect_true(file.exists(out$value))
})

test_that("save_plot() returns invisible path", {
  skip_if_not_installed("ggplot2")

  p <- plot_compare(
    mtcars,
    outcome = mpg,
    group = am,
    quiet = TRUE
  )

  out <- withVisible(
    save_plot(plot = p, filename = "invisible_plot.png", quiet = TRUE)
  )

  expect_false(out$visible)
  expect_true(file.exists(out$value))
})
