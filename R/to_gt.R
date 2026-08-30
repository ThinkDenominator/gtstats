.builder_publication_note <- function(object) {
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
        mean_se = "mean (SE)",
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
    } else if (identical(continuous_formats, "mean_se")) {
      paste0(
        "Continuous data are mean (SE). SE is the standard error of the ",
        "estimated mean, not the variability of individual observations."
      )
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
    categorical_text <- if (identical(object$categorical_layout, "separate")) {
      "Categorical data are n and %."
    } else if (identical(categorical_display, "n")) {
      "Categorical data are counts."
    } else if (identical(categorical_display, "percent")) {
      "Categorical data are percentages."
    } else {
      "Categorical data are n (%)."
    }
    notes <- c(notes, continuous_text)
    if ("mean_se" %in% continuous_formats &&
        !identical(continuous_formats, "mean_se")) {
      notes <- c(
        notes,
        "SE is the standard error of the estimated mean, not the variability of individual observations."
      )
    }
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

    if (length(categorical_vars) > 0L &&
        isTRUE(object$overall) &&
        identical(percent, "row") &&
        identical(object$overall_categorical %||% "auto", "auto")) {
      notes <- c(
        notes,
        "Overall categorical values are counts; grouped percentages use row denominators."
      )
    }

    ci_vars <- object$ci_variables %||% {
      if (isTRUE(object$ci)) categorical_vars else character()
    }
    categorical_ci_vars <- intersect(categorical_vars, ci_vars)
    continuous_ci_vars <- intersect(continuous_vars, ci_vars)
    if (length(categorical_ci_vars) > 0L) {
      notes <- c(
        notes,
        paste0(
          if (length(categorical_ci_vars) == length(categorical_vars)) {
            "Categorical proportions include "
          } else {
            "Selected categorical proportions include "
          },
          round(100 * (object$conf.level %||% 0.95)),
          "% ",
          if (identical(object$ci_method %||% "wilson", "wilson")) {
            "Wilson score"
          } else {
            "exact binomial"
          },
          " CIs."
        )
      )
    }
    if (length(continuous_ci_vars) > 0L) {
      notes <- c(
        notes,
        paste0(
          if (length(continuous_ci_vars) == length(continuous_vars)) {
            "Continuous means include "
          } else {
            "Selected continuous means include "
          },
          round(100 * (object$conf.level %||% 0.95)),
          "% t-based CIs."
        )
      )
    }
  }

  if ("proportion" %in% object$components) {
    proportion_note <- helper_notes[grepl("^Confidence intervals:", helper_notes)]
    if (length(proportion_note) > 0L) {
      notes <- c(notes, proportion_note)
    }
  }

  if ("ci" %in% (object$components %||% character())) {
    skipped_note <- helper_notes[grepl("^Confidence intervals were not added", helper_notes)]
    if (length(skipped_note) > 0L) notes <- c(notes, skipped_note)
  }

  if ("rate" %in% (object$components %||% character())) {
    rate_notes <- helper_notes[grepl("^Rates per ", helper_notes)]
    if (length(rate_notes) > 0L) notes <- c(notes, rate_notes)
  }

  paste(unique(notes[nzchar(notes)]), collapse = " ")
}

