
# ---- helper: null-coalescing ----
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}


utils::globalVariables(".data")
