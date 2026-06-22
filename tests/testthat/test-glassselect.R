
choices <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")


test_that("glassSelect() returns an htmltools object", {
  ui <- glassSelect("f", choices)
  expect_true(inherits(ui, c("shiny.tag", "shiny.tag.list")))
})


test_that("glassSelect() accepts unnamed choices", {
  expect_no_error(glassSelect("f", c("x", "y", "z")))
})

test_that("glassSelect() renders all option values in HTML", {
  html <- as.character(glassSelect("f", choices))
  expect_match(html, "apple")
  expect_match(html, "banana")
  expect_match(html, "cherry")
})

test_that("glassSelect() renders labels in HTML", {
  html <- as.character(glassSelect("f", choices))
  expect_match(html, "Apple")
  expect_match(html, "Banana")
  expect_match(html, "Cherry")
})

test_that("glassSelect() errors when choices is NULL", {
  expect_error(glassSelect("f", NULL))
})


test_that("glassSelect() defaults to no selected option", {
  html <- as.character(glassSelect("f", choices))
  expect_false(grepl('gt-gs-option selected', html, fixed = TRUE))
})

test_that("glassSelect() respects initial selection", {
  html <- as.character(glassSelect("f", choices, selected = "banana"))
  n <- lengths(regmatches(html, gregexpr("gt-gs-option selected", html, fixed = TRUE)))
  expect_equal(n, 1L)
  expect_true(grepl('data-value="banana"', html, fixed = TRUE))
})

test_that("glassSelect() drops invalid selected values", {
  html <- as.character(glassSelect("f", choices, selected = "dragonfruit"))
  expect_false(grepl('gt-gs-option selected', html, fixed = TRUE))
})

test_that("glassSelect() rejects multiple selected values", {
  expect_error(
    glassSelect("f", choices, selected = c("apple", "banana"))
  )
})


test_that("glassSelect() renders label when supplied", {
  html <- as.character(glassSelect("f", choices, label = "Pick a fruit"))
  expect_match(html, "Pick a fruit")
  expect_match(html, 'class="gt-input-label"')
})

test_that("glassSelect() renders placeholder when nothing selected", {
  html <- as.character(glassSelect("f", choices, placeholder = "Choose one"))
  expect_match(html, "Choose one")
})

test_that("glassSelect() shows selected label in trigger", {
  html <- as.character(glassSelect("f", choices, selected = "banana"))
  expect_match(html, "Banana")
})


test_that("glassSelect() searchable = TRUE renders search input", {
  html <- as.character(glassSelect("f", choices, searchable = TRUE))
  expect_match(html, 'type="text"')
  expect_match(html, "Search options...")
})

test_that("glassSelect() searchable = FALSE omits search input", {
  html <- as.character(glassSelect("f", choices, searchable = FALSE))
  expect_false(grepl('type="text"', html, fixed = TRUE))
  expect_false(grepl("Search options...", html, fixed = TRUE))
})

test_that("glassSelect() clearable = TRUE renders clear control", {
  html <- as.character(glassSelect("f", choices, clearable = TRUE))
  expect_match(html, 'class="gt-gs-clear"')
  expect_match(html, ">Clear<")
  expect_false(grepl('display:none;', html, fixed = TRUE))
})

test_that("glassSelect() clearable = FALSE keeps clear control hidden in DOM", {
  html <- as.character(glassSelect("f", choices, clearable = FALSE))
  expect_match(html, 'class="gt-gs-clear"')
  expect_true(grepl('display:none;', html, fixed = TRUE))
})


test_that("glassSelect() include_all = TRUE prepends explicit all choice", {
  html <- as.character(
    glassSelect(
      "f",
      choices,
      include_all = TRUE,
      all_choice_label = "All fruits",
      all_choice_value = "__all__"
    )
  )

  expect_match(html, "All fruits")
  expect_true(grepl('data-value="__all__"', html, fixed = TRUE))
})

test_that("glassSelect() does not duplicate explicit all choice if value already present", {
  custom_choices <- c("All fruits" = "__all__", Apple = "apple", Banana = "banana")

  html <- as.character(
    glassSelect(
      "f",
      custom_choices,
      include_all = TRUE,
      all_choice_label = "All fruits",
      all_choice_value = "__all__"
    )
  )

  n <- lengths(regmatches(html, gregexpr('data-value="__all__"', html, fixed = TRUE)))
  expect_equal(n, 1L)
})


