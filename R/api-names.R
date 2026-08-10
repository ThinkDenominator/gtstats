#' Proportion statistics
#'
#' Calculate a proportion and confidence interval, optionally within groups.
#' This is the descriptive-statistics counterpart to [rate_stats()].
#'
#' @param data A data frame.
#' @param var Binary or categorical variable whose selected level is counted.
#' @param by Optional categorical grouping variable.
#' @param level Outcome level to count. A sensible event level is selected when
#'   omitted.
#' @param conf.level Confidence level for the interval.
#' @param ci_method Confidence-interval method: `"wilson"` (default) or
#'   `"exact"`.
#' @param display Estimate display: `"n_percent"`, `"percent"`, or
#'   `"n_over_N_percent"`.
#' @param digits Number of decimal places.
#' @return A `gt_prop` object containing numeric results and a display table.
#' @examples
#' proportion_stats(mtcars, var = vs)
#' proportion_stats(mtcars, var = vs, by = am)
#' @export
proportion_stats <- function(
    data,
    var,
    by = NULL,
    level = NULL,
    conf.level = 0.95,
    ci_method = c("wilson", "exact"),
    display = c("n_percent", "percent", "n_over_N_percent"),
    digits = 1
) {
  data_name <- deparse(substitute(data))
  ci_method <- match.arg(ci_method)
  display <- match.arg(display)
  var_name <- .resolve_var_arg(substitute(var), env = parent.frame())
  by_name <- .resolve_var_arg(
    substitute(by),
    env = parent.frame(),
    allow_null = TRUE
  )

  result <- do.call(
    .proportion_result,
    list(
      data = data,
      var = var_name,
      by = by_name,
      level = level,
      conf.level = conf.level,
      ci_method = ci_method,
      display = display,
      digits = digits
    )
  )
  result$inputs$data_name <- data_name
  result$call <- match.call()
  result
}

