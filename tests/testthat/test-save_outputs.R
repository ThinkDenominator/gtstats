test_that("save_output() saves html from a gtstats object", {
  skip_if_not_installed("gt")

  res <- summary_table(mtcars, by = am, overall = TRUE) |>
    add_summary(vars = c(mpg, wt, cyl)) |>
    add_proportion(var = vs) |>
    add_total() |>
    add_p()

  out_file <- tempfile(fileext = ".html")

  out <- save_output(
    x = res,
    filename = out_file,
    quiet = TRUE
  )

  expect_true(is.character(out))
  expect_length(out, 1)
  expect_true(file.exists(out))
  expect_identical(
    normalizePath(out, winslash = "/", mustWork = FALSE),
    normalizePath(out_file, winslash = "/", mustWork = FALSE)
  )
})

test_that("save_output() saves html from a gt_tbl object", {
  skip_if_not_installed("gt")

  gt_obj <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt)) |>
    tbl_stats()

  out_file <- tempfile(fileext = ".html")

  out <- save_output(
    x = gt_obj,
    filename = basename(out_file),
    path = dirname(out_file),
    quiet = TRUE
  )

  expect_true(file.exists(out))
  expect_identical(normalizePath(out, winslash = "/", mustWork = FALSE),
                   normalizePath(out_file, winslash = "/", mustWork = FALSE))
})

test_that("save_output() uses the working directory for a bare filename", {
  skip_if_not_installed("gt")

  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = mpg)
  working_dir <- tempfile("gtstats-working-directory-")
  dir.create(working_dir)
  old_dir <- getwd()
  on.exit(setwd(old_dir), add = TRUE)
  setwd(working_dir)

  out <- save_output(res, filename = "table.html", quiet = TRUE)

  expect_identical(
    out,
    normalizePath(file.path(working_dir, "table.html"), winslash = "/")
  )
  expect_true(file.exists(out))
})

test_that("save_output() supports variance assessment results", {
  skip_if_not_installed("gt")

  out_file <- tempfile(fileext = ".html")
  out <- save_output(
    assess_variance(mtcars, vars = mpg, by = am),
    filename = out_file,
    quiet = TRUE
  )

  expect_true(file.exists(out))
})

