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
#' The automatic rule uses marginal sample skewness as transparent guidance; it
#' does not establish whether the relationship is linear or monotonic. Inspect
#' [plot_correlation()] before interpreting the coefficient. The selected rule,
#' skewness values, and usable-pair count are retained in `$method` and
#' `$diagnostics`.
#'
#' Printing returns a concise publication-ready table containing the variable
#' pair, analysed sample size, correlation coefficient, confidence interval
#' when available, and p-value. Detailed method and diagnostic information
#' remains available in the returned object.
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
#' correlation(mtcars, x = mpg, y = wt)
#'
#' correlation(mtcars, x = "mpg", y = "disp", method = "pearson")
#'
#' tbl_stats(correlation(mtcars, x = mpg, y = wt))
#'
#' @noRd
.correlation_pair <- function(
    data,
    x,
    y,
    method = c("auto", "pearson", "spearman"),
    conf.level = 0.95,
    digits = 2
) {
  method <- match.arg(method)
  .validate_conf_level(conf.level)
  .validate_digits(digits)

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
      "`correlation()` currently supports continuous variables only.",
      call. = FALSE
    )
  }

  # Keep complete finite pairs only. This makes the computation and companion
  # scatterplot use the same observations, while the audit retains exclusions.
  keep <- is.finite(x_var) & is.finite(y_var)
  x_clean <- x_var[keep]
  y_clean <- y_var[keep]

  n <- length(x_clean)
  n_excluded <- length(x_var) - n

  if (n < 3) {
    stop(
      "At least 3 complete finite pairs are required for correlation analysis.",
      call. = FALSE
    )
  }
  if (length(unique(x_clean)) < 2L || length(unique(y_clean)) < 2L) {
    stop(
      "Each variable must contain at least two distinct finite values.",
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
    threshold <- 10^(-digits)
    if (p < threshold) {
      return(paste0(
        "<",
        formatC(threshold, format = "f", digits = digits)
      ))
    }
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

  sx <- .skewness(x_clean)
  sy <- .skewness(y_clean)

  # Auto-select Pearson for approximately symmetric variables, else Spearman
  chosen_method <- method
  if (method == "auto") {
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
    n_excluded = n_excluded,
    strength = strength,
    direction = direction,
    interpretation = interpretation,
    notes = ""
  )

  # Concise publication table. Spearman confidence intervals are omitted
  # because base R does not provide one and no unannounced approximation should
  # be presented as if it were exact.
  correlation_display <- .fmt_num(estimate_val, digits)
  correlation_header <- "Correlation"
  if (!is.na(conf_low) && !is.na(conf_high)) {
    correlation_display <- paste0(
      correlation_display,
      " (",
      .fmt_num(conf_low, digits),
      " to ",
      .fmt_num(conf_high, digits),
      ")"
    )
    correlation_header <- paste0(
      "Correlation (",
      .conf_level_label(conf.level),
      ")"
    )
  }
  table_tbl <- tibble::tibble(
    Variables = paste0(
      .get_var_label(data, x_name),
      " and ",
      .get_var_label(data, y_name)
    ),
    n = n
  )
  table_tbl[[correlation_header]] <- correlation_display
  table_tbl[["p-value"]] <- .fmt_p(p_val, digits)

  result <- list(
    inputs = list(
      data_name = deparse(substitute(data)),
      x = x_name,
      y = y_name,
      method = method,
      conf.level = conf.level,
      digits = digits
    ),
    summary = summary_tbl,
    table = table_tbl,
    method = list(
      x_type = x_type,
      y_type = y_type,
      method_used = chosen_method,
      selection_rule = if (identical(method, "auto")) {
        if (identical(chosen_method, "pearson")) {
          "Both absolute sample skewness values were below 1; selected Pearson correlation."
        } else {
          "At least one absolute sample skewness value was 1 or greater; selected Spearman correlation."
        }
      } else {
        paste0("User specified ", chosen_method, " correlation.")
      },
      selection_inputs = list(
        x_skewness = sx,
        y_skewness = sy,
        complete_finite_pairs = n,
        excluded_pairs = n_excluded
      )
    ),
    assumptions = .assumptions_tbl(
      assumption = c(
        "Independent observation pairs",
        if (chosen_method == "pearson") {
          "Approximately linear relationship"
        } else {
          "Monotonic relationship"
        },
        "No dominating influential observations"
      ),
      status = c("user_check", "user_check", "user_check"),
      result = c("not_checked", "not_checked", "not_checked"),
      detail = c(
        "Confirm independence from the study design.",
        "Inspect a scatterplot before interpreting the coefficient.",
        "Inspect the scatterplot for observations that dominate the association."
      )
    ),
    diagnostics = dplyr::bind_rows(
      .diagnostics_tbl(
        check = if (identical(method, "auto")) {
          "Automatic correlation selection"
        } else {
          "Correlation method"
        },
        result = chosen_method,
        value = paste0(
          "x skewness = ", .format_number(sx, 2),
          "; y skewness = ", .format_number(sy, 2)
        ),
        threshold = if (identical(method, "auto")) {
          "Pearson when both absolute skewness values are < 1"
        } else {
          "User-specified method"
        },
        detail = if (identical(method, "auto")) {
          "Marginal symmetry does not establish linearity or monotonicity."
        } else {
          "Method was specified by the user; inspect the scatterplot before interpretation."
        }
      ),
      .diagnostics_tbl(
        check = "Usable observation pairs",
        result = "complete_finite_pairs",
        value = paste0("n = ", n, "; excluded = ", n_excluded),
        threshold = "At least 3 complete finite pairs",
        detail = "Pairs with a missing or non-finite value in either variable were excluded."
      )
    ),
    denominators = .denominators_tbl(
      variable = paste0(x_name, " + ", y_name),
      group = "Complete pairs",
      n_total = length(x_var),
      n_nonmissing = n,
      n_missing = n_excluded,
      numerator = NA_real_,
      denominator = n,
      rule = "Complete finite observation pairs"
    ),
    notes = c(
      "Pearson when both absolute sample skewness values are below 1; otherwise Spearman in auto mode.",
      paste0(
        "Inspect a scatterplot: Pearson requires an approximately linear ",
        "relationship; Spearman requires a monotonic relationship."
      ),
      "Correlation inference assumes independent observation pairs and no dominating influential observations.",
      paste0("Analysis used ", n, " complete finite pairs; ", n_excluded, " pairs were excluded.")
    ),
    call = match.call()
  )

  class(result) <- c("gt_correlation", "gtstats", "list")
  result
}
