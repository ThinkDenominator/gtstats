#' Create a summary table builder
#'
#' Create a publication-ready summary table, or initialise one that can be built
#' step by step using helper functions such as [add_summary()],
#' [add_proportion()], [add_rate()], [add_total()], and [add_p()].
#'
#' For the usual Table 1 workflow, select all variables together with
#' `include`. Continuous, binary, categorical, and ordinal variables are
#' detected automatically and added using beginner-friendly defaults. There is
#' no need to add continuous and categorical variables separately.
#'
#' When `include = NULL`, an empty builder is returned for advanced incremental
#' workflows using [add_summary()] and the other `add_*()` helpers. Printing a
#' completed object automatically displays a publication-ready `gt` table;
#' call [tbl_stats()] only when explicit rendering control is required.
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
#' @param include Optional variables to summarise immediately. Supply bare
#'   names, such as `c(age, sex, bmi)`, or a character vector. Mixed variable
#'   types can be selected together. When omitted, an empty advanced builder is
#'   returned.
#' @param mode Table mode. One of `"summary"` or `"rate"`.
#' @param overall Overall-column setting. Use `FALSE` to omit it, `"first"` to
#'   place it before the grouped columns, or `"last"` to place it after them.
#'   `TRUE` is accepted as a shorthand for `"first"`.
#' @param statistic Continuous summary format: `"recommended"`, `"mean_sd"`,
#'   `"mean_ci"`, `"median_iqr"`, or `"both"`. A single value applies to all
#'   continuous variables; a named vector can override individual variables.
#' @param categorical Categorical display: `"n_percent"`,
#'   `"n_over_N_percent"`, `"n"`, or `"percent"`.
#' @param percent Percentage denominator: `"column"`, `"row"`, or `"overall"`.
#' @param digits One number applied throughout, or a named numeric vector using
#'   `continuous`, `percent`, and `ci`.
#' @param missing Missing-row display: `"ifany"`, `"always"`, or `"no"`.
#' @param ci Logical; include confidence intervals for categorical proportions.
#' @param conf.level Confidence level for categorical proportion intervals.
#' @param ci_method Binomial confidence-interval method: `"wilson"` (default)
#'   or `"exact"`.
#' @param layout Table layout. `"compact"` keeps each summary in one cell.
#'   `"separate"` places summaries and confidence intervals in separate
#'   columns beneath each cohort header.
#' @param label Optional named character vector overriding variable labels.
#' @param format Display format: `"table"` (default) or `"tibble"`. The
#'   builder remains composable; this option changes how the completed object
#'   prints without discarding its audit components.
#'
#' @return A `gt_desc_table` object containing the source data,
#'   structural settings, and placeholders for table components.
#'
#' @examples
#' summary_table(
#'   mtcars,
#'   by = am,
#'   include = c(mpg, wt, cyl, vs),
#'   overall = TRUE
#' )
#'
#' summary_table(
#'   mtcars,
#'   by = am,
#'   include = c(mpg, wt, cyl, vs),
#'   overall = TRUE
#' ) |>
#'   add_p()
#'
#' # Percentages without decimals and Overall displayed last
#' summary_table(
#'   mtcars,
#'   by = am,
#'   include = c(mpg, wt, cyl, vs),
#'   overall = "last",
#'   digits = c(continuous = 1, percent = 0)
#' )
#'
#' # Ungrouped descriptive proportions with confidence intervals
#' summary_table(
#'   mtcars,
#'   include = c(cyl, vs),
#'   categorical = "percent",
#'   ci = TRUE
#' )
#'
#' # Advanced incremental construction
#' summary_table(mtcars, by = am, overall = TRUE) |>
#'   add_summary(
#'     vars = c(mpg, wt),
#'     statistic = c(mpg = "mean_sd", wt = "median_iqr")
#'   )
#'
#' @export
summary_table <- function(
    data,
    by = NULL,
    include = NULL,
    mode = c("summary", "rate"),
    overall = FALSE,
    statistic = "recommended",
    categorical = c("n_percent", "n_over_N_percent", "n", "percent"),
    percent = c("column", "row", "overall"),
    digits = 1,
    missing = c("ifany", "always", "no"),
    ci = FALSE,
    conf.level = 0.95,
    ci_method = c("wilson", "exact"),
    layout = c("compact", "separate"),
    label = NULL,
    format = c("table", "tibble")
) {
  format <- match.arg(format)
  mode <- match.arg(mode)
  categorical <- match.arg(categorical)
  percent <- match.arg(percent)
  missing <- match.arg(missing)
  ci_method <- match.arg(ci_method)
  layout <- match.arg(layout)
  if (is.logical(overall) && length(overall) == 1L && !is.na(overall)) {
    overall_position <- "first"
    overall_requested <- isTRUE(overall)
  } else if (is.character(overall) && length(overall) == 1L &&
             !is.na(overall) && overall %in% c("first", "last")) {
    overall_position <- overall
    overall_requested <- TRUE
  } else {
    stop(
      "`overall` must be FALSE, TRUE, \"first\", or \"last\".",
      call. = FALSE
    )
  }
  .validate_flag(ci, "ci")
  .validate_conf_level(conf.level)
  .resolve_summary_digits(digits)
  if (isTRUE(ci) && identical(categorical, "n")) {
    stop(
      "`ci = TRUE` requires a percentage-based `categorical` display.",
      call. = FALSE
    )
  }

  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }

  by <- .resolve_var_arg(
    substitute(by),
    env = parent.frame(),
    allow_null = TRUE
  )

  include_expr <- substitute(include)
  include_names <- if (identical(include_expr, NULL)) {
    NULL
  } else {
    .resolve_vars_arg(include_expr, env = parent.frame())
  }

  if (!is.null(label)) {
    if (!is.character(label) || is.null(names(label)) ||
        any(!nzchar(names(label))) || anyNA(label)) {
      stop(
        "`label` must be a named character vector.",
        call. = FALSE
      )
    }
    unknown_labels <- setdiff(names(label), names(data))
    if (length(unknown_labels) > 0L) {
      stop(
        "Label variables not found in `data`: ",
        paste(unknown_labels, collapse = ", "),
        ".",
        call. = FALSE
      )
    }
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

  # Initialise an empty summary table builder
  result <- list(
    data = data,
    data_name = deparse(substitute(data)),
    by = by,
    mode = mode,
    overall = overall_requested,
    overall_position = overall_position,
    layout = layout,
    format = format,
    display_columns = NULL,
    table = NULL,
    components = character(),
    footnotes = character(),
    methods_used = character(),
    pvalue_method_footnotes = character(),
    method = list(
      builder_mode = mode,
      percentage_denominator = NULL,
      missing_rows = NULL,
      p_adjust = NULL
    ),
    assumptions = .empty_assumptions(),
    diagnostics = .empty_diagnostics(),
    denominators = .empty_denominators(),
    call = match.call()
  )

  class(result) <- c("gt_desc_table", "gtstats", "list")

  if (!is.null(label)) {
    for (variable in names(label)) {
      attr(result$data[[variable]], "label") <- unname(label[[variable]])
    }
  }

  if (!is.null(include_names)) {
    if (!identical(mode, "summary")) {
      stop(
        "`include` is available only when `mode = \"summary\"`.",
        call. = FALSE
      )
    }
    include_names <- setdiff(include_names, by %||% character())
    if (length(include_names) == 0L) {
      stop(
        "`include` must select at least one variable other than `by`.",
        call. = FALSE
      )
    }
    result <- add_summary(
      result,
      vars = include_names,
      statistic = statistic,
      categorical = categorical,
      percent = percent,
      digits = digits,
      missing = missing,
      ci = ci,
      conf.level = conf.level,
      ci_method = ci_method,
      layout = layout
    )
  }

  result
}