test_that("save_output() saves png with explicit sizing arguments", {
  skip_if_not_installed("webshot2")
  skip_if_not_installed("gt")

  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  out_file <- tempfile(fileext = ".png")

  out <- save_output(
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

test_that("save_output() creates nested directory if needed", {
  skip_if_not_installed("gt")

  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  nested_dir <- file.path(tempdir(), "gtstats_test_nested", "tables")
  out <- save_output(
    x = res,
    filename = "nested_table.html",
    path = nested_dir,
    quiet = TRUE
  )

  expect_true(dir.exists(nested_dir))
  expect_true(file.exists(out))
})

test_that("save_output() passes title and subtitle through tbl_stats()", {
  skip_if_not_installed("gt")

  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  out_file <- tempfile(fileext = ".html")

  out <- save_output(
    x = res,
    filename = basename(out_file),
    path = dirname(out_file),
    title = "My title",
    subtitle = "My subtitle",
    quiet = TRUE
  )

  expect_true(file.exists(out))
})

test_that("save_output() errors for invalid filename", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  expect_error(
    save_output(res, filename = "", quiet = TRUE),
    "`filename` must be a single non-empty character string."
  )
})

test_that("save_output() errors for invalid path", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  expect_error(
    save_output(res, filename = "x.html", path = c("a", "b"), quiet = TRUE),
    "`path` must be NULL or a single non-empty character string."
  )
})

test_that("save_output() errors for unsupported extension", {
  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  expect_error(
    save_output(res, filename = "x.csv", quiet = TRUE),
    "Unsupported table file extension"
  )
})

test_that("save_output() errors for unsupported input", {
  expect_error(
    save_output(mtcars, filename = "x.html", quiet = TRUE),
    regexp = "must be a gtstats object compatible with `tbl_stats()` or a `gt_tbl`",
    fixed = TRUE
  )
})
test_that("save_output() saves png", {
  skip_if_not_installed("ggplot2")

  p <- plot_compare(
    mtcars,
    outcome = mpg,
    by = am
  )

  out_file <- tempfile(fileext = ".png")
  out <- save_output(
    x = p,
    filename = out_file,
    quiet = TRUE
  )

  expect_true(is.character(out))
  expect_length(out, 1)
  expect_true(file.exists(out))
  expect_identical(
    normalizePath(out, winslash = "/", mustWork = FALSE),
    normalizePath(out_file, winslash = "/", mustWork = FALSE)
  )
})

test_that("save_output() saves to explicit path", {
  skip_if_not_installed("ggplot2")

  p <- plot_compare(
    mtcars,
    outcome = mpg,
    by = am
  )

  out_file <- tempfile(fileext = ".png")

  out <- save_output(
    x = p,
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

test_that("save_output() supports tiff output", {
  skip_if_not_installed("ggplot2")

  p <- plot_compare(
    mtcars,
    outcome = mpg,
    by = am
  )

  out_file <- tempfile(fileext = ".tiff")

  out <- save_output(
    x = p,
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

test_that("save_output() creates nested directory if needed", {
  skip_if_not_installed("ggplot2")

  p <- plot_compare(
    mtcars,
    outcome = vs,
    by = am
  )

  nested_dir <- file.path(tempdir(), "gtstats_test_nested", "plots")
  out <- save_output(
    x = p,
    filename = "nested_plot.png",
    path = nested_dir,
    quiet = TRUE
  )

  expect_true(dir.exists(nested_dir))
  expect_true(file.exists(out))
})

test_that("save_output() errors for non-ggplot input", {
  expect_error(
    save_output(x = mtcars, filename = "x.png", quiet = TRUE),
    regexp = "must be a gtstats object compatible with `tbl_stats()` or a `gt_tbl`",
    fixed = TRUE
  )
})

test_that("save_output() errors for invalid filename", {
  p <- plot_compare(
    mtcars,
    outcome = mpg,
    by = am
  )

  expect_error(
    save_output(x = p, filename = "", quiet = TRUE),
    "`filename` must be a single non-empty character string."
  )
})

test_that("save_output() errors for invalid path", {
  p <- plot_compare(
    mtcars,
    outcome = mpg,
    by = am
  )

  expect_error(
    save_output(x = p, filename = "x.png", path = c("a", "b"), quiet = TRUE),
    "`path` must be NULL or a single non-empty character string."
  )
})

test_that("save_output() errors for invalid width, height, and dpi", {
  p <- plot_compare(
    mtcars,
    outcome = mpg,
    by = am
  )

  expect_error(
    save_output(x = p, filename = "x.png", width = 0, quiet = TRUE),
    "`width` must be a single positive number."
  )

  expect_error(
    save_output(x = p, filename = "x.png", height = -1, quiet = TRUE),
    "`height` must be a single positive number."
  )

  expect_error(
    save_output(x = p, filename = "x.png", dpi = 0, quiet = TRUE),
    "`dpi` must be a single positive number."
  )
})

test_that("save_output() returns invisible path", {
  skip_if_not_installed("gt")

  res <- summary_table(mtcars, by = am) |>
    add_summary(vars = c(mpg, wt))

  out <- withVisible(
    save_output(
      res,
      filename = "invisible_table.html",
      path = tempdir(),
      quiet = TRUE
    )
  )

  expect_false(out$visible)
  expect_true(file.exists(out$value))
})

test_that("save_output() returns invisible path", {
  skip_if_not_installed("ggplot2")

  p <- plot_compare(
    mtcars,
    outcome = mpg,
    by = am
  )

  out <- withVisible(
    save_output(
      x = p,
      filename = "invisible_plot.png",
      path = tempdir(),
      quiet = TRUE
    )
  )

  expect_false(out$visible)
  expect_true(file.exists(out$value))
})

test_that("save_output() saves png with explicit sizing arguments", {
  skip_on_cran()
  skip_if(Sys.getenv("CI") != "", "Table PNG export requires a working local Chrome browser.")
  skip_if_not_installed("webshot2")
  skip_if_not_installed("gt")

  # existing test body
})
