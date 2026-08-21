#' Add a proportion row to a descriptive table
#'
#' Add a row showing the proportion of a selected level of a binary,
#' categorical, or ordinal variable within a `gtstats` descriptive table.
#'
#' This is useful when you want to highlight a specific category such as
#' `"Yes"`, `"1"`, or `"TRUE"` within a Table 1 workflow. The row can be added
#' overall, by groups, or both, depending on how the descriptive table was
#' created.
#'
#' If `level = NULL`, the function chooses a default level using the following
#' order:
#' - `"1"`
#' - `"Yes"` / `"yes"`
#' - `"TRUE"` / `"True"` / `"true"`
#' - the second available level for binary variables
#' - otherwise the first available non-missing level
#'
#' Wilson confidence intervals are used by default. Exact binomial intervals
#' are available with `ci_method = "exact"`.
#'
#' @param x A `gt_desc_table` object created with [summary_table()].
#' @param var Variable to summarise as a proportion. Can be supplied as a bare
#'   name or as a character string.
#' @param level Optional level to count. If `NULL`, a default level is selected
#'   automatically.
#' @param ci Logical; whether to display a confidence interval.
#' @param conf.level Confidence level for the interval. Default is `0.95`.
#' @param ci_method Confidence-interval method: `"wilson"` or `"exact"`.
#' @param display Cell display: `"n_percent"`, `"percent"`, or
#'   `"n_over_N_percent"`.
#' @param layout Table layout. `NULL` inherits the parent table layout;
#'   `"compact"` keeps the estimate and CI together and `"separate"` places
#'   them in separate columns beneath each cohort header.
#' @param digits Number of decimal places used when formatting percentages.
#' @param label Optional row label. Defaults to the variable label if available,
#'   otherwise the variable name.
#'
#' @return An updated `gt_desc_table` object with a proportion row appended.
#'
#' @examples
#' summary_table(mtcars, by = am, overall = TRUE) |>
#'   add_proportion(var = vs)
#'
#' summary_table(mtcars, by = am, overall = TRUE) |>
#'   add_proportion(var = vs, level = "1", ci = TRUE)
#'
#' summary_table(mtcars) |>
#'   add_proportion(var = vs, ci = FALSE)
#'
#' @export
add_proportion <- function(
    x,
    var,
    level = NULL,
    ci = TRUE,
    conf.level = 0.95,
    ci_method = c("wilson", "exact"),
    display = c("n_percent", "percent", "n_over_N_percent"),
    layout = NULL,
    digits = 1,
    label = NULL
) {
  .validate_summary_builder(x, "add_proportion", mode = "summary")
  ci_method <- match.arg(ci_method)
  display <- match.arg(display)
  if (is.null(layout)) layout <- x$layout %||% "compact"
  layout <- match.arg(layout, c("compact", "separate"))
  .validate_flag(ci, "ci")
  .validate_conf_level(conf.level)
  .validate_digits(digits)

  # Validate table object and ensure this helper is used only in summary mode
  # Resolve variable name from either bare input or character input
  var_expr <- substitute(var)
  var_name <- if (is.symbol(var_expr)) {
    deparse(var_expr)
  } else {
    var_eval <- tryCatch(eval(var_expr, parent.frame()),
                         error = function(e) NULL)
    if (is.character(var_eval) && length(var_eval) == 1) {
      var_eval
    } else {
      deparse(var_expr)
    }
  }

  if (!var_name %in% names(x$data)) {
    stop("`var` was not found in the data.", call. = FALSE)
  }

  # Restrict this helper to variables where proportions are meaningful
  v <- x$data[[var_name]]
  v_type <- .detect_type(v)

  if (!v_type %in% c("binary", "categorical", "ordinal")) {
    stop(
      paste0(
        "`add_proportion()` currently supports binary, categorical, ",
        "or ordinal variables."
      ),
      call. = FALSE
    )
  }

  v_chr <- as.character(v)
  level <- .select_target_level(v_chr, level)

  # Use variable label if present; otherwise fall back to variable name
  label_supplied <- !is.null(label)
  if (is.null(label)) {
    label <- .get_var_label(x$data, var_name)
  }
  if (!is.character(label) || length(label) != 1L || is.na(label) ||
      !nzchar(label)) {
    stop("`label` must be NULL or a single non-empty character string.",
         call. = FALSE)
  }

  # Build the final display string for one cell
  .make_display <- function(values,
                            ci = TRUE,
                            conf.level = 0.95,
                            digits = 1) {
    result <- .proportion_summary(
      values,
      level = level,
      conf.level = conf.level,
      method = ci_method
    )
    .format_proportion_display(
      result,
      display = display,
      digits = digits,
      ci = ci
    )
  }

  .make_parts <- function(values) {
    result <- .proportion_summary(
      values, level = level, conf.level = conf.level, method = ci_method
    )
    estimate <- .format_proportion_display(
      result, display = display, digits = digits, ci = FALSE
    )
    interval <- if (!isTRUE(ci) || is.na(result$conf_low) ||
                    is.na(result$conf_high)) {
      ""
    } else {
      paste0(
        .format_ci(100 * result$conf_low, 100 * result$conf_high, digits),
        "%"
      )
    }
    c(estimate = estimate, ci = interval)
  }

  # Preserve an explicit publication label exactly. When the default variable
  # label is used, append the selected level so the highlighted event remains
  # visible without requiring the reader to inspect metadata.
  display_label <- if (label_supplied) label else paste0(label, " (", level, ")")
  row_tbl <- tibble::tibble(
    Variable = display_label,
    Level = ""
  )

  if (identical(layout, "separate")) {
    estimate_label <- switch(
      display,
      n_percent = "n (%)",
      percent = "%",
      n_over_N_percent = "n/N (%)"
    )
    x <- .builder_use_separate_layout(
      x, conf.level = conf.level, estimate_label = estimate_label
    )
  }

  # Add overall proportion if the descriptive table includes an Overall column
  if (isTRUE(x$overall)) {
    parts <- .make_parts(values = v_chr)
    if (identical(layout, "separate")) {
      row_tbl <- .builder_set_separate_cell(
        row_tbl, x, "Overall", parts[["estimate"]], parts[["ci"]]
      )
    } else {
      row_tbl$Overall <- .make_display(v_chr, ci, conf.level, digits)
    }
  }

  # Add group-specific proportions if the descriptive table is grouped
  if (!is.null(x$by)) {
    by_var <- x$data[[x$by]]
    group_values_chr <- .builder_group_values(x)
    group_labels <- .builder_group_columns(x)

    for (i in seq_along(group_values_chr)) {
      g <- group_values_chr[[i]]
      idx <- !is.na(by_var) & as.character(by_var) == g
      vg <- v_chr[idx]

      parts <- .make_parts(vg)
      if (identical(layout, "separate")) {
        row_tbl <- .builder_set_separate_cell(
          row_tbl, x, unname(group_labels[[i]]),
          parts[["estimate"]], parts[["ci"]]
        )
      } else {
        row_tbl[[group_labels[[i]]]] <- .make_display(vg, ci, conf.level, digits)
      }
    }
  } else if (!isTRUE(x$overall)) {
    # Use a single Value column when neither grouping nor overall is used
    parts <- .make_parts(v_chr)
    if (identical(layout, "separate")) {
      row_tbl <- .builder_set_separate_cell(
        row_tbl, x, "Value", parts[["estimate"]], parts[["ci"]]
      )
    } else {
      row_tbl$Value <- .make_display(v_chr, ci, conf.level, digits)
    }
  }

  row_tbl <- tibble::as_tibble(row_tbl)

  # Align the new row to the current table structure before appending
  x <- .append_builder_rows(x, row_tbl)

  # Record component type and explanatory footnote
  x$components <- unique(c(x$components, "proportion"))
  audit_groups <- .builder_audit_groups(x)
  audit_rows <- dplyr::bind_rows(lapply(
    names(audit_groups),
    function(group_label) {
      idx <- audit_groups[[group_label]]
      values <- v_chr[idx]
      .denominators_tbl(
        variable = var_name,
        level = level,
        group = group_label,
        n_total = length(values),
        n_nonmissing = sum(!is.na(values)),
        n_missing = sum(is.na(values)),
        numerator = sum(values == level, na.rm = TRUE),
        denominator = sum(!is.na(values)),
        rule = paste0("Non-missing observations; event level = ", level)
      )
    }
  ))
  x$denominators <- dplyr::bind_rows(
    x$denominators %||% .empty_denominators(),
    audit_rows
  )

  footnote_text <- if (ci) {
    paste0(
      "Selected event: ",
      label,
      " = ",
      level,
      ". Cells show n (%); the range after the semicolon is the ",
      round(conf.level * 100),
      "% ",
      if (identical(ci_method, "wilson")) "Wilson score" else "exact binomial",
      " confidence interval for the percentage."
    )
  } else {
    paste0("Selected event: ", label, " = ", level, ".")
  }

  footnote_text <- paste0(
    footnote_text,
    " This is a selected-event descriptive row. `add_p()` tests the full ",
    "variable association and therefore does not add a separate p-value to ",
    "this highlighted row."
  )

  x$footnotes <- unique(c(x$footnotes, footnote_text))

  x
}
