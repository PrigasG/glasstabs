# tests/testthat/test-dependencies.R
# Verifies the htmlDependency object and that bundled assets exist on disk.

test_that("useGlassTabs() returns an html_dependency", {
  expect_s3_class(useGlassTabs(), "html_dependency")
})

test_that("useGlassTabs() dependency is named 'glasstabs'", {
  expect_equal(useGlassTabs()$name, "glasstabs")
})

test_that("useGlassTabs() references glass.css", {
  expect_true("glass.css" %in% useGlassTabs()$stylesheet)
})

test_that("useGlassTabs() references glass.js", {
  expect_true("glass.js" %in% useGlassTabs()$script)
})

test_that("useGlassTabs() source directory exists on disk", {
  expect_true(dir.exists(useGlassTabs()$src$file))
})

test_that("useGlassTabs() glass.css file exists on disk", {
  dep <- useGlassTabs()
  expect_true(file.exists(file.path(dep$src$file, "glass.css")))
})

test_that("useGlassTabs() glass.js file exists on disk", {
  dep <- useGlassTabs()
  expect_true(file.exists(file.path(dep$src$file, "glass.js")))
})