#' Cross-tabulations with optional 2x2 epidemiological measures
#'
#' Create a publication-ready cross-tabulation for any two categorical
#' variables. Counts, selected row/column/total percentages, and margins are
#' displayed. For a binary 2x2 table, risks, risk ratios, odds ratios, and risk
#' differences are additionally available because their direction is defined.
#' For a 2x2 table, the selected exposed and event levels are always retained
#' in the result, including when they were chosen automatically. Association
#' diagnostics, zero-cell handling, and complete-pair denominators remain in
#' the audit components rather than cluttering the displayed table.
#'
#' @param data A data frame.
#' @param row Categorical row variable. For a binary 2x2 table, this is the
#'   exposure/reference axis.
#' @param col Categorical column variable. For a binary 2x2 table, this is the
#'   outcome/event axis.
#' @param percent Percentages to show in each cell: `"column"` (default),
#'   `"row"`, `"total"`, or `"none"`. Supply `c("row", "column")` to show
#'   more than one denominator.
#' @param totals Logical; include row, column, and grand totals.
#' @param row_level Level of `row` treated as exposed. A sensible event-like
#'   level is selected when omitted; set this explicitly for reporting.
#' @param col_level Level of `col` treated as the event. A sensible event-like
#'   level is selected when omitted; set this explicitly for reporting.
#' @param measures Measures to display: risk, risk ratio (`"rr"`), odds ratio
#'   (`"or"`), and/or risk difference (`"rd"`).
#' @param conf.level Confidence level for intervals.
#' @param risk_ci Risk confidence-interval method: `"wilson"` or `"exact"`.
#' @param test Association test: `"auto"`, `"none"`, `"chisq"`, or `"fisher"`.
#' @param zero_correction Zero-cell strategy: `"haldane_anscombe"` or `"none"`.
#' @param simulate_B Number of simulations for the automatic Fisher test in a
#'   sparse table larger than 2x2.
#' @param digits Number of decimal places.
#' @return A `gt_twobytwo` object.
#' @examples
#' crosstabs(mtcars, row = am, col = vs)
#' @export
crosstabs <- function(
    data,
    row,
    col,
    percent = "column",
    totals = TRUE,
    row_level = NULL,
    col_level = NULL,
    measures = c("rr", "or", "rd"),
    conf.level = 0.95,
    risk_ci = c("wilson", "exact"),
    test = c("auto", "none", "chisq", "fisher"),
    zero_correction = c("haldane_anscombe", "none"),
    simulate_B = 10000,
    digits = 2
) {
  data_name <- deparse(substitute(data))
  risk_ci <- match.arg(risk_ci)
  test <- match.arg(test)
  zero_correction <- match.arg(zero_correction)
  .validate_flag(totals, "totals")
  if (!is.character(percent) || length(percent) < 1L ||
      any(!percent %in% c("row", "column", "total", "none"))) {
    stop("`percent` must contain row, column, total, or none.", call. = FALSE)
  }
  percent <- unique(percent)
  if ("none" %in% percent && length(percent) > 1L) {
    stop("`percent = \"none\"` cannot be combined with other percentages.", call. = FALSE)
  }
  if (!is.numeric(simulate_B) || length(simulate_B) != 1L ||
      is.na(simulate_B) || simulate_B < 1000) {
    stop("`simulate_B` must be a single number of at least 1000.", call. = FALSE)
  }
  row_name <- .resolve_var_arg(
    substitute(row),
    env = parent.frame()
  )
  col_name <- .resolve_var_arg(
    substitute(col),
    env = parent.frame()
  )

  if (!row_name %in% names(data) || !col_name %in% names(data)) {
    stop("`row` and `col` must be columns in `data`.", call. = FALSE)
  }
  if (identical(row_name, col_name)) stop("`row` and `col` must be different variables.", call. = FALSE)
  keep <- !is.na(data[[row_name]]) & !is.na(data[[col_name]])
  row_x <- droplevels(as.factor(data[[row_name]][keep]))
  col_x <- droplevels(as.factor(data[[col_name]][keep]))
  if (!length(row_x)) stop("No complete row-column pairs are available.", call. = FALSE)
  tab <- table(row_x, col_x)
  if (nrow(tab) < 2L || ncol(tab) < 2L) stop("`row` and `col` must each have at least 2 observed levels.", call. = FALSE)
  chi <- suppressWarnings(stats::chisq.test(tab, correct = nrow(tab) == 2L && ncol(tab) == 2L))
  sparse <- any(chi$expected < 5)
  chosen <- if (identical(test, "auto")) if (sparse) "fisher" else "chisq" else test
  fisher_simulated <- identical(chosen, "fisher") && (nrow(tab) > 2L || ncol(tab) > 2L)
  fit <- if (identical(chosen, "none")) NULL else if (identical(chosen, "chisq")) chi else stats::fisher.test(tab, simulate.p.value = fisher_simulated, B = simulate_B)
  test_label <- if (identical(chosen, "none")) "None" else if (identical(chosen, "chisq")) {
    if (nrow(tab) == 2L && ncol(tab) == 2L) "Chi-square test with Yates correction" else "Pearson chi-square test"
  } else if (fisher_simulated) "Fisher's exact test (Monte Carlo p-value)" else "Fisher's exact test"
  total_n <- sum(tab)
  format_cell <- function(n, r, c) {
    bits <- as.character(n)
    if (!identical(percent, "none")) {
      multi_percent <- length(percent) > 1L
      if ("row" %in% percent) bits <- c(bits, paste0(if (multi_percent) "Row " else "", formatC(100 * n / sum(tab[r, ]), format = "f", digits = digits), "%"))
      if ("column" %in% percent) bits <- c(bits, paste0(if (multi_percent) "Col " else "", formatC(100 * n / sum(tab[, c]), format = "f", digits = digits), "%"))
      if ("total" %in% percent) bits <- c(bits, paste0(if (multi_percent) "Total " else "", formatC(100 * n / total_n, format = "f", digits = digits), "%"))
    }
    paste(bits, collapse = "<br>")
  }
  display <- matrix("", nrow(tab), ncol(tab), dimnames = dimnames(tab))
  for (i in seq_len(nrow(tab))) for (j in seq_len(ncol(tab))) display[i, j] <- format_cell(tab[i, j], i, j)
  table_tbl <- data.frame(
    Row = .display_level(rownames(tab)), display,
    check.names = FALSE, stringsAsFactors = FALSE
  )
  names(table_tbl)[-1L] <- .display_level(colnames(tab))
  if (isTRUE(totals)) {
    table_tbl$Total <- paste0(rowSums(tab), "<br>", formatC(100 * rowSums(tab) / total_n, format = "f", digits = digits), "%")
    total_row <- c("Total", paste0(colSums(tab), "<br>100.00%"), paste0(total_n, "<br>100.00%"))
    table_tbl <- rbind(table_tbl, stats::setNames(as.data.frame(as.list(total_row), stringsAsFactors = FALSE), names(table_tbl)))
  }
  names(table_tbl)[[1L]] <- .get_var_label(data, row_name)
  is_2x2 <- nrow(tab) == 2L && ncol(tab) == 2L
  epi <- NULL
  if (is_2x2) {
  epi <- do.call(.two_by_two_result, list(data = data, exposure = row_name, outcome = col_name, exposed_level = row_level, event_level = col_level, measures = measures, conf.level = conf.level, risk_ci = risk_ci, test = chosen, zero_correction = zero_correction, digits = digits))
  } else if (!is.null(row_level) || !is.null(col_level)) {
    stop("`row_level` and `col_level` are available only for a binary 2x2 table.", call. = FALSE)
  }
  notes <- paste0(
    if (identical(percent, "none")) "Cells are counts. " else paste0("Cells are n (", paste(percent, collapse = " and "), " %). "),
    test_label,
    if (is.null(fit)) "." else paste0(", p = ", format.pval(fit$p.value, digits = 3), "; "),
    "Cramer's V = ", formatC(sqrt(unname(chi$statistic) / (total_n * min(nrow(tab) - 1L, ncol(tab) - 1L))), format = "f", digits = digits), "."
  )
  if (is_2x2 && !is.null(epi$table)) {
    effect_column <- grep("^Effect", names(epi$table), value = TRUE)
    exposed_column <- grep("^Exposed", names(epi$table), value = TRUE)
    unexposed_column <- grep("^Unexposed", names(epi$table), value = TRUE)
    measure_text <- vapply(seq_len(nrow(epi$table)), function(i) {
      if (identical(epi$table$Measure[[i]], "Risk")) return(NA_character_)
      values <- c(
        if (length(effect_column)) epi$table[[effect_column[[1L]]]][[i]] else NA_character_,
        if (length(exposed_column)) epi$table[[exposed_column[[1L]]]][[i]] else NA_character_,
        if (length(unexposed_column)) epi$table[[unexposed_column[[1L]]]][[i]] else NA_character_
      )
      values <- values[!is.na(values) & nzchar(values)]
      label <- c("Risk ratio" = "RR", "Odds ratio" = "OR", "Risk difference" = "RD")[epi$table$Measure[[i]]]
      paste0(label, " ", paste(values, collapse = "; "))
    }, character(1))
    measure_text <- measure_text[!is.na(measure_text)]
    if (length(measure_text) > 0L) notes <- c(notes, paste(measure_text, collapse = "; "))
    direction_and_correction <- epi$notes[grepl(
      "^Exposure:|^Zero cell:", epi$notes
    )]
    notes <- c(notes, direction_and_correction)
  }
  crosstab_denominators <- if (is_2x2) {
    epi$denominators
  } else {
    dplyr::bind_rows(lapply(colnames(tab), function(col_level_value) {
      col_raw <- data[[col_name]]
      in_column_level <- !is.na(col_raw) &
        as.character(col_raw) == col_level_value
      complete_in_level <- keep & as.character(data[[col_name]]) == col_level_value
      .denominators_tbl(
        variable = row_name,
        level = NA_character_,
        group = paste0(col_name, " = ", col_level_value),
        n_total = sum(in_column_level),
        n_nonmissing = sum(complete_in_level),
        n_missing = sum(in_column_level) - sum(complete_in_level),
        numerator = NA_real_,
        denominator = sum(complete_in_level),
        rule = "Complete row-column pairs within displayed column"
      )
    }))
  }
  crosstab_assumptions <- if (is_2x2) {
    epi$assumptions
  } else {
    .assumptions_tbl(
      assumption = c("Independent observations", "Mutually exclusive categories"),
      status = c("user_check", "user_check"),
      result = c("not_checked", "not_checked"),
      detail = c(
        "Confirm independence from the study design.",
        "Each observation should occupy one cross-tabulation cell."
      )
    )
  }
  crosstab_diagnostics <- if (is_2x2) {
    epi$diagnostics
  } else {
    .diagnostics_tbl(
      check = "Expected cell counts",
      result = if (sparse) "sparse" else "adequate",
      value = .format_number(min(chi$expected), 2),
      threshold = "Minimum expected count >= 5",
      detail = paste0("Association test: ", test_label, ".")
    )
  }
  result <- if (is_2x2) epi else list()
  result$inputs <- list(
    data_name = data_name,
    row = row_name,
    col = col_name,
    percent = percent,
    totals = totals,
    row_level = if (is_2x2) epi$inputs$exposed_level else row_level,
    col_level = if (is_2x2) epi$inputs$event_level else col_level,
    measures = measures,
    test = test,
    conf.level = conf.level,
    risk_ci = risk_ci,
    zero_correction = zero_correction,
    simulate_B = simulate_B,
    digits = digits
  )
  result$counts <- as.data.frame.matrix(tab)
  result$table <- tibble::as_tibble(table_tbl)
  result$epi <- if (is_2x2) epi$table else NULL
  result$method <- utils::modifyList(
    if (is_2x2) epi$method else list(),
    list(
      table_type = "crosstab",
      association_test = test_label,
      expected_counts = chi$expected,
      cramers_v = sqrt(unname(chi$statistic) / (
        total_n * min(nrow(tab) - 1L, ncol(tab) - 1L)
      )),
      sparse = sparse,
      fisher_simulated = fisher_simulated,
      selection_rule = if (identical(test, "auto")) {
        if (sparse) {
          "At least one expected cell count was below 5; selected Fisher's exact test."
        } else {
          "All expected cell counts were at least 5; selected chi-square test."
        }
      } else {
        paste0("User specified ", test, " association test.")
      }
    )
  )
  result$assumptions <- crosstab_assumptions
  result$diagnostics <- crosstab_diagnostics
  result$denominators <- crosstab_denominators
  result$notes <- notes
  result$call <- match.call()
  class(result) <- c("gt_twobytwo", "gtstats", "list")
  result
}

