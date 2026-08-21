# Shared helpers -----------------------------------------------------------

.get_var_label <- function(data, var) {
  label <- attr(data[[var]], "label", exact = TRUE)
  if (!is.null(label) && length(label) == 1L && !is.na(label) &&
      nzchar(as.character(label))) {
    return(as.character(label))
  }
  var
}

.detect_type <- function(x, cat_threshold = 5L) {
  if (inherits(x, "Date")) return("date")
  if (inherits(x, c("POSIXct", "POSIXlt"))) return("datetime")
  if (is.ordered(x)) return("ordinal")

  observed <- stats::na.omit(x)
  n_unique <- length(unique(observed))
  if (length(observed) == 0L) return("categorical")
  if (is.logical(x)) return("binary")
  if (is.factor(x)) {
    if (nlevels(x) == 2L) return("binary")
    return("categorical")
  }
  if (is.character(x)) {
    if (n_unique == 2L) return("binary")
    return(if (n_unique <= cat_threshold) "categorical" else "text")
  }
  if (is.numeric(x) || is.integer(x)) {
    observed <- observed[is.finite(observed)]
    n_unique <- length(unique(observed))
    if (length(observed) == 0L) return("categorical")
    if (n_unique == 2L) return("binary")
    integer_like <- all(
      abs(observed - round(observed)) < sqrt(.Machine$double.eps)
    )
    if (integer_like && n_unique <= cat_threshold) return("categorical")
    return("continuous")
  }
  "other"
}

.ordinal_assessment <- function(x, variable, label) {
  observed <- stats::na.omit(x)
  values <- if (is.factor(x)) {
    levels(droplevels(x))
  } else {
    unique(as.character(observed))
  }
  empty <- tibble::tibble(
    variable = character(),
    label = character(),
    classification = character(),
    levels = character(),
    reason = character()
  )
  if (length(values) < 3L) return(empty)

  if (is.ordered(x)) {
    return(tibble::tibble(
      variable = variable,
      label = label,
      classification = "Confirmed ordinal",
      levels = paste(values, collapse = " < "),
      reason = "Stored as an ordered factor."
    ))
  }

  normalized <- tolower(trimws(values))
  known_sequences <- list(
    c("none", "one", "two or more"),
    c("low", "medium", "high"),
    c("mild", "moderate", "severe"),
    c("poor", "fair", "good", "very good", "excellent"),
    c(
      "strongly disagree", "disagree", "neutral", "agree",
      "strongly agree"
    ),
    c("stage i", "stage ii", "stage iii", "stage iv"),
    c("grade i", "grade ii", "grade iii", "grade iv")
  )
  semantic_match <- any(vapply(
    known_sequences,
    function(sequence) identical(normalized, sequence),
    logical(1)
  ))
  name_suggests_order <- grepl(
    "stage|grade|severity|pain|likert|rank|ordinal",
    paste(variable, label),
    ignore.case = TRUE
  )
  numeric_values <- suppressWarnings(as.numeric(as.character(observed)))
  consecutive_integer <- length(numeric_values) > 0L &&
    all(!is.na(numeric_values)) &&
    all(abs(numeric_values - round(numeric_values)) <
          sqrt(.Machine$double.eps)) &&
    length(unique(numeric_values)) <= 10L &&
    identical(
      sort(unique(as.integer(numeric_values))),
      seq.int(min(numeric_values), max(numeric_values))
    )

  if (semantic_match) {
    return(tibble::tibble(
      variable = variable,
      label = label,
      classification = "Possible ordinal",
      levels = paste(values, collapse = " < "),
      reason = "Category labels describe a recognised progression."
    ))
  }
  if (name_suggests_order) {
    return(tibble::tibble(
      variable = variable,
      label = label,
      classification = "Possible ordinal",
      levels = paste(values, collapse = " < "),
      reason = "The variable name or label suggests an ordered scale."
    ))
  }
  if (consecutive_integer) {
    return(tibble::tibble(
      variable = variable,
      label = label,
      classification = "Possible ordinal or count",
      levels = paste(sort(unique(numeric_values)), collapse = " < "),
      reason = "Observed values are consecutive integers; confirm their meaning."
    ))
  }
  empty
}

.validate_vars <- function(data, vars = NULL) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }
  if (is.null(vars)) return(names(data))

  vars <- as.character(vars)
  missing_vars <- setdiff(vars, names(data))
  if (length(missing_vars) > 0L) {
    stop(
      paste0(
        "These variables were not found in `data`: ",
        paste(missing_vars, collapse = ", "), "."
      ),
      call. = FALSE
    )
  }
  vars
}

.format_complete <- function(n, total, digits = 1L) {
  pct <- if (total == 0L) NA_real_ else 100 * n / total
  paste0(
    n, "/", total, " (",
    ifelse(is.na(pct), "NA", format(round(pct, digits), nsmall = digits)),
    "%)"
  )
}

