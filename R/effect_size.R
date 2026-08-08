# ---- effect size helpers ----

# Return a consistent internal effect-size record.
.effect_size_result <- function(
    estimate = NA_real_,
    type = NA_character_,
    symbol = NA_character_,
    conf_low = NA_real_,
    conf_high = NA_real_,
    interval_method = NA_character_
) {
  list(
    estimate = estimate,
    type = type,
    symbol = symbol,
    conf_low = conf_low,
    conf_high = conf_high,
    interval_method = interval_method
  )
}

# Hedges' g for two independent groups or paired measurements.
#
# Independent comparisons use the root-mean-square of the two group SDs. This
# does not impose the pooled-variance assumption contradicted by a Welch test.
# The CI is a large-sample normal interval based on the sampling variance of the
# standardized difference. Paired comparisons standardize the paired
# differences.
.hedges_g_result <- function(
    x1,
    x2,
    paired = FALSE,
    conf.level = 0.95
) {
  if (isTRUE(paired)) {
    keep <- !is.na(x1) & !is.na(x2)
    d_values <- x1[keep] - x2[keep]
    n <- length(d_values)
    if (n < 3L) return(.effect_size_result())
    s <- stats::sd(d_values)
    if (is.na(s) || s == 0) return(.effect_size_result())

    d <- mean(d_values) / s
    df <- n - 1
    correction <- 1 - 3 / (4 * df - 1)
    g <- correction * d
    variance <- correction^2 * (1 / n + d^2 / (2 * df))
    type <- "Paired Hedges' g"
  } else {
    x1 <- x1[!is.na(x1)]
    x2 <- x2[!is.na(x2)]
    n1 <- length(x1)
    n2 <- length(x2)
    if (n1 < 2L || n2 < 2L) return(.effect_size_result())

    s1 <- stats::sd(x1)
    s2 <- stats::sd(x2)
    scale <- sqrt((s1^2 + s2^2) / 2)
    if (is.na(scale) || scale == 0) return(.effect_size_result())

    d <- (mean(x1) - mean(x2)) / scale
    variance_df <- (s1^2 / n1 + s2^2 / n2)^2 /
      (
        (s1^2 / n1)^2 / (n1 - 1) +
          (s2^2 / n2)^2 / (n2 - 1)
      )
    correction <- 1 - 3 / (4 * variance_df - 1)
    g <- correction * d
    variance <- correction^2 * (
      (s1^2 / n1 + s2^2 / n2) / scale^2 +
        d^2 / (2 * variance_df)
    )
    type <- "Hedges' g"
  }

  se <- sqrt(variance)
  critical <- stats::qnorm(1 - (1 - conf.level) / 2)
  .effect_size_result(
    estimate = g,
    type = type,
    symbol = "g",
    conf_low = g - critical * se,
    conf_high = g + critical * se,
    interval_method = "Approximate large-sample normal interval"
  )
}

# Omega-squared from an omnibus F statistic. For Welch ANOVA this is an
# approximate variance-explained index derived from its F statistic and dfs.
.omega_squared_result <- function(statistic, df1, df2, welch = FALSE) {
  if (any(is.na(c(statistic, df1, df2))) || statistic < 0) {
    return(.effect_size_result())
  }
  value <- max(
    0,
    (statistic * df1 - df1) /
      (statistic * df1 + df2 + 1)
  )
  .effect_size_result(
    estimate = value,
    type = if (welch) {
      "Omega-squared (Welch approximation)"
    } else {
      "Omega-squared"
    },
    symbol = "\u03c9\u00b2"
  )
}

# Epsilon-squared for a Kruskal-Wallis comparison.
.epsilon_squared_result <- function(statistic, n, groups) {
  if (any(is.na(c(statistic, n, groups))) || n <= groups) {
    return(.effect_size_result())
  }
  .effect_size_result(
    estimate = max(0, (statistic - groups + 1) / (n - groups)),
    type = "Epsilon-squared",
    symbol = "\u03b5\u00b2"
  )
}

