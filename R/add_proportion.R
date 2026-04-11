#' Add a proportion row to a descriptive table
#'
#' Add a row showing the proportion of a selected level of a binary,
#' categorical, or ordinal variable within a `gtstats` descriptive table.
#'
#' This is useful when you want to highlight a specific category such as
#' `"Yes"`, `"1"`, or `"TRUE"` within a Table 1 workflow. The row can be added
#' overall, by groups, or both, depending on how the descriptive table was
#' created.
#'
#' If `level = NULL`, the function chooses a default level using the following
#' order:
#' - `"1"`
#' - `"Yes"` / `"yes"`
#' - `"TRUE"` / `"True"` / `"true"`
#' - the second available level for binary variables
#' - otherwise the first available non-missing level
#'
#' Confidence intervals are calculated using an exact binomial method via
#' [stats::binom.test()].
#'
#' @param x A `gt_desc_table` object created with [descriptive_table()].
#' @param var Variable to summarise as a proportion. Can be supplied as a bare
#'   name or as a character string.
#' @param level Optional level to count. If `NULL`, a default level is selected
#'   automatically.
#' @param ci Logical; whether to display a confidence interval.
#' @param conf.level Confidence level for the interval. Default is `0.95`.
#' @param digits Number of decimal places used when formatting percentages.
#' @param label Optional row label. Defaults to the variable label if available,
#'   otherwise the variable name.
#'
#' @return An updated `gt_desc_table` object with a proportion row appended.
#'
#' @examples
#' descriptive_table(mtcars, by = am, overall = TRUE) |>
#'   add_proportion(var = vs)
#'
#' descriptive_table(mtcars, by = am, overall = TRUE) |>
#'   add_proportion(var = vs, level = "1", ci = TRUE)
#'
#' descriptive_table(mtcars) |>
#'   add_proportion(var = vs, ci = FALSE)
#'
#' @export
add_proportion <- function(
    x,
    var,
    level = NULL,
    ci = TRUE,
    conf.level = 0.95,
    digits = 1,
    label = NULL
) {
  # Validate table object and ensure this helper is used only in summary mode
  if (!inherits(x, "gt_desc_table")) {
    stop("`x` must be a `gt_desc_table` object.", call. = FALSE)
  }

  if (!identical(x$mode, "summary")) {
    stop(
      paste0(
        "`add_proportion()` can only be used with descriptive tables ",
        "created with `mode = \"summary\"`."
      ),
      call. = FALSE
    )
  }

  # Resolve variable name from either bare input or character input
  var_expr <- substitute(var)
  var_name <- if (is.symbol(var_expr)) {
    deparse(var_expr)
  } else {
    var_eval <- tryCatch(eval(var_expr, parent.frame()),
                         error = function(e) NULL)
    if (is.character(var_eval) && length(var_eval) == 1) {
      var_eval
    } else {
      deparse(var_expr)
    }
  }

  if (!var_name %in% names(x$data)) {
    stop("`var` was not found in the data.", call. = FALSE)
  }

  # Restrict this helper to variables where proportions are meaningful
  v <- x$data[[var_name]]
  v_type <- .detect_type(v)

  if (!v_type %in% c("binary", "categorical", "ordinal")) {
    stop(
      paste0(
        "`add_proportion()` currently supports binary, categorical, ",
        "or ordinal variables."
      ),
      call. = FALSE
    )
  }

  v_chr <- as.character(v)
  all_levels <- unique(stats::na.omit(v_chr))
  all_levels <- sort(all_levels)

  if (length(all_levels) == 0) {
    stop("`var` has no non-missing values.", call. = FALSE)
  }

  # Choose a sensible default level when one is not supplied explicitly
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

  # Use variable label if present; otherwise fall back to variable name
  if (is.null(label)) {
    label <- .get_var_label(x$data, var_name)
  }

  # Helper to format percentages consistently
  .fmt_pct <- function(p, digits = 1) {
    sprintf(paste0("%.", digits, "f"), p)
  }

  # Exact binomial confidence interval for a proportion
  .prop_ci <- function(successes, total, conf.level = 0.95) {
    if (is.na(total) || total <= 0) {
      return(c(NA_real_, NA_real_))
    }

    bt <- stats::binom.test(successes, total, conf.level = conf.level)
    unname(bt$conf.int)
  }

  # Build the final display string for one cell
  .make_display <- function(successes, total,
                            ci = TRUE,
                            conf.level = 0.95,
                            digits = 1) {
    if (is.na(total) || total <= 0) {
      return(NA_character_)
    }

    prop <- 100 * successes / total

    if (!ci) {
      return(paste0(.fmt_pct(prop, digits), "%"))
    }

    ci_vals <- .prop_ci(successes, total, conf.level)
    low <- 100 * ci_vals[1]
    high <- 100 * ci_vals[2]

    paste0(
      .fmt_pct(prop, digits), "% (",
      .fmt_pct(low, digits), "\u2013",
      .fmt_pct(high, digits), "%)"
    )
  }

  # Start the new row with the selected label and level in the Variable column
  row_tbl <- tibble::tibble(
    Variable = paste0(label, " (", level, ")"),
    Level = ""
  )

  # Add overall proportion if the descriptive table includes an Overall column
  if (isTRUE(x$overall)) {
    total_all <- sum(!is.na(v_chr))
    succ_all <- sum(v_chr == level, na.rm = TRUE)

    row_tbl$Overall <- .make_display(
      successes = succ_all,
      total = total_all,
      ci = ci,
      conf.level = conf.level,
      digits = digits
    )
  }

  # Add group-specific proportions if the descriptive table is grouped
  if (!is.null(x$by)) {
    by_var <- x$data[[x$by]]
    group_values <- unique(by_var)
    group_values <- group_values[!is.na(group_values)]
    group_values_chr <- as.character(group_values)
    group_labels <- paste0(x$by, " = ", group_values_chr)
    names(group_labels) <- group_values_chr

    for (g in group_values_chr) {
      idx <- !is.na(by_var) & as.character(by_var) == g
      vg <- v_chr[idx]

      total_g <- sum(!is.na(vg))
      succ_g <- sum(vg == level, na.rm = TRUE)

      row_tbl[[group_labels[[g]]]] <- .make_display(
        successes = succ_g,
        total = total_g,
        ci = ci,
        conf.level = conf.level,
        digits = digits
      )
    }
  } else if (!isTRUE(x$overall)) {
    # Use a single Value column when neither grouping nor overall is used
    total_all <- sum(!is.na(v_chr))
    succ_all <- sum(v_chr == level, na.rm = TRUE)

    row_tbl$Value <- .make_display(
      successes = succ_all,
      total = total_all,
      ci = ci,
      conf.level = conf.level,
      digits = digits
    )
  }

  row_tbl <- tibble::as_tibble(row_tbl)

  # Align the new row to the current table structure before appending
  if (is.null(x$table)) {
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

  # Record component type and explanatory footnote
  x$components <- unique(c(x$components, "proportion"))

  footnote_text <- if (ci) {
    paste0(
      "Proportions are shown as % (",
      round(conf.level * 100),
      "% CI)."
    )
  } else {
    "Proportions are shown as %."
  }

  x$footnotes <- unique(c(x$footnotes, footnote_text))

  x
}
