#' Print a gtstats describe object
#'
#' Print a compact console preview of a `gt_describe` object.
#'
#' The print method shows the dataset name, the first few rows of the
#' display-ready table, and a short reminder of the main object
#' components available for further use.
#'
#' @param x A `gt_describe` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- describe_data(mtcars)
#' print(x)
#'
#' @export
print.gt_describe <- function(x, ...) {
  cat("GTstats: Dataset overview\n")
  cat("Data:", x$inputs$data_name, "\n\n")

  print(utils::head(x$table, 10))

  if (nrow(x$table) > 10) {
    cat("\nShowing first 10 variables only.\n")
  }

  cat("\nObject contains: $summary, $table, $inputs, $notes\n")
  cat("Use tbl_stats(x) for a formatted table.\n")

  invisible(x)
}

#' Print a gtstats summary object
#'
#' Print a compact console preview of a `gt_summary` object.
#'
#' The print method shows the dataset name, optional grouping variable,
#' the first few rows of the summary table, and a short description of
#' the summary format used for continuous and categorical variables.
#'
#' @param x A `gt_summary` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- summary_stats(mtcars, by = am)
#' print(x)
#'
#' @export
print.gt_summary <- function(x, ...) {
  cat("GTstats: Summary statistics\n")
  cat("Data:", x$inputs$data_name, "\n")

  if (!is.null(x$inputs$by)) {
    cat("Grouped by:", x$inputs$by, "\n")
  }

  cat("\n")
  print(utils::head(x$table, 10))

  if (nrow(x$table) > 10) {
    cat("\nShowing first 10 rows only.\n")
  }

  footnote_text <- if (x$inputs$continuous_format == "mean_sd") {
    if (!is.null(x$inputs$by)) {
      paste0(
        "Continuous summaries are shown as mean (SD). ",
        "Categorical summaries are shown as n (%) within each ",
        "group."
      )
    } else {
      paste0(
        "Continuous summaries are shown as mean (SD). ",
        "Categorical summaries are shown as n (%)."
      )
    }
  } else if (x$inputs$continuous_format == "median_iqr") {
    if (!is.null(x$inputs$by)) {
      paste0(
        "Continuous summaries are shown as median (IQR). ",
        "Categorical summaries are shown as n (%) within each ",
        "group."
      )
    } else {
      paste0(
        "Continuous summaries are shown as median (IQR). ",
        "Categorical summaries are shown as n (%)."
      )
    }
  } else if (x$inputs$continuous_format == "recommended") {
    if (!is.null(x$inputs$by)) {
      paste0(
        "Continuous summaries are shown as mean (SD) or median ",
        "(IQR) as appropriate. Categorical summaries are shown ",
        "as n (%) within each group."
      )
    } else {
      paste0(
        "Continuous summaries are shown as mean (SD) or median ",
        "(IQR) as appropriate. Categorical summaries are shown ",
        "as n (%)."
      )
    }
  } else {
    if (!is.null(x$inputs$by)) {
      paste0(
        "Continuous summaries are shown as mean (SD); median ",
        "(IQR). Categorical summaries are shown as n (%) ",
        "within each group."
      )
    } else {
      paste0(
        "Continuous summaries are shown as mean (SD); median ",
        "(IQR). Categorical summaries are shown as n (%)."
      )
    }
  }

  cat("\n", footnote_text, "\n", sep = "")
  cat(
    "Object contains: $summary, $table, $variable_info, ",
    "$inputs, $notes\n",
    sep = ""
  )
  cat("Use tbl_stats(x) for a formatted table.\n")

  invisible(x)
}

