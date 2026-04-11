#' Summary statistics
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
#' @param recommend Logical; whether to include a recommendation
#'   column internally.
#' @param normality_check Logical; currently reserved for future
#'   versions.
#' @param missing How to display missingness. One of `"ifany"`,
#'   `"no"`, or `"always"`.
#' @param digits Number of decimal places used for formatting.
#' @param conf.level Confidence level; currently reserved for future
#'   versions.
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
#' @examples
#' summary_stats(mtcars)
#'
#' summary_stats(mtcars, by = am)
#'
#' summary_stats(
#'   mtcars,
#'   vars = c("mpg", "wt", "cyl"),
#'   continuous_format = "mean_sd"
#' )
#'
#' tbl_stats(summary_stats(mtcars, by = am))
#'
#' @export
summary_stats <- function(
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
      "median_iqr",
      "both"
    ),
    recommend = TRUE,
    normality_check = FALSE,
    missing = c("ifany", "no", "always"),
    digits = 1,
    conf.level = 0.95,
    output = c("table", "tibble", "both"),
    quiet = FALSE
) {
  include <- match.arg(include)
  continuous_format <- match.arg(continuous_format)
  missing <- match.arg(missing)
  output <- match.arg(output)

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
    median_iqr,
    continuous_format,
    recommendation
  ) {
    switch(
      continuous_format,
      both = paste0(mean_sd, "; ", median_iqr),
      mean_sd = mean_sd,
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

        recommendation <- if (recommend) {
          if (!is.na(skew_val) && abs(skew_val) >= 1) {
            "Median (IQR) preferred"
          } else {
            "Mean (SD) appropriate"
          }
        } else {
          NA_character_
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
          median_iqr = median_iqr,
          range = range_val,
          count_pct = NA_character_,
          recommendation = recommendation,
          display_value = .make_cont_display(
            mean_sd = mean_sd,
            median_iqr = median_iqr,
            continuous_format = continuous_format,
            recommendation = recommendation
          ),
          notes = ""
        )
      } else {
        tab <- table(x, useNA = "no")
        pct <- prop.table(tab) * 100

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
          median_iqr = NA_character_,
          range = NA_character_,
          count_pct = paste0(
            as.numeric(tab),
            " (",
            .fmt_num(as.numeric(pct), digits),
            "%)"
          ),
          recommendation = if (recommend) "Count (%)" else NA_character_,
          display_value = paste0(
            as.numeric(tab),
            " (",
            .fmt_num(as.numeric(pct), digits),
            "%)"
          ),
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
    group_labels <- paste0(by, " = ", group_values_chr)
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

            recommendation_tmp <- if (recommend) {
              if (!is.na(skew_val) && abs(skew_val) >= 1) {
                "Median (IQR) preferred"
              } else {
                "Mean (SD) appropriate"
              }
            } else {
              NA_character_
            }

            display_value <- .make_cont_display(
              mean_sd = mean_sd,
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

          pct <- if (sum(tab) == 0) {
            rep(NA_real_, length(tab))
          } else {
            as.numeric(tab) / sum(tab) * 100
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
                percent = as.numeric(pct[j]),
                mean_sd = NA_character_,
                median_iqr = NA_character_,
                range = NA_character_,
                count_pct = paste0(
                  as.numeric(tab[j]),
                  " (",
                  .fmt_num(as.numeric(pct[j]), digits),
                  "%)"
                ),
                recommendation = if (recommend) {
                  "Count (%)"
                } else {
                  NA_character_
                },
                display_value = paste0(
                  as.numeric(tab[j]),
                  " (",
                  .fmt_num(as.numeric(pct[j]), digits),
                  "%)"
                ),
                notes = ""
              )
          }
        }
      }
    }

    summary_tbl <- dplyr::bind_rows(summary_list)

    row_keys <- dplyr::distinct(
      summary_tbl[, c("label", "level", "type")]
    )

    names(row_keys) <- c("Variable", "Level", "Type")
    row_keys$Level[is.na(row_keys$Level)] <- ""

    group_tables <- lapply(group_values_chr, function(g) {
      tmp <- summary_tbl[
        summary_tbl$group_level == g,
        c("label", "level", "display_value")
      ]

      names(tmp) <- c("Variable", "Level", group_labels[[g]])
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

  result <- list(
    inputs = list(
      data_name = deparse(substitute(data)),
      vars = vars,
      by = by,
      type = type,
      include = include,
      continuous_format = continuous_format,
      recommend = recommend,
      normality_check = normality_check,
      missing = missing,
      digits = digits,
      conf.level = conf.level,
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
        "count (%)."
      )
    ),
    notes = if (is.null(by)) {
      c("Summary output without grouping.")
    } else {
      c(paste0("Summary output grouped by `", by, "`."))
    },
    call = match.call()
  )

  class(result) <- "gt_summary"
  result
}