# Calculate effect size for supported inferential tests.
.compute_effect_size <- function(
    x1 = NULL,
    x2 = NULL,
    tab = NULL,
    test_used = NULL
) {
  # Cohen's d for independent or paired t-tests
  if (test_used %in% c(
    "Student t-test",
    "Welch t-test",
    "Paired t-test"
  )) {
    if (is.null(x1) || is.null(x2)) {
      return(NA_real_)
    }

    if (test_used == "Paired t-test") {
      d <- x1 - x2
      d <- d[!is.na(d)]

      if (length(d) < 2) {
        return(NA_real_)
      }

      s_d <- stats::sd(d)

      if (is.na(s_d) || s_d == 0) {
        return(NA_real_)
      }

      return(mean(d) / s_d)
    }

    x1 <- x1[!is.na(x1)]
    x2 <- x2[!is.na(x2)]

    n1 <- length(x1)
    n2 <- length(x2)

    if (n1 < 2 || n2 < 2) {
      return(NA_real_)
    }

    s1 <- stats::sd(x1)
    s2 <- stats::sd(x2)

    if (any(is.na(c(s1, s2)))) {
      return(NA_real_)
    }

    sp <- sqrt(
      ((n1 - 1) * s1^2 + (n2 - 1) * s2^2) /
        (n1 + n2 - 2)
    )

    if (is.na(sp) || sp == 0) {
      return(NA_real_)
    }

    return((mean(x1) - mean(x2)) / sp)
  }

  # Rank-biserial correlation for Wilcoxon rank-sum test
  if (test_used == "Wilcoxon rank-sum test") {
    if (is.null(x1) || is.null(x2)) {
      return(NA_real_)
    }

    x1 <- x1[!is.na(x1)]
    x2 <- x2[!is.na(x2)]

    n1 <- length(x1)
    n2 <- length(x2)

    if (n1 == 0 || n2 == 0) {
      return(NA_real_)
    }

    fit <- suppressWarnings(
      stats::wilcox.test(x1, x2, exact = FALSE)
    )

    # stats::wilcox.test() reports the Mann-Whitney statistic after subtracting
    # the minimum rank sum for the first sample. It is therefore already U,
    # despite being named W in the returned object.
    U <- unname(fit$statistic)

    return((2 * U) / (n1 * n2) - 1)
  }

  # Matched rank-biserial correlation for signed-rank test
  if (test_used == "Wilcoxon signed-rank test") {
    if (is.null(x1) || is.null(x2)) {
      return(NA_real_)
    }

    d <- x1 - x2
    d <- d[!is.na(d) & d != 0]
    n <- length(d)

    if (n == 0) {
      return(NA_real_)
    }

    fit <- suppressWarnings(
      stats::wilcox.test(
        x1,
        x2,
        paired = TRUE,
        exact = FALSE
      )
    )

    V <- unname(fit$statistic)
    total_rank <- n * (n + 1) / 2

    return((2 * V / total_rank) - 1)
  }

  # Cramer's V for chi-square and Fisher-based comparisons
  if (test_used %in% c("Chi-square test", "Fisher's exact test")) {
    if (is.null(tab)) {
      return(NA_real_)
    }

    chi <- suppressWarnings(
      tryCatch(
        unname(stats::chisq.test(tab, correct = FALSE)$statistic),
        error = function(e) NA_real_
      )
    )

    n <- sum(tab)
    r <- nrow(tab)
    k <- ncol(tab)

    if (is.na(chi) || n == 0 || min(r, k) < 2) {
      return(NA_real_)
    }

    return(sqrt(chi / (n * min(r - 1, k - 1))))
  }

  NA_real_
}

# Convert a numeric effect size into a qualitative label.
.interpret_effect_size <- function(
    value = NA_real_,
    type = NA_character_
) {
  if (is.na(value) || is.na(type)) {
    return(NA_character_)
  }

  a <- abs(value)

  if (type %in% c("Cohen's d", "Hedges' g", "Paired Hedges' g")) {
    if (a < 0.2) {
      return("Negligible")
    }
    if (a < 0.5) {
      return("Small")
    }
    if (a < 0.8) {
      return("Medium")
    }
    if (a < 1.2) {
      return("Large")
    }
    return("Very large")
  }

  if (type %in% c(
    "Rank-biserial correlation",
    "Matched rank-biserial correlation"
  )) {
    if (a < 0.1) {
      return("Negligible")
    }
    if (a < 0.3) {
      return("Small")
    }
    if (a < 0.5) {
      return("Medium")
    }
    return("Large")
  }

  if (type == "Cramer's V") {
    if (a < 0.1) {
      return("Negligible")
    }
    if (a < 0.3) {
      return("Small")
    }
    if (a < 0.5) {
      return("Medium")
    }
    return("Large")
  }

  if (type %in% c(
    "Omega-squared",
    "Omega-squared (Welch approximation)",
    "Epsilon-squared"
  )) {
    if (a < 0.01) {
      return("Negligible")
    }
    if (a < 0.06) {
      return("Small")
    }
    if (a < 0.14) {
      return("Medium")
    }
    return("Large")
  }

  NA_character_
}
