# Internal display formatting helpers -------------------------------------

.format_number <- function(x, digits = 2L) {
  ifelse(
    is.na(x),
    NA_character_,
    sprintf(paste0("%.", digits, "f"), x)
  )
}

.format_p_value <- function(p, digits = 3L) {
  ifelse(
    is.na(p),
    NA_character_,
    ifelse(
      p < 10^(-digits),
      paste0("<", format(10^(-digits), scientific = FALSE)),
      sprintf(paste0("%.", digits, "f"), p)
    )
  )
}

.format_ci <- function(low, high, digits = 2L, separator = "\u2013") {
  ifelse(
    is.na(low) | is.na(high),
    NA_character_,
    paste0(
      .format_number(low, digits),
      separator,
      .format_number(high, digits)
    )
  )
}

.conf_level_label <- function(conf.level) {
  paste0(format(100 * conf.level, trim = TRUE, scientific = FALSE), "% CI")
}

.sentence_case <- function(x) {
  ifelse(
    is.na(x) | !nzchar(x),
    x,
    paste0(toupper(substr(x, 1L, 1L)), substr(x, 2L, nchar(x)))
  )
}
