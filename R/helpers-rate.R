# Shared event-rate helpers ------------------------------------------------

.poisson_rate_summary <- function(events, person_time, multiplier = 1,
                                  conf.level = 0.95) {
  if (is.na(events) || is.na(person_time) || person_time <= 0) {
    return(list(
      events = events,
      person_time = person_time,
      rate = NA_real_,
      conf_low = NA_real_,
      conf_high = NA_real_
    ))
  }

  fit <- stats::poisson.test(
    x = events,
    T = person_time,
    conf.level = conf.level
  )

  list(
    events = events,
    person_time = person_time,
    rate = unname(fit$estimate) * multiplier,
    conf_low = unname(fit$conf.int[[1L]]) * multiplier,
    conf_high = unname(fit$conf.int[[2L]]) * multiplier
  )
}

.format_rate_summary <- function(result, digits = 1L, ci = TRUE) {
  if (is.na(result$rate)) {
    return(NA_character_)
  }
  estimate <- .format_number(result$rate, digits)
  if (!isTRUE(ci)) {
    return(estimate)
  }

  paste0(
    estimate,
    " (",
    .format_ci(result$conf_low, result$conf_high, digits),
    ")"
  )
}
