test_that("correlation() works with default settings", {
  res <- correlation(mtcars, x = mpg, y = wt)

  expect_s3_class(res, "gt_correlation")
  expect_true(is.list(res))
  expect_true(all(c("summary", "table", "inputs", "notes") %in% names(res)))
  expect_equal(nrow(res$table), 1)
  expect_true(any(grepl("scatterplot", res$notes)))
  expect_true(any(grepl("independent", res$notes)))
})

test_that("correlation() accepts character input", {
  res <- correlation(mtcars, x = "mpg", y = "wt")

  expect_s3_class(res, "gt_correlation")
  expect_equal(res$inputs$x, "mpg")
  expect_equal(res$inputs$y, "wt")
})

test_that("correlation() preserves the original positional method API", {
  res <- correlation(mtcars, mpg, wt, "spearman")
  expect_identical(res$summary$method_used, "Spearman correlation")
})

test_that("correlation() uses complete observation pairs", {
  dat <- mtcars
  dat$mpg[c(1, 3)] <- NA_real_
  dat$wt[c(2, 3)] <- NA_real_

  res <- correlation(dat, x = mpg, y = wt)

  expect_equal(res$summary$n, 29)
  expect_equal(res$denominators$n_total, 32)
  expect_equal(res$denominators$n_nonmissing, 29)
  expect_equal(res$denominators$n_missing, 3)
  expect_identical(res$denominators$rule, "Complete finite observation pairs")
  expect_true(any(res$diagnostics$check == "Usable observation pairs"))
})

test_that("correlation() excludes non-finite pairs consistently and records them", {
  dat <- mtcars
  dat$mpg[[1L]] <- Inf
  dat$wt[[2L]] <- NaN

  res <- correlation(dat, x = mpg, y = wt)

  expect_equal(res$summary$n, 30L)
  expect_equal(res$summary$n_excluded, 2L)
  expect_equal(res$denominators$denominator, 30L)
  expect_match(res$diagnostics$value[2L], "excluded = 2", fixed = TRUE)
})

test_that("correlation() returns Pearson correlation when requested", {
  res <- correlation(mtcars, x = mpg, y = wt, method = "pearson")

  expect_s3_class(res, "gt_correlation")
  expect_equal(res$summary$method_used, "Pearson correlation")
  expect_true(any(grepl("Correlation \\(", names(res$table))))
  expect_identical(res$diagnostics$check[[1L]], "Correlation method")
  expect_match(res$method$selection_rule, "User specified pearson")
})

test_that("correlation() returns Spearman correlation when requested", {
  res <- correlation(mtcars, x = mpg, y = wt, method = "spearman")

  expect_s3_class(res, "gt_correlation")
  expect_equal(res$summary$method_used, "Spearman correlation")
  expect_identical(names(res$table), c(
    "Variables", "n", "Correlation", "p-value"
  ))
})

test_that("correlation() honours display digits and confidence level", {
  res <- correlation(
    mtcars,
    x = mpg,
    y = wt,
    method = "pearson",
    conf.level = 0.90,
    digits = 3
  )

  expect_true("Correlation (90% CI)" %in% names(res$table))
  expect_match(res$table[["Correlation (90% CI)"]], "^-0\\.868 \\(")
  expect_equal(res$table[["p-value"]], "<0.001")
})

test_that("correlation() returns concise publication output", {
  res <- correlation(mtcars, x = mpg, y = wt)

  expect_equal(nrow(res$table), 1L)
  expect_true(all(c("Variables", "n", "p-value") %in% names(res$table)))
  expect_true(any(grepl("^Correlation", names(res$table))))
  expect_false(any(c(
    "X", "Y", "Method", "Strength", "Direction", "Interpretation"
  ) %in% names(res$table)))
  expect_equal(res$summary$direction, "Negative")
  expect_true(nzchar(res$summary$strength))
})

test_that("correlation() rejects retired output controls", {
  expect_error(
    correlation(mtcars, mpg, wt, output = "tibble"),
    "unused argument"
  )
  expect_error(
    correlation(mtcars, mpg, wt, quiet = TRUE),
    "unused argument"
  )
})

