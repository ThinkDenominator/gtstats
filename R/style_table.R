#' Style a GTstats table
#'
#' Apply visual styling to a `gt` table produced by [tbl_stats()].
#'
#' This function modifies the appearance of a rendered `gtstats` table
#' without changing the underlying statistical results. It can be used
#' to:
#' - apply a theme
#' - add titles and source notes
#' - relabel columns, rows, and levels
#' - align, hide, bold, or italicise selected columns
#' - apply row striping and accent colours
#' - adjust overall font size
#'
#' The input must already be a `gt_tbl`, so styling is applied after
#' calling [tbl_stats()].
#'
#' @param x A `gt_tbl` object, typically created with [tbl_stats()].
#' @param theme Table theme. One of `"default"`, `"journal"`,
#'   `"classic"`, `"minimal"`, or `"compact"`.
#' @param title Optional table title.
#' @param subtitle Optional table subtitle.
#' @param source_note Optional source note shown below the table.
#' @param col_labels Optional named vector used to rename columns.
#' @param row_labels Optional named vector used to replace values in
#'   the `"Variable"` or `"Measure"` column.
#' @param level_labels Optional named vector used to replace values in
#'   the `"Level"` column.
#' @param align Optional named list controlling column alignment, for
#'   example `list(left = cols, right = cols, center = cols)`.
#' @param hide_cols Optional columns to hide.
#' @param bold_cols Optional columns to display in bold.
#' @param italic_cols Optional columns to display in italics.
#' @param font_size Optional table font size in pixels.
#' @param row_striping Logical; whether to apply row striping.
#' @param accent_color Optional accent colour used for borders.
#' @param stripe_color Optional background colour for striped rows.
#'
#' @return A styled `gt_tbl` object.
#'
#' @examples
#' tbl_stats(
#'   descriptive_table(mtcars, by = am) |>
#'     add_summary(vars = c(mpg, wt)) |>
#'     add_p()
#' ) |>
#'   style_table(theme = "journal")
#'
#' tbl_stats(
#'   descriptive_table(mtcars, by = am, overall = TRUE) |>
#'     add_summary(vars = c(mpg, wt, cyl)) |>
#'     add_total()
#' ) |>
#'   style_table(
#'     theme = "minimal",
#'     col_labels = c("am = 1" = "Manual", "am = 0" = "Automatic"),
#'     accent_color = "#123B7A"
#'   )
#'
#' @export
style_table <- function(
    x,
    theme = c("default", "journal", "classic", "minimal",
              "compact"),
    title = NULL,
    subtitle = NULL,
    source_note = NULL,
    col_labels = NULL,
    row_labels = NULL,
    level_labels = NULL,
    align = NULL,
    hide_cols = NULL,
    bold_cols = NULL,
    italic_cols = NULL,
    font_size = NULL,
    row_striping = NULL,
    accent_color = NULL,
    stripe_color = NULL
) {
  theme <- match.arg(theme)

  # Validate that the input is already a rendered gt table
  if (!inherits(x, "gt_tbl")) {
    stop(
      "`x` must be a gt table. Use `tbl_stats()` first.",
      call. = FALSE
    )
  }

  gt_tbl <- x

  # Update displayed values in the underlying table data
  df <- gt_tbl[["_data"]]

  if (!is.null(row_labels)) {
    target_col <- intersect(c("Variable", "Measure"), names(df))

    if (length(target_col) > 0) {
      col <- target_col[1]
      df[[col]] <- dplyr::recode(
        as.character(df[[col]]),
        !!!row_labels
      )
    }
  }

  if (!is.null(level_labels) && "Level" %in% names(df)) {
    df$Level <- dplyr::recode(
      as.character(df$Level),
      !!!level_labels
    )
  }

  gt_tbl[["_data"]] <- df

  # Apply header text
  if (!is.null(title) || !is.null(subtitle)) {
    gt_tbl <- gt::tab_header(
      gt_tbl,
      title = title %||% "",
      subtitle = subtitle
    )
  }

  # Add source note when supplied
  if (!is.null(source_note)) {
    gt_tbl <- gt::tab_source_note(gt_tbl, source_note)
  }

  # Rename columns when requested
  if (!is.null(col_labels)) {
    gt_tbl <- gt::cols_label(gt_tbl, .list = col_labels)
  }

  # Hide selected columns
  if (!is.null(hide_cols)) {
    gt_tbl <- gt::cols_hide(gt_tbl, columns = hide_cols)
  }

  # Apply alignment settings
  if (!is.null(align)) {
    if (!is.null(align$left)) {
      gt_tbl <- gt::cols_align(
        gt_tbl,
        align = "left",
        columns = align$left
      )
    }

    if (!is.null(align$right)) {
      gt_tbl <- gt::cols_align(
        gt_tbl,
        align = "right",
        columns = align$right
      )
    }

    if (!is.null(align$center)) {
      gt_tbl <- gt::cols_align(
        gt_tbl,
        align = "center",
        columns = align$center
      )
    }
  }

  # Bold selected columns
  if (!is.null(bold_cols)) {
    gt_tbl <- gt::tab_style(
      gt_tbl,
      style = gt::cell_text(weight = "bold"),
      locations = gt::cells_body(columns = bold_cols)
    )
  }

  # Italicise selected columns
  if (!is.null(italic_cols)) {
    gt_tbl <- gt::tab_style(
      gt_tbl,
      style = gt::cell_text(style = "italic"),
      locations = gt::cells_body(columns = italic_cols)
    )
  }

  # Apply theme-specific defaults
  if (theme == "journal") {
    gt_tbl <- gt_tbl |>
      gt::tab_options(
        table.border.top.width = gt::px(2),
        table.border.bottom.width = gt::px(2),
        column_labels.border.top.width = gt::px(2),
        column_labels.border.bottom.width = gt::px(1),
        table.font.size = gt::px(13),
        data_row.padding = gt::px(4)
      )
  }

  if (theme == "classic") {
    gt_tbl <- gt_tbl |>
      gt::tab_options(
        table.border.top.width = gt::px(1),
        table.border.bottom.width = gt::px(1),
        column_labels.border.bottom.width = gt::px(1),
        table.font.size = gt::px(13)
      )
  }

  if (theme == "minimal") {
    gt_tbl <- gt_tbl |>
      gt::tab_options(
        table.border.top.width = gt::px(0),
        table.border.bottom.width = gt::px(0),
        column_labels.border.top.width = gt::px(0),
        column_labels.border.bottom.width = gt::px(0),
        table.font.size = gt::px(13)
      )
  }

  if (theme == "compact") {
    gt_tbl <- gt_tbl |>
      gt::tab_options(
        table.font.size = gt::px(11),
        data_row.padding = gt::px(2)
      )
  }

  # "default" intentionally applies no extra styling
  if (theme == "default") {
    gt_tbl <- gt_tbl
  }

  # Apply or disable row striping
  if (isTRUE(row_striping)) {
    gt_tbl <- gt::opt_row_striping(gt_tbl)
  }

  if (identical(row_striping, FALSE)) {
    gt_tbl <- gt::tab_options(
      gt_tbl,
      row.striping.include_table_body = FALSE
    )
  }

  # Apply accent colours to table borders
  if (!is.null(accent_color)) {
    gt_tbl <- gt::tab_options(
      gt_tbl,
      table.border.top.color = accent_color,
      table.border.bottom.color = accent_color,
      column_labels.border.top.color = accent_color,
      column_labels.border.bottom.color = accent_color
    )
  }

  # Apply custom stripe background colour
  if (!is.null(stripe_color)) {
    gt_tbl <- gt::tab_options(
      gt_tbl,
      row.striping.background_color = stripe_color
    )
  }

  # Override font size if requested
  if (!is.null(font_size)) {
    gt_tbl <- gt::tab_options(
      gt_tbl,
      table.font.size = gt::px(font_size)
    )
  }

  gt_tbl
}
