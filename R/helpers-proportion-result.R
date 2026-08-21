#' Calculate proportion with confidence interval
#'
#' Calculate the proportion of a selected level of a binary,
#' categorical, or ordinal variable, with optional grouping and exact
#' binomial confidence intervals.
#'
#' This function is useful for simple epidemiological summaries and for
#' quickly reporting the proportion of a target category such as `"1"`,
#' `"Yes"`, or `"TRUE"`. If `level = NULL`, a default level is chosen
#' automatically using a simple priority rule.
#'
#' When a grouping variable is supplied, proportions are calculated
#' separately within each group. Confidence intervals are calculated
#' using Wilson intervals by default, with exact binomial intervals available.
#'
#' @param data A data.frame.
#' @param var Variable to summarise as a proportion. Can be supplied as
#'   a bare name or as a character string.
#' @param by Optional grouping variable. Can be supplied as a bare name
#'   or as a character string.
#' @param level Optional level to count. If `NULL`, the function will
#'   try to use `"1"`, `"Yes"`, `"TRUE"`, or the second available
#'   level.
#' @param conf.level Confidence level for the interval. Default is
#'   `0.95`.
#' @param ci_method Confidence-interval method.
#' @param display Estimate display: event count and percentage (`"n_percent"`),
#'   percentage only (`"percent"`), or event count over denominator and
#'   percentage (`"n_over_N_percent"`). The confidence interval is displayed
#'   in a separate publication-table column.
#' @param digits Number of decimal places used when formatting percentages.
#'
#' @return A `gt_prop` object containing:
#' \itemize{
#'   \item `inputs` — function inputs and settings
#'   \item `summary` — detailed summary table
#'   \item `table` — display-ready table
#'   \item `notes` — explanatory note
#'   \item `call` — matched function call
#' }
#'
#' @examples
#' .proportion_result(mtcars, var = vs)
#'
#' .proportion_result(mtcars, var = vs, by = am)
#'
#' .proportion_result(mtcars, var = vs, by = am, level = "1")
#'
#' tbl_stats(.proportion_result(mtcars, var = vs, by = am))
#'
#' @keywords internal
#' @noRd
.proportion_result <- function(
    data,
    var,
    by = NULL,
    level = NULL,
    conf.level = 0.95,
    ci_method = c("wilson", "exact"),
    display = c("n_percent", "percent", "n_over_N_percent"),
    digits = 1
) {
  ci_method <- match.arg(ci_method)
  display <- match.arg(display)
  .validate_conf_level(conf.level)
  .validate_digits(digits)

  # Validate input data
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }

  # Resolve bare or character variable names
  resolve_name <- function(expr) {
    if (is.symbol(expr)) {
      deparse(expr)
    } else {
      expr_eval <- tryCatch(
        eval(expr, parent.frame()),
        error = function(e) NULL
      )

      if (is.character(expr_eval) && length(expr_eval) == 1) {
        expr_eval
      } else {
        deparse(expr)
      }
    }
  }

  var_expr <- substitute(var)
  by_expr <- substitute(by)

  var_name <- resolve_name(var_expr)

  if (identical(by_expr, NULL)) {
    by_name <- NULL
  } else {
    by_eval <- tryCatch(
      eval(by_expr, parent.frame()),
      error = function(e) NULL
    )

    if (is.character(by_eval) && length(by_eval) == 1) {
      by_name <- by_eval
    } else if (is.symbol(by_expr)) {
      by_name <- deparse(by_expr)
    } else {
      by_name <- deparse(by_expr)
    }
  }

  if (!var_name %in% names(data)) {
    stop("`var` was not found in `data`.", call. = FALSE)
  }

  if (!is.null(by_name) && !by_name %in% names(data)) {
    stop("`by` was not found in `data`.", call. = FALSE)
  }

  # Restrict analysis to variables where proportions are meaningful
  v <- data[[var_name]]
  v_type <- .detect_type(v)

  if (!v_type %in% c("binary", "categorical", "ordinal")) {
    stop(
      paste0(
        "`proportion_stats()` currently supports binary, categorical, ",
        "or ordinal variables."
      ),
      call. = FALSE
    )
  }

  # Validate grouping variable when supplied
  if (!is.null(by_name)) {
    by_type <- .detect_type(data[[by_name]])

    if (by_type == "continuous") {
      stop(
        paste0(
          "`by` should be a categorical, binary, or ordinal ",
          "grouping variable."
        ),
        call. = FALSE
      )
    }
  }

  v_chr <- as.character(v)
  level <- .select_target_level(v_chr, level)
  estimate_label <- switch(
    display,
    n_percent = "n (%)",
    percent = "%",
    n_over_N_percent = "n/N (%)"
  )

  # Build one summary row for one group or for the overall sample
  .make_row <- function(
    group_label,
    x_chr,
    level,
    conf.level,
    digits
  ) {
    total <- sum(!is.na(x_chr))
    successes <- sum(x_chr == level, na.rm = TRUE)
    prop <- if (total > 0) {
      100 * successes / total
    } else {
      NA_real_
    }

    prop_result <- .proportion_summary(
      x_chr,
      level = level,
      conf.level = conf.level,
      method = ci_method
    )
    low <- 100 * prop_result$conf_low
    high <- 100 * prop_result$conf_high
    display_value <- .format_proportion_display(
      prop_result,
      display = display,
      digits = digits,
      ci = FALSE
    )
    ci_value <- if (is.na(low) || is.na(high)) {
      NA_character_
    } else {
      paste0(.format_ci(low, high, digits = digits), "%")
    }

    tibble::tibble(
      variable = var_name,
      label = .get_var_label(data, var_name),
      level = level,
      group = group_label,
      n = total,
      count = successes,
      proportion = prop,
      conf_low = low,
      conf_high = high,
      display = display_value,
      ci_display = ci_value
    )
  }

  # Build overall or grouped summary output
  if (is.null(by_name)) {
    summary_tbl <- .make_row(
      group_label = "Overall",
      x_chr = v_chr,
      level = level,
      conf.level = conf.level,
      digits = digits
    )

    table_tbl <- tibble::tibble(
      Event = level,
      estimate = summary_tbl$display,
      `95% CI` = summary_tbl$ci_display
    )
    names(table_tbl)[[2L]] <- estimate_label
    names(table_tbl)[[3L]] <- .conf_level_label(conf.level)
    display_columns <- tibble::tibble(
      group = "Overall",
      estimate = estimate_label,
      estimate_label = estimate_label,
      ci = .conf_level_label(conf.level)
    )
  } else {
    by_var <- data[[by_name]]
    observed_groups <- unique(as.character(stats::na.omit(by_var)))
    group_values_chr <- if (is.factor(by_var)) {
      levels(by_var)[levels(by_var) %in% observed_groups]
    } else {
      observed_groups
    }

    summary_list <- lapply(group_values_chr, function(g) {
      idx <- !is.na(by_var) & as.character(by_var) == g

      .make_row(
        group_label = g,
        x_chr = v_chr[idx],
        level = level,
        conf.level = conf.level,
        digits = digits
      )
    })

    summary_tbl <- dplyr::bind_rows(summary_list)

    table_tbl <- tibble::tibble(Event = level)
    display_columns <- vector("list", nrow(summary_tbl))
    for (i in seq_len(nrow(summary_tbl))) {
      estimate_col <- paste0("group_", i, "_estimate")
      ci_col <- paste0("group_", i, "_ci")
      table_tbl[[estimate_col]] <- summary_tbl$display[[i]]
      table_tbl[[ci_col]] <- summary_tbl$ci_display[[i]]
      display_columns[[i]] <- tibble::tibble(
        group = summary_tbl$group[[i]],
        estimate = estimate_col,
        estimate_label = estimate_label,
        ci = ci_col
      )
    }
    display_columns <- dplyr::bind_rows(display_columns)
  }

  denominator_audit <- .data_denominators(
    data,
    var_name,
    by = by_name,
    rule = paste0("Non-missing observations; event level = ", level)
  )
  denominator_audit$numerator <- summary_tbl$count[
    match(denominator_audit$group, summary_tbl$group)
  ]

  result <- list(
    inputs = list(
      data_name = deparse(substitute(data)),
      var = var_name,
      by = by_name,
      level = level,
      conf.level = conf.level,
      ci_method = ci_method,
      display = display,
      digits = digits
    ),
    summary = summary_tbl,
    table = table_tbl,
    method = list(
      estimate = "Proportion",
      interval = if (identical(ci_method, "wilson")) {
        "Wilson score"
      } else {
        "Exact binomial"
      },
      display_columns = display_columns,
      comparison_test = NULL
    ),
    assumptions = .assumptions_tbl(
      assumption = c(
        "Appropriate denominator",
        "Independent observations",
        "Mutually exclusive outcome level"
      ),
      status = c("user_check", "user_check", "partly_checked"),
      result = c("not_checked", "not_checked", "level_validated"),
      detail = c(
        "Confirm that non-missing observations define the intended population at risk.",
        "Confirm from the study design that observations are independent.",
        "The selected level was validated against observed outcome levels."
      )
    ),
    diagnostics = .diagnostics_tbl(
      check = "Non-missing denominator",
      result = "reported",
      value = paste(summary_tbl$n, collapse = "; "),
      threshold = "Greater than 0",
      detail = "Denominators are reported for every displayed group."
    ),
    denominators = denominator_audit,
    notes = c(
      paste0(
        "Selected event: ",
        .get_var_label(data, var_name),
        " = ",
        level,
        ". Estimates use ",
        if (identical(ci_method, "wilson")) "Wilson score" else "exact binomial",
        " ",
        round(conf.level * 100),
        "% confidence intervals."
      ),
      "This function estimates a proportion; it does not test differences between groups.",
      "The denominator must define the population at risk, and observations should be independent."
    ),
    call = match.call()
  )

  class(result) <- c("gt_prop", "gtstats", "list")
  result
}
