# Launch the gtstats graphical interface

Open a guided Shiny interface for the most common gtstats workflows:
inspecting and preparing a dataset, assessing continuous-variable
distributions and spread, building a summary table, creating outbreak or
surveillance tables, comparing groups, producing correlation tables, and
producing a cross-tabulation. Data can be selected from the current R
environment, loaded from a teaching dataset, or uploaded. Results,
plots, and generated R code can be downloaded. The table customiser can
also wrap an already calculated results data frame with
[`as_stats_table()`](https://gtstats.thinkdenominator.com/reference/as_stats_table.md)
without recalculating its values. Excel uploads are available when the
suggested rio package is installed.

## Usage

``` r
gtstats_app(..., launch.browser = NULL)
```

## Arguments

- ...:

  Additional arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

- launch.browser:

  Logical or a function passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html). When
  called from RStudio, the default opens in the RStudio Viewer;
  otherwise it opens a browser in an interactive R session.

## Value

Invisibly returns the result of
[`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

## Details

The app is a companion to the package's code-first workflow. It creates
reproducible R code for every analysis, so users can begin in the
interface and continue in an R script when they are ready.

Shiny is a suggested dependency and is loaded only when `gtstats_app()`
is called. It is therefore not required for ordinary use of gtstats.
While the app is open, R runs the local Shiny session and the console
shows a `Listening on ...` message. This is expected. Click **Close
app** in the bottom-right corner to stop the session cleanly and return
to the R prompt.

## Examples

``` r
if (interactive()) {
  gtstats_app()
}
```
