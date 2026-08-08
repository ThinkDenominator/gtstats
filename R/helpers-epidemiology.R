# Internal 2x2 implementation ---------------------------------------------

.two_by_two_result <- function(
    data,
    exposure,
    outcome,
    exposed_level = NULL,
    event_level = NULL,
    measures = c("rr", "or", "rd"),
    conf.level = 0.95,
    risk_ci = c("wilson", "exact"),
    test = c("auto", "none", "chisq", "fisher"),
    zero_correction = c("haldane_anscombe", "none"),
    digits = 2
) {
  risk_ci <- match.arg(risk_ci)
  test <- match.arg(test)
  zero_correction <- match.arg(zero_correction)
  .validate_conf_level(conf.level)
  .validate_digits(digits)

  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  allowed_measures <- c("risk", "rr", "or", "rd")
  if (!is.character(measures) || length(measures) == 0L ||
      anyNA(measures) || any(!measures %in% allowed_measures)) {
    stop(
      "`measures` must contain one or more of: risk, rr, or, rd.",
      call. = FALSE
    )
  }
  measures <- unique(measures)

  exposure_name <- .resolve_var_arg(
    substitute(exposure),
    env = parent.frame()
  )
  outcome_name <- .resolve_var_arg(
    substitute(outcome),
    env = parent.frame()
  )
  if (!exposure_name %in% names(data)) {
    stop("`row` was not found in `data`.", call. = FALSE)
  }
  if (!outcome_name %in% names(data)) {
    stop("`col` was not found in `data`.", call. = FALSE)
  }
  if (identical(exposure_name, outcome_name)) {
    stop("`row` and `col` must be different variables.", call. = FALSE)
  }

  exposure_raw <- data[[exposure_name]]
  outcome_raw <- data[[outcome_name]]
  complete <- !is.na(exposure_raw) & !is.na(outcome_raw)
  exposure_values <- as.character(exposure_raw[complete])
  outcome_values <- as.character(outcome_raw[complete])
  if (length(exposure_values) == 0L) {
    stop(
      "No complete row-column pairs are available.",
      call. = FALSE
    )
  }

  observed_levels <- function(variable, values) {
    observed <- unique(values)
    if (is.factor(variable)) {
      levels(variable)[levels(variable) %in% observed]
    } else {
      observed
    }
  }
  exposure_levels <- observed_levels(exposure_raw, exposure_values)
  outcome_levels <- observed_levels(outcome_raw, outcome_values)
  if (length(exposure_levels) != 2L) {
    stop(
      "`row` must have exactly 2 observed non-missing levels.",
      call. = FALSE
    )
  }
  if (length(outcome_levels) != 2L) {
    stop(
      "`col` must have exactly 2 observed non-missing levels.",
      call. = FALSE
    )
  }

  choose_level <- function(levels, specified, argument) {
    if (!is.null(specified)) {
      if (length(specified) != 1L || is.na(specified)) {
        stop(
          paste0("`", argument, "` must be one non-missing value."),
          call. = FALSE
        )
      }
      specified <- as.character(specified)
      if (!specified %in% levels) {
        stop(
          paste0(
            "Selected `", argument, "` was not found. Available levels: ",
            paste(levels, collapse = ", "), "."
          ),
          call. = FALSE
        )
      }
      return(specified)
    }
    preferred <- c("1", "Yes", "yes", "TRUE", "True", "true")
    hit <- preferred[preferred %in% levels]
    if (length(hit) > 0L) hit[[1L]] else levels[[2L]]
  }
  exposed_level <- choose_level(
    exposure_levels,
    exposed_level,
    "row_level"
  )
  event_level <- choose_level(outcome_levels, event_level, "col_level")
  unexposed_level <- setdiff(exposure_levels, exposed_level)
  nonevent_level <- setdiff(outcome_levels, event_level)

  exposed <- exposure_values == exposed_level
  event <- outcome_values == event_level
  a <- sum(exposed & event)
  b <- sum(exposed & !event)
  c <- sum(!exposed & event)
  d <- sum(!exposed & !event)
  exposed_n <- a + b
  unexposed_n <- c + d
  total_n <- a + b + c + d
  cells <- c(a = a, b = b, c = c, d = d)
  matrix_2x2 <- matrix(c(a, b, c, d), nrow = 2L, byrow = TRUE)

  proportion_interval <- function(events, total) {
    .binomial_ci(
      events,
      total,
      conf.level = conf.level,
      method = risk_ci
    )
  }
  exposed_risk <- a / exposed_n
  unexposed_risk <- c / unexposed_n
  exposed_risk_ci <- proportion_interval(a, exposed_n)
  unexposed_risk_ci <- proportion_interval(c, unexposed_n)

  ratio_result <- function(kind = c("rr", "or")) {
    kind <- match.arg(kind)
    corrected <- any(cells == 0L) &&
      identical(zero_correction, "haldane_anscombe")
    values <- cells
    if (corrected) values <- values + 0.5
    aa <- values[["a"]]
    bb <- values[["b"]]
    cc <- values[["c"]]
    dd <- values[["d"]]

    if (identical(kind, "rr")) {
      estimate <- (aa / (aa + bb)) / (cc / (cc + dd))
      se <- sqrt(
        (1 / aa) - (1 / (aa + bb)) +
          (1 / cc) - (1 / (cc + dd))
      )
    } else {
      estimate <- (aa * dd) / (bb * cc)
      se <- sqrt(1 / aa + 1 / bb + 1 / cc + 1 / dd)
    }
    interval_available <- is.finite(estimate) && is.finite(se) &&
      estimate > 0
    if (!interval_available) {
      return(list(
        estimate = estimate,
        low = NA_real_,
        high = NA_real_,
        corrected = corrected
      ))
    }
    z <- stats::qnorm(1 - (1 - conf.level) / 2)
    interval <- exp(log(estimate) + c(-1, 1) * z * se)
    list(
      estimate = unname(estimate),
      low = unname(interval[[1L]]),
      high = unname(interval[[2L]]),
      corrected = corrected
    )
  }
  rr_result <- ratio_result("rr")
  or_result <- ratio_result("or")

  rd_estimate <- exposed_risk - unexposed_risk
  rd_interval <- c(
    rd_estimate - sqrt(
      (exposed_risk - exposed_risk_ci[[1L]])^2 +
        (unexposed_risk_ci[[2L]] - unexposed_risk)^2
    ),
    rd_estimate + sqrt(
      (exposed_risk_ci[[2L]] - exposed_risk)^2 +
        (unexposed_risk - unexposed_risk_ci[[1L]])^2
    )
  )
  rd_interval <- pmax(-1, pmin(1, rd_interval))

  expected <- suppressWarnings(
    stats::chisq.test(matrix_2x2, correct = TRUE)$expected
  )
  minimum_expected <- min(expected)
  chosen_test <- if (identical(test, "auto")) {
    if (any(expected < 5)) "fisher" else "chisq"
  } else {
    test
  }
  if (identical(chosen_test, "none")) {
    test_used <- "None"
    p_value <- NA_real_
  } else if (identical(chosen_test, "fisher")) {
    test_used <- "Fisher's exact test"
    p_value <- stats::fisher.test(matrix_2x2)$p.value
  } else {
    test_used <- "Chi-square test with Yates correction"
    p_value <- suppressWarnings(
      stats::chisq.test(matrix_2x2, correct = TRUE)$p.value
    )
  }

  fmt_num <- function(value) {
    if (is.na(value)) return(NA_character_)
    if (is.infinite(value)) return(if (value > 0) "Inf" else "-Inf")
    .format_number(value, digits)
  }
  fmt_effect <- function(result) {
    estimate <- fmt_num(result$estimate)
    if (is.na(result$low) || is.na(result$high)) {
      return(paste0(estimate, " (CI unavailable)"))
    }
    paste0(
      estimate,
      " (",
      .format_ci(result$low, result$high, digits),
      ")"
    )
  }
  fmt_risk <- function(events, total, estimate, interval) {
    paste0(
      events,
      "/",
      total,
      " (",
      .format_number(100 * estimate, digits),
      "%; ",
      .format_ci(100 * interval[[1L]], 100 * interval[[2L]], digits),
      "%)"
    )
  }
  fmt_p <- function(value) {
    if (is.na(value)) return(NA_character_)
    if (value < 0.001) "<0.001" else sprintf("%.3f", value)
  }

  exposed_header <- paste0("Exposed: ", exposed_level)
  unexposed_header <- paste0("Unexposed: ", unexposed_level)
  effect_header <- paste0("Effect (", .conf_level_label(conf.level), ")")
  display_rows <- list()
  if ("risk" %in% measures) {
    display_rows[[length(display_rows) + 1L]] <- tibble::tibble(
      Measure = "Risk",
      exposed = fmt_risk(
        a, exposed_n, exposed_risk, exposed_risk_ci
      ),
      unexposed = fmt_risk(
        c, unexposed_n, unexposed_risk, unexposed_risk_ci
      ),
      effect = NA_character_
    )
  }
  if ("rr" %in% measures) {
    display_rows[[length(display_rows) + 1L]] <- tibble::tibble(
      Measure = "Risk ratio",
      exposed = NA_character_,
      unexposed = NA_character_,
      effect = fmt_effect(rr_result)
    )
  }
  if ("or" %in% measures) {
    display_rows[[length(display_rows) + 1L]] <- tibble::tibble(
      Measure = "Odds ratio",
      exposed = NA_character_,
      unexposed = NA_character_,
      effect = fmt_effect(or_result)
    )
  }
  if ("rd" %in% measures) {
    display_rows[[length(display_rows) + 1L]] <- tibble::tibble(
      Measure = "Risk difference",
      exposed = NA_character_,
      unexposed = NA_character_,
      effect = paste0(
        .format_number(100 * rd_estimate, digits),
        " pp (",
        .format_ci(
          100 * rd_interval[[1L]],
          100 * rd_interval[[2L]],
          digits
        ),
        " pp)"
      )
    )
  }
  table_tbl <- dplyr::bind_rows(display_rows)
  names(table_tbl) <- c(
    "Measure",
    exposed_header,
    unexposed_header,
    effect_header
  )
  if (!identical(chosen_test, "none")) {
    p_column <- rep(NA_character_, nrow(table_tbl))
    preferred_row <- match("Risk ratio", table_tbl$Measure)
    if (is.na(preferred_row)) preferred_row <- 1L
    p_column[[preferred_row]] <- fmt_p(p_value)
    table_tbl[["p-value"]] <- p_column
  }

  summary_tbl <- tibble::tibble(
    exposure = exposure_name,
    outcome = outcome_name,
    exposed_level = exposed_level,
    unexposed_level = unexposed_level,
    event_level = event_level,
    nonevent_level = nonevent_level,
    exposed_events = a,
    exposed_nonevents = b,
    unexposed_events = c,
    unexposed_nonevents = d,
    n_exposed = exposed_n,
    n_unexposed = unexposed_n,
    n_total = total_n,
    risk_exposed = exposed_risk,
    risk_exposed_low = unname(exposed_risk_ci[[1L]]),
    risk_exposed_high = unname(exposed_risk_ci[[2L]]),
    risk_unexposed = unexposed_risk,
    risk_unexposed_low = unname(unexposed_risk_ci[[1L]]),
    risk_unexposed_high = unname(unexposed_risk_ci[[2L]]),
    rr = rr_result$estimate,
    rr_low = rr_result$low,
    rr_high = rr_result$high,
    or = or_result$estimate,
    or_low = or_result$low,
    or_high = or_result$high,
    rd = rd_estimate,
    rd_low = unname(rd_interval[[1L]]),
    rd_high = unname(rd_interval[[2L]]),
    test_used = test_used,
    minimum_expected = minimum_expected,
    p_value = p_value
  )

  correction_applied <- any(cells == 0L) &&
    identical(zero_correction, "haldane_anscombe") &&
    any(measures %in% c("rr", "or"))
  result <- list(
    inputs = list(
      data_name = deparse(substitute(data)),
      exposure = exposure_name,
      outcome = outcome_name,
      exposed_level = exposed_level,
      event_level = event_level,
      measures = measures,
      conf.level = conf.level,
      risk_ci = risk_ci,
      test = test,
      zero_correction = zero_correction,
      digits = digits
    ),
    summary = summary_tbl,
    table = table_tbl,
    method = list(
      association_test = test_used,
      expected_counts = expected,
      risk_interval = if (identical(risk_ci, "wilson")) {
        "Wilson score"
      } else {
        "Exact binomial"
      },
      zero_cell_correction = if (correction_applied) {
        "haldane_anscombe"
      } else if (any(cells == 0L)) {
        "none"
      } else {
        "not_needed"
      },
      risk_difference_interval = "Newcombe hybrid score"
    ),
    assumptions = .assumptions_tbl(
      assumption = c(
        "Independent observations",
        "Mutually exclusive categories",
        "Correct exposure and event direction",
        "Adequate expected cell counts"
      ),
      status = c("user_check", "user_check", "user_check", "checked"),
      result = c(
        "not_checked",
        "not_checked",
        "levels_reported",
        if (minimum_expected >= 5) "all_at_least_5" else "sparse"
      ),
      detail = c(
        "Confirm independence from the study design.",
        "Each observation should occupy exactly one 2x2 cell.",
        "Review exposed_level and event_level before interpretation.",
        "Fisher's exact test is selected automatically when any expected count is below 5."
      )
    ),
    diagnostics = dplyr::bind_rows(
      .diagnostics_tbl(
        check = "Expected cell counts",
        result = if (minimum_expected >= 5) "adequate" else "sparse",
        value = .format_number(minimum_expected, 2),
        threshold = "Minimum expected count >= 5",
        detail = paste0("Association test: ", test_used, ".")
      ),
      .diagnostics_tbl(
        check = "Zero cells",
        result = if (any(cells == 0L)) "present" else "none",
        value = sum(cells == 0L),
        threshold = "0 preferred for log-scale Wald intervals",
        detail = if (correction_applied) {
          "Haldane-Anscombe added 0.5 to all cells for RR/OR estimation and intervals."
        } else if (any(cells == 0L)) {
          "No correction was applied; a ratio CI may be unavailable."
        } else {
          "No zero-cell correction was required."
        }
      )
    ),
    denominators = dplyr::bind_rows(
      .denominators_tbl(
        variable = outcome_name,
        level = event_level,
        group = exposed_level,
        n_total = sum(!is.na(exposure_raw) &
          as.character(exposure_raw) == exposed_level),
        n_nonmissing = exposed_n,
        n_missing = sum(!is.na(exposure_raw) &
          as.character(exposure_raw) == exposed_level) - exposed_n,
        numerator = a,
        denominator = exposed_n,
        rule = paste0("Complete pairs; event level = ", event_level)
      ),
      .denominators_tbl(
        variable = outcome_name,
        level = event_level,
        group = unexposed_level,
        n_total = sum(!is.na(exposure_raw) &
          as.character(exposure_raw) == unexposed_level),
        n_nonmissing = unexposed_n,
        n_missing = sum(!is.na(exposure_raw) &
          as.character(exposure_raw) == unexposed_level) - unexposed_n,
        numerator = c,
        denominator = unexposed_n,
        rule = paste0("Complete pairs; event level = ", event_level)
      )
    ),
    notes = c(
      paste0(
        "Exposure: ",
        .get_var_label(data, exposure_name),
        "; exposed = ",
        exposed_level,
        ", unexposed = ",
        unexposed_level,
        ". Event: ",
        .get_var_label(data, outcome_name),
        " = ",
        event_level,
        ". Complete pairs: N = ",
        total_n,
        "."
      ),
      if (!identical(chosen_test, "none")) {
        paste0("P-value from ", test_used, ".")
      } else {
        character()
      },
      if (correction_applied) {
        "Zero cell: 0.5 was added to all four cells for RR/OR estimates and confidence intervals."
      } else {
        character()
      }
    ),
    call = match.call()
  )
  class(result) <- c("gt_twobytwo", "gtstats", "list")
  result
}
