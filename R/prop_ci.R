#' Calculate proportion with confidence interval
#'
#' Calculate the proportion of a selected level of a binary,
#' categorical, or ordinal variable, with optional grouping and exact
#' binomial confidence intervals.
#'
#' This function is useful for simple epidemiological summaries and for
#' quickly reporting the proportion of a target category such as `"1"`,
#' `"Yes"`, or `"TRUE"`. If `level = NULL`, a default level is chosen
#' automatically using a simple priority rule.
#'
#' When a grouping variable is supplied, proportions are calculated
#' separately within each group. Confidence intervals are calculated
#' using [stats::binom.test()].
#'
#' @param data A data.frame.
#' @param var Variable to summarise as a proportion. Can be supplied as
#'   a bare name or as a character string.
#' @param by Optional grouping variable. Can be supplied as a bare name
#'   or as a character string.
#' @param level Optional level to count. If `NULL`, the function will
#'   try to use `"1"`, `"Yes"`, `"TRUE"`, or the second available
#'   level.
#' @param conf.level Confidence level for the interval. Default is
#'   `0.95`.
#' @param digits Number of decimal places used when formatting
#'   percentages.
#' @param output Output style. Currently stored in the returned object.
#' @param quiet Logical; suppress messages.
#'
#' @return A `gt_prop` object containing:
#' \itemize{
#'   \item `inputs` — function inputs and settings
#'   \item `summary` — detailed summary table
#'   \item `table` — display-ready table
#'   \item `notes` — explanatory note
#'   \item `call` — matched function call
#' }
#'
#' @examples
#' prop_ci(mtcars, var = vs)
#'
#' prop_ci(mtcars, var = vs, by = am)
#'
#' prop_ci(mtcars, var = vs, by = am, level = "1")
#'
#' tbl_stats(prop_ci(mtcars, var = vs, by = am))
#'
#' @export
prop_ci <- function(
    data,
    var,
    by = NULL,
    level = NULL,
    conf.level = 0.95,
    digits = 1,
    output = c("table", "tibble", "both"),
    quiet = FALSE
) {
  output <- match.arg(output)

  # Validate input data
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }

  # Resolve bare or character variable names
  resolve_name <- function(expr) {
    if (is.symbol(expr)) {
      deparse(expr)
    } else {
      expr_eval <- tryCatch(
        eval(expr, parent.frame()),
        error = function(e) NULL
      )

      if (is.character(expr_eval) && length(expr_eval) == 1) {
        expr_eval
      } else {
        deparse(expr)
      }
    }
  }

  var_expr <- substitute(var)
  by_expr <- substitute(by)

  var_name <- resolve_name(var_expr)

  if (identical(by_expr, NULL)) {
    by_name <- NULL
  } else {
    by_eval <- tryCatch(
      eval(by_expr, parent.frame()),
      error = function(e) NULL
    )

    if (is.character(by_eval) && length(by_eval) == 1) {
      by_name <- by_eval
    } else if (is.symbol(by_expr)) {
      by_name <- deparse(by_expr)
    } else {
      by_name <- deparse(by_expr)
    }
  }

  if (!var_name %in% names(data)) {
    stop("`var` was not found in `data`.", call. = FALSE)
  }

  if (!is.null(by_name) && !by_name %in% names(data)) {
    stop("`by` was not found in `data`.", call. = FALSE)
  }

  # Restrict analysis to variables where proportions are meaningful
  v <- data[[var_name]]
  v_type <- .detect_type(v)

  if (!v_type %in% c("binary", "categorical", "ordinal")) {
    stop(
      paste0(
        "`prop_ci()` currently supports binary, categorical, ",
        "or ordinal variables."
      ),
      call. = FALSE
    )
  }

  # Validate grouping variable when supplied
  if (!is.null(by_name)) {
    by_type <- .detect_type(data[[by_name]])

    if (by_type == "continuous") {
      stop(
        paste0(
          "`by` should be a categorical, binary, or ordinal ",
          "grouping variable."
        ),
        call. = FALSE
      )
    }
  }

  v_chr <- as.character(v)
  all_levels <- unique(stats::na.omit(v_chr))
  all_levels <- sort(all_levels)

  if (length(all_levels) == 0) {
    stop("`var` has no non-missing values.", call. = FALSE)
  }

  # Choose a sensible default level when one is not supplied
  if (is.null(level)) {
    preferred <- c("1", "Yes", "yes", "TRUE", "True", "true")
    hit <- preferred[preferred %in% all_levels]

    if (length(hit) > 0) {
      level <- hit[1]
    } else if (length(all_levels) == 2) {
      level <- all_levels[2]
    } else {
      level <- all_levels[1]
    }
  } else {
    level <- as.character(level)

    if (!level %in% all_levels) {
      stop(
        paste0(
          "`level` was not found in `",
          var_name,
          "`. Available levels: ",
          paste(all_levels, collapse = ", "),
          "."
        ),
        call. = FALSE
      )
    }
  }

  # Helper to format percentages consistently
  .fmt_pct <- function(p, digits = 1) {
    sprintf(paste0("%.", digits, "f"), p)
  }

  # Exact binomial confidence interval for a proportion
  .prop_ci_exact <- function(successes, total, conf.level = 0.95) {
    if (is.na(total) || total <= 0) {
      return(c(NA_real_, NA_real_))
    }

    bt <- stats::binom.test(
      successes,
      total,
      conf.level = conf.level
    )

    unname(bt$conf.int)
  }

  # Build one summary row for one group or for the overall sample
  .make_row <- function(
    group_label,
    x_chr,
    level,
    conf.level,
    digits
  ) {
    total <- sum(!is.na(x_chr))
    successes <- sum(x_chr == level, na.rm = TRUE)
    prop <- if (total > 0) {
      100 * successes / total
    } else {
      NA_real_
    }

    ci_vals <- .prop_ci_exact(
      successes,
      total,
      conf.level = conf.level
    )

    low <- 100 * ci_vals[1]
    high <- 100 * ci_vals[2]

    display <- if (is.na(prop)) {
      NA_character_
    } else {
      paste0(
        .fmt_pct(prop, digits), "% (",
        .fmt_pct(low, digits), "\u2013",
        .fmt_pct(high, digits), "%)"
      )
    }

    tibble::tibble(
      variable = var_name,
      label = .get_var_label(data, var_name),
      level = level,
      group = group_label,
      n = total,
      count = successes,
      proportion = prop,
      conf_low = low,
      conf_high = high,
      display = display
    )
  }

  # Build overall or grouped summary output
  if (is.null(by_name)) {
    summary_tbl <- .make_row(
      group_label = "Overall",
      x_chr = v_chr,
      level = level,
      conf.level = conf.level,
      digits = digits
    )

    table_tbl <- tibble::tibble(
      Variable = paste0(
        .get_var_label(data, var_name),
        " (",
        level,
        ")"
      ),
      n = summary_tbl$n,
      Count = summary_tbl$count,
      Proportion = summary_tbl$display
    )
  } else {
    by_var <- data[[by_name]]
    group_values <- unique(by_var)
    group_values <- group_values[!is.na(group_values)]
    group_values_chr <- as.character(group_values)

    summary_list <- lapply(group_values_chr, function(g) {
      idx <- !is.na(by_var) & as.character(by_var) == g

      .make_row(
        group_label = paste0(by_name, " = ", g),
        x_chr = v_chr[idx],
        level = level,
        conf.level = conf.level,
        digits = digits
      )
    })

    summary_tbl <- dplyr::bind_rows(summary_list)

    table_tbl <- summary_tbl[, c("group", "n", "count", "display")]
    names(table_tbl) <- c("Group", "n", "Count", "Proportion")
    table_tbl <- tibble::as_tibble(table_tbl)
  }

  result <- list(
    inputs = list(
      data_name = deparse(substitute(data)),
      var = var_name,
      by = by_name,
      level = level,
      conf.level = conf.level,
      digits = digits,
      output = output
    ),
    summary = summary_tbl,
    table = table_tbl,
    notes = paste0(
      "Proportions are shown as % with ",
      round(conf.level * 100),
      "% exact binomial confidence intervals."
    ),
    call = match.call()
  )

  class(result) <- "gt_prop"
  result
}
