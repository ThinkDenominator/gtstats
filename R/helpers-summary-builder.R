#' Internal summary-statistics engine
#'
#' Compute descriptive statistics for continuous and categorical
#' variables, with optional grouping.
#'
#' This function is designed for practical descriptive analysis and
#' teaching workflows. It supports continuous, binary, categorical,
#' and ordinal variables, and produces both a detailed summary object
#' and a display-ready table.
#'
#' Continuous variables can be summarised using:
#' - `"recommended"`: mean (SD) or median (IQR) based on skewness
#' - `"mean_sd"`: mean (SD)
#' - `"median_iqr"`: median (IQR)
#' - `"both"`: mean (SD) and median (IQR)
#'
#' Categorical variables are summarised as count (%).
#'
#' @param data A data.frame.
#' @param vars Optional character vector of variables to summarise.
#'   Default is all variables in `data`.
#' @param by Optional grouping variable. Can be supplied as a bare
#'   name or as a character string.
#' @param type Optional named list used to override detected variable
#'   types.
#' @param include Variable types to include. One of `"auto"`,
#'   `"continuous"`, `"categorical"`, `"binary"`, or `"ordinal"`.
#' @param continuous_format Format used for continuous summaries.
#' @param percent Denominator used for categorical percentages. `"column"`
#'   uses the non-missing denominator within each displayed group, `"row"`
#'   distributes each category across groups, `"overall"` uses the overall
#'   non-missing variable denominator, and `"none"` displays counts only.
#' @param categorical Display for categorical values: `"n_percent"`, `"n"`,
#'   or `"percent"`.
#' @param ci Logical; append binomial confidence intervals to categorical
#'   proportions.
#' @param conf.level Confidence level for categorical proportion intervals.
#' @param ci_digits Decimal places used for confidence limits.
#' @param missing How to display missingness. One of `"ifany"`,
#'   `"no"`, or `"always"`.
#' @param digits Number of decimal places used for formatting.
#' @param skew_cutoff Absolute skewness threshold used when
#'   `continuous_format = "recommended"`. Values with absolute skewness greater
#'   than or equal to this cutoff are displayed as median (IQR); otherwise
#'   mean (SD) is used.
#' @param output Output style.
#' @param quiet Logical; suppress messages.
#'
#' @return A `gt_summary` object containing:
#' \itemize{
#'   \item `inputs` — function inputs and settings
#'   \item `variable_info` — detected or overridden variable types
#'   \item `summary` — detailed summary table
#'   \item `table` — display-ready table
#'   \item `method` — summary method description
#'   \item `notes` — contextual notes
#'   \item `call` — matched function call
#' }
#'
#' @noRd
.build_summary_stats <- function(
    data,
    vars = NULL,
    by = NULL,
    type = NULL,
    include = c(
      "auto",
      "continuous",
      "categorical",
      "binary",
      "ordinal"
    ),
    continuous_format = c(
      "recommended",
      "mean_sd",
      "mean_ci",
      "median_iqr",
      "both"
    ),
    percent = c("column", "row", "overall", "none"),
    categorical = c("n_percent", "n_over_N_percent", "n", "percent"),
    ci = FALSE,
    conf.level = 0.95,
    ci_digits = digits,
    missing = c("ifany", "no", "always"),
    digits = 1,
    skew_cutoff = 1,
    output = c("table", "tibble", "both"),
    quiet = FALSE
) {
  include <- match.arg(include)
  continuous_format <- match.arg(continuous_format)
  percent <- match.arg(percent)
  categorical <- match.arg(categorical)
  missing <- match.arg(missing)
  output <- match.arg(output)
  if (!is.numeric(digits) || length(digits) != 1 ||
      is.na(digits) || digits < 0) {
    stop("`digits` must be a single non-negative number.", call. = FALSE)
  }
  .validate_flag(ci, "ci")
  .validate_conf_level(conf.level)
  .validate_digits(ci_digits, "ci_digits")
  if (identical(percent, "none") && !identical(categorical, "n")) {
    categorical <- "n"
  }
  if (isTRUE(ci) && identical(categorical, "n")) {
    stop(
      "`ci = TRUE` requires a percentage-based `categorical` display.",
      call. = FALSE
    )
  }

  if (!is.numeric(skew_cutoff) || length(skew_cutoff) != 1 ||
      is.na(skew_cutoff) || skew_cutoff <= 0) {
    stop("`skew_cutoff` must be a single positive number.", call. = FALSE)
  }

  # Resolve grouping variable from bare or character input
  by_expr <- substitute(by)

  if (identical(by_expr, NULL)) {
    by <- NULL
  } else {
    by_eval <- tryCatch(
      eval(by_expr, parent.frame()),
      error = function(e) NULL
    )

    if (is.character(by_eval) && length(by_eval) == 1) {
      by <- by_eval
    } else if (is.symbol(by_expr)) {
      by <- deparse(by_expr)
    } else if (is.character(by_expr) && length(by_expr) == 1) {
      by <- by_expr[1]
    } else {
      by <- deparse(by_expr)
    }
  }

  # Validate variable selection
  vars <- .validate_vars(data, vars)

  # Validate grouping variable when supplied
  if (!is.null(by)) {
    if (length(by) != 1) {
      stop("`by` must be a single variable name.", call. = FALSE)
    }

    if (!by %in% names(data)) {
      stop("`by` was not found in `data`.", call. = FALSE)
    }

    if (by %in% vars) {
      vars <- setdiff(vars, by)
    }

    by_type <- .detect_type(data[[by]])
    if (by_type == "continuous") {
      stop(
        paste0(
          "`by` should be a categorical, binary, or ordinal ",
          "grouping variable."
        ),
        call. = FALSE
      )
    }
  }
  if (is.null(by) && identical(percent, "row")) {
    stop("`percent = \"row\"` requires a grouping variable.", call. = FALSE)
  }

  # Build variable metadata with optional type overrides
  var_info <- lapply(vars, function(var) {
    detected_type <- .detect_type(data[[var]])
    final_type <- detected_type

    if (!is.null(type) && !is.null(type[[var]])) {
      final_type <- type[[var]]
    }

    data.frame(
      variable = var,
      label = .get_var_label(data, var),
      type = final_type,
      stringsAsFactors = FALSE
    )
  })

  var_info <- tibble::as_tibble(do.call(rbind, var_info))

  # Restrict to requested variable type when needed
  if (include != "auto") {
    var_info <- var_info[var_info$type == include, , drop = FALSE]
  }

  # Helper to format numeric values
  .fmt_num <- function(x, digits = 1) {
    ifelse(
      is.na(x),
      NA_character_,
      sprintf(paste0("%.", digits, "f"), x)
    )
  }

  .fmt_categorical <- function(count, pct, denominator) {
    pct_text <- paste0(.fmt_num(pct, digits), "%")
    interval_text <- ""
    if (isTRUE(ci) && is.finite(denominator) && denominator > 0L &&
        is.finite(count)) {
      interval <- 100 * .binomial_ci(
        successes = count,
        total = denominator,
        conf.level = conf.level,
        method = "exact"
      )
      interval_text <- paste0(
        .fmt_num(interval[[1L]], ci_digits),
        "\u2013",
        .fmt_num(interval[[2L]], ci_digits)
      )
    }
    if (identical(categorical, "n")) return(as.character(count))
    if (identical(categorical, "percent")) {
      if (nzchar(interval_text)) {
        return(paste0(
          pct_text, " (", round(100 * conf.level), "% CI ",
          interval_text, ")"
        ))
      }
      return(pct_text)
    }
    count_text <- if (identical(categorical, "n_over_N_percent")) {
      paste0(count, "/", denominator)
    } else {
      as.character(count)
    }
    if (nzchar(interval_text)) {
      return(paste0(
        count_text, " (", pct_text, "; ", round(100 * conf.level),
        "% CI ", interval_text, ")"
      ))
    }
    paste0(count_text, " (", pct_text, ")")
  }

  .make_mean_ci <- function(mean_value, sd_value, n_value) {
    if (!is.finite(mean_value) || !is.finite(sd_value) || n_value < 2L) {
      return(NA_character_)
    }
    margin <- stats::qt((1 + conf.level) / 2, df = n_value - 1L) *
      sd_value / sqrt(n_value)
    paste0(
      .fmt_num(mean_value, digits),
      " (", round(100 * conf.level), "% CI ",
      .fmt_num(mean_value - margin, ci_digits), "\u2013",
      .fmt_num(mean_value + margin, ci_digits), ")"
    )
  }

  # Simple skewness helper used for recommendation logic
  .skewness <- function(x) {
    x <- x[!is.na(x)]

    if (length(x) < 3) {
      return(NA_real_)
    }

    s <- stats::sd(x)
    if (is.na(s) || s == 0) {
      return(0)
    }

    m <- mean(x)
    mean((x - m)^3) / (s^3)
  }

  # Choose which continuous summary display to show
  .make_cont_display <- function(
    mean_sd,
    mean_ci,
    median_iqr,
    continuous_format,
    recommendation
  ) {
    switch(
      continuous_format,
      both = paste0(mean_sd, "; ", median_iqr),
      mean_sd = mean_sd,
      mean_ci = mean_ci,
      median_iqr = median_iqr,
      recommended = {
        if (!is.na(recommendation) &&
            grepl("Median", recommendation, fixed = TRUE)) {
          median_iqr
        } else {
          mean_sd
        }
      }
    )
  }

  # Build ungrouped summaries
  if (is.null(by)) {
    summary_list <- lapply(seq_len(nrow(var_info)), function(i) {
      var <- var_info$variable[i]
      label <- var_info$label[i]
      var_type <- var_info$type[i]
      x <- data[[var]]

      n_missing <- sum(is.na(x))
      n_nonmissing <- sum(!is.na(x))
      pct_missing <- if (length(x) == 0) {
        NA_real_
      } else {
        100 * n_missing / length(x)
      }

      if (var_type == "continuous") {
        mean_val <- mean(x, na.rm = TRUE)
        sd_val <- stats::sd(x, na.rm = TRUE)
        median_val <- stats::median(x, na.rm = TRUE)
        q1_val <- as.numeric(
          stats::quantile(x, 0.25, na.rm = TRUE, names = FALSE)
        )
        q3_val <- as.numeric(
          stats::quantile(x, 0.75, na.rm = TRUE, names = FALSE)
        )
        iqr_val <- q3_val - q1_val
        min_val <- min(x, na.rm = TRUE)
        max_val <- max(x, na.rm = TRUE)

        mean_sd <- paste0(
          .fmt_num(mean_val, digits),
          " (",
          .fmt_num(sd_val, digits),
          ")"
        )
        mean_ci <- .make_mean_ci(mean_val, sd_val, n_nonmissing)

        median_iqr <- paste0(
          .fmt_num(median_val, digits),
          " (",
          .fmt_num(q1_val, digits),
          "\u2013",
          .fmt_num(q3_val, digits),
          ")"
        )

        range_val <- paste0(
          .fmt_num(min_val, digits),
          "\u2013",
          .fmt_num(max_val, digits)
        )

        skew_val <- .skewness(x)

        recommendation <- if (!is.na(skew_val) &&
                              abs(skew_val) >= skew_cutoff) {
          "Median (IQR) preferred"
        } else {
          "Mean (SD) appropriate"
        }

        tibble::tibble(
          variable = var,
          label = label,
          type = var_type,
          by = NA_character_,
          group_level = NA_character_,
          level = NA_character_,
          n = n_nonmissing,
          n_missing = n_missing,
          pct_missing = pct_missing,
          mean = mean_val,
          sd = sd_val,
          median = median_val,
          q1 = q1_val,
          q3 = q3_val,
          iqr = iqr_val,
          min = min_val,
          max = max_val,
          count = NA_real_,
          percent = NA_real_,
          mean_sd = mean_sd,
          mean_ci = mean_ci,
          median_iqr = median_iqr,
          range = range_val,
          count_pct = NA_character_,
          recommendation = recommendation,
          display_value = .make_cont_display(
            mean_sd = mean_sd,
            mean_ci = mean_ci,
            median_iqr = median_iqr,
            continuous_format = continuous_format,
            recommendation = recommendation
          ),
          notes = ""
        )
      } else {
        tab <- table(x, useNA = "no")
        if (length(tab) == 0L || sum(tab) == 0L) {
          return(tibble::tibble(
            variable = var,
            label = label,
            type = var_type,
            by = NA_character_,
            group_level = NA_character_,
            level = NA_character_,
            n = n_nonmissing,
            n_missing = n_missing,
            pct_missing = pct_missing,
            mean = NA_real_, sd = NA_real_, median = NA_real_,
            q1 = NA_real_, q3 = NA_real_, iqr = NA_real_,
            min = NA_real_, max = NA_real_, count = NA_real_,
            percent = NA_real_, mean_sd = NA_character_,
            mean_ci = NA_character_, median_iqr = NA_character_,
            range = NA_character_, count_pct = NA_character_,
            recommendation = "No observed categories",
            display_value = "\u2014", notes = "All values are missing."
          ))
        }
        pct <- if (identical(percent, "none")) {
          rep(NA_real_, length(tab))
        } else {
          prop.table(tab) * 100
        }
        display <- if (identical(percent, "none")) {
          as.character(as.numeric(tab))
        } else {
          vapply(
            seq_along(tab),
            function(j) .fmt_categorical(
              as.numeric(tab[[j]]),
              as.numeric(pct[[j]]),
              sum(tab)
            ),
            character(1)
          )
        }

        tibble::tibble(
          variable = var,
          label = label,
          type = var_type,
          by = NA_character_,
          group_level = NA_character_,
          level = names(tab),
          n = n_nonmissing,
          n_missing = n_missing,
          pct_missing = pct_missing,
          mean = NA_real_,
          sd = NA_real_,
          median = NA_real_,
          q1 = NA_real_,
          q3 = NA_real_,
          iqr = NA_real_,
          min = NA_real_,
          max = NA_real_,
          count = as.numeric(tab),
          percent = as.numeric(pct),
            mean_sd = NA_character_,
            mean_ci = NA_character_,
            median_iqr = NA_character_,
          range = NA_character_,
          count_pct = display,
          recommendation = if (identical(percent, "none")) "Count" else "Count (%)",
          display_value = display,
          notes = ""
        )
      }
    })

    summary_tbl <- dplyr::bind_rows(summary_list)

    table_tbl <- summary_tbl[, c(
      "label",
      "level",
      "type",
      "display_value",
      "n_missing",
      "pct_missing"
    )]

    names(table_tbl) <- c(
      "Variable",
      "Level",
      "Type",
      "Summary",
      "Missing_n",
      "Missing_pct"
    )

    table_tbl$Level[is.na(table_tbl$Level)] <- ""

    table_tbl$Missing <- paste0(
      table_tbl$Missing_n,
      " (",
      .fmt_num(table_tbl$Missing_pct, digits),
      "%)"
    )

    table_tbl <- table_tbl[, c(
      "Variable",
      "Level",
      "Type",
      "Summary",
      "Missing"
    )]

    table_tbl <- tibble::as_tibble(table_tbl)

  } else {
    # Build grouped summaries
    group_values <- unique(data[[by]])
    group_values <- group_values[!is.na(group_values)]

    group_values_chr <- as.character(group_values)
    group_labels <- paste0(by, " = ", .display_level(group_values_chr))
    names(group_labels) <- group_values_chr

    summary_list <- list()

    for (i in seq_len(nrow(var_info))) {
      var <- var_info$variable[i]
      label <- var_info$label[i]
      var_type <- var_info$type[i]

      if (var_type == "continuous") {
        for (g in group_values_chr) {
          idx <- !is.na(data[[by]]) &
            as.character(data[[by]]) == g

          x <- data[[var]][idx]

          n_missing <- sum(is.na(x))
          n_nonmissing <- sum(!is.na(x))
          pct_missing <- if (length(x) == 0) {
            NA_real_
          } else {
            100 * n_missing / length(x)
          }

          if (n_nonmissing == 0) {
            mean_val <- NA_real_
            sd_val <- NA_real_
            median_val <- NA_real_
            q1_val <- NA_real_
            q3_val <- NA_real_
            iqr_val <- NA_real_
            min_val <- NA_real_
            max_val <- NA_real_
            mean_sd <- NA_character_
            mean_ci <- NA_character_
            median_iqr <- NA_character_
            range_val <- NA_character_
            recommendation_tmp <- NA_character_
            display_value <- NA_character_
          } else {
            mean_val <- mean(x, na.rm = TRUE)
            sd_val <- stats::sd(x, na.rm = TRUE)
            median_val <- stats::median(x, na.rm = TRUE)
            q1_val <- as.numeric(
              stats::quantile(
                x,
                0.25,
                na.rm = TRUE,
                names = FALSE
              )
            )
            q3_val <- as.numeric(
              stats::quantile(
                x,
                0.75,
                na.rm = TRUE,
                names = FALSE
              )
            )
            iqr_val <- q3_val - q1_val
            min_val <- min(x, na.rm = TRUE)
            max_val <- max(x, na.rm = TRUE)

            mean_sd <- paste0(
              .fmt_num(mean_val, digits),
              " (",
              .fmt_num(sd_val, digits),
              ")"
            )
            mean_ci <- .make_mean_ci(mean_val, sd_val, n_nonmissing)

            median_iqr <- paste0(
              .fmt_num(median_val, digits),
              " (",
              .fmt_num(q1_val, digits),
              "\u2013",
              .fmt_num(q3_val, digits),
              ")"
            )

            range_val <- paste0(
              .fmt_num(min_val, digits),
              "\u2013",
              .fmt_num(max_val, digits)
            )

            skew_val <- .skewness(x)

            recommendation_tmp <- if (!is.na(skew_val) &&
                                      abs(skew_val) >= skew_cutoff) {
              "Median (IQR) preferred"
            } else {
              "Mean (SD) appropriate"
            }

            display_value <- .make_cont_display(
              mean_sd = mean_sd,
              mean_ci = mean_ci,
              median_iqr = median_iqr,
              continuous_format = continuous_format,
              recommendation = recommendation_tmp
            )
          }

          summary_list[[length(summary_list) + 1]] <- tibble::tibble(
            variable = var,
            label = label,
            type = var_type,
            by = by,
            group_level = g,
            level = NA_character_,
            n = n_nonmissing,
            n_missing = n_missing,
            pct_missing = pct_missing,
            mean = mean_val,
            sd = sd_val,
            median = median_val,
            q1 = q1_val,
            q3 = q3_val,
            iqr = iqr_val,
            min = min_val,
            max = max_val,
            count = NA_real_,
            percent = NA_real_,
            mean_sd = mean_sd,
            mean_ci = mean_ci,
            median_iqr = median_iqr,
            range = range_val,
            count_pct = NA_character_,
            recommendation = recommendation_tmp,
            display_value = display_value,
            notes = ""
          )
        }
      } else {
        all_levels <- sort(
          unique(stats::na.omit(as.character(data[[var]])))
        )

        for (g in group_values_chr) {
          idx <- !is.na(data[[by]]) &
            as.character(data[[by]]) == g

          x <- as.character(data[[var]][idx])

          n_missing <- sum(is.na(data[[var]][idx]))
          n_nonmissing <- sum(!is.na(data[[var]][idx]))
          pct_missing <- if (sum(idx) == 0) {
            NA_real_
          } else {
            100 * n_missing / sum(idx)
          }

          tab <- table(
            factor(x, levels = all_levels),
            useNA = "no"
          )

          column_pct <- if (sum(tab) == 0) {
            rep(NA_real_, length(tab))
          } else {
            as.numeric(tab) / sum(tab) * 100
          }
          overall_denominator <- sum(!is.na(data[[var]]))

          if (length(all_levels) == 0L) {
            summary_list[[length(summary_list) + 1L]] <- tibble::tibble(
              variable = var,
              label = label,
              type = var_type,
              by = by,
              group_level = g,
              level = NA_character_,
              n = n_nonmissing,
              n_missing = n_missing,
              pct_missing = pct_missing,
              mean = NA_real_, sd = NA_real_, median = NA_real_,
              q1 = NA_real_, q3 = NA_real_, iqr = NA_real_,
              min = NA_real_, max = NA_real_, count = NA_real_,
              percent = NA_real_, mean_sd = NA_character_,
              mean_ci = NA_character_, median_iqr = NA_character_,
              range = NA_character_, count_pct = "\u2014",
              recommendation = "No observed categories",
              display_value = "\u2014", notes = "All values are missing."
            )
          }

          for (j in seq_along(all_levels)) {
            summary_list[[length(summary_list) + 1]] <-
              tibble::tibble(
                variable = var,
                label = label,
                type = var_type,
                by = by,
                group_level = g,
                level = all_levels[j],
                n = n_nonmissing,
                n_missing = n_missing,
                pct_missing = pct_missing,
                mean = NA_real_,
                sd = NA_real_,
                median = NA_real_,
                q1 = NA_real_,
                q3 = NA_real_,
                iqr = NA_real_,
                min = NA_real_,
                max = NA_real_,
                count = as.numeric(tab[j]),
                percent = dplyr::case_when(
                  percent == "none" ~ NA_real_,
                  percent == "overall" ~
                    100 * as.numeric(tab[j]) / overall_denominator,
                  TRUE ~ as.numeric(column_pct[j])
                ),
                mean_sd = NA_character_,
                mean_ci = NA_character_,
                median_iqr = NA_character_,
                range = NA_character_,
                count_pct = NA_character_,
                recommendation = if (identical(percent, "none")) "Count" else "Count (%)",
                display_value = NA_character_,
                notes = ""
              )
          }
        }
      }
    }

    summary_tbl <- dplyr::bind_rows(summary_list)

    if (identical(percent, "row")) {
      categorical_rows <- summary_tbl$type != "continuous"
      row_totals <- stats::ave(
        summary_tbl$count[categorical_rows],
        interaction(
          summary_tbl$variable[categorical_rows],
          summary_tbl$level[categorical_rows],
          drop = TRUE
        ),
        FUN = function(z) sum(z, na.rm = TRUE)
      )
      summary_tbl$percent[categorical_rows] <-
        100 * summary_tbl$count[categorical_rows] / row_totals
    }

    categorical_rows <- summary_tbl$type != "continuous"
    summary_tbl$count_pct[categorical_rows] <- if (identical(percent, "none")) {
      as.character(summary_tbl$count[categorical_rows])
    } else {
      vapply(
        which(categorical_rows),
        function(i) {
          if (is.na(summary_tbl$count[[i]])) {
            return("\u2014")
          }
          denominator <- if (identical(percent, "row")) {
            sum(summary_tbl$count[
              summary_tbl$variable == summary_tbl$variable[[i]] &
                summary_tbl$level == summary_tbl$level[[i]]
            ], na.rm = TRUE)
          } else if (identical(percent, "overall")) {
            sum(summary_tbl$count[
              summary_tbl$variable == summary_tbl$variable[[i]]
            ], na.rm = TRUE)
          } else {
            sum(summary_tbl$count[
              summary_tbl$variable == summary_tbl$variable[[i]] &
                summary_tbl$group_level == summary_tbl$group_level[[i]]
            ], na.rm = TRUE)
          }
          .fmt_categorical(
            summary_tbl$count[[i]],
            summary_tbl$percent[[i]],
            denominator
          )
        },
        character(1)
      )
    }
    summary_tbl$display_value[categorical_rows] <-
      summary_tbl$count_pct[categorical_rows]

    row_keys <- dplyr::distinct(
      summary_tbl[, c("label", "level", "type")]
    )

    names(row_keys) <- c("Variable", "Level", "Type")
    row_keys$Level[is.na(row_keys$Level)] <- ""

    group_tables <- lapply(seq_along(group_values_chr), function(i) {
      g <- group_values_chr[[i]]
      tmp <- summary_tbl[
        summary_tbl$group_level == g,
        c("label", "level", "display_value")
      ]

      names(tmp) <- c("Variable", "Level", group_labels[[i]])
      tmp$Level[is.na(tmp$Level)] <- ""
      tmp
    })

    table_tbl <- row_keys
    for (gtab in group_tables) {
      table_tbl <- dplyr::left_join(
        table_tbl,
        gtab,
        by = c("Variable", "Level")
      )
    }

    missing_tbl <- dplyr::distinct(summary_tbl[, c("label", "level")])
    names(missing_tbl) <- c("Variable", "Level")
    missing_tbl$Level[is.na(missing_tbl$Level)] <- ""

    missing_info <- lapply(seq_len(nrow(missing_tbl)), function(i) {
      v <- missing_tbl$Variable[i]

      var_name <- var_info$variable[var_info$label == v][1]
      x_all <- data[[var_name]]
      n_missing <- sum(is.na(x_all))
      pct_missing <- 100 * n_missing / length(x_all)

      paste0(
        n_missing,
        " (",
        .fmt_num(pct_missing, digits),
        "%)"
      )
    })

    missing_tbl$Missing <- unlist(missing_info)

    table_tbl <- dplyr::left_join(
      table_tbl,
      missing_tbl,
      by = c("Variable", "Level")
    )

    group_col_order <- unname(group_labels)

    table_tbl <- table_tbl[, c(
      "Variable",
      "Level",
      "Type",
      group_col_order,
      "Missing"
    )]

    table_tbl <- tibble::as_tibble(table_tbl)
  }

  if (identical(missing, "no") ||
      (identical(missing, "ifany") && !any(var_info$variable %in%
        names(data)[vapply(data, function(z) anyNA(z), logical(1))]))) {
    table_tbl$Missing <- NULL
  }

  result <- list(
    inputs = list(
      data_name = deparse(substitute(data)),
      vars = vars,
      by = by,
      type = type,
      include = include,
      continuous_format = continuous_format,
      percent = percent,
      categorical = categorical,
      ci = ci,
      conf.level = conf.level,
      ci_digits = ci_digits,
      missing = missing,
      digits = digits,
      skew_cutoff = skew_cutoff,
      output = output
    ),
    variable_info = var_info,
    summary = summary_tbl,
    table = table_tbl,
    method = list(
      summary_rule = paste0(
        "Continuous variables are summarised using mean ",
        "(SD), median (IQR), or a recommended display ",
        "based on skewness; categorical variables use ",
        if (identical(percent, "none")) {
          "counts."
        } else {
          paste0("count (%) using the `", percent, "` denominator.")
        }
      )
    ),
    assumptions = .empty_assumptions(),
    diagnostics = .diagnostics_tbl(
      check = "Displayed denominator",
      result = percent,
      value = if (is.null(by)) {
        as.character(nrow(data))
      } else {
        paste(as.integer(table(data[[by]], useNA = "no")), collapse = "; ")
      },
      threshold = "Report non-missing denominators",
      detail = if (is.null(by)) {
        paste0("Categorical display uses the `", percent, "` denominator.")
      } else {
        paste0("Categorical display uses the `", percent, "` denominator.")
      }
    ),
    denominators = dplyr::bind_rows(lapply(
      seq_len(nrow(var_info)),
      function(i) {
        variable <- var_info$variable[[i]]
        if (identical(var_info$type[[i]], "continuous")) {
          .data_denominators(
            data,
            vars = variable,
            by = by,
            rule = "Non-missing continuous-summary denominator"
          )
        } else {
          .categorical_denominators(
            data,
            variable = variable,
            by = by,
            percent = percent
          )
        }
      }
    )),
    notes = if (is.null(by)) {
      c("Summary output without grouping.")
    } else {
      c(paste0("Summary output grouped by `", by, "`."))
    },
    call = match.call()
  )

  class(result) <- c("gt_summary", "gtstats", "list")
  result
}
