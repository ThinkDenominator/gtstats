# Internal summary-table builder helpers ----------------------------------

.validate_summary_builder <- function(x, caller) {
  if (!inherits(x, "gtstats_summary")) {
    stop("`x` must be a `gtstats_summary` object created by `summary_table()`.", call. = FALSE)
  }

  invisible(TRUE)
}

.builder_group_values <- function(x) {
  if (is.null(x$by)) {
    return(character())
  }

  values <- x$data[[x$by]]
  observed <- !is.na(values)

  if (is.factor(values)) {
    return(levels(droplevels(values[observed])))
  }

  unique(as.character(values[observed]))
}

.builder_group_columns <- function(x) {
  values <- .builder_group_values(x)
  stats::setNames(paste0(x$by, " = ", .display_level(values)), values)
}

.builder_display_headers <- function(x) {
  labels <- character()

  if ("Overall" %in% names(x$table)) {
    labels[["Overall"]] <- paste0("Overall\nN = ", nrow(x$data))
  }
  if ("Value" %in% names(x$table) && is.null(x$by)) {
    labels[["Value"]] <- paste0("Overall\nN = ", nrow(x$data))
  }

  if (!is.null(x$by)) {
    values <- .builder_group_values(x)
    columns <- .builder_group_columns(x)
    for (i in seq_along(values)) {
      value <- values[[i]]
      column <- unname(columns[[i]])
      if (column %in% names(x$table)) {
        n_group <- sum(
          !is.na(x$data[[x$by]]) &
            as.character(x$data[[x$by]]) == value
        )
        labels[[column]] <- paste0(.display_level(value), "\nN = ", n_group)
      }
    }
  }

  labels
}

# Create the reader-facing first column without altering the analytical table.
.builder_characteristic_display <- function(tbl) {
  if (!all(c("Variable", "Level") %in% names(tbl)) || nrow(tbl) == 0L) {
    return(list(data = tbl, parent_rows = integer(), level_rows = integer()))
  }

  block_id <- cumsum(c(TRUE, tbl$Variable[-1L] != tbl$Variable[-nrow(tbl)]))
  blocks <- split(tbl, block_id)
  output <- vector("list", length(blocks))
  parent_rows <- integer()
  level_rows <- integer()
  cursor <- 0L

  for (i in seq_along(blocks)) {
    block <- blocks[[i]]
    variable <- block$Variable[[1L]]
    has_levels <- any(!is.na(block$Level) & nzchar(block$Level))

    if (!has_levels) {
      block$Characteristic <- variable
      block$Variable <- NULL
      block$Level <- NULL
      output[[i]] <- block[, c("Characteristic", setdiff(names(block), "Characteristic")), drop = FALSE]
      parent_rows <- c(parent_rows, cursor + 1L)
      cursor <- cursor + nrow(block)
      next
    }

    parent <- block[1L, , drop = FALSE]
    value_columns <- setdiff(names(parent), c("Variable", "Level", "p-value"))
    for (column in value_columns) parent[[column]] <- ""
    parent$Characteristic <- variable
    parent$Variable <- NULL
    parent$Level <- NULL

    levels <- block
    levels$Characteristic <- ifelse(
      is.na(levels$Level) | !nzchar(levels$Level),
      "Missing",
      as.character(levels$Level)
    )
    if ("p-value" %in% names(levels)) levels[["p-value"]] <- ""
    levels$Variable <- NULL
    levels$Level <- NULL

    combined <- dplyr::bind_rows(parent, levels)
    combined <- combined[, c("Characteristic", setdiff(names(combined), "Characteristic")), drop = FALSE]
    output[[i]] <- combined
    parent_rows <- c(parent_rows, cursor + 1L)
    level_rows <- c(level_rows, cursor + seq.int(2L, nrow(combined)))
    cursor <- cursor + nrow(combined)
  }

  list(
    data = tibble::as_tibble(dplyr::bind_rows(output)),
    parent_rows = parent_rows,
    level_rows = level_rows
  )
}

.publication_auto_padding <- function(n_rows) {
  if (n_rows <= 10L) return(3)
  if (n_rows <= 25L) return(2)
  1
}

.builder_base_display_columns <- function(x) {
  columns <- character()
  if (isTRUE(x$overall)) columns <- c(columns, "Overall")
  if (!is.null(x$by)) {
    columns <- c(columns, unname(.builder_group_columns(x)))
  }
  if (is.null(x$by) && !isTRUE(x$overall)) columns <- c(columns, "Value")
  unique(columns)
}

