#' Create a descriptive table builder
#'
#' Initialise a `gtstats` descriptive table object that can be built
#' step by step using helper functions such as [add_summary()],
#' [add_proportion()], [add_rate()], [add_total()], and [add_p()].
#'
#' This function creates the table builder object but does not yet add
#' any rows. Rows are appended later through the `add_*()` helpers,
#' and the finished object can be rendered with [tbl_stats()].
#'
#' Two modes are supported:
#' - `"summary"` for baseline tables and descriptive summaries
#' - `"rate"` for rate-based tables using [add_rate()]
#'
#' A grouping variable may be supplied to create one column per group.
#' An optional `overall` column can also be requested for later use.
#'
#' @param data A data.frame.
#' @param by Optional grouping variable. Can be supplied as a bare name
#'   or as a character string. The grouping variable must be
#'   categorical, binary, or ordinal.
#' @param mode Table mode. One of `"summary"` or `"rate"`.
#' @param overall Logical; whether an overall column should be included
#'   later when supported by downstream helpers.
#'
#' @return A `gt_desc_table` object containing the source data,
#'   structural settings, and placeholders for table components.
#'
#' @examples
#' descriptive_table(mtcars)
#'
#' descriptive_table(mtcars, by = am)
#'
#' descriptive_table(mtcars, by = am, overall = TRUE)
#'
#' descriptive_table(mtcars, mode = "rate")
#'
#' @export
descriptive_table <- function(
    data,
    by = NULL,
    mode = c("summary", "rate"),
    overall = FALSE
) {
  mode <- match.arg(mode)

  # Validate input data
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }

  # Resolve grouping variable from bare or character input
  by_expr <- substitute(by)

  if (identical(by_expr, NULL)) {
    by <- NULL
  } else if (is.character(by_expr)) {
    by <- by_expr[1]
  } else {
    by <- deparse(by_expr)
  }

  # Validate grouping variable when supplied
  if (!is.null(by)) {
    if (!by %in% names(data)) {
      stop("`by` was not found in `data`.", call. = FALSE)
    }

    by_type <- .detect_type(data[[by]])
    if (by_type == "continuous") {
      stop(
        "`by` should be a categorical, binary, or ordinal grouping variable.",
        call. = FALSE
      )
    }
  }

  # Initialise an empty descriptive table builder
  result <- list(
    data = data,
    by = by,
    mode = mode,
    overall = overall,
    table = NULL,
    components = character(),
    footnotes = character(),
    methods_used = character(),
    pvalue_method_footnotes = character(),
    call = match.call()
  )

  class(result) <- "gt_desc_table"
  result
}
