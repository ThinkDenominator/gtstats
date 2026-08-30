#' Add summary rows to a descriptive table
#'
#' Add summary statistics to a `gtstats` descriptive table builder.
#'
#' This function is the main way to populate a descriptive table with variable
#' summaries. It supports both grouped and ungrouped tables and can optionally
#' add an `Overall` column when the descriptive table was created with
#' `overall = TRUE`.
#'
#' Continuous variables can be displayed in one of four formats:
#' - `"recommended"`: mean (SD) or median (IQR) as appropriate
#' - `"mean_sd"`: mean (SD)
#' - `"mean_se"`: mean (standard error)
#' - `"mean_ci"`: mean with a t confidence interval
#' - `"median_iqr"`: median (IQR)
#' - `"both"`: mean (SD) and median (IQR)
#'
#' Variable names may be supplied either as bare names, for example
#' `c(age, sex, bmi)`, or as a character vector, for example
#' `c("age", "sex", "bmi")`.
#'
#' @param x A `gtstats_summary` object created with [summary_table()].
#' @param vars Variables to summarise. Can be supplied as bare names or as a
#'   character vector.
#' @param statistic Continuous summary selection. A single value
#'   applies to all selected continuous variables. A named character vector can
#'   select a different summary for each variable, for example
#'   `c(age = "mean_sd", bmi = "median_iqr")`. `"auto"` is accepted as an alias
#'   for `"recommended"`.
#' @param percent Denominator for categorical percentages: `"column"` uses the
#'   non-missing denominator within each group, `"row"` distributes each level
#'   across groups, `"overall"` uses the overall non-missing denominator, and
#'   `"none"` displays counts only.
#' @param categorical Display for categorical values: `"n_percent"`,
#'   `"n_over_N_percent"`, `"n"`, or `"percent"`.
#' @param categorical_layout Categorical display layout. `"combined"` keeps n
#'   and % together. `"separate"` creates distinct n and % child columns and is
#'   available for categorical-only tables without confidence intervals.
#' @param show_dichotomous How binary variables are displayed. `"all_levels"`
#'   (default) shows both levels. `"single_row"` shows one event level as a
#'   compact row using the variable label.
#' @param value Optional named character vector or named list selecting the
#'   event level used when `show_dichotomous = "single_row"`, for example
#'   `c(smoke = "Yes", hypertension = "Yes")`. When omitted, the second
#'   declared factor level (or the second sorted observed value) is used.
#' @param layout Table layout. `"compact"` keeps each summary in one cell;
#'   `"separate"` places summaries and confidence intervals in separate
#'   columns once intervals are added. It does not create empty CI columns.
#'   When omitted, the layout chosen in [summary_table()] is used.
#' @param overall_categorical Categorical display used only in the Overall
#'   column. `"auto"` uses counts only when `percent = "row"` and otherwise
#'   follows `categorical`. Other choices are `"n_percent"`,
#'   `"n_over_N_percent"`, `"n"`, and `"percent"`.
#' @param missing Missing-value display and percentage handling. `"ifany"`
#'   shows a missing row only when needed, `"always"` always shows it, and
#'   `"no"` hides it; these three use non-missing categorical denominators.
#'   `"as_category"` displays missing values as a category and includes them
#'   when calculating categorical percentages.
#' @param digits One number applied throughout, or a named numeric vector using
#'   `continuous`, `percent`, and `ci`.
#'
#' @return An updated `gtstats_summary` object with summary rows added.
#'
#' @examples
#' summary_table(mtcars, by = am) |>
#'   add_summary(vars = c(mpg, wt, cyl))
#'
#' summary_table(mtcars, by = am, overall = TRUE) |>
#'   add_summary(vars = c("mpg", "wt", "cyl"))
#'
#' summary_table(mtcars) |>
#'   add_summary(vars = c(mpg, wt), statistic = "mean_sd")
#'
#' missing_example <- mtcars
#' missing_example$vs[1:3] <- NA
#' summary_table(missing_example) |>
#'   add_summary(vars = vs, missing = "as_category")
#'
#' @export
add_summary <- function(
    x,
    vars,
    statistic = "recommended",
    percent = c("column", "row", "overall", "none"),
    categorical = c("n_percent", "n_over_N_percent", "n", "percent"),
    categorical_layout = c("combined", "separate"),
    overall_categorical = c("auto", "n_percent", "n_over_N_percent", "n", "percent"),
    show_dichotomous = c("all_levels", "single_row"),
    value = NULL,
    layout = NULL,
    missing = c("ifany", "always", "no", "as_category"),
    digits = 1
) {
  .validate_summary_builder(x, "add_summary")
  percent <- match.arg(percent)
  categorical <- match.arg(categorical)
  categorical_layout <- match.arg(categorical_layout)
  overall_categorical <- match.arg(overall_categorical)
  show_dichotomous <- match.arg(show_dichotomous)
  if (is.null(layout)) layout <- x$layout %||% "compact"
  layout <- match.arg(layout, c("compact", "separate"))
  missing <- match.arg(missing)
  conf.level <- x$conf.level %||% 0.95
  .validate_conf_level(conf.level)
  digits_map <- .resolve_summary_digits(digits)

  # Resolve variables from either bare names or character input
  vars_names <- .resolve_vars_arg(substitute(vars), env = parent.frame())
  .validate_data_vars(x$data, vars_names)
  value_map <- .resolve_dichotomous_values(
    value,
    data = x$data,
    vars = vars_names,
    show_dichotomous = show_dichotomous
  )
  selected_types <- vapply(
    vars_names, function(variable) .detect_type(x$data[[variable]]), character(1)
  )
  if (identical(categorical_layout, "separate")) {
    if (any(selected_types == "continuous")) {
      stop(
        "`categorical_layout = \"separate\"` is available for categorical-only tables. Use the combined layout for mixed tables.",
        call. = FALSE
      )
    }
    if (!categorical %in% c("n_percent", "n_over_N_percent")) {
      stop(
        "Separate n and % columns require `categorical = \"n_percent\"` or `\"n_over_N_percent\"`.",
        call. = FALSE
      )
    }
  }

  statistic_map <- stats::setNames(
    rep("recommended", length(vars_names)),
    vars_names
  )
  if (!is.null(statistic)) {
    if (!is.character(statistic) || length(statistic) < 1L ||
        anyNA(statistic)) {
      stop("`statistic` must be a character value or vector.", call. = FALSE)
    }

    statistic <- tolower(statistic)
    statistic[statistic == "auto"] <- "recommended"
    allowed <- c("recommended", "mean_sd", "mean_se", "mean_ci", "median_iqr", "both")
    unsupported <- setdiff(unname(statistic), allowed)
    if (length(unsupported) > 0L) {
      stop(
        "Unsupported `statistic`: ",
        paste(unique(unsupported), collapse = ", "),
        ".",
        call. = FALSE
      )
    }

    if (length(statistic) == 1L && is.null(names(statistic))) {
      statistic_map[] <- statistic
    } else {
      if (is.null(names(statistic)) || any(!nzchar(names(statistic)))) {
        stop(
          "Multiple `statistic` values must be named by variable.",
          call. = FALSE
        )
      }
      fallback_name <- intersect(names(statistic), "continuous")
      if (length(fallback_name) > 0L) {
        statistic_map[] <- unname(statistic[[fallback_name[[1L]]]])
        statistic <- statistic[names(statistic) != "continuous"]
      }
      unknown <- setdiff(names(statistic), vars_names)
      if (length(unknown) > 0L) {
        stop(
          "`statistic` names not selected in `vars`: ",
          paste(unknown, collapse = ", "),
          ".",
          call. = FALSE
        )
      }
      if (length(statistic) > 0L) {
        statistic_map[names(statistic)] <- statistic
      }
    }
  }

  # Resolve the automatic choice once per variable. A comparative table should
  # use one descriptive format across Overall and every displayed group.
  statistic_requested <- statistic_map
  resolve_recommended <- function(variable) {
    if (!identical(.detect_type(x$data[[variable]]), "continuous")) {
      return(statistic_map[[variable]])
    }
    populations <- list(x$data[[variable]])
    if (!is.null(x$by)) {
      observed_groups <- unique(x$data[[x$by]][!is.na(x$data[[x$by]])])
      grouped <- lapply(observed_groups, function(group_value) {
        x$data[[variable]][
          !is.na(x$data[[x$by]]) &
            as.character(x$data[[x$by]]) == as.character(group_value)
        ]
      })
      populations <- c(if (isTRUE(x$overall)) populations else list(), grouped)
    }
    skewness <- vapply(populations, function(values) {
      values <- values[is.finite(values)]
      if (length(values) < 3L) return(NA_real_)
      spread <- stats::sd(values)
      if (!is.finite(spread) || spread == 0) return(0)
      mean((values - mean(values))^3) / spread^3
    }, numeric(1))
    if (any(abs(skewness) >= 1, na.rm = TRUE)) "median_iqr" else "mean_sd"
  }
  recommended <- names(statistic_map)[statistic_map == "recommended"]
  if (length(recommended) > 0L) {
    statistic_map[recommended] <- vapply(recommended, resolve_recommended, character(1))
  }

  build_summary_table <- function(by = NULL, categorical_override = categorical) {
    pieces <- lapply(vars_names, function(variable) {
      variable_type <- .detect_type(x$data[[variable]])
      summary_data <- x$data
      if (identical(missing, "as_category") &&
          !identical(variable_type, "continuous") &&
          anyNA(summary_data[[variable]])) {
        original <- summary_data[[variable]]
        original_label <- attr(original, "label", exact = TRUE)
        values <- as.character(original)
        if (any(values == "Missing", na.rm = TRUE)) {
          stop(
            "`missing = \"as_category\"` cannot distinguish R missing values from an existing category named \"Missing\" in `",
            variable,
            "`. Rename that recorded category before building the table.",
            call. = FALSE
          )
        }
        values[is.na(values)] <- "Missing"
        if (is.factor(original)) {
          original_levels <- levels(original)
          summary_data[[variable]] <- factor(
            values,
            levels = unique(c(original_levels, "Missing")),
            ordered = is.ordered(original)
          )
        } else {
          summary_data[[variable]] <- values
        }
        if (!is.null(original_label)) {
          attr(summary_data[[variable]], "label") <- original_label
        }
      }
      variable_digits <- if (identical(variable_type, "continuous")) {
        digits_map[["continuous"]]
      } else {
        digits_map[["percent"]]
      }
      percent_value <- if (is.null(by) && identical(percent, "row")) {
        "overall"
      } else {
        percent
      }
      args <- list(
        data = summary_data,
        vars = variable,
        continuous_format = statistic_map[[variable]],
        percent = percent_value,
        categorical = categorical_override,
        ci = FALSE,
        conf.level = conf.level,
        ci_method = "wilson",
        ci_digits = digits_map[["ci"]],
        missing = "no",
        digits = variable_digits
      )
      if (!is.null(by)) {
        args$by <- by
      }
      piece <- do.call(.build_summary_stats, args)$table
      # Retain the source name while assembling the table. Publication labels
      # are not guaranteed to be unique, so they are not safe ordering keys.
      piece$.gtstats_variable <- variable
      if (identical(missing, "as_category") &&
          any(as.character(piece$Level) == "Missing")) {
        piece <- dplyr::bind_rows(
          piece[as.character(piece$Level) != "Missing", , drop = FALSE],
          piece[as.character(piece$Level) == "Missing", , drop = FALSE]
        )
      }
      if (identical(show_dichotomous, "single_row") &&
          identical(variable_type, "binary")) {
        selected_level <- value_map[[variable]]
        keep <- as.character(piece$Level) == selected_level
        if (identical(missing, "as_category")) {
          keep <- keep | as.character(piece$Level) == "Missing"
        }
        piece <- piece[keep, , drop = FALSE]
        if (identical(missing, "as_category") && nrow(piece) > 1L) {
          piece <- dplyr::bind_rows(
            piece[as.character(piece$Level) == selected_level, , drop = FALSE],
            piece[as.character(piece$Level) == "Missing", , drop = FALSE]
          )
        }
        # A compact dichotomous result is one publication row, not a parent row
        # followed by one indented child. The selected event remains available
        # in `x$dichotomous_values` for auditing and reproducible code.
        piece$Level[as.character(piece$Level) == selected_level] <- ""
      }
      piece
    })
    dplyr::bind_rows(pieces)
  }

  # Build grouped or ungrouped summary table depending on whether `by` is used
  tbl <- build_summary_table(by = x$by)
  tbl <- tbl[, setdiff(names(tbl), c("Type", "Missing")), drop = FALSE]
  tbl <- tibble::as_tibble(tbl)

  # Rename Summary to Value when there is no grouping and no overall column
  if (is.null(x$by) && !isTRUE(x$overall) && "Summary" %in% names(tbl)) {
    names(tbl)[names(tbl) == "Summary"] <- "Value"
  }

  # If overall summaries are requested, calculate them separately and merge
  if (isTRUE(x$overall)) {
    resolved_overall_categorical <- if (identical(overall_categorical, "auto")) {
      if (identical(percent, "row")) "n" else categorical
    } else {
      overall_categorical
    }
    overall_tbl <- build_summary_table(
      categorical_override = resolved_overall_categorical
    )

    if ("Summary" %in% names(overall_tbl)) {
      overall_tbl <- overall_tbl[, c(
        ".gtstats_variable", "Variable", "Level", "Summary"
      )]
      names(overall_tbl)[4] <- "Overall"

      tbl <- merge(
        overall_tbl,
        tbl,
        by = c(".gtstats_variable", "Variable", "Level"),
        all = TRUE,
        sort = FALSE
      )

      # Keep a consistent display order using the requested overall position.
      group_columns <- setdiff(
        names(tbl),
        c(".gtstats_variable", "Variable", "Level", "Overall")
      )
      preferred_order <- if (identical(x$overall_position, "last")) {
        c(".gtstats_variable", "Variable", "Level", group_columns, "Overall")
      } else {
        c(".gtstats_variable", "Variable", "Level", "Overall", group_columns)
      }

      tbl <- tbl[, preferred_order[preferred_order %in% names(tbl)],
                 drop = FALSE]
      tbl <- tibble::as_tibble(tbl)
    }
  }

  # Add explicit missing rows using the same displayed columns as the summary.
  if (!identical(missing, "no")) {
    format_missing <- function(n_missing, denominator, display = categorical) {
      percentage <- .format_number(
        if (denominator > 0) 100 * n_missing / denominator else NA_real_,
        digits_map[["percent"]]
      )
      if (identical(display, "n")) return(as.character(n_missing))
      if (identical(display, "percent")) return(paste0(percentage, "%"))
      if (identical(display, "n_over_N_percent")) {
        return(paste0(n_missing, "/", denominator, " (", percentage, "%)"))
      }
      paste0(n_missing, " (", percentage, "%)")
    }

    missing_rows <- lapply(vars_names, function(variable) {
      n_missing_all <- sum(is.na(x$data[[variable]]))
      variable_type <- .detect_type(x$data[[variable]])
      if (identical(missing, "as_category") &&
          !identical(variable_type, "continuous")) {
        return(NULL)
      }
      if (missing %in% c("ifany", "as_category") && n_missing_all == 0L) {
        return(NULL)
      }

      row <- tibble::tibble(
        .gtstats_variable = variable,
        Variable = .get_var_label(x$data, variable),
        Level = "Missing"
      )
      if (isTRUE(x$overall)) {
        overall_missing_display <- if (identical(overall_categorical, "auto")) {
          if (identical(percent, "row")) "n" else categorical
        } else {
          overall_categorical
        }
        row$Overall <- format_missing(
          n_missing_all, nrow(x$data), display = overall_missing_display
        )
      }
      if (!is.null(x$by)) {
        group_columns <- .builder_group_columns(x)
        for (group_value in names(group_columns)) {
          idx <- !is.na(x$data[[x$by]]) &
            as.character(x$data[[x$by]]) == group_value
          row[[group_columns[[group_value]]]] <- format_missing(
            sum(is.na(x$data[[variable]][idx])),
            sum(idx)
          )
        }
      } else if (!isTRUE(x$overall)) {
        row$Value <- format_missing(n_missing_all, nrow(x$data))
      }
      row
    })
    missing_rows <- dplyr::bind_rows(missing_rows)
    if (nrow(missing_rows) > 0L) {
      tbl <- dplyr::bind_rows(tbl, missing_rows)
    }
  }

  # Keep every missing row immediately after the summaries for its variable.
  # This also prevents visually duplicated, unlabelled Missing rows at the end
  # of publication tables.
  source_order <- match(tbl$.gtstats_variable, vars_names)
  tbl <- tbl[order(source_order, seq_len(nrow(tbl))), , drop = FALSE]
  tbl$.gtstats_variable <- NULL

  # Add summary rows to an empty builder or merge into an existing table
  if (is.null(x$table)) {
    x$table <- tbl
  } else {
    common_keys <- intersect(c("Variable", "Level"), names(x$table))

    if (length(common_keys) < 2) {
      stop(
        "Existing table structure is not compatible with summary rows.",
        call. = FALSE
      )
    }

    existing_keys <- paste(x$table$Variable, x$table$Level, sep = "\r")
    new_keys <- paste(tbl$Variable, tbl$Level, sep = "\r")
    duplicate_keys <- intersect(existing_keys, new_keys)
    if (length(duplicate_keys) > 0L) {
      stop(
        "One or more selected variables already exist in the summary table.",
        call. = FALSE
      )
    }

    x <- .append_builder_rows(x, tbl)
  }

  x$layout <- layout
  # Record component type
  x$components <- unique(c(x$components, "summary"))
  x$summary_statistics <- c(
    x$summary_statistics %||% character(),
    statistic_map
  )
  x$summary_statistics_requested <- c(
    x$summary_statistics_requested %||% character(),
    statistic_requested
  )
  x$percent <- percent
  x$categorical <- categorical
  x$categorical_layout <- categorical_layout
  x$overall_categorical <- overall_categorical
  x$show_dichotomous <- show_dichotomous
  x$dichotomous_values <- c(
    x$dichotomous_values %||% character(),
    value_map
  )
  x$digits <- digits_map
  x$missing <- missing
  x$method$percentage_denominator <- percent
  x$method$missing_rows <- missing
  make_denominator_rows <- function(by = NULL) {
    dplyr::bind_rows(lapply(vars_names, function(variable) {
      if (identical(.detect_type(x$data[[variable]]), "continuous")) {
        .data_denominators(
          x$data,
          vars = variable,
          by = by,
          rule = "Non-missing continuous-summary denominator"
        )
      } else {
        .categorical_denominators(
          x$data,
          variable = variable,
          by = by,
          percent = if (is.null(by) && identical(percent, "row")) {
            "overall"
          } else {
            percent
          },
          missing = if (identical(missing, "as_category")) {
            "as_category"
          } else {
            "exclude"
          }
        )
      }
    }))
  }
  denominator_rows <- make_denominator_rows(by = x$by)
  if (isTRUE(x$overall) && !is.null(x$by)) {
    denominator_rows <- dplyr::bind_rows(
      make_denominator_rows(),
      denominator_rows
    )
  }
  x$denominators <- dplyr::bind_rows(
    x$denominators %||% .empty_denominators(),
    denominator_rows
  )

  # Add explanatory footnote describing how values are displayed
  variable_types <- vapply(
    vars_names, function(variable) .detect_type(x$data[[variable]]), character(1)
  )
  has_continuous <- any(variable_types == "continuous")
  has_categorical <- any(variable_types != "continuous")
  continuous_variables <- names(variable_types)[variable_types == "continuous"]
  footnote_format <- unique(unname(statistic_map[continuous_variables]))
  footnote_format <- if (length(footnote_format) == 1L) {
    footnote_format[[1L]]
  } else {
    "mixed"
  }

  footnote_text <- if (!has_continuous) {
    character()
  } else if (footnote_format == "mean_sd") {
    "Continuous variables are shown as mean (SD)."
  } else if (footnote_format == "mean_se") {
    paste0(
      "Continuous variables are shown as mean (SE). SE is the standard error ",
      "of the estimated mean, not the variability of individual observations."
    )
  } else if (footnote_format == "mean_ci") {
    paste0(
      "Continuous variables are shown as mean (", round(100 * conf.level),
      "% CI)."
    )
  } else if (footnote_format == "median_iqr") {
    "Continuous variables are shown as median (IQR)."
  } else if (footnote_format == "recommended") {
    paste0(
      "Continuous variables are shown as mean (SD) or median (IQR) ",
      "as appropriate."
    )
  } else if (footnote_format == "both") {
    "Continuous variables are shown as mean (SD) and median (IQR)."
  } else {
    "Continuous variables use the specified summary statistics."
  }

  x$footnotes <- unique(c(
    x$footnotes,
    footnote_text,
    if (!has_categorical) {
      character()
    } else if (identical(categorical, "n") || identical(percent, "none")) {
      "Categorical variables are shown as counts."
    } else if (identical(categorical, "percent")) {
      "Categorical variables are shown as percentages."
    } else if (identical(categorical, "n_over_N_percent")) {
      paste0(
        "Categorical variables are shown as n/N (%) using the ",
        percent, " denominator."
      )
    } else {
      paste0("Categorical percentages use the ", percent, " denominator.")
    },
    if (identical(missing, "as_category") && has_categorical &&
        any(vapply(
          x$data[names(variable_types)[variable_types != "continuous"]],
          function(value) anyNA(value), logical(1)
        ))) {
      paste0(
        "Missing values are treated as a category and included when ",
        "calculating categorical percentages."
      )
    } else if (!identical(missing, "no") &&
        (identical(missing, "always") ||
         any(vapply(x$data[vars_names], function(value) anyNA(value), logical(1))))) {
      paste0("Missing-value rows are shown ", missing, ".")
    } else {
      character()
    }
  ))

  if (identical(categorical_layout, "separate")) {
    x <- .builder_use_separate_categorical_layout(x)
  }

  x
}