test_that("glassSelect() dark theme injects CSS accent variable", {
  html <- as.character(glassSelect("f", choices, theme = "dark"))
  expect_match(html, "--ms-accent")
})

test_that("glassSelect() light theme injects light accent color", {
  html <- as.character(glassSelect("f", choices, theme = "light"))
  expect_match(html, "#2563eb")
})

test_that("glassSelect() glass_select_theme() accent appears in HTML", {
  t <- glass_select_theme(accent_color = "#abcdef")
  html <- as.character(glassSelect("f", choices, theme = t))
  expect_match(html, "#abcdef")
})

test_that("glassSelect() errors on invalid theme string", {
  expect_error(glassSelect("f", choices, theme = "monokai"))
})


test_that("glassSelect() scopes element ids to inputId", {
  html <- as.character(glassSelect("my_select", choices))
  expect_true(grepl('id="my_select-wrap"', html, fixed = TRUE))
  expect_true(grepl('id="my_select-trigger"', html, fixed = TRUE))
  expect_true(grepl('id="my_select-dropdown"', html, fixed = TRUE))
  expect_true(grepl('id="my_select-options"', html, fixed = TRUE))
})

test_that("glassSelect() sets data-input-id attribute", {
  html <- as.character(glassSelect("my_select", choices))
  expect_true(grepl('data-input-id="my_select"', html, fixed = TRUE))
})

test_that("glassSelect() sets data-searchable and data-clearable attributes", {
  html <- as.character(glassSelect("my_select", choices, searchable = FALSE, clearable = TRUE))
  expect_true(grepl('data-searchable="false"', html, fixed = TRUE))
  expect_true(grepl('data-clearable="true"', html, fixed = TRUE))
})


test_that("glassSelectValue() returns a reactive", {
  input <- shiny::reactiveValues(pick = "banana")
  helper <- glassSelectValue(input, "pick")

  expect_true(is.function(helper))
  expect_equal(shiny::isolate(helper()), "banana")
})

test_that("glassSelectValue() falls back to NULL when input missing", {
  input <- shiny::reactiveValues()
  helper <- glassSelectValue(input, "pick")

  expect_null(shiny::isolate(helper()))
})


test_that("updateGlassSelect() sends normalized choices", {
  send_mock <- mockery::mock()
  fake_session <- list(sendInputMessage = send_mock)

  updateGlassSelect(fake_session, "pick", choices = choices)

  mockery::expect_called(send_mock, 1)
  args <- mockery::mock_args(send_mock)[[1]]

  expect_equal(args[[1]], "pick")
  expect_true(is.list(args[[2]]$choices))
  expect_equal(args[[2]]$choices[[1]]$label, "Apple")
  expect_equal(args[[2]]$choices[[1]]$value, "apple")
})

test_that("updateGlassSelect() sends selected value unchanged", {
  send_mock <- mockery::mock()
  fake_session <- list(sendInputMessage = send_mock)

  updateGlassSelect(fake_session, "pick", selected = "banana")

  args <- mockery::mock_args(send_mock)[[1]]
  expect_equal(args[[1]], "pick")
  expect_equal(args[[2]]$selected, "banana")
})

test_that("updateGlassSelect() sends shape when provided", {
  send_mock <- mockery::mock()
  fake_session <- list(sendInputMessage = send_mock)

  updateGlassSelect(fake_session, "pick", shape = "square")

  args <- mockery::mock_args(send_mock)[[1]]
  expect_equal(args[[2]]$shape, "square")
})

test_that("updateGlassSelect() omits shape when not supplied", {
  send_mock <- mockery::mock()
  fake_session <- list(sendInputMessage = send_mock)

  updateGlassSelect(fake_session, "pick", selected = "banana")

  args <- mockery::mock_args(send_mock)[[1]]
  expect_false("shape" %in% names(args[[2]]))
})

test_that("updateGlassSelect() rejects an invalid shape", {
  fake_session <- list(sendInputMessage = function(...) NULL)
  expect_error(updateGlassSelect(fake_session, "pick", shape = "oval"))
})

