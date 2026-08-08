#' Add p-values to a descriptive table
#'
#' Add a p-value column to a descriptive table by comparing each displayed
#' variable across the grouping variable. P-values are calculated using
#' [compare_groups()] and inserted once per variable, with optional superscript
#' markers indicating which statistical test was used.
#'
#' This function works only for descriptive tables created in `mode = "summary"`
#' and requires a grouping variable supplied via [summary_table()].
#'
#' Supported methods include:
#' - `"auto"`
#' - `"welch_t"`
#' - `"t_test"`
#' - `"wilcox"`
#' - `"anova"`
#' - `"welch_anova"`
#' - `"kruskal"`
#' - `"chisq"`
#' - `"fisher"`
#' - `"mcnemar"`
#'
#' You may also provide a named character vector or named list to specify
#' different methods for individual variables.
#'
#' ## Automatic selection and audit trail
#'
#' With `method = "auto"`, `add_p()` delegates each comparison to
#' [compare_groups()] using the same fixed selection policy: Welch t-test or
#' Welch ANOVA when distribution guidance does not flag skewness, rank-based
#' tests when it does, and chi-square or Fisher's exact test according to
#' expected cell counts. Shapiro-Wilk is supporting information only and does
#' not itself select a test.
#'
#' The publication table contains only the p-value and compact test markers.
#' The full per-variable audit trail is retained in `$assumptions`,
#' `$diagnostics`, `$p_values`, and `$denominators`. In particular,
#' `diagnostics_stats(x)` records automatic selection, distribution guidance,
#' expected cell counts where relevant, and observed group spread for
#' independent continuous comparisons. Observed spread is descriptive context,
#' not a variance-test gatekeeper; Welch methods do not require equal
#' variances.
#'
#' @param x A `gt_desc_table` object created with [summary_table()].
#' @param method Statistical test to use. Either a single method string, or a
#'   named character vector/list specifying methods for individual variables.
#'   Names may match either displayed variable labels or underlying variable
#'   names.
#' @param paired Logical; whether comparisons should be treated as paired.
#' @param id Pair or participant identifier required when `paired = TRUE`.
#' @param normality_check Logical; when `method = "auto"`, use distribution
#'   guidance to choose parametric or rank-based tests. This guidance is based
#'   on skewness; Shapiro-Wilk is supporting information only. For paired
#'   analyses the check is applied to within-pair differences.
#' @param var_equal Logical; use equal-variance Student t-tests when appropriate.
#'   The default is `FALSE`, giving Welch tests.
#' @param correction Logical; apply continuity correction to chi-square and
#'   McNemar tests where applicable.
#' @param p_adjust Multiplicity adjustment applied across displayed variable
#'   tests. One of [stats::p.adjust.methods]; default `"none"`.
#' @param digits Number of decimal places used when formatting p-values.
#'
#' @return An updated `gt_desc_table` object with a `p-value` column added.
#'
#' @examples
#' summary_table(mtcars, by = am) |>
#'   add_summary(vars = c(mpg, wt, cyl)) |>
#'   add_p()
#'
#' summary_table(mtcars, by = am) |>
#'   add_summary(vars = c(mpg, wt, cyl)) |>
#'   add_p(method = c(mpg = "welch_t", wt = "wilcox", cyl = "chisq"))
#'
#' @export
add_p <- function(
    x,
    method = "auto",
    paired = FALSE,
    id = NULL,
    normality_check = TRUE,
    var_equal = FALSE,
    correction = TRUE,
    p_adjust = c("none", setdiff(stats::p.adjust.methods, "none")),
    digits = 3
) {
  p_adjust <- match.arg(p_adjust)
  .validate_flag(paired, "paired")
  .validate_flag(normality_check, "normality_check")
  .validate_flag(var_equal, "var_equal")
  .validate_flag(correction, "correction")
  .validate_digits(digits)
  id_name <- .resolve_var_arg(
    substitute(id),
    env = parent.frame(),
    allow_null = TRUE
  )
  if (isTRUE(paired) && is.null(id_name)) {
    stop("`id` is required when `paired = TRUE`.", call. = FALSE)
  }

  # Validate object type and table mode
  if (!inherits(x, "gt_desc_table")) {
    stop("`x` must be a `gt_desc_table` object.", call. = FALSE)
  }

  if (!identical(x$mode, "summary")) {
    stop(
      paste0(
        "`add_p()` can only be used with descriptive tables created ",
        "with `mode = \"summary\"`."
      ),
      call. = FALSE
    )
  }
  # Require a grouping variable because p-values compare across groups

  if (is.null(x$by)) {
    stop(
      "`add_p()` requires a grouping variable
      from `summary_table(..., by = ...)`.",
      call. = FALSE
    )
  }
  # Require existing rows before adding a p-value colum

  if (is.null(x$table) || nrow(x$table) == 0) {
    stop(
      "No rows have been added yet.
      Add summary or proportion rows before `add_p()`.",
      call. = FALSE
    )
  }
  # Helper to format p-values consistently for display

  .fmt_p <- function(p, digits = 3) {
    if (is.na(p)) return("")
    if (p < 0.001) return("<0.001")
    sprintf(paste0("%.", digits, "f"), p)
  }
  # Resolve the requested test method for each variable

  .resolve_method <- function(var_label, base_label, method) {
    allowed <- c(
      "auto", "welch_t", "t_test", "wilcox",
      "anova", "welch_anova", "kruskal", "chisq", "fisher", "mcnemar"
    )

    if (is.character(method) && length(method) == 1) {
      if (!method %in% allowed) {
        stop(paste0("Unsupported `method`: ", method, "."), call. = FALSE)
      }
      return(method)
    }

    if (is.list(method)) {
      method <- unlist(method, use.names = TRUE)
    }

    if (is.character(method) && length(method) > 1 && !is.null(names(method))) {
      chosen <- if (var_label %in% names(method)) {
        unname(method[var_label])
      } else {
        NULL
      }

      if (is.null(chosen) && base_label %in% names(method)) {
        chosen <- unname(method[base_label])
      }

      if (is.null(chosen)) {
        chosen <- "auto"
      }

      if (!chosen %in% allowed) {
        stop(
          paste0(
            "Unsupported method for variable `",
            var_label,
            "`: ",
            chosen,
            "."
          ),
          call. = FALSE
        )
      }

      return(chosen)
    }

    stop(
      "`method` must be a single method string,
      or a named character vector/list.",
      call. = FALSE
    )
  }
  # Remove trailing level text from displayed labels, e.g. "vs (1)" -> "vs"

  .base_label <- function(v) {
    sub("\\s*\\([^)]*\\)$", "", v)
  }
  # Superscript symbols used to link p-values to statistical test footnotes

  superscripts <- c(
    "\u1d43", # ᵃ
    "\u1d47", # ᵇ
    "\u1d9c", # ᶜ
    "\u1d48", # ᵈ
    "\u1d49", # ᵉ
    "\u1da0", # ᶠ
    "\u1d4d", # ᵍ
    "\u02b0"  # ʰ
  )
  # Store mapping between test names and superscript symbols

  test_symbol_map <- list()

  data_names <- names(x$data)
  data_labels <- vapply(
    data_names,
    function(v) .get_var_label(x$data, v),
    character(1)
  )
  # Match displayed table labels back to original variable names in the data

  .find_var_name <- function(display_label) {
    # Match the complete display label first. Parentheses are often a genuine
    # part of a clinical label, for example "Maternal age (years)".
    hit_label <- data_names[data_labels == display_label]
    if (length(hit_label) > 0) {
      return(hit_label[1])
    }

    hit_name <- data_names[data_names == display_label]
    if (length(hit_name) > 0) {
      return(hit_name[1])
    }

    # Only strip a trailing parenthesised value as a fallback for rows created
    # by add_proportion(), such as "Smoking prevalence (Yes)".
    base_label <- .base_label(display_label)
    hit_label <- data_names[data_labels == base_label]
    if (length(hit_label) > 0) {
      return(hit_label[1])
    }

    hit_name <- data_names[data_names == base_label]
    if (length(hit_name) > 0) {
      return(hit_name[1])
    }

    NA_character_
  }

  tbl <- x$table
  var_order <- unique(tbl$Variable)
  skip_labels <- c("Total", "Total (N)", "Total participants")

  p_map <- list()
  p_records <- list()
  tests_used <- character()
  assumption_rows <- list()
  diagnostic_rows <- list()

  # Work through each displayed variable once and calculate its p-value

  for (var_label in var_order) {
    # Skip total rows or empty labels because these are not tested
    if (var_label %in% skip_labels ||
        identical(var_label, "")
        || is.na(var_label)) {
      next
    }
    # Resolve displayed label back to source variable name
    var_name <- .find_var_name(var_label)
    if (is.na(var_name)) {
      next
    }
    # Choose method either globally or variable-specific
    chosen_method <- .resolve_method(
      var_label = var_label,
      base_label = var_name,
      method = method
    )
    # Run group comparison safely so one failure does not break the whole table
    cmp <- tryCatch(
      compare_groups(
        data = x$data,
        variable = var_name,
        group = x$by,
        paired = paired,
        id = id_name,
        test = chosen_method,
        digits = digits,
        .normality_check = normality_check,
        .var_equal = var_equal,
        .correction = correction
      ),
      error = function(e) {
        message("add_p() failed for ", var_name, ": ", e$message)
        NULL
      }
    )

    if (is.null(cmp)) {
      p_map[[var_label]] <- ""
      next
    }
    if (!is.null(cmp$assumptions) && nrow(cmp$assumptions) > 0) {
      cmp_assumptions <- cmp$assumptions
      cmp_assumptions$variable <- var_name
      assumption_rows[[length(assumption_rows) + 1L]] <- cmp_assumptions
    }
    if (!is.null(cmp$diagnostics) && nrow(cmp$diagnostics) > 0) {
      cmp_diagnostics <- cmp$diagnostics
      cmp_diagnostics$variable <- var_name
      diagnostic_rows[[length(diagnostic_rows) + 1L]] <- cmp_diagnostics
    }
    # Extract p-value and test name from compare_groups() output
    p_val <- cmp$inferential$p_value[1]
    test_used <- cmp$inferential$test_used[1]
    tests_used <- unique(c(tests_used, test_used))

    # Assign a unique superscript symbol to each distinct test used
    if (!(test_used %in% names(test_symbol_map))) {
      idx <- length(test_symbol_map) + 1

      if (idx > length(superscripts)) {
        stop(
          "Too many distinct tests used for available superscripts.",
          call. = FALSE
        )
      }

      test_symbol_map[[test_used]] <- superscripts[idx]
    }

    symbol <- unname(test_symbol_map[[test_used]])

    p_records[[length(p_records) + 1L]] <- tibble::tibble(
      variable = var_name,
      label = var_label,
      test = test_used,
      symbol = symbol,
      p_value = p_val
    )
  }
  p_values <- dplyr::bind_rows(p_records)
  if (nrow(p_values) > 0L) {
    p_values$p_adjusted <- stats::p.adjust(
      p_values$p_value,
      method = p_adjust
    )
    p_values$p_adjust_method <- p_adjust
    display_p <- if (identical(p_adjust, "none")) {
      p_values$p_value
    } else {
      p_values$p_adjusted
    }
    for (i in seq_len(nrow(p_values))) {
      p_map[[p_values$label[[i]]]] <- paste0(
        .fmt_p(display_p[[i]], digits),
        p_values$symbol[[i]]
      )
    }
  }
  # Show the p-value only on the first row for each variable
  p_col <- rep("", nrow(tbl))
  first_idx <- !duplicated(tbl$Variable)

  for (i in seq_len(nrow(tbl))) {
    if (first_idx[i]) {
      var_label <- tbl$Variable[i]
      if (!is.null(p_map[[var_label]])) {
        p_col[i] <- p_map[[var_label]]
      }
    }
  }
  # Append p-value column to table
  tbl$`p-value` <- p_col
  x$table <- tbl

   # Track that p-values were added and record which tests were used
  x$components <- unique(c(x$components, "p_value"))
  x$methods_used <- unique(c(x$methods_used, tests_used))

  # Build footnotes linking superscript symbols to test names
  method_footnotes <- character()
  for (test_name in names(test_symbol_map)) {
    method_footnotes <- c(
      method_footnotes,
      paste0(test_symbol_map[[test_name]], " ", test_name)
    )
  }

  x$pvalue_method_footnotes <- method_footnotes
  x$p_values <- p_values
  x$p_adjust <- p_adjust
  x$method$p_adjust <- p_adjust
  new_assumptions <- dplyr::bind_rows(assumption_rows)
  new_diagnostics <- dplyr::bind_rows(diagnostic_rows)
  if (nrow(new_assumptions) > 0) {
    existing <- x$assumptions %||% .empty_assumptions()
    if (!"variable" %in% names(existing)) {
      existing$variable <- character(nrow(existing))
    }
    x$assumptions <- dplyr::bind_rows(existing, new_assumptions)
  }
  if (nrow(new_diagnostics) > 0) {
    existing <- x$diagnostics %||% .empty_diagnostics()
    if (!"variable" %in% names(existing)) {
      existing$variable <- character(nrow(existing))
    }
    x$diagnostics <- dplyr::bind_rows(existing, new_diagnostics)
  }
  x$assumption_notes <- unique(c(
    x$assumption_notes %||% character(),
    paste0(
      "Automatic tests used distribution guidance: ",
      if (normality_check) "yes" else "no",
      ". Independence and study design require user confirmation.",
      if (!identical(p_adjust, "none")) {
        paste0(
          " Displayed p-values use the ",
          p_adjust,
          " multiplicity adjustment."
        )
      } else {
        ""
      }
    )
  ))

  x
}
