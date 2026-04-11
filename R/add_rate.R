#' Add a rate row to a descriptive table
#'
#' Add a rate row to a `gtstats` descriptive table using event counts and
#' denominators, with optional exact Poisson confidence intervals.
#'
#' This helper is intended for rate-style descriptive tables, for example
#' incidence rates, event rates, or counts per population/person-time. Rates
#' may be displayed overall, by groups, or both, depending on how the
#' descriptive table was created.
#'
#' Confidence intervals are calculated using an exact Poisson method based on
#' the chi-squared distribution.
#'
#' This helper should not be combined with summary-style components such as
#' `add_summary()`, `add_proportion()`, `add_total()`, or `add_p()` in the same
#' descriptive table.
#'
#' @param x A `gt_desc_table` object created with [descriptive_table()].
#' @param events Event count variable. Can be supplied as a bare name or as a
#'   character string.
#' @param denom Denominator variable. Can be supplied as a bare name or as a
#'   character string.
#' @param label Row label to display. Defaults to `"Rate (per <multiplier>)"`.
#' @param multiplier Multiplier used to scale the rate, for example `1000` or
#'   `100000`.
#' @param ci Logical; whether to display an exact Poisson confidence interval.
#' @param conf.level Confidence level for the interval. Default is `0.95`.
#' @param digits Number of decimal places used when formatting rates.
#'
#' @return An updated `gt_desc_table` object with a rate row appended.
#'
#' @examples
#' descriptive_table(mtcars, by = am, overall = TRUE) |>
#'   add_rate(
#'     events = carb,
#'     denom = cyl,
#'     label = "Carburettor rate",
#'     multiplier = 1000
#'   )
#'
#' descriptive_table(mtcars) |>
#'   add_rate(
#'     events = carb,
#'     denom = cyl,
#'     multiplier = 1000,
#'     ci = FALSE
#'   )
#'
#' @export
add_rate <- function(
    x,
    events,
    denom,
    label = paste0("Rate (per ", multiplier, ")"),
    multiplier = 100000,
    ci = TRUE,
    conf.level = 0.95,
    digits = 1
) {
  # Validate table object and prevent mixing rate rows with summary-style rows
  if (!inherits(x, "gt_desc_table")) {
    stop("`x` must be a `gt_desc_table` object.", call. = FALSE)
  }

  if (any(x$components %in% c("summary", "proportion", "total", "p_value"))) {
    stop(
      paste0(
        "`add_rate()` cannot be combined with summary/proportion/total/",
        "p-value components in the same descriptive table."
      ),
      call. = FALSE
    )
  }

  # Validate numerical arguments used in formatting and interval calculation
  if (!is.numeric(multiplier) || length(multiplier) != 1 ||
      is.na(multiplier) || multiplier <= 0) {
    stop("`multiplier` must be a single positive number.", call. = FALSE)
  }

  if (!is.numeric(conf.level) || length(conf.level) != 1 ||
      is.na(conf.level) || conf.level <= 0 || conf.level >= 1) {
    stop(
      "`conf.level` must be a single number between 0 and 1.",
      call. = FALSE
    )
  }

  if (!is.numeric(digits) || length(digits) != 1 ||
      is.na(digits) || digits < 0) {
    stop("`digits` must be a single non-negative number.", call. = FALSE)
  }

  # Resolve variable names from either bare names or character input
  events_expr <- substitute(events)
  denom_expr <- substitute(denom)

  resolve_name <- function(expr) {
    if (is.symbol(expr)) {
      deparse(expr)
    } else {
      expr_eval <- tryCatch(eval(expr, parent.frame()),
                            error = function(e) NULL)
      if (is.character(expr_eval) && length(expr_eval) == 1) {
        expr_eval
      } else {
        deparse(expr)
      }
    }
  }

  events_name <- resolve_name(events_expr)
  denom_name <- resolve_name(denom_expr)

  if (!events_name %in% names(x$data)) {
    stop("`events` was not found in the data.", call. = FALSE)
  }

  if (!denom_name %in% names(x$data)) {
    stop("`denom` was not found in the data.", call. = FALSE)
  }

  # Ensure both variables are numeric before computing rates
  events_var <- x$data[[events_name]]
  denom_var <- x$data[[denom_name]]

  if (!is.numeric(events_var)) {
    stop("`events` must be numeric.", call. = FALSE)
  }

  if (!is.numeric(denom_var)) {
    stop("`denom` must be numeric.", call. = FALSE)
  }

  # Helper to format numeric values consistently
  .fmt_num <- function(z, digits = 1) {
    ifelse(
      is.na(z),
      NA_character_,
      sprintf(paste0("%.", digits, "f"), z)
    )
  }

  # Exact Poisson interval for the event count
  .poisson_ci <- function(events, conf.level = 0.95) {
    alpha <- 1 - conf.level

    if (is.na(events) || events < 0) {
      return(c(NA_real_, NA_real_))
    }

    lower <- if (events == 0) {
      0
    } else {
      0.5 * stats::qchisq(alpha / 2, df = 2 * events)
    }

    upper <- 0.5 * stats::qchisq(1 - alpha / 2, df = 2 * (events + 1))

    c(lower, upper)
  }

  # Build the final display string for one rate cell
  .make_rate_display <- function(events,
                                 denom,
                                 multiplier,
                                 ci,
                                 conf.level,
                                 digits) {
    if (is.na(events) || is.na(denom) || denom <= 0) {
      return(NA_character_)
    }

    rate <- (events / denom) * multiplier

    if (!ci) {
      return(.fmt_num(rate, digits))
    }

    ci_events <- .poisson_ci(events, conf.level = conf.level)
    low <- (ci_events[1] / denom) * multiplier
    high <- (ci_events[2] / denom) * multiplier

    paste0(
      .fmt_num(rate, digits), " (",
      .fmt_num(low, digits), "\u2013",
      .fmt_num(high, digits), ")"
    )
  }

  # Start the new row
  row_tbl <- tibble::tibble(
    Variable = label,
    Level = ""
  )

  # Add overall rate if the descriptive table includes an Overall column
  if (isTRUE(x$overall)) {
    total_events <- sum(events_var, na.rm = TRUE)
    total_denom <- sum(denom_var, na.rm = TRUE)

    row_tbl$Overall <- .make_rate_display(
      events = total_events,
      denom = total_denom,
      multiplier = multiplier,
      ci = ci,
      conf.level = conf.level,
      digits = digits
    )
  }

  # Add group-specific rates if the descriptive table is grouped
  if (!is.null(x$by)) {
    by_var <- x$data[[x$by]]
    group_values <- unique(by_var)
    group_values <- group_values[!is.na(group_values)]
    group_values_chr <- as.character(group_values)
    group_labels <- paste0(x$by, " = ", group_values_chr)
    names(group_labels) <- group_values_chr

    for (g in group_values_chr) {
      idx <- !is.na(by_var) & as.character(by_var) == g

      events_g <- sum(events_var[idx], na.rm = TRUE)
      denom_g <- sum(denom_var[idx], na.rm = TRUE)

      row_tbl[[group_labels[[g]]]] <- .make_rate_display(
        events = events_g,
        denom = denom_g,
        multiplier = multiplier,
        ci = ci,
        conf.level = conf.level,
        digits = digits
      )
    }
  } else if (!isTRUE(x$overall)) {
    # Use a single Value column when neither grouping nor overall is used
    total_events <- sum(events_var, na.rm = TRUE)
    total_denom <- sum(denom_var, na.rm = TRUE)

    row_tbl$Value <- .make_rate_display(
      events = total_events,
      denom = total_denom,
      multiplier = multiplier,
      ci = ci,
      conf.level = conf.level,
      digits = digits
    )
  }

  row_tbl <- tibble::as_tibble(row_tbl)

  # Align the new row to the current table structure before appending
  if (is.null(x$table)) {
    x$table <- row_tbl
  } else {
    missing_cols <- setdiff(names(x$table), names(row_tbl))
    for (col in missing_cols) {
      row_tbl[[col]] <- ""
    }

    extra_cols <- setdiff(names(row_tbl), names(x$table))
    for (col in extra_cols) {
      x$table[[col]] <- ""
    }

    row_tbl <- row_tbl[, names(x$table), drop = FALSE]
    x$table <- dplyr::bind_rows(x$table, row_tbl)
  }

  # Record component type and explanatory footnote
  x$components <- unique(c(x$components, "rate"))

  rate_note <- if (ci) {
    paste0(
      "Rates are shown per ",
      format(multiplier, scientific = FALSE, trim = TRUE),
      " with ",
      round(conf.level * 100),
      "% exact Poisson confidence intervals."
    )
  } else {
    paste0(
      "Rates are shown per ",
      format(multiplier, scientific = FALSE, trim = TRUE),
      "."
    )
  }

  x$footnotes <- unique(c(x$footnotes, rate_note))

  x
}
