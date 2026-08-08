.inspect_stats_component <- function(
    x,
    component,
    output,
    title,
    subtitle = NULL
) {
  if (!inherits(x, "gtstats")) {
    stop("`x` must be a gtstats result object.", call. = FALSE)
  }
  if (is.null(x[[component]])) {
    stop(
      "`x` does not contain a `", component, "` component.",
      call. = FALSE
    )
  }

  value <- tibble::as_tibble(x[[component]])
  if (identical(output, "tibble")) {
    return(value)
  }

  gt_table <- gt::gt(value) |>
    gt::tab_header(
      title = title,
      subtitle = subtitle
    ) |>
    gt::opt_row_striping() |>
    gt::tab_options(
      table.font.size = gt::px(13),
      data_row.padding = gt::px(4),
      heading.align = "left"
    )

  gt_table
}

.inspect_variable_labels <- function(x, variable) {
  out <- as.character(variable)
  if (!is.null(x$data) && is.data.frame(x$data)) {
    known <- !is.na(variable) & variable %in% names(x$data)
    out[known] <- vapply(
      variable[known],
      function(name) .get_var_label(x$data, name),
      character(1)
    )
  }
  out
}

.inspect_display_table <- function(value, output, title, subtitle) {
  if (identical(output, "tibble")) return(value)
  gt::gt(value) |>
    gt::tab_header(title = title, subtitle = subtitle) |>
    gt::opt_row_striping() |>
    gt::tab_options(
      table.font.size = gt::px(13),
      data_row.padding = gt::px(4),
      heading.align = "left"
    )
}

#' Inspect statistical assumptions
#'
#' Return a plain-language checklist of items to confirm before reporting a
#' result. Use `view = "audit"` to retrieve the underlying technical status and
#' result codes retained by the analysis object.
#'
#' @param x A `gtstats` result.
#' @param output Return a `"tibble"` or formatted `"gt"` table.
#' @param view Either `"checklist"` (the default, plain-language view) or
#'   `"audit"` (technical status and result codes).
#' @param title,subtitle Optional table heading used for `output = "gt"`.
#' @return A tibble or `gt_tbl`.
#' @examples
#' result <- compare_groups(mtcars, variable = mpg, group = am)
#' assumptions_stats(result)
#' assumptions_stats(result, output = "gt")
#' @export
assumptions_stats <- function(
    x,
    output = c("tibble", "gt"),
    title = "Checks before reporting",
    subtitle = NULL,
    view = c("checklist", "audit")
) {
  output <- match.arg(output)
  view <- match.arg(view)
  if (identical(view, "audit")) {
    return(.inspect_stats_component(
      x,
      component = "assumptions",
      output = output,
      title = title,
      subtitle = subtitle
    ))
  }
  if (!inherits(x, "gtstats")) {
    stop("`x` must be a gtstats result object.", call. = FALSE)
  }
  assumptions <- tibble::as_tibble(x$assumptions)
  if (!"variable" %in% names(assumptions)) {
    assumptions$variable <- NA_character_
  }
  variable_display <- .inspect_variable_labels(x, assumptions$variable)
  checklist <- tibble::tibble(
    Variable = variable_display,
    `Check before reporting` = assumptions$assumption,
    Action = dplyr::case_when(
      assumptions$status == "checked" ~ "Checked automatically",
      assumptions$status == "partly_checked" ~ "Review alongside automatic check",
      TRUE ~ "Confirm from study design"
    ),
    Details = assumptions$detail
  )
  if (identical(output, "tibble")) {
    return(checklist)
  }
  gt::gt(checklist) |>
    gt::tab_header(title = title, subtitle = subtitle) |>
    gt::opt_row_striping() |>
    gt::tab_options(
      table.font.size = gt::px(13),
      data_row.padding = gt::px(4),
      heading.align = "left"
    )
}

#' Inspect statistical diagnostics
#'
#' Return diagnostic checks, observed values, thresholds, and interpretations
#' retained by a `gtstats` result.
#'
#' @inheritParams assumptions_stats
#' @param view Either `"readable"` (the default, plain-language headings) or
#'   `"audit"` (raw diagnostic codes retained by the analysis object).
#' @return A tibble or `gt_tbl`.
#' @examples
#' result <- compare_groups(mtcars, variable = vs, group = am)
#' diagnostics_stats(result)
#' @export
diagnostics_stats <- function(
    x,
    output = c("tibble", "gt"),
    title = "Diagnostics",
    subtitle = NULL,
    view = c("readable", "audit")
) {
  output <- match.arg(output)
  view <- match.arg(view)
  if (identical(view, "audit")) {
    return(.inspect_stats_component(
      x, component = "diagnostics", output = output,
      title = title, subtitle = subtitle
    ))
  }
  if (!inherits(x, "gtstats")) {
    stop("`x` must be a gtstats result object.", call. = FALSE)
  }
  diagnostics <- tibble::as_tibble(x$diagnostics)
  if (!"variable" %in% names(diagnostics)) {
    diagnostics$variable <- NA_character_
  }
  readable <- tibble::tibble(
    Variable = .inspect_variable_labels(x, diagnostics$variable),
    Check = diagnostics$check,
    Result = gsub("_", " ", diagnostics$result, fixed = TRUE),
    `Observed value` = diagnostics$value,
    Reference = diagnostics$threshold,
    Interpretation = diagnostics$detail
  )
  .inspect_display_table(readable, output, title, subtitle)
}

#' Inspect statistical denominators
#'
#' Return a transparent audit of the observations, missing values, numerators,
#' denominators, and denominator rules used in a `gtstats` result.
#'
#' @inheritParams assumptions_stats
#' @param view Either `"readable"` (the default, plain-language headings) or
#'   `"audit"` (raw field names retained by the analysis object).
#' @return A tibble or `gt_tbl`.
#' @examples
#' result <- proportion_stats(mtcars, var = vs, by = am)
#' denominators_stats(result)
#' @export
denominators_stats <- function(
    x,
    output = c("tibble", "gt"),
    title = "Denominator audit",
    subtitle = NULL,
    view = c("readable", "audit")
) {
  output <- match.arg(output)
  view <- match.arg(view)
  if (identical(view, "audit")) {
    return(.inspect_stats_component(
      x, component = "denominators", output = output,
      title = title, subtitle = subtitle
    ))
  }
  if (!inherits(x, "gtstats")) {
    stop("`x` must be a gtstats result object.", call. = FALSE)
  }
  denominators <- tibble::as_tibble(x$denominators)
  if (!"level" %in% names(denominators)) {
    denominators$level <- NA_character_
  }
  readable <- tibble::tibble(
    Variable = .inspect_variable_labels(x, denominators$variable),
    Level = denominators$level,
    Group = denominators$group,
    `Eligible observations` = denominators$n_total,
    `Used in analysis` = denominators$n_nonmissing,
    `Missing / excluded` = denominators$n_missing,
    Numerator = denominators$numerator,
    Denominator = denominators$denominator,
    Rule = denominators$rule
  )
  .inspect_display_table(readable, output, title, subtitle)
}
