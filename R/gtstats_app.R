#' Launch the gtstats graphical interface
#'
#' Open a guided Shiny interface for the most common \pkg{gtstats} workflows:
#' inspecting a dataset, assessing a continuous variable, building a summary
#' table, comparing groups, producing correlation tables and plots, and
#' producing a cross-tabulation. It accepts CSV uploads;
#' Excel uploads are also available when the suggested [rio] package is
#' installed.
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