.format_value <- function(x, digits = 2L) {
  if (is.na(x)) return("NA")
  format(round(x, digits), nsmall = digits, trim = TRUE)
}

.common_values <- function(x, max_values = 3L, digits = 1L) {
  observed <- x[!is.na(x)]
  if (length(observed) == 0L) return("No observed values")
  tab <- sort(table(as.character(observed)), decreasing = TRUE)
  tab <- utils::head(tab, max_values)
  pct <- 100 * as.numeric(tab) / length(observed)
  paste0(
    names(tab), " ", as.integer(tab), " (",
    format(round(pct, digits), nsmall = digits), "%)",
    collapse = "; "
  )
}

.variable_overview <- function(x, type, digits = 2L) {
  observed <- x[!is.na(x)]
  n <- length(observed)
  if (n == 0L) return("No observed values")

  if (type == "continuous") {
    mean_text <- .format_value(mean(observed), digits)
    sd_text <- if (n > 1L) .format_value(stats::sd(observed), digits) else "NA"
    median_text <- .format_value(stats::median(observed), digits)
    return(paste0(
      "Mean ", mean_text, " (SD ", sd_text, "); median ", median_text
    ))
  }
  if (type %in% c("binary", "categorical", "ordinal")) {
    return(.common_values(x, digits = min(digits, 1L)))
  }
  if (type %in% c("date", "datetime")) {
    return(paste0(min(observed), " to ", max(observed)))
  }
  if (type == "text") {
    return(paste0(length(unique(observed)), " distinct text values"))
  }
  paste0(length(unique(observed)), " distinct values")
}

.range_or_levels <- function(x, type, digits = 2L) {
  observed <- x[!is.na(x)]
  if (length(observed) == 0L) return("")
  if (type == "continuous") {
    return(paste0(
      .format_value(min(observed), digits), " to ",
      .format_value(max(observed), digits)
    ))
  }
  if (type %in% c("binary", "categorical", "ordinal")) {
    values <- if (is.factor(x)) {
      levels(droplevels(x))
    } else {
      unique(as.character(observed))
    }
    preview <- paste(utils::head(values, 5L), collapse = ", ")
    if (length(values) > 5L) preview <- paste0(preview, ", ...")
    return(preview)
  }
  ""
}

.variable_issues <- function(
    x,
    variable,
    label,
    type,
    n_total,
    n_missing,
    n_unique
) {
  observed_n <- n_total - n_missing
  rows <- list()
  add_issue <- function(issue, why, check) {
    rows[[length(rows) + 1L]] <<- tibble::tibble(
      variable = variable,
      label = label,
      issue = issue,
      why_flagged = why,
      suggested_check = check
    )
  }
  if (observed_n == 0L) {
    add_issue(
      "All values missing",
      "No observed values are available.",
      "Confirm data import and whether the variable should be analysed."
    )
  }
  if (n_total > 0L && n_missing / n_total >= 0.2) {
    add_issue(
      "High missingness",
      "At least 20% of values are missing.",
      "Review the reason for missingness before analysis."
    )
  } else if (n_missing > 0L) {
    add_issue(
      "Missing values",
      paste0(n_missing, " value", if (n_missing == 1L) " is" else "s are",
             " missing."),
      "Confirm the denominator used in each analysis."
    )
  }
  if (observed_n > 0L && n_unique == 1L) {
    add_issue(
      "Constant variable",
      "Every observed value is identical.",
      "Confirm the coding; this variable cannot distinguish participants."
    )
  }
  if (type == "continuous" && is.integer(x) && n_unique <= 10L) {
    add_issue(
      "Low-cardinality numeric",
      paste0("Only ", n_unique, " distinct integer values were observed."),
      "Confirm whether this is a count, ordered category, or continuous measure."
    )
  }
  if (observed_n >= 10L && n_unique == observed_n &&
      (is.integer(x) || is.character(x))) {
    add_issue(
      "Possible identifier",
      "Every observed value is unique.",
      "Confirm that this variable should not be summarised as a measurement."
    )
  }
  if (type %in% c("binary", "categorical", "ordinal") && observed_n > 0L) {
    counts <- table(as.character(stats::na.omit(x)))
    if (length(counts) > 1L && any(counts < 5L)) {
      add_issue(
        "Sparse category",
        "At least one observed category contains fewer than 5 records.",
        "Confirm coding and consider whether categories are clinically distinct."
      )
    }
  }
  if (length(rows) == 0L) {
    return(tibble::tibble(
      variable = character(),
      label = character(),
      issue = character(),
      why_flagged = character(),
      suggested_check = character()
    ))
  }
  dplyr::bind_rows(rows)
}