#' Print a gtstats distribution object
#'
#' Print a compact console preview of a `gt_distribution` object.
#'
#' The print method shows the dataset name, optional grouping variable,
#' the first few rows of the distribution table, and a short reminder of
#' the practical guidance used for symmetric and skewed variables.
#'
#' @param x A `gt_distribution` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- check_distribution(mtcars)
#' print(x)
#'
#' @export
print.gt_distribution <- function(x, ...) {
  cat("GTstats: Distribution check\n")
  cat("Data:", x$inputs$data_name, "\n")

  if (!is.null(x$inputs$by)) {
    cat("Grouped by:", x$inputs$by, "\n")
  }

  cat("\n")
  print(utils::head(x$table, 10))

  if (nrow(x$table) > 10) {
    cat("\nShowing first 10 rows only.\n")
  }

  cat("\nGuidance:\n")
  cat("- Approximately symmetric -> Mean (SD), t-test, ANOVA\n")
  cat("- Skewed -> Median (IQR), Wilcoxon, Kruskal-Wallis\n")
  cat("Object contains: $summary, $table, $inputs, $notes\n")
  cat("Use tbl_stats(x) for a formatted table.\n")

  invisible(x)
}

#' Print a gtstats compare object
#'
#' Print a compact console preview of a `gt_compare` object.
#'
#' The print method shows the dataset name, outcome, grouping variable,
#' a brief descriptive summary, and the display-ready inferential
#' results table.
#'
#' @param x A `gt_compare` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- compare_groups(mtcars, outcome = mpg, group = am)
#' print(x)
#'
#' @export
print.gt_compare <- function(x, ...) {
  cat("GTstats: Group comparison\n")
  cat("Data:", x$inputs$data_name, "\n")
  cat("Outcome:", x$inputs$outcome, "\n")
  cat("Group:", x$inputs$group, "\n\n")

  if (!is.null(x$descriptives) && nrow(x$descriptives) > 0) {
    cat("Descriptive summary\n")

    desc <- x$descriptives

    if (all(is.na(desc$level))) {
      desc_show <- desc[, c("group_level", "n", "display_value")]
      names(desc_show) <- c("Group", "n", "Summary")
      print(desc_show)
    } else {
      desc_show <- desc[, c("group_level", "level", "display_value")]
      names(desc_show) <- c("Group", "Level", "Summary")
      print(utils::head(desc_show, 10))

      if (nrow(desc_show) > 10) {
        cat("\nShowing first 10 descriptive rows only.\n")
      }
    }

    cat("\nInferential result\n")
  }

  print(x$table)

  cat(
    "\nObject contains: $descriptives, $inferential, $table, ",
    "$inputs, $notes\n",
    sep = ""
  )
  cat("Use tbl_stats(x) for a formatted table.\n")

  invisible(x)
}

#' Print a gtstats correlation object
#'
#' Print a compact console preview of a `gt_correlation` object.
#'
#' The print method shows the dataset name, the two variables analysed,
#' and the display-ready correlation results table.
#'
#' @param x A `gt_correlation` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- correlate_vars(mtcars, x = mpg, y = wt)
#' print(x)
#'
#' @export
print.gt_correlation <- function(x, ...) {
  cat("GTstats: Correlation analysis\n")
  cat("Data:", x$inputs$data_name, "\n")
  cat("X:", x$inputs$x, "\n")
  cat("Y:", x$inputs$y, "\n\n")

  print(x$table)

  cat("\nObject contains: $summary, $table, $inputs, $notes\n")
  cat("Use tbl_stats(x) for a formatted table.\n")

  invisible(x)
}

#' Print a descriptive table builder
#'
#' Print a compact console preview of a `gt_desc_table` object.
#'
#' The print method shows the table mode, source data, grouping status,
#' whether an overall column is requested, and the first few rows of the
#' current table builder.
#'
#' @param x A `gt_desc_table` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- descriptive_table(mtcars, by = am, overall = TRUE)
#' print(x)
#'
#' @export
print.gt_desc_table <- function(x, ...) {
  cat("GTstats: Descriptive table builder\n")
  cat("Mode:", x$mode, "\n")
  cat("Data:", deparse(x$call$data), "\n")

  if (!is.null(x$by)) {
    cat("Grouped by:", x$by, "\n")
  }

  cat(
    "Overall column:",
    if (isTRUE(x$overall)) "Yes" else "No",
    "\n"
  )

  cat(
    "Components added:",
    if (length(x$components) == 0) {
      "None"
    } else {
      paste(x$components, collapse = ", ")
    },
    "\n\n"
  )

  if (is.null(x$table)) {
    cat("No rows have been added yet.\n")
  } else {
    print(utils::head(x$table, 10))

    if (nrow(x$table) > 10) {
      cat("\nShowing first 10 rows only.\n")
    }
  }

  cat("\nUse tbl_stats(x) for a formatted table.\n")

  invisible(x)
}

