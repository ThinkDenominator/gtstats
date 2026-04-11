# ---- helper: safe variable labels ----

# Return a user-defined variable label when present; otherwise use
# the original variable name.
.get_var_label <- function(data, var) {
  lbl <- attr(data[[var]], "label", exact = TRUE)

  if (!is.null(lbl) &&
      length(lbl) == 1 &&
      !is.na(lbl) &&
      nzchar(lbl)) {
    return(as.character(lbl))
  }

  var
}

# ---- helper: detect variable type ----

# Classify a variable into a simple analysis-friendly type.
.detect_type <- function(
    x,
    detect_ordinal = TRUE,
    cat_threshold = 5
) {
  if (is.ordered(x) && detect_ordinal) {
    return("ordinal")
  }

  x_no_na <- stats::na.omit(x)
  n_unique <- length(unique(x_no_na))

  if (length(x_no_na) == 0) {
    return("categorical")
  }

  if (is.logical(x)) {
    return("binary")
  }

  if (is.factor(x)) {
    if (nlevels(x) == 2) {
      return("binary")
    }

    if (is.ordered(x) && detect_ordinal) {
      return("ordinal")
    }

    return("categorical")
  }

  if (is.character(x)) {
    if (n_unique == 2) {
      return("binary")
    }

    return("categorical")
  }

  if (is.numeric(x) || is.integer(x)) {
    if (n_unique == 2) {
      return("binary")
    }

    is_integer_like <- all(
      abs(x_no_na - round(x_no_na)) <
        sqrt(.Machine$double.eps)
    )

    if (is_integer_like && n_unique <= cat_threshold) {
      return("categorical")
    }

    return("continuous")
  }

  "categorical"
}

# ---- helper: collapse levels preview ----

# Show a short preview of variable levels for display purposes.
.levels_preview <- function(x, max_levels = 5) {
  ux <- unique(stats::na.omit(x))
  ux <- as.character(ux)

  if (length(ux) == 0) {
    return(NA_character_)
  }

  if (length(ux) > max_levels) {
    return(
      paste0(
        paste(utils::head(ux, max_levels), collapse = ", "),
        ", ..."
      )
    )
  }

  paste(ux, collapse = ", ")
}

# ---- helper: suggested summary ----

# Suggest a default descriptive summary based on variable type.
.suggested_summary <- function(type) {
  switch(
    type,
    continuous = "Mean (SD) and Median (IQR)",
    binary = "Count (%)",
    categorical = "Count (%)",
    ordinal = "Count (%)",
    "Count (%)"
  )
}

# ---- helper: suggested plot ----

# Suggest a simple plot type based on variable type.
.suggested_plot <- function(type) {
  switch(
    type,
    continuous = "Histogram",
    binary = "Bar chart",
    categorical = "Bar chart",
    ordinal = "Bar chart",
    "Bar chart"
  )
}

# ---- helper: validate vars ----

