#' Add an event-rate row
#'
#' Add an event rate to a rate-mode table created with [summary_table()].
#' Event counts and accumulated time are calculated from complete event-time
#' pairs only. Event counts and time values must be finite. Exact Poisson
#' confidence intervals are shown by default. A row with zero accumulated time
#' is retained as `\u2014` and recorded as not estimable in the audit.
#'
#' `add_rate()` cannot be combined with summary-style components in the same
#' builder because rate denominators have a different meaning.
#'
#' @param x A rate-mode `gt_desc_table` created with [summary_table()].
#' @param event Non-negative integer event count, supplied as a bare name or
#'   character string. Logical values are accepted as binary event indicators.
#' @param time Non-negative numeric person-time or exposure-time variable.
#' @param label Optional row label.
#' @param multiplier Positive rate multiplier. Default is `1000`.
#' @param time_label Optional readable time unit such as `"person-years"` or
#'   `"catheter-days"`. Defaults to `"person-time"`.
#' @param ci Logical; display an exact Poisson confidence interval.
#' @param conf.level Confidence level.
#' @param digits Number of decimal places.
#'
#' @return The updated `gt_desc_table`.
#'
#' @examples
#' summary_table(mtcars, by = am, overall = TRUE, mode = "rate") |>
#'   add_rate(
#'     event = carb,
#'     time = cyl,
#'     label = "Carburettor rate",
#'     multiplier = 1000
#'   )
#'
#' @export
add_rate <- function(
    x,
    event,
    time,
    label = NULL,
    multiplier = 1000,
    time_label = NULL,
    ci = TRUE,
    conf.level = 0.95,
    digits = 1
) {
  .validate_summary_builder(x, "add_rate", mode = "rate")
  .validate_flag(ci, "ci")
  .validate_conf_level(conf.level)
  .validate_digits(digits)
  if (!is.numeric(multiplier) || length(multiplier) != 1L ||
      is.na(multiplier) || multiplier <= 0) {
    stop("`multiplier` must be a single positive number.", call. = FALSE)
  }
  if (!is.null(time_label) &&
      (!is.character(time_label) || length(time_label) != 1L ||
       is.na(time_label) || !nzchar(time_label))) {
    stop("`time_label` must be NULL or one non-empty string.", call. = FALSE)
  }

  event_name <- .resolve_var_arg(substitute(event), env = parent.frame())
  time_name <- .resolve_var_arg(substitute(time), env = parent.frame())
  if (!event_name %in% names(x$data)) {
    stop("`event` was not found in the data.", call. = FALSE)
  }
  if (!time_name %in% names(x$data)) {
    stop("`time` was not found in the data.", call. = FALSE)
  }
  if (identical(event_name, time_name)) {
    stop("`event` and `time` must be different variables.", call. = FALSE)
  }

  event_var <- x$data[[event_name]]
  time_var <- x$data[[time_name]]
  if (!is.numeric(event_var) && !is.logical(event_var)) {
    stop("`event` must be numeric or logical.", call. = FALSE)
  }
  if (is.logical(event_var)) event_var <- as.numeric(event_var)
  if (any(!is.finite(event_var[!is.na(event_var)]))) {
    stop("`event` must contain finite values.", call. = FALSE)
  }
  if (any(event_var < 0, na.rm = TRUE)) {
    stop("`event` must not contain negative values.", call. = FALSE)
  }
  if (any(
    abs(event_var - round(event_var)) > sqrt(.Machine$double.eps),
    na.rm = TRUE
  )) {
    stop("`event` must contain non-negative integer counts.", call. = FALSE)
  }
  if (!is.numeric(time_var)) {
    stop("`time` must be numeric.", call. = FALSE)
  }
  if (any(!is.finite(time_var[!is.na(time_var)]))) {
    stop("`time` must contain finite values.", call. = FALSE)
  }
  if (any(time_var < 0, na.rm = TRUE)) {
    stop("`time` must not contain negative values.", call. = FALSE)
  }

  display_time_label <- time_label %||% "person-time"
  if (is.null(label)) {
    label <- paste0(
      "Rate per ",
      format(multiplier, scientific = FALSE, trim = TRUE, big.mark = ","),
      " ",
      display_time_label
    )
  }
  if (!is.character(label) || length(label) != 1L ||
      is.na(label) || !nzchar(label)) {
    stop("`label` must be NULL or one non-empty string.", call. = FALSE)
  }

  make_display <- function(idx) {
    complete <- idx & !is.na(event_var) & !is.na(time_var)
    result <- .poisson_rate_summary(
      events = sum(event_var[complete]),
      person_time = sum(time_var[complete]),
      multiplier = multiplier,
      conf.level = conf.level
    )
    display <- .format_rate_summary(result, digits = digits, ci = ci)
    if (is.na(display)) "\u2014" else display
  }

  row_tbl <- tibble::tibble(Variable = label, Level = "")
  if (isTRUE(x$overall)) {
    row_tbl$Overall <- make_display(rep(TRUE, nrow(x$data)))
  }
  if (!is.null(x$by)) {
    by_var <- x$data[[x$by]]
    group_values <- .builder_group_values(x)
    group_columns <- .builder_group_columns(x)
    for (group in group_values) {
      row_tbl[[group_columns[[group]]]] <- make_display(
        !is.na(by_var) & as.character(by_var) == group
      )
    }
  } else if (!isTRUE(x$overall)) {
    row_tbl$Value <- make_display(rep(TRUE, nrow(x$data)))
  }
  row_tbl <- .builder_order_display_columns(x, tibble::as_tibble(row_tbl))
  x <- .append_builder_rows(x, row_tbl)
  x$components <- unique(c(x$components, "rate"))

  audit_groups <- .builder_audit_groups(x)
  audit_rows <- dplyr::bind_rows(lapply(
    names(audit_groups),
    function(group_label) {
      idx <- audit_groups[[group_label]]
      complete <- !is.na(event_var[idx]) & !is.na(time_var[idx])
      .denominators_tbl(
        variable = event_name,
        group = group_label,
        n_total = sum(idx),
        n_nonmissing = sum(complete),
        n_missing = sum(!complete),
        numerator = sum(event_var[idx][complete]),
        denominator = sum(time_var[idx][complete]),
        rule = paste0(
          "Complete event-time pairs; accumulated ",
          display_time_label,
          "; rate per ",
          multiplier
        )
      )
    }
  ))
  x$denominators <- dplyr::bind_rows(
    x$denominators %||% .empty_denominators(),
    audit_rows
  )

  zero_time_groups <- audit_rows$group[audit_rows$denominator <= 0]
  rate_diagnostic <- .diagnostics_tbl(
    check = "Accumulated person-time",
    result = if (length(zero_time_groups) > 0L) "not_estimable" else "positive",
    value = paste(.format_number(audit_rows$denominator, 2), collapse = "; "),
    threshold = "Greater than 0",
    detail = if (length(zero_time_groups) > 0L) {
      paste0(
        "Zero accumulated time in: ",
        paste(zero_time_groups, collapse = ", "),
        "; its rate and interval are unavailable."
      )
    } else {
      "Accumulated time is positive for every displayed group."
    }
  )
  x$diagnostics <- dplyr::bind_rows(
    x$diagnostics %||% .empty_diagnostics(),
    rate_diagnostic
  )

  note <- paste0(
    "Rates per ",
    format(multiplier, scientific = FALSE, trim = TRUE, big.mark = ","),
    " ",
    display_time_label,
    " use complete event-time pairs",
    if (isTRUE(ci)) {
      paste0(
        " and ",
        round(100 * conf.level),
        "% exact Poisson confidence intervals."
      )
    } else {
      "."
    }
  )
  x$footnotes <- unique(c(x$footnotes, note))
  if (length(zero_time_groups) > 0L) {
    x$footnotes <- unique(c(
      x$footnotes,
      "A displayed group has zero accumulated time; its rate is not estimable."
    ))
  }
  x
}
