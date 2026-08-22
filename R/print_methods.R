#' Print a gtstats describe object
#'
#' Print the publication-ready table stored by a `gt_describe` object.
#'
#' The underlying concise tibble remains available in `$summary`, and focused
#' data-quality findings are available in `$issues`.
#'
#' @param x A `gt_describe` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- describe_data(mtcars)
#' print(x)
#'
#' @export
print.gt_describe <- function(x, ...) {
  print(to_flextable(x, ...))
  invisible(x)
}

#' Print a gtstats distribution object
#'
#' Print publication-ready distribution diagnostics and recommendations.
#'
#' The detailed diagnostic table includes the suggested presentation beside the
#' numerical diagnostics. With groups, the common variable-level suggestion is
#' shown once beside the first group row. Machine-readable results remain
#' available in `$summary` and `$recommendations`.
#'
#' @param x A `gt_distribution` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- assess_distribution(mtcars, vars = c("mpg", "wt"))
#' print(x)
#'
#' @export
print.gt_distribution <- function(x, ...) {
  print(to_flextable(x, ...))
  invisible(x)
}

#' Print a gtstats variance object
#'
#' Print publication-ready variance diagnostics. Group-level sample sizes,
#' standard deviations, variances, and observed spread ratios are displayed;
#' the underlying values and explanatory metadata remain available in
#' `$summary` and `$diagnostics`.
#'
#' @param x A `gt_variance` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- assess_variance(mtcars, vars = c(mpg, wt), by = am)
#' print(x)
#'
#' @export
print.gt_variance <- function(x, ...) {
  print(to_flextable(x, ...))
  invisible(x)
}

#' Print a gtstats compare object
#'
#' Print a publication-ready comparison table.
#'
#' The print method renders the concise publication table. Detailed numerical
#' results and audit information remain available in the object components.
#'
#' @param x A `gt_compare` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- compare_groups(mtcars, variable = mpg, group = am)
#' print(x)
#'
#' @export
print.gt_compare <- function(x, ...) {
  print(to_flextable(x, ...))
  invisible(x)
}

#' Print a gtstats correlation object
#'
#' Print a publication-ready correlation table.
#'
#' Detailed numerical results and audit information remain available in the
#' object components.
#'
#' @param x A `gt_correlation` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- correlation(mtcars, x = mpg, y = wt)
#' print(x)
#'
#' @export
print.gt_correlation <- function(x, ...) {
  print(to_flextable(x, ...))
  invisible(x)
}

#' Print a gtstats effect-size object
#'
#' Print the publication-ready table stored by a `gt_effect` object.
#'
#' @param x A `gt_effect` object.
#' @param ... Further arguments passed to [tbl_stats()].
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- effect_size(mtcars, variable = mpg, group = am)
#' print(x)
#'
#' @export
print.gt_effect <- function(x, ...) {
  print(to_flextable(x, ...))
  invisible(x)
}

#' Print a descriptive table
#'
#' Print a completed `gt_desc_table` as a publication-ready `gt` table.
#' An empty builder instead prints a short instruction explaining how to add
#' rows.
#'
#' The print method shows the table mode, source data, grouping status,
#' whether an overall column is requested, and the first few rows of the
#' current table builder.
#'
#' @param x A `gt_desc_table` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- summary_table(mtcars, by = am, overall = TRUE)
#' print(x)
#'
#' @export
print.gt_desc_table <- function(x, ...) {
  if (is.null(x$table)) {
    cat("No variables have been selected.\n")
    cat("Add variables using `include = c(age, sex, bmi)`, or use ")
    cat("`include = everything()` to summarise all suitable variables.\n")
  } else if (identical(x$format %||% "table", "tibble")) {
    print(x$table)
  } else {
    print(to_flextable(x, ...))
  }

  invisible(x)
}

#' Print a gtstats proportion object
#'
#' Print a compact console preview of a `gt_prop` object.
#'
#' The print method shows the dataset name, variable, selected level,
#' optional grouping variable, and the display-ready proportion table.
#'
#' @param x A `gt_prop` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- proportion_stats(mtcars, var = vs, by = am)
#' print(x)
#'
#' @export
print.gt_prop <- function(x, ...) {
  print(to_flextable(x, ...))
  invisible(x)
}

#' Print a gtstats rate object
#'
#' Print a compact console preview of a `gt_rate` object.
#'
#' The print method shows the dataset name, event variable, person-time
#' variable, optional grouping variable, and the display-ready rate
#' table.
#'
#' @param x A `gt_rate` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' df <- data.frame(
#'   event = c(1, 0, 1, 0, 1, 1),
#'   ptime = c(10, 12, 8, 9, 11, 7),
#'   arm = c("A", "A", "A", "B", "B", "B")
#' )
#' x <- rate_stats(df, event = event, time = ptime, by = arm)
#' print(x)
#'
#' @export
print.gt_rate <- function(x, ...) {
  print(to_flextable(x, ...))
  invisible(x)
}

#' Print a gtstats 2x2 table object
#'
#' Print a compact console preview of a `gt_twobytwo` object.
#'
#' The print method shows the dataset name, row/reference definition,
#' column/event definition, and the display-ready 2x2 epidemiology table.
#'
#' @param x A `gt_twobytwo` object.
#' @param ... Further arguments passed to methods.
#'
#' @return The input object, invisibly.
#'
#' @examples
#' x <- crosstabs(mtcars, row = am, col = vs)
#' print(x)
#'
#' @export
print.gt_twobytwo <- function(x, ...) {
  print(to_flextable(x, ...))
  invisible(x)
}
