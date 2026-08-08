#' Convert a gtstats object to flextable
#'
#' Convert a supported `gtstats` object into a `flextable` for use in
#' Word, PowerPoint, and other Office-style outputs.
#'
#' This function is intended for export workflows where a `gtstats`
#' object needs to be inserted into a report or presentation. The input
#' should be the original analytical object, not the rendered `gt` table
#' returned by [tbl_stats()].
#'
#' Text columns are left-aligned and value columns are right-aligned.
#' Notes, footnotes, and p-value method footnotes are appended to the
#' footer when available.
#'
#' @param x A supported `gtstats` object containing a `$table`
#'   component, such as an object returned by [summary_table()],
#'   [summary_table()], [compare_groups()], [proportion_stats()], or related
#'   functions.
#' @param font_size Font size applied to the whole table. Default is
#'   `10`.
#' @param font Optional font family applied to the whole table.
#' @param autofit Logical; whether column widths should be adjusted
#'   automatically using [flextable::autofit()].
#' @param show_footnotes Logical; include concise explanatory footnotes.
#'
#' @return A `flextable` object.
#'
#' @examples
#' res <- summary_table(mtcars, by = am, overall = TRUE) |>
#'   add_summary(vars = c(mpg, wt, cyl)) |>
#'   add_total() |>
#'   add_p()
#'
#' to_flextable(res)
#'
#' @export
to_flextable <- function(
    x,
    font_size = 10,
    font = NULL,
    autofit = TRUE,
    show_footnotes = TRUE
) {
  if (!is.numeric(font_size) || length(font_size) != 1L ||
      is.na(font_size) || font_size <= 0) {
    stop("`font_size` must be a single positive number.", call. = FALSE)
  }
  if (!is.null(font) &&
      (!is.character(font) || length(font) != 1L ||
       is.na(font) || !nzchar(font))) {
    stop("`font` must be NULL or a single non-empty font name.", call. = FALSE)
  }
  .validate_flag(autofit, "autofit")
  .validate_flag(show_footnotes, "show_footnotes")

  # Validate input and require the original gtstats object
  if (inherits(x, "gt_tbl")) {
    stop(
      paste0(
        "Please pass the gtstats object BEFORE `tbl_stats()`, ",
        "not a rendered gt table."
      ),
      call. = FALSE
    )
  }

  if (!is.list(x) || is.null(x$table)) {
    stop(
      "`x` must be a gtstats object containing a `$table`.",
      call. = FALSE
    )
  }

  df <- x$table

  # Build the base flextable
  ft <- flextable::flextable(df)
  if (inherits(x, "gt_desc_table")) {
    header_labels <- .builder_display_headers(x)
    if (length(header_labels) > 0L) {
      ft <- do.call(
        flextable::set_header_labels,
        c(list(x = ft), as.list(header_labels))
      )
    }
  }
  ft <- flextable::theme_booktabs(ft)
  ft <- flextable::fontsize(ft, size = font_size, part = "all")
  if (!is.null(font)) {
    ft <- flextable::font(ft, fontname = font, part = "all")
  }
  ft <- flextable::bold(ft, part = "header")

  # Align label columns left and value columns right
  text_cols <- intersect(
    c("Variable", "Level", "Measure", "Group"),
    names(df)
  )
  value_cols <- setdiff(names(df), text_cols)

  if (length(text_cols) > 0) {
    ft <- flextable::align(
      ft,
      j = text_cols,
      align = "left",
      part = "all"
    )
  }

  if (length(value_cols) > 0) {
    ft <- flextable::align(
      ft,
      j = value_cols,
      align = "right",
      part = "all"
    )
  }

  # Adjust column widths automatically when requested
  if (isTRUE(autofit)) {
    ft <- flextable::autofit(ft)
  }

  # Keep publication output concise. Analyst-facing audit information remains
  # available from the original object through the dedicated audit helpers.
  if (!show_footnotes) {
    notes <- character()
  } else if (inherits(x, "gt_desc_table")) {
    notes <- c(
      .builder_publication_note(x),
      if (length(x$pvalue_method_footnotes) > 0L) {
        paste(x$pvalue_method_footnotes, collapse = "; ")
      } else {
        character()
      }
    )
    notes <- notes[nzchar(notes)]
  } else {
    notes <- character()
    if (!is.null(x$notes)) notes <- c(notes, x$notes)
    if (!is.null(x$footnotes)) notes <- c(notes, x$footnotes)
    if (!is.null(x$pvalue_method_footnotes)) {
      notes <- c(notes, x$pvalue_method_footnotes)
    }
  }

  # Append notes to the table footer
  if (length(notes) > 0) {
    for (note in notes) {
      ft <- flextable::add_footer_lines(ft, values = note)
    }
  }

  ft
}
