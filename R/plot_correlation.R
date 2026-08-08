#' Plot the relationship between two continuous variables
#'
#' Create a publication-ready scatterplot that is aligned with
#' [correlation()]. The minimal call is `plot_correlation(data, x, y)`.
#' Incomplete pairs are excluded and the analysed number of complete pairs is
#' shown in the caption.
#'
#' With `trend = "auto"`, a linear trend is used for Pearson correlation and a
#' smooth trend for Spearman correlation. Set `trend = "none"` to display the
#' observations alone. When `show_correlation = TRUE`, the caption reports the
#' same method, coefficient, confidence interval when available, and p-value as
#' [correlation()]. The returned object is a standard `ggplot`, so ordinary
#' ggplot2 layers can be added.
#'
#' @param data A data frame.
#' @param x,y Continuous variables, supplied as bare names or character strings.
#' @param method Correlation method: `"auto"`, `"pearson"`, or `"spearman"`.
#' @param trend Fitted trend: `"auto"`, `"linear"`, `"smooth"`, or `"none"`.
#' @param show_ci Logical; display the confidence band around a fitted trend.
#' @param show_correlation Logical; report the correlation result in the
#'   caption.
#' @param conf.level Confidence level passed to [correlation()].
#' @param digits Number of decimal places used in the correlation annotation.
#' @param point_color,line_color Colours used for observations and the trend.
#' @param base_size Base font size.
#' @param title,caption Optional plot title and caption.
#' @param xlab,ylab Optional axis labels.
#'
#' @return A `ggplot` object.
#'
#' @examples
#' plot_correlation(mtcars, x = mpg, y = wt)
#'
#' plot_correlation(
#'   mtcars,
#'   x = mpg,
#'   y = wt,
#'   show_correlation = TRUE
#' )
#'
#' @export
plot_correlation <- function(
    data,
    x,
    y,
    method = c("auto", "pearson", "spearman"),
    trend = c("auto", "linear", "smooth", "none"),
    show_ci = TRUE,
    show_correlation = FALSE,
    conf.level = 0.95,
    digits = 2,
    point_color = "#4472C4",
    line_color = "#ED7D31",
    base_size = 14,
    title = NULL,
    caption = NULL,
    xlab = NULL,
    ylab = NULL
) {
  method <- match.arg(method)
  trend <- match.arg(trend)
  .validate_conf_level(conf.level)
  .validate_digits(digits)

  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }
  for (argument in c("show_ci", "show_correlation")) {
    value <- get(argument)
    if (!is.logical(value) || length(value) != 1L || is.na(value)) {
      stop(paste0("`", argument, "` must be TRUE or FALSE."), call. = FALSE)
    }
  }
  if (!is.numeric(base_size) || length(base_size) != 1L ||
      is.na(base_size) || base_size <= 0) {
    stop("`base_size` must be a single positive number.", call. = FALSE)
  }
  for (argument in c("point_color", "line_color")) {
    value <- get(argument)
    if (!is.character(value) || length(value) != 1L ||
        is.na(value) || !nzchar(value)) {
      stop(
        paste0("`", argument, "` must be a single colour."),
        call. = FALSE
      )
    }
  }

  x_name <- .resolve_var_arg(substitute(x), env = parent.frame())
  y_name <- .resolve_var_arg(substitute(y), env = parent.frame())
  missing_names <- setdiff(c(x_name, y_name), names(data))
  if (length(missing_names) > 0L) {
    stop(
      paste0("`", missing_names[[1L]], "` was not found in `data`."),
      call. = FALSE
    )
  }
  if (identical(x_name, y_name)) {
    stop("`x` and `y` must be different variables.", call. = FALSE)
  }

  analysis <- correlation(
    data = data,
    x = x_name,
    y = y_name,
    method = method,
    conf.level = conf.level,
    digits = digits
  )
  result <- analysis$summary[1L, , drop = FALSE]
  chosen_method <- analysis$method$method_used
  if (identical(trend, "auto")) {
    trend <- if (identical(chosen_method, "pearson")) "linear" else "smooth"
  }

  keep <- is.finite(data[[x_name]]) & is.finite(data[[y_name]])
  plot_data <- data[keep, c(x_name, y_name), drop = FALSE]

  fmt_num <- function(value) {
    sprintf(paste0("%.", digits, "f"), value)
  }
  fmt_p <- function(value) {
    threshold <- 10^(-digits)
    if (value < threshold) {
      paste0("< ", formatC(threshold, format = "f", digits = digits))
    } else {
      paste0("= ", fmt_num(value))
    }
  }

  analysis_caption <- paste0("Complete pairs: N = ", result$n[[1L]])
  if (isTRUE(show_correlation)) {
    coefficient <- paste0(
      result$estimate_type[[1L]],
      " = ",
      fmt_num(result$estimate[[1L]])
    )
    if (!is.na(result$conf_low[[1L]]) &&
        !is.na(result$conf_high[[1L]])) {
      coefficient <- paste0(
        coefficient,
        " (",
        .conf_level_label(conf.level),
        " ",
        fmt_num(result$conf_low[[1L]]),
        " to ",
        fmt_num(result$conf_high[[1L]]),
        ")"
      )
    }
    analysis_caption <- paste0(
      result$method_used[[1L]],
      ": ",
      coefficient,
      ", p ",
      fmt_p(result$p_value[[1L]]),
      "; complete pairs: N = ",
      result$n[[1L]]
    )
  }
  final_caption <- if (is.null(caption) || !nzchar(caption)) {
    analysis_caption
  } else {
    paste(caption, analysis_caption, sep = " | ")
  }
  final_caption <- paste(strwrap(final_caption, width = 65), collapse = "\n")

  if (is.null(xlab)) xlab <- .get_var_label(data, x_name)
  if (is.null(ylab)) ylab <- .get_var_label(data, y_name)

  p <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = .data[[x_name]], y = .data[[y_name]])
  ) +
    ggplot2::geom_point(
      colour = point_color,
      size = 2.4,
      alpha = 0.72
    )

  if (identical(trend, "linear")) {
    p <- p + ggplot2::geom_smooth(
      method = "lm",
      formula = y ~ x,
      se = show_ci,
      colour = line_color,
      fill = line_color,
      linewidth = 0.8,
      alpha = 0.16
    )
  } else if (identical(trend, "smooth")) {
    p <- p + ggplot2::geom_smooth(
      method = "loess",
      formula = y ~ x,
      se = show_ci,
      colour = line_color,
      fill = line_color,
      linewidth = 0.8,
      alpha = 0.16
    )
  }

  p <- p +
    ggplot2::labs(
      title = title,
      caption = final_caption,
      x = xlab,
      y = ylab
    ) +
    ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(face = "bold"),
      axis.title = ggplot2::element_text(face = "plain")
    )

  attr(p, "source") <- "plot_correlation"
  attr(p, "correlation_method") <- chosen_method
  attr(p, "trend") <- trend
  attr(p, "n_complete") <- result$n[[1L]]
  p
}
