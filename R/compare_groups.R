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
#'
#' ## Automatic selection policy
#'
#' `test = "auto"` uses the following fixed, data-driven rules. These rules are
#' intended as transparent defaults, not a substitute for a prespecified
#' analysis plan.
#'
#' - **Continuous outcome, two independent groups:** Welch t-test, unless
#'   distribution guidance flags skewness in either group, then Wilcoxon
#'   rank-sum test.
#' - **Continuous outcome, three or more independent groups:** Welch ANOVA,
#'   unless distribution guidance flags skewness in any group, then
#'   Kruskal-Wallis test.
#' - **Paired continuous outcome:** paired t-test, unless distribution guidance
#'   flags skewness in the within-pair differences, then Wilcoxon signed-rank
#'   test.
#' - **Ordinal outcome:** Wilcoxon rank-sum test for two groups or
#'   Kruskal-Wallis test for three or more groups.
#' - **Independent binary or nominal categorical outcome:** Pearson chi-square
#'   test when every expected cell count is at least 5; Fisher's exact test
#'   otherwise.
#' - **Paired binary outcome:** McNemar test.
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
#' automatic test selection. Welch t-tests and Welch ANOVA do not require equal
#' variances.
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
#'   `"fisher"`, or `"mcnemar"`. See **Automatic selection policy** for the
#'   exact rules used by `"auto"`.
#' @param effect_size Logical; calculate and display the effect size selected
#'   for the comparison structure. Default is `FALSE`.
#' @param conf.level Confidence level for intervals.
#' @param digits Number of decimal places for formatting.
#' @param ... Reserved for internal package use.
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
#' tbl_stats(compare_groups(mtcars, variable = mpg, group = am))
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
      "anova", "welch_anova", "kruskal", "chisq", "fisher", "mcnemar"
    ),
    effect_size = FALSE,
    conf.level = 0.95,
    digits = 2,
    ...
) {
  dots_expr <- match.call(expand.dots = FALSE)$...
  dots_names <- names(dots_expr) %||% character()
  allowed_internal <- c(
    ".normality_check", ".var_equal", ".correction", ".quiet"
  )
  unknown_internal <- setdiff(dots_names, allowed_internal)
  if (length(unknown_internal) > 0L || any(!nzchar(dots_names))) {
    stop("Unused arguments supplied through `...`.", call. = FALSE)
  }
  internal_names <- intersect(
    dots_names,
    c(".normality_check", ".var_equal", ".correction", ".quiet")
  )
  internal <- lapply(dots_expr[internal_names], eval, envir = parent.frame())
  test <- match.arg(test)
  .validate_flag(paired, "paired")
  .validate_flag(effect_size, "effect_size")
  .validate_conf_level(conf.level)
  .validate_digits(digits)
  normality_check <- internal$.normality_check %||% TRUE
  var_equal <- internal$.var_equal %||% identical(test, "t_test")
  correction <- internal$.correction %||% TRUE
  quiet <- internal$.quiet %||% FALSE
  .validate_flag(normality_check, ".normality_check")
  .validate_flag(var_equal, ".var_equal")
  .validate_flag(correction, ".correction")
  .validate_flag(quiet, ".quiet")

  # Validate input data
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }

  # Resolve variable and grouping names from bare or character input
  outcome_expr <- substitute(variable)
  group_expr <- substitute(group)

  outcome_eval <- tryCatch(
    eval(outcome_expr, parent.frame()),
    error = function(e) NULL
  )
  group_eval <- tryCatch(
    eval(group_expr, parent.frame()),
    error = function(e) NULL
  )

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
    substitute(id),
    env = parent.frame(),
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
    if (n_groups != 2L) {
      stop("Paired analyses require exactly two groups.", call. = FALSE)
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
    first <- paired_data[paired_data$group == group_levels[[1L]], ]
    second <- paired_data[paired_data$group == group_levels[[2L]], ]
    common_ids <- intersect(first$id, second$id)
    if (length(common_ids) < 2L) {
      stop("At least two complete pairs are required.", call. = FALSE)
    }

    first <- first[match(common_ids, first$id), ]
    second <- second[match(common_ids, second$id), ]
    paired_values <- list(
      ids = common_ids,
      group_levels = group_levels,
      x1 = first$outcome,
      x2 = second$outcome,
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
        x = c(paired_values$x1, paired_values$x2),
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
      if (isTRUE(normality_check)) {
        group_assessments <- if (isTRUE(paired)) {
          list(
            .assess_distribution(
              paired_values$x1 - paired_values$x2,
              normality_test = TRUE
            )$distribution
          )
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
        distribution_flag <- any(
          unlist(group_assessments) %in% c("Skewed", "Possibly skewed")
        )
      }

      if (distribution_flag && n_groups == 2L) {
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
        chosen_test <- "welch_anova"
      }

      assessed_distribution <- if (isTRUE(normality_check)) {
        paste(unlist(group_assessments), collapse = "; ")
      } else {
        "Distribution guidance disabled"
      }
      selection_inputs <- list(
        distribution_guidance = assessed_distribution,
        skewness_flagged = distribution_flag,
        groups = n_groups,
        paired = paired
      )
      selection_rule <- if (isTRUE(paired)) {
        if (isTRUE(distribution_flag)) {
          "Paired continuous outcome: skewness flagged in within-pair differences; selected Wilcoxon signed-rank test."
        } else {
          "Paired continuous outcome: no skewness flag in within-pair differences; selected paired t-test."
        }
      } else if (n_groups == 2L && isTRUE(distribution_flag)) {
        "Two-group continuous outcome: skewness flagged in at least one group; selected Wilcoxon rank-sum test."
      } else if (n_groups == 2L) {
        "Two-group continuous outcome: no skewness flag; selected Welch t-test."
      } else if (isTRUE(distribution_flag)) {
        "Multi-group continuous outcome: skewness flagged in at least one group; selected Kruskal-Wallis test."
      } else {
        "Multi-group continuous outcome: no skewness flag; selected Welch ANOVA."
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
          estimate_type <- "Mean difference"
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
        x = c(paired_values$x1, paired_values$x2),
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
    paired_tab <- if (isTRUE(paired)) {
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

    chosen_test <- test
    if (test == "auto") {
      if (identical(outcome_type, "ordinal")) {
        chosen_test <- if (n_groups == 2L) "wilcox" else "kruskal"
        selection_rule <- if (n_groups == 2L) {
          "Two-group ordinal outcome: selected Wilcoxon rank-sum test."
        } else {
          "Multi-group ordinal outcome: selected Kruskal-Wallis test."
        }
        selection_inputs <- list(groups = n_groups, outcome_type = "ordinal")
      } else if (paired && n_groups == 2 && outcome_type == "binary") {
        chosen_test <- "mcnemar"
        selection_rule <- "Paired binary outcome: selected McNemar test."
        selection_inputs <- list(groups = n_groups, outcome_type = "binary", paired = TRUE)
      } else {
        if (any(expected_counts < 5)) {
          chosen_test <- "fisher"
        } else {
          chosen_test <- "chisq"
        }
        selection_rule <- if (any(expected_counts < 5)) {
          "Independent categorical outcome: at least one expected cell count was below 5; selected Fisher's exact test."
        } else {
          "Independent categorical outcome: all expected cell counts were at least 5; selected Pearson chi-square test."
        }
        selection_inputs <- list(
          groups = n_groups,
          outcome_type = outcome_type,
          minimum_expected_count = min(expected_counts),
          expected_count_threshold = 5
        )
      }
    }

    if (identical(outcome_type, "ordinal") &&
        chosen_test %in% c("wilcox", "kruskal")) {
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
      fit <- stats::fisher.test(tab, conf.level = conf.level)

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
        test_used = "Fisher's exact test",
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
        method_detail = "",
        reason_for_test = paste0(
          "Categorical outcome compared across groups with ",
          "small expected counts"
        ),
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
      "ANOVA", "Welch ANOVA"
    )) {
      .assumptions_tbl(
        assumption = "Distribution and influential outliers",
        status = if (isTRUE(normality_check)) "partly_checked" else "user_check",
        result = if (
          isTRUE(normality_check) &&
          exists("distribution_flag") &&
          !isTRUE(distribution_flag)
        ) "no_skew_flag" else "not_checked",
        detail = if (isTRUE(paired)) {
          "Inspect the within-pair differences for influential outliers and severe asymmetry."
        } else {
          "Inspect group distributions or model residuals for influential outliers and severe asymmetry."
        }
      )
    } else if (test_used_final %in% c(
      "Wilcoxon rank-sum test",
      "Kruskal-Wallis test"
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
    if (test_used_final %in% c("Chi-square test", "Fisher's exact test")) {
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
            all(expected_counts >= 5)
          ) "all_at_least_5" else "sparse"
        ),
        detail = c(
          "Confirm that every observation contributes to one category per variable.",
          "Automatic selection uses Fisher's exact test when any expected count is below 5."
        )
      )
    } else if (test_used_final == "McNemar test") {
      .assumptions_tbl(
        assumption = "Correctly matched binary observations",
        status = "partly_checked",
        result = "aligned_by_id",
        detail = "Identifiers were aligned and duplicate id/group records were rejected; confirm the clinical pairing."
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
        "Welch t-test and Welch ANOVA do not require equal variances;",
        "this does not alter automatic test selection."
      )
    )
  }
  if (!is.null(selection_inputs) && !is.null(variation_inputs)) {
    selection_inputs$observed_group_spread <- variation_inputs
  }

  diagnostics_tbl <- dplyr::bind_rows(
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
          "All expected counts >= 5 for chi-square"
        } else if (!is.null(selection_inputs$distribution_guidance)) {
          "No group-level skewness flag for parametric default"
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
      isTRUE(normality_check) &&
      exists("group_assessments")
    ) {
      distributions <- unlist(group_assessments)
      .diagnostics_tbl(
        check = "Distribution guidance",
        result = if (any(distributions %in% c(
          "Skewed", "Possibly skewed"
        ))) "rank_based_recommended" else "parametric_reasonable",
        value = paste(distributions, collapse = "; "),
        threshold = "Absolute skewness guidance",
        detail = if (isTRUE(paired)) {
          "Assessment applied to within-pair differences."
        } else {
          "Assessment applied within each group."
        }
      )
    } else {
      .empty_diagnostics()
    },
    variation_diagnostic,
    if (exists("expected_counts") && !is.null(expected_counts)) {
      .diagnostics_tbl(
        check = "Expected cell counts",
        result = if (all(expected_counts >= 5)) "adequate" else "sparse",
        value = .fmt_num(min(expected_counts), 2),
        threshold = "Minimum expected count >= 5",
        detail = "Fisher's exact test is selected automatically when any expected count is below 5."
      )
    } else {
      .empty_diagnostics()
    },
    if (isTRUE(paired)) {
      .diagnostics_tbl(
        check = "Complete pairs",
        result = "aligned",
        value = as.character(paired_values$n_pairs),
        threshold = "At least 2",
        detail = "Only identifiers observed once in both groups were analysed."
      )
    } else {
      .empty_diagnostics()
    }
  )
  denominators_tbl <- if (isTRUE(paired)) {
    .denominators_tbl(
      variable = outcome_name,
      group = "Complete pairs",
      n_total = length(unique(stats::na.omit(data[[id_name]]))),
      n_nonmissing = paired_values$n_pairs,
      n_missing = length(unique(stats::na.omit(data[[id_name]]))) -
        paired_values$n_pairs,
      numerator = NA_real_,
      denominator = paired_values$n_pairs,
      rule = "Identifiers observed once in both groups"
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
      data_name = deparse(substitute(data)),
      variable = outcome_name,
      group = group_name,
      id = id_name,
      paired = paired,
      test = test,
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
      selection_rule = selection_rule %||% "User-specified test; automatic selection was not used.",
      selection_inputs = selection_inputs,
      expected_counts = if (exists("expected_counts")) {
        expected_counts
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
        paste0(
          "Paired analysis used ",
          paired_values$n_pairs,
          " complete pairs; distribution checks apply to within-pair differences."
        )
      } else {
        "The analysis assumes independent observations; study design must confirm this."
      }
      assumption_note <- dplyr::case_when(
        test_used %in% c("Student t-test", "Welch t-test", "Paired t-test") ~
          "Check for influential outliers and an approximately symmetric sampling distribution.",
        test_used == "ANOVA" ~
          "Classical ANOVA assumes approximately normal residuals and similar group variances.",
        test_used == "Welch ANOVA" ~
          "Welch ANOVA allows unequal variances; check residual shape and influential outliers.",
        test_used == "Wilcoxon rank-sum test" ~
          "Wilcoxon rank-sum is rank based; similar distribution shapes are needed for a median-shift interpretation.",
        test_used == "Wilcoxon signed-rank test" ~
          "Wilcoxon signed-rank assumes a roughly symmetric distribution of non-zero paired differences.",
        test_used == "Kruskal-Wallis test" ~
          "Kruskal-Wallis is rank based; similar distribution shapes are needed for a location-shift interpretation.",
        test_used == "Chi-square test" ~
          "Chi-square requires mutually exclusive categories and adequate expected cell counts.",
        test_used == "Fisher's exact test" ~
          "Fisher's exact test handles sparse counts but still requires independent observations.",
        test_used == "McNemar test" ~
          "McNemar's test requires correctly matched binary pairs.",
        TRUE ~ ""
      )
      count_note <- if (
        exists("expected_counts") &&
        !is.null(expected_counts)
      ) {
        paste0(
          "Minimum expected cell count was ",
          .fmt_num(min(expected_counts), 2),
          "; Fisher's exact test is selected automatically when any expected count is below 5."
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
    call = match.call()
  )

  class(result) <- c("gt_compare", "gtstats", "list")
  result
}
