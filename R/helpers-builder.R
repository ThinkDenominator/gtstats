# Internal summary-table builder helpers ----------------------------------

.validate_summary_builder <- function(x, caller, mode = NULL) {
  if (!inherits(x, "gt_desc_table")) {
    stop("`x` must be a `gt_desc_table` object.", call. = FALSE)
  }

  if (!is.null(mode) && !identical(x$mode, mode)) {
    stop(
      "`", caller, "()` can only be used with tables created with ",
      "`mode = \"", mode, "\"`.",
      call. = FALSE
    )
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

.builder_use_separate_layout <- function(x, conf.level = 0.95,
                                         estimate_label = "Summary") {
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

.builder_set_separate_cell <- function(row, x, source, estimate, ci = "") {
  mapping <- x$display_columns[x$display_columns$source == source, , drop = FALSE]
  if (nrow(mapping) != 1L) return(row)
  row[[mapping$estimate[[1L]]]] <- estimate
  row[[mapping$ci[[1L]]]] <- ci
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