.split_summary_ci_display <- function(value) {
  if (is.na(value) || !nzchar(value) || identical(value, "\u2014")) {
    return(c(estimate = value, ci = ""))
  }
  # Categorical n (%) or n/N (%) followed by an interval.
  match <- regexec(
    "^(.*) \\(([^;]+); [0-9.]+% CI ([^)]+)\\)$",
    value
  )
  parts <- regmatches(value, match)[[1L]]
  if (length(parts) == 4L) {
    return(c(
      estimate = paste0(parts[[2L]], " (", parts[[3L]], ")"),
      ci = paste0(parts[[4L]], "%")
    ))
  }
  # Current compact categorical display: n (%); lower–upper%.
  match <- regexec("^(.* \\([^;]+%\\)); ([^;]+%)$", value)
  parts <- regmatches(value, match)[[1L]]
  if (length(parts) == 3L) {
    return(c(estimate = parts[[2L]], ci = parts[[3L]]))
  }
  # Current percentage-only display: estimate%; lower–upper%.
  match <- regexec("^(.*%); ([^;]+%)$", value)
  parts <- regmatches(value, match)[[1L]]
  if (length(parts) == 3L) {
    return(c(estimate = parts[[2L]], ci = parts[[3L]]))
  }
  # Percentage-only categorical display.
  match <- regexec("^(.*%) \\([0-9.]+% CI ([^)]+)\\)$", value)
  parts <- regmatches(value, match)[[1L]]
  if (length(parts) == 3L) {
    return(c(estimate = parts[[2L]], ci = paste0(parts[[3L]], "%")))
  }
  # Continuous mean with CI.
  match <- regexec("^(.*) \\([0-9.]+% CI ([^)]+)\\)$", value)
  parts <- regmatches(value, match)[[1L]]
  if (length(parts) == 3L) {
    return(c(estimate = parts[[2L]], ci = parts[[3L]]))
  }
  c(estimate = value, ci = "")
}

.builder_summary_estimate_label <- function(x) {
  statistics <- x$summary_statistics %||% character()
  if (length(statistics) == 0L) return("Summary")
  types <- vapply(names(statistics), function(variable) {
    .detect_type(x$data[[variable]])
  }, character(1))
  if (all(types != "continuous")) {
    return(switch(
      x$categorical %||% "n_percent",
      n_percent = "n (%)",
      n_over_N_percent = "n/N (%)",
      n = "n",
      percent = "%",
      "Summary"
    ))
  }
  if (all(types == "continuous")) {
    formats <- unique(unname(statistics))
    if (length(formats) == 1L) {
      return(switch(
        formats,
        mean_sd = "Mean (SD)",
        mean_ci = "Mean (CI)",
        median_iqr = "Median (IQR)",
        both = "Mean (SD); median (IQR)",
        "Summary"
      ))
    }
  }
  "Summary"
}

.builder_use_separate_layout <- function(x, conf.level = 0.95,
                                         estimate_label = NULL) {
  if (identical(x$layout %||% "compact", "separate") &&
      !is.null(x$display_columns)) {
    return(x)
  }
  if (is.null(x$table)) {
    x$table <- tibble::tibble(Variable = character(), Level = character())
    for (column in .builder_base_display_columns(x)) {
      x$table[[column]] <- character()
    }
  }
  base_columns <- intersect(.builder_base_display_columns(x), names(x$table))
  if (length(base_columns) == 0L) {
    x$layout <- "separate"
    return(x)
  }
  fixed <- intersect(c("Variable", "Level"), names(x$table))
  estimate_label <- estimate_label %||% .builder_summary_estimate_label(x)
  remaining <- setdiff(names(x$table), c(fixed, base_columns))
  rebuilt <- x$table[, fixed, drop = FALSE]
  display <- vector("list", length(base_columns))
  headers <- .builder_display_headers(x)
  for (i in seq_along(base_columns)) {
    base <- base_columns[[i]]
    estimate_col <- paste0("summary_", i, "_estimate")
    ci_col <- paste0("summary_", i, "_ci")
    parts <- lapply(x$table[[base]], .split_summary_ci_display)
    rebuilt[[estimate_col]] <- vapply(parts, `[[`, character(1), "estimate")
    rebuilt[[ci_col]] <- vapply(parts, `[[`, character(1), "ci")
    display[[i]] <- tibble::tibble(
      group = headers[[base]] %||% base,
      source = base,
      estimate = estimate_col,
      ci = ci_col,
      estimate_label = estimate_label,
      ci_label = .conf_level_label(conf.level)
    )
  }
  for (column in remaining) rebuilt[[column]] <- x$table[[column]]
  x$table <- tibble::as_tibble(rebuilt)
  x$display_columns <- dplyr::bind_rows(display)
  x$layout <- "separate"
  x
}

