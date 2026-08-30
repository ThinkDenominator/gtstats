#' Outbreak and surveillance summary table
#'
#' Build a publication-ready epidemiology table from either individual
#' line-list records or aggregate numerator/denominator data. Unlike
#' [summary_table()], this function always makes the event and denominator
#' explicit and always reports a confidence interval.
#'
#' @param data A data frame.
#' @param outcomes Line-list outcome variables selected with tidyselect syntax.
#' @param by Optional grouping variable.
#' @param event Event level to count. Supply one value for all outcomes or a
#'   named vector, for example `c(infected = "Yes", admitted = "Yes")`.
#' @param numerator,denominator Aggregate count and denominator columns. For an
#'   incidence rate, `denominator` is accumulated person-time.
#' @param label Optional aggregate outcome-label column or a single text label.
#' @param person_time Optional line-list person-time column. Required when
#'   `measure = "incidence_rate"`.
#' @param measure One of `"proportion"`, `"prevalence"`, `"attack_rate"`, or
#'   `"incidence_rate"`.
#' @param multiplier Scale used for estimates. Defaults to 100 for proportions,
#'   prevalence and attack rates, and 1,000 for incidence rates.
#' @param ci_method Binomial interval method: `"wilson"` or `"exact"`.
#'   Incidence rates always use an exact Poisson interval.
#' @param conf.level Confidence level.
#' @param p_value Add an association/rate-comparison p-value when `by` is used.
#' @param p_adjust Optional multiplicity adjustment passed to [stats::p.adjust()].
#' @param effects Optional two-group effect measures. Use `"none"` (default),
#'   `"all"`, or any of `"rr"`, `"rd"`, and `"or"`. Incidence-rate tables
#'   support `"irr"`.
#' @param layout `"auto"`, `"wide"`, or `"long"`. Auto uses wide output for
#'   four or fewer groups and long output otherwise.
#' @param digits Number of decimal places.
#' @param format `"table"` (default) or `"tibble"`.
#'
#' @return A `gt_epi_table` object containing `$summary`, `$table`,
#'   `$denominators`, `$p_values`, `$effects`, `$inputs`, and `$notes`.
#' @examples
#' epi_table(
#'   birthwt, outcomes = low, by = smoke,
#'   event = "Low birth weight", measure = "prevalence"
#' )
#'
#' aggregate_data <- data.frame(
#'   ward = c("A", "B"), cases = c(12, 7), population = c(80, 65)
#' )
#' epi_table(
#'   aggregate_data, numerator = cases, denominator = population,
#'   by = ward, label = "Influenza", measure = "attack_rate"
#' )
#' @export
epi_table <- function(
    data,
    outcomes = NULL,
    by = NULL,
    event = NULL,
    numerator = NULL,
    denominator = NULL,
    label = NULL,
    person_time = NULL,
    measure = c("proportion", "prevalence", "attack_rate", "incidence_rate"),
    multiplier = NULL,
    ci_method = c("wilson", "exact"),
    conf.level = 0.95,
    p_value = FALSE,
    p_adjust = c("none", "holm", "bonferroni", "BH", "fdr"),
    effects = "none",
    layout = c("auto", "wide", "long"),
    digits = 1,
    format = c("table", "tibble")
) {
  if (!is.data.frame(data)) stop("`data` must be a data frame.", call. = FALSE)
  measure <- match.arg(measure)
  ci_method <- match.arg(ci_method)
  p_adjust <- match.arg(p_adjust)
  layout <- match.arg(layout)
  format <- match.arg(format)
  .validate_flag(p_value, "p_value")
  if (!is.numeric(conf.level) || length(conf.level) != 1L || is.na(conf.level) || conf.level <= 0 || conf.level >= 1) {
    stop("`conf.level` must be a single number between 0 and 1.", call. = FALSE)
  }
  if (!is.numeric(digits) || length(digits) != 1L || is.na(digits) || digits < 0) {
    stop("`digits` must be a single non-negative number.", call. = FALSE)
  }
  multiplier <- multiplier %||% if (identical(measure, "incidence_rate")) 1000 else 100
  if (!is.numeric(multiplier) || length(multiplier) != 1L || is.na(multiplier) || multiplier <= 0) {
    stop("`multiplier` must be a single positive number.", call. = FALSE)
  }

  outcome_expr <- substitute(outcomes)
  numerator_expr <- substitute(numerator)
  denominator_expr <- substitute(denominator)
  line_route <- !identical(outcome_expr, quote(NULL))
  aggregate_route <- !identical(numerator_expr, quote(NULL)) || !identical(denominator_expr, quote(NULL))
  if (line_route && aggregate_route) {
    stop("Choose one data structure: supply `outcomes` for a line list, or `numerator` and `denominator` for aggregate data.", call. = FALSE)
  }
  if (!line_route && !aggregate_route) {
    stop("No epidemiology ingredients were supplied. Use `outcomes = c(...)` for a line list, or supply both `numerator` and `denominator` for aggregate data.", call. = FALSE)
  }
  if (aggregate_route && (identical(numerator_expr, quote(NULL)) || identical(denominator_expr, quote(NULL)))) {
    stop("Aggregate data require both `numerator` and `denominator`.", call. = FALSE)
  }

  by_name <- .resolve_var_arg(substitute(by), env = parent.frame(), allow_null = TRUE)
  if (!is.null(by_name) && !by_name %in% names(data)) stop("`by` was not found in `data`.", call. = FALSE)
  group_value <- if (is.null(by_name)) rep("Overall", nrow(data)) else as.character(data[[by_name]])
  if (anyNA(group_value)) group_value[is.na(group_value)] <- "Missing"
  group_levels <- if (!is.null(by_name) && is.factor(data[[by_name]])) {
    c(levels(data[[by_name]])[levels(data[[by_name]]) %in% group_value], if (any(group_value == "Missing")) "Missing" else character())
  } else {
    unique(group_value)
  }

  label_for <- function(variable) {
    value <- attr(data[[variable]], "label", exact = TRUE)
    if (is.null(value) || !nzchar(as.character(value)[[1L]])) variable else as.character(value)[[1L]]
  }
  rows <- list()
  source_details <- list()

  if (line_route) {
    selected <- tidyselect::eval_select(outcome_expr, data = data)
    outcome_names <- names(selected)
    if (!length(outcome_names)) stop("`outcomes` must select at least one variable.", call. = FALSE)
    time_name <- .resolve_var_arg(substitute(person_time), env = parent.frame(), allow_null = TRUE)
    if (identical(measure, "incidence_rate") && is.null(time_name)) {
      stop("Line-list incidence rates require `person_time`.", call. = FALSE)
    }
    if (!is.null(time_name) && (!time_name %in% names(data) || !is.numeric(data[[time_name]]))) {
      stop("`person_time` must be a numeric column in `data`.", call. = FALSE)
    }
    event_map <- event
    for (variable in outcome_names) {
      requested <- if (is.null(event_map)) NULL else if (!is.null(names(event_map)) && variable %in% names(event_map)) event_map[[variable]] else if (length(event_map) == 1L) event_map[[1L]] else NULL
      selected_event <- .select_target_level(data[[variable]], requested, arg = paste0("event for ", variable))
      if (!identical(measure, "incidence_rate") && length(unique(stats::na.omit(as.character(data[[variable]])))) < 2L) {
        stop("Line-list outcome `", variable, "` does not contain both event and non-event observations. Supply an explicit denominator using the aggregate route.", call. = FALSE)
      }
      for (group in group_levels) {
        idx <- group_value == group
        outcome_values <- as.character(data[[variable]][idx])
        complete <- !is.na(outcome_values)
        cases <- sum(outcome_values[complete] == selected_event)
        denom <- if (identical(measure, "incidence_rate")) sum(data[[time_name]][idx & !is.na(data[[variable]])], na.rm = TRUE) else sum(complete)
        rows[[length(rows) + 1L]] <- .epi_row(variable, label_for(variable), group, selected_event, cases, denom, measure, multiplier, ci_method, conf.level)
      }
      source_details[[variable]] <- list(type = "line_list", event = selected_event)
    }
  } else {
    numerator_name <- .resolve_var_arg(numerator_expr, env = parent.frame())
    denominator_name <- .resolve_var_arg(denominator_expr, env = parent.frame())
    if (!all(c(numerator_name, denominator_name) %in% names(data))) stop("`numerator` and `denominator` must be columns in `data`.", call. = FALSE)
    numerators <- data[[numerator_name]]
    denominators <- data[[denominator_name]]
    if (!is.numeric(numerators) || any(!is.finite(numerators)) || any(numerators < 0) || any(abs(numerators - round(numerators)) > sqrt(.Machine$double.eps))) {
      stop("`numerator` must contain finite non-negative integer counts.", call. = FALSE)
    }
    if (!is.numeric(denominators) || any(!is.finite(denominators)) || any(denominators <= 0)) {
      stop("`denominator` must contain finite positive values.", call. = FALSE)
    }
    if (!identical(measure, "incidence_rate") && (any(abs(denominators - round(denominators)) > sqrt(.Machine$double.eps)) || any(numerators > denominators))) {
      stop("For proportions, prevalence and attack rates, denominators must be integer counts and each numerator must not exceed its denominator.", call. = FALSE)
    }
    label_expr <- substitute(label)
    if (identical(label_expr, quote(NULL))) {
      labels <- rep("Outcome", nrow(data))
    } else {
      label_eval <- tryCatch(eval(label_expr, parent.frame()), error = function(e) NULL)
      label_name <- if (is.symbol(label_expr)) deparse(label_expr) else if (is.character(label_eval) && length(label_eval) == 1L && label_eval %in% names(data)) label_eval else NULL
      labels <- if (!is.null(label_name) && label_name %in% names(data)) as.character(data[[label_name]]) else rep(as.character(label_eval %||% deparse(label_expr))[[1L]], nrow(data))
    }
    aggregate <- stats::aggregate(
      list(cases = numerators, denominator = denominators),
      by = list(outcome = labels, group = factor(group_value, levels = group_levels)), FUN = sum
    )
    for (i in seq_len(nrow(aggregate))) {
      variable <- make.names(aggregate$outcome[[i]])
      rows[[length(rows) + 1L]] <- .epi_row(variable, aggregate$outcome[[i]], aggregate$group[[i]], NA_character_, aggregate$cases[[i]], aggregate$denominator[[i]], measure, multiplier, ci_method, conf.level)
    }
    source_details$aggregate <- list(type = "aggregate", numerator = numerator_name, denominator = denominator_name)
  }

  summary_tbl <- do.call(rbind, rows)
  rownames(summary_tbl) <- NULL
  p_tbl <- .epi_p_values(summary_tbl, measure, p_value, p_adjust)
  effect_tbl <- .epi_effects(summary_tbl, measure, effects, conf.level, multiplier)
  summary_tbl <- merge(summary_tbl, p_tbl[, c("outcome", "p_value", "p_adjusted", "test"), drop = FALSE], by = "outcome", all.x = TRUE, sort = FALSE)
  summary_tbl$display_p <- if (identical(p_adjust, "none")) summary_tbl$p_value else summary_tbl$p_adjusted
  chosen_layout <- if (identical(layout, "auto")) if (length(unique(summary_tbl$group)) <= 4L) "wide" else "long" else layout
  display_tbl <- .epi_display_table(summary_tbl, chosen_layout, digits, conf.level, effect_tbl)
  notes <- c(
    paste0(.conf_level_label(conf.level), " is ", if (identical(measure, "incidence_rate")) "an exact Poisson interval" else paste0("a ", ci_method, " binomial interval"), "."),
    if (isTRUE(p_value)) "P-values compare the full event/non-event distribution across groups; they do not replace effect estimates or confidence intervals." else NULL,
    if (isTRUE(p_value)) paste0("Tests used: ", paste(unique(stats::na.omit(p_tbl$test)), collapse = "; "), ".") else NULL,
    if (isTRUE(p_value) && !identical(p_adjust, "none")) paste0("Displayed p-values use the ", p_adjust, " multiplicity adjustment.") else NULL,
    if (nrow(effect_tbl)) "Effect estimates use the first displayed group relative to the second; verify group order before reporting." else NULL
  )
  diagnostics <- data.frame(
    check = c("Data structure", "Occurrence measure", "Confidence interval", "Denominator validation"),
    result = c(if (line_route) "line_list" else "aggregate", measure, if (identical(measure, "incidence_rate")) "exact_poisson" else ci_method, "passed"),
    detail = c(
      if (line_route) "Events were counted from individual records." else "Supplied numerator and denominator columns were aggregated within outcome and group.",
      paste0("Estimates are reported per ", format(multiplier, big.mark = ",", scientific = FALSE), "."),
      if (identical(measure, "incidence_rate")) "Exact Poisson intervals were used." else paste0(.sentence_case(ci_method), " binomial intervals were used."),
      if (line_route) "Each denominator is the number of non-missing outcome records, or accumulated person-time for an incidence rate." else "Numerators and denominators passed range and consistency checks."
    ), stringsAsFactors = FALSE
  )
  assumptions <- data.frame(
    assumption = c("Event definition", "Eligible denominator", if (isTRUE(p_value)) "Independent groups" else character()),
    status = c("user_check", "user_check", if (isTRUE(p_value)) "user_check" else character()),
    result = "not_checked",
    detail = c(
      "Confirm that the selected event matches the clinical or surveillance definition.",
      "Confirm that the denominator represents the population or person-time eligible to experience the event.",
      if (isTRUE(p_value)) "Confirm from the study or surveillance design that compared groups are independent." else character()
    ), stringsAsFactors = FALSE
  )
  result <- list(
    summary = tibble::as_tibble(summary_tbl), table = tibble::as_tibble(display_tbl),
    denominators = tibble::as_tibble(summary_tbl[, c("outcome", "label", "group", "cases", "denominator")]),
    p_values = tibble::as_tibble(p_tbl), effects = tibble::as_tibble(effect_tbl),
    diagnostics = tibble::as_tibble(diagnostics), assumptions = tibble::as_tibble(assumptions),
    inputs = list(data_name = deparse(substitute(data)), route = if (line_route) "line_list" else "aggregate", by = by_name, measure = measure, multiplier = multiplier, ci_method = ci_method, conf.level = conf.level, p_value = p_value, p_adjust = p_adjust, effects = effects, layout = chosen_layout, digits = digits),
    method = list(source = source_details), notes = notes, call = match.call()
  )
  class(result) <- c("gt_epi_table", "gtstats", "list")
  if (identical(format, "tibble")) return(result$summary)
  result
}

