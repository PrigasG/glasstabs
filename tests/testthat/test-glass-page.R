test_that("glassPage() creates a fillable bslib page with glasstabs", {
  skip_if_not_installed("bslib")

  page <- glassPage(shiny::h1("Hello"), title = "A glass app")
  html <- as.character(page)

  expect_s3_class(page, "shiny.tag.list")
  expect_match(html, "Hello")
  deps <- htmltools::findDependencies(page)
  expect_true(any(vapply(deps, function(dep) dep$name == "glasstabs", logical(1))))
})

test_that("glassPage() accepts a custom Bootstrap theme", {
  skip_if_not_installed("bslib")

  page <- glassPage(
    shiny::p("Content"),
    theme = bslib::bs_theme(version = 5, primary = "#2563eb"),
    fillable_mobile = TRUE
  )
  expect_s3_class(page, "shiny.tag.list")
})

test_that("glassPage() gives useful argument errors", {
  skip_if_not_installed("bslib")

  expect_error(
    glassPage(title = character()),
    "single non-empty string or NULL",
    class = "glasstabs_error_bad_argument"
  )
  expect_error(
    glassPage(theme = "dark"),
    "bslib theme",
    class = "glasstabs_error_bad_theme"
  )
  expect_error(
    glassPage(fillable_mobile = NA),
    "must be.*TRUE.*FALSE",
    class = "glasstabs_error_bad_argument"
  )
})
