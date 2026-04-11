#' Add total counts to a descriptive table
#'
#' Add a total row to a `gtstats` descriptive table showing the number of
#' observations overall or within each displayed group.
#'
#' This helper is useful in Table 1 workflows where a final row is needed to
#' show the number of observations contributing to each column. When the table
#' includes an `Overall` column, the total number of rows in the source data is
#' shown there. When the table is grouped, totals are calculated within each
#' displayed group.
#'
#' This helper can be used only with descriptive tables created in
#' `mode = "summary"`.
#'
#' @param x A `gt_desc_table` object created with [descriptive_table()].
#' @param label Row label to display in the `Variable` column. Defaults to
#'   `"Total (N)"`.
#'
#' @return An updated `gt_desc_table` object with a total row appended.
#'
#' @examples
#' descriptive_table(mtcars, by = am) |>
#'   add_summary(vars = c(mpg, wt, cyl)) |>
#'   add_total()
#'
#' descriptive_table(mtcars, by = am, overall = TRUE) |>
#'   add_summary(vars = c(mpg, wt)) |>
#'   add_total()
#'
#' descriptive_table(mtcars) |>
#'   add_total()
#'
#' @export
add_total <- function(
    x,
    label = "Total (N)"
) {
  # Validate table object and restrict use to summary-mode descriptive tables
  if (!inherits(x, "gt_desc_table")) {
    stop("`x` must be a `gt_desc_table` object.", call. = FALSE)
  }

  if (!identical(x$mode, "summary")) {
    stop(
      paste0(
        "`add_total()` can only be used with descriptive tables ",
        "created with `mode = \"summary\"`."
      ),
      call. = FALSE
    )
  }

  # Validate row label
  if (!is.character(label) || length(label) != 1) {
    stop("`label` must be a single character string.", call. = FALSE)
  }

  # Start the total row
  total_row <- tibble::tibble(
    Variable = label,
    Level = ""
  )

  # Add overall total if the descriptive table includes an Overall column
  if (isTRUE(x$overall)) {
    total_row$Overall <- as.character(nrow(x$data))
  }

  # Add group-specific totals when the table is grouped
  if (!is.null(x$by)) {
    group_values <- unique(x$data[[x$by]])
    group_values <- group_values[!is.na(group_values)]
    group_values_chr <- as.character(group_values)
    group_labels <- paste0(x$by, " = ", group_values_chr)
    names(group_labels) <- group_values_chr

    for (g in group_values_chr) {
      n_g <- sum(!is.na(x$data[[x$by]]) & as.character(x$data[[x$by]]) == g)
      total_row[[group_labels[[g]]]] <- as.character(n_g)
    }
  } else if (!isTRUE(x$overall)) {
    # Use a single Value column when neither grouping nor overall is used
    total_row$Value <- as.character(nrow(x$data))
  }

  total_row <- tibble::as_tibble(total_row)

  # Align the new row to the current table structure before appending
  if (is.null(x$table)) {
    x$table <- total_row
  } else {
    missing_cols <- setdiff(names(x$table), names(total_row))
    for (col in missing_cols) {
      total_row[[col]] <- ""
    }

    extra_cols <- setdiff(names(total_row), names(x$table))
    for (col in extra_cols) {
      x$table[[col]] <- ""
    }

    total_row <- total_row[, names(x$table), drop = FALSE]
    x$table <- dplyr::bind_rows(x$table, total_row)
  }

  # Record component type and explanatory footnote
  x$components <- unique(c(x$components, "total"))
  x$footnotes <- unique(c(
    x$footnotes,
    "Totals represent the number of observations in each displayed group."
  ))

  x
}