#' Print a gtstats proportion object
#'
#' Print a compact console preview of a `gt_prop` object.
#'
#' The print method shows the dataset name, variable, selected level,
#' optional grouping variable, and the display-ready proportion table.
#'
#' @param x A `gt_prop` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- prop_ci(mtcars, var = vs, by = am)
#' print(x)
#'
#' @export
print.gt_prop <- function(x, ...) {
  cat("GTstats: Proportion with confidence interval\n")
  cat("Data:", x$inputs$data_name, "\n")
  cat("Variable:", x$inputs$var, "\n")
  cat("Level:", x$inputs$level, "\n")

  if (!is.null(x$inputs$by)) {
    cat("Grouped by:", x$inputs$by, "\n")
  }

  cat("\n")
  print(x$table)

  cat("\n", x$notes, "\n", sep = "")
  cat("Object contains: $summary, $table, $inputs, $notes\n")
  cat("Use tbl_stats(x) for a formatted table.\n")

  invisible(x)
}

#' Print a gtstats rate object
#'
#' Print a compact console preview of a `gt_rate` object.
#'
#' The print method shows the dataset name, event variable, person-time
#' variable, optional grouping variable, and the display-ready rate
#' table.
#'
#' @param x A `gt_rate` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' df <- data.frame(
#'   event = c(1, 0, 1, 0, 1, 1),
#'   ptime = c(10, 12, 8, 9, 11, 7),
#'   arm = c("A", "A", "A", "B", "B", "B")
#' )
#' x <- rate_stats(df, event = event, time = ptime, by = arm)
#' print(x)
#'
#' @export
print.gt_rate <- function(x, ...) {
  cat("GTstats: Rate with confidence interval\n")
  cat("Data:", x$inputs$data_name, "\n")
  cat("Event:", x$inputs$event, "\n")
  cat("Person-time:", x$inputs$time, "\n")

  if (!is.null(x$inputs$by)) {
    cat("Grouped by:", x$inputs$by, "\n")
  }

  cat("\n")
  print(x$table)

  cat("\n", x$notes, "\n", sep = "")
  cat("Object contains: $summary, $table, $inputs, $notes\n")
  cat("Use tbl_stats(x) for a formatted table.\n")

  invisible(x)
}

#' Print a gtstats 2x2 table object
#'
#' Print a compact console preview of a `gt_twobytwo` object.
#'
#' The print method shows the dataset name, exposure definition,
#' outcome definition, and the display-ready 2x2 epidemiology table.
#'
#' @param x A `gt_twobytwo` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- twobytwo_table(mtcars, exposure = am, outcome = vs)
#' print(x)
#'
#' @export
print.gt_twobytwo <- function(x, ...) {
  cat("GTstats: 2x2 epidemiology table\n")
  cat("Data:", x$inputs$data_name, "\n")
  cat(
    "Exposure:",
    paste0(
      x$inputs$exposure,
      " (",
      x$inputs$exposed_level,
      ")"
    ),
    "\n"
  )
  cat(
    "Outcome:",
    paste0(
      x$inputs$outcome,
      " (",
      x$inputs$outcome_level,
      ")"
    ),
    "\n\n"
  )

  print(x$table)

  cat("\n", paste(x$notes, collapse = " "), "\n", sep = "")
  cat("Object contains: $summary, $table, $inputs, $notes\n")
  cat("Use tbl_stats(x) for a formatted table.\n")

  invisible(x)
}