test_that("to_gt() works on correlation output", {
  gt_obj <- correlation(mtcars, x = mpg, y = wt) |>
    to_gt()

  expect_s3_class(gt_obj, "gt_tbl")
})

test_that("to_flextable() works on correlation output", {
  ft <- correlation(mtcars, x = mpg, y = wt) |>
    to_flextable()

  expect_s3_class(ft, "flextable")
})

test_that("correlation() errors when x is missing from data", {
  expect_error(
    correlation(mtcars, x = not_a_var, y = wt),
    regexp = "not found"
  )
})

test_that("correlation() errors when y is missing from data", {
  expect_error(
    correlation(mtcars, x = mpg, y = not_a_var),
    regexp = "not found"
  )
})

test_that("correlation() errors when x and y are the same", {
  expect_error(
    correlation(mtcars, x = mpg, y = mpg),
    regexp = "must be different"
  )
})

test_that("correlation() errors when a variable is non-continuous", {
  expect_error(
    correlation(mtcars, x = mpg, y = am),
    regexp = "continuous"
  )
})

test_that("correlation() errors clearly for constant finite variables", {
  dat <- data.frame(
    x = c(rep(1, 3), 2:6, rep(NA_real_, 5)),
    y = c(1:3, rep(NA_real_, 5), 4:8)
  )
  expect_error(
    correlation(dat, x, y),
    "at least two distinct finite values"
  )
})

test_that("correlation() creates a tidy publication matrix", {
  res <- correlation(mtcars, vars = c(mpg, disp, hp, wt))

  expect_s3_class(res, "gt_correlation_matrix")
  expect_s3_class(res, "gt_correlation")
  expect_equal(nrow(res$summary), 6L)
  expect_equal(nrow(res$table), 4L)
  expect_equal(names(res$table), c("Variable", "mpg", "disp", "hp", "wt"))
  expect_identical(res$method$method_used, "pearson")
  expect_true(all(c("p_adjusted", "adjust_method") %in% names(res$summary)))
  expect_s3_class(to_gt(res), "gt_tbl")
  expect_s3_class(to_flextable(res), "flextable")
})

test_that("matrix mode uses one transparent method and pairwise denominators", {
  dat <- mtcars
  dat$mpg[[1L]] <- NA_real_
  dat$disp[[2L]] <- NA_real_
  dat$hp <- dat$hp^3
  res <- correlation(
    dat,
    vars = c(mpg, disp, hp),
    method = "auto",
    display = "estimate_p",
    adjust = "holm"
  )

  expect_identical(res$method$method_used, "spearman")
  expect_true(all(res$summary$method_used == "Spearman correlation"))
  expect_true(length(unique(res$summary$n)) > 1L)
  expect_true(all(res$summary$p_adjusted >= res$summary$p_value))
  expect_match(res$method$selection_rule, "Spearman was used throughout")
})

test_that("matrix mode validates mutually exclusive and continuous inputs", {
  expect_error(
    correlation(mtcars, x = mpg, y = wt, vars = c(mpg, wt)),
    "either `x` and `y`, or `vars`"
  )
  expect_error(correlation(mtcars, vars = mpg), "at least two")
  expect_error(correlation(mtcars, vars = c(mpg, am)), "not a continuous")
})

test_that("matrix mode supports layout, ordering, diagonal, and cell content", {
  upper <- correlation(
    mtcars,
    vars = c(wt, mpg, hp, disp),
    triangle = "upper",
    order = "alphabetical",
    show_diagonal = FALSE,
    display = "estimate_p_n"
  )

  expect_identical(names(upper$table), c("Variable", "disp", "hp", "mpg", "wt"))
  expect_true(all(vapply(seq_len(4L), function(i) upper$table[[i + 1L]][[i]] == "", logical(1))))
  expect_true(any(grepl("n = 32", unlist(upper$table), fixed = TRUE)))

  clustered <- correlation(
    mtcars,
    vars = c(mpg, disp, hp, wt),
    order = "cluster",
    display = "estimate_n"
  )
  expect_setequal(clustered$inputs$vars, c("mpg", "disp", "hp", "wt"))
  expect_identical(clustered$inputs$order, "cluster")
})
