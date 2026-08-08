# Internal result-contract helpers -----------------------------------------

.assumptions_tbl <- function(
    assumption = character(),
    status = character(),
    result = character(),
    detail = character()
) {
  tibble::tibble(
    assumption = as.character(assumption),
    status = as.character(status),
    result = as.character(result),
    detail = as.character(detail)
  )
}

.diagnostics_tbl <- function(
    check = character(),
    result = character(),
    value = character(),
    threshold = character(),
    detail = character()
) {
  tibble::tibble(
    check = as.character(check),
    result = as.character(result),
    value = as.character(value),
    threshold = as.character(threshold),
    detail = as.character(detail)
  )
}

.empty_assumptions <- function() {
  .assumptions_tbl()
}

.empty_diagnostics <- function() {
  .diagnostics_tbl()
}

.denominators_tbl <- function(
    variable = character(),
    level = character(),
    group = character(),
    n_total = integer(),
    n_nonmissing = integer(),
    n_missing = integer(),
    numerator = numeric(),
    denominator = numeric(),
    rule = character()
) {
  target_size <- max(
    length(variable), length(group), length(n_total), length(n_nonmissing),
    length(n_missing), length(numerator), length(denominator), length(rule)
  )
  if (length(level) == 0L && target_size > 0L) {
    level <- rep(NA_character_, target_size)
  }
  tibble::tibble(
    variable = as.character(variable),
    level = as.character(level),
    group = as.character(group),
    n_total = as.integer(n_total),
    n_nonmissing = as.integer(n_nonmissing),
    n_missing = as.integer(n_missing),
    numerator = as.numeric(numerator),
    denominator = as.numeric(denominator),
    rule = as.character(rule)
  )
}

.empty_denominators <- function() {
  .denominators_tbl()
}

.data_denominators <- function(data, vars, by = NULL,
                               rule = "Non-missing variable observations") {
  groups <- if (is.null(by)) {
    list(Overall = rep(TRUE, nrow(data)))
  } else {
    values <- data[[by]]
    observed_levels <- if (is.factor(values)) {
      levels(droplevels(values[!is.na(values)]))
    } else {
      unique(as.character(values[!is.na(values)]))
    }
    stats::setNames(
      lapply(
        observed_levels,
        function(level) !is.na(values) & as.character(values) == level
      ),
      paste0(by, " = ", observed_levels)
    )
  }

  rows <- lapply(vars, function(variable) {
    dplyr::bind_rows(lapply(names(groups), function(group_label) {
      idx <- groups[[group_label]]
      values <- data[[variable]][idx]
      .denominators_tbl(
        variable = variable,
        group = group_label,
        n_total = length(values),
        n_nonmissing = sum(!is.na(values)),
        n_missing = sum(is.na(values)),
        numerator = NA_real_,
        denominator = sum(!is.na(values)),
        rule = rule
      )
    }))
  })

  dplyr::bind_rows(rows)
}

# Keep categorical percentage denominators at the same resolution as the
# displayed table cell. This is particularly important for `percent = "row"`,
# where each category has its own denominator across groups.
.categorical_denominators <- function(
    data,
    variable,
    by = NULL,
    percent = c("column", "row", "overall", "none")
) {
  percent <- match.arg(percent)
  values <- as.character(data[[variable]])
  levels <- sort(unique(values[!is.na(values)]))
  if (length(levels) == 0L) {
    return(.empty_denominators())
  }

  groups <- if (is.null(by)) {
    list(Overall = rep(TRUE, nrow(data)))
  } else {
    group_values <- data[[by]]
    observed_levels <- if (is.factor(group_values)) {
      levels(droplevels(group_values[!is.na(group_values)]))
    } else {
      unique(as.character(group_values[!is.na(group_values)]))
    }
    stats::setNames(
      lapply(
        observed_levels,
        function(group_level) {
          !is.na(group_values) & as.character(group_values) == group_level
        }
      ),
      paste0(by, " = ", observed_levels)
    )
  }

  overall_denominator <- sum(!is.na(values))
  dplyr::bind_rows(lapply(levels, function(level_value) {
    row_denominator <- sum(values == level_value, na.rm = TRUE)
    dplyr::bind_rows(lapply(names(groups), function(group_label) {
      idx <- groups[[group_label]]
      group_values <- values[idx]
      group_nonmissing <- sum(!is.na(group_values))
      numerator <- sum(group_values == level_value, na.rm = TRUE)
      denominator <- switch(
        percent,
        column = group_nonmissing,
        row = row_denominator,
        overall = overall_denominator,
        none = group_nonmissing
      )
      rule <- switch(
        percent,
        column = "Non-missing observations within displayed group",
        row = "Non-missing observations for this category across displayed groups",
        overall = "All non-missing observations of this variable",
        none = "Counts displayed; non-missing denominator retained for audit"
      )
      .denominators_tbl(
        variable = variable,
        level = level_value,
        group = group_label,
        n_total = length(group_values),
        n_nonmissing = group_nonmissing,
        n_missing = sum(is.na(group_values)),
        numerator = numerator,
        denominator = denominator,
        rule = rule
      )
    }))
  }))
}
