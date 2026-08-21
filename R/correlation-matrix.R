#' Correlation analysis for one pair or several continuous variables
#'
#' `correlation()` analyses either one prespecified pair (`x` and `y`) or a
#' correlation matrix (`vars`). Matrix mode uses one method throughout, retains
#' pairwise sample sizes and inferential results in `$summary`, and prints a
#' compact publication-ready matrix. Use [plot_correlation()] for a shaded
#' heatmap of a matrix result.
#'
#' In automatic matrix mode, Pearson correlation is used only when every
#' selected variable has absolute sample skewness below 1; otherwise Spearman
#' correlation is used throughout. This is transparent descriptive guidance,
#' not proof of linearity or monotonicity. Inspect the matrix heatmap and
#' relevant pairwise plots before interpretation.
#'
#' @param data A data frame.
#' @param x,y Two continuous variables supplied as bare names or character
#'   strings. Omit these when using `vars`.
#' @param vars Optional vector of at least two continuous variables, supplied as
#'   `c(age, weight, outcome)` or a character vector.
#' @param method Correlation method: `"auto"`, `"pearson"`, or `"spearman"`.
#' @param triangle Matrix display: `"lower"`, `"upper"`, or `"full"`.
#' @param order Variable order in matrix mode: `"input"` preserves the order in
#'   `vars`, `"alphabetical"` orders display labels, and `"cluster"` places
#'   variables with similar absolute correlation patterns together.
#' @param show_diagonal Logical; show self-correlations on the diagonal.
#' @param display Matrix cell content: correlation `"estimate"`,
#'   `"estimate_p"`, `"estimate_n"`, `"estimate_p_n"`, or `"estimate_ci"`.
#'   Confidence intervals unavailable
#'   from the selected method are shown as an em dash in the tidy result and
#'   omitted from the matrix cell.
#' @param shade Logical; apply coefficient-based shading to the publication
#'   matrix. This affects rendering, not `$summary`.
#' @param missing Matrix missing-data rule. Currently `"pairwise"`: each
#'   coefficient uses all complete finite observations for that pair.
#' @param adjust Multiplicity adjustment for matrix p-values: `"none"`,
#'   `"holm"`, `"bonferroni"`, or `"BH"`.
#' @param conf.level Confidence level for intervals.
#' @param digits Number of decimal places used for display.
#' @param format Output format: `"table"` (default) or a plain console
#'   `"tibble"`.
#'
#' @return A `gt_correlation` object. Matrix results additionally inherit from
#'   `gt_correlation_matrix` and contain a tidy pair-level `$summary`.
#' @examples
#' correlation(mtcars, x = mpg, y = wt)
#' correlation(mtcars, vars = c(mpg, disp, hp, wt))
#' plot_correlation(correlation(mtcars, vars = c(mpg, disp, hp, wt)))
#' @export
correlation <- function(
    data,
    x = NULL,
    y = NULL,
    method = c("auto", "pearson", "spearman"),
    conf.level = 0.95,
    digits = 2,
    vars = NULL,
    triangle = c("lower", "upper", "full"),
    order = c("input", "alphabetical", "cluster"),
    show_diagonal = TRUE,
    display = c("estimate", "estimate_p", "estimate_n", "estimate_p_n", "estimate_ci"),
    shade = TRUE,
    missing = c("pairwise"),
    adjust = c("none", "holm", "bonferroni", "BH"),
    format = c("table", "tibble")
) {
  format <- match.arg(format)
  method <- match.arg(method)
  triangle <- match.arg(triangle)
  order <- match.arg(order)
  display <- match.arg(display)
  missing <- match.arg(missing)
  adjust <- match.arg(adjust)
  .validate_flag(shade, "shade")
  .validate_flag(show_diagonal, "show_diagonal")

  vars_expr <- substitute(vars)
  matrix_mode <- !identical(vars_expr, quote(NULL))
  if (matrix_mode) {
    if (!identical(substitute(x), quote(NULL)) ||
        !identical(substitute(y), quote(NULL))) {
      stop("Use either `x` and `y`, or `vars`; do not supply both.", call. = FALSE)
    }
    vars_names <- unique(.resolve_vars_arg(vars_expr, env = parent.frame()))
    result <- .correlation_matrix(
      data, vars_names, method, triangle, order, show_diagonal, display, shade, missing, adjust,
      conf.level, digits, data_name = deparse(substitute(data)),
      matched_call = match.call()
    )
    if (identical(format, "tibble")) return(result$table)
    return(result)
  }

  if (identical(substitute(x), quote(NULL)) ||
      identical(substitute(y), quote(NULL))) {
    stop("Supply both `x` and `y`, or supply `vars` for a matrix.", call. = FALSE)
  }
  x_name <- .resolve_var_arg(substitute(x), env = parent.frame())
  y_name <- .resolve_var_arg(substitute(y), env = parent.frame())
  result <- .correlation_pair(data, x_name, y_name, method, conf.level, digits)
  if (identical(format, "tibble")) return(result$table)
  result
}

