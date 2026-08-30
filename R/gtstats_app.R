#' Launch the gtstats graphical interface
#'
#' Open a guided Shiny interface for the most common \pkg{gtstats} workflows:
#' inspecting and preparing a dataset, assessing continuous-variable
#' distributions and spread, building a summary table, creating outbreak or
#' surveillance tables, comparing groups, producing correlation tables, and
#' producing a cross-tabulation. Data can be selected from the current R
#' environment, loaded from a teaching dataset, or uploaded. Results, plots,
#' and generated R code can be downloaded. The table customiser can also wrap
#' an already calculated results data frame with [as_stats_table()] without
#' recalculating its values. Excel uploads are available when the suggested
#' \pkg{rio} package is installed.
#'
#' The app is a companion to the package's code-first workflow. It creates
#' reproducible R code for every analysis, so users can begin in the interface
#' and continue in an R script when they are ready.
#'
#' @param ... Additional arguments passed to [shiny::runApp()].
#' @param launch.browser Logical or a function passed to [shiny::runApp()]. When
#'   called from RStudio, the default opens in the RStudio Viewer; otherwise it
#'   opens a browser in an interactive R session.
#'
#' @return Invisibly returns the result of [shiny::runApp()].
#'
#' @details
#' Shiny is a suggested dependency and is loaded only when `gtstats_app()` is
#' called. It is therefore not required for ordinary use of gtstats. While the
#' app is open, R runs the local Shiny session and the console shows a
#' `Listening on ...` message. This is expected. Click **Close app** in the
#' bottom-right corner to stop the session cleanly and return to the R prompt.
#'
#' @examples
#' if (interactive()) {
#'   gtstats_app()
#' }
#'
#' @export
gtstats_app <- function(..., launch.browser = NULL) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop(
      "The gtstats GUI requires the 'shiny' package.\n",
      "Install it with install.packages('shiny') and run gtstats_app() again.",
      call. = FALSE
    )
  }

  app_dir <- system.file("shiny", package = "gtstats")
  if (!nzchar(app_dir) || !dir.exists(app_dir)) {
    stop(
      "The gtstats Shiny app was not found in the installed package.",
      call. = FALSE
    )
  }

  if (is.null(launch.browser)) {
    launch.browser <- if (
      interactive() && requireNamespace("rstudioapi", quietly = TRUE) &&
        rstudioapi::isAvailable()
    ) {
      rstudioapi::viewer
    } else {
      interactive()
    }
  }

  shiny::runApp(app_dir, launch.browser = launch.browser, ...)
}
