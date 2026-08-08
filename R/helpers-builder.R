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
  stats::setNames(paste0(x$by, " = ", values), values)
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
    for (value in values) {
      column <- unname(columns[[value]])
      if (column %in% names(x$table)) {
        n_group <- sum(
          !is.na(x$data[[x$by]]) &
            as.character(x$data[[x$by]]) == value
        )
        labels[[column]] <- paste0(value, "\nN = ", n_group)
      }
    }
  }

  labels
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
