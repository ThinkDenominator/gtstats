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
#'   `"n_over_N_percent"`. The publication table places the confidence
#'   interval in a separate column; with `by`, each group spans its estimate
#'   and interval columns.
#' @param digits Number of decimal places.
#' @param format Output format: `"table"` (default) or a plain console
#'   `"tibble"`.
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
    digits = 1,
    format = c("table", "tibble")
) {
  format <- match.arg(format)
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
  if (identical(format, "tibble")) return(result$table)
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
#' @param format Output format: `"table"` (default) or a plain console
#'   `"tibble"`.
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
    digits = 2,
    format = c("table", "tibble")
) {
  format <- match.arg(format)
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
  chi_effect <- suppressWarnings(stats::chisq.test(tab, correct = FALSE))
  expected_screen <- .expected_count_screen(chi$expected)
  sparse <- expected_screen$sparse
  chosen <- if (identical(test, "auto")) if (sparse) "fisher" else "chisq" else test
  fisher_simulated <- identical(chosen, "fisher") && (nrow(tab) > 2L || ncol(tab) > 2L)
  fit <- if (identical(chosen, "none")) NULL else if (identical(chosen, "chisq")) chi else stats::fisher.test(tab, simulate.p.value = fisher_simulated, B = simulate_B)
  test_label <- if (identical(chosen, "none")) "None" else if (identical(chosen, "chisq")) {
    if (nrow(tab) == 2L && ncol(tab) == 2L) "Chi-square test with Yates correction" else "Pearson chi-square test"
  } else if (fisher_simulated) "Fisher's exact test (Monte Carlo p-value)" else "Fisher's exact test"
  total_n <- sum(tab)
  collapse_cell <- function(bits) {
    if (identical(format, "tibble")) {
      if (length(bits) == 1L) return(bits[[1L]])
      return(paste0(bits[[1L]], " (", paste(bits[-1L], collapse = "; "), ")"))
    }
    paste(bits, collapse = "<br>")
  }
  format_cell <- function(n, r, c) {
    bits <- as.character(n)
    if (!identical(percent, "none")) {
      multi_percent <- length(percent) > 1L
      if ("row" %in% percent) bits <- c(bits, paste0(if (multi_percent) "Row " else "", formatC(100 * n / sum(tab[r, ]), format = "f", digits = digits), "%"))
      if ("column" %in% percent) bits <- c(bits, paste0(if (multi_percent) "Col " else "", formatC(100 * n / sum(tab[, c]), format = "f", digits = digits), "%"))
      if ("total" %in% percent) bits <- c(bits, paste0(if (multi_percent) "Total " else "", formatC(100 * n / total_n, format = "f", digits = digits), "%"))
    }
    collapse_cell(bits)
  }
  display <- matrix("", nrow(tab), ncol(tab), dimnames = dimnames(tab))
  for (i in seq_len(nrow(tab))) for (j in seq_len(ncol(tab))) display[i, j] <- format_cell(tab[i, j], i, j)
  table_tbl <- data.frame(
    Row = .display_level(rownames(tab)), display,
    check.names = FALSE, stringsAsFactors = FALSE
  )
  names(table_tbl)[-1L] <- .display_level(colnames(tab))
  if (isTRUE(totals)) {
    table_tbl$Total <- vapply(
      seq_len(nrow(tab)),
      function(index) collapse_cell(c(
        as.character(rowSums(tab)[[index]]),
        paste0(formatC(100 * rowSums(tab)[[index]] / total_n, format = "f", digits = digits), "%")
      )),
      character(1)
    )
    total_row <- c(
      "Total",
      vapply(colSums(tab), function(value) collapse_cell(c(as.character(value), "100.00%")), character(1)),
      collapse_cell(c(as.character(total_n), "100.00%"))
    )
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
  cell_note <- if (identical(percent, "none")) {
    "Cells are counts."
  } else {
    paste0("Cells are n (", paste(percent, collapse = " and "), " %).")
  }
  association_note <- if (is.null(fit)) {
    NULL
  } else {
    paste0(test_label, ", p = ", format.pval(fit$p.value, digits = 3), ".")
  }
  cramer_note <- paste0(
    "Cramer's V = ",
    formatC(
      sqrt(unname(chi_effect$statistic) /
        (total_n * min(nrow(tab) - 1L, ncol(tab) - 1L))),
      format = "f", digits = digits
    ),
    "."
  )
  notes <- paste(c(cell_note, association_note, cramer_note), collapse = " ")
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
      threshold = "No expected count < 1 and <=20% of expected counts < 5",
      detail = paste0(
        "Association test: ", test_label, ". ",
        expected_screen$n_below_5, " of ", expected_screen$n_cells,
        " expected cells were below 5."
      )
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
      expected_count_screen = expected_screen,
      fisher_simulated = fisher_simulated,
      selection_rule = if (identical(test, "auto")) {
        if (sparse) {
          "Independent categorical outcome: expected cell count guidance was not met (an expected count below 1 or more than 20% below 5); selected Fisher's exact test."
        } else {
          "Independent categorical outcome: expected cell count guidance was met (no expected count below 1 and no more than 20% below 5); selected chi-square test."
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
  if (identical(format, "tibble")) return(result$table)
  result
}

#' Save a gtstats table or plot
#'
#' Save a `gtstats` result, rendered `flextable`, rendered `gt_tbl`, or
#' `ggplot2` plot. A named list of gtstats results, flextables, and plots can be
#' combined into one Word document. The object determines the export route
#' automatically. The file type is inferred from `filename`.
#'
#' @param x A `gtstats` result, rendered `flextable`, rendered `gt_tbl`,
#'   `ggplot2` plot, or a named list of tables and plots for a combined Word
#'   report.
#' @param filename Output filename including a supported extension.
#' @param path Optional output directory. When omitted, `filename` is used as
#'   supplied, so a simple filename saves in the current working directory.
#' @param title,subtitle Optional table title and subtitle.
#' @param bold_labels Logical; bold variable labels in tables.
#' @param show_footnotes Logical; include explanatory table footnotes.
#' @param zoom,expand Image-export controls for tables.
#' @param vwidth,vheight Browser viewport dimensions for table image export.
#' @param width,height Plot dimensions.
#' @param units Dimension units passed to `ggplot2::ggsave()` for plots.
#' @param dpi Output resolution for plots.
#' @param bg Plot background colour.
#' @param quiet Logical; suppress the saved-path message.
#' @param page_break Logical; when saving a list to Word, start each output
#'   after the first on a new page.
#' @param ... Additional arguments passed to the relevant underlying save method.
#' @return The normalized saved path, invisibly.
#' @examples
#' \dontrun{
#' table <- summary_table(mtcars) |> add_summary(vars = c(mpg, wt))
#' save_output(table, "summary.html")
#'
#' plot <- plot_compare(mtcars, variable = mpg, group = am)
#' save_output(plot, "comparison.png")
#'
#' save_output(
#'   list("Table 1" = table, "Comparison plot" = plot),
#'   "statistical-report.docx"
#' )
#' }
#' @export
save_output <- function(
    x,
    filename,
    path = NULL,
    title = NULL,
    subtitle = NULL,
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
    page_break = TRUE,
    quiet = FALSE,
    ...
) {
  if (is.null(path) && is.character(filename) &&
      length(filename) == 1L && !is.na(filename) && nzchar(filename)) {
    path <- dirname(filename)
    filename <- basename(filename)
  }
  if (!is.logical(page_break) || length(page_break) != 1L || is.na(page_break)) {
    stop("`page_break` must be TRUE or FALSE.", call. = FALSE)
  }
  saved <- if (is.list(x) && !is.data.frame(x) && !inherits(x, "gtstats") &&
      !inherits(x, c("flextable", "gt_tbl", "ggplot"))) {
    .save_word_report(
      x = x,
      filename = filename,
      path = path,
      title = title,
      subtitle = subtitle,
      show_footnotes = show_footnotes,
      width = width,
      height = height,
      page_break = page_break,
      quiet = quiet
    )
  } else if (inherits(x, "ggplot")) {
    .save_plot(
      plot = x, filename = filename, path = path, width = width,
      height = height, units = units, dpi = dpi, bg = bg, quiet = quiet, ...
    )
  } else {
    .save_table(
      x = x, filename = filename, path = path, title = title,
      subtitle = subtitle,
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
#' @param x A supported `gtstats` result, rendered `flextable`, or rendered
#'   `gt_tbl`.
#' @param engine Rendering engine used when `x` is an unrendered result.
#'   `"flextable"` is the default; use `"gt"` for HTML-oriented workflows.
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
#' @param spanning_header Optional spanning heading. Supply one character value
#'   to span all result columns, or a named list/vector mapping displayed
#'   headings to completed column names.
#' @param footnotes Optional additional footer notes.
#' @param borders Border style: `"horizontal"`, `"all"`, or `"minimal"`.
#' @param density Cell density: `"standard"`, `"compact"`, or `"spacious"`.
#' @param column_widths Optional named numeric vector of column widths in inches
#'   for flextable output.
#' @param pvalue_style P-value style for summary-table results: `"threshold"`,
#'   `"fixed"`, or `"scientific"`.
#' @param pvalue_digits Number of displayed p-value digits.
#' @param pvalue_threshold Threshold displayed using a less-than sign.
#' @param pvalue_prefix Logical; prepend `p =` to ordinary p-values.
#' @return A styled `flextable` by default, or a `gt_tbl` when `engine = "gt"`
#'   or `x` is already a gt table.
#' @examples
#' result <- summary_table(mtcars, include = c(mpg, wt))
#' customise_table(result, title = "Vehicle characteristics")
#' @export
customise_table <- function(
    x,
    engine = c("flextable", "gt"),
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
    show_footnotes = TRUE,
    spanning_header = NULL,
    footnotes = NULL,
    borders = c("horizontal", "all", "minimal"),
    density = c("standard", "compact", "spacious"),
    column_widths = NULL,
    pvalue_style = c("threshold", "fixed", "scientific"),
    pvalue_digits = 3,
    pvalue_threshold = 0.001,
    pvalue_prefix = FALSE
) {
  engine <- match.arg(engine)
  theme <- match.arg(theme)
  borders <- match.arg(borders)
  density <- match.arg(density)
  pvalue_style <- match.arg(pvalue_style)
  .validate_flag(bold_labels, "bold_labels")
  .validate_flag(show_footnotes, "show_footnotes")
  .validate_flag(pvalue_prefix, "pvalue_prefix")
  if (!is.null(font) && (!is.character(font) || length(font) != 1L ||
      is.na(font) || !nzchar(font))) {
    stop("`font` must be NULL or a single non-empty font name.", call. = FALSE)
  }
  if (!is.null(width) && (!is.numeric(width) || length(width) != 1L ||
      is.na(width) || width <= 0 || width > 100)) {
    stop("`width` must be a percentage between 0 and 100.", call. = FALSE)
  }
  if (!is.null(row_striping)) {
    .validate_flag(row_striping, "row_striping")
  }
  if (!inherits(x, c("gt_tbl", "flextable"))) {
    if (!inherits(x, "gtstats")) {
      stop(
        "`x` must be a gtstats result, flextable, or rendered gt table.",
        call. = FALSE
      )
    }
    x <- .style_pvalues_in_result(
      x,
      style = pvalue_style,
      digits = pvalue_digits,
      threshold = pvalue_threshold,
      prefix = pvalue_prefix
    )
    x <- if (identical(engine, "flextable")) {
      to_flextable(x, show_footnotes = show_footnotes)
    } else {
      to_gt(x, bold_labels = bold_labels, show_footnotes = show_footnotes)
    }
  }
  if (inherits(x, "flextable")) {
    return(.style_flextable(
      x = x, theme = theme, title = title, subtitle = subtitle,
      source_note = source_note, col_labels = col_labels,
      row_labels = row_labels, level_labels = level_labels, align = align,
      hide_cols = hide_cols, bold_cols = bold_cols, italic_cols = italic_cols,
      font_size = font_size, font = font, row_striping = row_striping,
      accent_color = accent_color, stripe_color = stripe_color,
      spanning_header = spanning_header, footnotes = footnotes,
      borders = borders, density = density, column_widths = column_widths
    ))
  }
  gt_result <- .style_table(
    x = x, theme = theme, title = title, subtitle = subtitle,
    source_note = source_note, col_labels = col_labels,
    row_labels = row_labels, level_labels = level_labels, align = align,
    hide_cols = hide_cols, bold_cols = bold_cols, italic_cols = italic_cols,
    font_size = font_size, font = font, width = width,
    row_striping = row_striping, accent_color = accent_color,
    stripe_color = stripe_color
  )
  if (!is.null(spanning_header)) {
    keys <- names(gt_result[["_data"]])
    label_cols <- intersect(c("Variable", "Level", "Measure", "Group", "Event"), keys)
    spans <- .normalise_spanning_header(spanning_header, setdiff(keys, label_cols))
    for (label in names(spans)) {
      gt_result <- gt::tab_spanner(
        gt_result,
        label = label,
        columns = spans[[label]]
      )
    }
  }
  if (!is.null(footnotes)) {
    for (note in footnotes) gt_result <- gt::tab_source_note(gt_result, source_note = note)
  }
  density_padding <- switch(density, compact = 1, spacious = 6, 3)
  gt_result <- gt::tab_options(
    gt_result,
    data_row.padding = gt::px(density_padding)
  )
  if (identical(borders, "minimal")) {
    gt_result <- gt::tab_options(
      gt_result,
      table_body.hlines.style = "none",
      column_labels.border.bottom.style = "none"
    )
  } else if (identical(borders, "all")) {
    gt_result <- gt::tab_style(
      gt_result,
      style = gt::cell_borders(
        sides = "all",
        color = accent_color %||% "#A6A6A6",
        weight = gt::px(1)
      ),
      locations = list(gt::cells_body(), gt::cells_column_labels())
    )
  }
  gt_result
}

.normalise_spanning_header <- function(x, value_cols) {
  if (is.null(x) || length(value_cols) == 0L) return(list())
  if (is.character(x) && length(x) == 1L && is.null(names(x))) {
    return(stats::setNames(list(value_cols), x))
  }
  if (is.character(x) && !is.null(names(x)) && all(nzchar(names(x)))) {
    x <- split(unname(x), names(x))
  }
  if (!is.list(x) || is.null(names(x)) || any(!nzchar(names(x)))) {
    stop(
      paste0(
        "`spanning_header` must be one heading or a named list/vector ",
        "mapping headings to completed columns."
      ),
      call. = FALSE
    )
  }
  out <- lapply(x, function(columns) {
    columns <- as.character(columns)
    unknown <- setdiff(columns, value_cols)
    if (length(unknown) > 0L) {
      stop(
        paste0(
          "Unknown `spanning_header` column(s): ",
          paste(unknown, collapse = ", "), "."
        ),
        call. = FALSE
      )
    }
    unique(columns)
  })
  used <- unlist(out, use.names = FALSE)
  if (anyDuplicated(used)) {
    stop("A column cannot belong to more than one spanning header.", call. = FALSE)
  }
  out
}

.style_pvalues_in_result <- function(
    x, style = "threshold", digits = 3, threshold = 0.001, prefix = FALSE
) {
  if (!is.numeric(digits) || length(digits) != 1L || is.na(digits) || digits < 1) {
    stop("`pvalue_digits` must be a single positive number.", call. = FALSE)
  }
  if (!is.numeric(threshold) || length(threshold) != 1L || is.na(threshold) ||
      threshold <= 0 || threshold >= 1) {
    stop("`pvalue_threshold` must be between 0 and 1.", call. = FALSE)
  }
  .one <- function(p) {
    if (!is.finite(p)) return("NA")
    value <- if (identical(style, "scientific")) {
      format(p, scientific = TRUE, digits = digits)
    } else if (identical(style, "fixed")) {
      sprintf(paste0("%.", digits, "f"), p)
    } else if (p < threshold) {
      paste0("<", format(threshold, scientific = FALSE, trim = TRUE))
    } else {
      sprintf(paste0("%.", digits, "f"), p)
    }
    if (isTRUE(prefix) && !startsWith(value, "<")) paste0("p = ", value) else value
  }
  if (inherits(x, "gtstats_summary") && is.data.frame(x$p_values) &&
      "p-value" %in% names(x$table)) {
    for (i in seq_len(nrow(x$p_values))) {
      row <- x$p_values$row_index[[i]]
      symbol <- x$p_values$symbol[[i]] %||% ""
      x$table[["p-value"]][[row]] <- paste0(.one(x$p_values$p_value[[i]]), symbol)
    }
  }
  x
}
