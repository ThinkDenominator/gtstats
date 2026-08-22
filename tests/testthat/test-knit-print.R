test_that("gtstats objects render as tables in knitr documents", {
  skip_if_not_installed("knitr")

  method <- getS3method(
    "knit_print",
    "gtstats",
    envir = asNamespace("knitr"),
    optional = TRUE
  )

  expect_true(is.function(method))

  result <- describe_data(mtcars)
  rendered <- knitr::knit_print(result)

  expect_s3_class(rendered, "knit_asis")
  expect_match(as.character(rendered), "<table", fixed = TRUE)
  expect_false(grepl("&lt;br&gt;", as.character(rendered), fixed = TRUE))
})
