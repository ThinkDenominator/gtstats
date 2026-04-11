#' Plot grouped comparisons
#'
#' Create a simple comparison plot for teaching and exploratory
#' analysis.
#'
#' For continuous outcomes, the function draws a boxplot with optional
#' jittered points. For categorical outcomes, it draws a grouped bar
#' chart of counts or within-group proportions. An optional p-value can
#' be added using [compare_groups()].
#'
#' @param data A data.frame.
#' @param outcome Outcome variable. Can be supplied as a bare name or
#'   as a character string.
#' @param group Grouping variable. Can be supplied as a bare name or as
#'   a character string.
#' @param type Plot type. One of `"auto"`, `"box"`, or `"bar"`.
#' @param proportions Logical; for categorical outcomes, whether to
#'   plot within-group proportions instead of counts.
#' @param jitter Logical; for continuous outcomes, whether to add
#'   jittered points.
#' @param show_p Logical; whether to add a p-value annotation using
#'   [compare_groups()].
#' @param title Optional plot title.
#' @param xlab Optional x-axis label.
#' @param ylab Optional y-axis label.
#' @param legend_title Optional legend title.
#' @param quiet Logical; suppress messages.
#'
#' @return A `ggplot` object.
#'
#' @examples
#' plot_compare(mtcars, outcome = mpg, group = am)
#'
#' plot_compare(
#'   mtcars,
#'   outcome = mpg,
#'   group = am,
#'   show_p = TRUE
#' )
#'
#' plot_compare(
#'   mtcars,
#'   outcome = vs,
#'   group = am,
#'   type = "bar",
#'   proportions = TRUE
#' )
#'
#' @export
plot_compare <- function(
    data,
    outcome,
    group,
    type = c("auto", "box", "bar"),
    proportions = TRUE,
    jitter = TRUE,
    show_p = FALSE,
    title = NULL,
    xlab = NULL,
    ylab = NULL,
    legend_title = NULL,
    quiet = FALSE
) {
  type <- match.arg(type)

  # Validate input data
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }

  # Resolve outcome and group names from bare or character input
  outcome_expr <- substitute(outcome)
  group_expr <- substitute(group)

  outcome_eval <- tryCatch(
    eval(outcome_expr, parent.frame()),
    error = function(e) NULL
  )
  group_eval <- tryCatch(
    eval(group_expr, parent.frame()),
    error = function(e) NULL
  )

  outcome_name <- if (is.character(outcome_eval) &&
                      length(outcome_eval) == 1) {
    outcome_eval
  } else if (is.symbol(outcome_expr)) {
    deparse(outcome_expr)
  } else if (is.character(outcome_expr) &&
             length(outcome_expr) == 1) {
    outcome_expr[1]
  } else {
    deparse(outcome_expr)
  }

  group_name <- if (is.character(group_eval) &&
                    length(group_eval) == 1) {
    group_eval
  } else if (is.symbol(group_expr)) {
    deparse(group_expr)
  } else if (is.character(group_expr) &&
             length(group_expr) == 1) {
    group_expr[1]
  } else {
    deparse(group_expr)
  }

  if (!outcome_name %in% names(data)) {
    stop("`outcome` was not found in `data`.", call. = FALSE)
  }

  if (!group_name %in% names(data)) {
    stop("`group` was not found in `data`.", call. = FALSE)
  }

  if (outcome_name == group_name) {
    stop(
      "`outcome` and `group` must be different variables.",
      call. = FALSE
    )
  }

  # Detect variable types
  outcome_var <- data[[outcome_name]]
  group_var <- data[[group_name]]

  outcome_type <- .detect_type(outcome_var)
  group_type <- .detect_type(group_var)

  if (group_type == "continuous") {
    stop(
      "`group` should be a categorical, binary, or ordinal variable.",
      call. = FALSE
    )
  }

  # Keep complete cases only
  keep <- !is.na(outcome_var) & !is.na(group_var)
  dat <- data[keep, , drop = FALSE]

  if (nrow(dat) == 0) {
    stop(
      "No complete cases available for `outcome` and `group`.",
      call. = FALSE
    )
  }

  dat[[group_name]] <- as.factor(dat[[group_name]])

  # Choose plot type automatically when requested
  if (type == "auto") {
    type <- if (outcome_type == "continuous") "box" else "bar"
  }

  if (type == "box" && outcome_type != "continuous") {
    stop(
      "`type = \"box\"` requires a continuous outcome.",
      call. = FALSE
    )
  }

  if (type == "bar" &&
      !outcome_type %in% c("binary", "categorical", "ordinal")) {
    stop(
      paste0(
        "`type = \"bar\"` requires a categorical, binary, ",
        "or ordinal outcome."
      ),
      call. = FALSE
    )
  }

  # Require ggplot2
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop(
      paste0(
        "Package `ggplot2` is required for `plot_compare()`. ",
        "Please install it."
      ),
      call. = FALSE
    )
  }

  outcome_label <- .get_var_label(data, outcome_name)
  group_label <- .get_var_label(data, group_name)

  if (is.null(xlab)) {
    xlab <- group_label
  }

  if (is.null(legend_title)) {
    legend_title <- outcome_label
  }

  # Format p-value label for annotation
  .fmt_plot_p <- function(p) {
    if (is.na(p)) {
      return("p = NA")
    }
    if (p < 0.001) {
      return("p < 0.001")
    }
    paste0("p = ", sprintf("%.3f", p))
  }

  # Safely obtain p-value text from compare_groups()
  .safe_compare_p <- function(data, outcome_name, group_name) {
    cmp <- tryCatch(
      compare_groups(
        data = data,
        outcome = outcome_name,
        group = group_name,
        quiet = TRUE
      ),
      error = function(e) NULL
    )

    if (is.null(cmp) ||
        is.null(cmp$inferential) ||
        nrow(cmp$inferential) == 0) {
      return(NULL)
    }

    if (!"p_value" %in% names(cmp$inferential)) {
      return(NULL)
    }

    .fmt_plot_p(cmp$inferential$p_value[1])
  }

  # Continuous outcome: boxplot
  if (type == "box") {
    if (is.null(ylab)) {
      ylab <- outcome_label
    }

    p <- ggplot2::ggplot(
      dat,
      ggplot2::aes(
        x = .data[[group_name]],
        y = .data[[outcome_name]]
      )
    ) +
      ggplot2::geom_boxplot(outlier.shape = NA)

    if (isTRUE(jitter)) {
      p <- p +
        ggplot2::geom_jitter(width = 0.12, alpha = 0.7)
    }

    p <- p +
      ggplot2::labs(
        title = title,
        x = xlab,
        y = ylab
      ) +
      ggplot2::theme_minimal()

    if (isTRUE(show_p)) {
      p_text <- .safe_compare_p(
        data = data,
        outcome_name = outcome_name,
        group_name = group_name
      )

      if (!is.null(p_text)) {
        y_max <- max(dat[[outcome_name]], na.rm = TRUE)
        y_rng <- diff(range(dat[[outcome_name]], na.rm = TRUE))

        if (is.na(y_rng) || y_rng == 0) {
          y_rng <- 1
        }

        p <- p +
          ggplot2::annotate(
            "text",
            x = Inf,
            y = y_max + 0.05 * y_rng,
            label = p_text,
            hjust = 1.1,
            vjust = 0,
            size = 4
          ) +
          ggplot2::coord_cartesian(clip = "off")
      }
    }

    if (!quiet) {
      message(
        "Continuous outcome detected: showing boxplot by group."
      )
    }

    return(p)
  }

  # Categorical outcome: bar plot
  dat[[outcome_name]] <- as.factor(dat[[outcome_name]])

  if (is.null(ylab)) {
    ylab <- if (isTRUE(proportions)) "Proportion" else "Count"
  }

  # Proportion bars
  if (isTRUE(proportions)) {
    count_df <- dplyr::count(
      dat,
      .data[[group_name]],
      .data[[outcome_name]],
      name = "n"
    )

    names(count_df)[1:2] <- c("group", "outcome")

    plot_df <- count_df |>
      dplyr::group_by(.data$group) |>
      dplyr::mutate(prop = .data$n / sum(.data$n)) |>
      dplyr::ungroup()

    p <- ggplot2::ggplot(
      plot_df,
      ggplot2::aes(
        x = .data$group,
        y = .data$prop,
        fill = .data$outcome
      )
    ) +
      ggplot2::geom_col(position = "fill") +
      ggplot2::labs(
        title = title,
        x = xlab,
        y = ylab,
        fill = legend_title
      ) +
      ggplot2::theme_minimal()

    if (isTRUE(show_p)) {
      p_text <- .safe_compare_p(
        data = data,
        outcome_name = outcome_name,
        group_name = group_name
      )

      if (!is.null(p_text)) {
        p <- p +
          ggplot2::annotate(
            "text",
            x = Inf,
            y = 1.05,
            label = p_text,
            hjust = 1.1,
            vjust = 0,
            size = 4
          ) +
          ggplot2::coord_cartesian(
            ylim = c(0, 1.1),
            clip = "off"
          )
      }
    }

    if (!quiet) {
      message(
        paste0(
          "Categorical outcome detected: showing within-group ",
          "proportions."
        )
      )
    }

    return(p)
  }

  # Count bars
  p <- ggplot2::ggplot(
    dat,
    ggplot2::aes(
      x = .data[[group_name]],
      fill = .data[[outcome_name]]
    )
  ) +
    ggplot2::geom_bar(position = "dodge") +
    ggplot2::labs(
      title = title,
      x = xlab,
      y = ylab,
      fill = legend_title
    ) +
    ggplot2::theme_minimal()

  if (isTRUE(show_p)) {
    p_text <- .safe_compare_p(
      data = data,
      outcome_name = outcome_name,
      group_name = group_name
    )

    if (!is.null(p_text)) {
      max_count <- max(
        table(dat[[group_name]], dat[[outcome_name]]),
        na.rm = TRUE
      )

      p <- p +
        ggplot2::annotate(
          "text",
          x = Inf,
          y = max_count * 1.05,
          label = p_text,
          hjust = 1.1,
          vjust = 0,
          size = 4
        ) +
        ggplot2::coord_cartesian(
          ylim = c(0, max_count * 1.1),
          clip = "off"
        )
    }
  }

  if (!quiet) {
    message("Categorical outcome detected: showing counts by group.")
  }

  p
}
