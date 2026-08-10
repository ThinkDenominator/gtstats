#' Plot a group comparison
#'
#' Create a publication-ready comparison plot using a sensible visual selected
#' from the outcome type and study design.
#'
#' The minimal call is `plot_compare(data, outcome, by)`. Continuous outcomes
#' are shown as boxplots with individual observations, categorical outcomes as
#' stacked within-group proportions, and paired continuous outcomes as
#' participant-level connected observations. The returned object is a standard
#' `ggplot` and can be customized with ordinary ggplot2 layers.
#'
#' When `show_p = TRUE`, the annotation is obtained from [compare_groups()] with
#' the same `test`, `var_equal`, `paired`, and `id` settings. The test name is always shown
#' with the p-value. The annotation and plotted denominators use the same
#' complete observations; non-finite continuous values are excluded.
#'
#' @param data A data frame.
#' @param outcome Outcome variable, supplied as a bare name or character string.
#' @param by Categorical grouping variable, supplied as a bare name or character
#'   string.
#' @param paired Logical; whether the continuous measurements are paired.
#' @param id Participant identifier required when `paired = TRUE`.
#' @param type Plot type: `"auto"`, `"box"`, or `"bar"`.
#' @param display Categorical display: within-group `"proportion"` or `"count"`.
#' @param show_points Logical; show individual observations for continuous data.
#' @param show_p Logical; add the selected test and p-value as a plot caption.
#' @param test Test passed to [compare_groups()] when `show_p = TRUE`.
#' @param var_equal Logical; passed to [compare_groups()] when `show_p = TRUE`.
#'   With `test = "auto"`, `TRUE` selects the equal-variance parametric route
#'   for independent, non-skewed continuous outcomes. Default `FALSE` retains
#'   Welch methods; no variance test is performed.
#' @param palette Optional character vector of colours. It must contain at least
#'   one colour per displayed group or outcome level.
#' @param base_size Base font size.
#' @param title,caption Optional plot title and caption.
#' @param xlab,ylab Optional axis labels.
#' @param legend_title Optional legend title.
#'
#' @return A `ggplot` object.
#'
#' @examples
#' plot_compare(mtcars, outcome = mpg, by = am)
#'
#' plot_compare(
#'   mtcars,
#'   outcome = vs,
#'   by = am,
#'   display = "proportion",
#'   show_p = TRUE
#' )
#'
#' @export
plot_compare <- function(
    data,
    outcome,
    by,
    paired = FALSE,
    id = NULL,
    type = c("auto", "box", "bar"),
    display = c("proportion", "count"),
    show_points = TRUE,
    show_p = FALSE,
    test = c(
      "auto", "t_test", "welch_t", "wilcox",
      "anova", "welch_anova", "kruskal", "chisq", "fisher", "mcnemar"
    ),
    var_equal = FALSE,
    palette = NULL,
    base_size = 14,
    title = NULL,
    caption = NULL,
    xlab = NULL,
    ylab = NULL,
    legend_title = NULL
) {
  type <- match.arg(type)
  display <- match.arg(display)
  test <- match.arg(test)
  .validate_flag(var_equal, "var_equal")

  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }
  if (!is.logical(paired) || length(paired) != 1L || is.na(paired)) {
    stop("`paired` must be TRUE or FALSE.", call. = FALSE)
  }
  if (!is.logical(show_points) || length(show_points) != 1L ||
      is.na(show_points)) {
    stop("`show_points` must be TRUE or FALSE.", call. = FALSE)
  }
  if (!is.logical(show_p) || length(show_p) != 1L || is.na(show_p)) {
    stop("`show_p` must be TRUE or FALSE.", call. = FALSE)
  }
  if (!is.numeric(base_size) || length(base_size) != 1L ||
      is.na(base_size) || base_size <= 0) {
    stop("`base_size` must be a single positive number.", call. = FALSE)
  }

  outcome_name <- .resolve_var_arg(substitute(outcome), env = parent.frame())
  by_name <- .resolve_var_arg(substitute(by), env = parent.frame())
  id_name <- .resolve_var_arg(
    substitute(id),
    env = parent.frame(),
    allow_null = TRUE
  )

  missing_names <- setdiff(c(outcome_name, by_name), names(data))
  if (length(missing_names) > 0L) {
    stop(
      paste0(
        "`", missing_names[[1L]], "` was not found in `data`."
      ),
      call. = FALSE
    )
  }
  if (identical(outcome_name, by_name)) {
    stop("`outcome` and `by` must be different variables.", call. = FALSE)
  }
  if (isTRUE(paired) && is.null(id_name)) {
    stop("`id` is required when `paired = TRUE`.", call. = FALSE)
  }
  if (!is.null(id_name) && !id_name %in% names(data)) {
    stop("`id` was not found in `data`.", call. = FALSE)
  }

  outcome_type <- .detect_type(data[[outcome_name]])
  by_type <- .detect_type(data[[by_name]])
  if (identical(by_type, "continuous")) {
    stop(
      "`by` should be a categorical, binary, or ordinal variable.",
      call. = FALSE
    )
  }
  if (isTRUE(paired) && !identical(outcome_type, "continuous")) {
    stop(
      "Paired plotting currently supports continuous outcomes only.",
      call. = FALSE
    )
  }

  if (identical(type, "auto")) {
    type <- if (identical(outcome_type, "continuous")) "box" else "bar"
  }
  if (identical(type, "box") && !identical(outcome_type, "continuous")) {
    stop("`type = \"box\"` requires a continuous outcome.", call. = FALSE)
  }
  if (identical(type, "bar") &&
      !outcome_type %in% c("binary", "categorical", "ordinal")) {
    stop(
      paste0(
        "`type = \"bar\"` requires a categorical, binary, ",
        "or ordinal outcome."
      ),
      call. = FALSE
    )
  }

  required <- c(outcome_name, by_name, if (isTRUE(paired)) id_name)
  keep <- stats::complete.cases(data[, required, drop = FALSE])
  if (identical(outcome_type, "continuous")) {
    keep <- keep & is.finite(data[[outcome_name]])
  }
  dat <- data[keep, , drop = FALSE]
  if (nrow(dat) == 0L) {
    stop(
      "No complete cases available for the requested plot.",
      call. = FALSE
    )
  }

  by_levels <- if (is.factor(data[[by_name]])) {
    levels(data[[by_name]])
  } else {
    unique(as.character(dat[[by_name]]))
  }
  by_levels <- by_levels[by_levels %in% as.character(dat[[by_name]])]
  dat[[by_name]] <- factor(as.character(dat[[by_name]]), levels = by_levels)
  if (nlevels(dat[[by_name]]) < 2L) {
    stop("`by` must contain at least two observed groups.", call. = FALSE)
  }

  default_palette <- c(
    "#4472C4", "#ED7D31", "#70AD47", "#A5A5A5",
    "#FFC000", "#5B9BD5", "#8064A2", "#9E480E"
  )
  colours_for <- function(n) {
    values <- palette %||% default_palette
    if (!is.character(values) || length(values) < n ||
        any(is.na(values)) || any(!nzchar(values))) {
      stop(
        "`palette` must contain at least one valid colour per displayed level.",
        call. = FALSE
      )
    }
    values[seq_len(n)]
  }
  publication_theme <- function() {
    ggplot2::theme_minimal(base_size = base_size) +
      ggplot2::theme(
        panel.grid.major.x = ggplot2::element_blank(),
        panel.grid.minor = ggplot2::element_blank(),
        plot.title = ggplot2::element_text(face = "bold"),
        axis.title = ggplot2::element_text(face = "plain"),
        legend.position = "right"
      )
  }
  fmt_p <- function(p) {
    if (is.na(p)) return("p = NA")
    if (p < 0.001) return("p < 0.001")
    paste0("p = ", sprintf("%.3f", p))
  }

  comparison_caption <- caption
  if (isTRUE(show_p)) {
    compare_args <- list(
      # Use precisely the observations displayed in the plot. This keeps
      # plotted group Ns and the optional inference annotation aligned.
      data = dat,
      variable = outcome_name,
      group = by_name,
      paired = paired,
      test = test,
      var_equal = var_equal
    )
    if (isTRUE(paired)) compare_args$id <- id_name
    comparison <- tryCatch(
      do.call(compare_groups, compare_args),
      error = function(e) {
        stop(
          paste0("Unable to add the requested p-value: ", conditionMessage(e)),
          call. = FALSE
        )
      }
    )
    test_caption <- paste0(
      comparison$inferential$test_used[[1L]],
      ", ",
      fmt_p(comparison$inferential$p_value[[1L]])
    )
    comparison_caption <- if (is.null(caption) || !nzchar(caption)) {
      test_caption
    } else {
      paste(caption, test_caption, sep = " | ")
    }
  }

  outcome_label <- .get_var_label(data, outcome_name)
  by_label <- .get_var_label(data, by_name)
  if (is.null(xlab)) xlab <- by_label

  if (identical(type, "box")) {
    if (is.null(ylab)) ylab <- outcome_label

    if (isTRUE(paired)) {
      if (nlevels(dat[[by_name]]) != 2L) {
        stop("Paired plots require exactly two groups.", call. = FALSE)
      }
      duplicate_key <- duplicated(dat[, c(id_name, by_name)]) |
        duplicated(dat[, c(id_name, by_name)], fromLast = TRUE)
      if (any(duplicate_key)) {
        stop(
          "Each `id` must have at most one observation in each group.",
          call. = FALSE
        )
      }
      pair_counts <- table(dat[[id_name]])
      complete_ids <- names(pair_counts)[pair_counts == 2L]
      dat <- dat[as.character(dat[[id_name]]) %in% complete_ids, ,
                 drop = FALSE]
      if (length(complete_ids) < 2L) {
        stop("At least two complete pairs are required.", call. = FALSE)
      }
      group_labels <- stats::setNames(
        paste0(by_levels, "\nN = ", length(complete_ids)),
        by_levels
      )
      p <- ggplot2::ggplot(
        dat,
        ggplot2::aes(
          x = .data[[by_name]],
          y = .data[[outcome_name]],
          group = .data[[id_name]]
        )
      ) +
        ggplot2::geom_line(
          colour = "#A5A5A5",
          linewidth = 0.5,
          alpha = 0.65
        )
      if (isTRUE(show_points)) {
        p <- p + ggplot2::geom_point(
          ggplot2::aes(fill = .data[[by_name]]),
          shape = 21,
          size = 2.5,
          colour = "#3F3F3F",
          stroke = 0.4,
          show.legend = FALSE
        )
      }
      p <- p +
        ggplot2::scale_fill_manual(values = colours_for(2L)) +
        ggplot2::scale_x_discrete(labels = group_labels)
    } else {
      group_n <- table(dat[[by_name]])
      group_labels <- stats::setNames(
        paste0(names(group_n), "\nN = ", as.integer(group_n)),
        names(group_n)
      )
      p <- ggplot2::ggplot(
        dat,
        ggplot2::aes(
          x = .data[[by_name]],
          y = .data[[outcome_name]],
          fill = .data[[by_name]]
        )
      ) +
        ggplot2::geom_boxplot(
          width = 0.58,
          outlier.shape = NA,
          alpha = 0.45,
          colour = "#3F3F3F",
          linewidth = 0.6,
          show.legend = FALSE
        )
      if (isTRUE(show_points)) {
        p <- p + ggplot2::geom_point(
          position = ggplot2::position_jitter(width = 0.10, seed = 1049),
          shape = 21,
          size = 2,
          alpha = 0.65,
          colour = "#3F3F3F",
          stroke = 0.3,
          show.legend = FALSE
        )
      }
      p <- p +
        ggplot2::scale_fill_manual(
          values = colours_for(nlevels(dat[[by_name]]))
        ) +
        ggplot2::scale_x_discrete(labels = group_labels)
    }

    p <- p +
      ggplot2::labs(
        title = title,
        caption = comparison_caption,
        x = xlab,
        y = ylab
      ) +
      publication_theme()
    attr(p, "source") <- "plot_compare"
    attr(p, "plot_type") <- if (paired) "paired" else "box"
    return(p)
  }

  outcome_levels <- if (is.factor(data[[outcome_name]])) {
    levels(data[[outcome_name]])
  } else {
    unique(as.character(dat[[outcome_name]]))
  }
  outcome_levels <- outcome_levels[
    outcome_levels %in% as.character(dat[[outcome_name]])
  ]
  dat[[outcome_name]] <- factor(
    as.character(dat[[outcome_name]]),
    levels = outcome_levels,
    ordered = identical(outcome_type, "ordinal")
  )
  if (is.null(legend_title)) legend_title <- outcome_label
  if (is.null(ylab)) {
    ylab <- if (identical(display, "proportion")) "Proportion" else "Count"
  }

  counts <- as.data.frame(
    table(dat[[by_name]], dat[[outcome_name]]),
    stringsAsFactors = FALSE
  )
  names(counts) <- c("group", "outcome", "n")
  counts$group <- factor(counts$group, levels = by_levels)
  counts$outcome <- factor(
    counts$outcome,
    levels = outcome_levels,
    ordered = identical(outcome_type, "ordinal")
  )
  group_totals <- stats::setNames(
    as.integer(table(dat[[by_name]])),
    names(table(dat[[by_name]]))
  )
  counts$proportion <- counts$n / unname(group_totals[as.character(counts$group)])
  group_labels <- stats::setNames(
    paste0(names(group_totals), "\nN = ", group_totals),
    names(group_totals)
  )
  y_value <- if (identical(display, "proportion")) "proportion" else "n"

  p <- ggplot2::ggplot(
    counts,
    ggplot2::aes(
      x = .data$group,
      y = .data[[y_value]],
      fill = .data$outcome
    )
  ) +
    ggplot2::geom_col(width = 0.72, colour = "white", linewidth = 0.25) +
    ggplot2::scale_fill_manual(
      values = colours_for(length(outcome_levels)),
      drop = FALSE
    ) +
    ggplot2::scale_x_discrete(labels = group_labels) +
    ggplot2::labs(
      title = title,
      caption = comparison_caption,
      x = xlab,
      y = ylab,
      fill = legend_title
    ) +
    publication_theme()
  if (identical(display, "proportion")) {
    p <- p + ggplot2::scale_y_continuous(
      limits = c(0, 1),
      breaks = seq(0, 1, 0.2),
      labels = function(x) paste0(round(100 * x), "%"),
      expand = ggplot2::expansion(mult = c(0, 0.01))
    )
  } else {
    p <- p + ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0, 0.05))
    )
  }
  attr(p, "source") <- "plot_compare"
  attr(p, "plot_type") <- if (identical(outcome_type, "ordinal")) {
    "ordinal_bar"
  } else {
    "bar"
  }
  p
}