#' Understand a dataset before analysis
#'
#' Create a concise, clinically oriented first look at a dataset. One row is
#' returned per variable, combining its label, detected type, completeness,
#' cardinality, a type-specific overview, and range or levels. Potential
#' data-quality findings are kept separately in `$issues`.
#'
#' `describe_data()` deliberately does not assess distributional assumptions
#' or recommend inferential tests. Use [assess_distribution()] for the shape of
#' selected continuous variables, [summary_table()] for detailed descriptive
#' statistics, and [compare_groups()] for inferential comparisons.
#'
#' @param data A data.frame.
#' @param vars Optional character vector of variables. Default is all variables.
#' @param digits Number of decimal places in concise numeric summaries.
#' @param format Output format: `"table"` (default) or `"tibble"`.
#' @param output Compatibility alias for `format`.
#'
#' @return With `format = "table"`, a `gt_describe` object that prints as a
#'   publication-ready table. `$summary` is the concise variable overview and
#'   `$issues` contains only findings requiring review. With
#'   `format = "tibble"`, the concise summary tibble is returned directly.
#'
#' @examples
#' describe_data(mtcars)
#' describe_data(mtcars, vars = c("mpg", "cyl", "am"))
#' tbl_stats(describe_data(mtcars))
#'
#' @export
describe_data <- function(
    data,
    vars = NULL,
    digits = 2,
    format = c("table", "tibble"),
    output = NULL
) {
  if (!is.null(output)) {
    format <- output
  }
  format <- match.arg(format, c("table", "tibble"))
  vars <- .validate_vars(data, vars)
  if (!is.numeric(digits) || length(digits) != 1L ||
      is.na(digits) || digits < 0) {
    stop("`digits` must be a single non-negative number.", call. = FALSE)
  }

  n_total <- nrow(data)
  issue_rows <- list()
  ordinal_rows <- list()
  rows <- lapply(vars, function(variable) {
    x <- data[[variable]]
    type <- .detect_type(x)
    n_missing <- sum(is.na(x))
    n_complete <- n_total - n_missing
    n_unique <- length(unique(stats::na.omit(x)))
    issue_rows[[length(issue_rows) + 1L]] <<- .variable_issues(
      x = x,
      variable = variable,
      label = .get_var_label(data, variable),
      type = type,
      n_total = n_total,
      n_missing = n_missing,
      n_unique = n_unique
    )
    ordinal_rows[[length(ordinal_rows) + 1L]] <<- .ordinal_assessment(
      x = x,
      variable = variable,
      label = .get_var_label(data, variable)
    )

    tibble::tibble(
      variable = variable,
      label = .get_var_label(data, variable),
      type = type,
      complete = .format_complete(n_complete, n_total),
      n_unique = n_unique,
      overview = .variable_overview(x, type, digits),
      range_levels = .range_or_levels(x, type, digits)
    )
  })
  summary_tbl <- dplyr::bind_rows(rows)
  issues_tbl <- dplyr::bind_rows(issue_rows)
  ordinal_tbl <- dplyr::bind_rows(ordinal_rows)

  table_tbl <- summary_tbl
  table_tbl$display_variable <- ifelse(
    table_tbl$label == table_tbl$variable,
    table_tbl$variable,
    paste0(table_tbl$label, " [", table_tbl$variable, "]")
  )
  possible_ordinal <- ordinal_tbl$variable[
    grepl("^Possible ordinal", ordinal_tbl$classification)
  ]
  table_tbl$type[
    table_tbl$variable %in% possible_ordinal
  ] <- paste0(
    table_tbl$type[table_tbl$variable %in% possible_ordinal],
    "*"
  )
  table_tbl <- table_tbl[, c(
    "display_variable", "type", "complete", "n_unique", "overview",
    "range_levels"
  ), drop = FALSE]
  names(table_tbl) <- c(
    "Variable", "Type", "Complete", "Unique", "Overview", "Range / levels"
  )

  if (identical(format, "tibble")) {
    return(summary_tbl)
  }

  result <- list(
    inputs = list(
      data_name = deparse(substitute(data)),
      vars = vars,
      digits = digits,
      format = format
    ),
    summary = summary_tbl,
    issues = tibble::as_tibble(issues_tbl),
    ordinal = tibble::as_tibble(ordinal_tbl),
    table = tibble::as_tibble(table_tbl),
    notes = c(
      "One row is shown per selected variable.",
      "Potential data-quality findings and interpretation prompts are stored in `$issues`.",
      if (length(possible_ordinal) > 0L) {
        paste0(
          "* Possible ordinal or count-coded variable; confirm the intended ",
          "meaning and order from the data dictionary or clinical context."
        )
      } else {
        "Ordered factors are identified as ordinal variables."
      }
    ),
    call = match.call()
  )
  class(result) <- c("gt_describe", "gtstats", "list")
  result
}
