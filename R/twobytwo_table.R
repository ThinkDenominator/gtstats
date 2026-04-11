#' Create a 2x2 epidemiology table
#'
#' Compute a 2x2 table for a binary exposure and a binary outcome,
#' including risks, risk ratio, odds ratio, risk difference, and a
#' p-value.
#'
#' This function is intended for simple epidemiological analyses where
#' both exposure and outcome have exactly two non-missing levels.
#' Users may optionally specify which exposure level should be treated
#' as "exposed" and which outcome level should be treated as the event.
#'
#' The returned object contains both a detailed summary and a compact,
#' display-ready table. By default, the function reports:
#' - risks in exposed and unexposed groups
#' - risk ratio
#' - odds ratio
#' - risk difference
#' - a p-value from either chi-square or Fisher's exact test
#'
#' Continuity correction is applied automatically for ratio measures
#' when zero cells are present.
#'
#' @param data A data.frame.
#' @param exposure Exposure variable. Can be supplied as a bare name or
#'   as a character string.
#' @param outcome Outcome variable. Can be supplied as a bare name or
#'   as a character string.
#' @param exposed_level Optional exposed level used to define the
#'   exposed group.
#' @param outcome_level Optional outcome level used to define the
#'   event.
#' @param measures Character vector of measures to include. Must contain
#'   one or more of `"risk"`, `"rr"`, `"or"`, or `"rd"`.
#' @param conf.level Confidence level for intervals. Default is `0.95`.
#' @param digits Number of decimal places used for formatting.
#' @param test Statistical test to use. One of `"auto"`, `"chisq"`, or
#'   `"fisher"`.
#' @param output Output style. Currently stored in the returned object.
#' @param quiet Logical; suppress messages.
#'
#' @return A `gt_twobytwo` object containing:
#' \itemize{
#'   \item `inputs` — function inputs and settings
#'   \item `summary` — detailed summary table
#'   \item `table` — display-ready 2x2 results table
#'   \item `notes` — explanatory notes
#'   \item `call` — matched function call
#' }
#'
#' @examples
#' twobytwo_table(mtcars, exposure = am, outcome = vs)
#'
#' twobytwo_table(
#'   mtcars,
#'   exposure = am,
#'   outcome = vs,
#'   measures = c("risk", "rr", "or")
#' )
#'
#' tbl_stats(twobytwo_table(mtcars, exposure = am, outcome = vs))
#'
#' @export
twobytwo_table <- function(
    data,
    exposure,
    outcome,
    exposed_level = NULL,
    outcome_level = NULL,
    measures = c("risk", "rr", "or", "rd"),
    conf.level = 0.95,
    digits = 1,
    test = c("auto", "chisq", "fisher"),
    output = c("table", "tibble", "both"),
    quiet = FALSE
) {
  test <- match.arg(test)
  output <- match.arg(output)

  # Validate selected measures
  allowed_measures <- c("risk", "rr", "or", "rd")
  if (length(measures) == 0 ||
      !all(measures %in% allowed_measures)) {
    stop(
      paste0(
        "`measures` must contain one or more of: ",
        paste(allowed_measures, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }

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

  exposure_expr <- substitute(exposure)
  outcome_expr <- substitute(outcome)

  exposure_name <- resolve_name(exposure_expr)
  outcome_name <- resolve_name(outcome_expr)

  if (!exposure_name %in% names(data)) {
    stop("`exposure` was not found in `data`.", call. = FALSE)
  }

  if (!outcome_name %in% names(data)) {
    stop("`outcome` was not found in `data`.", call. = FALSE)
  }

  if (exposure_name == outcome_name) {
    stop(
      "`exposure` and `outcome` must be different variables.",
      call. = FALSE
    )
  }

  # Keep complete cases only
  x <- as.character(data[[exposure_name]])
  y <- as.character(data[[outcome_name]])

  keep <- !is.na(x) & !is.na(y)
  x <- x[keep]
  y <- y[keep]

  if (length(x) == 0) {
    stop(
      "No complete cases available for exposure and outcome.",
      call. = FALSE
    )
  }

  # Require exactly two non-missing levels for both variables
  x_levels <- sort(unique(x))
  y_levels <- sort(unique(y))

  if (length(x_levels) != 2) {
    stop(
      paste0(
        "`exposure` must have exactly 2 non-missing levels ",
        "for `twobytwo_table()`."
      ),
      call. = FALSE
    )
  }

  if (length(y_levels) != 2) {
    stop(
      paste0(
        "`outcome` must have exactly 2 non-missing levels ",
        "for `twobytwo_table()`."
      ),
      call. = FALSE
    )
  }

  # Choose a level explicitly or fall back to a sensible default
  choose_level <- function(levels, specified) {
    if (!is.null(specified)) {
      specified <- as.character(specified)

      if (!specified %in% levels) {
        stop(
          paste0(
            "Selected level `",
            specified,
            "` was not found. Available levels: ",
            paste(levels, collapse = ", "),
            "."
          ),
          call. = FALSE
        )
      }

      return(specified)
    }

    preferred <- c("1", "Yes", "yes", "TRUE", "True", "true")
    hit <- preferred[preferred %in% levels]

    if (length(hit) > 0) {
      return(hit[1])
    }

    levels[2]
  }

  exposed_level <- choose_level(x_levels, exposed_level)
  outcome_level <- choose_level(y_levels, outcome_level)

  unexposed_level <- setdiff(x_levels, exposed_level)
  noncase_level <- setdiff(y_levels, outcome_level)

  # Convert to binary indicators and count 2x2 cells
  exp_bin <- x == exposed_level
  out_bin <- y == outcome_level

  a <- sum(exp_bin & out_bin)
  b <- sum(exp_bin & !out_bin)
  c <- sum(!exp_bin & out_bin)
  d <- sum(!exp_bin & !out_bin)

  n_exp <- a + b
  n_unexp <- c + d
  n_total <- a + b + c + d

  # Helper formatters
  .fmt_num <- function(z, digits = 2) {
    ifelse(
      is.na(z),
      NA_character_,
      sprintf(paste0("%.", digits, "f"), z)
    )
  }

  .fmt_pct <- function(z, digits = 1) {
    ifelse(
      is.na(z),
      NA_character_,
      sprintf(paste0("%.", digits, "f"), z)
    )
  }

  .fmt_p <- function(p, digits = 3) {
    if (is.na(p)) {
      return(NA_character_)
    }

    if (p < 0.001) {
      return("<0.001")
    }

    sprintf(paste0("%.", digits, "f"), p)
  }

  # Exact binomial confidence interval for risks
  .prop_ci_exact <- function(successes, total, conf.level = 0.95) {
    if (is.na(total) || total <= 0) {
      return(c(NA_real_, NA_real_))
    }

    bt <- stats::binom.test(
      successes,
      total,
      conf.level = conf.level
    )

    unname(bt$conf.int)
  }

  .fmt_prop_ci <- function(successes, total, conf.level = 0.95,
                           digits = 1) {
    if (is.na(total) || total <= 0) {
      return(NA_character_)
    }

    p <- 100 * successes / total
    ci <- .prop_ci_exact(successes, total, conf.level)

    paste0(
      .fmt_pct(p, digits), "% (",
      .fmt_pct(100 * ci[1], digits), "\u2013",
      .fmt_pct(100 * ci[2], digits), "%)"
    )
  }

  # Log-scale CI for risk ratio with continuity correction when needed
  safe_log_rr <- function(a, b, c, d, conf.level = 0.95) {
    if (any(c(a, b, c, d) == 0)) {
      a <- a + 0.5
      b <- b + 0.5
      c <- c + 0.5
      d <- d + 0.5
    }

    rr <- (a / (a + b)) / (c / (c + d))
    se <- sqrt(
      (1 / a) - (1 / (a + b)) +
        (1 / c) - (1 / (c + d))
    )

    z <- stats::qnorm(1 - (1 - conf.level) / 2)
    ci <- exp(log(rr) + c(-1, 1) * z * se)

    list(est = rr, low = ci[1], high = ci[2])
  }

  # Log-scale CI for odds ratio with continuity correction when needed
  safe_log_or <- function(a, b, c, d, conf.level = 0.95) {
    if (any(c(a, b, c, d) == 0)) {
      a <- a + 0.5
      b <- b + 0.5
      c <- c + 0.5
      d <- d + 0.5
    }

    or <- (a * d) / (b * c)
    se <- sqrt(1 / a + 1 / b + 1 / c + 1 / d)

    z <- stats::qnorm(1 - (1 - conf.level) / 2)
    ci <- exp(log(or) + c(-1, 1) * z * se)

    list(est = or, low = ci[1], high = ci[2])
  }

  # Wald CI for risk difference
  safe_rd <- function(a, b, c, d, conf.level = 0.95) {
    p1 <- a / (a + b)
    p0 <- c / (c + d)
    rd <- p1 - p0

    se <- sqrt(
      (p1 * (1 - p1) / (a + b)) +
        (p0 * (1 - p0) / (c + d))
    )

    z <- stats::qnorm(1 - (1 - conf.level) / 2)
    ci <- rd + c(-1, 1) * z * se

    list(est = rd, low = ci[1], high = ci[2])
  }

  # Core epidemiological measures
  risk_exp <- if (n_exp > 0) a / n_exp else NA_real_
  risk_unexp <- if (n_unexp > 0) c / n_unexp else NA_real_

  risk_exp_ci <- .prop_ci_exact(a, n_exp, conf.level)
  risk_unexp_ci <- .prop_ci_exact(c, n_unexp, conf.level)

  rr_res <- safe_log_rr(a, b, c, d, conf.level = conf.level)
  or_res <- safe_log_or(a, b, c, d, conf.level = conf.level)
  rd_res <- safe_rd(a, b, c, d, conf.level = conf.level)

  # Choose chi-square or Fisher test
  mat <- matrix(c(a, b, c, d), nrow = 2, byrow = TRUE)

  chosen_test <- test
  if (test == "auto") {
    expected <- suppressWarnings(
      stats::chisq.test(mat, correct = TRUE)$expected
    )

    chosen_test <- if (any(expected < 5)) {
      "fisher"
    } else {
      "chisq"
    }
  }

  if (chosen_test == "chisq") {
    fit <- suppressWarnings(
      stats::chisq.test(mat, correct = TRUE)
    )
    test_used <- "Chi-square test"
    p_value <- fit$p.value
  } else {
    fit <- stats::fisher.test(mat, conf.level = conf.level)
    test_used <- "Fisher's exact test"
    p_value <- fit$p.value
  }

  # Detailed summary output
  summary_tbl <- tibble::tibble(
    exposure = exposure_name,
    outcome = outcome_name,
    exposed_level = exposed_level,
    unexposed_level = unexposed_level,
    outcome_level = outcome_level,
    noncase_level = noncase_level,
    exposed_cases = a,
    exposed_noncases = b,
    unexposed_cases = c,
    unexposed_noncases = d,
    n_exposed = n_exp,
    n_unexposed = n_unexp,
    n_total = n_total,
    risk_exposed = risk_exp,
    risk_exposed_low = risk_exp_ci[1],
    risk_exposed_high = risk_exp_ci[2],
    risk_unexposed = risk_unexp,
    risk_unexposed_low = risk_unexp_ci[1],
    risk_unexposed_high = risk_unexp_ci[2],
    rr = rr_res$est,
    rr_low = rr_res$low,
    rr_high = rr_res$high,
    or = or_res$est,
    or_low = or_res$low,
    or_high = or_res$high,
    rd = rd_res$est,
    rd_low = rd_res$low,
    rd_high = rd_res$high,
    test_used = test_used,
    p_value = p_value
  )

  # Build display-ready table rows
  rows <- list(
    tibble::tibble(
      Measure = paste0("Exposed (", exposed_level, ")"),
      Value = paste0(a, "/", n_exp)
    ),
    tibble::tibble(
      Measure = paste0("Unexposed (", unexposed_level, ")"),
      Value = paste0(c, "/", n_unexp)
    )
  )

  if ("risk" %in% measures) {
    rows <- c(
      rows,
      list(
        tibble::tibble(
          Measure = "Risk in exposed",
          Value = .fmt_prop_ci(a, n_exp, conf.level, digits)
        ),
        tibble::tibble(
          Measure = "Risk in unexposed",
          Value = .fmt_prop_ci(c, n_unexp, conf.level, digits)
        )
      )
    )
  }

  if ("rr" %in% measures) {
    rows <- c(
      rows,
      list(
        tibble::tibble(
          Measure = "Risk ratio",
          Value = paste0(
            .fmt_num(rr_res$est, digits), " (",
            .fmt_num(rr_res$low, digits), "\u2013",
            .fmt_num(rr_res$high, digits), ")"
          )
        )
      )
    )
  }

  if ("or" %in% measures) {
    rows <- c(
      rows,
      list(
        tibble::tibble(
          Measure = "Odds ratio",
          Value = paste0(
            .fmt_num(or_res$est, digits), " (",
            .fmt_num(or_res$low, digits), "\u2013",
            .fmt_num(or_res$high, digits), ")"
          )
        )
      )
    )
  }

  if ("rd" %in% measures) {
    rows <- c(
      rows,
      list(
        tibble::tibble(
          Measure = "Risk difference",
          Value = paste0(
            .fmt_pct(100 * rd_res$est, digits), " pp (",
            .fmt_pct(100 * rd_res$low, digits), " to ",
            .fmt_pct(100 * rd_res$high, digits), ")"
          )
        )
      )
    )
  }

  rows <- c(
    rows,
    list(
      tibble::tibble(
        Measure = "P-value",
        Value = paste0(.fmt_p(p_value, 3), "\u1d43")
      )
    )
  )

  table_tbl <- dplyr::bind_rows(rows)

  result <- list(
    inputs = list(
      data_name = deparse(substitute(data)),
      exposure = exposure_name,
      outcome = outcome_name,
      exposed_level = exposed_level,
      outcome_level = outcome_level,
      measures = measures,
      conf.level = conf.level,
      digits = digits,
      test = test,
      output = output
    ),
    summary = summary_tbl,
    table = table_tbl,
    notes = c(
      paste0(
        "Risks are shown as % with ",
        round(conf.level * 100),
        "% exact binomial confidence intervals."
      ),
      paste0(
        "Risk ratio, odds ratio, and risk difference are ",
        "shown with ",
        round(conf.level * 100),
        "% confidence intervals."
      ),
      paste0("\u1d43 P-value from ", test_used, ".")
    ),
    call = match.call()
  )

  class(result) <- "gt_twobytwo"
  result
}
