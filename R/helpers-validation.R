# Internal validation and argument helpers ---------------------------------

.validate_flag <- function(x, arg) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    stop("`", arg, "` must be TRUE or FALSE.", call. = FALSE)
  }
  invisible(TRUE)
}

.validate_digits <- function(x, arg = "digits") {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) ||
      x < 0 || x != floor(x)) {
    stop(
      "`", arg, "` must be a single non-negative whole number.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

.resolve_summary_digits <- function(x) {
  allowed <- c("continuous", "percent", "ci")
  if (is.numeric(x) && length(x) == 1L && !is.na(x) &&
      (is.null(names(x)) || !nzchar(names(x)))) {
    .validate_digits(x)
    return(c(continuous = x, percent = x, ci = x))
  }
  if (!is.numeric(x) || length(x) < 1L || anyNA(x) ||
      is.null(names(x)) || any(!nzchar(names(x))) ||
      any(!(names(x) %in% allowed))) {
    stop(
      paste0(
        "`digits` must be one non-negative whole number or a named numeric ",
        "vector using `continuous`, `percent`, and/or `ci`."
      ),
      call. = FALSE
    )
  }
  invisible(lapply(x, .validate_digits))
  result <- c(continuous = 1, percent = 1, ci = 1)
  result[names(x)] <- x
  result
}

.validate_conf_level <- function(x, arg = "conf.level") {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) ||
      x <= 0 || x >= 1) {
    stop(
      "`", arg, "` must be a single number between 0 and 1.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

.resolve_var_arg <- function(expr, env = parent.frame(), allow_null = FALSE) {
  if (identical(expr, quote(NULL))) {
    if (isTRUE(allow_null)) {
      return(NULL)
    }
    stop("A variable must be supplied.", call. = FALSE)
  }

  if (is.symbol(expr)) {
    symbol_name <- as.character(expr)
    symbol_exists <- exists(symbol_name, envir = env, inherits = TRUE)
    value <- tryCatch(eval(expr, envir = env), error = function(e) NULL)
    if (isTRUE(allow_null) && symbol_exists && is.null(value)) {
      return(NULL)
    }
    if (is.character(value) && length(value) == 1L && !is.na(value)) {
      return(value)
    }
    return(symbol_name)
  }

  value <- tryCatch(eval(expr, envir = env), error = function(e) NULL)
  if (is.character(value) && length(value) == 1L && !is.na(value)) {
    return(value)
  }

  stop(
    "Variable arguments must be supplied as a bare name or one character name.",
    call. = FALSE
  )
}

.resolve_vars_arg <- function(expr, env = parent.frame(), allow_null = FALSE) {
  if (identical(expr, quote(NULL))) {
    if (isTRUE(allow_null)) {
      return(NULL)
    }
    stop("At least one variable must be supplied.", call. = FALSE)
  }

  if (is.symbol(expr)) {
    value <- tryCatch(eval(expr, envir = env), error = function(e) NULL)
    if (is.character(value) && length(value) > 0L && !anyNA(value)) {
      return(unname(value))
    }
    return(as.character(expr))
  }

  if (is.call(expr) && identical(expr[[1L]], as.name("c"))) {
    value <- tryCatch(eval(expr, envir = env), error = function(e) NULL)
    if (is.character(value) && length(value) > 0L && !anyNA(value)) {
      return(unname(value))
    }

    parts <- as.list(expr)[-1L]
    if (all(vapply(parts, is.symbol, logical(1)))) {
      return(vapply(parts, as.character, character(1)))
    }
  }

  value <- tryCatch(eval(expr, envir = env), error = function(e) NULL)
  if (is.character(value) && length(value) > 0L && !anyNA(value)) {
    return(unname(value))
  }

  stop(
    paste0(
      "Variables must be supplied as bare names, for example ",
      "`c(age, sex)`, or as a character vector."
    ),
    call. = FALSE
  )
}

.validate_data_vars <- function(data, vars, arg = "variables") {
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }

  missing_vars <- setdiff(vars, names(data))
  if (length(missing_vars) > 0L) {
    stop(
      "Variables not found in `data`: ",
      paste(missing_vars, collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  invisible(TRUE)
}

# Convert empty observed category labels to a safe, explicit display label.
# Empty strings are valid data values, but cannot safely be used as table
# column names or named-list indices.
.display_level <- function(x, blank = "(blank)") {
  x <- as.character(x)
  x[!is.na(x) & !nzchar(trimws(x))] <- blank
  x
}

# Assess whether Pearson chi-square expected-count guidance is inadequate.
# The conventional screen is an expected count below 1 in any cell, or more
# than 20% of expected counts below 5. This guides automatic selection only;
# it does not affect an explicitly requested association test.
.expected_count_screen <- function(expected) {
  values <- as.numeric(expected)
  values <- values[is.finite(values)]
  if (!length(values)) {
    return(list(
      sparse = TRUE, any_below_1 = NA, proportion_below_5 = NA,
      n_below_5 = NA_integer_, n_cells = 0L
    ))
  }
  any_below_1 <- any(values < 1)
  proportion_below_5 <- mean(values < 5)
  list(
    sparse = isTRUE(any_below_1) || proportion_below_5 > 0.20,
    any_below_1 = any_below_1,
    proportion_below_5 = proportion_below_5,
    n_below_5 = sum(values < 5),
    n_cells = length(values)
  )
}
