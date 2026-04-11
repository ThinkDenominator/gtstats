#' Save a ggplot object to file
#'
#' Save a `ggplot` object to disk using `ggplot2::ggsave()`.
#'
#' If `path = NULL`, the file is saved to `tempdir()` and the full
#' path is reported in a message.
#'
#' Supported formats include PNG, PDF, TIFF, JPEG, and SVG,
#' depending on the graphics device available.
#'
#' @param plot A `ggplot` object.
#' @param filename Output file name, including extension.
#' @param path Optional directory to save into. Defaults to
#'   `tempdir()`.
#' @param width Width of the plot.
#' @param height Height of the plot.
#' @param units Units for width and height. One of `"in"`,
#'   `"cm"`, `"mm"`.
#' @param dpi Resolution in dots per inch for raster outputs.
#' @param bg Background colour passed to `ggsave()`.
#' @param quiet Logical; suppress save message.
#' @param ... Additional arguments passed to
#'   `ggplot2::ggsave()`.
#'
#' @return Invisibly returns the saved file path.
#'
#' @examples
#' library(ggplot2)
#'
#' p <- ggplot(mtcars, aes(x = wt, y = mpg)) +
#'   geom_point()
#'
#' # Save to temporary directory
#' save_plot(p, filename = "example_plot.png")
#'
#' # Save to a specific folder
#' \donttest{
#' save_plot(
#'   p,
#'   filename = "example_plot.pdf",
#'   path = tempdir(),
#'   width = 6,
#'   height = 4
#' )
#' }
#'
#' @export
save_plot <- function(
    plot,
    filename,
    path = NULL,
    width = 7,
    height = 5,
    units = c("in", "cm", "mm"),
    dpi = 300,
    bg = "white",
    quiet = FALSE,
    ...
) {
  units <- match.arg(units)

  if (!inherits(plot, "ggplot")) {
    stop("`plot` must be a ggplot object.", call. = FALSE)
  }

  if (!is.character(filename) || length(filename) != 1 ||
      is.na(filename) || filename == "") {
    stop(
      "`filename` must be a single non-empty character string.",
      call. = FALSE
    )
  }

  if (!is.null(path)) {
    if (!is.character(path) || length(path) != 1 ||
        is.na(path) || path == "") {
      stop(
        "`path` must be NULL or a single non-empty character string.",
        call. = FALSE
      )
    }
  }

  if (!is.numeric(width) || length(width) != 1 ||
      is.na(width) || width <= 0) {
    stop("`width` must be a single positive number.", call. = FALSE)
  }

  if (!is.numeric(height) || length(height) != 1 ||
      is.na(height) || height <= 0) {
    stop("`height` must be a single positive number.", call. = FALSE)
  }

  if (!is.numeric(dpi) || length(dpi) != 1 ||
      is.na(dpi) || dpi <= 0) {
    stop("`dpi` must be a single positive number.", call. = FALSE)
  }

  save_dir <- if (is.null(path)) {
    tempdir()
  } else {
    path
  }

  if (!dir.exists(save_dir)) {
    dir.create(save_dir, recursive = TRUE, showWarnings = FALSE)
  }

  out_file <- file.path(save_dir, filename)

  ggplot2::ggsave(
    filename = out_file,
    plot = plot,
    width = width,
    height = height,
    units = units,
    dpi = dpi,
    bg = bg,
    ...
  )

  if (!quiet) {
    message(
      "Plot saved to: ",
      normalizePath(out_file, winslash = "/", mustWork = FALSE)
    )
  }

  invisible(out_file)
}
