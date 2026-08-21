#' Estimate an effect size
#'
#' Quantify the magnitude of a group difference or association without adding
#' the full hypothesis-test output produced by [compare_groups()].
#' For directional two-group measures, the Contrast column names the grouping
#' variable and reports first group minus second group. Factor order is therefore
#' meaningful. Cramer's V and omnibus measures have no direction.
#'
#' The default `method = "auto"` selects one measure from the outcome and
#' comparison structure:
#' - Hedges' g for two-group parametric comparisons
#' - rank-biserial correlation for two-group rank comparisons
#' - omega-squared for comparisons involving more than two continuous groups
#' - epsilon-squared when a multi-group rank method is requested
#' - Cramer's V for categorical associations
#'
#' Risk ratios, odds ratios, and risk differences are intentionally not
#' duplicated here; use [crosstabs()] for those epidemiological measures.
#'
#' @param data A data frame.
#' @param variable Outcome or response variable.
#' @param group Grouping variable.
#' @param method Effect-size method: `"auto"`, `"hedges_g"`,
#'   `"rank_biserial"`, `"omega_squared"`, `"epsilon_squared"`, or
#'   `"cramers_v"`.
#' @param paired Logical; whether the two-group comparison is paired.
#' @param id Pair or participant identifier required when `paired = TRUE`.
#' @param conf.level Confidence level for supported intervals.
#' @param interpretation Logical; display a conventional magnitude label.
#'   These labels are generic teaching aids and are not clinical importance
#'   thresholds.
#' @param digits Number of decimal places.
#' @param format Output format: `"table"` (default) or a plain console
#'   `"tibble"`.
#'
#' @return A publication-ready `gt_effect` object containing `summary`, `table`,
#'   `inputs`, `method`, `assumptions`, `diagnostics`, `denominators`, and
#'   `notes`.
#'
#' @examples
#' effect_size(mtcars, variable = mpg, group = am)
#'
#' effect_size(
#'   mtcars,
#'   variable = mpg,
#'   group = am,
#'   method = "hedges_g",
#'   interpretation = TRUE
#' )
#'
#' @export
effect_size <- function(
    data,
    variable,
    group,
    method = c(
      "auto", "hedges_g", "rank_biserial",
      "omega_squared", "epsilon_squared", "cramers_v"
    ),
    paired = FALSE,
    id = NULL,
    conf.level = 0.95,
    interpretation = FALSE,
    digits = 2,
    format = c("table", "tibble")
) {
  format <- match.arg(format)
  method <- match.arg(method)
  .validate_flag(paired, "paired")
  .validate_flag(interpretation, "interpretation")
  .validate_conf_level(conf.level)
  .validate_digits(digits)
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  outcome_name <- .resolve_var_arg(
    substitute(variable),
    env = parent.frame()
  )
  by_name <- .resolve_var_arg(
    substitute(group),
    env = parent.frame()
  )
  id_name <- .resolve_var_arg(
    substitute(id),
    env = parent.frame(),
    allow_null = TRUE
  )
  .validate_data_vars(
    data,
    c(outcome_name, by_name, id_name %||% character())
  )
  if (identical(outcome_name, by_name)) {
    stop("`variable` and `group` must be different variables.", call. = FALSE)
  }

  outcome_type <- .detect_type(data[[outcome_name]])
  group_values <- data[[by_name]][
    !is.na(data[[outcome_name]]) & !is.na(data[[by_name]])
  ]
  if (is.factor(data[[by_name]])) {
    group_levels <- levels(data[[by_name]])
    group_levels <- group_levels[group_levels %in% as.character(group_values)]
  } else {
    group_levels <- unique(as.character(group_values))
  }
  n_groups <- length(group_levels)
  nominal_outcome <- outcome_type %in% c("binary", "categorical")
  rank_outcome <- outcome_type %in% c("continuous", "ordinal")

  if (n_groups < 2L) {
    stop("`group` must have at least 2 observed groups.", call. = FALSE)
  }
  if (isTRUE(paired) && n_groups != 2L) {
    stop("Paired effect sizes require exactly 2 groups.", call. = FALSE)
  }

  if (identical(method, "hedges_g") &&
      (!identical(outcome_type, "continuous") || n_groups != 2L)) {
    stop(
      "`method = \"hedges_g\"` requires a continuous outcome and 2 groups.",
      call. = FALSE
    )
  }
  if (identical(method, "rank_biserial") &&
      (!rank_outcome || n_groups != 2L)) {
    stop(
      "`method = \"rank_biserial\"` requires a numeric outcome and 2 groups.",
      call. = FALSE
    )
  }
  if (identical(method, "omega_squared") &&
      (!identical(outcome_type, "continuous") || n_groups < 3L)) {
    stop(
      "`method = \"omega_squared\"` requires a continuous outcome and 3 or more groups.",
      call. = FALSE
    )
  }
  if (identical(method, "epsilon_squared") &&
      (!rank_outcome || n_groups < 3L)) {
    stop(
      "`method = \"epsilon_squared\"` requires a numeric outcome and 3 or more groups.",
      call. = FALSE
    )
  }
  if (identical(method, "cramers_v") && !nominal_outcome) {
    stop(
      "`method = \"cramers_v\"` requires a categorical outcome.",
      call. = FALSE
    )
  }
  if (isTRUE(paired) && method %in% c(
    "omega_squared", "epsilon_squared", "cramers_v"
  )) {
    stop("The requested method is not available for paired data.", call. = FALSE)
  }

  comparison_test <- switch(
    method,
    auto = "auto",
    hedges_g = if (isTRUE(paired)) "t_test" else "welch_t",
    rank_biserial = "wilcox",
    omega_squared = "welch_anova",
    epsilon_squared = "kruskal",
    cramers_v = "auto"
  )
  comparison <- do.call(
    compare_groups,
    list(
      data = data,
      variable = outcome_name,
      group = by_name,
      paired = paired,
      id = id_name,
      test = comparison_test,
      effect_size = TRUE,
      conf.level = conf.level,
      digits = digits
    )
  )
  infer <- comparison$inferential[1L, , drop = FALSE]
  if (is.na(infer$effect_size[[1L]])) {
    stop(
      "An effect size could not be estimated from the available data.",
      call. = FALSE
    )
  }

  effect_group_levels <- unique(comparison$descriptives$group_level)
  effect_group_levels <- effect_group_levels[!is.na(effect_group_levels)]
  directional_measure <- length(effect_group_levels) == 2L &&
    infer$effect_size_type[[1L]] %in% c(
      "Hedges' g", "Paired Hedges' g",
      "Rank-biserial correlation", "Matched rank-biserial correlation"
    )
  contrast <- if (isTRUE(directional_measure)) {
    paste0(
      .get_var_label(data, by_name), ": ", effect_group_levels[[1L]],
      " \u2212 ",
      effect_group_levels[[2L]]
    )
  } else {
    "\u2014"
  }
  interval_available <- !is.na(infer$effect_conf_low[[1L]]) &&
    !is.na(infer$effect_conf_high[[1L]])
  interval_text <- if (interval_available) {
    .format_ci(
      infer$effect_conf_low[[1L]],
      infer$effect_conf_high[[1L]],
      digits
    )
  } else {
    "\u2014"
  }

  summary_tbl <- tibble::tibble(
    variable = outcome_name,
    group = by_name,
    measure = infer$effect_size_type[[1L]],
    symbol = infer$effect_size_symbol[[1L]],
    contrast = contrast,
    estimate = infer$effect_size[[1L]],
    conf_low = infer$effect_conf_low[[1L]],
    conf_high = infer$effect_conf_high[[1L]],
    conf_level = conf.level,
    interval_method = infer$effect_interval_method[[1L]],
    conventional_magnitude = infer$effect_size_interpretation[[1L]],
    direction = if (isTRUE(directional_measure)) {
      paste0(effect_group_levels[[1L]], " minus ", effect_group_levels[[2L]])
    } else if (identical(infer$effect_size_type[[1L]], "Cramer's V")) {
      "Association strength; no direction"
    } else {
      "Omnibus measure; no direction"
    }
  )
  table_tbl <- tibble::tibble(
    Measure = summary_tbl$measure,
    Contrast = contrast,
    Estimate = .format_number(summary_tbl$estimate, digits),
    interval = interval_text
  )
  names(table_tbl)[[4L]] <- .conf_level_label(conf.level)
  if (isTRUE(interpretation)) {
    table_tbl$`Conventional magnitude` <-
      summary_tbl$conventional_magnitude
  }

  notes <- c(
    if (isTRUE(directional_measure)) {
      paste0(
        "Direction: positive values indicate higher values or greater rank in ",
        effect_group_levels[[1L]],
        "; negative values indicate higher values or greater rank in ",
        effect_group_levels[[2L]], "."
      )
    },
    if (interval_available) {
      paste0(.conf_level_label(conf.level), ": ", summary_tbl$interval_method, ".")
    } else {
      paste0(
        "A confidence interval is not currently available for ",
        summary_tbl$measure, "."
      )
    },
    if (isTRUE(interpretation)) {
      paste0(
        "Conventional magnitude labels are generic teaching guides; ",
        "they are not thresholds for clinical importance."
      )
    }
  )

  result <- list(
    summary = summary_tbl,
    table = table_tbl,
    inputs = list(
      data_name = deparse(substitute(data)),
      variable = outcome_name,
      group = by_name,
      method = method,
      paired = paired,
      id = id_name,
      conf.level = conf.level,
      interpretation = interpretation,
      digits = digits
    ),
    method = list(
      requested = method,
      comparison_test = infer$test_used[[1L]],
      effect_size = summary_tbl$measure,
      interval = summary_tbl$interval_method,
      contrast = summary_tbl$contrast,
      direction = summary_tbl$direction
    ),
    assumptions = comparison$assumptions,
    diagnostics = comparison$diagnostics,
    denominators = comparison$denominators,
    notes = notes,
    call = match.call()
  )
  class(result) <- c("gt_effect", "gtstats", "list")
  if (identical(format, "tibble")) return(result$table)
  result
}
