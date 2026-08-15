#' Assess variation of continuous variables across groups
#'
#' Describe the spread of continuous numeric variables within groups. This is a
#' diagnostic companion to [assess_distribution()] and is intended to make
#' variation visible before a group comparison is interpreted.
#'
#' `assess_variance()` reports group sample sizes, standard deviations,
#' variances, and the ratio of the largest to the smallest group SD and
#' variance. These ratios are descriptive diagnostics, not pass/fail tests.
#' The function deliberately does not run a variance hypothesis test by
#' default, and it does not choose an inferential test. In particular, Welch
#' t-tests and Welch ANOVA do not require equal variances.
#' Set `test = "bartlett"` to add Bartlett's test as supporting information.
#' Bartlett's test assumes normal group distributions and is deliberately not
#' used to select a test in `compare_groups()`.
#'
#' @param data A data frame.
#' @param vars Continuous numeric variables to assess. Bare names or a character
#'   vector are accepted. When omitted, all detected continuous variables are
#'   assessed. Categorical, ordinal, logical, date-time, and binary variables
#'   are rejected when explicitly selected.
#' @param by Grouping variable, supplied as a bare name or character string.
#'   It must be categorical, binary, logical, or ordinal and contain at least
#'   two observed groups.
#' @param digits Number of decimal places.
#' @param test Variance hypothesis test to display: `"none"` (default) or
#'   `"bartlett"`. Bartlett's test is sensitive to non-normality and is a
#'   diagnostic, not a gatekeeper for ANOVA or Welch methods.
#' @param output Either `"table"` (the default) or `"tibble"`.
#'
#' @return With `output = "table"`, a `gt_variance` object that prints as a
#'   publication-ready table. `$summary` contains all group-level values and
#'   repeated variable-level diagnostics. With `output = "tibble"`, the
#'   detailed summary tibble is returned.
#'
#' @examples
#' assess_variance(mtcars, vars = c(mpg, wt), by = am)
#' assess_variance(mtcars, vars = "mpg", by = am, digits = 1)
#' assess_variance(mtcars, vars = "mpg", by = am, test = "bartlett")
#'
#' @export
assess_variance <- function(
    data,
    vars = NULL,
    by,
    digits = 2,
    test = c("none", "bartlett"),
    output = c("table", "tibble")
) {
  output <- match.arg(output)
  test <- match.arg(test)
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }
  .validate_digits(digits)

  by_name <- .resolve_var_arg(substitute(by), env = parent.frame())
  if (!by_name %in% names(data)) {
    stop("`by` was not found in `data`.", call. = FALSE)
  }
  if (identical(.detect_type(data[[by_name]]), "continuous")) {
    stop(
      "`by` must be a categorical, ordinal, logical, or binary grouping variable.",
      call. = FALSE
    )
  }
  group_values <- unique(as.character(data[[by_name]][!is.na(data[[by_name]])]))
  if (length(group_values) < 2L) {
    stop("`by` must contain at least two observed groups.", call. = FALSE)
  }

  vars_expr <- substitute(vars)
  vars_selected <- !identical(vars_expr, quote(NULL))
  vars_names <- if (vars_selected) {
    .resolve_vars_arg(vars_expr, env = parent.frame())
  } else {
    names(data)[vapply(
      data,
      function(x) identical(.detect_type(x), "continuous"),
      logical(1)
    )]
  }
  missing_vars <- setdiff(vars_names, names(data))
  if (length(missing_vars) > 0L) {
    stop(
      "These variables were not found in `data`: ",
      paste(missing_vars, collapse = ", "), ".",
      call. = FALSE
    )
  }
  vars_names <- setdiff(vars_names, by_name)
  if (length(vars_names) == 0L) {
    stop("Select at least one continuous numeric variable other than `by`.", call. = FALSE)
  }

  is_supported_continuous <- function(x) {
    if (!is.numeric(x) || inherits(x, c("Date", "POSIXct", "POSIXlt"))) {
      return(FALSE)
    }
    finite <- x[is.finite(x)]
    # Retain sparse and constant numeric variables so the output can describe
    # the data-quality issue instead of failing before it is visible.
    if (any(!is.na(x) & !is.finite(x)) || length(finite) <= 1L ||
        length(unique(finite)) <= 1L) {
      return(TRUE)
    }
    identical(.detect_type(x), "continuous")
  }
  invalid_vars <- vars_names[!vapply(
    data[vars_names], is_supported_continuous, logical(1)
  )]
  if (length(invalid_vars) > 0L) {
    variable <- invalid_vars[[1L]]
    stop(
      "Variable \"", variable, "\" is ", .detect_type(data[[variable]]),
      ". `assess_variance()` is intended for continuous numeric variables only.",
      call. = FALSE
    )
  }

  group_summary <- function(variable, group_value) {
    index <- !is.na(data[[by_name]]) &
      as.character(data[[by_name]]) == group_value
    x <- data[[variable]][index]
    missing <- sum(is.na(x))
    non_finite <- sum(!is.na(x) & !is.finite(x))
    observed <- x[is.finite(x)]
    n <- length(observed)
    sd_value <- if (n >= 2L) stats::sd(observed) else NA_real_
    variance_value <- if (n >= 2L) stats::var(observed) else NA_real_
    status <- if (n == 0L) {
      "No finite observations"
    } else if (n == 1L) {
      "One finite observation"
    } else if (isTRUE(sd_value == 0)) {
      "Constant values"
    } else {
      "Available"
    }
    tibble::tibble(
      variable = variable,
      label = .get_var_label(data, variable),
      group = group_value,
      n = n,
      missing = missing,
      non_finite = non_finite,
      sd = sd_value,
      variance = variance_value,
      group_status = status
    )
  }

  summary_tbl <- dplyr::bind_rows(unlist(lapply(vars_names, function(variable) {
    lapply(group_values, group_summary, variable = variable)
  }), recursive = FALSE))

  diagnostics <- dplyr::bind_rows(lapply(vars_names, function(variable) {
    rows <- summary_tbl[summary_tbl$variable == variable, , drop = FALSE]
    estimable <- is.finite(rows$sd)
    positive <- estimable & rows$sd > 0
    status <- ""
    sd_ratio <- NA_real_
    variance_ratio <- NA_real_

    if (sum(estimable) < 2L) {
      status <- "Cannot compare spread: fewer than two groups have an estimable SD."
    } else if (all(rows$sd[estimable] == 0)) {
      sd_ratio <- 1
      variance_ratio <- 1
      status <- "All groups have zero observed spread. Review the variable coding."
    } else if (any(rows$sd[estimable] == 0)) {
      sd_ratio <- Inf
      variance_ratio <- Inf
      status <- "At least one group has zero observed spread. Review the variable coding and data."
    } else {
      sd_ratio <- max(rows$sd[positive]) / min(rows$sd[positive])
      variance_ratio <- max(rows$variance[positive]) / min(rows$variance[positive])
      status <- "Descriptive spread shown; Welch methods do not require equal variances."
    }

    if (any(rows$missing > 0L | rows$non_finite > 0L)) {
      status <- paste0(status, " Missing or non-finite values are excluded from SD and variance.")
    }
    bartlett <- if (identical(test, "bartlett")) {
      test_data <- data.frame(
        value = data[[variable]], group = data[[by_name]]
      )
      test_data <- test_data[stats::complete.cases(test_data) & is.finite(test_data$value), , drop = FALSE]
      tryCatch(stats::bartlett.test(value ~ as.factor(group), data = test_data), error = function(e) NULL)
    } else NULL
    tibble::tibble(
      variable = variable,
      label = .get_var_label(data, variable),
      sd_ratio = sd_ratio,
      variance_ratio = variance_ratio,
      bartlett_statistic = if (is.null(bartlett)) NA_real_ else unname(bartlett$statistic),
      bartlett_df = if (is.null(bartlett)) NA_real_ else unname(bartlett$parameter),
      bartlett_p = if (is.null(bartlett)) NA_real_ else bartlett$p.value,
      bartlett_status = if (!identical(test, "bartlett")) "Not requested" else if (is.null(bartlett)) "Not estimable" else "Supporting information",
      interpretation = status
    )
  }))

  summary_tbl <- dplyr::left_join(summary_tbl, diagnostics, by = c("variable", "label"))
  display_tbl <- summary_tbl
  display_tbl$label <- stats::ave(
    display_tbl$label, display_tbl$variable,
    FUN = function(x) c(x[[1L]], rep("", length(x) - 1L))
  )
  display_tbl$sd_ratio <- stats::ave(
    display_tbl$sd_ratio, display_tbl$variable,
    FUN = function(x) c(x[[1L]], rep(NA_real_, length(x) - 1L))
  )
  display_tbl$variance_ratio <- stats::ave(
    display_tbl$variance_ratio, display_tbl$variable,
    FUN = function(x) c(x[[1L]], rep(NA_real_, length(x) - 1L))
  )
  display_tbl$interpretation <- stats::ave(
    display_tbl$interpretation, display_tbl$variable,
    FUN = function(x) c(x[[1L]], rep("", length(x) - 1L))
  )
  for (column in c("bartlett_statistic", "bartlett_df", "bartlett_p", "bartlett_status")) {
    display_tbl[[column]] <- stats::ave(display_tbl[[column]], display_tbl$variable, FUN = function(x) c(x[[1L]], rep(NA, length(x) - 1L)))
  }

  display_cols <- c(
    "label", "group", "n",
    if (any(summary_tbl$missing > 0L)) "missing",
    if (any(summary_tbl$non_finite > 0L)) "non_finite",
    "sd", "variance", "sd_ratio", "variance_ratio", "interpretation"
    , if (identical(test, "bartlett")) c("bartlett_p", "bartlett_status")
  )
  table_tbl <- display_tbl[, display_cols, drop = FALSE]
  names(table_tbl) <- c(
    "Variable", "Group", "n",
    if (any(summary_tbl$missing > 0L)) "Missing",
    if (any(summary_tbl$non_finite > 0L)) "Non-finite",
    "SD", "Variance", "SD ratio", "Variance ratio", "Interpretation",
    if (identical(test, "bartlett")) c("Bartlett p", "Bartlett status")
  )
  for (column in intersect(c("SD", "Variance", "SD ratio", "Variance ratio"), names(table_tbl))) {
    table_tbl[[column]] <- vapply(table_tbl[[column]], function(value) {
      if (is.infinite(value)) return("Inf")
      .format_number(value, digits = digits)
    }, character(1))
  }

  if (identical(output, "tibble")) {
    attr(summary_tbl, "diagnostics") <- diagnostics
    return(summary_tbl)
  }

  result <- list(
    inputs = list(
      data_name = deparse(substitute(data)), vars = vars_names, by = by_name,
      digits = digits, test = test, output = output
    ),
    summary = summary_tbl,
    diagnostics = diagnostics,
    table = tibble::as_tibble(table_tbl),
    notes = c(
      ratios = "SD and variance ratios are the largest group value divided by the smallest group value. They describe observed spread; they are not pass/fail tests.",
      welch = "Welch t-tests and Welch ANOVA do not require equal variances. `assess_variance()` does not select an inferential test.",
      bartlett = if (identical(test, "bartlett")) "Bartlett's test is supporting information only: it assumes normal group distributions, and its p-value neither proves equal variances nor selects an inferential test." else NULL,
      review = "Interpret spread alongside sample size, distributional shape, outliers, missingness, and the study design."
    ),
    call = match.call()
  )
  class(result) <- c("gt_variance", "gtstats", "list")
  result
}