.split_categorical_display <- function(value) {
  if (is.na(value) || !nzchar(value) || identical(value, "\u2014")) {
    return(c(count = value, percent = ""))
  }
  match <- regexec("^(.*) \\(([^)]+%)\\)$", value)
  parts <- regmatches(value, match)[[1L]]
  if (length(parts) == 3L) {
    return(c(count = parts[[2L]], percent = parts[[3L]]))
  }
  c(count = value, percent = "")
}

.builder_use_separate_categorical_layout <- function(x) {
  if (!is.null(x$display_columns)) return(x)
  base_columns <- intersect(.builder_base_display_columns(x), names(x$table))
  fixed <- intersect(c("Variable", "Level"), names(x$table))
  remaining <- setdiff(names(x$table), c(fixed, base_columns))
  rebuilt <- x$table[, fixed, drop = FALSE]
  display <- vector("list", length(base_columns))
  headers <- .builder_display_headers(x)
  count_label <- if (identical(x$categorical, "n_over_N_percent")) "n/N" else "n"
  for (i in seq_along(base_columns)) {
    base <- base_columns[[i]]
    count_col <- paste0("summary_", i, "_count")
    percent_col <- paste0("summary_", i, "_percent")
    parts <- lapply(x$table[[base]], .split_categorical_display)
    rebuilt[[count_col]] <- vapply(parts, `[[`, character(1), "count")
    percentages <- vapply(parts, `[[`, character(1), "percent")
    has_percentages <- any(!is.na(percentages) & nzchar(percentages))
    if (has_percentages) rebuilt[[percent_col]] <- percentages
    display[[i]] <- tibble::tibble(
      group = headers[[base]] %||% base,
      source = base,
      estimate = count_col,
      ci = if (has_percentages) percent_col else NA_character_,
      estimate_label = count_label,
      ci_label = if (has_percentages) "%" else NA_character_
    )
  }
  for (column in remaining) rebuilt[[column]] <- x$table[[column]]
  x$table <- tibble::as_tibble(rebuilt)
  x$display_columns <- dplyr::bind_rows(display)
  x$layout <- "separate"
  x
}

.builder_set_separate_cell <- function(row, x, source, estimate, ci = "") {
  mapping <- x$display_columns[x$display_columns$source == source, , drop = FALSE]
  if (nrow(mapping) != 1L) return(row)
  row[[mapping$estimate[[1L]]]] <- estimate
  if (!is.na(mapping$ci[[1L]]) && nzchar(mapping$ci[[1L]])) {
    row[[mapping$ci[[1L]]]] <- ci
  }
  row
}

.builder_order_display_columns <- function(x, table) {
  fixed <- intersect(c("Variable", "Level"), names(table))
  groups <- if (is.null(x$by)) {
    character()
  } else {
    intersect(unname(.builder_group_columns(x)), names(table))
  }
  overall <- intersect("Overall", names(table))
  value <- intersect("Value", names(table))
  data_columns <- if (identical(x$overall_position, "last")) {
    c(groups, overall, value)
  } else {
    c(overall, groups, value)
  }
  remaining <- setdiff(names(table), c(fixed, data_columns))
  table[, c(fixed, data_columns, remaining), drop = FALSE]
}

.builder_audit_groups <- function(x) {
  groups <- list()
  if (isTRUE(x$overall) || is.null(x$by)) {
    groups$Overall <- rep(TRUE, nrow(x$data))
  }
  if (!is.null(x$by)) {
    values <- .builder_group_values(x)
    for (value in values) {
      groups[[paste0(x$by, " = ", value)]] <-
        !is.na(x$data[[x$by]]) &
        as.character(x$data[[x$by]]) == value
    }
  }
  groups
}

.append_builder_rows <- function(x, rows, position = "last") {
  position <- match.arg(position, c("first", "last"))
  rows <- tibble::as_tibble(rows)

  if (is.null(x$table)) {
    x$table <- rows
    return(x)
  }

  all_cols <- union(names(x$table), names(rows))
  for (column in setdiff(all_cols, names(x$table))) {
    x$table[[column]] <- ""
  }
  for (column in setdiff(all_cols, names(rows))) {
    rows[[column]] <- ""
  }

  x$table <- x$table[, all_cols, drop = FALSE]
  rows <- rows[, all_cols, drop = FALSE]

  x$table <- if (identical(position, "first")) {
    dplyr::bind_rows(rows, x$table)
  } else {
    dplyr::bind_rows(x$table, rows)
  }

  x
}
