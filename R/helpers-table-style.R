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
#'   summary_table(mtcars, by = am) |>
#'     add_summary(vars = c(mpg, wt)) |>
#'     add_p()
#' ) |>
#'   .style_table(theme = "journal")
#'
#' tbl_stats(
#'   summary_table(mtcars, by = am, overall = TRUE) |>
#'     add_summary(vars = c(mpg, wt, cyl)) |>
#'     add_total()
#' ) |>
#'   .style_table(
#'     theme = "minimal",
#'     col_labels = c("am = 1" = "Manual", "am = 0" = "Automatic"),
#'     accent_color = "#123B7A"
#'   )
#'
#' @keywords internal
#' @noRd
.style_table <- function(
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
    font = NULL,
    width = NULL,
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

  # Summary tables now expose one publication-facing Characteristic column.
  # Preserve customisation calls written against the analytical Variable/Level
  # columns by mapping them to the rendered column and discarding the hidden
  # Level selector.
  map_rendered_cols <- function(cols) {
    if (is.null(cols)) return(NULL)
    cols <- as.character(cols)
    if ("Characteristic" %in% names(df)) {
      cols[cols == "Variable"] <- "Characteristic"
      cols <- cols[cols != "Level"]
    }
    unique(intersect(cols, names(df)))
  }

  if (!is.null(row_labels)) {
    target_col <- intersect(c("Characteristic", "Variable", "Measure"), names(df))

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
  if (!is.null(level_labels) && "Characteristic" %in% names(df)) {
    df$Characteristic <- dplyr::recode(
      as.character(df$Characteristic), !!!level_labels
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
    if ("Characteristic" %in% names(df)) {
      if ("Variable" %in% names(col_labels) &&
          !"Characteristic" %in% names(col_labels)) {
        col_labels[["Characteristic"]] <- col_labels[["Variable"]]
      }
      col_labels <- col_labels[setdiff(names(col_labels), c("Variable", "Level"))]
    }
    col_labels <- col_labels[intersect(names(col_labels), names(df))]
    if (length(col_labels) > 0L) {
      gt_tbl <- gt::cols_label(gt_tbl, .list = col_labels)
    }
  }

  # Hide selected columns
  if (!is.null(hide_cols)) {
    hide_cols <- map_rendered_cols(hide_cols)
    if (length(hide_cols) > 0L) {
      gt_tbl <- gt::cols_hide(gt_tbl, columns = hide_cols)
    }
  }

  # Apply alignment settings
  if (!is.null(align)) {
    if (!is.null(align$left)) {
      align$left <- map_rendered_cols(align$left)
      if (length(align$left) > 0L) {
        gt_tbl <- gt::cols_align(
          gt_tbl, align = "left", columns = align$left
        )
      }
    }

    if (!is.null(align$right)) {
      align$right <- map_rendered_cols(align$right)
      if (length(align$right) > 0L) {
        gt_tbl <- gt::cols_align(
          gt_tbl, align = "right", columns = align$right
        )
      }
    }

    if (!is.null(align$center)) {
      align$center <- map_rendered_cols(align$center)
      if (length(align$center) > 0L) {
        gt_tbl <- gt::cols_align(
          gt_tbl, align = "center", columns = align$center
        )
      }
    }
  }

  # Bold selected columns
  if (!is.null(bold_cols)) {
    bold_cols <- map_rendered_cols(bold_cols)
    if (length(bold_cols) > 0L) {
      gt_tbl <- gt::tab_style(
        gt_tbl,
        style = gt::cell_text(weight = "bold"),
        locations = gt::cells_body(columns = bold_cols)
      )
    }
  }

  # Italicise selected columns
  if (!is.null(italic_cols)) {
    italic_cols <- map_rendered_cols(italic_cols)
    if (length(italic_cols) > 0L) {
      gt_tbl <- gt::tab_style(
        gt_tbl,
        style = gt::cell_text(style = "italic"),
        locations = gt::cells_body(columns = italic_cols)
      )
    }
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
    if (!is.numeric(font_size) || length(font_size) != 1L ||
        is.na(font_size) || font_size <= 0) {
      stop("`font_size` must be a single positive number.", call. = FALSE)
    }
    gt_tbl <- gt::tab_options(
      gt_tbl,
      table.font.size = gt::px(font_size)
    )
  }

  if (!is.null(font)) {
    if (!is.character(font) || length(font) != 1L ||
        is.na(font) || !nzchar(font)) {
      stop("`font` must be a single non-empty font name.", call. = FALSE)
    }
    gt_tbl <- gt::opt_table_font(gt_tbl, font = font)
  }

  if (!is.null(width)) {
    if (!is.numeric(width) || length(width) != 1L ||
        is.na(width) || width <= 0 || width > 100) {
      stop(
        "`width` must be a percentage between 0 and 100.",
        call. = FALSE
      )
    }
    gt_tbl <- gt::tab_options(
      gt_tbl,
      table.width = gt::pct(width)
    )
  }

  gt_tbl
}

.style_flextable <- function(
    x,
    theme = "default",
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
    font = NULL,
    row_striping = NULL,
    accent_color = NULL,
    stripe_color = NULL,
    spanning_header = NULL,
    footnotes = NULL,
    borders = "horizontal",
    density = "standard",
    column_widths = NULL
) {
  ft <- x
  keys <- ft$col_keys
  map_flex_cols <- function(cols) {
    if (is.null(cols)) return(NULL)
    cols <- as.character(cols)
    if ("Characteristic" %in% keys) {
      cols[cols == "Variable"] <- "Characteristic"
      cols <- cols[cols != "Level"]
    }
    unique(intersect(cols, keys))
  }

  if (!is.null(col_labels)) {
    labels <- as.list(col_labels[intersect(names(col_labels), keys)])
    if (length(labels) > 0L) {
      ft <- do.call(flextable::set_header_labels, c(list(x = ft), labels))
    }
  }
  if (!is.null(row_labels)) {
    target <- intersect(c("Characteristic", "Variable", "Measure"), keys)
    if (length(target) > 0L) {
      ft$body$dataset[[target[[1L]]]] <- dplyr::recode(
        as.character(ft$body$dataset[[target[[1L]]]]), !!!row_labels
      )
    }
  }
  if (!is.null(level_labels) && "Level" %in% keys) {
    ft$body$dataset$Level <- dplyr::recode(
      as.character(ft$body$dataset$Level), !!!level_labels
    )
  }
  if (!is.null(level_labels) && "Characteristic" %in% keys) {
    ft$body$dataset$Characteristic <- dplyr::recode(
      as.character(ft$body$dataset$Characteristic), !!!level_labels
    )
  }
  if (!is.null(hide_cols)) {
    hide_cols <- map_flex_cols(hide_cols)
    if (length(hide_cols) > 0L) {
      ft <- flextable::delete_columns(ft, j = hide_cols)
      keys <- ft$col_keys
    }
  }
  if (!is.null(align)) {
    for (where in intersect(names(align), c("left", "right", "center"))) {
      cols <- map_flex_cols(align[[where]])
      if (length(cols) > 0L) ft <- flextable::align(ft, j = cols, align = where, part = "all")
    }
  }
  if (!is.null(bold_cols)) {
    cols <- map_flex_cols(bold_cols)
    if (length(cols) > 0L) ft <- flextable::bold(ft, j = cols, part = "body")
  }
  if (!is.null(italic_cols)) {
    cols <- map_flex_cols(italic_cols)
    if (length(cols) > 0L) ft <- flextable::italic(ft, j = cols, part = "body")
  }

  ft <- switch(
    theme,
    journal = flextable::theme_booktabs(ft),
    classic = flextable::theme_vanilla(ft),
    minimal = flextable::theme_borderless(ft),
    compact = flextable::theme_booktabs(ft),
    flextable::theme_booktabs(ft)
  )
  border <- flextable::fp_border_default(
    color = accent_color %||% "#A6A6A6",
    width = if (identical(borders, "minimal")) 0 else 0.75
  )
  if (identical(borders, "minimal")) {
    ft <- flextable::border_remove(ft)
  } else if (identical(borders, "all")) {
    ft <- flextable::border_outer(ft, border = border, part = "all")
    ft <- flextable::border_inner(ft, border = border, part = "all")
  } else {
    ft <- flextable::border_remove(ft)
    ft <- flextable::border_outer(ft, border = border, part = "all")
    ft <- flextable::border_inner_h(ft, border = border, part = "body")
  }

  pad <- switch(density, compact = 1, spacious = 6, 3)
  ft <- flextable::padding(ft, padding = pad, part = "all")
  if (identical(theme, "compact") && is.null(font_size)) font_size <- 9
  if (!is.null(font_size)) ft <- flextable::fontsize(ft, size = font_size, part = "all")
  if (!is.null(font)) ft <- flextable::font(ft, fontname = font, part = "all")

  if (isTRUE(row_striping)) {
    colour <- stripe_color %||% "#F4F4F4"
    rows <- seq.int(2L, nrow(ft$body$dataset), by = 2L)
    if (length(rows) > 0L) ft <- flextable::bg(ft, i = rows, bg = colour, part = "body")
  }
  if (!is.null(column_widths)) {
    if (is.null(names(column_widths)) || !is.numeric(column_widths)) {
      stop("`column_widths` must be a named numeric vector.", call. = FALSE)
    }
    width_names <- names(column_widths)
    if ("Characteristic" %in% keys) {
      width_names[width_names == "Variable"] <- "Characteristic"
    }
    names(column_widths) <- width_names
    for (column in intersect(names(column_widths), keys)) {
      ft <- flextable::width(ft, j = column, width = column_widths[[column]])
    }
  }
  if (!is.null(spanning_header)) {
    label_cols <- intersect(c("Variable", "Level", "Measure", "Group", "Event"), keys)
    value_cols <- setdiff(keys, label_cols)
    spans <- .normalise_spanning_header(spanning_header, value_cols)
    if (length(spans) > 0L) {
      column_labels <- stats::setNames(rep("", length(keys)), keys)
      for (label in names(spans)) column_labels[spans[[label]]] <- label
      runs <- rle(unname(column_labels))
      values <- runs$values
      widths <- runs$lengths
      ft <- flextable::add_header_row(ft, values = values, colwidths = widths, top = TRUE)
    }
  }
  header_lines <- c(subtitle, title)
  header_lines <- header_lines[!is.na(header_lines) & nzchar(header_lines)]
  for (line in header_lines) ft <- flextable::add_header_lines(ft, values = line, top = TRUE)
  notes <- c(source_note, footnotes)
  notes <- notes[!is.na(notes) & nzchar(notes)]
  for (note in notes) ft <- flextable::add_footer_lines(ft, values = note)
  if (length(notes) > 0L) {
    ft <- flextable::fontsize(
      ft,
      size = min(8, font_size %||% 10),
      part = "footer"
    )
  }
  ft
}
