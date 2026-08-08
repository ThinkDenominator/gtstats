.builder_publication_note <- function(object) {
  if (identical(object$mode, "rate")) {
    return(paste(unique(object$footnotes), collapse = " "))
  }

  notes <- character()
  helper_notes <- object$footnotes %||% character()

  if ("summary" %in% object$components) {
    summary_vars <- names(object$summary_statistics %||% character())
    summary_types <- if (length(summary_vars) > 0L &&
        !is.null(object$data) && is.data.frame(object$data)) {
      vapply(summary_vars, function(variable) {
        if (variable %in% names(object$data)) {
          .detect_type(object$data[[variable]])
        } else {
          NA_character_
        }
      }, character(1))
    } else {
      character()
    }
    continuous_vars <- summary_vars[summary_types == "continuous"]
    categorical_vars <- summary_vars[
      !is.na(summary_types) & summary_types != "continuous"
    ]
    continuous_formats <- unique(unname(
      (object$summary_statistics %||% character())[continuous_vars]
    ))
    continuous_labels <- if (length(continuous_vars) > 0L) {
      vapply(
        continuous_vars,
        function(variable) .get_var_label(object$data, variable),
        character(1)
      )
    } else {
      character()
    }
    format_label <- function(format) {
      switch(
        format,
        mean_sd = "mean (SD)",
        mean_ci = paste0(
          "mean (", round(100 * (object$conf.level %||% 0.95)), "% CI)"
        ),
        median_iqr = "median (IQR)",
        both = "mean (SD) and median (IQR)",
        recommended = "mean (SD) or median (IQR)",
        "the stated summary"
      )
    }
    continuous_text <- if (length(continuous_vars) == 0L) {
      character()
    } else if (identical(continuous_formats, "mean_sd")) {
      "Continuous data are mean (SD)."
    } else if (identical(continuous_formats, "mean_ci")) {
      paste0(
        "Continuous data are mean (",
        round(100 * (object$conf.level %||% 0.95)), "% CI)."
      )
    } else if (identical(continuous_formats, "median_iqr")) {
      "Continuous data are median (IQR)."
    } else if (identical(continuous_formats, "both")) {
      "Continuous data are mean (SD) and median (IQR)."
    } else if (identical(continuous_formats, "recommended")) {
      "Continuous data are mean (SD) or median (IQR)."
    } else {
      paste0(
        "Continuous data: ",
        paste(
          paste0(
            continuous_labels, ": ",
            vapply(
              unname((object$summary_statistics %||% character())[continuous_vars]),
              format_label,
              character(1)
            )
          ),
          collapse = "; "
        ),
        "."
      )
    }

    percent <- object$method$percentage_denominator %||% "column"
    categorical_display <- object$categorical %||% {
      if (identical(percent, "none")) "n" else "n_percent"
    }
    categorical_text <- if (identical(categorical_display, "n")) {
      "Categorical data are counts."
    } else if (identical(categorical_display, "percent")) {
      "Categorical data are percentages."
    } else {
      "Categorical data are n (%)."
    }
    notes <- c(notes, continuous_text)
    if (length(categorical_vars) > 0L) notes <- c(notes, categorical_text)

    if (length(categorical_vars) > 0L && percent %in% c("row", "overall")) {
      notes <- c(
        notes,
        paste0(
          "Percentages use ",
          if (identical(percent, "row")) "row" else "overall",
          " denominators."
        )
      )
    }

    if (length(categorical_vars) > 0L && isTRUE(object$ci)) {
      notes <- c(
        notes,
        paste0(
          "Categorical proportions include ",
          round(100 * (object$conf.level %||% 0.95)),
          "% exact binomial CIs."
        )
      )
    }
  }

  if ("proportion" %in% object$components) {
    proportion_note <- helper_notes[grepl("^Selected event:", helper_notes)]
    if (length(proportion_note) > 0L) {
      notes <- c(notes, proportion_note)
    }
  }

  paste(unique(notes[nzchar(notes)]), collapse = " ")
}

