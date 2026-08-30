#' Convert an already summarised data frame into a publication table
#'
#' Wrap a data frame or tibble containing values that have already been
#' calculated so it can be rendered, styled, and exported with gtstats. No
#' descriptive statistics, confidence intervals, or p-values are calculated or
#' checked by this function.
#'
#' Use [summary_table()] instead when each row represents a participant or
#' observation and descriptive statistics still need to be calculated. Use
#' [epi_table()] when events and denominators need to be calculated from a line
#' list or aggregate outbreak/surveillance data.
#'
#' @param data A data frame or tibble containing one row per intended table row.
#' @param notes Optional character vector of explanatory notes to display below
#'   the table.
#'
#' @return A `gt_data_table` object. Use [customise_table()], [to_flextable()],
#'   [to_gt()], or [save_output()] to present or export it.
#'
#' @examples
#' summarised <- mtcars |>
#'   dplyr::summarise(
#'     Cars = dplyr::n(),
#'     `Mean mpg` = mean(mpg),
#'     `Mean weight` = mean(wt)
#'   )
#'
#' table <- as_stats_table(
#'   summarised,
#'   notes = "Values were calculated before table formatting."
#' )
#' customise_table(table, title = "Vehicle summary")
#' to_flextable(table)
#' to_gt(table)
#'
#' @export
as_stats_table <- function(data, notes = NULL) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame or tibble.", call. = FALSE)
  }
  if (!ncol(data)) {
    stop("`data` must contain at least one column.", call. = FALSE)
  }
  if (!nrow(data)) {
    stop("`data` must contain at least one row to display.", call. = FALSE)
  }
  if (anyNA(names(data)) || any(!nzchar(names(data))) || anyDuplicated(names(data))) {
    stop("Every column in `data` must have a unique, non-empty name.", call. = FALSE)
  }
  supported <- vapply(data, function(column) {
    is.atomic(column) || is.factor(column) ||
      inherits(column, c("Date", "POSIXct", "POSIXlt"))
  }, logical(1))
  if (any(!supported)) {
    stop(
      "All columns must be ordinary atomic vectors; list or nested columns are not supported.",
      call. = FALSE
    )
  }
  if (!is.null(notes) && (!is.character(notes) || anyNA(notes))) {
    stop("`notes` must be NULL or a character vector without missing values.", call. = FALSE)
  }
  notes <- unique(trimws(notes %||% character()))
  notes <- notes[nzchar(notes)]
  table <- tibble::as_tibble(data, .name_repair = "check_unique")
  result <- list(
    inputs = list(data_name = deparse(substitute(data))),
    summary = table,
    table = table,
    notes = notes,
    call = match.call()
  )
  class(result) <- c("gt_data_table", "gtstats", "list")
  result
}

#' Print an already summarised gtstats table
#'
#' @param x A `gt_data_table` object.
#' @param ... Further arguments passed to [to_flextable()].
#'
#' @return The input object, invisibly.
#' @export
print.gt_data_table <- function(x, ...) {
  print(to_flextable(x, ...))
  invisible(x)
}
