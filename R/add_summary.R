#' Add summary rows to a descriptive table
#'
#' Add summary statistics from [summary_stats()] to a `gtstats` descriptive
#' table builder.
#'
#' This function is the main way to populate a descriptive table with variable
#' summaries. It supports both grouped and ungrouped tables and can optionally
#' add an `Overall` column when the descriptive table was created with
#' `overall = TRUE`.
#'
#' Continuous variables can be displayed in one of four formats:
#' - `"recommended"`: mean (SD) or median (IQR) as appropriate
#' - `"mean_sd"`: mean (SD)
#' - `"median_iqr"`: median (IQR)
#' - `"both"`: mean (SD) and median (IQR)
#'
#' Variable names may be supplied either as bare names, for example
#' `c(age, sex, bmi)`, or as a character vector, for example
#' `c("age", "sex", "bmi")`.
#'
#' @param x A `gt_desc_table` object created with [descriptive_table()].
#' @param vars Variables to summarise. Can be supplied as bare names or as a
#'   character vector.
#' @param continuous_format Format to use for continuous variables. One of
#'   `"recommended"`, `"mean_sd"`, `"median_iqr"`, or `"both"`.
#' @param digits Number of decimal places used when formatting summaries.
#'
#' @return An updated `gt_desc_table` object with summary rows added.
#'
#' @examples
#' descriptive_table(mtcars, by = am) |>
#'   add_summary(vars = c(mpg, wt, cyl))
#'
#' descriptive_table(mtcars, by = am, overall = TRUE) |>
#'   add_summary(vars = c("mpg", "wt", "cyl"))
#'
#' descriptive_table(mtcars) |>
#'   add_summary(vars = c(mpg, wt), continuous_format = "mean_sd")
#'
#' @export
add_summary <- function(
    x,
    vars,
    continuous_format = c("recommended", "mean_sd", "median_iqr", "both"),
    digits = 1
) {
  continuous_format <- match.arg(continuous_format)

  # Validate object type and ensure this helper is used only in summary mode
  if (!inherits(x, "gt_desc_table")) {
    stop("`x` must be a `gt_desc_table` object.", call. = FALSE)
  }

  if (!identical(x$mode, "summary")) {
    stop(
      paste0(
        "`add_summary()` can only be used with descriptive tables ",
        "created with `mode = \"summary\"`."
      ),
      call. = FALSE
    )
  }

  # Resolve variables from either bare names or character input
  vars_expr <- substitute(vars)

  vars_names <- if (is.symbol(vars_expr)) {
    deparse(vars_expr)

  } else if (is.call(vars_expr) && identical(vars_expr[[1]], as.name("c"))) {
    # Try evaluating first: this works for c("mpg", "wt", "cyl")
    vars_eval <- tryCatch(eval(vars_expr, parent.frame()),
                          error = function(e) NULL)

    if (is.character(vars_eval)) {
      vars_eval
    } else {
      # Fall back to deparsing symbols: this works for c(mpg, wt, cyl)
      vapply(as.list(vars_expr)[-1], deparse, character(1))
    }

  } else {
    vars_eval <- tryCatch(eval(vars_expr, parent.frame()),
                          error = function(e) NULL)

    if (is.character(vars_eval)) {
      vars_eval
    } else {
      stop(
        paste0(
          "`vars` should be supplied as bare names, e.g. c(age, sex), ",
          "or as a character vector."
        ),
        call. = FALSE
      )
    }
  }

  vars_names <- as.character(vars_names)

  # Build grouped or ungrouped summary table depending on whether `by` is used
  res <- if (is.null(x$by)) {
    summary_stats(
      data = x$data,
      vars = vars_names,
      continuous_format = continuous_format,
      digits = digits
    )
  } else {
    summary_stats(
      data = x$data,
      vars = vars_names,
      by = x$by,
      continuous_format = continuous_format,
      digits = digits
    )
  }

  tbl <- res$table
  tbl <- tbl[, setdiff(names(tbl), c("Type", "Missing")), drop = FALSE]
  tbl <- tibble::as_tibble(tbl)

  # Rename Summary to Value when there is no grouping and no overall column
  if (is.null(x$by) && !isTRUE(x$overall) && "Summary" %in% names(tbl)) {
    names(tbl)[names(tbl) == "Summary"] <- "Value"
  }

  # If overall summaries are requested, calculate them separately and merge
  if (isTRUE(x$overall)) {
    overall_res <- summary_stats(
      data = x$data,
      vars = vars_names,
      continuous_format = continuous_format,
      digits = digits
    )

    overall_tbl <- overall_res$table

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

      # Keep a consistent display order with Overall shown first
      preferred_order <- c(
        "Variable", "Level", "Overall",
        setdiff(names(tbl), c("Variable", "Level", "Overall"))
      )

      tbl <- tbl[, preferred_order[preferred_order %in% names(tbl)],
                 drop = FALSE]
      tbl <- tibble::as_tibble(tbl)
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

    new_cols <- setdiff(names(tbl), names(x$table))

    if (length(new_cols) == 0) {
      stop(
        paste0(
          "No new columns were added. Summary rows may already exist ",
          "or table structure is incompatible."
        ),
        call. = FALSE
      )
    }

    x$table <- dplyr::full_join(x$table, tbl, by = c("Variable", "Level"))
  }

  # Record component type
  x$components <- unique(c(x$components, "summary"))

  # Add explanatory footnote describing how values are displayed
  has_by <- !is.null(x$by)

  footnote_text <- if (continuous_format == "mean_sd") {
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
  } else if (continuous_format == "median_iqr") {
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
  } else if (continuous_format == "recommended") {
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
  } else {
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
  }

  x$footnotes <- unique(c(x$footnotes, footnote_text))

  x
}
