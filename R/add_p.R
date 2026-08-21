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
#' Welch ANOVA by default when distribution guidance does not flag skewness;
#' Student's t-test or classical ANOVA when `var_equal = TRUE`; rank-based tests
#' when marked skewness is flagged; and chi-square or Fisher's exact test according to
#' expected cell counts. For independent ordered factors, automatic mode uses
#' the same chi-square/Fisher distribution comparison as other categorical
#' variables; select `"wilcox"` or `"kruskal"` explicitly when a rank-based
#' ordinal comparison is wanted. Shapiro-Wilk is supporting information only
#' and does not itself select a test.
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
#' @param include Variables in the descriptive table for which p-values should
#'   be calculated. Uses tidy-select syntax and defaults to all summarized
#'   variables. For example, `include = -bwt` keeps birth weight in the
#'   descriptive table but omits its p-value when the grouping variable was
#'   derived from birth weight.
#' @param paired Logical; whether comparisons should be treated as paired.
#' @param id Pair or participant identifier required when `paired = TRUE`.
#' @param distribution_check Logical; when `method = "auto"`, use distribution
#'   guidance to choose parametric or rank-based tests. This guidance is based
#'   on skewness; Shapiro-Wilk is supporting information only. For paired
#'   analyses the check is applied to within-pair differences.
#' @param var_equal Logical; for independent, non-skewed continuous comparisons
#'   in `method = "auto"`, use Student's t-test or classical ANOVA. The default
#'   `FALSE` uses Welch methods. This is a user-specified assumption, not a
#'   variance test, and does not affect paired, categorical, ordinal, or
#'   rank-based comparisons.
#' @param correction Logical; apply continuity correction to chi-square and
#'   McNemar tests where applicable.
#' @param fisher_seed Integer seed for simulated Fisher exact tests on tables
#'   larger than 2 x 2. Use `NULL` to use the current random-number state.
#' @param p_adjust Multiplicity adjustment applied across displayed variable
#'   tests. One of [stats::p.adjust.methods]; default `"none"`.
#' @param digits Number of decimal places used when formatting p-values.
#'
#' @return An updated `gt_desc_table` object with a `p-value` column added.
#'   When `paired = TRUE`, `$paired_p_notes` records the complete-pair
#'   denominator for each displayed p-value; [tbl_stats()] displays this as a
#'   concise p-value footnote.
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
#' summary_table(mtcars, by = am, include = c(mpg, wt, cyl)) |>
#'   add_p(include = c(mpg, wt))
#'
#' @export
add_p <- function(
    x,
    method = "auto",
    include = tidyselect::everything(),
    paired = FALSE,
    id = NULL,
    distribution_check = TRUE,
    var_equal = FALSE,
    correction = TRUE,
    fisher_seed = 1049L,
    p_adjust = c("none", setdiff(stats::p.adjust.methods, "none")),
    digits = 3
) {
  p_adjust <- match.arg(p_adjust)
  .validate_flag(paired, "paired")
  .validate_flag(distribution_check, "distribution_check")
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

  # Re-running `add_p()` is common in an interactive workflow. Replace the
  # previous p-value audit rather than retaining stale methods/diagnostics from
  # the earlier call.
  previous_p_values <- x$p_values %||% tibble::tibble()
  previous_p_variables <- if ("variable" %in% names(previous_p_values)) {
    unique(previous_p_values$variable)
  } else {
    character()
  }
  remove_previous_p_audit <- function(existing) {
    if (is.null(existing) || nrow(existing) == 0L) return(existing)
    if ("analysis_component" %in% names(existing)) {
      return(existing[is.na(existing$analysis_component) |
        existing$analysis_component != "add_p", , drop = FALSE])
    }
    if (length(previous_p_variables) > 0L && "variable" %in% names(existing)) {
      return(existing[!existing$variable %in% previous_p_variables, , drop = FALSE])
    }
    existing
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

  tbl <- x$table
  summary_vars <- unique(names(x$summary_statistics %||% character()))
  if (length(summary_vars) == 0L) {
    stop(
      "`add_p()` requires variables added by `add_summary()` or the ",
      "`include` argument of `summary_table()`.",
      call. = FALSE
    )
  }

  include_expr <- substitute(include)
  selected_positions <- tidyselect::eval_select(
    include_expr,
    data = x$data,
    env = parent.frame()
  )
  selected_vars <- names(selected_positions)
  summary_vars <- summary_vars[summary_vars %in% selected_vars]

  # Retain source-variable identity instead of reverse-matching labels. Two
  # variables may legitimately share a publication label, and label matching
  # alone can silently attach the wrong test and superscript.
  cursor <- 1L
  test_targets <- lapply(summary_vars, function(var_name) {
    var_label <- .get_var_label(x$data, var_name)
    candidates <- which(
      seq_len(nrow(tbl)) >= cursor & tbl$Variable == var_label
    )
    if (length(candidates) == 0L) return(NULL)
    row_index <- candidates[[1L]]
    observed_levels <- unique(as.character(
      x$data[[var_name]][!is.na(x$data[[var_name]])]
    ))
    block_rows <- if (identical(.detect_type(x$data[[var_name]]), "continuous")) {
      1L
    } else {
      max(length(observed_levels), 1L)
    }
    if (identical(x$missing %||% "no", "always") ||
        (identical(x$missing %||% "no", "ifany") &&
         anyNA(x$data[[var_name]]))) {
      block_rows <- block_rows + 1L
    }
    cursor <<- row_index + block_rows
    list(variable = var_name, label = var_label, row_index = row_index)
  })
  test_targets <- Filter(Negate(is.null), test_targets)

  p_map <- list()
  p_records <- list()
  tests_used <- character()
  assumption_rows <- list()
  diagnostic_rows <- list()
  paired_notes <- character()

  # Work through each source summary variable once and calculate its p-value.
  for (target in test_targets) {
    var_name <- target$variable
    var_label <- target$label
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
        .distribution_check = distribution_check,
        var_equal = var_equal,
        fisher_seed = fisher_seed,
        .correction = correction
      ),
      error = function(e) {
        message("add_p() failed for ", var_name, ": ", e$message)
        NULL
      }
    )

    if (is.null(cmp)) {
      p_map[[as.character(target$row_index)]] <- ""
      next
    }
    if (isTRUE(paired) && !is.null(cmp$denominators) &&
        nrow(cmp$denominators) > 0L) {
      denominator <- cmp$denominators$denominator[[1L]]
      excluded <- cmp$denominators$n_missing[[1L]]
      if (is.finite(denominator) && is.finite(excluded)) {
        paired_notes <- c(
          paired_notes,
          paste0(
            var_label, ": paired p-value used ", denominator,
            " complete ", if (cmp$inferential$group_levels[[1L]] == 2L) "pairs" else "participants",
            "; ", excluded, " excluded because complete matched observations were unavailable."
          )
        )
      }
    }
    if (!is.null(cmp$assumptions) && nrow(cmp$assumptions) > 0) {
      cmp_assumptions <- cmp$assumptions
      cmp_assumptions$variable <- var_name
      cmp_assumptions$analysis_component <- "add_p"
      assumption_rows[[length(assumption_rows) + 1L]] <- cmp_assumptions
    }
    if (!is.null(cmp$diagnostics) && nrow(cmp$diagnostics) > 0) {
      cmp_diagnostics <- cmp$diagnostics
      cmp_diagnostics$variable <- var_name
      cmp_diagnostics$analysis_component <- "add_p"
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
      row_index = target$row_index,
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
      p_map[[as.character(p_values$row_index[[i]])]] <- paste0(
        .fmt_p(display_p[[i]], digits),
        p_values$symbol[[i]]
      )
    }
  }
  # Show the p-value only on the recorded first row for each source variable.
  p_col <- rep("", nrow(tbl))
  for (row_name in names(p_map)) {
    row_index <- as.integer(row_name)
    if (is.finite(row_index) && row_index >= 1L && row_index <= nrow(tbl)) {
      p_col[[row_index]] <- p_map[[row_name]]
    }
  }
  # Append p-value column to table
  tbl$`p-value` <- p_col
  x$table <- tbl

   # Track that p-values were added and record which tests were used
  x$components <- unique(c(x$components, "p_value"))
  previous_tests <- if ("test" %in% names(previous_p_values)) {
    unique(previous_p_values$test)
  } else {
    character()
  }
  x$methods_used <- unique(c(
    setdiff(x$methods_used %||% character(), previous_tests),
    tests_used
  ))

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
  existing_assumptions <- remove_previous_p_audit(
    x$assumptions %||% .empty_assumptions()
  )
  existing_diagnostics <- remove_previous_p_audit(
    x$diagnostics %||% .empty_diagnostics()
  )
  x$assumptions <- dplyr::bind_rows(existing_assumptions, new_assumptions)
  x$diagnostics <- dplyr::bind_rows(existing_diagnostics, new_diagnostics)
  existing_notes <- x$assumption_notes %||% character()
  existing_notes <- existing_notes[!grepl(
    "^Automatic tests used distribution guidance:",
    existing_notes
  )]
  x$assumption_notes <- unique(c(
    existing_notes,
    paste0(
      "Automatic tests used distribution guidance: ",
      if (distribution_check) "yes" else "no",
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
  x$paired_p_notes <- unique(paired_notes)

  x
}
