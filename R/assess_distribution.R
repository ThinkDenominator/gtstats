#' Assess the empirical distribution of continuous variables
#'
#' Assess the empirical distribution of continuous numeric variables to support
#' descriptive reporting. The function describes missingness, finite sample
#' size, skewness, and (optionally) Shapiro-Wilk results. It provides guidance
#' about presenting a variable; it does **not** select an inferential test.
#'
#' When `by` is supplied, diagnostics are calculated within every group and one
#' consistent, variable-level recommendation is also returned in
#' `$recommendations`. Shapiro-Wilk is supporting information only: it is
#' sensitive to sample size and never determines the recommendation by itself.
#'
#' @param data A data frame.
#' @param vars Continuous numeric variables to assess. Bare names or a character
#'   vector are accepted. When omitted, all detected continuous variables are
#'   assessed. Categorical, ordinal, logical, date-time, and binary variables
#'   are rejected when explicitly selected.
#' @param by Optional grouping variable, supplied as a bare name or character
#'   string. Factors, characters, logical variables, binary variables, and
#'   ordinal variables are supported.
#' @param normality_test Logical; run Shapiro-Wilk when 3 to 5000 finite
#'   observations are available. Default is `TRUE`.
#' @param skew_cutoff Positive absolute-skewness threshold for marked skew.
#' @param min_n Minimum finite observations required for a shape assessment.
#' @param plots Logical; create histogram, density, Q-Q, and box plots. Plots
#'   are stored in `$plots` (or `attr(result, "plots")` for tibble output).
#' @param digits Number of decimal places.
#' @param format Output format: `"table"` (default) or `"tibble"`.
#' @param output Compatibility alias for `format`.
#'
#' @return With `format = "table"`, a `gt_distribution` object that prints as a
#'   publication-ready table. `$summary` contains group-level diagnostics and
#'   `$recommendations` contains one descriptive recommendation per variable.
#'   With `format = "tibble"`, the group-level summary tibble is returned.
#'
#' @examples
#' assess_distribution(mtcars, vars = c(mpg, wt))
#' assess_distribution(mtcars, vars = c(mpg, wt), by = am)
#' assess_distribution(mtcars, vars = "mpg", normality_test = FALSE)
#' assess_distribution(mtcars, vars = c("mpg", "wt"), plots = TRUE)$plots
#'
#' @export
assess_distribution <- function(
    data,
    vars = NULL,
    by = NULL,
    normality_test = TRUE,
    skew_cutoff = 1,
    min_n = 3,
    plots = FALSE,
    digits = 2,
    format = c("table", "tibble"),
    output = NULL
) {
  if (!is.null(output)) {
    format <- output
  }
  format <- match.arg(format, c("table", "tibble"))
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }
  .validate_flag(normality_test, "normality_test")
  .validate_flag(plots, "plots")
  if (!is.numeric(skew_cutoff) || length(skew_cutoff) != 1L ||
      is.na(skew_cutoff) || skew_cutoff <= 0) {
    stop("`skew_cutoff` must be a single positive number.", call. = FALSE)
  }
  if (!is.numeric(min_n) || length(min_n) != 1L ||
      is.na(min_n) || min_n < 3 || min_n != floor(min_n)) {
    stop("`min_n` must be a whole number greater than or equal to 3.",
         call. = FALSE)
  }
  .validate_digits(digits)

  by_name <- .resolve_var_arg(
    substitute(by), env = parent.frame(), allow_null = TRUE
  )
  if (!is.null(by_name) && !by_name %in% names(data)) {
    stop("`by` was not found in `data`.", call. = FALSE)
  }
  if (!is.null(by_name) && identical(.detect_type(data[[by_name]]), "continuous")) {
    stop(
      "`by` must be a categorical, ordinal, logical, or binary grouping variable.",
      call. = FALSE
    )
  }

  vars_expr <- substitute(vars)
  vars_selected <- !identical(vars_expr, quote(NULL))
  vars_names <- if (vars_selected) {
    .resolve_vars_arg(vars_expr, env = parent.frame())
  } else {
    names(data)[vapply(data, function(x) identical(.detect_type(x), "continuous"), logical(1))]
  }
  missing_vars <- setdiff(vars_names, names(data))
  if (length(missing_vars) > 0L) {
    stop("These variables were not found in `data`: ",
         paste(missing_vars, collapse = ", "), ".", call. = FALSE)
  }
  vars_names <- setdiff(vars_names, by_name %||% character())
  if (length(vars_names) == 0L) {
    stop("Select at least one continuous numeric variable other than `by`.", call. = FALSE)
  }

  is_supported_continuous <- function(x) {
    if (!is.numeric(x) || inherits(x, c("Date", "POSIXct", "POSIXlt"))) {
      return(FALSE)
    }
    finite <- x[is.finite(x)]
    # All-missing and constant numeric variables are retained so that the
    # function can report the data-quality issue rather than fail early.
    if (any(!is.na(x) & !is.finite(x)) || length(finite) <= 1L ||
        length(unique(finite)) <= 1L) {
      return(TRUE)
    }
    identical(.detect_type(x), "continuous")
  }
  invalid_vars <- vars_names[!vapply(data[vars_names], is_supported_continuous, logical(1))]
  if (length(invalid_vars) > 0L) {
    variable <- invalid_vars[[1L]]
    type <- .detect_type(data[[variable]])
    stop(
      "Variable \"", variable, "\" is ", type,
      ". `assess_distribution()` is intended for continuous numeric variables only.",
      call. = FALSE
    )
  }

  .shape_guidance <- function(n, missing, non_finite, skewness, constant) {
    if (n == 0L) {
      return(c("All values missing or non-finite", "No descriptive summary; resolve data quality first."))
    }
    if (constant) {
      return(c("Constant (zero variance)", "Report the value and n; dispersion is zero."))
    }
    if (n < min_n || is.na(skewness)) {
      return(c("Insufficient observations", "Review manually; too few finite observations for a shape assessment."))
    }
    if (abs(skewness) >= skew_cutoff) {
      direction <- if (skewness > 0) "right" else "left"
      return(c(paste("Marked", direction, "skew"), "Median (IQR) is usually preferable."))
    }
    if (abs(skewness) >= skew_cutoff / 2) {
      direction <- if (skewness > 0) "right" else "left"
      return(c(paste("Some", direction, "asymmetry"), "Compare mean (SD) and median (IQR)."))
    }
    c("Little/no asymmetry", "Mean (SD) is usually suitable.")
  }

  .diagnose <- function(x, variable, group = NA_character_) {
    missing <- sum(is.na(x))
    non_finite <- sum(!is.na(x) & !is.finite(x))
    observed <- x[is.finite(x)]
    n <- length(observed)
    constant <- n > 0L && length(unique(observed)) == 1L
    skewness <- if (constant) NA_real_ else .sample_skewness(observed)
    shapiro_p <- NA_real_
    shapiro_note <- "Not requested"
    if (isTRUE(normality_test)) {
      if (constant) {
        shapiro_note <- "Not run: constant values"
      } else if (n < 3L || n > 5000L) {
        shapiro_note <- "Not run: requires 3 to 5000 finite observations"
      } else {
        shapiro_p <- tryCatch(stats::shapiro.test(observed)$p.value,
          error = function(e) NA_real_)
        shapiro_note <- if (is.na(shapiro_p)) "Not run: calculation failed" else "Supporting information"
      }
    }
    guidance <- .shape_guidance(n, missing, non_finite, skewness, constant)
    tibble::tibble(
      variable = variable,
      label = .get_var_label(data, variable),
      group = group,
      n = n,
      missing = missing,
      non_finite = non_finite,
      skewness = skewness,
      shape = guidance[[1L]],
      group_guidance = guidance[[2L]],
      shapiro_p = shapiro_p,
      shapiro_note = shapiro_note
    )
  }

  group_values <- if (is.null(by_name)) {
    NA_character_
  } else {
    unique(as.character(data[[by_name]][!is.na(data[[by_name]])]))
  }
  rows <- unlist(lapply(vars_names, function(variable) {
    lapply(group_values, function(group_value) {
      index <- if (is.null(by_name)) rep(TRUE, nrow(data)) else
        !is.na(data[[by_name]]) & as.character(data[[by_name]]) == group_value
      .diagnose(data[[variable]][index], variable, group_value)
    })
  }), recursive = FALSE)
  summary_tbl <- dplyr::bind_rows(rows)

  recommendations <- dplyr::bind_rows(lapply(vars_names, function(variable) {
    rows_for_var <- summary_tbl[summary_tbl$variable == variable, , drop = FALSE]
    shapes <- rows_for_var$shape
    actionable <- !(shapes %in% c("All values missing or non-finite", "Constant (zero variance)", "Insufficient observations"))
    marked_shape <- any(grepl("Marked", shapes))
    some_shape <- any(grepl("Some", shapes))
    little_shape <- all(shapes == "Little/no asymmetry")
    data_quality_flag <- any(rows_for_var$missing > 0L | rows_for_var$non_finite > 0L)
    shapiro_conflict <- isTRUE(normality_test) &&
      ((little_shape && any(rows_for_var$shapiro_p < 0.05, na.rm = TRUE)) ||
        ((marked_shape || some_shape) && any(rows_for_var$shapiro_p >= 0.05, na.rm = TRUE)))

    affected_groups <- if (is.null(by_name)) {
      ""
    } else {
      paste(rows_for_var$group[grepl("Marked|Some", shapes)], collapse = ", ")
    }
    recommendation <- if (is.null(by_name)) {
      if (any(!actionable)) {
        "Review data before summarising"
      } else if (marked_shape) {
        "Median (IQR) preferred"
      } else if (some_shape) {
        "Review mean (SD) and median (IQR)"
      } else {
        "Mean (SD) reasonable"
      }
    } else if (any(!actionable)) {
      "Review data before summarising"
    } else if (marked_shape) {
      "Median (IQR) preferred"
    } else if (some_shape) {
      "Review mean (SD) and median (IQR)"
    } else {
      "Mean (SD) reasonable"
    }

    why <- if (any(!actionable)) {
      paste(unique(shapes[!actionable]), collapse = "; ")
    } else if (marked_shape) {
      if (is.null(by_name)) "Marked asymmetry in the observed values" else
        paste0("Marked asymmetry in: ", affected_groups)
    } else if (some_shape) {
      if (is.null(by_name)) "Some asymmetry in the observed values" else
        paste0("Some asymmetry in: ", affected_groups)
    } else {
      if (is.null(by_name)) "Little/no asymmetry" else
        "Little/no asymmetry in all assessed groups"
    }
    if (data_quality_flag && all(actionable)) {
      why <- paste0(why, "; missing or non-finite values are present")
    }
    review <- if (any(!actionable)) {
      "Resolve the data-quality issue before choosing a summary"
    } else if (shapiro_conflict) {
      "Inspect histogram and Q-Q plot; Shapiro-Wilk and skewness differ"
    } else if (marked_shape || some_shape) {
      "Inspect histogram and Q-Q plot"
    } else {
      "Use clinical judgement and visual review when important"
    }
    tibble::tibble(
      variable = variable,
      label = .get_var_label(data, variable),
      overall_recommendation = recommendation,
      reason = why,
      review = review
    )
  }))
  summary_tbl <- dplyr::left_join(summary_tbl, recommendations, by = c("variable", "label"))

  display_tbl <- summary_tbl
  display_tbl$label <- stats::ave(
    display_tbl$label, display_tbl$variable,
    FUN = function(x) c(x[[1L]], rep("", length(x) - 1L))
  )
  display_tbl$overall_recommendation <- stats::ave(
    display_tbl$overall_recommendation, display_tbl$variable,
    FUN = function(x) c(x[[1L]], rep("", length(x) - 1L))
  )
  display_cols <- c(
    "label", if (!is.null(by_name)) "group", "n",
    if (any(summary_tbl$missing > 0L)) "missing",
    if (any(summary_tbl$non_finite > 0L)) "non_finite",
    "skewness", "shape", "overall_recommendation",
    if (isTRUE(normality_test)) "shapiro_p"
  )
  table_tbl <- display_tbl[, display_cols, drop = FALSE]
  names(table_tbl) <- c(
    "Variable", if (!is.null(by_name)) "Group", "n",
    if (any(summary_tbl$missing > 0L)) "Missing",
    if (any(summary_tbl$non_finite > 0L)) "Non-finite",
    "Skewness", "Shape", "Suggested presentation",
    if (isTRUE(normality_test)) "Shapiro p"
  )
  table_tbl$Skewness <- vapply(table_tbl$Skewness, .format_number, character(1), digits = digits)
  if ("Shapiro p" %in% names(table_tbl)) {
    table_tbl$`Shapiro p` <- vapply(table_tbl$`Shapiro p`, .format_p_value, character(1))
  }

  .make_plots <- function(variable) {
    plot_data <- tibble::tibble(
      value = data[[variable]],
      group = if (is.null(by_name)) "Overall" else as.character(data[[by_name]])
    )
    plot_data <- plot_data[is.finite(plot_data$value) & !is.na(plot_data$group), , drop = FALSE]
    title <- .get_var_label(data, variable)
    facet <- if (is.null(by_name)) NULL else
      ggplot2::facet_wrap(ggplot2::vars(.data$group), scales = "free")
    base <- ggplot2::theme_minimal(base_size = 12) +
      ggplot2::theme(legend.position = "none", plot.title = ggplot2::element_text(face = "bold"))
    histogram <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data$value, fill = .data$group)) +
      ggplot2::geom_histogram(bins = 30, alpha = 0.7, na.rm = TRUE) + facet + base +
      ggplot2::labs(title = paste("Histogram:", title), x = title, y = "Count")
    density <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data$value, fill = .data$group)) +
      ggplot2::geom_density(alpha = 0.35, na.rm = TRUE) + facet + base +
      ggplot2::labs(title = paste("Density:", title), x = title, y = "Density")
    qq <- ggplot2::ggplot(plot_data, ggplot2::aes(sample = .data$value)) +
      ggplot2::stat_qq(na.rm = TRUE) + ggplot2::stat_qq_line(na.rm = TRUE) + facet + base +
      ggplot2::labs(title = paste("Q-Q plot:", title), x = "Theoretical quantiles", y = "Sample quantiles")
    boxplot <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data$group, y = .data$value, fill = .data$group)) +
      ggplot2::geom_boxplot(na.rm = TRUE) + base +
      ggplot2::labs(title = paste("Boxplot:", title), x = if (is.null(by_name)) NULL else .get_var_label(data, by_name), y = title)
    list(histogram = histogram, density = density, qq = qq, boxplot = boxplot)
  }
  plot_list <- if (isTRUE(plots)) stats::setNames(lapply(vars_names, .make_plots), vars_names) else NULL

  if (identical(format, "tibble")) {
    attr(summary_tbl, "recommendations") <- recommendations
    attr(summary_tbl, "plots") <- plot_list
    return(summary_tbl)
  }

  result <- list(
    inputs = list(data_name = deparse(substitute(data)), vars = vars_names,
      by = by_name, normality_test = normality_test, skew_cutoff = skew_cutoff,
      min_n = min_n, plots = plots, digits = digits, format = format),
    summary = summary_tbl,
    recommendations = recommendations,
    table = tibble::as_tibble(table_tbl),
    plots = plot_list,
    notes = c(
      shape = paste0("Shape categories use absolute sample skewness: little/no asymmetry < ",
        .format_number(skew_cutoff / 2, 2), "; some asymmetry ",
        .format_number(skew_cutoff / 2, 2), " to < ", .format_number(skew_cutoff, 2),
        "; marked skew >= ", .format_number(skew_cutoff, 2), ". They are descriptive guidance, not formal classifications."),
      shapiro = "Shapiro-Wilk is sensitive to sample size. Interpretation should consider skewness, graphical assessment, sample size and subject-matter knowledge.",
      recommendation = "Suggested summaries are intended for descriptive reporting only and should not be used alone to determine inferential statistical methods.",
      grouped_recommendation = "For grouped data, the suggested presentation applies to all groups of each variable."
    ),
    call = match.call()
  )
  class(result) <- c("gt_distribution", "gtstats", "list")
  result
}
