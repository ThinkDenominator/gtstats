#' Save a formatted table to file
#'
#' Save a `gtstats` object or a rendered `gt_tbl` to disk.
#'
#' If a `gtstats` object is supplied, it is first rendered with
#' [tbl_stats()]. If `path = NULL`, the file is saved to `tempdir()`
#' and the full path is reported in a message.
#'
#' Supported formats depend on [gt::gtsave()] and currently include:
#' HTML, PNG, PDF, RTF, LaTeX, and DOCX.
#'
#' @param x A `gtstats` object or a `gt_tbl`.
#' @param filename Output file name, including extension.
#' @param path Optional directory to save into. Defaults to
#'   `tempdir()`.
#' @param title Optional title passed to [tbl_stats()] when `x` is a
#'   `gtstats` object.
#' @param subtitle Optional subtitle passed to [tbl_stats()].
#' @param pvalue_style P-value display style passed to [tbl_stats()].
#' @param bold_labels Logical; whether labels should be bolded in
#'   [tbl_stats()].
#' @param show_footnotes Logical; whether footnotes should be shown in
#'   [tbl_stats()].
#' @param zoom Scaling factor used for PNG export where supported.
#' @param expand Number of pixels to expand image borders for PNG
#'   export.
#' @param vwidth Virtual browser width in pixels for PNG export where
#'   supported.
#' @param vheight Virtual browser height in pixels for PNG export where
#'   supported.
#' @param quiet Logical; suppress save message.
#' @param ... Additional arguments passed to [gt::gtsave()].
#'
#' @return Invisibly returns the saved file path.
#'
#' @examples
#' res <- descriptive_table(mtcars, by = am, overall = TRUE) |>
#'   add_summary(vars = c(mpg, wt, cyl)) |>
#'   add_total() |>
#'   add_p()
#'
#' \donttest{
#' save_table(res, filename = "table1.html")
#' }
#'
#' gt_obj <- tbl_stats(res)
#'
#' \donttest{
#' save_table(gt_obj, filename = "table2.html")
#' }
#'
#' @export
save_table <- function(
    x,
    filename,
    path = NULL,
    title = NULL,
    subtitle = NULL,
    pvalue_style = c("default", "scientific"),
    bold_labels = TRUE,
    show_footnotes = TRUE,
    zoom = 1.5,
    expand = 10,
    vwidth = 1400,
    vheight = 900,
    quiet = FALSE,
    ...
) {
  pvalue_style <- match.arg(pvalue_style)

  # Validate filename and optional output path
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

  save_dir <- if (is.null(path)) {
    tempdir()
  } else {
    path
  }

  if (!dir.exists(save_dir)) {
    dir.create(save_dir, recursive = TRUE, showWarnings = FALSE)
  }

  out_file <- file.path(save_dir, filename)
  ext <- tolower(tools::file_ext(out_file))

  # Restrict to supported output file types
  allowed_ext <- c("html", "htm", "png", "pdf", "rtf", "tex", "docx")

  if (!ext %in% allowed_ext) {
    stop(
      paste0(
        "Unsupported table file extension `.",
        ext,
        "`. Supported extensions are: ",
        paste(allowed_ext, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }

  # Supported gtstats object classes that can be rendered by tbl_stats()
  valid_gtstats_classes <- c(
    "gt_summary",
    "gt_distribution",
    "gt_compare",
    "gt_correlation",
    "gt_desc_table",
    "gt_prop",
    "gt_rate",
    "gt_twobytwo",
    "gt_describe"
  )

  if (!inherits(x, "gt_tbl") &&
      !any(inherits(x, valid_gtstats_classes))) {
    stop(
      paste0(
        "`x` must be a gtstats object compatible with ",
        "`tbl_stats()` or a `gt_tbl`."
      ),
      call. = FALSE
    )
  }

  # Render the input if a gtstats object was supplied
  gt_obj <- if (inherits(x, "gt_tbl")) {
    x
  } else {
    tbl_stats(
      x,
      title = title,
      subtitle = subtitle,
      pvalue_style = pvalue_style,
      bold_labels = bold_labels,
      show_footnotes = show_footnotes
    )
  }

  if (!inherits(gt_obj, "gt_tbl")) {
    stop(
      paste0(
        "`x` must be a gtstats object compatible with ",
        "`tbl_stats()` or a `gt_tbl`."
      ),
      call. = FALSE
    )
  }

  # Use PNG-specific save options where appropriate
  if (ext == "png") {
    gt::gtsave(
      data = gt_obj,
      filename = out_file,
      zoom = zoom,
      expand = expand,
      vwidth = vwidth,
      vheight = vheight,
      ...
    )
  } else {
    gt::gtsave(
      data = gt_obj,
      filename = out_file,
      ...
    )
  }

  if (!quiet) {
    message(
      "Table saved to: ",
      normalizePath(out_file, winslash = "/", mustWork = FALSE)
    )
  }

  invisible(out_file)
}