.epi_row <- function(outcome, label, group, event, cases, denominator, measure, multiplier, ci_method, conf.level) {
  if (denominator <= 0) stop("Every epidemiology denominator must be greater than zero.", call. = FALSE)
  if (identical(measure, "incidence_rate")) {
    interval <- .poisson_rate_summary(cases, denominator, multiplier, conf.level)
    estimate <- interval$rate
    low <- interval$conf_low
    high <- interval$conf_high
  } else {
    interval <- .binomial_ci(cases, denominator, conf.level, ci_method)
    estimate <- multiplier * cases / denominator
    low <- multiplier * interval[["low"]]
    high <- multiplier * interval[["high"]]
  }
  data.frame(outcome = outcome, label = label, group = group, event = event, cases = cases, denominator = denominator, estimate = estimate, conf_low = low, conf_high = high, measure = measure, multiplier = multiplier, stringsAsFactors = FALSE)
}

.epi_p_values <- function(x, measure, enabled, adjustment) {
  outcomes <- unique(x$outcome)
  rows <- lapply(outcomes, function(outcome) {
    piece <- x[x$outcome == outcome, , drop = FALSE]
    if (!enabled || nrow(piece) < 2L) return(data.frame(outcome = outcome, p_value = NA_real_, test = NA_character_))
    if (identical(measure, "incidence_rate")) {
      fit <- stats::poisson.test(piece$cases, piece$denominator)
      return(data.frame(outcome = outcome, p_value = fit$p.value, test = "Poisson rate comparison"))
    }
    tab <- rbind(event = piece$cases, non_event = piece$denominator - piece$cases)
    expected <- suppressWarnings(stats::chisq.test(tab, correct = FALSE))$expected
    sparse <- .expected_count_screen(expected)$sparse
    fit <- if (sparse) stats::fisher.test(tab, simulate.p.value = ncol(tab) > 2L, B = 10000) else stats::chisq.test(tab, correct = ncol(tab) == 2L)
    data.frame(outcome = outcome, p_value = fit$p.value, test = if (sparse) "Fisher's exact test" else if (ncol(tab) == 2L) "Chi-square test with Yates correction" else "Pearson chi-square test")
  })
  out <- do.call(rbind, rows)
  out$p_adjusted <- if (enabled) stats::p.adjust(out$p_value, method = adjustment) else out$p_value
  out
}