#' Convert a gtstats result to a gt table
#'
#' Render supported `gtstats` objects as formatted `gt` tables.
#'
#' This function is the explicit rendering bridge between analytical
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
#' - `gtstats_summary`
#' - `gt_data_table`
#'
#' @param x A supported `gtstats` object.
#' @param title Optional table title.
#' @param subtitle Optional table subtitle.
#' @param bold_labels Logical; whether to bold variable labels where
#'   appropriate.
#' @param show_footnotes Logical; whether explanatory footnotes should
#'   be displayed.
#'
#' @return A `gt_tbl` object.
#'
#' @examples
#' to_gt(describe_data(mtcars))
#'
#' to_gt(summary_table(mtcars, by = am, include = c(mpg, wt)))
#'
#' to_gt(compare_groups(mtcars, variable = mpg, group = am))
#'
#' to_gt(
#'   summary_table(
#'     mtcars,
#'     by = am,
#'     include = c(mpg, wt, cyl),
#'     overall = TRUE
#'   ) |>
#'     add_total() |>
#'     add_p()
#' )
#'
#' @export
to_gt <- function(
    x,
    title = NULL,
    subtitle = NULL,
    bold_labels = TRUE,
    show_footnotes = TRUE
) {
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
    body_padding <- .publication_auto_padding(nrow(gt_tbl[["_data"]]))
    gt_tbl |>
      gt::tab_options(
        table.font.names = "system-ui",
        table.font.size = gt::px(13),
        footnotes.font.size = gt::px(10),
        source_notes.font.size = gt::px(10),
        data_row.padding = gt::px(body_padding),
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

  # Render an already summarised data frame without changing its values.
  if (inherits(x, "gt_data_table")) {
    gt_tbl <- gt::gt(x$table)
    gt_tbl <- .apply_header(gt_tbl, title = title, subtitle = subtitle)
    gt_tbl <- .style_common(gt_tbl)
    text_columns <- names(x$table)[vapply(
      x$table,
      function(column) is.character(column) || is.factor(column),
      logical(1)
    )]
    if (length(text_columns)) {
      gt_tbl <- gt::cols_align(gt_tbl, align = "left", columns = text_columns)
    }
    numeric_columns <- names(x$table)[vapply(x$table, is.numeric, logical(1))]
    if (length(numeric_columns)) {
      gt_tbl <- gt::cols_align(gt_tbl, align = "right", columns = numeric_columns)
    }
    if (show_footnotes && length(x$notes %||% character())) {
      for (note in x$notes) {
        gt_tbl <- gt::tab_source_note(gt_tbl, source_note = note)
      }
    }
    return(gt_tbl)
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

    if (show_footnotes && "Observed SD ratio" %in% names(x$table)) {
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = x$notes[["ratios"]],
        locations = gt::cells_column_labels(columns = "Observed SD ratio")
      )
    }
    variance_test_column <- intersect(c("Levene p", "Bartlett p"), names(x$table))
    if (show_footnotes && length(variance_test_column) == 1L) {
      variance_test_note <- unlist(
        x$notes[c("levene", "bartlett", "welch")],
        use.names = FALSE
      )
      variance_test_note <- variance_test_note[
        !is.na(variance_test_note) & nzchar(variance_test_note)
      ]
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = paste(variance_test_note, collapse = " "),
        locations = gt::cells_column_labels(columns = variance_test_column)
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
      paired_analysis_note <- if (isTRUE(x$inferential$paired[[1L]])) {
        denominator <- x$denominators$denominator[[1L]] %||% NA_real_
        excluded <- x$denominators$n_missing[[1L]] %||% NA_real_
        if (is.finite(denominator) && is.finite(excluded)) {
          paste0(
            "Paired analysis used ", denominator, " complete ",
            if (x$inferential$group_levels[[1L]] == 2L) "pairs" else "participants",
            "; ", excluded, " excluded because complete matched observations were unavailable."
          )
        } else {
          NULL
        }
      } else {
        NULL
      }
      repeated_anova_note <- if (identical(
        x$inferential$test_used[[1L]],
        "Repeated-measures ANOVA"
      )) {
        "Greenhouse-Geisser-corrected degrees of freedom are used for sphericity."
      } else {
        NULL
      }
      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = paste(
          c(x$inferential$test_used[[1L]], paired_analysis_note, repeated_anova_note),
          collapse = " "
        ),
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

    if (inherits(x, "gt_correlation_matrix")) {
      if (isTRUE(x$inputs$shade)) {
        palette <- grDevices::colorRamp(c("#355C7D", "#FFFFFF", "#C06C5B"))
        labels <- names(x$table)[-1L]
        values <- diag(length(labels))
        rownames(values) <- colnames(values) <- labels
        for (i in seq_len(nrow(x$summary))) {
          a <- labels[match(x$summary$x[[i]], x$inputs$vars)]
          b <- labels[match(x$summary$y[[i]], x$inputs$vars)]
          values[a, b] <- values[b, a] <- x$summary$estimate[[i]]
        }
        for (row in seq_along(labels)) {
          for (column in seq_along(labels)) {
            if (!nzchar(x$table[[column + 1L]][[row]])) next
            if (row == column) {
              fill <- "#F2F2F2"
            } else {
              rgb <- palette((values[row, column] + 1) / 2) / 255
              fill <- grDevices::rgb(rgb[[1L]], rgb[[2L]], rgb[[3L]])
            }
            gt_tbl <- gt::tab_style(
              gt_tbl,
              style = gt::cell_fill(color = fill),
              locations = gt::cells_body(columns = column + 1L, rows = row)
            )
          }
        }
      }
      if (show_footnotes) {
        gt_tbl <- gt::tab_source_note(gt_tbl, source_note = x$method$selection_rule)
        gt_tbl <- gt::tab_source_note(
          gt_tbl,
          source_note = "Pairwise complete finite observations are used; pair-specific N and p-values remain in `$summary`."
        )
      }
      return(.add_audit_note(gt_tbl, x))
    }

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

    display_columns <- x$method$display_columns
    if (!is.null(x$inputs$by) && is.data.frame(display_columns)) {
      for (i in seq_len(nrow(display_columns))) {
        child_columns <- c(
          display_columns$estimate[[i]],
          display_columns$ci[[i]]
        )
        gt_tbl <- gt::tab_spanner(
          gt_tbl,
          label = display_columns$group[[i]],
          columns = tidyselect::all_of(child_columns)
        )
        labels <- stats::setNames(
          list(
            display_columns$estimate_label[[i]],
            .conf_level_label(x$inputs$conf.level)
          ),
          child_columns
        )
        gt_tbl <- do.call(gt::cols_label, c(list(.data = gt_tbl), labels))
      }
    }

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title,
      subtitle = subtitle
    )

    gt_tbl <- .style_common(gt_tbl)

    text_cols <- intersect(
      "Event",
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
      ci_columns <- if (is.data.frame(display_columns)) {
        display_columns$ci
      } else {
        names(x$table)[ncol(x$table)]
      }

      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = paste0(
          x$method$interval,
          " ",
          round(x$inputs$conf.level * 100),
          "% confidence interval."
        ),
        locations = gt::cells_column_labels(
          columns = tidyselect::all_of(ci_columns)
        )
      )
    }

    return(.add_audit_note(gt_tbl, x))
  }

  # Render descriptive table builder output
  if (inherits(x, "gtstats_summary")) {
    if (is.null(x$table)) {
      stop(
        paste0(
          "This descriptive table has no rows yet. Add rows ",
          "before calling `to_gt()`."
        ),
        call. = FALSE
      )
    }

    characteristic_display <- .builder_characteristic_display(x$table)
    tbl <- characteristic_display$data

    gt_tbl <- gt::gt(tbl)

    if (identical(x$layout %||% "compact", "separate") &&
        is.data.frame(x$display_columns)) {
      for (i in seq_len(nrow(x$display_columns))) {
        child_columns <- c(x$display_columns$estimate[[i]])
        if (!is.na(x$display_columns$ci[[i]]) &&
            nzchar(x$display_columns$ci[[i]])) {
          child_columns <- c(child_columns, x$display_columns$ci[[i]])
        }
        gt_tbl <- gt::tab_spanner(
          gt_tbl,
          label = gt::md(sub(
            "\n", "  \n", x$display_columns$group[[i]], fixed = TRUE
          )),
          columns = tidyselect::all_of(child_columns)
        )
        child_labels <- c(x$display_columns$estimate_label[[i]])
        if (length(child_columns) == 2L) {
          child_labels <- c(child_labels, x$display_columns$ci_label[[i]])
        }
        labels <- stats::setNames(as.list(child_labels), child_columns)
        gt_tbl <- do.call(gt::cols_label, c(list(.data = gt_tbl), labels))
      }
    }

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title,
      subtitle = subtitle
    )

    if (bold_labels && "Characteristic" %in% names(tbl)) {
      non_empty_rows <- characteristic_display$parent_rows

      if (length(non_empty_rows) > 0) {
        gt_tbl <- gt::tab_style(
          gt_tbl,
          style = gt::cell_text(weight = "bold"),
          locations = gt::cells_body(
            columns = "Characteristic",
            rows = non_empty_rows
          )
        )
      }
    }

    if ("Characteristic" %in% names(tbl)) {
      if (length(characteristic_display$level_rows) > 0L) {
        gt_tbl <- gt::tab_style(
          gt_tbl,
          style = gt::cell_text(indent = gt::px(14)),
          locations = gt::cells_body(
            columns = "Characteristic",
            rows = characteristic_display$level_rows
          )
        )
      }
    }

    header_labels <- if (identical(x$layout %||% "compact", "separate")) {
      character()
    } else {
      .builder_display_headers(x)
    }
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

    text_cols <- intersect("Characteristic", names(tbl))
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

      if ("p-value" %in% names(tbl) &&
          length(x$paired_p_notes %||% character()) > 0L) {
        gt_tbl <- gt::tab_footnote(
          gt_tbl,
          footnote = paste(x$paired_p_notes, collapse = " "),
          locations = gt::cells_column_labels(columns = "p-value")
        )
      }

      if ("p-value" %in% names(tbl) &&
          !identical(x$method$p_adjust %||% "none", "none")) {
        gt_tbl <- gt::tab_footnote(
          gt_tbl,
          footnote = paste0(
            "P-values use the ", x$method$p_adjust,
            " multiplicity adjustment."
          ),
          locations = gt::cells_column_labels(columns = "p-value")
        )
      }
    }

    return(.add_audit_note(gt_tbl, x))
  }

  # Render rate tables
  if (inherits(x, "gt_rate")) {
    gt_tbl <- gt::gt(x$table)

    display_columns <- x$method$display_columns
    if (!is.null(x$inputs$by) && is.data.frame(display_columns)) {
      for (i in seq_len(nrow(display_columns))) {
        child_columns <- unname(unlist(display_columns[i, c(
          "events", "time", "rate", "ci"
        )]))
        gt_tbl <- gt::tab_spanner(
          gt_tbl,
          label = display_columns$group[[i]],
          columns = tidyselect::all_of(child_columns)
        )
        labels <- stats::setNames(
          list(
            "Events",
            .sentence_case(x$inputs$time_label),
            paste0(
              "Rate per ",
              format(x$inputs$multiplier, scientific = FALSE, trim = TRUE, big.mark = ",")
            ),
            .conf_level_label(x$inputs$conf.level)
          ),
          child_columns
        )
        gt_tbl <- do.call(gt::cols_label, c(list(.data = gt_tbl), labels))
      }
    }

    gt_tbl <- .apply_header(
      gt_tbl,
      title = title,
      subtitle = subtitle
    )

    gt_tbl <- .style_common(gt_tbl)

    text_cols <- intersect(
      "Event",
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
      ci_columns <- if (is.data.frame(display_columns)) {
        display_columns$ci
      } else {
        names(x$table)[ncol(x$table)]
      }

      gt_tbl <- gt::tab_footnote(
        gt_tbl,
        footnote = paste0(
          "Exact Poisson ",
          round(x$inputs$conf.level * 100),
          "% confidence interval."
        ),
        locations = gt::cells_column_labels(
          columns = tidyselect::all_of(ci_columns)
        )
      )
    }

    return(.add_audit_note(gt_tbl, x))
  }

  # Render 2x2 epidemiology tables
  if (inherits(x, "gt_epi_table")) {
    gt_tbl <- gt::gt(x$table)
    groups <- attr(x$table, "epi_groups", exact = TRUE)
    if (identical(x$inputs$layout, "wide") && length(groups)) {
      labels <- list(Outcome = "Outcome")
      for (group in groups) {
        key <- make.names(group)
        columns <- paste0(key, c("__Cases", "__Denominator", "__Estimate", "__CI"))
        gt_tbl <- gt::tab_spanner(gt_tbl, label = group, columns = tidyselect::all_of(columns))
        labels[[columns[[1L]]]] <- "Cases"
        labels[[columns[[2L]]]] <- if (identical(x$inputs$measure, "incidence_rate")) "Person-time" else "Denominator"
        labels[[columns[[3L]]]] <- .epi_measure_label(x$inputs$measure, x$inputs$multiplier)
        labels[[columns[[4L]]]] <- .conf_level_label(x$inputs$conf.level)
      }
      gt_tbl <- do.call(gt::cols_label, c(list(.data = gt_tbl), labels))
    }
    gt_tbl <- .apply_header(gt_tbl, title = title, subtitle = subtitle)
    gt_tbl <- .style_common(gt_tbl)
    gt_tbl <- gt::cols_align(gt_tbl, align = "left", columns = tidyselect::all_of(intersect(c("Outcome", "Group"), names(x$table))))
    gt_tbl <- gt::cols_align(gt_tbl, align = "right", columns = tidyselect::all_of(setdiff(names(x$table), c("Outcome", "Group"))))
    if (show_footnotes) for (note in x$notes) gt_tbl <- gt::tab_source_note(gt_tbl, source_note = note)
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
    "`to_gt()` does not yet support this object class.",
    call. = FALSE
  )
}
