#' Compare groups using common inferential tests
#'
#' Compare an outcome across groups using a practical set of common
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
#' - `"kruskal"`
#' - `"chisq"`
#' - `"fisher"`
#' - `"mcnemar"`
#'
#' In `test = "auto"` mode:
#' - continuous outcomes with 2 groups use a t-test or Welch t-test
#' - continuous outcomes with >2 groups use ANOVA
#' - categorical outcomes use chi-square or Fisher's exact test
#' - paired binary outcomes use McNemar test
#'
#' When `effect_size = TRUE`, effect sizes are returned where supported.
#'
#' @param data A data.frame.
#' @param outcome Outcome variable. Can be supplied as a bare name or
#'   as a character string.
#' @param group Grouping variable. Can be supplied as a bare name or as
#'   a character string.
#' @param paired Logical; whether the comparison is paired. If `TRUE`,
#'   paired t-test, Wilcoxon signed-rank test, or McNemar test will be
#'   used where appropriate.
#' @param test Test to use. One of `"auto"`, `"t_test"`, `"welch_t"`,
#'   `"wilcox"`, `"anova"`, `"kruskal"`, `"chisq"`, `"fisher"`, or
#'   `"mcnemar"`.
#' @param normality_check Logical; currently reserved for future
#'   versions.
#' @param var_equal Logical; whether equal variances should be assumed
#'   for two-sample t-tests.
#' @param correction Logical; whether continuity correction should be
#'   used for chi-square tests where relevant.
#' @param effect_size Logical; whether effect size should be calculated
#'   where supported.
#' @param conf.level Confidence level for intervals.
#' @param digits Number of decimal places for formatting.
#' @param output Output style. Currently stored in the returned object.
#' @param quiet Logical; suppress messages.
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
#' compare_groups(mtcars, outcome = mpg, group = am)
#'
#' compare_groups(
#'   mtcars,
#'   outcome = mpg,
#'   group = am,
#'   effect_size = TRUE
#' )
#'
#' compare_groups(
#'   mtcars,
#'   outcome = vs,
#'   group = am,
#'   test = "chisq",
#'   effect_size = TRUE
#' )
#'
#' compare_groups(
#'   mtcars,
#'   outcome = mpg,
#'   group = am,
#'   paired = FALSE,
#'   test = "welch_t"
#' )
#'
#' tbl_stats(compare_groups(mtcars, outcome = mpg, group = am))
#'
#' @export
compare_groups <- function(
    data,
    outcome,
    group,
    paired = FALSE,
    test = c(
      "auto", "t_test", "welch_t", "wilcox",
      "anova", "kruskal", "chisq", "fisher", "mcnemar"
    ),
    normality_check = FALSE,
    var_equal = FALSE,
    correction = TRUE,
    effect_size = FALSE,
    conf.level = 0.95,
    digits = 3,
    output = c("table", "tibble", "both"),
    quiet = FALSE
) {
  test <- match.arg(test)
  output <- match.arg(output)

  # Validate input data
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }

  # Resolve outcome and group names from bare or character input
  outcome_expr <- substitute(outcome)
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

  if (!outcome_name %in% names(data)) {
    stop("`outcome` was not found in `data`.", call. = FALSE)
  }

  if (!group_name %in% names(data)) {
    stop("`group` was not found in `data`.", call. = FALSE)
  }

  if (outcome_name == group_name) {
    stop(
      "`outcome` and `group` must be different variables.",
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
  outcome_clean <- outcome_var[keep]
  group_clean <- group_var[keep]

  if (length(outcome_clean) == 0) {
    stop(
      "No complete cases available for `outcome` and `group`.",
      call. = FALSE
    )
  }

  group_factor <- as.factor(group_clean)
  n_groups <- nlevels(group_factor)

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
    if (p < 0.001) {
      return("<0.001")
    }
    sprintf(paste0("%.", digits, "f"), p)
  }

  .fmt_ci <- function(low, high, digits = 3) {
    if (is.na(low) || is.na(high)) {
      return(NA_character_)
    }
    paste0(.fmt_num(low, digits), " to ", .fmt_num(high, digits))
  }

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
    levs_outcome <- sort(unique(as.character(stats::na.omit(x))))

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

    # Select the test for continuous outcomes
    chosen_test <- test
    if (test == "auto") {
      if (n_groups == 2) {
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
        chosen_test <- "anova"
      }
    }

    if (n_groups == 2 &&
        chosen_test %in% c("t_test", "welch_t", "wilcox")) {
      grp_levels <- levels(group_factor)
      x1 <- outcome_clean[group_factor == grp_levels[1]]
      x2 <- outcome_clean[group_factor == grp_levels[2]]

      if (paired) {
        if (length(x1) != length(x2)) {
          stop(
            "For paired tests, both groups must have equal length.",
            call. = FALSE
          )
        }

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

      effect_size_val <- if (isTRUE(effect_size)) {
        tryCatch(
          .compute_effect_size(
            x1 = x1,
            x2 = x2,
            test_used = test_used
          ),
          error = function(e) NA_real_
        )
      } else {
        NA_real_
      }

      effect_size_type_val <- if (!is.na(effect_size_val)) {
        dplyr::case_when(
          test_used %in% c(
            "Student t-test",
            "Welch t-test",
            "Paired t-test"
          ) ~ "Cohen's d",
          test_used == "Wilcoxon rank-sum test" ~
            "Rank-biserial correlation",
          test_used == "Wilcoxon signed-rank test" ~
            "Matched rank-biserial correlation",
          TRUE ~ NA_character_
        )
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
        effect_size_interpretation =
          effect_size_interpretation_val,
        method_detail = method_detail,
        reason_for_test = reason_for_test,
        interpretation = interpretation_text,
        notes = ""
      )
    } else if (n_groups > 2 &&
               chosen_test %in% c("anova", "kruskal")) {
      df_tmp <- data.frame(
        outcome = outcome_clean,
        group = group_factor
      )

      if (chosen_test == "anova") {
        fit <- stats::aov(outcome ~ group, data = df_tmp)
        sm <- summary(fit)[[1]]
        statistic <- sm[["F value"]][1]
        p_value <- sm[["Pr(>F)"]][1]
        df1 <- sm[["Df"]][1]
        df2 <- sm[["Df"]][2]

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

        inferential_tbl <- tibble::tibble(
          outcome = outcome_name,
          label = .get_var_label(data, outcome_name),
          outcome_type = outcome_type,
          group = group_name,
          group_levels = n_groups,
          test_requested = test,
          test_used = "ANOVA",
          paired = paired,
          statistic = statistic,
          df = df1,
          p_value = p_value,
          estimate = NA_real_,
          estimate_type = NA_character_,
          conf_low = NA_real_,
          conf_high = NA_real_,
          conf_level = conf.level,
          effect_size = NA_real_,
          effect_size_type = NA_character_,
          effect_size_interpretation = NA_character_,
          method_detail = paste0("Residual df = ", df2),
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
          effect_size = NA_real_,
          effect_size_type = NA_character_,
          effect_size_interpretation = NA_character_,
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

    # Select the test for categorical outcomes
    tab <- table(group_factor, outcome_clean)

    chosen_test <- test
    if (test == "auto") {
      if (paired && n_groups == 2 && outcome_type == "binary") {
        chosen_test <- "mcnemar"
      } else {
        expected <- suppressWarnings(
          stats::chisq.test(tab, correct = correction)$expected
        )

        if (any(expected < 5)) {
          chosen_test <- "fisher"
        } else {
          chosen_test <- "chisq"
        }
      }
    }

    if (chosen_test == "mcnemar") {
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

      fit <- stats::mcnemar.test(tab, correct = correction)

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

  result <- list(
    inputs = list(
      data_name = deparse(substitute(data)),
      outcome = outcome_name,
      group = group_name,
      paired = paired,
      test = test,
      normality_check = normality_check,
      var_equal = var_equal,
      correction = correction,
      effect_size = effect_size,
      conf.level = conf.level,
      digits = digits,
      output = output
    ),
    descriptives = descriptives_tbl,
    inferential = inferential_tbl,
    table = table_tbl,
    method = list(
      outcome_type = outcome_type,
      group_type = group_type
    ),
    notes = c("This is version 1 comparison output."),
    call = match.call()
  )

  class(result) <- "gt_compare"
  result
}