# Validate user-supplied variable names against the dataset.
.validate_vars <- function(data, vars = NULL) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }

  if (is.null(vars)) {
    return(names(data))
  }

  vars <- as.character(vars)
  missing_vars <- setdiff(vars, names(data))

  if (length(missing_vars) > 0) {
    stop(
      paste0(
        "These variables were not found in `data`: ",
        paste(missing_vars, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }

  vars
}

# ---- helper: format missing ----

# Format missing counts and percentages for display.
.format_missing <- function(n_missing, n_total, digits = 1) {
  pct <- if (n_total == 0) {
    NA_real_
  } else {
    100 * n_missing / n_total
  }

  paste0(
    n_missing,
    " (",
    format(round(pct, digits), nsmall = digits),
    "%)"
  )
}

# ---- describe_data() ----

#' Describe dataset structure and variable types
#'
#' Provide a quick overview of variables in a dataset, including
#' variable labels, detected types, missingness, number of unique
#' values, simple value ranges, and suggested summaries or plots.
#'
#' This function is intended as a first-step data check before moving
#' to descriptive or inferential analysis. Variable types are detected
#' automatically using simple rules suitable for teaching and applied
#' statistical workflows.
#'
#' @param data A data.frame.
#' @param vars Optional character vector of variables to describe.
#'   Default is all variables in `data`.
#' @param missing Logical; currently stored in the returned object for
#'   future use.
#' @param detect_ordinal Logical; whether ordered factors should be
#'   classified as `"ordinal"`.
#' @param output Output style. Currently stored in the returned
#'   object.
#' @param quiet Logical; suppress messages.
#'
#' @return A `gt_describe` object containing:
#' \itemize{
#'   \item `inputs` — function inputs and settings
#'   \item `summary` — detailed variable summary
#'   \item `table` — display-ready table
#'   \item `notes` — explanatory notes
#'   \item `call` — matched function call
#' }
#'
#' @examples
#' describe_data(mtcars)
#'
#' describe_data(mtcars, vars = c("mpg", "cyl", "am"))
#'
#' tbl_stats(describe_data(mtcars))
#'
#' @export
describe_data <- function(
    data,
    vars = NULL,
    missing = TRUE,
    detect_ordinal = TRUE,
    output = c("table", "tibble"),
    quiet = FALSE
) {
  output <- match.arg(output)

  # Validate requested variables
  vars <- .validate_vars(data, vars)

  # Build one summary row per variable
  out <- lapply(vars, function(var) {
    x <- data[[var]]
    type <- .detect_type(
      x,
      detect_ordinal = detect_ordinal
    )

    n_total <- nrow(data)
    n_missing <- sum(is.na(x))
    n_nonmissing <- sum(!is.na(x))
    pct_missing <- if (n_total == 0) {
      NA_real_
    } else {
      100 * n_missing / n_total
    }

    n_unique <- length(unique(stats::na.omit(x)))

    min_value <- if (type == "continuous" && n_nonmissing > 0) {
      suppressWarnings(min(x, na.rm = TRUE))
    } else {
      NA_real_
    }

    max_value <- if (type == "continuous" && n_nonmissing > 0) {
      suppressWarnings(max(x, na.rm = TRUE))
    } else {
      NA_real_
    }

    levels_preview <- if (
      type %in% c("binary", "categorical", "ordinal")
    ) {
      .levels_preview(x)
    } else {
      NA_character_
    }

    notes <- ""
    if (type == "continuous" &&
        is.integer(x) &&
        n_unique <= 10) {
      notes <- paste0(
        "Low number of unique numeric values; ",
        "review if categorical."
      )
    }

    data.frame(
      variable = var,
      label = .get_var_label(data, var),
      class = paste(class(x), collapse = ", "),
      type = type,
      n_total = n_total,
      n_nonmissing = n_nonmissing,
      n_missing = n_missing,
      pct_missing = pct_missing,
      n_unique = n_unique,
      min_value = min_value,
      max_value = max_value,
      levels_preview = levels_preview,
      suggested_summary = .suggested_summary(type),
      suggested_plot = .suggested_plot(type),
      notes = notes,
      stringsAsFactors = FALSE
    )
  })

  summary_tbl <- tibble::as_tibble(do.call(rbind, out))

  # Build a simpler display table for printing and rendering
  table_tbl <- summary_tbl[, c(
    "label",
    "type",
    "n_missing",
    "pct_missing",
    "n_unique",
    "suggested_summary"
  )]

  names(table_tbl) <- c(
    "Variable",
    "Type",
    "Missing",
    "% Missing",
    "Unique values",
    "Suggested summary"
  )

  result <- list(
    inputs = list(
      data_name = deparse(substitute(data)),
      vars = vars,
      missing = missing,
      detect_ordinal = detect_ordinal,
      output = output
    ),
    summary = summary_tbl,
    table = tibble::as_tibble(table_tbl),
    notes = c("Variable type was auto-detected."),
    call = match.call()
  )

  class(result) <- "gt_describe"
  result
}
