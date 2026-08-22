#' Add confidence intervals to a summary table
#'
#' Add confidence intervals to all eligible summaries, or only to selected
#' variables, without rebuilding the descriptive table. Categorical variables
#' receive binomial confidence intervals for their displayed proportions.
#' Continuous variables displayed with a mean receive a t-based confidence
#' interval for the mean. Median-only summaries are left unchanged because a
#' distribution-free median interval is not implied by the displayed IQR.
#' Compact tables show the interval after the estimate without repeating the
#' confidence level in every cell. Separate tables use concise `CI` child
#' columns. The confidence level and interval method are stated once in the
#' publication footnote.
#'
#' @param x A table created by [summary_table()].
#' @param vars Variables that should receive confidence intervals. `NULL`
#'   (default) selects every eligible variable already in the table. Variables
#'   may be supplied as bare names, for example `c(age, sex)`, or as a character
#'   vector.
#' @param conf.level Confidence level. Default is `0.95`.
#' @param method Binomial interval method for categorical proportions:
#'   `"wilson"` (default) or `"exact"`. Continuous mean intervals use the
#'   usual t interval.
#' @param digits Decimal places for confidence limits. `NULL` inherits the
#'   confidence-interval precision from the table.
#'
#' @return The updated `gt_desc_table` object.
#'
#' @examples
#' summary_table(mtcars, by = am, include = c(mpg, cyl), layout = "separate") |>
#'   add_ci()
#'
#' summary_table(mtcars, by = am, include = c(mpg, cyl, vs)) |>
#'   add_ci(vars = c(mpg, vs), conf.level = 0.90)
#'
#' @export
add_ci <- function(
    x,
    vars = NULL,
    conf.level = 0.95,
    method = c("wilson", "exact"),
    digits = NULL
) {
  .validate_summary_builder(x, "add_ci", mode = "summary")
  method <- match.arg(method)
  .validate_conf_level(conf.level)
  if (!is.null(digits)) .validate_digits(digits)
  if (!"summary" %in% (x$components %||% character())) {
    stop("`add_ci()` requires ordinary summaries in the table.", call. = FALSE)
  }
  if ("ci" %in% (x$components %||% character())) {
    stop("Confidence intervals have already been added to this table.", call. = FALSE)
  }
  if (identical(x$categorical_layout %||% "combined", "separate")) {
    stop(
      "`add_ci()` cannot be added to separate n and % columns. Build the table with `categorical_layout = \"combined\"` and `layout = \"separate\"`.",
      call. = FALSE
    )
  }

  available <- unique(names(x$summary_statistics %||% character()))
  vars_expr <- substitute(vars)
  selected <- if (identical(vars_expr, quote(NULL)) ||
                  (is.call(vars_expr) &&
                   identical(as.character(vars_expr[[1L]]), "everything"))) {
    available
  } else {
    .resolve_vars_arg(vars_expr, env = parent.frame())
  }
  unknown <- setdiff(selected, available)
  if (length(unknown) > 0L) {
    stop(
      "Variables are not ordinary summaries in this table: ",
      paste(unknown, collapse = ", "), ".",
      call. = FALSE
    )
  }
  if (length(selected) == 0L) {
    stop("`vars` must select at least one table variable.", call. = FALSE)
  }

  ci_digits <- if (is.null(digits)) {
    (x$digits %||% .resolve_summary_digits(1))[["ci"]] %||% 1L
  } else {
    as.integer(digits)
  }
  percent_digits <- (x$digits %||% .resolve_summary_digits(1))[["percent"]] %||% 1L
  statistics <- x$summary_statistics %||% character()
  types <- vapply(selected, function(variable) .detect_type(x$data[[variable]]), character(1))
  unsupported <- selected[
    types == "continuous" & statistics[selected] == "median_iqr"
  ]
  eligible <- setdiff(selected, unsupported)
  if (length(eligible) == 0L) {
    stop(
      "No confidence intervals were added. Median (IQR) summaries do not imply a median confidence interval.",
      call. = FALSE
    )
  }

  if (identical(x$layout %||% "compact", "separate")) {
    x <- .builder_use_separate_layout(x, conf.level = conf.level)
    if (!is.null(x$display_columns) && nrow(x$display_columns) > 0L) {
      x$display_columns$ci_label <- .conf_level_label(conf.level)
    }
  }

  group_masks <- list()
  if (isTRUE(x$overall)) group_masks$Overall <- rep(TRUE, nrow(x$data))
  if (!is.null(x$by)) {
    group_columns <- .builder_group_columns(x)
    for (group_value in names(group_columns)) {
      group_masks[[unname(group_columns[[group_value]])]] <-
        !is.na(x$data[[x$by]]) &
        as.character(x$data[[x$by]]) == group_value
    }
  }
  if (is.null(x$by) && !isTRUE(x$overall)) {
    group_masks$Value <- rep(TRUE, nrow(x$data))
  }

  format_ci <- function(low, high, percentage = FALSE) {
    if (!is.finite(low) || !is.finite(high)) return("")
    suffix <- if (isTRUE(percentage)) "%" else ""
    paste0(
      .format_number(low, ci_digits), "\u2013",
      .format_number(high, ci_digits), suffix
    )
  }
  put_ci <- function(row_index, source, interval, percentage = FALSE) {
    interval_text <- format_ci(interval[[1L]], interval[[2L]], percentage)
    if (identical(x$layout %||% "compact", "separate")) {
      mapping <- x$display_columns[x$display_columns$source == source, , drop = FALSE]
      if (nrow(mapping) == 1L) {
        x$table[[mapping$ci[[1L]]]][row_index] <<- interval_text
      }
    } else {
      current <- x$table[[source]][row_index]
      x$table[[source]][row_index] <<- paste0(current, "; ", interval_text)
    }
  }

  for (variable in eligible) {
    label <- .get_var_label(x$data, variable)
    variable_type <- .detect_type(x$data[[variable]])
    row_indices <- which(x$table$Variable == label & x$table$Level != "Missing")
    if (length(row_indices) == 0L) next

    for (source in names(group_masks)) {
      values <- x$data[[variable]][group_masks[[source]]]
      if (identical(variable_type, "continuous")) {
        continuous_rows <- row_indices[x$table$Level[row_indices] == ""]
        row_index <- if (length(continuous_rows) > 0L) continuous_rows[[1L]] else NA_integer_
        finite <- values[is.finite(values)]
        if (!is.na(row_index) && length(finite) >= 2L) {
          estimate <- mean(finite)
          se <- stats::sd(finite) / sqrt(length(finite))
          critical <- stats::qt((1 + conf.level) / 2, df = length(finite) - 1L)
          put_ci(row_index, source, estimate + c(-1, 1) * critical * se)
        }
      } else {
        nonmissing <- !is.na(values)
        for (row_index in row_indices) {
          level <- x$table$Level[[row_index]]
          numerator <- sum(as.character(values[nonmissing]) == level)
          denominator <- if (identical(x$percent %||% "column", "row") &&
                             !is.null(x$by) && source != "Overall") {
            sum(as.character(x$data[[variable]][!is.na(x$data[[variable]])]) == level)
          } else if (identical(x$percent %||% "column", "overall") && source != "Overall") {
            sum(!is.na(x$data[[variable]]))
          } else {
            sum(nonmissing)
          }
          if (denominator > 0L) {
            interval <- 100 * .binomial_ci(
              numerator, denominator, conf.level = conf.level, method = method
            )
            put_ci(row_index, source, interval, percentage = TRUE)
          }
        }
      }
    }
  }

  x$components <- unique(c(x$components, "ci"))
  x$ci <- TRUE
  x$ci_variables <- eligible
  x$ci_skipped <- unsupported
  x$conf.level <- conf.level
  x$ci_method <- method
  x$footnotes <- unique(c(
    x$footnotes,
    if (length(unsupported) > 0L) {
      paste0(
        "Confidence intervals were not added to median (IQR) summaries: ",
        paste(vapply(unsupported, function(v) .get_var_label(x$data, v), character(1)), collapse = ", "),
        "."
      )
    } else character()
  ))
  x
}