#' Save a gtstats table or plot
#'
#' Save a `gtstats` result, rendered `gt_tbl`, or `ggplot2` plot. The object
#' determines the export route automatically. The file type is inferred from
#' `filename`.
#'
#' @param x A `gtstats` result, rendered `gt_tbl`, or `ggplot2` plot.
#' @param filename Output filename including a supported extension.
#' @param path Optional output directory. When omitted, `filename` is used as
#'   supplied, so a simple filename saves in the current working directory.
#' @param title,subtitle Optional table title and subtitle.
#' @param pvalue_style P-value display style for tables.
#' @param bold_labels Logical; bold variable labels in tables.
#' @param show_footnotes Logical; include explanatory table footnotes.
#' @param zoom,expand Image-export controls for tables.
#' @param vwidth,vheight Browser viewport dimensions for table image export.
#' @param width,height Plot dimensions.
#' @param units Dimension units passed to `ggplot2::ggsave()` for plots.
#' @param dpi Output resolution for plots.
#' @param bg Plot background colour.
#' @param quiet Logical; suppress the saved-path message.
#' @param ... Additional arguments passed to the relevant underlying save method.
#' @return The normalized saved path, invisibly.
#' @examples
#' \dontrun{
#' table <- summary_table(mtcars) |> add_summary(vars = c(mpg, wt))
#' save_output(table, "summary.html")
#'
#' plot <- plot_compare(mtcars, outcome = mpg, by = am)
#' save_output(plot, "comparison.png")
#' }
#' @export
save_output <- function(
    x,
    filename,
    path = NULL,
    title = NULL,
    subtitle = NULL,
    pvalue_style = c("default", "scientific"),
    bold_labels = TRUE,
    show_footnotes = TRUE,
    zoom = 2,
    expand = 5,
    vwidth = 992,
    vheight = 744,
    width = 8,
    height = 6,
    units = "in",
    dpi = 300,
    bg = "white",
    quiet = FALSE,
    ...
) {
  if (is.null(path) && is.character(filename) &&
      length(filename) == 1L && !is.na(filename) && nzchar(filename)) {
    path <- dirname(filename)
    filename <- basename(filename)
  }
  saved <- if (inherits(x, "ggplot")) {
    .save_plot(
      plot = x, filename = filename, path = path, width = width,
      height = height, units = units, dpi = dpi, bg = bg, quiet = quiet, ...
    )
  } else {
    .save_table(
      x = x, filename = filename, path = path, title = title,
      subtitle = subtitle, pvalue_style = pvalue_style,
      bold_labels = bold_labels, show_footnotes = show_footnotes,
      zoom = zoom, expand = expand, vwidth = vwidth, vheight = vheight,
      quiet = quiet, ...
    )
  }
  invisible(normalizePath(saved, winslash = "/", mustWork = FALSE))
}

