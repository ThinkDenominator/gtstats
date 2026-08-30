#' Compare groups using common inferential tests
#'
#' Compare a variable across groups using a practical set of common
#' inferential tests.
#'
#' This function is designed for beginner-friendly and teaching-focused
#' workflows. It combines:
#' - descriptive summaries by group
#' - automatic or user-specified test selection
#' - effect size calculation where supported
#' - a simple display-ready results table
#'
#' Supported outcome types are:
#' - continuous
#' - binary
#' - categorical
#' - ordinal
#'
#' Supported tests include:
#' - `"auto"`
#' - `"t_test"`
#' - `"welch_t"`
#' - `"wilcox"`
#' - `"anova"`
#' - `"welch_anova"`
#' - `"kruskal"`
#' - `"chisq"`
#' - `"fisher"`
#' - `"mcnemar"`
#' - `"rm_anova"`
#' - `"friedman"`
#' - `"cochran_q"`
#'
#' ## Automatic selection policy
#'
#' `test = "auto"` uses the following fixed, data-driven rules. These rules are
#' intended as transparent defaults, not a substitute for a prespecified
#' analysis plan.
#'
#' - **Continuous outcome, two independent groups:** Welch t-test by default,
#'   or Student's t-test when `var_equal = TRUE`, unless
#'   marked skewness is flagged in either group, then Wilcoxon
#'   rank-sum test.
#' - **Continuous outcome, three or more independent groups:** Welch ANOVA by
#'   default, or classical one-way ANOVA when `var_equal = TRUE`, unless
#'   marked skewness is flagged in any group, then
#'   Kruskal-Wallis test.
#' - **Paired continuous outcome:** for two occasions, paired t-test unless
#'   marked skewness in within-pair differences is flagged, then Wilcoxon
#'   signed-rank; for three or more occasions, repeated-measures ANOVA unless
#'   marked skewness is flagged, then
#'   Friedman test. Repeated-measures ANOVA reports a conservative
#'   Greenhouse-Geisser-corrected p-value.
#' - **Independent ordinal, binary, or nominal categorical outcome:** Pearson chi-square
#'   test when no expected count is below 1 and no more than 20% are below 5;
#'   Fisher's exact test otherwise (Monte Carlo p-value for larger tables).
#'   This compares the distribution of all levels, which is the usual Table 1
#'   question. Use an explicit rank test (`"wilcox"` or `"kruskal"`) when the
#'   ordered scale itself is the intended estimand.
#' - **Paired ordinal outcome:** Wilcoxon signed-rank for two occasions;
#'   Friedman for three or more paired occasions.
#' - **Paired binary outcome:** McNemar test for two occasions; Cochran's Q
#'   test for three or more occasions.
#'
#' Distribution guidance uses the package's skewness assessment within each
#' group (or within-pair differences). Shapiro-Wilk is supporting information;
#' it does not by itself change the selected test. Automatic decisions, the
#' values used, and the selected method are retained in `$method`,
#' `$diagnostics`, and `$notes`.
#'
#' For independent continuous comparisons, `$diagnostics` also reports the
#' observed standard deviation and variance ratios across groups. These are
#' descriptive context only: they have no pass/fail threshold and do not alter
#' automatic test selection. `var_equal` is a user-specified analytical
#' assumption, not a variance hypothesis test: gtstats never infers it using
#' Levene, Bartlett, or F tests. Welch t-tests and Welch ANOVA are the
#' conservative defaults because they do not require equal variances.
#'
#' When `effect_size = TRUE`, the function selects an effect size from the
#' comparison structure:
#' - Hedges' g for two-group parametric comparisons
#' - rank-biserial correlation for two-group rank comparisons
#' - omega-squared for ANOVA or Welch ANOVA
#' - epsilon-squared for Kruskal-Wallis comparisons
#' - Cramer's V for categorical contingency tables
#'
#' Hedges' g is accompanied by a large-sample confidence interval. Other
#' effect-size intervals are omitted unless a supported interval method is
#' available. Conventional magnitude labels are retained in `inferential` for
#' teaching but are not displayed as clinical importance thresholds.
#'
#' @param data A data.frame.
#' @param variable Variable to compare. Can be supplied as a bare name or
#'   as a character string.
#' @param group Grouping variable. Can be supplied as a bare name or as
#'   a character string.
#' @param paired Logical; whether the comparison is paired. If `TRUE`,
#'   paired t-test, Wilcoxon signed-rank test, or McNemar test will be
#'   used where appropriate.
#' @param id Pair or participant identifier required when `paired = TRUE`.
#'   Each identifier must occur at most once in each group.
#' @param test Test to use. One of `"auto"`, `"t_test"`, `"welch_t"`,
#'   `"wilcox"`, `"anova"`, `"welch_anova"`, `"kruskal"`, `"chisq"`,
#'   `"fisher"`, `"mcnemar"`, `"rm_anova"`, `"friedman"`, or
#'   `"cochran_q"`. See **Automatic selection policy** for the
#'   exact rules used by `"auto"`.
#' @param var_equal Logical; for independent, non-skewed continuous outcomes
#'   with `test = "auto"`, use equal-variance Student's t-test (two groups) or
#'   classical one-way ANOVA (three or more groups). The default `FALSE` uses
#'   Welch methods. This is a prespecified user choice and is not tested or
#'   inferred from the observed variances. It does not affect paired,
#'   categorical, ordinal, or rank-based comparisons.
#' @param effect_size Logical; calculate and display the effect size selected
#'   for the comparison structure. Default is `FALSE`.
#' @param conf.level Confidence level for intervals.
#' @param digits Number of decimal places for formatting.
#' @param fisher_seed Integer seed used only for simulated Fisher exact tests
#'   on tables larger than 2 x 2. The default makes results reproducible.
#'   Set to `NULL` to use the current random-number state.
#' @param format Output format: `"table"` (default) or a plain console
#'   `"tibble"`.
#'
#' @return A `gt_compare` object containing:
#' \itemize{
#'   \item `inputs` — function inputs and settings
#'   \item `descriptives` — descriptive summaries by group
#'   \item `inferential` — inferential test results
#'   \item `table` — display-ready results table
#'   \item `method` — metadata on detected variable types
#'   \item `notes` — explanatory notes
#'   \item `call` — matched function call
#' }
#'
#' For paired or repeated analyses, only complete, uniquely matched identifiers
#' are analysed. The number retained and excluded is available in
#' `$denominators` and `$notes`; rendered tables also identify the complete-pair
#' denominator. Friedman and Cochran's Q require within-participant variation
#' and fail clearly when it is absent.
#'
#' @examples
#' compare_groups(mtcars, variable = mpg, group = am)
#'
#' compare_groups(
#'   mtcars,
#'   variable = mpg,
#'   group = am,
#'   effect_size = TRUE
#' )
#'
#' compare_groups(
#'   mtcars,
#'   variable = vs,
#'   group = am,
#'   test = "chisq",
#'   effect_size = TRUE
#' )
#'
#' compare_groups(
#'   mtcars,
#'   variable = mpg,
#'   group = am,
#'   paired = FALSE,
#'   test = "welch_t"
#' )
#'
#' compare_groups(mtcars, variable = mpg, group = am, var_equal = TRUE)
#'
#' to_gt(compare_groups(mtcars, variable = mpg, group = am))
#'
#' @export
compare_groups <- function(
    data,
    variable,
    group,
    paired = FALSE,
    id = NULL,
    test = c(
      "auto", "t_test", "welch_t", "wilcox",
      "anova", "welch_anova", "kruskal", "chisq", "fisher", "mcnemar",
      "rm_anova", "friedman", "cochran_q"
    ),
    effect_size = FALSE,
    conf.level = 0.95,
    digits = 2,
    var_equal = FALSE,
    fisher_seed = 1049L,
    format = c("table", "tibble")
) {
  .compare_groups_impl(
    data = data,
    outcome_expr = substitute(variable),
    group_expr = substitute(group),
    id_expr = substitute(id),
    caller_env = parent.frame(),
    user_call = match.call(),
    data_name = deparse(substitute(data)),
    paired = paired,
    test = test,
    effect_size = effect_size,
    conf.level = conf.level,
    digits = digits,
    var_equal = var_equal,
    fisher_seed = fisher_seed,
    format = format,
    distribution_check = TRUE,
    correction = TRUE,
    quiet = FALSE
  )
}

