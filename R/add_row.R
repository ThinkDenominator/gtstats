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
#' @param x A `gtstats_summary` object created with [summary_table()].
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
#' @return An updated `gtstats_summary` object with the custom row appended.
#'
#' @examples
#' res <- summary_table(mtcars, by = am, include = c(mpg, wt), overall = TRUE) |>
#'   add_row(
#'     label = "Study period",
#'     overall = "2020-2024",
#'     values = c("am = 1" = "2020-2024", "am = 0" = "2020-2024")
#'   )
#'
#' @export
add_row <- function(
    x,
    label,
    overall = NULL,
    values = NULL,
    level = ""
) {
  .validate_summary_builder(x, "add_row")

  if (!is.character(label) || length(label) != 1 || is.na(label) ||
      !nzchar(label)) {
    stop(
      "`label` must be a single non-empty character string.",
      call. = FALSE
    )
  }

  if (!is.character(level) || length(level) != 1 || is.na(level)) {
    stop(
      "`level` must be a single non-missing character string.",
      call. = FALSE
    )
  }

  if (!is.null(overall) &&
      (!is.character(overall) || length(overall) != 1L || is.na(overall))) {
    stop("`overall` must be NULL or a single non-missing character string.",
         call. = FALSE)
  }
  if (!isTRUE(x$overall) && !is.null(overall)) {
    stop(
      "`overall` can be supplied only when `summary_table(..., overall = TRUE)` was used.",
      call. = FALSE
    )
  }
  if (isTRUE(x$overall) && is.null(x$by) && !is.null(values)) {
    stop(
      "Use `overall` rather than `values` when the table has only an Overall column.",
      call. = FALSE
    )
  }

  # Build expected displayed columns from the current table structure
  expected_cols <- c("Variable", "Level")

  if (isTRUE(x$overall)) {
    expected_cols <- c(expected_cols, "Overall")
  }

  if (!is.null(x$by)) {
    group_labels <- unname(.builder_group_columns(x))
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

    if (anyNA(values) || any(!nzchar(values))) {
      stop("`values` must not contain missing or empty entries.", call. = FALSE)
    }

    group_labels <- unname(.builder_group_columns(x))

    if (length(values) > 0 && is.null(names(values))) {
      stop(
        "`values` must be named using the displayed group column names.",
        call. = FALSE
      )
    }
    if (length(values) > 0 &&
        (anyNA(names(values)) || any(!nzchar(names(values))) ||
          anyDuplicated(names(values)))) {
      stop(
        "`values` names must be unique, non-empty displayed group column names.",
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

      if (is.na(values[[1L]]) || !nzchar(as.character(values[[1L]]))) {
        stop("`values` must contain one non-empty, non-missing value.",
             call. = FALSE)
      }

      row_tbl$Value <- as.character(values[[1]])
    }
  }

  row_tbl <- tibble::as_tibble(row_tbl)
  if (identical(x$layout %||% "compact", "separate") &&
      !is.null(x$display_columns)) {
    x <- .builder_use_separate_layout(x, conf.level = x$conf.level %||% 0.95)
    compact_row <- row_tbl
    row_tbl <- compact_row[, intersect(c("Variable", "Level"), names(compact_row)), drop = FALSE]
    for (source in intersect(
      .builder_base_display_columns(x), names(compact_row)
    )) {
      row_tbl <- .builder_set_separate_cell(
        row_tbl, x, source, compact_row[[source]][[1L]]
      )
    }
  } else {
    row_tbl <- .builder_order_display_columns(x, row_tbl)
  }

  if (is.null(x$table)) {
    # Ensure full structure even when the table is empty
    for (col in setdiff(expected_cols, names(row_tbl))) {
      row_tbl[[col]] <- ""
    }

    if (identical(x$overall_position, "last") &&
        "Overall" %in% expected_cols) {
      expected_cols <- c(
        setdiff(expected_cols, "Overall"),
        "Overall"
      )
    }
    row_tbl <- row_tbl[, expected_cols, drop = FALSE]
    x$table <- row_tbl
  } else {
    x <- .append_builder_rows(x, row_tbl)
  }

  x$components <- unique(c(x$components, "custom_row"))

  x
}