.correlation_matrix <- function(data, vars, method, triangle, order,
                                show_diagonal, display, shade,
                                missing, adjust, conf.level, digits,
                                data_name, matched_call) {
  if (!is.data.frame(data)) stop("`data` must be a data.frame.", call. = FALSE)
  .validate_conf_level(conf.level)
  .validate_digits(digits)
  if (length(vars) < 2L) stop("`vars` must contain at least two variables.", call. = FALSE)
  absent <- setdiff(vars, names(data))
  if (length(absent)) stop(paste0("`", absent[[1L]], "` was not found in `data`."), call. = FALSE)
  bad <- vars[vapply(vars, function(v) .detect_type(data[[v]]) != "continuous", logical(1))]
  if (length(bad)) stop(paste0("`", bad[[1L]], "` is not a continuous variable."), call. = FALSE)

  skew <- vapply(vars, function(v) {
    z <- data[[v]][is.finite(data[[v]])]
    s <- stats::sd(z)
    if (length(z) < 3L || is.na(s) || s == 0) return(if (s == 0) 0 else NA_real_)
    mean((z - mean(z))^3) / s^3
  }, numeric(1))
  chosen <- if (method == "auto") {
    if (all(!is.na(skew)) && all(abs(skew) < 1)) "pearson" else "spearman"
  } else method

  pairs <- utils::combn(vars, 2L, simplify = FALSE)
  results <- lapply(pairs, function(pair) {
    ans <- .correlation_pair(data, pair[[1L]], pair[[2L]], chosen, conf.level, digits)
    ans$summary
  })
  summary <- dplyr::bind_rows(results)
  summary$method_requested <- method
  summary$p_adjusted <- if (adjust == "none") summary$p_value else stats::p.adjust(summary$p_value, method = adjust)
  summary$adjust_method <- adjust

  labels <- vapply(vars, function(v) .get_var_label(data, v), character(1))
  if (identical(order, "alphabetical")) {
    vars <- vars[base::order(tolower(labels), seq_along(labels))]
    labels <- labels[vars]
  } else if (identical(order, "cluster")) {
    coefficient_matrix <- diag(1, nrow = length(vars), ncol = length(vars))
    dimnames(coefficient_matrix) <- list(vars, vars)
    for (i in seq_len(nrow(summary))) {
      coefficient_matrix[summary$x[[i]], summary$y[[i]]] <- summary$estimate[[i]]
      coefficient_matrix[summary$y[[i]], summary$x[[i]]] <- summary$estimate[[i]]
    }
    clustered <- stats::hclust(stats::as.dist(1 - abs(coefficient_matrix)))$order
    vars <- vars[clustered]
    labels <- labels[vars]
  }
  display_labels <- make.unique(labels, sep = " \u2014 ")
  fmt <- function(z) ifelse(is.na(z), "\u2014", sprintf(paste0("%.", digits, "f"), z))
  fmt_p <- function(p) {
    threshold <- 10^(-digits)
    ifelse(is.na(p), "\u2014", ifelse(p < threshold,
      paste0("<", formatC(threshold, format = "f", digits = digits)),
      sprintf(paste0("%.", digits, "f"), p)))
  }
  cells <- matrix("", nrow = length(vars), ncol = length(vars), dimnames = list(vars, vars))
  diag(cells) <- if (isTRUE(show_diagonal)) "1.00" else ""
  for (i in seq_len(nrow(summary))) {
    a <- match(summary$x[[i]], vars); b <- match(summary$y[[i]], vars)
    value <- fmt(summary$estimate[[i]])
    if (display == "estimate_p") value <- paste0(value, "\np = ", fmt_p(summary$p_adjusted[[i]]))
    if (display == "estimate_n") value <- paste0(value, "\nn = ", summary$n[[i]])
    if (display == "estimate_p_n") value <- paste0(
      value, "\np = ", fmt_p(summary$p_adjusted[[i]]), "\nn = ", summary$n[[i]]
    )
    if (display == "estimate_ci" && !is.na(summary$conf_low[[i]])) {
      value <- paste0(value, "\n(", fmt(summary$conf_low[[i]]), " to ", fmt(summary$conf_high[[i]]), ")")
    }
    cells[a, b] <- cells[b, a] <- value
  }
  if (triangle == "lower") cells[upper.tri(cells)] <- ""
  if (triangle == "upper") cells[lower.tri(cells)] <- ""
  table <- tibble::as_tibble(cbind(Variable = unname(labels), cells), .name_repair = "minimal")
  names(table) <- c("Variable", unname(display_labels))

  n_total <- nrow(data)
  denominators <- dplyr::bind_rows(lapply(seq_len(nrow(summary)), function(i) {
    .denominators_tbl(
      variable = paste0(summary$x[[i]], " + ", summary$y[[i]]),
      group = "Complete pairs", n_total = n_total,
      n_nonmissing = summary$n[[i]], n_missing = summary$n_excluded[[i]],
      numerator = NA_real_, denominator = summary$n[[i]],
      rule = "Pairwise complete finite observations"
    )
  }))
  rule <- if (method == "auto") {
    if (chosen == "pearson") "All selected variables had absolute sample skewness below 1; Pearson was used throughout."
    else "At least one selected variable had absolute sample skewness of 1 or greater (or could not be assessed); Spearman was used throughout."
  } else paste0("User specified ", chosen, " correlation throughout.")

  out <- list(
    inputs = list(data_name = data_name, vars = vars, method = method,
      triangle = triangle, order = order, show_diagonal = show_diagonal,
      display = display, shade = shade, missing = missing,
      adjust = adjust, conf.level = conf.level, digits = digits),
    summary = summary, table = table,
    method = list(method_used = chosen, selection_rule = rule,
      variable_skewness = skew, display_labels = stats::setNames(display_labels, vars)),
    assumptions = .assumptions_tbl(
      assumption = c("Independent observation pairs", if (chosen == "pearson") "Approximately linear relationships" else "Monotonic relationships", "No dominating influential observations"),
      status = rep("user_check", 3), result = rep("not_checked", 3),
      detail = c("Confirm independence from the study design.", "Inspect relevant pairwise plots before interpretation.", "Inspect plots for observations that dominate associations.")
    ),
    diagnostics = .diagnostics_tbl(
      check = "Matrix correlation selection", result = chosen,
      value = paste0(names(skew), " = ", .format_number(skew, 2), collapse = "; "),
      threshold = if (method == "auto") "Pearson only when every absolute skewness is < 1" else "User-specified method",
      detail = "One method is used throughout; marginal shape does not establish linearity or monotonicity."
    ),
    denominators = denominators,
    notes = c(rule,
      "Each coefficient uses pairwise complete finite observations; sample sizes can differ between pairs.",
      if (adjust == "none") "P-values are unadjusted." else paste0("Matrix p-values use the ", adjust, " multiplicity adjustment."),
      "Correlation does not imply causation. Inspect relevant pairwise plots before interpretation."),
    call = matched_call
  )
  class(out) <- c("gt_correlation_matrix", "gt_correlation", "gtstats", "list")
  out
}
