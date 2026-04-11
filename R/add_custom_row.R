#' Add a custom row to a descriptive table
#'
#' Add a user-defined row to a `gtstats` descriptive table. This is useful for
#' inserting contextual information such as study period, data source, setting,
#' or other custom annotations that should appear alongside the main table
#' content.
#'
#' The row is matched to the current table structure automatically:
#' - if `overall = TRUE`, an `Overall` column is supported
#' - if `by` is used, values must be named using displayed group column names
#' - if neither `overall` nor `by` is used, a single `Value` column is used
#'
#' @param x A `gt_desc_table` object created with [descriptive_table()].
#' @param label A single character string giving the row label to display in the
#'   `Variable` column.
#' @param overall Optional value to display in the `Overall` column when the
#'   descriptive table includes `overall = TRUE`.
#' @param values Optional named character vector or named list giving values for
#'   displayed group columns. Names must match the displayed group column names,
#'   for example `c("am = 1" = "2020-2024", "am = 0" = "2020-2024")`.
#' @param level Optional text to display in the `Level` column. Defaults to an
#'   empty string.
#'
#' @return An updated `gt_desc_table` object with the custom row appended.
#'
#' @examples
#' res <- descriptive_table(mtcars, by = am, overall = TRUE) |>
#'   add_summary(vars = c(mpg, wt)) |>
#'   add_custom_row(
#'     label = "Study period",
#'     overall = "2020-2024",
#'     values = c("am = 1" = "2020-2024", "am = 0" = "2020-2024")
#'   )
#'
#' @export
add_custom_row <- function(
    x,
    label,
    overall = NULL,
    values = NULL,
    level = ""
) {
  if (!inherits(x, "gt_desc_table")) {
    stop("`x` must be a `gt_desc_table` object.", call. = FALSE)
  }

  if (!is.character(label) || length(label) != 1 || is.na(label)) {
    stop(
      "`label` must be a single non-missing character string.",
      call. = FALSE
    )
  }

  if (!is.character(level) || length(level) != 1 || is.na(level)) {
    stop(
      "`level` must be a single non-missing character string.",
      call. = FALSE
    )
  }

  # Build expected displayed columns from the current table structure
  expected_cols <- c("Variable", "Level")

  if (isTRUE(x$overall)) {
    expected_cols <- c(expected_cols, "Overall")
  }

  if (!is.null(x$by)) {
    group_values <- unique(x$data[[x$by]])
    group_values <- group_values[!is.na(group_values)]
    group_values_chr <- as.character(group_values)
    group_labels <- paste0(x$by, " = ", group_values_chr)
    expected_cols <- c(expected_cols, group_labels)
  } else if (!isTRUE(x$overall)) {
    expected_cols <- c(expected_cols, "Value")
  }

  row_tbl <- tibble::tibble(
    Variable = label,
    Level = level
  )

  if (isTRUE(x$overall)) {
    row_tbl$Overall <- if (is.null(overall)) "" else as.character(overall)
  }

  if (!is.null(x$by)) {
    if (is.null(values)) {
      values <- character()
    }

    if (is.list(values)) {
      values <- unlist(values, use.names = TRUE)
    }

    if (!is.character(values)) {
      stop(
        "`values` must be a named character vector or list.",
        call. = FALSE
      )
    }

    group_values <- unique(x$data[[x$by]])
    group_values <- group_values[!is.na(group_values)]
    group_values_chr <- as.character(group_values)
    group_labels <- paste0(x$by, " = ", group_values_chr)

    if (length(values) > 0 && is.null(names(values))) {
      stop(
        "`values` must be named using the displayed group column names.",
        call. = FALSE
      )
    }

    bad_names <- setdiff(names(values), group_labels)
    if (length(bad_names) > 0) {
      stop(
        paste0(
          "Unknown names in `values`: ",
          paste(bad_names, collapse = ", "),
          ". Expected names are: ",
          paste(group_labels, collapse = ", "),
          "."
        ),
        call. = FALSE
      )
    }

    for (g in group_labels) {
      row_tbl[[g]] <- if (g %in% names(values)) {
        as.character(values[[g]])
      } else {
        ""
      }
    }
  } else if (!isTRUE(x$overall)) {
    if (is.null(values)) {
      row_tbl$Value <- ""
    } else {
      if (is.list(values)) {
        values <- unlist(values, use.names = TRUE)
      }

      if (length(values) != 1) {
        stop(
          paste0(
            "Without `by` or `overall = TRUE`, `values` must contain ",
            "a single value."
          ),
          call. = FALSE
        )
      }

      row_tbl$Value <- as.character(values[[1]])
    }
  }

  row_tbl <- tibble::as_tibble(row_tbl)

  if (is.null(x$table)) {
    # Ensure full structure even when the table is empty
    for (col in setdiff(expected_cols, names(row_tbl))) {
      row_tbl[[col]] <- ""
    }

    row_tbl <- row_tbl[, expected_cols, drop = FALSE]
    x$table <- row_tbl
  } else {
    missing_cols <- setdiff(names(x$table), names(row_tbl))
    for (col in missing_cols) {
      row_tbl[[col]] <- ""
    }

    extra_cols <- setdiff(names(row_tbl), names(x$table))
    for (col in extra_cols) {
      x$table[[col]] <- ""
    }

    row_tbl <- row_tbl[, names(x$table), drop = FALSE]
    x$table <- dplyr::bind_rows(x$table, row_tbl)
  }

  x$components <- unique(c(x$components, "custom_row"))

  x
}