#' Customize a gtstats table
#'
#' Apply titles, labels, alignment, emphasis, colours, and a predefined visual
#' theme to a table produced by `gtstats`.
#'
#' @param x A supported `gtstats` result or rendered `gt_tbl`.
#' @param theme Visual theme: `"default"`, `"journal"`, `"classic"`,
#'   `"minimal"`, or `"compact"`.
#' @param title,subtitle Optional title and subtitle.
#' @param source_note Optional note below the table.
#' @param col_labels,row_labels,level_labels Named character vectors for
#'   relabelling.
#' @param align Named list of left-, right-, or centre-aligned columns.
#' @param hide_cols Columns to hide.
#' @param bold_cols,italic_cols Columns to emphasise.
#' @param font_size Font size in pixels.
#' @param font Optional font family.
#' @param width Table width as a percentage from 0 to 100.
#' @param row_striping Logical; apply alternating row shading.
#' @param accent_color,stripe_color Optional table colours.
#' @param bold_labels Logical; bold variable labels when rendering a raw result.
#' @param show_footnotes Logical; retain explanatory footnotes when rendering a
#'   raw result.
#' @return A styled `gt_tbl`.
#' @examples
#' result <- summary_table(mtcars, include = c(mpg, wt))
#' customise_table(result, title = "Vehicle characteristics")
#' @export
customise_table <- function(
    x,
    theme = c("default", "journal", "classic", "minimal", "compact"),
    title = NULL,
    subtitle = NULL,
    source_note = NULL,
    col_labels = NULL,
    row_labels = NULL,
    level_labels = NULL,
    align = NULL,
    hide_cols = NULL,
    bold_cols = NULL,
    italic_cols = NULL,
    font_size = NULL,
    font = NULL,
    width = NULL,
    row_striping = NULL,
    accent_color = NULL,
    stripe_color = NULL,
    bold_labels = TRUE,
    show_footnotes = TRUE
) {
  theme <- match.arg(theme)
  .validate_flag(bold_labels, "bold_labels")
  .validate_flag(show_footnotes, "show_footnotes")
  if (!is.null(row_striping)) {
    .validate_flag(row_striping, "row_striping")
  }
  if (!inherits(x, "gt_tbl")) {
    if (!inherits(x, "gtstats")) {
      stop(
        "`x` must be a gtstats result or a rendered gt table.",
        call. = FALSE
      )
    }
    x <- tbl_stats(
      x,
      bold_labels = bold_labels,
      show_footnotes = show_footnotes
    )
  }
  .style_table(
    x = x,
    theme = theme,
    title = title,
    subtitle = subtitle,
    source_note = source_note,
    col_labels = col_labels,
    row_labels = row_labels,
    level_labels = level_labels,
    align = align,
    hide_cols = hide_cols,
    bold_cols = bold_cols,
    italic_cols = italic_cols,
    font_size = font_size,
    font = font,
    width = width,
    row_striping = row_striping,
    accent_color = accent_color,
    stripe_color = stripe_color
  )
}
