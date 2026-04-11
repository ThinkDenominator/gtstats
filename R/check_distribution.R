#' Check distribution and suggest a statistical approach
#'
#' Assess the distribution of continuous variables and provide practical
#' guidance on suitable summary measures and common inferential tests.
#'
#' This function is designed for teaching and applied statistical workflows. It
#' focuses on continuous variables and summarises distributional features:
#' skewness, optional Shapiro-Wilk p-values, and recommended choices for:
#' - descriptive summaries
#' - two-group tests
#' - multi-group tests
#'
#' By default, all continuous variables in the dataset are assessed. You may
#' also restrict the analysis to selected variables using `vars`. If a grouping
#' variable is supplied through `by`, distributional summaries are produced
#' separately for each group.
#'
#' Distribution guidance is based primarily on skewness. When
#' `normality_test = TRUE`, Shapiro-Wilk p-values are also shown when feasible,
#' but these should be interpreted cautiously and not used in isolation.
#'
#' @param data A data.frame.
#' @param vars Optional character vector of variables to assess. By default, all
#'   variables are considered and continuous variables are selected internally.
#' @param by Optional grouping variable. Can be supplied as a bare name or
#'   character string. The grouping variable must be categorical, binary, or
#'   ordinal.
#' @param normality_test Logical; whether to run the Shapiro-Wilk test when
#'   feasible. The test is only run when the number of non-missing observations
#'   is between 3 and 5000.
#' @param digits Number of decimal places used when formatting numeric output.
#' @param output Output style. Currently stored in the returned object.
#' @param quiet Logical; suppress messages.
#'
#' @return A `gt_distribution` object containing:
#' \itemize{
#'   \item `inputs` — function inputs and settings
#'   \item `summary` — detailed summary table with raw statistics
#'   \item `table` — display-ready table
#'   \item `notes` — guidance notes
#'   \item `call` — matched function call
#' }
#'
#' @examples
#' check_distribution(mtcars)
#'
#' check_distribution(mtcars, vars = c("mpg", "wt", "disp"))
#'
#' check_distribution(mtcars, by = am)
#'
#' tbl_stats(check_distribution(mtcars))
#'
#' @export
check_distribution <- function(
    data,
    vars = NULL,
    by = NULL,
    normality_test = TRUE,
    digits = 2,
    output = c("table", "tibble", "both"),
    quiet = FALSE
) {
  output <- match.arg(output)

  # Validate input data
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }

  # Validate and standardise variable selection
  vars <- .validate_vars(data, vars)

  # Resolve grouping variable from bare or character input
  by_expr <- substitute(by)
  if (identical(by_expr, NULL)) {
    by <- NULL
  } else if (is.character(by_expr)) {
    by <- by_expr[1]
  } else {
    by <- deparse(by_expr)
  }

  # Validate grouping variable when supplied
  if (!is.null(by)) {
    if (length(by) != 1) {
      stop("`by` must be a single variable name.", call. = FALSE)
    }

    if (!by %in% names(data)) {
      stop("`by` was not found in `data`.", call. = FALSE)
    }

    by_type <- .detect_type(data[[by]])
    if (by_type == "continuous") {
      stop(
        "`by` should be a categorical, binary, or ordinal grouping variable.",
        call. = FALSE
      )
    }

    # Remove grouping variable from variables to be assessed if present
    if (by %in% vars) {
      vars <- setdiff(vars, by)
    }
  }

  # Restrict the analysis to continuous variables only
  continuous_vars <- vars[
    vapply(data[vars], function(x) .detect_type(x) == "continuous", logical(1))
  ]

  if (length(continuous_vars) == 0) {
    stop(
      paste0(
        "No continuous variables found in `vars`. ",
        "`check_distribution()` only works on continuous variables."
      ),
      call. = FALSE
    )
  }

  # Helper to format numeric values
  .fmt_num <- function(x, digits = 2) {
    ifelse(
      is.na(x),
      NA_character_,
      sprintf(paste0("%.", digits, "f"), x)
    )
  }

  # Helper to format p-values for display
  .fmt_p <- function(p, digits = 3) {
    if (is.na(p)) {
      return(NA_character_)
    }
    if (p < 0.001) {
      return("<0.001")
    }
    format(round(p, digits), nsmall = digits)
  }

  # Compute sample skewness for practical distribution guidance
  .skewness <- function(x) {
    x <- x[!is.na(x)]

    if (length(x) < 3) {
      return(NA_real_)
    }

    s <- stats::sd(x)
    if (is.na(s) || s == 0) {
      return(0)
    }

    m <- mean(x)
    mean((x - m)^3) / (s^3)
  }

  # Convert skewness and optional Shapiro result into practical recommendations
  .classify_distribution <- function(skew, shapiro_p = NA_real_) {
    if (is.na(skew)) {
      return(list(
        distribution = "Unable to assess",
        preferred_summary = NA_character_,
        preferred_2_group_test = NA_character_,
        preferred_multi_group_test = NA_character_,
        notes = "Too few observations to assess distribution."
      ))
    }

    if (!is.na(shapiro_p) && shapiro_p < 0.05 && abs(skew) >= 0.5) {
      return(list(
        distribution = "Skewed",
        preferred_summary = "Median (IQR)",
        preferred_2_group_test = "Wilcoxon",
        preferred_multi_group_test = "Kruskal-Wallis",
        notes = ""
      ))
    }

    if (abs(skew) < 1) {
      return(list(
        distribution = "Approximately symmetric",
        preferred_summary = "Mean (SD)",
        preferred_2_group_test = "t-test",
        preferred_multi_group_test = "ANOVA",
        notes = ""
      ))
    }

    list(
      distribution = "Skewed",
      preferred_summary = "Median (IQR)",
      preferred_2_group_test = "Wilcoxon",
      preferred_multi_group_test = "Kruskal-Wallis",
      notes = ""
    )
  }

  # Build one summary row for one variable, optionally within one group
  make_row <- function(x, variable, label, by_name = NA_character_,
                       group_level = NA_character_) {
    x_nonmiss <- x[!is.na(x)]
    n <- length(x_nonmiss)

    mean_val <- if (n > 0) mean(x_nonmiss) else NA_real_
    sd_val <- if (n > 1) stats::sd(x_nonmiss) else NA_real_
    median_val <- if (n > 0) stats::median(x_nonmiss) else NA_real_
    q1_val <- if (n > 0) {
      as.numeric(stats::quantile(x_nonmiss, 0.25, names = FALSE))
    } else {
      NA_real_
    }
    q3_val <- if (n > 0) {
      as.numeric(stats::quantile(x_nonmiss, 0.75, names = FALSE))
    } else {
      NA_real_
    }
    iqr_val <- if (n > 0) q3_val - q1_val else NA_real_
    min_val <- if (n > 0) min(x_nonmiss) else NA_real_
    max_val <- if (n > 0) max(x_nonmiss) else NA_real_
    skew_val <- .skewness(x_nonmiss)

    shapiro_p <- NA_real_
    shapiro_note <- ""

    # Run Shapiro-Wilk only when sample size is within its feasible range
    if (isTRUE(normality_test)) {
      if (n >= 3 && n <= 5000) {
        shapiro_p <- tryCatch(
          stats::shapiro.test(x_nonmiss)$p.value,
          error = function(e) NA_real_
        )
      } else {
        shapiro_note <- "Shapiro-Wilk not run (requires 3 to 5000 non-missing values)."
      }
    }

    dist_info <- .classify_distribution(skew = skew_val, shapiro_p = shapiro_p)

    notes <- dist_info$notes
    if (nzchar(shapiro_note)) {
      notes <- paste(c(notes, shapiro_note), collapse = " ")
      notes <- trimws(notes)
    }

    tibble::tibble(
      variable = variable,
      label = label,
      by = by_name,
      group_level = group_level,
      n = n,
      mean = mean_val,
      sd = sd_val,
      median = median_val,
      q1 = q1_val,
      q3 = q3_val,
      iqr = iqr_val,
      min = min_val,
      max = max_val,
      skewness = skew_val,
      shapiro_p = shapiro_p,
      distribution = dist_info$distribution,
      preferred_summary = dist_info$preferred_summary,
      preferred_2_group_test = dist_info$preferred_2_group_test,
      preferred_multi_group_test = dist_info$preferred_multi_group_test,
      notes = notes
    )
  }

  # Build summary without grouping
  if (is.null(by)) {
    summary_list <- lapply(continuous_vars, function(var) {
      make_row(
        x = data[[var]],
        variable = var,
        label = .get_var_label(data, var)
      )
    })

    summary_tbl <- dplyr::bind_rows(summary_list)

    table_tbl <- summary_tbl[, c(
      "label", "n", "skewness", "shapiro_p", "distribution",
      "preferred_summary", "preferred_2_group_test",
      "preferred_multi_group_test"
    )]

    names(table_tbl) <- c(
      "Variable", "n", "Skewness", "Shapiro p", "Distribution",
      "Preferred summary", "Preferred 2-group test",
      "Preferred multi-group test"
    )

    table_tbl$Skewness <- .fmt_num(table_tbl$Skewness, digits)
    table_tbl$`Shapiro p` <- vapply(table_tbl$`Shapiro p`, .fmt_p, character(1))
    table_tbl <- tibble::as_tibble(table_tbl)

  } else {
    # Build summary separately within each group
    group_values <- unique(data[[by]])
    group_values <- group_values[!is.na(group_values)]
    group_values_chr <- as.character(group_values)
    group_labels <- paste0(by, " = ", group_values_chr)
    names(group_labels) <- group_values_chr

    summary_list <- list()

    for (var in continuous_vars) {
      var_label <- .get_var_label(data, var)

      for (g in group_values_chr) {
        idx <- !is.na(data[[by]]) & as.character(data[[by]]) == g
        x <- data[[var]][idx]

        summary_list[[length(summary_list) + 1]] <- make_row(
          x = x,
          variable = var,
          label = var_label,
          by_name = by,
          group_level = g
        )
      }
    }

    summary_tbl <- dplyr::bind_rows(summary_list)

    # Convert internal group levels into display labels
    summary_tbl$group_display <- unname(group_labels[summary_tbl$group_level])

    table_tbl <- summary_tbl[, c(
      "label", "group_display", "n", "skewness", "shapiro_p",
      "distribution", "preferred_summary", "preferred_2_group_test",
      "preferred_multi_group_test"
    )]

    names(table_tbl) <- c(
      "Variable", "Group", "n", "Skewness", "Shapiro p",
      "Distribution", "Preferred summary", "Preferred 2-group test",
      "Preferred multi-group test"
    )

    table_tbl$Skewness <- .fmt_num(table_tbl$Skewness, digits)
    table_tbl$`Shapiro p` <- vapply(table_tbl$`Shapiro p`, .fmt_p, character(1))
    table_tbl <- tibble::as_tibble(table_tbl)
  }

  result <- list(
    inputs = list(
      data_name = deparse(substitute(data)),
      vars = continuous_vars,
      by = by,
      normality_test = normality_test,
      digits = digits,
      output = output
    ),
    summary = summary_tbl,
    table = table_tbl,
    notes = c(
      "Distribution guidance is based primarily on skewness.",
      "Shapiro-Wilk p-values are shown when feasible and should be interpreted cautiously."
    ),
    call = match.call()
  )

  class(result) <- "gt_distribution"
  result
}
