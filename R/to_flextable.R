#' Convert a gtstats object to flextable
#'
#' Convert a supported `gtstats` object into a `flextable` for use in
#' Word, PowerPoint, and other Office-style outputs.
#'
#' This function is intended for export workflows where a `gtstats`
#' object needs to be inserted into a report or presentation. The input
#' should be the original analytical object, not the rendered `gt` table
#' returned by [to_gt()].
#'
#' Text columns are left-aligned and value columns are right-aligned.
#' Notes, footnotes, and p-value method footnotes are appended to the
#' footer when available.
#'
#' @param x A supported `gtstats` object containing a `$table`
#'   component, such as an object returned by [summary_table()],
#'   [compare_groups()], [proportion_stats()], [as_stats_table()], or related
#'   functions.
#' @param font_size Font size applied to the whole table. Default is
#'   `10`.
#' @param font Optional font family applied to the whole table.
#' @param autofit Logical; whether column widths should be adjusted
#'   automatically using [flextable::autofit()].
#' @param show_footnotes Logical; include concise explanatory footnotes.
#' @param title,subtitle Optional title and subtitle placed above the table.
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
    show_footnotes = TRUE,
    title = NULL,
    subtitle = NULL
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
        "Please pass the gtstats object BEFORE `to_gt()`, ",
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
  characteristic_display <- NULL
  if (inherits(x, "gtstats_summary")) {
    characteristic_display <- .builder_characteristic_display(df)
    df <- characteristic_display$data
  }

  # Analytical tables use <br> as an engine-neutral marker for stacked cell
  # content. Flextable treats strings as text, so translate the marker to a
  # real line break before rendering rather than exposing literal HTML.
  character_columns <- names(df)[vapply(df, is.character, logical(1))]
  for (column in character_columns) {
    df[[column]] <- gsub("<br>", "\n", df[[column]], fixed = TRUE)
  }

  # Build the base flextable
  ft <- flextable::flextable(df)
  if (inherits(x, "gt_epi_table") && identical(x$inputs$layout, "wide")) {
    groups <- attr(x$table, "epi_groups", exact = TRUE)
    if (length(groups)) {
      values <- ""
      widths <- 1L
      labels <- list(Outcome = "Outcome")
      for (group in groups) {
        key <- make.names(group)
        columns <- paste0(key, c("__Cases", "__Denominator", "__Estimate", "__CI"))
        labels[[columns[[1L]]]] <- "Cases"
        labels[[columns[[2L]]]] <- if (identical(x$inputs$measure, "incidence_rate")) "Person-time" else "Denominator"
        labels[[columns[[3L]]]] <- .epi_measure_label(x$inputs$measure, x$inputs$multiplier)
        labels[[columns[[4L]]]] <- .conf_level_label(x$inputs$conf.level)
        values <- c(values, group)
        widths <- c(widths, 4L)
      }
      grouped_columns <- unlist(lapply(groups, function(group) paste0(make.names(group), c("__Cases", "__Denominator", "__Estimate", "__CI"))), use.names = FALSE)
      trailing <- setdiff(names(df), c("Outcome", grouped_columns))
      if (length(trailing)) {
        values <- c(values, rep("", length(trailing)))
        widths <- c(widths, rep(1L, length(trailing)))
        for (column in trailing) labels[[column]] <- column
      }
      ft <- do.call(flextable::set_header_labels, c(list(x = ft), labels))
      ft <- flextable::add_header_row(ft, values = values, colwidths = widths, top = TRUE)
    }
  }
  if (inherits(x, "gt_prop") && !is.null(x$inputs$by) &&
      is.data.frame(x$method$display_columns)) {
    display_columns <- x$method$display_columns
    child_labels <- c(Event = "Event")
    for (i in seq_len(nrow(display_columns))) {
      child_labels[[display_columns$estimate[[i]]]] <- display_columns$estimate_label[[i]]
      child_labels[[display_columns$ci[[i]]]] <- .conf_level_label(x$inputs$conf.level)
    }
    ft <- do.call(
      flextable::set_header_labels,
      c(list(x = ft), as.list(child_labels))
    )
    ft <- flextable::add_header_row(
      ft,
      values = c("", display_columns$group),
      colwidths = c(1L, rep(2L, nrow(display_columns))),
      top = TRUE
    )
  }
  if (inherits(x, "gt_rate") && !is.null(x$inputs$by) &&
      is.data.frame(x$method$display_columns)) {
    display_columns <- x$method$display_columns
    child_labels <- c(Event = "Event")
    for (i in seq_len(nrow(display_columns))) {
      child_labels[[display_columns$events[[i]]]] <- "Events"
      child_labels[[display_columns$time[[i]]]] <- .sentence_case(x$inputs$time_label)
      child_labels[[display_columns$rate[[i]]]] <- paste0(
        "Rate per ",
        format(x$inputs$multiplier, scientific = FALSE, trim = TRUE, big.mark = ",")
      )
      child_labels[[display_columns$ci[[i]]]] <- .conf_level_label(x$inputs$conf.level)
    }
    ft <- do.call(
      flextable::set_header_labels,
      c(list(x = ft), as.list(child_labels))
    )
    ft <- flextable::add_header_row(
      ft,
      values = c("", display_columns$group),
      colwidths = c(1L, rep(4L, nrow(display_columns))),
      top = TRUE
    )
  }
  if (inherits(x, "gtstats_summary")) {
    if (identical(x$layout %||% "compact", "separate") &&
        is.data.frame(x$display_columns)) {
      child_labels <- c(Characteristic = "Characteristic")
      for (i in seq_len(nrow(x$display_columns))) {
        child_labels[[x$display_columns$estimate[[i]]]] <-
          x$display_columns$estimate_label[[i]]
        if (!is.na(x$display_columns$ci[[i]]) &&
            nzchar(x$display_columns$ci[[i]])) {
          child_labels[[x$display_columns$ci[[i]]]] <-
            x$display_columns$ci_label[[i]]
        }
      }
      display_value_columns <- unlist(lapply(seq_len(nrow(x$display_columns)), function(i) {
        columns <- x$display_columns$estimate[[i]]
        if (!is.na(x$display_columns$ci[[i]]) &&
            nzchar(x$display_columns$ci[[i]])) {
          columns <- c(columns, x$display_columns$ci[[i]])
        }
        columns
      }), use.names = FALSE)
      display_widths <- vapply(seq_len(nrow(x$display_columns)), function(i) {
        1L + as.integer(!is.na(x$display_columns$ci[[i]]) &&
          nzchar(x$display_columns$ci[[i]]))
      }, integer(1))
      trailing <- setdiff(names(df), c(
        "Characteristic",
        display_value_columns
      ))
      for (column in trailing) child_labels[[column]] <- column
      ft <- do.call(
        flextable::set_header_labels,
        c(list(x = ft), as.list(child_labels))
      )
      ft <- flextable::add_header_row(
        ft,
        values = c(
          "",
          x$display_columns$group,
          rep("", length(trailing))
        ),
        colwidths = c(
          1L,
          display_widths,
          rep(1L, length(trailing))
        ),
        top = TRUE
      )
    } else {
      header_labels <- c(
        Characteristic = "Characteristic",
        .builder_display_headers(x)
      )
      header_labels <- header_labels[names(header_labels) %in% names(df)]
      if (length(header_labels) > 0L) {
        ft <- do.call(
          flextable::set_header_labels,
          c(list(x = ft), as.list(header_labels))
        )
      }
    }
  }
  ft <- flextable::theme_booktabs(ft)
  body_padding <- .publication_auto_padding(nrow(df))
  ft <- flextable::padding(ft, padding = body_padding, part = "body")
  ft <- flextable::padding(ft, padding = 3, part = "header")
  ft <- flextable::fontsize(ft, size = font_size, part = "all")
  if (!is.null(font)) {
    ft <- flextable::font(ft, fontname = font, part = "all")
  }
  ft <- flextable::bold(ft, part = "header")

  if (inherits(x, "gtstats_summary") && "Characteristic" %in% names(df)) {
    label_rows <- characteristic_display$parent_rows
    if (length(label_rows) > 0L) {
      ft <- flextable::bold(
        ft,
        i = label_rows,
        j = "Characteristic",
        bold = TRUE,
        part = "body"
      )
    }
    if (length(characteristic_display$level_rows) > 0L) {
      ft <- flextable::padding(
        ft,
        i = characteristic_display$level_rows,
        j = "Characteristic",
        padding.left = 14,
        part = "body"
      )
    }
  }

  # Align label columns left and value columns right
  text_cols <- intersect(
    c("Characteristic", "Variable", "Level", "Measure", "Group", "Event"),
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
  } else if (inherits(x, "gtstats_summary")) {
    adjustment_note <- if (!identical(x$method$p_adjust %||% "none", "none")) {
      paste0(
        "P-values use the ", x$method$p_adjust,
        " multiplicity adjustment."
      )
    } else {
      character()
    }
    notes <- c(
      .builder_publication_note(x),
      if (length(x$pvalue_method_footnotes) > 0L) {
        paste(x$pvalue_method_footnotes, collapse = "; ")
      } else {
        character()
      },
      x$paired_p_notes %||% character(),
      adjustment_note
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
    ft <- flextable::padding(ft, padding = 2, part = "footer")
    ft <- flextable::fontsize(ft, size = min(8, font_size), part = "footer")
  }

  header_lines <- c(subtitle, title)
  header_lines <- header_lines[!is.na(header_lines) & nzchar(header_lines)]
  for (line in header_lines) {
    ft <- flextable::add_header_lines(ft, values = line, top = TRUE)
  }

  ft
}
