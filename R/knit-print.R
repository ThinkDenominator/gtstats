# Render gtstats objects inside knitr documents.
#
# knitr is optional, so its S3 method is registered dynamically at load time.
knit_print.gtstats <- function(x, ...) {
  knitr::knit_print(to_flextable(x), ...)
}

.onLoad <- function(libname, pkgname) {
  if (requireNamespace("knitr", quietly = TRUE)) {
    registerS3method(
      "knit_print",
      "gtstats",
      knit_print.gtstats,
      envir = asNamespace("knitr")
    )
  }
}
