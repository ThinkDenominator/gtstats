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
#' - `gt_summary`
#' - `gt_distribution`
#' - `gt_compare`
#' - `gt_correlation`
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
#' tbl_stats(summary_stats(mtcars, by = am))
#'
#' tbl_stats(compare_groups(mtcars, outcome = mpg, group = am))
#'
#' tbl_stats(
#'   descriptive_table(mtcars, by = am, overall = TRUE) |>
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
      gt::opt_row_striping() |>
      gt::tab_options(
        table.font.size = gt::px(13),
        data_row.padding = gt::px(4),
        heading.align = "left"
      )
  }

  # Render dataset overview tables
  if (inherits(x, "gt_describe")) {
    gt_tbl <- gt::gt(x$table)

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title %||% "Dataset overview",
      subtitle = subtitle %||%
        paste0("Data: ", x$inputs$data_name)
    )

    gt_tbl <- .style_common(gt_tbl)

    return(gt_tbl)
  }

  # Render summary statistics tables
  if (inherits(x, "gt_summary")) {
    tbl <- x$table

    if ("Level" %in% names(tbl)) {
      tbl$Level <- ifelse(
        tbl$Level == "u2014",
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
      title = title %||% "Summary statistics",
      subtitle = subtitle %||% {
        if (!is.null(x$inputs$by)) {
          paste0(
            "Data: ",
            x$inputs$data_name,
            " | Grouped by: ",
            x$inputs$by
          )
        } else {
          paste0("Data: ", x$inputs$data_name)
        }
      }
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

    gt_tbl <- .style_common(gt_tbl)

    if (show_footnotes) {
      if (!is.null(x$inputs$by)) {
        group_cols <- setdiff(
          names(tbl),
          c("Variable", "Level", "Type", "Missing")
        )

        if (length(group_cols) > 0) {
          gt_tbl <- gt::tab_footnote(
            gt_tbl,
            footnote = paste0(
              "Continuous summaries are shown as mean (SD); ",
              "median (IQR). Categorical summaries are shown ",
              "as n (%) within each group."
            ),
            locations = gt::cells_column_labels(
              columns = group_cols[1]
            )
          )
        }
      } else if ("Summary" %in% names(tbl)) {
        gt_tbl <- gt::tab_footnote(
          gt_tbl,
          footnote = paste0(
            "Continuous summaries are shown as mean (SD); ",
            "median (IQR). Categorical summaries are shown ",
            "as n (%)."
          ),
          locations = gt::cells_column_labels(
            columns = "Summary"
          )
        )
      }
    }

    return(gt_tbl)
  }

  # Render distribution-check tables
  if (inherits(x, "gt_distribution")) {
    gt_tbl <- gt::gt(x$table)

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title %||% "Distribution check",
      subtitle = subtitle %||% {
        if (!is.null(x$inputs$by)) {
          paste0(
            "Data: ",
            x$inputs$data_name,
            " | Grouped by: ",
            x$inputs$by
          )
        } else {
          paste0("Data: ", x$inputs$data_name)
        }
      }
    )

    gt_tbl <- .style_common(gt_tbl)

    if (show_footnotes && "Distribution" %in% names(x$table)) {
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = paste0(
          "Guidance is based primarily on skewness, with ",
          "Shapiro-Wilk p-values shown when feasible."
        ),
        locations = gt::cells_column_labels(
          columns = "Distribution"
        )
      )
    }

    return(gt_tbl)
  }

  # Render group comparison tables
  if (inherits(x, "gt_compare")) {
    gt_tbl <- gt::gt(x$table)

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title %||% "Group comparison",
      subtitle = subtitle %||% paste0(
        "Data: ", x$inputs$data_name,
        " | Outcome: ", x$inputs$outcome,
        " | Group: ", x$inputs$group
      )
    )

    gt_tbl <- .style_common(gt_tbl)

    if (show_footnotes && "Estimate" %in% names(x$table)) {
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = paste0(
          "For two-group t-tests, the estimate is the mean ",
          "difference based on the displayed group ordering."
        ),
        locations = gt::cells_column_labels(
          columns = "Estimate"
        )
      )
    }

    return(gt_tbl)
  }

  # Render correlation tables
  if (inherits(x, "gt_correlation")) {
    gt_tbl <- gt::gt(x$table)

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title %||% "Correlation analysis",
      subtitle = subtitle %||% paste0(
        "Data: ", x$inputs$data_name,
        " | X: ", x$inputs$x,
        " | Y: ", x$inputs$y
      )
    )

    gt_tbl <- .style_common(gt_tbl)

    if (show_footnotes && "Method" %in% names(x$table)) {
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = paste0(
          "Pearson is used for approximately symmetric ",
          "continuous variables; otherwise Spearman is ",
          "preferred in auto mode."
        ),
        locations = gt::cells_column_labels(
          columns = "Method"
        )
      )
    }

    return(gt_tbl)
  }

  # Render proportion tables
  if (inherits(x, "gt_prop")) {
    gt_tbl <- gt::gt(x$table)

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title %||% "Proportion with confidence interval",
      subtitle = subtitle %||% {
        if (!is.null(x$inputs$by)) {
          paste0(
            "Data: ", x$inputs$data_name,
            " | Variable: ", x$inputs$var,
            " | Level: ", x$inputs$level,
            " | Grouped by: ", x$inputs$by
          )
        } else {
          paste0(
            "Data: ", x$inputs$data_name,
            " | Variable: ", x$inputs$var,
            " | Level: ", x$inputs$level
          )
        }
      }
    )

    gt_tbl <- .style_common(gt_tbl)

    text_cols <- intersect(
      c("Variable", "Group"),
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
      note_col <- if ("Proportion" %in% names(x$table)) {
        "Proportion"
      } else {
        names(x$table)[ncol(x$table)]
      }

      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = x$notes,
        locations = gt::cells_column_labels(columns = note_col)
      )
    }

    return(gt_tbl)
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
      title = title %||% "Descriptive table",
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
      first_data_col <- setdiff(
        names(tbl),
        c("Variable", "Level")
      )[1]

      if (!is.na(first_data_col) &&
          length(first_data_col) == 1) {
        if (length(x$footnotes) > 0) {
          gt_tbl <- gt::tab_footnote(
            gt_tbl,
            footnote = paste(x$footnotes, collapse = " "),
            locations = gt::cells_column_labels(
              columns = first_data_col
            )
          )
        }

        if ("p-value" %in% names(tbl) &&
            length(x$pvalue_method_footnotes) > 0) {
          gt_tbl <- gt::tab_footnote(
            gt_tbl,
            footnote = paste(
              x$pvalue_method_footnotes,
              collapse = "; "
            ),
            locations = gt::cells_column_labels(
              columns = "p-value"
            )
          )
        }
      }
    }

    return(gt_tbl)
  }

  # Render rate tables
  if (inherits(x, "gt_rate")) {
    gt_tbl <- gt::gt(x$table)

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title %||% "Rate with confidence interval",
      subtitle = subtitle %||% {
        if (!is.null(x$inputs$by)) {
          paste0(
            "Data: ", x$inputs$data_name,
            " | Event: ", x$inputs$event,
            " | Person-time: ", x$inputs$time,
            " | Grouped by: ", x$inputs$by
          )
        } else {
          paste0(
            "Data: ", x$inputs$data_name,
            " | Event: ", x$inputs$event,
            " | Person-time: ", x$inputs$time
          )
        }
      }
    )

    gt_tbl <- .style_common(gt_tbl)

    text_cols <- intersect(
      c("Variable", "Group"),
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
      note_col <- if ("Rate" %in% names(x$table)) {
        "Rate"
      } else {
        names(x$table)[ncol(x$table)]
      }

      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = x$notes,
        locations = gt::cells_column_labels(columns = note_col)
      )
    }

    return(gt_tbl)
  }

  # Render 2x2 epidemiology tables
  if (inherits(x, "gt_twobytwo")) {
    gt_tbl <- gt::gt(x$table)

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title %||% "2x2 epidemiology table",
      subtitle = subtitle %||% paste0(
        "Data: ", x$inputs$data_name,
        " | Exposure: ", x$inputs$exposure,
        " (", x$inputs$exposed_level, ")",
        " | Outcome: ", x$inputs$outcome,
        " (", x$inputs$outcome_level, ")"
      )
    )

    gt_tbl <- .style_common(gt_tbl)

    gt_tbl <- gt::cols_align(
      gt_tbl,
      align = "left",
      columns = "Measure"
    )

    gt_tbl <- gt::cols_align(
      gt_tbl,
      align = "right",
      columns = "Value"
    )

    if (show_footnotes && length(x$notes) > 0) {
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = paste(x$notes, collapse = " "),
        locations = gt::cells_column_labels(
          columns = "Value"
        )
      )
    }

    return(gt_tbl)
  }

  stop(
    "`tbl_stats()` does not yet support this object class.",
    call. = FALSE
  )
}
