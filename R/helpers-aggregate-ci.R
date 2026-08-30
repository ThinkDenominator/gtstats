.resolve_aggregate_column <- function(data, expr, env, arg) {
  if (identical(expr, quote(NULL))) return(NULL)
  evaluated <- tryCatch(eval(expr, env), error = function(error) NULL)
  column <- if (is.character(evaluated) && length(evaluated) == 1L) {
    evaluated
  } else if (is.symbol(expr)) {
    deparse(expr)
  } else if (is.character(expr) && length(expr) == 1L) {
    expr
  } else {
    stop("`", arg, "` must identify one column.", call. = FALSE)
  }
  if (!column %in% names(data)) {
    stop("`", arg, "` column `", column, "` was not found in the table data.", call. = FALSE)
  }
  if (!is.numeric(data[[column]])) {
    stop("`", arg, "` column `", column, "` must be numeric.", call. = FALSE)
  }
  column
}

.add_aggregate_ci <- function(
    x,
    type,
    estimate_expr,
    numerator_expr,
    denominator_expr,
    sd_expr,
    n_expr,
    se_expr,
    env,
    conf.level,
    method,
    digits,
    multiplier,
    ci_name
) {
  if (is.null(type)) {
    stop(
      "For an already summarised table, supply `type = \"proportion\"`, \"rate\", \"mean\", or \"normal\".",
      call. = FALSE
    )
  }
  type <- match.arg(type, c("proportion", "rate", "mean", "normal"))
  .validate_conf_level(conf.level)
  if (is.null(digits)) digits <- 1L
  .validate_digits(digits)
  if (!is.numeric(multiplier) || length(multiplier) != 1L ||
      is.na(multiplier) || multiplier <= 0) {
    stop("`multiplier` must be one positive number.", call. = FALSE)
  }
  if (!is.null(ci_name) &&
      (!is.character(ci_name) || length(ci_name) != 1L ||
       is.na(ci_name) || !nzchar(trimws(ci_name)))) {
    stop("`ci_name` must be NULL or one non-empty column name.", call. = FALSE)
  }

  columns <- list(
    estimate = .resolve_aggregate_column(x$table, estimate_expr, env, "estimate"),
    numerator = .resolve_aggregate_column(x$table, numerator_expr, env, "numerator"),
    denominator = .resolve_aggregate_column(x$table, denominator_expr, env, "denominator"),
    sd = .resolve_aggregate_column(x$table, sd_expr, env, "sd"),
    n = .resolve_aggregate_column(x$table, n_expr, env, "n"),
    se = .resolve_aggregate_column(x$table, se_expr, env, "se")
  )
  required <- switch(
    type,
    proportion = c("numerator", "denominator"),
    rate = c("numerator", "denominator"),
    mean = c("estimate", "sd", "n"),
    normal = c("estimate", "se")
  )
  absent <- required[vapply(columns[required], is.null, logical(1))]
  if (length(absent)) {
    stop(
      "`type = \"", type, "\"` requires: ",
      paste0("`", required, "`", collapse = ", "), ".",
      call. = FALSE
    )
  }

  values <- lapply(columns[required], function(column) x$table[[column]])
  complete <- Reduce(`&`, lapply(values, is.finite))
  interval <- matrix(NA_real_, nrow = nrow(x$table), ncol = 2L)

  if (identical(type, "proportion")) {
    successes <- values$numerator
    totals <- values$denominator
    invalid <- complete & (
      successes < 0 | totals <= 0 | successes > totals |
        successes != round(successes) | totals != round(totals)
    )
    if (any(invalid)) {
      stop("Proportion inputs require integer `numerator` and `denominator` values with 0 <= numerator <= denominator and denominator > 0.", call. = FALSE)
    }
    interval[complete, ] <- t(vapply(which(complete), function(i) {
      100 * .binomial_ci(successes[[i]], totals[[i]], conf.level, method)
    }, numeric(2)))
    note <- paste0(
      .conf_level_label(conf.level), " uses the ",
      if (identical(method, "wilson")) "Wilson score" else "exact binomial",
      " interval for the percentage."
    )
  } else if (identical(type, "rate")) {
    events <- values$numerator
    exposure <- values$denominator
    invalid <- complete & (events < 0 | events != round(events) | exposure <= 0)
    if (any(invalid)) {
      stop("Rate inputs require a non-negative integer `numerator` and a positive `denominator` representing person-time or exposure.", call. = FALSE)
    }
    interval[complete, ] <- t(vapply(which(complete), function(i) {
      result <- .poisson_rate_summary(
        events[[i]], exposure[[i]], multiplier = multiplier,
        conf.level = conf.level
      )
      c(result$conf_low, result$conf_high)
    }, numeric(2)))
    note <- paste0(
      .conf_level_label(conf.level), " uses the exact Poisson interval; rates are expressed per ",
      .format_number(multiplier, 0), " units of person-time or exposure."
    )
  } else if (identical(type, "mean")) {
    means <- values$estimate
    spreads <- values$sd
    sample_sizes <- values$n
    invalid <- complete & (
      spreads < 0 | sample_sizes < 2 | sample_sizes != round(sample_sizes)
    )
    if (any(invalid)) {
      stop("Mean inputs require `sd >= 0` and an integer `n >= 2`.", call. = FALSE)
    }
    critical <- stats::qt((1 + conf.level) / 2, df = sample_sizes[complete] - 1)
    margin <- critical * spreads[complete] / sqrt(sample_sizes[complete])
    interval[complete, ] <- cbind(means[complete] - margin, means[complete] + margin)
    note <- paste0(.conf_level_label(conf.level), " is a t-based confidence interval for the mean.")
  } else {
    estimates <- values$estimate
    standard_errors <- values$se
    invalid <- complete & standard_errors < 0
    if (any(invalid)) stop("Normal intervals require `se >= 0`.", call. = FALSE)
    critical <- stats::qnorm((1 + conf.level) / 2)
    margin <- critical * standard_errors[complete]
    interval[complete, ] <- cbind(
      estimates[complete] - margin,
      estimates[complete] + margin
    )
    note <- paste0(
      .conf_level_label(conf.level),
      " uses the normal approximation (estimate +/- z x SE)."
    )
  }

  ci_name <- trimws(ci_name %||% .conf_level_label(conf.level))
  if (ci_name %in% names(x$table)) {
    stop("The confidence-interval column `", ci_name, "` already exists.", call. = FALSE)
  }
  formatted <- rep(NA_character_, nrow(x$table))
  available <- is.finite(interval[, 1L]) & is.finite(interval[, 2L])
  suffix <- if (identical(type, "proportion")) "%" else ""
  formatted[available] <- paste0(
    .format_number(interval[available, 1L], digits), "\u2013",
    .format_number(interval[available, 2L], digits), suffix
  )
  x$table[[ci_name]] <- formatted
  x$summary <- x$table
  x$notes <- unique(c(x$notes %||% character(), note))
  x$ci <- list(
    type = type,
    columns = columns[required],
    conf.level = conf.level,
    method = if (identical(type, "proportion")) method else switch(
      type, rate = "exact_poisson", mean = "t", normal = "normal"
    ),
    multiplier = if (identical(type, "rate")) multiplier else NULL,
    column = ci_name
  )
  x
}