.epi_effects <- function(x, measure, effects, conf.level, multiplier) {
  effects <- unique(as.character(effects %||% "none"))
  if ("none" %in% effects || length(unique(x$group)) != 2L) return(data.frame())
  if ("all" %in% effects) effects <- if (identical(measure, "incidence_rate")) "irr" else c("rr", "rd", "or")
  allowed <- if (identical(measure, "incidence_rate")) "irr" else c("rr", "rd", "or")
  if (any(!effects %in% allowed)) stop("Unsupported `effects` for this measure. Available: ", paste(allowed, collapse = ", "), ".", call. = FALSE)
  z <- stats::qnorm(1 - (1 - conf.level) / 2)
  rows <- list()
  for (outcome in unique(x$outcome)) {
    piece <- x[x$outcome == outcome, , drop = FALSE]
    if (nrow(piece) != 2L) next
    a <- piece$cases[[1L]]; n1 <- piece$denominator[[1L]]; c0 <- piece$cases[[2L]]; n0 <- piece$denominator[[2L]]
    for (kind in effects) {
      corrected <- any(c(a, c0) == 0) || (!identical(measure, "incidence_rate") && any(c(n1 - a, n0 - c0) == 0))
      aa <- if (corrected) a + 0.5 else a; cc <- if (corrected) c0 + 0.5 else c0
      nn1 <- if (corrected && !identical(measure, "incidence_rate")) n1 + 1 else n1
      nn0 <- if (corrected && !identical(measure, "incidence_rate")) n0 + 1 else n0
      if (kind %in% c("rr", "irr")) {
        estimate <- (aa / nn1) / (cc / nn0); se <- sqrt(1 / aa - if (kind == "rr") 1 / nn1 else 0 + 1 / cc - if (kind == "rr") 1 / nn0 else 0)
        low <- exp(log(estimate) - z * se); high <- exp(log(estimate) + z * se)
      } else if (kind == "or") {
        estimate <- (aa / (nn1 - aa)) / (cc / (nn0 - cc)); se <- sqrt(1 / aa + 1 / (nn1 - aa) + 1 / cc + 1 / (nn0 - cc)); low <- exp(log(estimate) - z * se); high <- exp(log(estimate) + z * se)
      } else {
        p1 <- a / n1; p0 <- c0 / n0; estimate <- multiplier * (p1 - p0); se <- multiplier * sqrt(p1 * (1 - p1) / n1 + p0 * (1 - p0) / n0); low <- estimate - z * se; high <- estimate + z * se
      }
      rows[[length(rows) + 1L]] <- data.frame(outcome = outcome, measure = toupper(kind), contrast = paste(piece$group[[1L]], "vs", piece$group[[2L]]), estimate = estimate, conf_low = low, conf_high = high, zero_correction = corrected)
    }
  }
  if (length(rows)) do.call(rbind, rows) else data.frame()
}