.compare_groups_impl <- function(
    data,
    outcome_expr,
    group_expr,
    id_expr,
    caller_env,
    user_call,
    data_name,
    paired = FALSE,
    test = c(
      "auto", "t_test", "welch_t", "wilcox",
      "anova", "welch_anova", "kruskal", "chisq", "fisher", "mcnemar",
      "rm_anova", "friedman", "cochran_q"
    ),
    effect_size = FALSE,
    conf.level = 0.95,
    digits = 2,
    var_equal = FALSE,
    fisher_seed = 1049L,
    format = c("table", "tibble"),
    distribution_check = TRUE,
    correction = TRUE,
    quiet = FALSE
) {
  format <- match.arg(format)
  test <- match.arg(test)
  .validate_flag(paired, "paired")
  .validate_flag(effect_size, "effect_size")
  .validate_conf_level(conf.level)
  .validate_digits(digits)
  .validate_flag(distribution_check, "distribution_check")
  .validate_flag(var_equal, "var_equal")
  .validate_flag(correction, "correction")
  .validate_flag(quiet, "quiet")
  if (!is.null(fisher_seed) &&
      (!is.numeric(fisher_seed) || length(fisher_seed) != 1L ||
       is.na(fisher_seed) || !is.finite(fisher_seed))) {
    stop("`fisher_seed` must be a single finite number or NULL.", call. = FALSE)
  }

  # Validate input data
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }

  # Resolve variable and grouping names from bare or character input
  outcome_eval <- tryCatch(
    eval(outcome_expr, caller_env),
    error = function(e) NULL
  )
  group_eval <- tryCatch(
    eval(group_expr, caller_env),
    error = function(e) NULL
  )

  outcome_is_c_call <- is.call(outcome_expr) &&
    identical(as.character(outcome_expr[[1L]]), "c")
  if (outcome_is_c_call ||
      (is.character(outcome_eval) && length(outcome_eval) > 1L)) {
    stop(
      "`compare_groups()` analyses one `variable` at a time. Supply one ",
      "outcome, for example `variable = score`. For a multi-variable Table 1, ",
      "use `summary_table()` followed by `add_p()`.",
      call. = FALSE
    )
  }

  outcome_name <- if (is.character(outcome_eval) &&
                      length(outcome_eval) == 1) {
    outcome_eval
  } else if (is.symbol(outcome_expr)) {
    deparse(outcome_expr)
  } else if (is.character(outcome_expr) &&
             length(outcome_expr) == 1) {
    outcome_expr[1]
  } else {
    deparse(outcome_expr)
  }

  group_name <- if (is.character(group_eval) &&
                    length(group_eval) == 1) {
    group_eval
  } else if (is.symbol(group_expr)) {
    deparse(group_expr)
  } else if (is.character(group_expr) &&
             length(group_expr) == 1) {
    group_expr[1]
  } else {
    deparse(group_expr)
  }

  id_name <- .resolve_var_arg(
    id_expr,
    env = caller_env,
    allow_null = TRUE
  )
  if (isTRUE(paired) && is.null(id_name)) {
    stop("`id` is required when `paired = TRUE`.", call. = FALSE)
  }
  if (!is.null(id_name) && !id_name %in% names(data)) {
    stop("`id` was not found in `data`.", call. = FALSE)
  }

  if (!outcome_name %in% names(data)) {
    stop("`variable` was not found in `data`.", call. = FALSE)
  }

  if (!group_name %in% names(data)) {
      stop("`group` was not found in `data`.", call. = FALSE)
  }

  if (outcome_name == group_name) {
    stop(
      "`variable` and `group` must be different variables.",
      call. = FALSE
    )
  }

  # Detect variable types
  outcome_var <- data[[outcome_name]]
  group_var <- data[[group_name]]

  outcome_type <- .detect_type(outcome_var)
  group_type <- .detect_type(group_var)

  if (group_type == "continuous") {
    stop(
      "`group` should be a categorical, binary, or ordinal variable.",
      call. = FALSE
    )
  }

  # Keep complete cases only
  keep <- !is.na(outcome_var) & !is.na(group_var)
  if (isTRUE(paired)) {
    keep <- keep & !is.na(data[[id_name]])
  }
  outcome_clean <- outcome_var[keep]
  group_clean <- group_var[keep]
  id_clean <- if (isTRUE(paired)) data[[id_name]][keep] else NULL

  if (length(outcome_clean) == 0) {
    stop(
      "No complete cases available for `variable` and `group`.",
      call. = FALSE
    )
  }

  group_factor <- as.factor(group_clean)
  n_groups <- nlevels(group_factor)

  paired_values <- NULL
  if (isTRUE(paired)) {
    if (n_groups < 2L) {
      stop("Paired analyses require at least two groups.", call. = FALSE)
    }

    paired_data <- data.frame(
      id = as.character(id_clean),
      group = as.character(group_clean),
      outcome = outcome_clean,
      stringsAsFactors = FALSE
    )
    if (anyDuplicated(paired_data[c("id", "group")])) {
      stop(
        "Each `id` must have at most one observation in each group.",
        call. = FALSE
      )
    }

    group_levels <- levels(group_factor)
    ids_by_group <- lapply(group_levels, function(level) {
      paired_data$id[paired_data$group == level]
    })
    common_ids <- Reduce(intersect, ids_by_group)
    if (length(common_ids) < 2L) {
      stop("At least two participants observed at every paired occasion are required.", call. = FALSE)
    }
    paired_columns <- lapply(group_levels, function(level) {
      values <- paired_data[paired_data$group == level, ]
      values$outcome[match(common_ids, values$id)]
    })
    paired_matrix <- if (is.factor(outcome_clean) || is.character(outcome_clean) || is.logical(outcome_clean)) {
      matrix(unlist(lapply(paired_columns, as.character), use.names = FALSE), nrow = length(common_ids), ncol = n_groups)
    } else {
      do.call(cbind, paired_columns)
    }
    colnames(paired_matrix) <- group_levels
    paired_values <- list(
      ids = common_ids,
      group_levels = group_levels,
      values = paired_matrix,
      x1 = if (n_groups == 2L) paired_matrix[, 1L] else NULL,
      x2 = if (n_groups == 2L) paired_matrix[, 2L] else NULL,
      n_pairs = length(common_ids)
    )
  }

  .fmt_num <- function(x, digits = 3) {
    ifelse(
      is.na(x),
      NA_character_,
      sprintf(paste0("%.", digits, "f"), x)
    )
  }

  .fmt_p <- function(p, digits = 3) {
    if (is.na(p)) {
      return(NA_character_)
    }
    threshold <- 10^(-digits)
    if (p < threshold) {
      return(paste0("<", formatC(
        threshold,
        format = "f",
        digits = digits
      )))
    }
    sprintf(paste0("%.", digits, "f"), p)
  }

  .fmt_ci <- function(low, high, digits = 3) {
    if (is.na(low) || is.na(high)) {
      return(NA_character_)
    }
    paste0(.fmt_num(low, digits), " to ", .fmt_num(high, digits))
  }

  # Filled only when `test = "auto"`. Keeping this separate from the printed
  # table makes the automatic rule inspectable without adding clutter to a
  # publication-ready result.
  selection_rule <- NULL
  selection_inputs <- NULL

  # Build descriptive summaries for continuous outcomes
  make_cont_desc <- function(
    x,
    g,
    outcome_name,
    outcome_label,
    group_name
  ) {
    levs <- levels(g)

    out <- lapply(levs, function(lev) {
      xi <- x[g == lev]
      n <- sum(!is.na(xi))
      n_missing <- sum(is.na(xi))

      mean_val <- if (n > 0) mean(xi, na.rm = TRUE) else NA_real_
      sd_val <- if (n > 1) stats::sd(xi, na.rm = TRUE) else NA_real_
      median_val <- if (n > 0) {
        stats::median(xi, na.rm = TRUE)
      } else {
        NA_real_
      }
      q1_val <- if (n > 0) {
        as.numeric(
          stats::quantile(xi, 0.25, na.rm = TRUE, names = FALSE)
        )
      } else {
        NA_real_
      }
      q3_val <- if (n > 0) {
        as.numeric(
          stats::quantile(xi, 0.75, na.rm = TRUE, names = FALSE)
        )
      } else {
        NA_real_
      }
      iqr_val <- if (n > 0) q3_val - q1_val else NA_real_

      mean_sd <- if (n > 0) {
        paste0(
          .fmt_num(mean_val, digits), " (",
          .fmt_num(sd_val, digits), ")"
        )
      } else {
        NA_character_
      }

      median_iqr <- if (n > 0) {
        paste0(
          .fmt_num(median_val, digits), " (",
          .fmt_num(q1_val, digits), "\u2013",
          .fmt_num(q3_val, digits), ")"
        )
      } else {
        NA_character_
      }

      tibble::tibble(
        outcome = outcome_name,
        label = outcome_label,
        outcome_type = "continuous",
        group = group_name,
        group_level = as.character(lev),
        level = NA_character_,
        n = n,
        n_missing = n_missing,
        mean = mean_val,
        sd = sd_val,
        median = median_val,
        q1 = q1_val,
        q3 = q3_val,
        iqr = iqr_val,
        count = NA_real_,
        percent = NA_real_,
        mean_sd = mean_sd,
        median_iqr = median_iqr,
        count_pct = NA_character_,
        display_value = paste0(mean_sd, "; ", median_iqr)
      )
    })

    dplyr::bind_rows(out)
  }

  # Build descriptive summaries for categorical outcomes
  make_cat_desc <- function(
    x,
    g,
    outcome_name,
    outcome_label,
    group_name,
    outcome_type
  ) {
    levs_group <- levels(g)
    levs_outcome <- if (is.factor(x)) {
      levels(droplevels(x[!is.na(x)]))
    } else {
      sort(unique(as.character(stats::na.omit(x))))
    }

    out <- list()

    for (gr in levs_group) {
      xi <- as.character(x[g == gr])
      tab <- table(
        factor(xi, levels = levs_outcome),
        useNA = "no"
      )

      pct <- if (sum(tab) == 0) {
        rep(NA_real_, length(tab))
      } else {
        as.numeric(tab) / sum(tab) * 100
      }

      for (j in seq_along(levs_outcome)) {
        out[[length(out) + 1]] <- tibble::tibble(
          outcome = outcome_name,
          label = outcome_label,
          outcome_type = outcome_type,
          group = group_name,
          group_level = as.character(gr),
          level = levs_outcome[j],
          n = sum(!is.na(x[g == gr])),
          n_missing = sum(is.na(x[g == gr])),
          mean = NA_real_,
          sd = NA_real_,
          median = NA_real_,
          q1 = NA_real_,
          q3 = NA_real_,
          iqr = NA_real_,
          count = as.numeric(tab[j]),
          percent = as.numeric(pct[j]),
          mean_sd = NA_character_,
          median_iqr = NA_character_,
          count_pct = paste0(
            as.numeric(tab[j]), " (",
            .fmt_num(as.numeric(pct[j]), digits), "%)"
          ),
          display_value = paste0(
            as.numeric(tab[j]), " (",
            .fmt_num(as.numeric(pct[j]), digits), "%)"
          )
        )
      }
    }

    dplyr::bind_rows(out)
  }

  if (outcome_type == "continuous") {
    descriptives_tbl <- make_cont_desc(
      x = outcome_clean,
      g = group_factor,
      outcome_name = outcome_name,
      outcome_label = .get_var_label(data, outcome_name),
      group_name = group_name
    )
    if (isTRUE(paired)) {
      descriptives_tbl <- make_cont_desc(
        x = as.vector(paired_values$values),
        g = factor(
          rep(paired_values$group_levels, each = paired_values$n_pairs),
          levels = paired_values$group_levels
        ),
        outcome_name = outcome_name,
        outcome_label = .get_var_label(data, outcome_name),
        group_name = group_name
      )
    }

    # Select the test for continuous outcomes
    chosen_test <- test
    if (test == "auto") {
      distribution_flag <- FALSE
      if (isTRUE(distribution_check)) {
        group_assessments <- if (isTRUE(paired) && n_groups == 2L) {
          list(
            .assess_distribution(
              paired_values$x1 - paired_values$x2,
              normality_test = TRUE
            )$distribution
          )
        } else if (isTRUE(paired)) {
          lapply(seq_len(ncol(paired_values$values)), function(index) {
            .assess_distribution(
              paired_values$values[, index], normality_test = TRUE
            )$distribution
          })
        } else {
          lapply(
            levels(group_factor),
            function(group_level) {
              .assess_distribution(
                outcome_clean[group_factor == group_level],
                normality_test = TRUE
              )$distribution
            }
          )
        }
        # Shapiro-Wilk remains supporting information. It can label a group
        # "Possibly skewed" in assess_distribution(), but only marked
        # skewness changes the conservative parametric automatic route.
        distribution_flag <- any(unlist(group_assessments) == "Skewed")
      }

      if (isTRUE(paired) && n_groups > 2L) {
        chosen_test <- if (distribution_flag) "friedman" else "rm_anova"
      } else if (distribution_flag && n_groups == 2L) {
        chosen_test <- "wilcox"
      } else if (distribution_flag && n_groups > 2L) {
        chosen_test <- "kruskal"
      } else if (n_groups == 2) {
        if (paired) {
          chosen_test <- "t_test"
        } else {
          chosen_test <- if (isTRUE(var_equal)) {
            "t_test"
          } else {
            "welch_t"
          }
        }
      } else {
        chosen_test <- if (isTRUE(var_equal)) "anova" else "welch_anova"
      }

      assessed_distribution <- if (isTRUE(distribution_check)) {
        paste(unlist(group_assessments), collapse = "; ")
      } else {
        "Distribution guidance disabled"
      }
      selection_inputs <- list(
        distribution_guidance = assessed_distribution,
        skewness_flagged = distribution_flag,
        groups = n_groups,
        paired = paired,
        var_equal = var_equal,
        variance_assumption_source = "User-specified; not inferred from a variance hypothesis test"
      )
      selection_rule <- if (isTRUE(paired) && n_groups > 2L) {
        if (isTRUE(distribution_flag)) {
          "Repeated continuous outcome across three or more occasions: marked skewness was flagged; selected Friedman test."
        } else {
          "Repeated continuous outcome across three or more occasions: no skewness flag; selected repeated-measures ANOVA with Greenhouse-Geisser correction."
        }
      } else if (isTRUE(paired)) {
        if (isTRUE(distribution_flag)) {
          "Paired continuous outcome: marked skewness flagged in within-pair differences; selected Wilcoxon signed-rank test."
        } else {
          "Paired continuous outcome: no skewness flag in within-pair differences; selected paired t-test."
        }
      } else if (n_groups == 2L && isTRUE(distribution_flag)) {
        "Two-group continuous outcome: marked skewness flagged in at least one group; selected Wilcoxon rank-sum test."
      } else if (n_groups == 2L) {
        if (isTRUE(var_equal)) {
          "Two-group continuous outcome: no skewness flag; equal variance was user-specified (`var_equal = TRUE`); selected Student's t-test. No variance hypothesis test was used."
        } else {
          "Two-group continuous outcome: no skewness flag; `var_equal = FALSE`; selected Welch t-test, the conservative default that does not require equal variances."
        }
      } else if (isTRUE(distribution_flag)) {
        "Multi-group continuous outcome: marked skewness flagged in at least one group; selected Kruskal-Wallis test."
      } else {
        if (isTRUE(var_equal)) {
          "Multi-group continuous outcome: no skewness flag; equal variance was user-specified (`var_equal = TRUE`); selected classical one-way ANOVA. No variance hypothesis test was used."
        } else {
          "Multi-group continuous outcome: no skewness flag; `var_equal = FALSE`; selected Welch ANOVA, the conservative default that does not require equal variances."
        }
      }
    }

    if (n_groups == 2 &&
        chosen_test %in% c("t_test", "welch_t", "wilcox")) {
      grp_levels <- levels(group_factor)
      if (isTRUE(paired)) {
        x1 <- paired_values$x1
        x2 <- paired_values$x2
      } else {
        x1 <- outcome_clean[group_factor == grp_levels[1]]
        x2 <- outcome_clean[group_factor == grp_levels[2]]
      }

      if (paired) {
        if (chosen_test %in% c("t_test", "welch_t")) {
          fit <- stats::t.test(
            x1,
            x2,
            paired = TRUE,
            conf.level = conf.level
          )
          test_used <- "Paired t-test"
          estimate_type <- "Mean within-pair difference"
          method_detail <- "Paired comparison"
          estimate_val <- mean(x1 - x2, na.rm = TRUE)
          reason_for_test <- paste0(
            "Continuous outcome compared across two paired ",
            "groups"
          )
        } else {
          fit <- stats::wilcox.test(
            x1,
            x2,
            paired = TRUE,
            conf.int = FALSE,
            conf.level = conf.level,
            exact = FALSE
          )
          test_used <- "Wilcoxon signed-rank test"
          estimate_type <- "Median difference"
          method_detail <- "Paired comparison"
          estimate_val <- if (!is.null(fit$estimate)) {
            unname(fit$estimate)
          } else {
            NA_real_
          }
          reason_for_test <- paste0(
            "Continuous outcome compared across two paired ",
            "groups"
          )
        }
      } else {
        if (chosen_test == "t_test") {
          fit <- stats::t.test(
            x1,
            x2,
            var.equal = TRUE,
            conf.level = conf.level
          )
          test_used <- "Student t-test"
          estimate_type <- "Mean difference"
          method_detail <- "Equal variances assumed"
          estimate_val <- mean(x1, na.rm = TRUE) -
            mean(x2, na.rm = TRUE)
          reason_for_test <- paste0(
            "Continuous outcome compared across two ",
            "independent groups"
          )
        } else if (chosen_test == "welch_t") {
          fit <- stats::t.test(
            x1,
            x2,
            var.equal = FALSE,
            conf.level = conf.level
          )
          test_used <- "Welch t-test"
          estimate_type <- "Mean difference"
          method_detail <- "Unequal variances assumed"
          estimate_val <- mean(x1, na.rm = TRUE) -
            mean(x2, na.rm = TRUE)
          reason_for_test <- paste0(
            "Continuous outcome compared across two ",
            "independent groups"
          )
        } else {
          fit <- stats::wilcox.test(
            x1,
            x2,
            conf.int = FALSE,
            exact = FALSE
          )
          test_used <- "Wilcoxon rank-sum test"
          estimate_type <- "Location shift"
          method_detail <- ""
          estimate_val <- if (!is.null(fit$estimate)) {
            unname(fit$estimate)
          } else {
            NA_real_
          }
          reason_for_test <- paste0(
            "Continuous outcome compared across two ",
            "independent groups"
          )
        }
      }

      interpretation_text <- if (fit$p.value < 0.05) {
        paste0(
          "There was evidence of a difference in ",
          .get_var_label(data, outcome_name),
          " across ",
          group_name,
          " groups."
        )
      } else {
        paste0(
          "There was no clear evidence of a difference in ",
          .get_var_label(data, outcome_name),
          " across ",
          group_name,
          " groups."
        )
      }

      effect_result <- .effect_size_result()
      if (isTRUE(effect_size)) {
        if (test_used %in% c(
          "Student t-test", "Welch t-test", "Paired t-test"
        )) {
          effect_result <- tryCatch(
            .hedges_g_result(
              x1,
              x2,
              paired = identical(test_used, "Paired t-test"),
              conf.level = conf.level
            ),
            error = function(e) .effect_size_result()
          )
        } else {
          effect_size_val_raw <- tryCatch(
            .compute_effect_size(
              x1 = x1,
              x2 = x2,
              test_used = test_used
            ),
            error = function(e) NA_real_
          )
          effect_result <- .effect_size_result(
            estimate = effect_size_val_raw,
            type = if (test_used == "Wilcoxon rank-sum test") {
              "Rank-biserial correlation"
            } else if (test_used == "Wilcoxon signed-rank test") {
              "Matched rank-biserial correlation"
            } else {
              NA_character_
            },
            symbol = if (test_used %in% c(
              "Wilcoxon rank-sum test", "Wilcoxon signed-rank test"
            )) "r" else NA_character_
          )
        }
      }
      effect_size_val <- effect_result$estimate
      effect_size_type_val <- effect_result$type

      effect_size_interpretation_val <- .interpret_effect_size(
        value = effect_size_val,
        type = effect_size_type_val
      )

      inferential_tbl <- tibble::tibble(
        outcome = outcome_name,
        label = .get_var_label(data, outcome_name),
        outcome_type = outcome_type,
        group = group_name,
        group_levels = n_groups,
        test_requested = test,
        test_used = test_used,
        paired = paired,
        statistic = unname(fit$statistic),
        df = if (!is.null(fit$parameter)) {
          unname(fit$parameter)
        } else {
          NA_real_
        },
        p_value = fit$p.value,
        estimate = estimate_val,
        estimate_type = estimate_type,
        conf_low = if (!is.null(fit$conf.int)) {
          fit$conf.int[1]
        } else {
          NA_real_
        },
        conf_high = if (!is.null(fit$conf.int)) {
          fit$conf.int[2]
        } else {
          NA_real_
        },
        conf_level = conf.level,
        effect_size = effect_size_val,
        effect_size_type = effect_size_type_val,
        effect_size_symbol = effect_result$symbol,
        effect_conf_low = effect_result$conf_low,
        effect_conf_high = effect_result$conf_high,
        effect_interval_method = effect_result$interval_method,
        effect_size_interpretation =
          effect_size_interpretation_val,
        method_detail = method_detail,
        reason_for_test = reason_for_test,
        interpretation = interpretation_text,
        notes = ""
      )
    } else if (isTRUE(paired) && n_groups > 2L &&
               chosen_test %in% c("rm_anova", "friedman")) {
      repeated_long <- data.frame(
        id = factor(rep(paired_values$ids, times = n_groups)),
        group = factor(
          rep(paired_values$group_levels, each = paired_values$n_pairs),
          levels = paired_values$group_levels
        ),
        outcome = as.vector(paired_values$values)
      )
      if (identical(chosen_test, "friedman")) {
        within_person_variation <- apply(
          paired_values$values,
          1L,
          function(values) length(unique(values)) > 1L
        )
        if (!any(within_person_variation)) {
          stop(
            "Friedman test cannot be calculated because there is no within-participant variation across occasions.",
            call. = FALSE
          )
        }
        fit <- stats::friedman.test(paired_values$values)
        if (!is.finite(fit$p.value)) {
          stop(
            "Friedman test was not estimable from the complete paired observations. Review within-participant variation and coding.",
            call. = FALSE
          )
        }
        statistic <- unname(fit$statistic)
        df1 <- unname(fit$parameter)
        p_value <- fit$p.value
        test_label <- "Friedman test"
        method_detail <- "Repeated rank-based comparison across complete participants"
      } else {
        fit <- stats::aov(outcome ~ group + Error(id), data = repeated_long)
        within <- summary(fit)[["Error: Within"]][[1L]]
        statistic <- within[["F value"]][1L]
        df1 <- within[["Df"]][1L]
        df2 <- within[["Df"]][2L]
        centred_cov <- {
          centre <- diag(n_groups) - matrix(1 / n_groups, n_groups, n_groups)
          centre %*% stats::cov(paired_values$values) %*% centre
        }
        eigenvalues <- eigen(centred_cov, symmetric = TRUE,
                             only.values = TRUE)$values
        eigenvalues <- eigenvalues[eigenvalues >
          sqrt(.Machine$double.eps) * max(abs(eigenvalues), 1)]
        gg_epsilon <- if (length(eigenvalues) == 0L ||
                          sum(eigenvalues^2) == 0) {
          1
        } else {
          (sum(eigenvalues)^2) /
            ((n_groups - 1) * sum(eigenvalues^2))
        }
        gg_epsilon <- min(1, max(1 / (n_groups - 1), gg_epsilon))
        p_value <- stats::pf(
          statistic,
          df1 = df1 * gg_epsilon,
          df2 = df2 * gg_epsilon,
          lower.tail = FALSE
        )
        test_label <- "Repeated-measures ANOVA"
        method_detail <- paste0(
          "Greenhouse-Geisser correction applied; epsilon = ",
          .fmt_num(gg_epsilon, 3),
          ". Corrected df = ", .fmt_num(df1 * gg_epsilon, 2),
          ", ", .fmt_num(df2 * gg_epsilon, 2), "."
        )
      }
      interpretation_text <- if (p_value < 0.05) {
        paste0("There was evidence of a difference in ", .get_var_label(data, outcome_name), " across repeated ", group_name, " occasions.")
      } else {
        paste0("There was no clear evidence of a difference in ", .get_var_label(data, outcome_name), " across repeated ", group_name, " occasions.")
      }
      inferential_tbl <- tibble::tibble(
        outcome = outcome_name, label = .get_var_label(data, outcome_name),
        outcome_type = outcome_type, group = group_name, group_levels = n_groups,
        test_requested = test, test_used = test_label, paired = paired,
        statistic = statistic, df = df1, p_value = p_value,
        estimate = NA_real_, estimate_type = NA_character_, conf_low = NA_real_,
        conf_high = NA_real_, conf_level = conf.level,
        effect_size = NA_real_, effect_size_type = NA_character_,
        effect_size_symbol = NA_character_, effect_conf_low = NA_real_,
        effect_conf_high = NA_real_, effect_interval_method = NA_character_,
        effect_size_interpretation = NA_character_, method_detail = method_detail,
        reason_for_test = "Continuous outcome compared across three or more repeated occasions",
        interpretation = interpretation_text, notes = ""
      )
    } else if (n_groups > 2 &&
               chosen_test %in% c("anova", "welch_anova", "kruskal")) {
      df_tmp <- data.frame(
        outcome = outcome_clean,
        group = group_factor
      )

      if (chosen_test %in% c("anova", "welch_anova")) {
        if (chosen_test == "welch_anova") {
          fit <- stats::oneway.test(
            outcome ~ group,
            data = df_tmp,
            var.equal = FALSE
          )
          statistic <- unname(fit$statistic)
          p_value <- fit$p.value
          df1 <- unname(fit$parameter[[1L]])
          df2 <- unname(fit$parameter[[2L]])
          test_label <- "Welch ANOVA"
          method_detail <- paste0(
            "Unequal variances allowed; denominator df = ",
            .fmt_num(df2, digits)
          )
        } else {
        fit <- stats::aov(outcome ~ group, data = df_tmp)
        sm <- summary(fit)[[1]]
        statistic <- sm[["F value"]][1]
        p_value <- sm[["Pr(>F)"]][1]
        df1 <- sm[["Df"]][1]
        df2 <- sm[["Df"]][2]
          test_label <- "ANOVA"
          method_detail <- paste0("Residual df = ", df2)
        }

        interpretation_text <- if (p_value < 0.05) {
          paste0(
            "There was evidence of a difference in ",
            .get_var_label(data, outcome_name),
            " across ",
            group_name,
            " groups."
          )
        } else {
          paste0(
            "There was no clear evidence of a difference in ",
            .get_var_label(data, outcome_name),
            " across ",
            group_name,
            " groups."
          )
        }

        omnibus_effect <- if (isTRUE(effect_size)) {
          .omega_squared_result(
            statistic,
            df1,
            df2,
            welch = identical(chosen_test, "welch_anova")
          )
        } else {
          .effect_size_result()
        }

        inferential_tbl <- tibble::tibble(
          outcome = outcome_name,
          label = .get_var_label(data, outcome_name),
          outcome_type = outcome_type,
          group = group_name,
          group_levels = n_groups,
          test_requested = test,
          test_used = test_label,
          paired = paired,
          statistic = statistic,
          df = df1,
          p_value = p_value,
          estimate = NA_real_,
          estimate_type = NA_character_,
          conf_low = NA_real_,
          conf_high = NA_real_,
          conf_level = conf.level,
          effect_size = omnibus_effect$estimate,
          effect_size_type = omnibus_effect$type,
          effect_size_symbol = omnibus_effect$symbol,
          effect_conf_low = omnibus_effect$conf_low,
          effect_conf_high = omnibus_effect$conf_high,
          effect_interval_method = omnibus_effect$interval_method,
          effect_size_interpretation = .interpret_effect_size(
            omnibus_effect$estimate,
            omnibus_effect$type
          ),
          method_detail = method_detail,
          reason_for_test = paste0(
            "Continuous outcome compared across more than ",
            "two independent groups"
          ),
          interpretation = interpretation_text,
          notes = ""
        )
      } else {
        fit <- stats::kruskal.test(outcome_clean, group_factor)

        interpretation_text <- if (fit$p.value < 0.05) {
          paste0(
            "There was evidence of a difference in ",
            .get_var_label(data, outcome_name),
            " across ",
            group_name,
            " groups."
          )
        } else {
          paste0(
            "There was no clear evidence of a difference in ",
            .get_var_label(data, outcome_name),
            " across ",
            group_name,
            " groups."
          )
        }

        omnibus_effect <- if (isTRUE(effect_size)) {
          .epsilon_squared_result(
            unname(fit$statistic),
            length(outcome_clean),
            n_groups
          )
        } else {
          .effect_size_result()
        }

        inferential_tbl <- tibble::tibble(
          outcome = outcome_name,
          label = .get_var_label(data, outcome_name),
          outcome_type = outcome_type,
          group = group_name,
          group_levels = n_groups,
          test_requested = test,
          test_used = "Kruskal-Wallis test",
          paired = paired,
          statistic = unname(fit$statistic),
          df = unname(fit$parameter),
          p_value = fit$p.value,
          estimate = NA_real_,
          estimate_type = NA_character_,
          conf_low = NA_real_,
          conf_high = NA_real_,
          conf_level = conf.level,
          effect_size = omnibus_effect$estimate,
          effect_size_type = omnibus_effect$type,
          effect_size_symbol = omnibus_effect$symbol,
          effect_conf_low = omnibus_effect$conf_low,
          effect_conf_high = omnibus_effect$conf_high,
          effect_interval_method = omnibus_effect$interval_method,
          effect_size_interpretation = .interpret_effect_size(
            omnibus_effect$estimate,
            omnibus_effect$type
          ),
          method_detail = "",
          reason_for_test = paste0(
            "Continuous outcome compared across more than ",
            "two independent groups"
          ),
          interpretation = interpretation_text,
          notes = ""
        )
      }
    } else {
      stop(
        paste0(
          "Requested `test` is not compatible with the current ",
          "outcome/group structure."
        ),
        call. = FALSE
      )
    }

    infer_row <- inferential_tbl[1, ]

    table_tbl <- tibble::tibble(
      Outcome = .get_var_label(data, outcome_name),
      Comparison = paste0(group_name, " (", n_groups, " groups)"),
      Test = infer_row$test_used,
      Statistic = if (!is.na(infer_row$statistic)) {
        .fmt_num(infer_row$statistic, digits)
      } else {
        NA_character_
      },
      `p-value` = .fmt_p(infer_row$p_value, digits),
      Estimate = if (!is.na(infer_row$estimate)) {
        .fmt_num(infer_row$estimate, digits)
      } else {
        NA_character_
      },
      `95% CI` = .fmt_ci(
        infer_row$conf_low,
        infer_row$conf_high,
        digits
      ),
      `Effect size` = if (!is.na(infer_row$effect_size)) {
        .fmt_num(infer_row$effect_size, digits)
      } else {
        NA_character_
      },
      `Effect size type` = infer_row$effect_size_type,
      `Effect size interpretation` =
        infer_row$effect_size_interpretation,
      Interpretation = infer_row$interpretation
    )

  } else {
    descriptives_tbl <- make_cat_desc(
      x = outcome_clean,
      g = group_factor,
      outcome_name = outcome_name,
      outcome_label = .get_var_label(data, outcome_name),
      group_name = group_name,
      outcome_type = outcome_type
    )
    if (isTRUE(paired)) {
      descriptives_tbl <- make_cat_desc(
        x = as.vector(paired_values$values),
        g = factor(
          rep(paired_values$group_levels, each = paired_values$n_pairs),
          levels = paired_values$group_levels
        ),
        outcome_name = outcome_name,
        outcome_label = .get_var_label(data, outcome_name),
        group_name = group_name,
        outcome_type = outcome_type
      )
    }

    # Select the test for categorical outcomes
    tab <- table(group_factor, outcome_clean)
    paired_tab <- if (isTRUE(paired) && n_groups == 2L) {
      outcome_levels <- sort(unique(as.character(outcome_clean)))
      table(
        factor(as.character(paired_values$x1), levels = outcome_levels),
        factor(as.character(paired_values$x2), levels = outcome_levels)
      )
    } else {
      NULL
    }
    expected_counts <- if (!isTRUE(paired)) {
      suppressWarnings(stats::chisq.test(tab, correct = correction)$expected)
    } else {
      NULL
    }
    expected_screen <- if (!isTRUE(paired)) {
      .expected_count_screen(expected_counts)
    } else {
      NULL
    }

    chosen_test <- test
    if (test == "auto") {
      if (identical(outcome_type, "ordinal") && isTRUE(paired)) {
        chosen_test <- if (n_groups > 2L) "friedman" else "wilcox"
        selection_rule <- if (n_groups > 2L) {
          "Repeated ordinal outcome across three or more occasions: selected Friedman test."
        } else {
          "Paired ordinal outcome at two occasions: selected Wilcoxon signed-rank test."
        }
        selection_inputs <- list(groups = n_groups, outcome_type = "ordinal", paired = TRUE)
      } else if (paired && n_groups == 2 && outcome_type == "binary") {
        chosen_test <- "mcnemar"
        selection_rule <- "Paired binary outcome: selected McNemar test."
        selection_inputs <- list(groups = n_groups, outcome_type = "binary", paired = TRUE)
      } else if (paired && n_groups > 2L && outcome_type == "binary") {
        chosen_test <- "cochran_q"
        selection_rule <- "Repeated binary outcome across three or more occasions: selected Cochran's Q test."
        selection_inputs <- list(groups = n_groups, outcome_type = "binary", paired = TRUE)
      } else {
        if (expected_screen$sparse) {
          chosen_test <- "fisher"
        } else {
          chosen_test <- "chisq"
        }
        outcome_description <- if (identical(outcome_type, "ordinal")) {
          "Independent ordinal outcome: compared the distribution of ordered levels"
        } else {
          "Independent categorical outcome"
        }
        selection_rule <- if (expected_screen$sparse) {
          paste0(outcome_description, "; expected cell count guidance was not met (an expected count below 1 or more than 20% below 5); selected Fisher's exact test.")
        } else {
          paste0(outcome_description, "; expected cell count guidance was met (no expected count below 1 and no more than 20% below 5); selected Pearson chi-square test.")
        }
        selection_inputs <- list(
          groups = n_groups,
          outcome_type = outcome_type,
          minimum_expected_count = min(expected_counts),
          expected_count_threshold = "No expected count < 1 and <=20% below 5",
          expected_count_screen = expected_screen
        )
      }
    }

    if (identical(outcome_type, "ordinal") &&
        chosen_test %in% c("wilcox", "kruskal", "friedman")) {
      ordinal_scores <- as.numeric(outcome_clean)
      if (identical(chosen_test, "wilcox") && n_groups == 2L) {
        group_levels <- levels(group_factor)
        x1 <- ordinal_scores[group_factor == group_levels[[1L]]]
        x2 <- ordinal_scores[group_factor == group_levels[[2L]]]
        if (isTRUE(paired)) {
          x1 <- as.numeric(paired_values$x1)
          x2 <- as.numeric(paired_values$x2)
        }
        fit <- stats::wilcox.test(
          x1,
          x2,
          paired = paired,
          exact = FALSE
        )
        test_label <- if (paired) {
          "Wilcoxon signed-rank test"
        } else {
          "Wilcoxon rank-sum test"
        }
        effect_size_val <- if (isTRUE(effect_size)) {
          tryCatch(
            .compute_effect_size(
              x1 = x1,
              x2 = x2,
              test_used = test_label
            ),
            error = function(e) NA_real_
          )
        } else {
          NA_real_
        }
        effect_size_type_val <- if (!is.na(effect_size_val)) {
          if (paired) {
            "Matched rank-biserial correlation"
          } else {
            "Rank-biserial correlation"
          }
        } else {
          NA_character_
        }
        statistic_val <- unname(fit$statistic)
        df_val <- NA_real_
      } else if (identical(chosen_test, "friedman") && isTRUE(paired) && n_groups > 2L) {
        ordinal_matrix <- apply(paired_values$values, 2L, function(values) {
          match(as.character(values), levels(outcome_clean))
        })
        within_person_variation <- apply(
          ordinal_matrix,
          1L,
          function(values) length(unique(values)) > 1L
        )
        if (!any(within_person_variation)) {
          stop(
            "Friedman test cannot be calculated because there is no within-participant variation across occasions.",
            call. = FALSE
          )
        }
        fit <- stats::friedman.test(ordinal_matrix)
        if (!is.finite(fit$p.value)) {
          stop(
            "Friedman test was not estimable from the complete paired observations. Review within-participant variation and coding.",
            call. = FALSE
          )
        }
        test_label <- "Friedman test"
        effect_size_val <- NA_real_
        effect_size_type_val <- NA_character_
        statistic_val <- unname(fit$statistic)
        df_val <- unname(fit$parameter)
      } else if (identical(chosen_test, "kruskal") && n_groups > 2L) {
        fit <- stats::kruskal.test(ordinal_scores, group_factor)
        test_label <- "Kruskal-Wallis test"
        ordinal_effect <- if (isTRUE(effect_size)) {
          .epsilon_squared_result(
            unname(fit$statistic),
            length(ordinal_scores),
            n_groups
          )
        } else {
          .effect_size_result()
        }
        effect_size_val <- ordinal_effect$estimate
        effect_size_type_val <- ordinal_effect$type
        statistic_val <- unname(fit$statistic)
        df_val <- unname(fit$parameter)
      } else {
        stop(
          "Requested rank test is not compatible with the ordinal comparison.",
          call. = FALSE
        )
      }

      inferential_tbl <- tibble::tibble(
        outcome = outcome_name,
        label = .get_var_label(data, outcome_name),
        outcome_type = outcome_type,
        group = group_name,
        group_levels = n_groups,
        test_requested = test,
        test_used = test_label,
        paired = paired,
        statistic = statistic_val,
        df = df_val,
        p_value = fit$p.value,
        estimate = NA_real_,
        estimate_type = NA_character_,
        conf_low = NA_real_,
        conf_high = NA_real_,
        conf_level = conf.level,
        effect_size = effect_size_val,
        effect_size_type = effect_size_type_val,
        effect_size_interpretation = .interpret_effect_size(
          effect_size_val,
          effect_size_type_val
        ),
        method_detail = "Ordered levels analysed using their ranks",
        reason_for_test = "Ordinal outcome compared across groups",
        interpretation = "",
        notes = ""
      )
    } else if (chosen_test == "mcnemar") {
      if (!(paired && n_groups == 2 &&
            outcome_type == "binary")) {
        stop(
          paste0(
            "`mcnemar` requires a paired binary outcome with ",
            "exactly 2 groups."
          ),
          call. = FALSE
        )
      }

      fit <- stats::mcnemar.test(paired_tab, correct = correction)

      interpretation_text <- if (fit$p.value < 0.05) {
        paste0(
          "There was evidence of a difference in paired ",
          "proportions of ",
          .get_var_label(data, outcome_name),
          "."
        )
      } else {
        paste0(
          "There was no clear evidence of a difference in ",
          "paired proportions of ",
          .get_var_label(data, outcome_name),
          "."
        )
      }

      inferential_tbl <- tibble::tibble(
        outcome = outcome_name,
        label = .get_var_label(data, outcome_name),
        outcome_type = outcome_type,
        group = group_name,
        group_levels = n_groups,
        test_requested = test,
        test_used = "McNemar test",
        paired = TRUE,
        statistic = unname(fit$statistic),
        df = unname(fit$parameter),
        p_value = fit$p.value,
        estimate = NA_real_,
        estimate_type = NA_character_,
        conf_low = NA_real_,
        conf_high = NA_real_,
        conf_level = conf.level,
        effect_size = NA_real_,
        effect_size_type = NA_character_,
        effect_size_interpretation = NA_character_,
        method_detail = "Paired binary comparison",
        reason_for_test = "Paired categorical outcome comparison",
        interpretation = interpretation_text,
        notes = ""
      )
    } else if (chosen_test == "cochran_q") {
      if (!(isTRUE(paired) && n_groups > 2L && outcome_type == "binary")) {
        stop("`cochran_q` requires a paired binary outcome with three or more groups.", call. = FALSE)
      }
      binary_levels <- levels(factor(as.character(outcome_clean)))
      binary_matrix <- apply(paired_values$values, 2L, function(values) {
        as.integer(factor(as.character(values), levels = binary_levels)) - 1L
      })
      column_totals <- colSums(binary_matrix)
      row_totals <- rowSums(binary_matrix)
      total <- sum(column_totals)
      denominator <- n_groups * total - sum(row_totals^2)
      if (!is.finite(denominator) || denominator <= 0) {
        stop("Cochran's Q test cannot be calculated because there is no usable within-participant variation.", call. = FALSE)
      }
      statistic_q <- (n_groups - 1) * (n_groups * sum(column_totals^2) - total^2) / denominator
      p_q <- stats::pchisq(statistic_q, df = n_groups - 1L, lower.tail = FALSE)
      interpretation_text <- if (p_q < 0.05) {
        paste0("There was evidence that paired proportions of ", .get_var_label(data, outcome_name), " differed across repeated ", group_name, " occasions.")
      } else {
        paste0("There was no clear evidence that paired proportions of ", .get_var_label(data, outcome_name), " differed across repeated ", group_name, " occasions.")
      }
      inferential_tbl <- tibble::tibble(
        outcome = outcome_name, label = .get_var_label(data, outcome_name),
        outcome_type = outcome_type, group = group_name, group_levels = n_groups,
        test_requested = test, test_used = "Cochran's Q test", paired = TRUE,
        statistic = statistic_q, df = n_groups - 1L, p_value = p_q,
        estimate = NA_real_, estimate_type = NA_character_, conf_low = NA_real_,
        conf_high = NA_real_, conf_level = conf.level, effect_size = NA_real_,
        effect_size_type = NA_character_, effect_size_interpretation = NA_character_,
        method_detail = "Repeated binary comparison across complete participants",
        reason_for_test = "Binary outcome compared across three or more repeated occasions",
        interpretation = interpretation_text, notes = ""
      )
    } else if (chosen_test == "chisq") {
      fit <- suppressWarnings(stats::chisq.test(tab, correct = correction))

      interpretation_text <- if (fit$p.value < 0.05) {
        paste0(
          "There was evidence that the distribution of ",
          .get_var_label(data, outcome_name),
          " differed across ",
          group_name,
          " groups."
        )
      } else {
        paste0(
          "There was no clear evidence that the distribution of ",
          .get_var_label(data, outcome_name),
          " differed across ",
          group_name,
          " groups."
        )
      }

      effect_size_val <- if (isTRUE(effect_size)) {
        tryCatch(
          .compute_effect_size(
            tab = tab,
            test_used = "Chi-square test"
          ),
          error = function(e) NA_real_
        )
      } else {
        NA_real_
      }

      effect_size_type_val <- if (isTRUE(effect_size)) {
        "Cramer's V"
      } else {
        NA_character_
      }

      effect_size_interpretation_val <- .interpret_effect_size(
        value = effect_size_val,
        type = effect_size_type_val
      )

      inferential_tbl <- tibble::tibble(
        outcome = outcome_name,
        label = .get_var_label(data, outcome_name),
        outcome_type = outcome_type,
        group = group_name,
        group_levels = n_groups,
        test_requested = test,
        test_used = "Chi-square test",
        paired = paired,
        statistic = unname(fit$statistic),
        df = unname(fit$parameter),
        p_value = fit$p.value,
        estimate = NA_real_,
        estimate_type = NA_character_,
        conf_low = NA_real_,
        conf_high = NA_real_,
        conf_level = conf.level,
        effect_size = effect_size_val,
        effect_size_type = effect_size_type_val,
        effect_size_interpretation =
          effect_size_interpretation_val,
        method_detail = if (correction) {
          "Continuity correction used where applicable"
        } else {
          ""
        },
        reason_for_test =
          "Categorical outcome compared across groups",
        interpretation = interpretation_text,
        notes = ""
      )
    } else if (chosen_test == "fisher") {
      fisher_simulated <- nrow(tab) > 2L || ncol(tab) > 2L
      if (fisher_simulated && !is.null(fisher_seed)) {
        old_seed_exists <- exists(".Random.seed", envir = .GlobalEnv,
                                  inherits = FALSE)
        if (old_seed_exists) old_seed <- get(".Random.seed", envir = .GlobalEnv)
        on.exit({
          if (old_seed_exists) {
            assign(".Random.seed", old_seed, envir = .GlobalEnv)
          } else if (exists(".Random.seed", envir = .GlobalEnv,
                            inherits = FALSE)) {
            rm(".Random.seed", envir = .GlobalEnv)
          }
        }, add = TRUE)
        set.seed(as.integer(fisher_seed))
      }
      fit <- stats::fisher.test(
        tab,
        conf.level = conf.level,
        simulate.p.value = fisher_simulated,
        B = if (fisher_simulated) 10000L else 2000L
      )

      interpretation_text <- if (fit$p.value < 0.05) {
        paste0(
          "There was evidence that the distribution of ",
          .get_var_label(data, outcome_name),
          " differed across ",
          group_name,
          " groups."
        )
      } else {
        paste0(
          "There was no clear evidence that the distribution of ",
          .get_var_label(data, outcome_name),
          " differed across ",
          group_name,
          " groups."
        )
      }

      effect_size_val <- if (isTRUE(effect_size)) {
        tryCatch(
          .compute_effect_size(
            tab = tab,
            test_used = "Fisher's exact test"
          ),
          error = function(e) NA_real_
        )
      } else {
        NA_real_
      }

      effect_size_type_val <- if (isTRUE(effect_size)) {
        "Cramer's V"
      } else {
        NA_character_
      }

      effect_size_interpretation_val <- .interpret_effect_size(
        value = effect_size_val,
        type = effect_size_type_val
      )

      inferential_tbl <- tibble::tibble(
        outcome = outcome_name,
        label = .get_var_label(data, outcome_name),
        outcome_type = outcome_type,
        group = group_name,
        group_levels = n_groups,
        test_requested = test,
        test_used = if (fisher_simulated) {
          "Fisher's exact test (Monte Carlo p-value)"
        } else {
          "Fisher's exact test"
        },
        paired = paired,
        statistic = NA_real_,
        df = NA_real_,
        p_value = fit$p.value,
        estimate = if (!is.null(fit$estimate)) {
          unname(fit$estimate[1])
        } else {
          NA_real_
        },
        estimate_type = if (!is.null(fit$estimate)) {
          "Odds ratio"
        } else {
          NA_character_
        },
        conf_low = if (!is.null(fit$conf.int)) {
          fit$conf.int[1]
        } else {
          NA_real_
        },
        conf_high = if (!is.null(fit$conf.int)) {
          fit$conf.int[2]
        } else {
          NA_real_
        },
        conf_level = conf.level,
        effect_size = effect_size_val,
        effect_size_type = effect_size_type_val,
        effect_size_interpretation =
          effect_size_interpretation_val,
        method_detail = if (fisher_simulated) {
          "Monte Carlo p-value (10,000 simulations) for a table larger than 2x2"
        } else "",
        reason_for_test = "Categorical outcome compared across groups with inadequate expected-count guidance",
        interpretation = interpretation_text,
        notes = ""
      )
    } else {
      stop(
        paste0(
          "Requested `test` is not compatible with the current ",
          "outcome/group structure."
        ),
        call. = FALSE
      )
    }

    infer_row <- inferential_tbl[1, ]

    table_tbl <- tibble::tibble(
      Outcome = .get_var_label(data, outcome_name),
      Comparison = paste0(group_name, " (", n_groups, " groups)"),
      Test = infer_row$test_used,
      Statistic = if (!is.na(infer_row$statistic)) {
        .fmt_num(infer_row$statistic, digits)
      } else {
        NA_character_
      },
      `p-value` = .fmt_p(infer_row$p_value, digits),
      Estimate = if (!is.na(infer_row$estimate)) {
        .fmt_num(infer_row$estimate, digits)
      } else {
        NA_character_
      },
      `95% CI` = .fmt_ci(
        infer_row$conf_low,
        infer_row$conf_high,
        digits
      ),
      `Effect size` = if (!is.na(infer_row$effect_size)) {
        .fmt_num(infer_row$effect_size, digits)
      } else {
        NA_character_
      },
      `Effect size type` = infer_row$effect_size_type,
      `Effect size interpretation` =
        infer_row$effect_size_interpretation,
      Interpretation = infer_row$interpretation
    )
  }

  # Standardise effect-size metadata across every analysis branch. Unsupported
  # intervals remain absent rather than being silently approximated.
  effect_defaults <- list(
    effect_size_symbol = NA_character_,
    effect_conf_low = NA_real_,
    effect_conf_high = NA_real_,
    effect_interval_method = NA_character_
  )
  for (field in names(effect_defaults)) {
    if (!field %in% names(inferential_tbl)) {
      inferential_tbl[[field]] <- effect_defaults[[field]]
    }
  }
  if (isTRUE(effect_size) && !is.na(inferential_tbl$effect_size[[1L]]) &&
      is.na(inferential_tbl$effect_size_symbol[[1L]])) {
    inferential_tbl$effect_size_symbol[[1L]] <- dplyr::case_when(
      inferential_tbl$effect_size_type[[1L]] == "Cramer's V" ~ "V",
      inferential_tbl$effect_size_type[[1L]] %in% c(
        "Rank-biserial correlation",
        "Matched rank-biserial correlation"
      ) ~ "r",
      inferential_tbl$effect_size_type[[1L]] == "Epsilon-squared" ~
        "\u03b5\u00b2",
      inferential_tbl$effect_size_type[[1L]] %in% c(
        "Omega-squared",
        "Omega-squared (Welch approximation)"
      ) ~ "\u03c9\u00b2",
      TRUE ~ NA_character_
    )
  }

  # Build the concise publication table. Detailed test statistics, degrees of
  # freedom, selection reasons, and diagnostics remain in `inferential`.
  infer_row <- inferential_tbl[1, ]
  group_levels_display <- levels(group_factor)
  group_levels_label <- .display_level(group_levels_display)
  group_n <- vapply(
    group_levels_display,
    function(level) {
      if (isTRUE(paired)) {
        paired_values$n_pairs
      } else {
        sum(group_factor == level)
      }
    },
    integer(1)
  )
  group_columns <- stats::setNames(
    paste0(group_levels_label, "\nN = ", group_n),
    group_levels_display
  )

  estimate_label <- infer_row$estimate_type[[1L]]
  estimate_display <- NA_character_
  if (!is.na(infer_row$estimate[[1L]])) {
    estimate_display <- .fmt_num(infer_row$estimate[[1L]], digits)
    if (!is.na(infer_row$conf_low[[1L]]) &&
        !is.na(infer_row$conf_high[[1L]])) {
      estimate_display <- paste0(
        estimate_display,
        " (",
        .fmt_num(infer_row$conf_low[[1L]], digits),
        " to ",
        .fmt_num(infer_row$conf_high[[1L]], digits),
        ")"
      )
    }
  }

  if (identical(outcome_type, "continuous")) {
    rank_based <- infer_row$test_used[[1L]] %in% c(
      "Wilcoxon rank-sum test",
      "Wilcoxon signed-rank test",
      "Kruskal-Wallis test"
    )
    summary_field <- if (rank_based) "median_iqr" else "mean_sd"

    table_tbl <- tibble::tibble(
      Variable = .get_var_label(data, outcome_name)
    )
    for (i in seq_along(group_levels_display)) {
      level <- group_levels_display[[i]]
      desc_row <- descriptives_tbl[
        descriptives_tbl$group_level == level,
        ,
        drop = FALSE
      ]
      table_tbl[[group_columns[[i]]]] <-
        desc_row[[summary_field]][[1L]]
    }
    if (!is.na(estimate_display)) {
      estimate_header <- if (
        !is.na(infer_row$conf_low[[1L]]) &&
        !is.na(infer_row$conf_high[[1L]])
      ) {
        paste0(
          estimate_label,
          " (",
          .conf_level_label(conf.level),
          ")"
        )
      } else {
        estimate_label
      }
      table_tbl[[estimate_header]] <- estimate_display
    }
    if (isTRUE(effect_size) && !is.na(infer_row$effect_size[[1L]])) {
      effect_display <- paste0(
        infer_row$effect_size_symbol[[1L]],
        " = ",
        .fmt_num(infer_row$effect_size[[1L]], digits)
      )
      if (!is.na(infer_row$effect_conf_low[[1L]]) &&
          !is.na(infer_row$effect_conf_high[[1L]])) {
        effect_display <- paste0(
          effect_display,
          " (",
          .fmt_num(infer_row$effect_conf_low[[1L]], digits),
          " to ",
          .fmt_num(infer_row$effect_conf_high[[1L]], digits),
          ")"
        )
      }
      effect_header <- if (
        !is.na(infer_row$effect_conf_low[[1L]]) &&
        !is.na(infer_row$effect_conf_high[[1L]])
      ) {
        paste0("Effect size (", .conf_level_label(conf.level), ")")
      } else {
        "Effect size"
      }
      table_tbl[[effect_header]] <- effect_display
    }
    table_tbl[["p-value"]] <- .fmt_p(infer_row$p_value[[1L]], digits)
  } else {
    outcome_levels <- unique(descriptives_tbl$level)
    table_tbl <- tibble::tibble(
      Variable = c(
        .get_var_label(data, outcome_name),
        rep("", max(length(outcome_levels) - 1L, 0L))
      ),
      Level = outcome_levels
    )
    for (i in seq_along(group_levels_display)) {
      level <- group_levels_display[[i]]
      values <- descriptives_tbl[
        descriptives_tbl$group_level == level,
        c("level", "count_pct"),
        drop = FALSE
      ]
      table_tbl[[group_columns[[i]]]] <-
        values$count_pct[match(outcome_levels, values$level)]
    }
    if (!is.na(estimate_display)) {
      estimate_header <- if (
        !is.na(infer_row$conf_low[[1L]]) &&
        !is.na(infer_row$conf_high[[1L]])
      ) {
        paste0(
          estimate_label,
          " (",
          .conf_level_label(conf.level),
          ")"
        )
      } else {
        estimate_label
      }
      table_tbl[[estimate_header]] <- c(
        estimate_display,
        rep("", max(length(outcome_levels) - 1L, 0L))
      )
    }
    if (isTRUE(effect_size) && !is.na(infer_row$effect_size[[1L]])) {
      table_tbl[["Effect size"]] <- c(
        paste0(
          infer_row$effect_size_symbol[[1L]],
          " = ",
          .fmt_num(infer_row$effect_size[[1L]], digits)
        ),
        rep("", max(length(outcome_levels) - 1L, 0L))
      )
    }
    table_tbl[["p-value"]] <- c(
      .fmt_p(infer_row$p_value[[1L]], digits),
      rep("", max(length(outcome_levels) - 1L, 0L))
    )
  }

  test_used_final <- inferential_tbl$test_used[[1L]]
  assumptions_tbl <- dplyr::bind_rows(
    .assumptions_tbl(
      assumption = if (isTRUE(paired)) {
        "Independence between pairs"
      } else {
        "Independent observations"
      },
      status = "user_check",
      result = "not_checked",
      detail = if (isTRUE(paired)) {
        "Confirm that matched pairs are independent of other matched pairs."
      } else {
        "Confirm from the study design that each observation contributes independently."
      }
    ),
    if (test_used_final %in% c(
      "Student t-test", "Welch t-test", "Paired t-test",
      "ANOVA", "Welch ANOVA", "Repeated-measures ANOVA"
    )) {
      .assumptions_tbl(
        assumption = "Distribution and influential outliers",
        status = if (isTRUE(distribution_check)) "partly_checked" else "user_check",
        result = if (
          isTRUE(distribution_check) &&
          exists("distribution_flag") &&
          !isTRUE(distribution_flag)
        ) "no_skew_flag" else "not_checked",
        detail = if (identical(test_used_final, "Repeated-measures ANOVA")) {
          "Inspect repeated-measures residuals for influential outliers and severe asymmetry. The p-value uses a Greenhouse-Geisser sphericity correction."
        } else if (isTRUE(paired)) {
          "Inspect the within-pair differences for influential outliers and severe asymmetry."
        } else {
          "Inspect group distributions or model residuals for influential outliers and severe asymmetry."
        }
      )
    } else if (test_used_final %in% c(
      "Wilcoxon rank-sum test",
      "Kruskal-Wallis test", "Friedman test"
    )) {
      .assumptions_tbl(
        assumption = "Comparable distribution shapes",
        status = "user_check",
        result = "not_checked",
        detail = "Required when interpreting the rank-based result specifically as a location or median shift."
      )
    } else if (test_used_final == "Wilcoxon signed-rank test") {
      .assumptions_tbl(
        assumption = "Symmetry of non-zero paired differences",
        status = "user_check",
        result = "not_checked",
        detail = "Inspect the distribution of within-pair differences."
      )
    } else {
      .empty_assumptions()
    },
    if (test_used_final == "Repeated-measures ANOVA") {
      .assumptions_tbl(
        assumption = "Sphericity",
        status = "partly_checked",
        result = "greenhouse_geisser_corrected",
        detail = "The reported p-value uses Greenhouse-Geisser-corrected degrees of freedom; consider a mixed-effects model when covariance structure or incomplete follow-up is central."
      )
    } else if (test_used_final %in% c("Chi-square test", "Fisher's exact test", "Fisher's exact test (Monte Carlo p-value)")) {
      .assumptions_tbl(
        assumption = c(
          "Mutually exclusive categories",
          "Adequate expected cell counts"
        ),
        status = c("user_check", "checked"),
        result = c(
          "not_checked",
          if (
            exists("expected_counts") &&
            !is.null(expected_counts) &&
            !is.null(expected_screen) && !isTRUE(expected_screen$sparse)
          ) "guidance_met" else "sparse"
        ),
        detail = c(
          "Confirm that every observation contributes to one category per variable.",
          "Automatic selection uses Fisher's exact test when any expected count is below 1 or more than 20% are below 5."
        )
      )
    } else if (test_used_final == "McNemar test") {
      .assumptions_tbl(
        assumption = "Correctly matched binary observations",
        status = "partly_checked",
        result = "aligned_by_id",
        detail = "Identifiers were aligned and duplicate id/group records were rejected; confirm the clinical pairing."
      )
    } else if (test_used_final == "Cochran's Q test") {
      .assumptions_tbl(
        assumption = "Correctly matched binary observations",
        status = "partly_checked",
        result = "aligned_by_id",
        detail = "Identifiers were aligned across all occasions and duplicate id/group records were rejected; confirm the clinical pairing."
      )
    } else {
      .empty_assumptions()
    }
  )

  # Make observed group spread visible without using a variance-test
  # gatekeeper. Welch methods are already the parametric defaults for
  # independent continuous comparisons, so this diagnostic is context for
  # interpretation rather than an input to automatic selection.
  variation_diagnostic <- .empty_diagnostics()
  variation_inputs <- NULL
  if (outcome_type == "continuous" && !isTRUE(paired)) {
    group_spread <- lapply(levels(group_factor), function(group_level) {
      values <- outcome_clean[group_factor == group_level]
      values <- values[is.finite(values)]
      n_values <- length(values)
      tibble::tibble(
        group = as.character(group_level),
        n = n_values,
        sd = if (n_values >= 2L) stats::sd(values) else NA_real_,
        variance = if (n_values >= 2L) stats::var(values) else NA_real_
      )
    }) |> dplyr::bind_rows()

    usable_sd <- group_spread$sd[is.finite(group_spread$sd)]
    usable_variance <- group_spread$variance[
      is.finite(group_spread$variance)
    ]
    sd_ratio <- if (length(usable_sd) >= 2L) {
      max(usable_sd) / min(usable_sd)
    } else {
      NA_real_
    }
    variance_ratio <- if (length(usable_variance) >= 2L) {
      max(usable_variance) / min(usable_variance)
    } else {
      NA_real_
    }
    group_values <- paste0(
      group_spread$group, " (n = ", group_spread$n,
      "): SD ", .fmt_num(group_spread$sd, 2),
      "; variance ", .fmt_num(group_spread$variance, 2)
    )

    variation_inputs <- list(
      group_spread = group_spread,
      sd_ratio = sd_ratio,
      variance_ratio = variance_ratio
    )
    variation_diagnostic <- .diagnostics_tbl(
      check = "Observed group spread",
      result = if (is.finite(sd_ratio) && is.finite(variance_ratio)) {
        "descriptive_context"
      } else {
        "not_fully_estimable"
      },
      value = if (is.finite(sd_ratio) && is.finite(variance_ratio)) {
        paste0(
          paste(group_values, collapse = "; "),
          "; SD ratio = ", .fmt_num(sd_ratio, 2),
          "; variance ratio = ", .fmt_num(variance_ratio, 2)
        )
      } else {
        paste0(
          paste(group_values, collapse = "; "),
          "; ratios need at least two groups with two finite observations."
        )
      },
      threshold = "Descriptive diagnostic; no pass/fail threshold",
      detail = paste(
        "Observed spread is descriptive only; no Levene, Bartlett, or F test was performed.",
        if (isTRUE(var_equal)) {
          "`var_equal = TRUE` is a user-specified equal-variance assumption for the parametric auto route."
        } else {
          "`var_equal = FALSE` retains Welch methods as the conservative parametric auto default."
        }
      )
    )
  }
  if (!is.null(selection_inputs) && !is.null(variation_inputs)) {
    selection_inputs$observed_group_spread <- variation_inputs
  }

  diagnostics_tbl <- dplyr::bind_rows(
    .diagnostics_tbl(
      check = "Comparison design",
      result = if (isTRUE(paired)) "paired" else "independent",
      value = if (isTRUE(paired)) "Paired observations" else "Independent observations",
      threshold = "Defined by the study design",
      detail = if (isTRUE(paired)) {
          if (n_groups == 2L) "Paired routes use within-pair differences; `var_equal` does not apply." else "Repeated-measures routes align the same participants across all occasions; `var_equal` does not apply."
      } else {
        "Independent comparison; confirm independence from the study design."
      }
    ),
    if (outcome_type == "continuous" && !isTRUE(paired)) {
      .diagnostics_tbl(
        check = "Variance assumption",
        result = if (isTRUE(var_equal)) "equal_variance_user_specified" else "welch_default",
        value = paste0("var_equal = ", if (isTRUE(var_equal)) "TRUE" else "FALSE"),
        threshold = "User-specified analytical assumption",
        detail = if (isTRUE(var_equal)) {
          "Equal variance was specified by the user. It is not inferred or proven by Levene, Bartlett, or F tests."
        } else {
          "Welch is the conservative default and does not require equal variances. No variance hypothesis test was used."
        }
      )
    } else {
      .diagnostics_tbl(
        check = "Variance assumption",
        result = "not_applicable",
        value = paste0("var_equal = ", if (isTRUE(var_equal)) "TRUE" else "FALSE"),
        threshold = "Applies only to independent parametric continuous comparisons",
        detail = "`var_equal` does not alter paired, categorical, ordinal, or rank-based routes."
      )
    },
    if (identical(test, "auto") && !is.null(selection_rule)) {
      .diagnostics_tbl(
        check = "Automatic test selection",
        result = inferential_tbl$test_used[[1L]],
        value = if (!is.null(selection_inputs$minimum_expected_count)) {
          .fmt_num(selection_inputs$minimum_expected_count, 2)
        } else if (!is.null(selection_inputs$distribution_guidance)) {
          selection_inputs$distribution_guidance
        } else {
          as.character(selection_inputs$outcome_type %||% outcome_type)
        },
        threshold = if (!is.null(selection_inputs$expected_count_threshold)) {
          "No expected count below 1 and no more than 20% below 5"
        } else if (!is.null(selection_inputs$distribution_guidance)) {
          "No marked group-level skewness flag for parametric default"
        } else {
          "Outcome type and comparison design"
        },
        detail = selection_rule
      )
    } else {
      .empty_diagnostics()
    },
    if (
      outcome_type == "continuous" &&
      isTRUE(distribution_check) &&
      exists("group_assessments")
    ) {
      distributions <- unlist(group_assessments)
      .diagnostics_tbl(
        check = "Distribution guidance",
        result = if (any(distributions == "Skewed")) {
          "rank_based_recommended"
        } else {
          "parametric_reasonable"
        },
        value = paste(distributions, collapse = "; "),
        threshold = "Marked absolute skewness guidance; Shapiro-Wilk is supporting information only",
        detail = if (isTRUE(paired) && n_groups == 2L) {
          "Assessment applied to within-pair differences."
        } else if (isTRUE(paired)) {
          "Assessment applied at each repeated occasion; repeated-measures ANOVA also requires a sphericity review."
        } else {
          "Assessment applied within each group."
        }
      )
    } else {
      .empty_diagnostics()
    },
    variation_diagnostic,
    if (exists("gg_epsilon") && identical(chosen_test, "rm_anova")) {
      .diagnostics_tbl(
        check = "Sphericity correction",
        result = "greenhouse_geisser_applied",
        value = .fmt_num(gg_epsilon, 3),
        threshold = paste0("Lower bound = ", .fmt_num(1 / (n_groups - 1), 3),
                           "; upper bound = 1"),
        detail = "The reported repeated-measures ANOVA p-value uses Greenhouse-Geisser-corrected degrees of freedom."
      )
    } else {
      .empty_diagnostics()
    },
    if (exists("expected_counts") && !is.null(expected_counts)) {
      .diagnostics_tbl(
        check = "Expected cell counts",
        result = if (!is.null(expected_screen) && !isTRUE(expected_screen$sparse)) "guidance_met" else "sparse",
        value = .fmt_num(min(expected_counts), 2),
        threshold = "No expected count below 1 and no more than 20% below 5",
        detail = "Fisher's exact test is selected automatically when expected-count guidance is not met."
      )
    } else {
      .empty_diagnostics()
    },
    if (isTRUE(paired)) {
      .diagnostics_tbl(
        check = if (n_groups == 2L) "Complete pairs" else "Complete repeated participants",
        result = "aligned",
        value = as.character(paired_values$n_pairs),
        threshold = "At least 2",
        detail = if (n_groups == 2L) "Only identifiers observed once in both groups were analysed." else "Only identifiers observed once at every occasion were analysed."
      )
    } else {
      .empty_diagnostics()
    }
  )
  denominators_tbl <- if (isTRUE(paired)) {
    .denominators_tbl(
      variable = outcome_name,
      group = if (n_groups == 2L) "Complete pairs" else "Complete participants",
      n_total = length(unique(stats::na.omit(data[[id_name]]))),
      n_nonmissing = paired_values$n_pairs,
      n_missing = length(unique(stats::na.omit(data[[id_name]]))) -
        paired_values$n_pairs,
      numerator = NA_real_,
      denominator = paired_values$n_pairs,
      rule = if (n_groups == 2L) "Identifiers observed once in both groups" else "Identifiers observed once at every occasion"
    )
  } else {
    .data_denominators(
      data,
      vars = outcome_name,
      by = group_name,
      rule = "Non-missing outcome observations within group"
    )
  }

  result <- list(
    inputs = list(
      data_name = data_name,
      variable = outcome_name,
      group = group_name,
      id = id_name,
      paired = paired,
      test = test,
      var_equal = var_equal,
      fisher_seed = fisher_seed,
      effect_size = effect_size,
      conf.level = conf.level,
      digits = digits
    ),
    descriptives = descriptives_tbl,
    inferential = inferential_tbl,
    table = table_tbl,
    method = list(
      outcome_type = outcome_type,
      group_type = group_type,
      test_requested = test,
      test_selected = inferential_tbl$test_used[[1L]],
      variance_assumption = list(
        value = var_equal,
        source = "User-specified; not inferred from a variance hypothesis test",
        applies = identical(outcome_type, "continuous") && !isTRUE(paired)
      ),
      selection_rule = selection_rule %||% "User-specified test; automatic selection was not used.",
      selection_inputs = selection_inputs,
      expected_counts = if (exists("expected_counts")) {
        expected_counts
      } else {
        NULL
      },
      expected_count_screen = if (exists("expected_screen")) expected_screen else NULL,
      fisher_simulation = if (exists("fisher_simulated") && fisher_simulated) {
        list(seed = fisher_seed, replicates = 10000L)
      } else {
        NULL
      }
    ),
    assumptions = assumptions_tbl,
    diagnostics = diagnostics_tbl,
    denominators = denominators_tbl,
    notes = {
      test_used <- inferential_tbl$test_used[[1L]]
      design_note <- if (isTRUE(paired)) {
        total_ids <- length(unique(stats::na.omit(data[[id_name]])))
        excluded_ids <- total_ids - paired_values$n_pairs
        if (n_groups == 2L) {
          if (test_used %in% c("Paired t-test", "Wilcoxon signed-rank test")) {
            paste0(
              "The within-pair difference is ", group_levels_label[[1L]],
              " minus ", group_levels_label[[2L]], ". Analysis used ",
              paired_values$n_pairs, " complete pairs; ", excluded_ids,
              " participant", if (excluded_ids == 1L) " was" else "s were",
              " excluded because a complete, uniquely matched pair was not ",
              "available. Distribution checks apply to within-pair differences."
            )
          } else {
            paste0(
              "Analysis used ", paired_values$n_pairs,
              " complete, uniquely matched binary pairs; ", excluded_ids,
              " participant", if (excluded_ids == 1L) " was" else "s were",
              " excluded because a complete pair was not available."
            )
          }
        } else {
          paste0(
            "Repeated-measures analysis used ", paired_values$n_pairs,
            " participants observed at all ", n_groups, " occasions; ",
            excluded_ids, " participant",
            if (excluded_ids == 1L) " was" else "s were",
            " excluded because complete, uniquely matched repeated ",
            "observations were not available."
          )
        }
      } else {
        "The analysis assumes independent observations; study design must confirm this."
      }
      incomplete_repeated_note <- if (isTRUE(paired) && excluded_ids > 0L) {
        " Paired and repeated-measures tests here use complete matched observations. If incomplete repeated observations must be retained, consider a prespecified mixed-effects model rather than treating this complete-case comparison as equivalent."
      } else {
        ""
      }
      design_note <- paste0(design_note, incomplete_repeated_note)
      assumption_note <- dplyr::case_when(
        test_used %in% c("Student t-test", "Welch t-test", "Paired t-test") ~
          if (identical(test_used, "Paired t-test")) {
            "Check the within-pair differences for influential outliers and substantial departures from normality, particularly in small samples."
          } else {
            "Check within-group distributions for influential outliers and substantial departures from normality, particularly in small samples."
          },
        test_used == "ANOVA" ~
          "Classical ANOVA assumes approximately normal residuals and similar group variances.",
        test_used == "Welch ANOVA" ~
          "Welch ANOVA allows unequal variances; check residual shape and influential outliers.",
        test_used == "Repeated-measures ANOVA" ~
          "Repeated-measures ANOVA requires review of residual shape, influential outliers, and sphericity.",
        test_used == "Wilcoxon rank-sum test" ~
          "Wilcoxon rank-sum is rank based; similar distribution shapes are needed for a median-shift interpretation.",
        test_used == "Wilcoxon signed-rank test" ~
          "Wilcoxon signed-rank assumes a roughly symmetric distribution of non-zero paired differences.",
        test_used == "Kruskal-Wallis test" ~
          "Kruskal-Wallis is rank based; similar distribution shapes are needed for a location-shift interpretation.",
        test_used == "Friedman test" ~
          "Friedman is a rank-based repeated-measures test; it assesses differences across paired occasions.",
        test_used == "Chi-square test" ~
          "Chi-square requires mutually exclusive categories and adequate expected cell counts.",
        test_used == "Fisher's exact test" ~
          "Fisher's exact test handles sparse counts but still requires independent observations.",
        test_used == "Fisher's exact test (Monte Carlo p-value)" ~
          "Fisher's exact test with a Monte Carlo p-value handles sparse larger tables but still requires independent observations.",
        test_used == "McNemar test" ~
          "McNemar's test requires correctly matched binary pairs.",
        test_used == "Cochran's Q test" ~
          "Cochran's Q test requires correctly matched binary observations across all occasions.",
        TRUE ~ ""
      )
      count_note <- if (
        exists("expected_counts") &&
        !is.null(expected_counts)
      ) {
        paste0(
          "Minimum expected cell count was ",
          .fmt_num(min(expected_counts), 2),
          "; Fisher's exact test is selected automatically when an expected count is below 1 or more than 20% are below 5."
        )
      } else {
        character()
      }
      selection_note <- if (
        identical(test, "auto") && !is.null(selection_rule)
      ) {
        paste0(
          "Automatic selection used distribution guidance or design/cell-count rules. ",
          "Rule applied: ", selection_rule
        )
      } else {
        character()
      }
      effect_note <- if (
        isTRUE(effect_size) &&
        !is.na(inferential_tbl$effect_size[[1L]])
      ) {
        paste0(
          "Effect size: ",
          inferential_tbl$effect_size_type[[1L]],
          ". Conventional magnitude labels are descriptive guides, not ",
          "clinical importance thresholds."
        )
      } else {
        character()
      }
      c(
        design_note,
        selection_note,
        assumption_note,
        count_note,
        effect_note
      )
    },
    call = user_call
  )

  class(result) <- c("gt_compare", "gtstats", "list")
  if (identical(format, "tibble")) return(result$table)
  result
}
