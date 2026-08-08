# Shared continuous-distribution assessment -------------------------------

.sample_skewness <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) < 3L) {
    return(NA_real_)
  }

  s <- stats::sd(x)
  if (is.na(s) || s == 0) {
    return(0)
  }

  m <- mean(x)
  mean((x - m)^3) / (s^3)
}

.distribution_decision <- function(
    n,
    skewness,
    shapiro_p = NA_real_,
    skew_cutoff = 1,
    min_n = 3L
) {
  if (n < min_n || is.na(skewness)) {
    return(list(
      distribution = "Unable to assess",
      recommended_summary = "Review manually",
      suggested_approach = "Review manually",
      suggested_2_group_test = NA_character_,
      suggested_multi_group_test = NA_character_,
      decision_reason = paste0(
        "Fewer than ", min_n, " non-missing observations."
      ),
      teaching_note = paste0(
        "There are too few observations to assess the distribution reliably."
      )
    ))
  }

  if (abs(skewness) >= skew_cutoff) {
    return(list(
      distribution = "Skewed",
      recommended_summary = "Median (IQR)",
      suggested_approach = "Non-parametric may be appropriate",
      suggested_2_group_test = "Wilcoxon rank-sum",
      suggested_multi_group_test = "Kruskal-Wallis",
      decision_reason = paste0(
        "Absolute skewness is at or above ", skew_cutoff, "."
      ),
      teaching_note = paste0(
        "The median and IQR are usually easier to interpret for skewed data."
      )
    ))
  }

  if (!is.na(shapiro_p) && shapiro_p < 0.05 &&
      abs(skewness) >= skew_cutoff / 2) {
    return(list(
      distribution = "Possibly skewed",
      recommended_summary = "Median (IQR)",
      suggested_approach = "Inspect the distribution",
      suggested_2_group_test = "Wilcoxon rank-sum",
      suggested_multi_group_test = "Kruskal-Wallis",
      decision_reason = paste0(
        "Shapiro-Wilk p < 0.05 with moderate skewness."
      ),
      teaching_note = paste0(
        "Review a plot and the study design before choosing a test."
      )
    ))
  }

  list(
    distribution = "Approximately symmetric",
    recommended_summary = "Mean (SD)",
    suggested_approach = "Parametric may be reasonable",
    suggested_2_group_test = "t-test",
    suggested_multi_group_test = "ANOVA",
    decision_reason = paste0(
      "Absolute skewness is below ", skew_cutoff, "."
    ),
    teaching_note = paste0(
      "The mean and SD may be reasonable, subject to the analysis assumptions."
    )
  )
}

.assess_distribution <- function(
    x,
    normality_test = TRUE,
    skew_cutoff = 1,
    min_n = 3L
) {
  x_nonmissing <- x[!is.na(x)]
  n <- length(x_nonmissing)
  skewness <- .sample_skewness(x_nonmissing)

  shapiro_p <- NA_real_
  shapiro_note <- ""
  if (isTRUE(normality_test)) {
    if (n >= min_n && n <= 5000L) {
      shapiro_p <- tryCatch(
        stats::shapiro.test(x_nonmissing)$p.value,
        error = function(e) NA_real_
      )
    } else {
      shapiro_note <- paste0(
        "Shapiro-Wilk not run; requires ", min_n,
        " to 5000 non-missing observations."
      )
    }
  }

  decision <- .distribution_decision(
    n = n,
    skewness = skewness,
    shapiro_p = shapiro_p,
    skew_cutoff = skew_cutoff,
    min_n = min_n
  )

  c(
    list(
      n = n,
      n_missing = sum(is.na(x)),
      mean = if (n > 0L) mean(x_nonmissing) else NA_real_,
      sd = if (n > 1L) stats::sd(x_nonmissing) else NA_real_,
      median = if (n > 0L) stats::median(x_nonmissing) else NA_real_,
      q1 = if (n > 0L) {
        as.numeric(stats::quantile(x_nonmissing, 0.25, names = FALSE))
      } else {
        NA_real_
      },
      q3 = if (n > 0L) {
        as.numeric(stats::quantile(x_nonmissing, 0.75, names = FALSE))
      } else {
        NA_real_
      },
      min = if (n > 0L) min(x_nonmissing) else NA_real_,
      max = if (n > 0L) max(x_nonmissing) else NA_real_,
      skewness = skewness,
      shapiro_p = shapiro_p,
      shapiro_note = shapiro_note
    ),
    decision
  )
}