#' Create formatted gt tables from gtstats objects
#'
#' Render supported `gtstats` objects as formatted `gt` tables.
#'
#' This function is the main rendering bridge between analytical
#' `gtstats` objects and presentation-ready table output. It supports
#' descriptive, inferential, epidemiological, and table-builder
#' objects created by the package and applies a consistent visual
#' style using `gt`.
#'
#' Supported inputs include:
#' - `gt_describe`
#' - `gt_distribution`
#' - `gt_variance`
#' - `gt_compare`
#' - `gt_correlation`
#' - `gt_effect`
#' - `gt_prop`
#' - `gt_rate`
#' - `gt_twobytwo`
#' - `gt_desc_table`
#'
#' @param x A supported `gtstats` object.
#' @param title Optional table title.
#' @param subtitle Optional table subtitle.
#' @param digits Optional digits argument reserved for future use.
#' @param pvalue_style P-value display style. Currently stored but
#'   reserved for future formatting extensions.
#' @param bold_labels Logical; whether to bold variable labels where
#'   appropriate.
#' @param show_footnotes Logical; whether explanatory footnotes should
#'   be displayed.
#'
#' @return A `gt_tbl` object.
#'
#' @examples
#' tbl_stats(describe_data(mtcars))
#'
#' tbl_stats(summary_table(mtcars, by = am, include = c(mpg, wt)))
#'
#' tbl_stats(compare_groups(mtcars, variable = mpg, group = am))
#'
#' tbl_stats(
#'   summary_table(mtcars, by = am, overall = TRUE) |>
#'     add_summary(vars = c(mpg, wt, cyl)) |>
#'     add_total() |>
#'     add_p()
#' )
#'
#' @export
tbl_stats <- function(
    x,
    title = NULL,
    subtitle = NULL,
    digits = NULL,
    pvalue_style = c("default", "scientific"),
    bold_labels = TRUE,
    show_footnotes = TRUE
) {
  pvalue_style <- match.arg(pvalue_style)

  # Apply title and subtitle when supplied
  .apply_header <- function(gt_tbl, title = NULL, subtitle = NULL) {
    if (!is.null(title) || !is.null(subtitle)) {
      gt_tbl <- gt::tab_header(
        gt_tbl,
        title = title %||% "",
        subtitle = subtitle
      )
    }

    gt_tbl
  }

  # Apply a shared minimal house style
  .style_common <- function(gt_tbl) {
    gt_tbl |>
      gt::tab_options(
        table.font.names = "system-ui",
        table.font.size = gt::px(13),
        data_row.padding = gt::px(4),
        heading.background.color = "white",
        table.background.color = "white",
        heading.align = "left"
      ) |>
      gt::tab_style(
        style = gt::cell_text(weight = "bold"),
        locations = gt::cells_column_labels()
      )
  }

  .add_audit_note <- function(gt_tbl, object) {
    # Assumptions, diagnostics, and denominators remain available through
    # assumptions_stats(), diagnostics_stats(), and denominators_stats().
    # They are analyst audit information, not publication-table annotations.
    gt_tbl
  }

  # Render dataset overview tables
  if (inherits(x, "gt_describe")) {
    gt_tbl <- gt::gt(x$table)

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title,
      subtitle = subtitle
    )

    gt_tbl <- .style_common(gt_tbl)

    possible_rows <- which(grepl("\\*$", x$table$Type))
    if (show_footnotes && length(possible_rows) > 0L) {
      gt_tbl <- gt::tab_source_note(
        gt_tbl,
        source_note = paste0(
          "* ",
          "Possible ordinal or count-coded variable. Confirm the intended ",
          "meaning and order using the data dictionary or clinical context."
        )
      )
    }

    return(.add_audit_note(gt_tbl, x))
  }

  # Render distribution-check tables
  if (inherits(x, "gt_distribution")) {
    gt_tbl <- gt::gt(x$table)

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title,
      subtitle = subtitle
    )

    gt_tbl <- .style_common(gt_tbl)

    if (show_footnotes && "Shape" %in% names(x$table)) {
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = x$notes[["shape"]] %||% x$notes[[1L]],
        locations = gt::cells_column_labels(
          columns = "Shape"
        )
      )
    }

    if (show_footnotes && "Shapiro p" %in% names(x$table)) {
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = x$notes[["shapiro"]] %||% x$notes[[3L]],
        locations = gt::cells_column_labels(
          columns = "Shapiro p"
        )
      )
    }

    if (show_footnotes && "Suggested presentation" %in% names(x$table)) {
      presentation_note <- x$notes[["recommendation"]]
      if (!is.null(x$inputs$by)) {
        presentation_note <- paste(
          presentation_note,
          x$notes[["grouped_recommendation"]]
        )
      }
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = presentation_note,
        locations = gt::cells_column_labels(
          columns = "Suggested presentation"
        )
      )
    }

    return(.add_audit_note(gt_tbl, x))
  }

  # Render variance-diagnostic tables
  if (inherits(x, "gt_variance")) {
    gt_tbl <- gt::gt(x$table)
    gt_tbl <- .apply_header(gt_tbl, title = title, subtitle = subtitle)
    gt_tbl <- .style_common(gt_tbl)

    if (show_footnotes && "SD ratio" %in% names(x$table)) {
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = x$notes[["ratios"]],
        locations = gt::cells_column_labels(columns = "SD ratio")
      )
    }
    if (show_footnotes && "Interpretation" %in% names(x$table)) {
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = paste(x$notes[["welch"]], x$notes[["review"]]),
        locations = gt::cells_column_labels(columns = "Interpretation")
      )
    }
    return(.add_audit_note(gt_tbl, x))
  }

  # Render standalone effect-size tables
  if (inherits(x, "gt_effect")) {
    gt_tbl <- gt::gt(x$table)
    gt_tbl <- .apply_header(
      gt_tbl,
      title = title,
      subtitle = subtitle
    )
    gt_tbl <- gt::cols_align(
      gt_tbl,
      align = "left",
      columns = c("Measure", "Contrast")
    )
    numeric_columns <- setdiff(
      names(x$table),
      c("Measure", "Contrast", "Conventional magnitude")
    )
    if (length(numeric_columns) > 0L) {
      gt_tbl <- gt::cols_align(
        gt_tbl,
        align = "right",
        columns = numeric_columns
      )
    }
    gt_tbl <- .style_common(gt_tbl)
    if (isTRUE(show_footnotes) && length(x$notes) > 0L) {
      for (note in x$notes) {
        gt_tbl <- gt::tab_source_note(gt_tbl, source_note = note)
      }
    }
    return(.add_audit_note(gt_tbl, x))
  }

  # Render group comparison tables
  if (inherits(x, "gt_compare")) {
    tbl <- x$table
    if ("Level" %in% names(tbl)) {
      tbl$Level <- ifelse(tbl$Level == "", "", paste0("  ", tbl$Level))
    }
    gt_tbl <- gt::gt(tbl)

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title,
      subtitle = subtitle
    )

    if ("Level" %in% names(tbl)) {
      gt_tbl <- gt::cols_label(gt_tbl, Level = "")
    }
    group_headers <- grep("\nN = ", names(tbl), value = TRUE, fixed = TRUE)
    if (length(group_headers) > 0L) {
      header_labels <- stats::setNames(
        lapply(
          group_headers,
          function(label) gt::md(sub("\n", "  \n", label, fixed = TRUE))
        ),
        group_headers
      )
      gt_tbl <- do.call(
        gt::cols_label,
        c(list(.data = gt_tbl), header_labels)
      )
    }
    gt_tbl <- .style_common(gt_tbl)

    if (show_footnotes && "p-value" %in% names(tbl)) {
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = x$inferential$test_used[[1L]],
        locations = gt::cells_column_labels(
          columns = "p-value"
        )
      )
    }

    estimate_columns <- grep(
      "difference|Odds ratio",
      names(tbl),
      value = TRUE,
      ignore.case = TRUE
    )
    if (show_footnotes && length(estimate_columns) > 0L &&
        grepl("difference", estimate_columns[[1L]], ignore.case = TRUE)) {
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = paste0(
          "Difference is ",
          unique(x$descriptives$group_level)[[1L]],
          " minus ",
          unique(x$descriptives$group_level)[[2L]],
          "."
        ),
        locations = gt::cells_column_labels(
          columns = estimate_columns[[1L]]
        )
      )
    }

    effect_columns <- grep("^Effect size", names(tbl), value = TRUE)
    if (show_footnotes && length(effect_columns) == 1L &&
        !is.na(x$inferential$effect_size_type[[1L]])) {
      effect_note <- x$inferential$effect_size_type[[1L]]
      if (x$inferential$effect_size_type[[1L]] %in% c(
        "Hedges' g",
        "Paired Hedges' g",
        "Rank-biserial correlation",
        "Matched rank-biserial correlation"
      )) {
        effect_note <- paste0(
          effect_note,
          "; direction is ",
          unique(x$descriptives$group_level)[[1L]],
          " minus ",
          unique(x$descriptives$group_level)[[2L]],
          "."
        )
      } else if (identical(
        x$inferential$effect_size_type[[1L]],
        "Cramer's V"
      )) {
        effect_note <- paste0(
          effect_note,
          " measures association strength and has no direction."
        )
      }
      if (!is.na(x$inferential$effect_interval_method[[1L]])) {
        effect_note <- paste0(
          effect_note,
          " CI: ",
          x$inferential$effect_interval_method[[1L]],
          "."
        )
      }
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = effect_note,
        locations = gt::cells_column_labels(
          columns = effect_columns[[1L]]
        )
      )
    }

    return(.add_audit_note(gt_tbl, x))
  }

  # Render correlation tables
  if (inherits(x, "gt_correlation")) {
    gt_tbl <- gt::gt(x$table)

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title,
      subtitle = subtitle
    )

    gt_tbl <- .style_common(gt_tbl)

    correlation_column <- grep(
      "^Correlation",
      names(x$table),
      value = TRUE
    )
    if (show_footnotes && length(correlation_column) == 1L) {
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = x$summary$method_used[[1L]],
        locations = gt::cells_column_labels(
          columns = correlation_column
        )
      )
    }

    return(.add_audit_note(gt_tbl, x))
  }

  # Render proportion tables
  if (inherits(x, "gt_prop")) {
    gt_tbl <- gt::gt(x$table)

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title,
      subtitle = subtitle
    )

    gt_tbl <- .style_common(gt_tbl)

    text_cols <- intersect(
      "Group",
      names(x$table)
    )
    value_cols <- setdiff(names(x$table), text_cols)

    if (length(text_cols) > 0) {
      gt_tbl <- gt::cols_align(
        gt_tbl,
        align = "left",
        columns = text_cols
      )
    }

    if (length(value_cols) > 0) {
      gt_tbl <- gt::cols_align(
        gt_tbl,
        align = "right",
        columns = value_cols
      )
    }

    if (show_footnotes) {
      note_col <- names(x$table)[ncol(x$table)]

      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = x$notes[[1L]],
        locations = gt::cells_column_labels(columns = note_col)
      )
    }

    return(.add_audit_note(gt_tbl, x))
  }

  # Render descriptive table builder output
  if (inherits(x, "gt_desc_table")) {
    if (is.null(x$table)) {
      stop(
        paste0(
          "This descriptive table has no rows yet. Add rows ",
          "before calling `tbl_stats()`."
        ),
        call. = FALSE
      )
    }

    tbl <- x$table

    if ("Level" %in% names(tbl)) {
      tbl$Level <- ifelse(
        tbl$Level %in% c("", "u2014"),
        "",
        paste0("  ", tbl$Level)
      )
    }

    if ("Variable" %in% names(tbl) &&
        "Level" %in% names(tbl)) {
      keep_var <- !duplicated(tbl$Variable)
      tbl$Variable <- ifelse(keep_var, tbl$Variable, "")
    }

    gt_tbl <- gt::gt(tbl)

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title,
      subtitle = subtitle
    )

    if (bold_labels && "Variable" %in% names(tbl)) {
      non_empty_rows <- which(tbl$Variable != "")

      if (length(non_empty_rows) > 0) {
        gt_tbl <- gt::tab_style(
          gt_tbl,
          style = gt::cell_text(weight = "bold"),
          locations = gt::cells_body(
            columns = "Variable",
            rows = non_empty_rows
          )
        )
      }
    }

    if ("Level" %in% names(tbl)) {
      gt_tbl <- gt::cols_label(gt_tbl, Level = "")
    }

    header_labels <- .builder_display_headers(x)
    if (length(header_labels) > 0L) {
      gt_labels <- lapply(
        header_labels,
        function(label) gt::md(sub("\n", "  \n", label, fixed = TRUE))
      )
      gt_tbl <- do.call(
        gt::cols_label,
        c(list(.data = gt_tbl), gt_labels)
      )
    }

    gt_tbl <- .style_common(gt_tbl)

    text_cols <- intersect(c("Variable", "Level"), names(tbl))
    value_cols <- setdiff(names(tbl), text_cols)

    if (length(text_cols) > 0) {
      gt_tbl <- gt::cols_align(
        gt_tbl,
        align = "left",
        columns = text_cols
      )
    }

    if (length(value_cols) > 0) {
      gt_tbl <- gt::cols_align(
        gt_tbl,
        align = "right",
        columns = value_cols
      )
    }

    if (show_footnotes) {
      data_cols <- setdiff(
        names(tbl),
        c("Variable", "Level", "p-value")
      )

      if (length(data_cols) > 0L) {
        publication_note <- .builder_publication_note(x)
        if (nzchar(publication_note)) {
          gt_tbl <- gt::tab_footnote(
            gt_tbl,
            footnote = publication_note,
            locations = gt::cells_column_labels(
              columns = data_cols
            )
          )
        }

      }

      if ("p-value" %in% names(tbl) &&
          length(x$pvalue_method_footnotes) > 0) {
        gt_tbl <- gt::tab_footnote(
          gt_tbl,
          footnote = paste(x$pvalue_method_footnotes, collapse = "; "),
          locations = gt::cells_column_labels(
            columns = "p-value"
          )
        )
      }
    }

    return(.add_audit_note(gt_tbl, x))
  }

  # Render rate tables
  if (inherits(x, "gt_rate")) {
    gt_tbl <- gt::gt(x$table)

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title,
      subtitle = subtitle
    )

    gt_tbl <- .style_common(gt_tbl)

    text_cols <- intersect(
      "Group",
      names(x$table)
    )
    value_cols <- setdiff(names(x$table), text_cols)

    if (length(text_cols) > 0) {
      gt_tbl <- gt::cols_align(
        gt_tbl,
        align = "left",
        columns = text_cols
      )
    }

    if (length(value_cols) > 0) {
      gt_tbl <- gt::cols_align(
        gt_tbl,
        align = "right",
        columns = value_cols
      )
    }

    if (show_footnotes) {
      note_col <- names(x$table)[ncol(x$table)]

      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = x$notes[[1L]],
        locations = gt::cells_column_labels(columns = note_col)
      )
    }

    return(.add_audit_note(gt_tbl, x))
  }

  # Render 2x2 epidemiology tables
  if (inherits(x, "gt_twobytwo")) {
    gt_tbl <- gt::gt(x$table)

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title,
      subtitle = subtitle
    )

    gt_tbl <- .style_common(gt_tbl)

    if (identical(x$method$table_type, "crosstab")) {
      row_column <- names(x$table)[[1L]]
      gt_tbl <- gt::cols_align(gt_tbl, align = "left", columns = row_column)
      gt_tbl <- gt::cols_align(gt_tbl, align = "right", columns = setdiff(names(x$table), row_column))
      value_columns <- setdiff(names(x$table), row_column)
      if (length(value_columns) > 0L) {
        gt_tbl <- gt::fmt_markdown(gt_tbl, columns = value_columns)
      }
      if (show_footnotes) {
        for (note in x$notes) gt_tbl <- gt::tab_source_note(gt_tbl, source_note = note)
      }
      return(.add_audit_note(gt_tbl, x))
    }

    gt_tbl <- gt::cols_align(gt_tbl, align = "left", columns = "Measure")

    gt_tbl <- gt::cols_align(
      gt_tbl,
      align = "right",
      columns = setdiff(names(x$table), "Measure")
    )

    if (show_footnotes && length(x$notes) > 0) {
      exposed_column <- grep("^Exposed:", names(x$table), value = TRUE)
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = x$notes[[1L]],
        locations = gt::cells_column_labels(
          columns = exposed_column[[1L]]
        )
      )
      if ("p-value" %in% names(x$table)) {
        test_note <- x$notes[grepl("^P-value", x$notes)]
        if (length(test_note) > 0L) {
          gt_tbl <- gt::tab_footnote(
            gt_tbl,
            footnote = test_note[[1L]],
            locations = gt::cells_column_labels(columns = "p-value")
          )
        }
      }
      correction_note <- x$notes[grepl("^Zero cell", x$notes)]
      if (length(correction_note) > 0L) {
        effect_column <- grep("^Effect", names(x$table), value = TRUE)
        gt_tbl <- gt::tab_footnote(
          gt_tbl,
          footnote = correction_note[[1L]],
          locations = gt::cells_column_labels(
            columns = effect_column[[1L]]
          )
        )
      }
    }

    return(.add_audit_note(gt_tbl, x))
  }

  stop(
    "`tbl_stats()` does not yet support this object class.",
    call. = FALSE
  )
}
