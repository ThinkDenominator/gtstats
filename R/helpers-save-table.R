#' Save a formatted table to file
#'
#' Save a `gtstats` object, rendered `flextable`, or rendered `gt_tbl` to disk.
#'
#' If a `gtstats` object is supplied, it is rendered using the output engine
#' appropriate to the requested extension. If `path = NULL`, the file is saved
#' in the current working directory and the full path is reported in a message.
#'
#' Word, PowerPoint, HTML, RTF, and flextable image exports use `flextable`;
#' PDF and LaTeX exports use `gt`.
#'
#' @param x A `gtstats` object, `flextable`, or `gt_tbl`.
#' @param filename Output file name, including extension.
#' @param path Optional directory to save into. Defaults to
#'   the current working directory.
#' @param title Optional title passed to [to_gt()] when `x` is a
#'   `gtstats` object.
#' @param subtitle Optional subtitle passed to [to_gt()].
#' @param bold_labels Logical; whether labels should be bolded in
#'   [to_gt()].
#' @param show_footnotes Logical; whether footnotes should be shown in
#'   [to_gt()].
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
#' @noRd
#'
#' @examples
#' res <- summary_table(mtcars, by = am, overall = TRUE) |>
#'   add_summary(vars = c(mpg, wt, cyl)) |>
#'   add_total() |>
#'   add_p()
#'
#' \donttest{
#' .save_table(res, filename = "table1.html")
#' }
#'
#' gt_obj <- to_gt(res)
#'
#' \donttest{
#' .save_table(gt_obj, filename = "table2.html")
#' }
#'
.save_table <- function(
    x,
    filename,
    path = NULL,
    title = NULL,
    subtitle = NULL,
    bold_labels = TRUE,
    show_footnotes = TRUE,
    zoom = 1.5,
    expand = 10,
    vwidth = 1400,
    vheight = 900,
    quiet = FALSE,
    ...
) {
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
    getwd()
  } else {
    path
  }

  if (!dir.exists(save_dir)) {
    dir.create(save_dir, recursive = TRUE, showWarnings = FALSE)
  }

  out_file <- file.path(save_dir, filename)
  ext <- tolower(tools::file_ext(out_file))

  # Restrict to supported output file types
  allowed_ext <- c("html", "htm", "png", "pdf", "rtf", "tex", "docx", "pptx")

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

  # Supported gtstats object classes that can be rendered for export.
  valid_gtstats_classes <- c(
    "gt_distribution",
    "gt_variance",
    "gt_compare",
    "gt_correlation",
    "gt_effect",
    "gtstats_summary",
    "gt_prop",
    "gt_rate",
    "gt_epi_table",
    "gt_twobytwo",
    "gt_describe"
  )

  if (!inherits(x, c("gt_tbl", "flextable")) &&
      !any(inherits(x, valid_gtstats_classes))) {
    stop(
      paste0(
        "`x` must be a supported gtstats object, flextable, or gt table."
      ),
      call. = FALSE
    )
  }

  flex_ext <- ext %in% c("docx", "pptx", "rtf", "html", "htm", "png")
  if (inherits(x, "flextable") ||
      (flex_ext && any(inherits(x, valid_gtstats_classes)))) {
    ft <- if (inherits(x, "flextable")) x else to_flextable(
      x,
      show_footnotes = show_footnotes,
      title = title,
      subtitle = subtitle
    )
    if (identical(ext, "docx")) flextable::save_as_docx(ft, path = out_file)
    else if (identical(ext, "pptx")) flextable::save_as_pptx(ft, path = out_file)
    else if (identical(ext, "rtf")) flextable::save_as_rtf(ft, path = out_file)
    else if (ext %in% c("html", "htm")) flextable::save_as_html(ft, path = out_file)
    else if (identical(ext, "png")) flextable::save_as_image(ft, path = out_file, expand = expand)
    else stop("This flextable export format is not supported.", call. = FALSE)
    if (!quiet) message("Table saved to: ", normalizePath(out_file, winslash = "/", mustWork = FALSE))
    return(invisible(out_file))
  }

  # Render remaining formats with gt.
  gt_obj <- if (inherits(x, "gt_tbl")) {
    x
  } else {
    to_gt(
      x,
      title = title,
      subtitle = subtitle,
      bold_labels = bold_labels,
      show_footnotes = show_footnotes
    )
  }

  if (!inherits(gt_obj, "gt_tbl")) {
    stop(
      paste0(
        "`x` must be a gtstats object compatible with ",
        "`to_gt()` or a `gt_tbl`."
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

.save_word_report <- function(
    x,
    filename,
    path = NULL,
    title = NULL,
    subtitle = NULL,
    show_footnotes = TRUE,
    width = 8,
    height = 6,
    page_break = TRUE,
    quiet = FALSE
) {
  if (!length(x)) {
    stop("`x` must contain at least one table or plot.", call. = FALSE)
  }
  if (!is.character(filename) || length(filename) != 1L ||
      is.na(filename) || !nzchar(filename)) {
    stop("`filename` must be a single non-empty character string.", call. = FALSE)
  }
  if (!identical(tolower(tools::file_ext(filename)), "docx")) {
    stop(
      "A list of outputs can currently be combined only in a `.docx` file.",
      call. = FALSE
    )
  }

  save_dir <- path %||% getwd()
  if (!dir.exists(save_dir)) {
    dir.create(save_dir, recursive = TRUE, showWarnings = FALSE)
  }
  out_file <- file.path(save_dir, filename)

  supported <- vapply(
    x,
    function(item) inherits(item, c("gtstats", "flextable", "ggplot")),
    logical(1)
  )
  if (any(!supported)) {
    stop(
      paste0(
        "Every item in `x` must be a gtstats result, flextable, or ggplot. ",
        "Unsupported item(s): ", paste(which(!supported), collapse = ", "), "."
      ),
      call. = FALSE
    )
  }

  item_names <- names(x)
  if (is.null(item_names)) item_names <- rep("", length(x))
  missing_names <- is.na(item_names) | !nzchar(trimws(item_names))
  item_names[missing_names] <- paste("Output", which(missing_names))

  doc <- officer::read_docx()
  if (!is.null(title) && nzchar(title)) {
    doc <- officer::body_add_par(doc, value = title, style = "heading 1")
  }
  if (!is.null(subtitle) && nzchar(subtitle)) {
    doc <- officer::body_add_par(doc, value = subtitle, style = "centered")
  }

  for (i in seq_along(x)) {
    if (i > 1L && isTRUE(page_break)) {
      doc <- officer::body_add_break(doc)
    }
    section_style <- if (is.null(title)) "heading 1" else "heading 2"
    doc <- officer::body_add_par(doc, value = item_names[[i]], style = section_style)
    item <- x[[i]]
    if (inherits(item, "ggplot")) {
      doc <- officer::body_add_gg(doc, value = item, width = width, height = height)
    } else {
      ft <- if (inherits(item, "flextable")) {
        item
      } else {
        to_flextable(item, show_footnotes = show_footnotes)
      }
      doc <- flextable::body_add_flextable(doc, value = ft)
    }
  }

  print(doc, target = out_file)
  if (!quiet) {
    message(
      "Report saved to: ",
      normalizePath(out_file, winslash = "/", mustWork = FALSE)
    )
  }
  invisible(out_file)
}
