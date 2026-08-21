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
#' default, and it does not choose an inferential test. Welch t-tests and Welch
#' ANOVA do not require equal variances for *independent* groups; this function
#' does not assess pairing, repeated-measures sphericity, or select a
#' repeated-measures method.
#' The default is the median-centred Levene test (often called the
#' Brown-Forsythe modification) as supporting information. It is less sensitive
#' to non-normality than Bartlett's test. Set `test = "none"` for descriptive
#' spread only, or `test = "bartlett"` when the normal-distribution assumption
#' is justified. Neither test is used to select a test in [compare_groups()].
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
#' @param test Variance hypothesis test to display: `"levene"` (default),
#'   `"none"`, or `"bartlett"`. Levene's test is median-centred (the robust
#'   Brown-Forsythe form). Both are supporting diagnostics, not gatekeepers for
#'   ANOVA or Welch methods.
#' @param format Output format: `"table"` (default) or `"tibble"`.
#' @param output Compatibility alias for `format`.
#'
#' @return With `format = "table"`, a `gt_variance` object that prints as one
#'   readable row per variable: each group's `n` and SD, the observed SD ratio,
#'   the requested test p-value, and a plain-language interpretation.
#'   `$summary` contains the full group-level values and `$diagnostics` retains
#'   technical test metadata. With `format = "tibble"`, the detailed summary
#'   tibble is returned.
#'
#' @examples
#' assess_variance(mtcars, vars = c(mpg, wt), by = am)
#' assess_variance(mtcars, vars = "mpg", by = am, digits = 1)
#' assess_variance(mtcars, vars = "mpg", by = am, test = "bartlett")
#' assess_variance(mtcars, vars = "mpg", by = am, test = "levene")
#'
#' @export
assess_variance <- function(
    data,
    vars = NULL,
    by,
    digits = 2,
    test = c("levene", "none", "bartlett"),
    format = c("table", "tibble"),
    output = NULL
) {
  if (!is.null(output)) {
    format <- output
  }
  format <- match.arg(format, c("table", "tibble"))
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
  group_values <- if (is.factor(data[[by_name]])) {
    levels(droplevels(data[[by_name]]))
  } else {
    unique(as.character(data[[by_name]][!is.na(data[[by_name]])]))
  }
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
      status <- "Descriptive spread shown; interpret it in the context of the study design."
    }

    if (any(rows$missing > 0L | rows$non_finite > 0L)) {
      status <- paste0(status, " Missing or non-finite values are excluded from SD and variance.")
    }
    test_data <- data.frame(value = data[[variable]], group = data[[by_name]])
    test_data <- test_data[
      stats::complete.cases(test_data) & is.finite(test_data$value),
      , drop = FALSE
    ]
    bartlett <- if (identical(test, "bartlett")) {
      tryCatch(stats::bartlett.test(value ~ as.factor(group), data = test_data), error = function(e) NULL)
    } else NULL
    levene <- if (identical(test, "levene")) {
      tryCatch({
        test_data$group <- droplevels(as.factor(test_data$group))
        group_n <- table(test_data$group)
        if (length(group_n) < 2L || any(group_n < 2L)) {
          NULL
        } else {
          centres <- stats::setNames(
            vapply(split(test_data$value, test_data$group), stats::median, numeric(1)),
            levels(test_data$group)
          )
          test_data$absolute_deviation <- abs(
            test_data$value - unname(centres[as.character(test_data$group)])
          )
          deviation_variance <- stats::var(test_data$absolute_deviation)
          if (!is.finite(deviation_variance) || deviation_variance == 0) {
            NULL
          } else {
            fit <- stats::lm(absolute_deviation ~ group, data = test_data)
            anova_row <- stats::anova(fit)[1L, , drop = FALSE]
            list(
              statistic = unname(anova_row[["F value"]]),
              df1 = unname(anova_row[["Df"]]),
              df2 = unname(stats::df.residual(fit)),
              p.value = unname(anova_row[["Pr(>F)"]])
            )
          }
        }
      }, error = function(e) NULL)
    } else NULL
    interpretation <- status
    if (identical(status, "Descriptive spread shown; interpret it in the context of the study design.")) {
      interpretation <- if (identical(test, "levene")) {
        if (is.null(levene)) {
          "Levene test is not estimable; review group sizes and variation."
        } else if (levene$p.value < 0.05) {
          "Levene suggests different spreads; interpret this with the study design."
        } else {
          "Levene found no clear evidence of different spreads; this does not prove equal variances."
        }
      } else if (identical(test, "bartlett")) {
        if (is.null(bartlett)) {
          "Bartlett's test is not estimable; review group sizes and variation."
        } else if (bartlett$p.value < 0.05) {
          "Bartlett's test suggests different spreads; interpret this with the study design."
        } else {
          "Bartlett's test found no clear evidence of different spreads; this does not prove equal variances."
        }
      } else {
        "Observed SD ratio shown; interpret it with the study design."
      }
    }
    if (any(rows$missing > 0L | rows$non_finite > 0L)) {
      interpretation <- paste0(interpretation, " Some values were excluded.")
    }
    tibble::tibble(
      variable = variable,
      label = .get_var_label(data, variable),
      sd_ratio = sd_ratio,
      variance_ratio = variance_ratio,
      bartlett_statistic = if (is.null(bartlett)) NA_real_ else unname(bartlett$statistic),
      bartlett_df = if (is.null(bartlett)) NA_real_ else unname(bartlett$parameter),
      bartlett_p = if (is.null(bartlett)) NA_real_ else bartlett$p.value,
      bartlett_status = if (!identical(test, "bartlett")) "Not requested" else if (is.null(bartlett)) "Not estimable" else "Supporting information",
      levene_statistic = if (is.null(levene)) NA_real_ else levene$statistic,
      levene_df1 = if (is.null(levene)) NA_real_ else levene$df1,
      levene_df2 = if (is.null(levene)) NA_real_ else levene$df2,
      levene_p = if (is.null(levene)) NA_real_ else levene$p.value,
      levene_status = if (!identical(test, "levene")) "Not requested" else if (is.null(levene)) "Not estimable" else "Supporting information",
      interpretation = interpretation
    )
  }))

  summary_tbl <- dplyr::left_join(summary_tbl, diagnostics, by = c("variable", "label"))
  # The printed table is intentionally one row per variable. Each group cell
  # retains n, SD, and variance so the evidence is visible without requiring
  # users to inspect an internal component.
  group_headers <- vapply(group_values, .display_level, character(1))
  group_headers <- make.unique(group_headers, sep = " ")
  variable_rows <- lapply(vars_names, function(variable) {
    rows <- summary_tbl[summary_tbl$variable == variable, , drop = FALSE]
    diagnostic <- diagnostics[diagnostics$variable == variable, , drop = FALSE]
    out <- list(Variable = .get_var_label(data, variable))
    for (i in seq_along(group_values)) {
      group_value <- group_values[[i]]
      row <- rows[rows$group == group_value, , drop = FALSE]
      excluded <- row$missing + row$non_finite
      out[[group_headers[[i]]]] <- if (row$n == 0L) {
        "No finite observations"
      } else if (!is.finite(row$sd)) {
        paste0("n = ", row$n, "; SD not estimable")
      } else {
        paste0(
          "n = ", row$n, "; SD = ", .format_number(row$sd, digits = digits),
          "; variance = ", .format_number(row$variance, digits = digits),
          if (excluded > 0L) paste0(" (", excluded, " excluded)") else ""
        )
      }
    }
    out[["Observed SD ratio"]] <- if (is.infinite(diagnostic$sd_ratio)) {
      "Not estimable"
    } else {
      .format_number(diagnostic$sd_ratio, digits = digits)
    }
    out[["Observed variance ratio"]] <- if (is.infinite(diagnostic$variance_ratio)) {
      "Not estimable"
    } else {
      .format_number(diagnostic$variance_ratio, digits = digits)
    }
    if (!identical(test, "none")) {
      p_value <- if (identical(test, "levene")) diagnostic$levene_p else diagnostic$bartlett_p
      out[[paste0(if (identical(test, "levene")) "Levene" else "Bartlett", " p")]] <-
        if (is.finite(p_value)) .format_p_value(p_value, digits = 3L) else "Not estimable"
    }
    out[["Interpretation"]] <- diagnostic$interpretation
    as.data.frame(out, stringsAsFactors = FALSE, check.names = FALSE)
  })
  table_tbl <- tibble::as_tibble(dplyr::bind_rows(variable_rows))

  if (identical(format, "tibble")) {
    attr(summary_tbl, "diagnostics") <- diagnostics
    return(summary_tbl)
  }

  result <- list(
    inputs = list(
      data_name = deparse(substitute(data)), vars = vars_names, by = by_name,
      digits = digits, test = test, format = format
    ),
    summary = summary_tbl,
    diagnostics = diagnostics,
    table = tibble::as_tibble(table_tbl),
    notes = c(
      ratios = "SD and variance ratios are the largest group value divided by the smallest group value. They describe observed spread; they are not pass/fail tests.",
      welch = "For independent groups, Welch t-tests and Welch ANOVA do not require equal variances. `assess_variance()` does not select an inferential test and does not assess pairing or repeated-measures sphericity.",
      bartlett = if (identical(test, "bartlett")) "Bartlett's test is supporting information only: it assumes normal group distributions, and its p-value neither proves equal variances nor selects an inferential test." else NULL,
      levene = if (identical(test, "levene")) "The displayed Levene test is median-centred (Brown-Forsythe). It is supporting information only: its p-value neither proves equal variances nor selects an inferential test." else NULL,
      review = "Interpret spread alongside sample size, distributional shape, outliers, missingness, and the study design."
    ),
    call = match.call()
  )
  class(result) <- c("gt_variance", "gtstats", "list")
  result
}
