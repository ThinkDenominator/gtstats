# Shared proportion helpers -----------------------------------------------

.select_target_level <- function(x, level = NULL, arg = "level") {
  available <- sort(unique(as.character(stats::na.omit(x))))
  if (length(available) == 0L) {
    stop("The variable has no non-missing values.", call. = FALSE)
  }

  if (!is.null(level)) {
    if (length(level) != 1L || is.na(level)) {
      stop("`", arg, "` must be one non-missing value.", call. = FALSE)
    }
    level <- as.character(level)
    if (!level %in% available) {
      stop(
        "`", arg, "` was not found. Available levels: ",
        paste(available, collapse = ", "),
        ".",
        call. = FALSE
      )
    }
    return(level)
  }

  preferred <- c("1", "Yes", "yes", "TRUE", "True", "true")
  hit <- preferred[preferred %in% available]
  if (length(hit) > 0L) {
    return(hit[[1L]])
  }
  if (length(available) == 2L) {
    return(available[[2L]])
  }
  available[[1L]]
}

.binomial_ci <- function(successes, total, conf.level = 0.95,
                         method = c("exact", "wilson")) {
  method <- match.arg(method)
  if (is.na(total) || total <= 0L) {
    return(c(low = NA_real_, high = NA_real_))
  }

  if (identical(method, "exact")) {
    interval <- stats::binom.test(
      successes,
      total,
      conf.level = conf.level
    )$conf.int
    return(stats::setNames(unname(interval), c("low", "high")))
  }

  estimate <- successes / total
  z <- stats::qnorm(1 - (1 - conf.level) / 2)
  denominator <- 1 + z^2 / total
  centre <- (estimate + z^2 / (2 * total)) / denominator
  half_width <- (
    z * sqrt(
      estimate * (1 - estimate) / total +
        z^2 / (4 * total^2)
    ) / denominator
  )

  c(low = max(0, centre - half_width), high = min(1, centre + half_width))
}

.proportion_summary <- function(x, level, conf.level = 0.95,
                                method = c("exact", "wilson")) {
  method <- match.arg(method)
  x_character <- as.character(x)
  total <- sum(!is.na(x_character))
  successes <- sum(x_character == level, na.rm = TRUE)
  interval <- .binomial_ci(
    successes,
    total,
    conf.level = conf.level,
    method = method
  )

  list(
    level = level,
    numerator = successes,
    denominator = total,
    proportion = if (total > 0L) successes / total else NA_real_,
    conf_low = unname(interval[["low"]]),
    conf_high = unname(interval[["high"]]),
    conf.level = conf.level,
    method = method
  )
}

.format_proportion_summary <- function(result, digits = 1L, ci = TRUE) {
  if (is.na(result$proportion)) {
    return(NA_character_)
  }

  estimate <- paste0(
    .format_number(100 * result$proportion, digits),
    "%"
  )
  if (!isTRUE(ci)) {
    return(estimate)
  }

  paste0(
    estimate,
    " (",
    .format_ci(
      100 * result$conf_low,
      100 * result$conf_high,
      digits = digits
    ),
    "%)"
  )
}

.format_proportion_display <- function(
    result,
    display = c("n_percent", "percent", "n_over_N_percent"),
    digits = 1L,
    ci = TRUE
) {
  display <- match.arg(display)
  if (is.na(result$proportion)) return(NA_character_)

  percentage <- paste0(
    .format_number(100 * result$proportion, digits),
    "%"
  )
  estimate <- switch(
    display,
    n_percent = paste0(result$numerator, " (", percentage, ")"),
    percent = percentage,
    n_over_N_percent = paste0(
      result$numerator,
      "/",
      result$denominator,
      " (",
      percentage,
      ")"
    )
  )
  if (!isTRUE(ci)) return(estimate)

  paste0(
    estimate,
    "; ",
    .format_ci(
      100 * result$conf_low,
      100 * result$conf_high,
      digits = digits
    ),
    "%"
  )
}
