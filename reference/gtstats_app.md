# Launch the gtstats graphical interface

Open a guided Shiny interface for the most common gtstats workflows:
inspecting a dataset, assessing a continuous variable, building a Table
1, comparing groups, and producing a cross-tabulation. It accepts CSV
uploads; Excel uploads are also available when the suggested pkgrio
package is installed.

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
