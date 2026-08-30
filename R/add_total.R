#' Add total counts to a descriptive table
#'
#' Add a total row to a `gtstats` descriptive table showing the number of
#' observations overall or within each displayed group.
#'
#' This helper is useful in Table 1 workflows where a final row is needed to
#' show the number of observations contributing to each column. When the table
#' includes an `Overall` column, the total number of rows in the source data is
#' shown there. When the table is grouped, totals are calculated within each
#' displayed group. Publication-table headers already display these cohort
#' denominators automatically, so this row is optional.
#'
#' This helper can be used only with descriptive tables created in
#' `mode = "summary"`.
#'
#' @param x A `gtstats_summary` object created with [summary_table()].
#' @param label Row label to display in the `Variable` column. Defaults to
#'   `"Total (N)"`.
#' @param position Position of the total row. Use `"first"` to place sample
#'   sizes at the top of the table or `"last"` to append them.
#'
#' @return An updated `gtstats_summary` object with a total row appended.
#'
#' @examples
#' summary_table(mtcars, by = am, include = c(mpg, wt, cyl)) |>
#'   add_total()
#'
#' summary_table(mtcars, by = am, include = c(mpg, wt), overall = TRUE) |>
#'   add_total()
#'
#' summary_table(mtcars) |>
#'   add_total()
#'
#' @export
add_total <- function(
    x,
    label = "Total (N)",
    position = c("last", "first")
) {
  position <- match.arg(position)
  .validate_summary_builder(x, "add_total")

  # Validate row label
  if (!is.character(label) || length(label) != 1L || is.na(label) ||
      !nzchar(label)) {
    stop("`label` must be a single non-empty character string.", call. = FALSE)
  }
  if ("total" %in% (x$components %||% character())) {
    stop("A total row has already been added to this table.", call. = FALSE)
  }

  # Start the total row
  total_row <- tibble::tibble(
    Variable = label,
    Level = ""
  )
  separate <- identical(x$layout %||% "compact", "separate") &&
    !is.null(x$display_columns)
  if (separate) {
    x <- .builder_use_separate_layout(x, conf.level = x$conf.level %||% 0.95)
  }

  # Add overall total if the descriptive table includes an Overall column
  if (isTRUE(x$overall)) {
    if (separate) {
      total_row <- .builder_set_separate_cell(
        total_row, x, "Overall", as.character(nrow(x$data))
      )
    } else {
      total_row$Overall <- as.character(nrow(x$data))
    }
  }

  # Add group-specific totals when the table is grouped
  if (!is.null(x$by)) {
    group_values_chr <- .builder_group_values(x)
    group_labels <- .builder_group_columns(x)

    for (i in seq_along(group_values_chr)) {
      g <- group_values_chr[[i]]
      n_g <- sum(!is.na(x$data[[x$by]]) & as.character(x$data[[x$by]]) == g)
      if (separate) {
        total_row <- .builder_set_separate_cell(
          total_row, x, unname(group_labels[[i]]), as.character(n_g)
        )
      } else {
        total_row[[group_labels[[i]]]] <- as.character(n_g)
      }
    }
  } else if (!isTRUE(x$overall)) {
    # Use a single Value column when neither grouping nor overall is used
    if (separate) {
      total_row <- .builder_set_separate_cell(
        total_row, x, "Value", as.character(nrow(x$data))
      )
    } else {
      total_row$Value <- as.character(nrow(x$data))
    }
  }

  total_row <- tibble::as_tibble(total_row)
  total_row <- .builder_order_display_columns(x, total_row)

  x <- .append_builder_rows(x, total_row, position = position)

  # Record component type and explanatory footnote
  x$components <- unique(c(x$components, "total"))
  x$footnotes <- unique(c(
    x$footnotes,
    "Totals represent the number of observations in each displayed group."
  ))

  x
}
