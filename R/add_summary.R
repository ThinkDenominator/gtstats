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
#' - `"mean_ci"`: mean with a t confidence interval
#' - `"median_iqr"`: median (IQR)
#' - `"both"`: mean (SD) and median (IQR)
#'
#' Variable names may be supplied either as bare names, for example
#' `c(age, sex, bmi)`, or as a character vector, for example
#' `c("age", "sex", "bmi")`.
#'
#' @param x A `gt_desc_table` object created with [summary_table()].
#' @param vars Variables to summarise. Can be supplied as bare names or as a
#'   character vector.
#' @param continuous_format Format to use for continuous variables. One of
#'   `"recommended"`, `"mean_sd"`, `"mean_ci"`, `"median_iqr"`, or `"both"`.
#' @param statistic Optional continuous summary selection. A single value
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
#' @param ci Logical; append confidence intervals to categorical proportions.
#' @param conf.level Confidence level for categorical proportion intervals.
#' @param missing Whether explicit missing-value rows are shown: `"ifany"`,
#'   `"always"`, or `"no"`.
#' @param digits One number applied throughout, or a named numeric vector using
#'   `continuous`, `percent`, and `ci`.
#'
#' @return An updated `gt_desc_table` object with summary rows added.
#'
#' @examples
#' summary_table(mtcars, by = am) |>
#'   add_summary(vars = c(mpg, wt, cyl))
#'
#' summary_table(mtcars, by = am, overall = TRUE) |>
#'   add_summary(vars = c("mpg", "wt", "cyl"))
#'
#' summary_table(mtcars) |>
#'   add_summary(vars = c(mpg, wt), continuous_format = "mean_sd")
#'
#' @export
add_summary <- function(
    x,
    vars,
    continuous_format = c("recommended", "mean_sd", "mean_ci", "median_iqr", "both"),
    statistic = NULL,
    percent = c("column", "row", "overall", "none"),
    categorical = c("n_percent", "n_over_N_percent", "n", "percent"),
    ci = FALSE,
    conf.level = 0.95,
    missing = c("ifany", "always", "no"),
    digits = 1
) {
  continuous_format <- match.arg(continuous_format)
  percent <- match.arg(percent)
  categorical <- match.arg(categorical)
  missing <- match.arg(missing)
  .validate_summary_builder(x, "add_summary", mode = "summary")
  .validate_flag(ci, "ci")
  .validate_conf_level(conf.level)
  digits_map <- .resolve_summary_digits(digits)
  if (isTRUE(ci) && identical(categorical, "n")) {
    stop(
      "`ci = TRUE` requires a percentage-based `categorical` display.",
      call. = FALSE
    )
  }

  # Resolve variables from either bare names or character input
  vars_names <- .resolve_vars_arg(substitute(vars), env = parent.frame())
  .validate_data_vars(x$data, vars_names)

  statistic_map <- stats::setNames(
    rep(continuous_format, length(vars_names)),
    vars_names
  )
  if (!is.null(statistic)) {
    if (!is.character(statistic) || length(statistic) < 1L ||
        anyNA(statistic)) {
      stop("`statistic` must be a character value or vector.", call. = FALSE)
    }

    statistic <- tolower(statistic)
    statistic[statistic == "auto"] <- "recommended"
    allowed <- c("recommended", "mean_sd", "mean_ci", "median_iqr", "both")
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
      unknown <- setdiff(names(statistic), vars_names)
      if (length(unknown) > 0L) {
        stop(
          "`statistic` names not selected in `vars`: ",
          paste(unknown, collapse = ", "),
          ".",
          call. = FALSE
        )
      }
      statistic_map[names(statistic)] <- statistic
    }
  }

  build_summary_table <- function(by = NULL) {
    pieces <- lapply(vars_names, function(variable) {
      variable_type <- .detect_type(x$data[[variable]])
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
        data = x$data,
        vars = variable,
        continuous_format = statistic_map[[variable]],
        percent = percent_value,
        categorical = categorical,
        ci = ci,
        conf.level = conf.level,
        ci_digits = digits_map[["ci"]],
        missing = "no",
        digits = variable_digits
      )
      if (!is.null(by)) {
        args$by <- by
      }
      do.call(.build_summary_stats, args)$table
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
    overall_tbl <- build_summary_table()

    if ("Summary" %in% names(overall_tbl)) {
      overall_tbl <- overall_tbl[, c("Variable", "Level", "Summary")]
      names(overall_tbl)[3] <- "Overall"

      tbl <- merge(
        overall_tbl,
        tbl,
        by = c("Variable", "Level"),
        all = TRUE,
        sort = FALSE
      )

      # Keep a consistent display order using the requested overall position.
      group_columns <- setdiff(
        names(tbl),
        c("Variable", "Level", "Overall")
      )
      preferred_order <- if (identical(x$overall_position, "last")) {
        c("Variable", "Level", group_columns, "Overall")
      } else {
        c("Variable", "Level", "Overall", group_columns)
      }

      tbl <- tbl[, preferred_order[preferred_order %in% names(tbl)],
                 drop = FALSE]
      tbl <- tibble::as_tibble(tbl)
    }
  }

  # Add explicit missing rows using the same displayed columns as the summary.
  if (!identical(missing, "no")) {
    format_missing <- function(n_missing, denominator) {
      paste0(
        n_missing,
        " (",
        .format_number(
          if (denominator > 0) 100 * n_missing / denominator else NA_real_,
          digits_map[["percent"]]
        ),
        "%)"
      )
    }

    missing_rows <- lapply(vars_names, function(variable) {
      n_missing_all <- sum(is.na(x$data[[variable]]))
      if (identical(missing, "ifany") && n_missing_all == 0L) {
        return(NULL)
      }

      row <- tibble::tibble(
        Variable = .get_var_label(x$data, variable),
        Level = "Missing"
      )
      if (isTRUE(x$overall)) {
        row$Overall <- format_missing(n_missing_all, nrow(x$data))
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

  # Record component type
  x$components <- unique(c(x$components, "summary"))
  x$summary_statistics <- c(
    x$summary_statistics %||% character(),
    statistic_map
  )
  x$percent <- percent
  x$categorical <- categorical
  x$ci <- ci
  x$conf.level <- conf.level
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
  has_by <- !is.null(x$by)
  footnote_format <- unique(unname(statistic_map))
  footnote_format <- if (length(footnote_format) == 1L) {
    footnote_format[[1L]]
  } else {
    "mixed"
  }

  footnote_text <- if (footnote_format == "mean_sd") {
    if (has_by) {
      paste0(
        "Continuous variables are shown as mean (SD); ",
        "categorical variables as n (%) within each group."
      )
    } else {
      paste0(
        "Continuous variables are shown as mean (SD); ",
        "categorical variables as n (%)."
      )
    }
  } else if (footnote_format == "mean_ci") {
    if (has_by) {
      paste0(
        "Continuous variables are shown as mean (", round(100 * conf.level),
        "% CI); categorical variables as n (%) within each group."
      )
    } else {
      paste0(
        "Continuous variables are shown as mean (", round(100 * conf.level),
        "% CI); categorical variables as n (%)."
      )
    }
  } else if (footnote_format == "median_iqr") {
    if (has_by) {
      paste0(
        "Continuous variables are shown as median (IQR); ",
        "categorical variables as n (%) within each group."
      )
    } else {
      paste0(
        "Continuous variables are shown as median (IQR); ",
        "categorical variables as n (%)."
      )
    }
  } else if (footnote_format == "recommended") {
    if (has_by) {
      paste0(
        "Continuous variables are shown as mean (SD) or median (IQR) ",
        "as appropriate; categorical variables as n (%) within each group."
      )
    } else {
      paste0(
        "Continuous variables are shown as mean (SD) or median (IQR) ",
        "as appropriate; categorical variables as n (%)."
      )
    }
  } else if (footnote_format == "both") {
    if (has_by) {
      paste0(
        "Continuous variables are shown as mean (SD) and median (IQR); ",
        "categorical variables as n (%) within each group."
      )
    } else {
      paste0(
        "Continuous variables are shown as mean (SD) and median (IQR); ",
        "categorical variables as n (%)."
      )
    }
  } else {
    "Continuous variables use the specified summary statistics."
  }

  x$footnotes <- unique(c(
    x$footnotes,
    footnote_text,
    if (identical(categorical, "n") || identical(percent, "none")) {
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
    if (isTRUE(ci)) {
      paste0(
        "Categorical proportions include ",
        round(100 * conf.level),
        "% exact binomial confidence intervals."
      )
    } else {
      character()
    },
    if (!identical(missing, "no")) {
      paste0("Missing-value rows are shown ", missing, ".")
    } else {
      character()
    }
  ))

  x
}