test_that("updateGlassSelect() allows clearing with character(0)", {
  send_mock <- mockery::mock()
  fake_session <- list(sendInputMessage = send_mock)

  updateGlassSelect(fake_session, "pick", selected = character(0))

  args <- mockery::mock_args(send_mock)[[1]]
  expect_equal(args[[2]]$selected, character(0))
})

test_that("updateGlassSelect() rejects multiple selected values", {
  fake_session <- list(sendInputMessage = function(...) NULL)

  expect_error(
    updateGlassSelect(fake_session, "pick", selected = c("apple", "banana"))
  )
})

test_that("updateGlassSelect() sends empty message when no updates supplied", {
  send_mock <- mockery::mock()
  fake_session <- list(sendInputMessage = send_mock)

  updateGlassSelect(fake_session, "pick")

  args <- mockery::mock_args(send_mock)[[1]]
  expect_equal(args[[1]], "pick")
  expect_equal(args[[2]], list())
})


test_that("glassSelect() accepts empty choices", {
  expect_no_error(glassSelect("f", character(0)))
})

test_that("glassSelect() with empty choices shows placeholder", {
  html <- as.character(glassSelect("f", character(0), placeholder = "Choose"))
  expect_true(grepl("Choose", html, fixed = TRUE))
})

test_that("glassSelect() with empty choices renders no option rows", {
  html <- as.character(glassSelect("f", character(0)))
  expect_false(grepl("gt-gs-option", html, fixed = TRUE))
})

test_that("glassSelect(server = TRUE) renders a bounded initial option set", {
  many <- stats::setNames(sprintf("value-%03d", 1:100), sprintf("Choice %03d", 1:100))
  html <- as.character(glassSelect("remote", many, server = TRUE, server_limit = 10))

  n <- lengths(regmatches(html, gregexpr("gt-gs-option", html, fixed = TRUE)))
  expect_equal(n, 10L)
  expect_true(grepl('data-server="true"', html, fixed = TRUE))
  expect_true(grepl('data-server-total="100"', html, fixed = TRUE))
  expect_true(grepl("value-010", html, fixed = TRUE))
  expect_false(grepl("value-011", html, fixed = TRUE))
})

test_that("glassSelect(server = TRUE) includes selected value outside initial slice", {
  many <- stats::setNames(sprintf("value-%03d", 1:100), sprintf("Choice %03d", 1:100))
  html <- as.character(glassSelect("remote", many, selected = "value-099", server = TRUE, server_limit = 10))

  n <- lengths(regmatches(html, gregexpr("gt-gs-option", html, fixed = TRUE)))
  expect_equal(n, 11L)
  expect_true(grepl("value-099", html, fixed = TRUE))
  expect_true(grepl("Choice 099", html, fixed = TRUE))
})

test_that(".gt_filter_choices() returns bounded server matches", {
  many <- c(Apple = "apple", Apricot = "apricot", Banana = "banana", Pineapple = "pineapple")
  filtered <- .gt_filter_choices(many, query = "app", limit = 1)

  expect_equal(filtered$total, 2L)
  expect_equal(filtered$labels, "Apple")
  expect_equal(filtered$values, "apple")
})

test_that(".gt_choice_payload() returns unnamed array-like lists", {
  payload <- .gt_choice_payload(
    labels = stats::setNames("Choice", "name"),
    values = stats::setNames("value", "name")
  )

  expect_null(names(payload))
  expect_equal(payload[[1]]$label, "Choice")
  expect_equal(payload[[1]]$value, "value")
})


test_that("glassSelect() defaults to rounded corners (no shape-square class)", {
  html <- as.character(glassSelect("f", choices))
  expect_false(grepl("shape-square", html, fixed = TRUE))
})

test_that("glassSelect(shape = 'square') adds the shape-square wrap class", {
  html <- as.character(glassSelect("f", choices, shape = "square"))
  expect_match(html, "gt-gs-wrap[^\"]*shape-square")
})

test_that("glassSelect(shape = 'rounded') is the explicit default", {
  html <- as.character(glassSelect("f", choices, shape = "rounded"))
  expect_false(grepl("shape-square", html, fixed = TRUE))
})

test_that("glassSelect() rejects an invalid shape", {
  expect_error(glassSelect("f", choices, shape = "circle"))
})
