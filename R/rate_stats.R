#' Incidence rate with exact Poisson confidence interval
#'
#' Compute an incidence or event rate with exact Poisson confidence
#' intervals, either overall or within groups defined by a categorical
#' variable.
#'
#' This function is designed for simple epidemiological summaries where
#' events are counted over a denominator of person-time. The `event`
#' variable may be a binary indicator, a logical variable, or a count
#' variable. The `time` variable must be numeric, finite, and non-negative.
#' A zero accumulated person-time denominator is retained and clearly marked as
#' not estimable rather than silently converted to a rate.
#'
#' When a grouping variable is supplied, rates are calculated
#' separately within each group. Confidence intervals are calculated
#' using [stats::poisson.test()].
#' The publication table uses each group as a spanning header, with separate
#' columns for events, accumulated time, rate, and confidence interval. The
#' tidy long-form numerical results remain available in `$summary`.
#'
#' @param data A data.frame.
#' @param event Event variable. Can be supplied as a bare name or as a
#'   character string. May be binary (`0/1`, `TRUE/FALSE`) or a count
#'   variable.
#' @param time Person-time variable. Can be supplied as a bare name or
#'   as a character string. Must be numeric and non-negative.
#' @param by Optional grouping variable. Can be supplied as a bare name
#'   or as a character string.
#' @param multiplier Numeric multiplier used to scale the rate, for
#'   example `1000` or `100000`. Default is `1000`.
#' @param time_label Optional readable unit for accumulated time, such as
#'   `"person-years"` or `"catheter-days"`. Defaults to `"person-time"`.
#' @param conf.level Confidence level for the interval. Default is
#'   `0.95`.
#' @param digits Number of decimal places used when formatting rates.
#'   Default is `1`.
#' @param format Output format: `"table"` (default) or a plain console
#'   `"tibble"`.
#'
#' @return A `gt_rate` object containing:
#' \itemize{
#'   \item `inputs` — function inputs and settings
#'   \item `summary` — detailed summary table
#'   \item `table` — display-ready table
#'   \item `notes` — explanatory note
#'   \item `call` — matched function call
#' }
#'
#' @examples
#' df <- data.frame(
#'   event = c(1, 0, 1, 0, 1, 1),
#'   ptime = c(10, 12, 8, 9, 11, 7),
#'   arm = c("A", "A", "A", "B", "B", "B")
#' )
#'
#' rate_stats(df, event = event, time = ptime)
#'
#' rate_stats(df, event = event, time = ptime, by = arm)
#'
#' to_gt(rate_stats(df, event = event, time = ptime, by = arm))
#'
#' @export
rate_stats <- function(
    data,
    event,
    time,
    by = NULL,
    multiplier = 1000,
    time_label = NULL,
    conf.level = 0.95,
    digits = 1,
    format = c("table", "tibble")
) {
  format <- match.arg(format)
  # Validate input data
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
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

  event_expr <- substitute(event)
  time_expr <- substitute(time)
  by_expr <- substitute(by)

  event_name <- resolve_name(event_expr)
  time_name <- resolve_name(time_expr)

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

  # Check that requested variables exist
  vars_needed <- c(event_name, time_name, by_name)
  vars_needed <- vars_needed[!is.na(vars_needed) & !is.null(vars_needed)]

  missing_vars <- setdiff(vars_needed, names(data))

  if (length(missing_vars) > 0) {
    stop(
      paste0(
        "Variable(s) not found in `data`: ",
        paste(missing_vars, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  # Keep complete cases only
  df <- data[, vars_needed, drop = FALSE]
  df <- stats::na.omit(df)

  if (nrow(df) == 0) {
    stop(
      "No complete cases available after removing missing values.",
      call. = FALSE
    )
  }

  # Validate event variable
  if (!is.numeric(df[[event_name]]) &&
      !is.logical(df[[event_name]])) {
    stop("`event` must be numeric or logical.", call. = FALSE)
  }

  if (is.logical(df[[event_name]])) {
    df[[event_name]] <- as.numeric(df[[event_name]])
  }

  if (any(!is.finite(df[[event_name]]))) {
    stop("`event` must contain finite values.", call. = FALSE)
  }

  if (any(df[[event_name]] < 0, na.rm = TRUE)) {
    stop("`event` must not contain negative values.", call. = FALSE)
  }
  if (any(
    abs(df[[event_name]] - round(df[[event_name]])) >
      sqrt(.Machine$double.eps),
    na.rm = TRUE
  )) {
    stop("`event` must contain non-negative integer counts.", call. = FALSE)
  }

  # Validate person-time variable
  if (!is.numeric(df[[time_name]])) {
    stop("`time` must be numeric.", call. = FALSE)
  }

  if (any(!is.finite(df[[time_name]]))) {
    stop("`time` must contain finite values.", call. = FALSE)
  }

  if (any(df[[time_name]] < 0, na.rm = TRUE)) {
    stop("`time` must not contain negative values.", call. = FALSE)
  }

  # Validate grouping variable when supplied
  if (!is.null(by_name)) {
    by_type <- .detect_type(df[[by_name]])

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

  # Validate formatting and interval arguments
  if (!is.numeric(multiplier) ||
      length(multiplier) != 1 ||
      is.na(multiplier) ||
      multiplier <= 0) {
    stop(
      "`multiplier` must be a single positive number.",
      call. = FALSE
    )
  }
  if (!is.null(time_label) &&
      (!is.character(time_label) || length(time_label) != 1L ||
       is.na(time_label) || !nzchar(time_label))) {
    stop("`time_label` must be NULL or one non-empty string.", call. = FALSE)
  }
  display_time_label <- time_label %||% "person-time"

  .validate_conf_level(conf.level)
  .validate_digits(digits)

  # Helper to format numeric values
  .fmt_num <- function(x, digits = 1) {
    .format_number(x, digits)
  }

  # Build one summary row for one group or for the overall sample
  .make_rate_row <- function(group_label, events, person_time, n_obs) {
    rate_result <- .poisson_rate_summary(
      events = events,
      person_time = person_time,
      multiplier = multiplier,
      conf.level = conf.level
    )
    rate_est <- rate_result$rate
    rate_low <- rate_result$conf_low
    rate_high <- rate_result$conf_high
    display <- .format_rate_summary(rate_result, digits = digits, ci = FALSE)
    ci_display <- if (is.na(rate_low) || is.na(rate_high)) {
      NA_character_
    } else {
      .format_ci(rate_low, rate_high, digits = digits)
    }

    tibble::tibble(
      variable = event_name,
      label = .get_var_label(data, event_name),
      time_var = time_name,
      group = group_label,
      n = n_obs,
      events = events,
      person_time = person_time,
      rate = rate_est,
      conf_low = rate_low,
      conf_high = rate_high,
      display = display,
      ci_display = ci_display
    )
  }

  # Build overall or grouped summaries
  if (is.null(by_name)) {
    total_events <- sum(df[[event_name]], na.rm = TRUE)
    total_time <- sum(df[[time_name]], na.rm = TRUE)

    summary_tbl <- .make_rate_row(
      group_label = "Overall",
      events = total_events,
      person_time = total_time,
      n_obs = nrow(df)
    )

    table_tbl <- tibble::tibble(
      Event = .get_var_label(data, event_name),
      Events = summary_tbl$events
    )
    table_tbl[[.sentence_case(display_time_label)]] <- summary_tbl$person_time
    rate_label <- paste0(
      "Rate per ",
      format(multiplier, scientific = FALSE, trim = TRUE, big.mark = ",")
    )
    table_tbl[[rate_label]] <- summary_tbl$display
    table_tbl[[.conf_level_label(conf.level)]] <- summary_tbl$ci_display
    display_columns <- tibble::tibble(
      group = "Overall",
      events = "Events",
      time = .sentence_case(display_time_label),
      rate = rate_label,
      ci = .conf_level_label(conf.level)
    )
  } else {
    observed_groups <- unique(as.character(stats::na.omit(df[[by_name]])))
    group_values_chr <- if (is.factor(data[[by_name]])) {
      levels(data[[by_name]])[levels(data[[by_name]]) %in% observed_groups]
    } else {
      observed_groups
    }

    summary_list <- lapply(group_values_chr, function(g) {
      idx <- as.character(df[[by_name]]) == g

      .make_rate_row(
        group_label = g,
        events = sum(df[[event_name]][idx], na.rm = TRUE),
        person_time = sum(df[[time_name]][idx], na.rm = TRUE),
        n_obs = sum(idx)
      )
    })

    summary_tbl <- dplyr::bind_rows(summary_list)

    rate_label <- paste0(
      "Rate per ",
      format(multiplier, scientific = FALSE, trim = TRUE, big.mark = ",")
    )
    table_tbl <- tibble::tibble(Event = .get_var_label(data, event_name))
    display_columns <- vector("list", nrow(summary_tbl))
    for (i in seq_len(nrow(summary_tbl))) {
      event_col <- paste0("group_", i, "_events")
      time_col <- paste0("group_", i, "_time")
      rate_col <- paste0("group_", i, "_rate")
      ci_col <- paste0("group_", i, "_ci")
      table_tbl[[event_col]] <- summary_tbl$events[[i]]
      table_tbl[[time_col]] <- summary_tbl$person_time[[i]]
      table_tbl[[rate_col]] <- summary_tbl$display[[i]]
      table_tbl[[ci_col]] <- summary_tbl$ci_display[[i]]
      display_columns[[i]] <- tibble::tibble(
        group = summary_tbl$group[[i]],
        events = event_col,
        time = time_col,
        rate = rate_col,
        ci = ci_col
      )
    }
    display_columns <- dplyr::bind_rows(display_columns)
  }

  audit_groups <- if (is.null(by_name)) {
    list(Overall = rep(TRUE, nrow(data)))
  } else {
    observed_groups <- unique(as.character(stats::na.omit(data[[by_name]])))
    if (is.factor(data[[by_name]])) {
      observed_groups <- levels(data[[by_name]])[
        levels(data[[by_name]]) %in% observed_groups
      ]
    }
    stats::setNames(
      lapply(
        observed_groups,
        function(g) !is.na(data[[by_name]]) &
          as.character(data[[by_name]]) == g
      ),
      observed_groups
    )
  }
  denominator_audit <- dplyr::bind_rows(lapply(
    names(audit_groups),
    function(group_label) {
      idx <- audit_groups[[group_label]]
      complete <- !is.na(data[[event_name]][idx]) &
        !is.na(data[[time_name]][idx])
      summary_row <- summary_tbl[summary_tbl$group == group_label, ]
      .denominators_tbl(
        variable = event_name,
        group = group_label,
        n_total = sum(idx),
        n_nonmissing = sum(complete),
        n_missing = sum(!complete),
        numerator = summary_row$events,
        denominator = summary_row$person_time,
        rule = paste0("Accumulated person-time; rate per ", multiplier)
      )
    }
  ))

  result <- list(
    inputs = list(
      data_name = deparse(substitute(data)),
      event = event_name,
      time = time_name,
      by = by_name,
      multiplier = multiplier,
      time_label = display_time_label,
      conf.level = conf.level,
      digits = digits
    ),
    summary = summary_tbl,
    table = table_tbl,
    method = list(
      estimate = "Event rate",
      interval = "Exact Poisson",
      multiplier = multiplier,
      display_columns = display_columns
    ),
    assumptions = .assumptions_tbl(
      assumption = c(
        "Valid person-time denominator",
        "Poisson event process",
        "Independent event counts"
      ),
      status = c("partly_checked", "user_check", "user_check"),
      result = c(
        if (any(summary_tbl$person_time <= 0)) {
          "zero_total_time"
        } else {
          "positive_total_time"
        },
        "not_checked", "not_checked"
      ),
      detail = c(
        if (any(summary_tbl$person_time <= 0)) {
          "At least one displayed group has zero accumulated time, so its rate is not estimable. Confirm the intended exposure denominator."
        } else {
          "Numeric positive accumulated time is checked; confirm that it represents genuine exposure time."
        },
        "Confirm that a Poisson process is a reasonable approximation.",
        "Consider recurrent-event or clustered methods when event counts are dependent."
      )
    ),
    diagnostics = dplyr::bind_rows(
      .diagnostics_tbl(
        check = "Accumulated person-time",
        result = if (any(summary_tbl$person_time <= 0)) {
          "not_estimable"
        } else {
          "positive"
        },
        value = paste(.format_number(summary_tbl$person_time, 2), collapse = "; "),
        threshold = "Greater than 0",
        detail = if (any(summary_tbl$person_time <= 0)) {
          "At least one displayed group has zero accumulated person-time; its rate and interval are unavailable."
        } else {
          "Person-time is reported for every displayed group."
        }
      ),
      .diagnostics_tbl(
        check = "Possible proportion-like input",
        result = if (
          all(df[[time_name]] == 1) &&
          all(df[[event_name]] %in% c(0, 1))
        ) "review" else "not_flagged",
        value = if (all(df[[time_name]] == 1)) "All time values equal 1" else "Time varies",
        threshold = "Binary event plus one unit per row",
        detail = if (
          all(df[[time_name]] == 1) &&
          all(df[[event_name]] %in% c(0, 1))
        ) {
          "This input may represent a proportion rather than a genuine person-time rate; confirm the estimand."
        } else {
          "No simple proportion-like pattern was detected."
        }
      ),
      .diagnostics_tbl(
        check = "Events recorded with zero time",
        result = if (any(df[[event_name]] > 0 & df[[time_name]] == 0)) {
          "review"
        } else {
          "not_flagged"
        },
        value = sum(df[[event_name]] > 0 & df[[time_name]] == 0),
        threshold = "0 records",
        detail = paste0(
          "Positive events with zero contributed time require review; ",
          "the record remains in the accumulated totals."
        )
      )
    ),
    denominators = denominator_audit,
    notes = c(
      paste0(
        "Rates are shown per ",
        format(multiplier, scientific = FALSE, trim = TRUE),
        " ",
        display_time_label,
        " using complete event-time pairs and ",
        round(conf.level * 100),
        "% exact Poisson confidence intervals."
      ),
      "Confirm that the denominator represents positive person-time or exposure time.",
      if (any(summary_tbl$person_time <= 0)) {
        "A displayed group has zero accumulated person-time; its rate is not estimable."
      } else {
        character()
      },
      "Exact Poisson intervals assume independent event counts arising from a Poisson process.",
      if (
        all(df[[time_name]] == 1) &&
        all(df[[event_name]] %in% c(0, 1))
      ) {
        "All time values equal 1 with a binary event; confirm whether a proportion is more appropriate."
      } else {
        character()
      }
    ),
    call = match.call()
  )

  class(result) <- c("gt_rate", "gtstats", "list")
  if (identical(format, "tibble")) return(result$table)
  result
}