.epi_measure_label <- function(measure, multiplier) {
  scale <- format(multiplier, big.mark = ",", scientific = FALSE, trim = TRUE)
  if (multiplier == 100 && measure %in% c("proportion", "prevalence", "attack_rate")) {
    return(switch(measure, proportion = "Proportion (%)", prevalence = "Prevalence (%)", attack_rate = "Attack rate (%)"))
  }
  switch(measure, proportion = paste0("Proportion per ", scale), prevalence = paste0("Prevalence per ", scale), attack_rate = paste0("Attack rate per ", scale), incidence_rate = paste0("Incidence rate per ", scale))
}

.epi_display_table <- function(x, layout, digits, conf.level, effects = data.frame()) {
  ci_label <- .conf_level_label(conf.level)
  fmt <- function(value) ifelse(is.na(value), "\u2014", .format_number(value, digits))
  p_fmt <- function(value) ifelse(is.na(value), "", ifelse(value < 0.001, "<0.001", formatC(value, format = "f", digits = 3)))
  x$Cases <- format(x$cases, trim = TRUE, scientific = FALSE)
  x$Denominator <- .format_number(x$denominator, if (all(abs(x$denominator - round(x$denominator)) < sqrt(.Machine$double.eps))) 0 else digits)
  x$Estimate <- fmt(x$estimate)
  x[[ci_label]] <- paste0(fmt(x$conf_low), "\u2013", fmt(x$conf_high))
  x$`p-value` <- p_fmt(x$display_p)
  effect_label <- paste0("Effect measures (", ci_label, ")")
  effect_display <- if (nrow(effects)) {
    vapply(unique(x$outcome), function(outcome) {
      piece <- effects[effects$outcome == outcome, , drop = FALSE]
      paste0(piece$measure, " ", fmt(piece$estimate), " (", fmt(piece$conf_low), "\u2013", fmt(piece$conf_high), ")", collapse = "<br>")
    }, character(1))
  } else character()
  names(effect_display) <- if (length(effect_display)) unique(x$outcome) else character()
  if (identical(layout, "long") || length(unique(x$group)) == 1L) {
    names(x)[names(x) == "Estimate"] <- .epi_measure_label(x$measure[[1L]], x$multiplier[[1L]])
    estimate_column <- .epi_measure_label(x$measure[[1L]], x$multiplier[[1L]])
    if (length(effect_display)) {
      x[[effect_label]] <- effect_display[x$outcome]
      x[[effect_label]][duplicated(x$outcome)] <- ""
    }
    keep <- c("label", if (length(unique(x$group)) > 1L) "group", "Cases", "Denominator", estimate_column, ci_label, if (length(effect_display)) effect_label, if (any(nzchar(x$`p-value`))) "p-value")
    out <- x[, keep, drop = FALSE]
    names(out)[names(out) == "label"] <- "Outcome"
    names(out)[names(out) == "group"] <- "Group"
    return(out)
  }
  groups <- unique(x$group)
  base <- unique(x[, c("outcome", "label"), drop = FALSE])
  out <- data.frame(Outcome = base$label, stringsAsFactors = FALSE)
  for (group in groups) {
    piece <- x[x$group == group, , drop = FALSE]
    piece <- piece[match(base$outcome, piece$outcome), , drop = FALSE]
    key <- make.names(group)
    out[[paste0(key, "__Cases")]] <- piece$Cases
    out[[paste0(key, "__Denominator")]] <- piece$Denominator
    out[[paste0(key, "__Estimate")]] <- piece$Estimate
    out[[paste0(key, "__CI")]] <- piece[[ci_label]]
  }
  if (length(effect_display)) out[[effect_label]] <- unname(effect_display[base$outcome])
  if (any(!is.na(x$display_p))) out$`p-value` <- p_fmt(base$outcome |> vapply(function(o) x$display_p[match(o, x$outcome)], numeric(1)))
  attr(out, "epi_groups") <- groups
  attr(out, "ci_label") <- ci_label
  out
}
