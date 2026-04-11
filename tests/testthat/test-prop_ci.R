test_that("prop_ci() works without grouping", {
  res <- prop_ci(mtcars, var = vs)

  expect_s3_class(res, "gt_prop")
  expect_true(is.list(res))
  expect_true(all(c("summary", "table", "inputs", "notes") %in% names(res)))
  expect_equal(nrow(res$table), 1)
})

test_that("prop_ci() works with grouping", {
  res <- prop_ci(mtcars, var = vs, by = am)

  expect_s3_class(res, "gt_prop")
  expect_equal(res$inputs$by, "am")
  expect_equal(nrow(res$table), 2)
})

test_that("prop_ci() accepts character input", {
  res <- prop_ci(mtcars, var = "vs", by = "am")

  expect_s3_class(res, "gt_prop")
  expect_equal(res$inputs$var, "vs")
  expect_equal(res$inputs$by, "am")
})

test_that("prop_ci() supports explicit level", {
  res <- prop_ci(mtcars, var = vs, by = am, level = "1")

  expect_s3_class(res, "gt_prop")
  expect_equal(as.character(res$inputs$level), "1")
})

test_that("prop_ci() returns formatted proportion strings", {
  res <- prop_ci(mtcars, var = vs)

  expect_true("Proportion" %in% names(res$table))
  expect_true(any(grepl("%", res$table$Proportion)))
  expect_true(any(grepl("\\(", res$table$Proportion)))
})

test_that("prop_ci() grouped output includes Group column", {
  res <- prop_ci(mtcars, var = vs, by = am)

  expect_true("Group" %in% names(res$table))
})

test_that("tbl_stats() works on prop_ci output", {
  gt_obj <- prop_ci(mtcars, var = vs, by = am) |>
    tbl_stats()

  expect_s3_class(gt_obj, "gt_tbl")
})

test_that("to_flextable() works on prop_ci output", {
  ft <- prop_ci(mtcars, var = vs, by = am) |>
    to_flextable()

  expect_s3_class(ft, "flextable")
})

test_that("prop_ci() errors for missing variable", {
  expect_error(
    prop_ci(mtcars, var = not_a_var),
    regexp = "not found"
  )
})

test_that("prop_ci() errors for missing grouping variable", {
  expect_error(
    prop_ci(mtcars, var = vs, by = not_a_var),
    regexp = "not found"
  )
})

test_that("prop_ci() errors for invalid level", {
  expect_error(
    prop_ci(mtcars, var = vs, level = "not_a_level"),
    regexp = "level"
  )
})
