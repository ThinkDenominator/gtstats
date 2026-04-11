#' Incidence rate with exact Poisson confidence interval
#'
#' Compute an incidence or event rate with exact Poisson confidence
#' intervals, either overall or within groups defined by a categorical
#' variable.
#'
#' This function is designed for simple epidemiological summaries where
#' events are counted over a denominator of person-time. The `event`
#' variable may be a binary indicator, a logical variable, or a count
#' variable. The `time` variable must be numeric and non-negative.
#'
#' When a grouping variable is supplied, rates are calculated
#' separately within each group. Confidence intervals are calculated
#' using [stats::poisson.test()].
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
#' @param conf.level Confidence level for the interval. Default is
#'   `0.95`.
#' @param digits Number of decimal places used when formatting rates.
#'   Default is `1`.
#' @param output Output style. Currently stored in the returned object.
#' @param quiet Logical; suppress messages.
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
#' tbl_stats(rate_stats(df, event = event, time = ptime, by = arm))
#'
#' @export
rate_stats <- function(
    data,
    event,
    time,
    by = NULL,
    multiplier = 1000,
    conf.level = 0.95,
    digits = 1,
    output = c("table", "tibble", "both"),
    quiet = FALSE
) {
  output <- match.arg(output)

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

  if (any(df[[event_name]] < 0, na.rm = TRUE)) {
    stop("`event` must not contain negative values.", call. = FALSE)
  }

  # Validate person-time variable
  if (!is.numeric(df[[time_name]])) {
    stop("`time` must be numeric.", call. = FALSE)
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

  if (!is.numeric(conf.level) ||
      length(conf.level) != 1 ||
      is.na(conf.level) ||
      conf.level <= 0 ||
      conf.level >= 1) {
    stop(
      "`conf.level` must be a single number between 0 and 1.",
      call. = FALSE
    )
  }

  if (!is.numeric(digits) ||
      length(digits) != 1 ||
      is.na(digits) ||
      digits < 0) {
    stop(
      "`digits` must be a single non-negative number.",
      call. = FALSE
    )
  }

  # Helper to format numeric values
  .fmt_num <- function(x, digits = 1) {
    ifelse(
      is.na(x),
      NA_character_,
      sprintf(paste0("%.", digits, "f"), x)
    )
  }

  # Build one summary row for one group or for the overall sample
  .make_rate_row <- function(group_label, events, person_time, n_obs) {
    if (is.na(person_time) || person_time <= 0) {
      rate_est <- NA_real_
      rate_low <- NA_real_
      rate_high <- NA_real_
      display <- NA_character_
    } else {
      pt <- stats::poisson.test(
        x = events,
        T = person_time,
        conf.level = conf.level
      )

      rate_est <- unname(pt$estimate) * multiplier
      rate_low <- unname(pt$conf.int[1]) * multiplier
      rate_high <- unname(pt$conf.int[2]) * multiplier

      display <- paste0(
        .fmt_num(rate_est, digits), " (",
        .fmt_num(rate_low, digits), "\u2013",
        .fmt_num(rate_high, digits), ")"
      )
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
      display = display
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
      Variable = .get_var_label(data, event_name),
      n = summary_tbl$n,
      Events = summary_tbl$events,
      `Person-time` = summary_tbl$person_time,
      Rate = summary_tbl$display
    )
  } else {
    group_values <- unique(df[[by_name]])
    group_values <- group_values[!is.na(group_values)]
    group_values_chr <- as.character(group_values)

    summary_list <- lapply(group_values_chr, function(g) {
      idx <- as.character(df[[by_name]]) == g

      .make_rate_row(
        group_label = paste0(by_name, " = ", g),
        events = sum(df[[event_name]][idx], na.rm = TRUE),
        person_time = sum(df[[time_name]][idx], na.rm = TRUE),
        n_obs = sum(idx)
      )
    })

    summary_tbl <- dplyr::bind_rows(summary_list)

    table_tbl <- summary_tbl[, c(
      "group",
      "n",
      "events",
      "person_time",
      "display"
    )]

    names(table_tbl) <- c(
      "Group",
      "n",
      "Events",
      "Person-time",
      "Rate"
    )

    table_tbl <- tibble::as_tibble(table_tbl)
  }

  result <- list(
    inputs = list(
      data_name = deparse(substitute(data)),
      event = event_name,
      time = time_name,
      by = by_name,
      multiplier = multiplier,
      conf.level = conf.level,
      digits = digits,
      output = output
    ),
    summary = summary_tbl,
    table = table_tbl,
    notes = paste0(
      "Rates are shown per ",
      format(multiplier, scientific = FALSE, trim = TRUE),
      " person-time with ",
      round(conf.level * 100),
      "% exact Poisson confidence intervals."
    ),
    call = match.call()
  )

  class(result) <- "gt_rate"
  result
}
