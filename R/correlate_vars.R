#' Correlate two variables
#'
#' Perform correlation analysis between two continuous variables using Pearson
#' or Spearman correlation.
#'
#' This function is designed for practical teaching and applied analysis. It
#' accepts two continuous variables, removes incomplete pairs, selects a
#' correlation method automatically or uses a user-specified method, and returns
#' both a detailed summary and a display-ready table.
#'
#' In `method = "auto"` mode:
#' - Pearson correlation is used when both variables are approximately symmetric
#' - Spearman correlation is used otherwise
#'
#' The output includes the correlation estimate, confidence interval when
#' available, p-value, strength, direction, and a short interpretation.
#'
#' @param data A data.frame.
#' @param x First variable. Can be supplied as a bare name or as a character
#'   string.
#' @param y Second variable. Can be supplied as a bare name or as a character
#'   string.
#' @param method Correlation method. One of `"auto"`, `"pearson"`, or
#'   `"spearman"`.
#' @param conf.level Confidence level for the interval. Default is `0.95`.
#' @param digits Number of decimal places used when formatting numeric output.
#' @param output Output style. Currently stored in the returned object.
#' @param quiet Logical; suppress messages.
#'
#' @return A `gt_correlation` object containing:
#' \itemize{
#'   \item `inputs` — function inputs and settings
#'   \item `summary` — detailed summary table
#'   \item `table` — display-ready table
#'   \item `method` — metadata on variable types and method used
#'   \item `notes` — explanatory notes
#'   \item `call` — matched function call
#' }
#'
#' @examples
#' correlate_vars(mtcars, x = mpg, y = wt)
#'
#' correlate_vars(mtcars, x = "mpg", y = "disp", method = "pearson")
#'
#' tbl_stats(correlate_vars(mtcars, x = mpg, y = wt))
#'
#' @export
correlate_vars <- function(
    data,
    x,
    y,
    method = c("auto", "pearson", "spearman"),
    conf.level = 0.95,
    digits = 3,
    output = c("table", "tibble", "both"),
    quiet = FALSE
) {
  method <- match.arg(method)
  output <- match.arg(output)

  # Validate input data
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }

  # Resolve variable names from either bare names or character input
  x_expr <- substitute(x)
  y_expr <- substitute(y)

  x_eval <- tryCatch(eval(x_expr, parent.frame()), error = function(e) NULL)
  y_eval <- tryCatch(eval(y_expr, parent.frame()), error = function(e) NULL)

  x_name <- if (is.character(x_eval) && length(x_eval) == 1) {
    x_eval
  } else if (is.symbol(x_expr)) {
    deparse(x_expr)
  } else if (is.character(x_expr) && length(x_expr) == 1) {
    x_expr[1]
  } else {
    deparse(x_expr)
  }

  y_name <- if (is.character(y_eval) && length(y_eval) == 1) {
    y_eval
  } else if (is.symbol(y_expr)) {
    deparse(y_expr)
  } else if (is.character(y_expr) && length(y_expr) == 1) {
    y_expr[1]
  } else {
    deparse(y_expr)
  }

  if (!x_name %in% names(data)) {
    stop("`x` was not found in `data`.", call. = FALSE)
  }

  if (!y_name %in% names(data)) {
    stop("`y` was not found in `data`.", call. = FALSE)
  }

  if (x_name == y_name) {
    stop("`x` and `y` must be different variables.", call. = FALSE)
  }

  # Restrict analysis to continuous variables
  x_var <- data[[x_name]]
  y_var <- data[[y_name]]

  x_type <- .detect_type(x_var)
  y_type <- .detect_type(y_var)

  if (x_type != "continuous" || y_type != "continuous") {
    stop(
      "`correlate_vars()` currently supports continuous variables only.",
      call. = FALSE
    )
  }

  # Keep complete pairs only
  keep <- !is.na(x_var) & !is.na(y_var)
  x_clean <- x_var[keep]
  y_clean <- y_var[keep]

  n <- length(x_clean)

  if (n < 3) {
    stop(
      "At least 3 complete pairs are required for correlation analysis.",
      call. = FALSE
    )
  }

  # Helper to format numeric values
  .fmt_num <- function(x, digits = 3) {
    ifelse(
      is.na(x),
      NA_character_,
      sprintf(paste0("%.", digits, "f"), x)
    )
  }

  # Helper to format p-values
  .fmt_p <- function(p, digits = 3) {
    if (is.na(p)) return(NA_character_)
    if (p < 0.001) return("<0.001")
    sprintf(paste0("%.", digits, "f"), p)
  }

  # Helper to format confidence intervals
  .fmt_ci <- function(low, high, digits = 3) {
    if (is.na(low) || is.na(high)) return(NA_character_)
    paste0(.fmt_num(low, digits), " to ", .fmt_num(high, digits))
  }

  # Simple skewness helper used in auto method selection
  .skewness <- function(v) {
    v <- v[!is.na(v)]
    if (length(v) < 3) return(NA_real_)

    s <- stats::sd(v)
    if (is.na(s) || s == 0) return(0)

    m <- mean(v)
    mean((v - m)^3) / (s^3)
  }

  # Classify strength of association based on absolute correlation size
  .strength_label <- function(r) {
    a <- abs(r)

    if (is.na(a)) return(NA_character_)
    if (a < 0.20) return("Negligible")
    if (a < 0.40) return("Weak")
    if (a < 0.60) return("Moderate")
    if (a < 0.80) return("Strong")
    "Very strong"
  }

  # Describe the direction of association
  .direction_label <- function(r) {
    if (is.na(r)) return(NA_character_)
    if (r > 0) return("Positive")
    if (r < 0) return("Negative")
    "No clear direction"
  }

  # Auto-select Pearson for approximately symmetric variables, else Spearman
  chosen_method <- method
  if (method == "auto") {
    sx <- .skewness(x_clean)
    sy <- .skewness(y_clean)

    if (!is.na(sx) && !is.na(sy) && abs(sx) < 1 && abs(sy) < 1) {
      chosen_method <- "pearson"
    } else {
      chosen_method <- "spearman"
    }
  }

  # Run correlation test using the selected method
  if (chosen_method == "pearson") {
    fit <- stats::cor.test(
      x_clean,
      y_clean,
      method = "pearson",
      conf.level = conf.level
    )
    method_used <- "Pearson correlation"
    estimate_type <- "r"
  } else {
    fit <- stats::cor.test(
      x_clean,
      y_clean,
      method = "spearman",
      conf.level = conf.level,
      exact = FALSE
    )
    method_used <- "Spearman correlation"
    estimate_type <- "rho"
  }

  estimate_val <- unname(fit$estimate[[1]])
  p_val <- fit$p.value
  conf_low <- if (!is.null(fit$conf.int)) fit$conf.int[1] else NA_real_
  conf_high <- if (!is.null(fit$conf.int)) fit$conf.int[2] else NA_real_

  # Add practical interpretation labels
  strength <- .strength_label(estimate_val)
  direction <- .direction_label(estimate_val)

  interpretation <- if (p_val < 0.05) {
    paste0(
      .get_var_label(data, x_name),
      " showed a ",
      tolower(strength),
      " ",
      tolower(direction),
      " correlation with ",
      .get_var_label(data, y_name),
      "."
    )
  } else {
    paste0(
      "There was no clear evidence of a correlation between ",
      .get_var_label(data, x_name),
      " and ",
      .get_var_label(data, y_name),
      "."
    )
  }

  # Detailed summary output
  summary_tbl <- tibble::tibble(
    x = x_name,
    x_label = .get_var_label(data, x_name),
    y = y_name,
    y_label = .get_var_label(data, y_name),
    method_requested = method,
    method_used = method_used,
    n = n,
    estimate = estimate_val,
    estimate_type = estimate_type,
    conf_low = conf_low,
    conf_high = conf_high,
    conf_level = conf.level,
    p_value = p_val,
    strength = strength,
    direction = direction,
    interpretation = interpretation,
    notes = ""
  )

  # Display-ready table output
  table_tbl <- tibble::tibble(
    X = .get_var_label(data, x_name),
    Y = .get_var_label(data, y_name),
    Method = method_used,
    n = n,
    Correlation = .fmt_num(estimate_val, digits),
    `95% CI` = .fmt_ci(conf_low, conf_high, digits),
    `p-value` = .fmt_p(p_val, digits),
    Strength = strength,
    Direction = direction,
    Interpretation = interpretation
  )

  result <- list(
    inputs = list(
      data_name = deparse(substitute(data)),
      x = x_name,
      y = y_name,
      method = method,
      conf.level = conf.level,
      digits = digits,
      output = output
    ),
    summary = summary_tbl,
    table = table_tbl,
    method = list(
      x_type = x_type,
      y_type = y_type,
      method_used = chosen_method
    ),
    notes = c(
      "Pearson for symmetric data; otherwise Spearman in auto mode."
    ),
    call = match.call()
  )

  class(result) <- "gt_correlation"
  result
}
