# tests/testthat/test-multiselect.R

choices <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")

# ── return type ───────────────────────────────────────────────────────────────

test_that("glassMultiSelect() returns an htmltools object", {
  ui <- glassMultiSelect("f", choices)
  expect_true(inherits(ui, c("shiny.tag", "shiny.tag.list")))
})

test_that("glassFilterTags() returns an htmltools tag", {
  expect_true(inherits(glassFilterTags("f"), "shiny.tag"))
})

# ── choices ───────────────────────────────────────────────────────────────────

test_that("glassMultiSelect() accepts unnamed choices", {
  expect_no_error(glassMultiSelect("f", c("x", "y", "z")))
})

test_that("glassMultiSelect() renders all option values in HTML", {
  html <- as.character(glassMultiSelect("f", choices))
  expect_match(html, "apple")
  expect_match(html, "banana")
  expect_match(html, "cherry")
})

test_that("glassMultiSelect() errors when choices is NULL", {
  expect_error(glassMultiSelect("f", NULL))
})

# ── selected ──────────────────────────────────────────────────────────────────

test_that("glassMultiSelect() defaults to all options checked", {
  html <- as.character(glassMultiSelect("f", choices))
  n <- lengths(regmatches(html, gregexpr("gt-ms-option checked", html)))
  expect_equal(n, 3L)
})

test_that("glassMultiSelect() respects partial initial selection", {
  html <- as.character(glassMultiSelect("f", choices, selected = "apple"))
  n <- lengths(regmatches(html, gregexpr("gt-ms-option checked", html)))
  expect_equal(n, 1L)
})

test_that("glassMultiSelect() respects empty initial selection", {
  html <- as.character(glassMultiSelect("f", choices, selected = character(0)))
  expect_false(grepl("gt-ms-option checked", html))
})

test_that("glassMultiSelect() drops invalid selected values", {
  html <- as.character(glassMultiSelect("f", choices, selected = c("apple", "nope")))
  n <- lengths(regmatches(html, gregexpr("gt-ms-option checked", html)))
  expect_equal(n, 1L)
  expect_match(html, "apple")
})

# ── label and placeholder ─────────────────────────────────────────────────────

test_that("glassMultiSelect() renders label when supplied", {
  html <- as.character(glassMultiSelect("f", choices, label = "Pick fruits"))
  expect_match(html, "Pick fruits")
  expect_match(html, 'class="gt-input-label"')
})

test_that("glassMultiSelect() custom placeholder appears when nothing selected", {
  html <- as.character(
    glassMultiSelect(
      "f",
      choices,
      selected = character(0),
      placeholder = "Choose a fruit"
    )
  )
  expect_match(html, "Choose a fruit")
})

test_that("glassMultiSelect() shows default all label when all selected", {
  html <- as.character(glassMultiSelect("f", choices))
  expect_match(html, "All categories")
})

test_that("glassMultiSelect() respects custom all_label", {
  html <- as.character(glassMultiSelect("f", choices, all_label = "Everything"))
  expect_match(html, "Everything")
  expect_match(html, 'data-all-label="Everything"', fixed = TRUE)
})

# ── check_style ───────────────────────────────────────────────────────────────

test_that("glassMultiSelect() check_style = 'checkbox' adds correct class", {
  html <- as.character(glassMultiSelect("f", choices, check_style = "checkbox"))
  expect_match(html, "style-checkbox")
})

test_that("glassMultiSelect() check_style = 'check-only' adds correct class", {
  html <- as.character(glassMultiSelect("f", choices, check_style = "check-only"))
  expect_match(html, "style-check-only")
})

test_that("glassMultiSelect() check_style = 'filled' adds correct class", {
  html <- as.character(glassMultiSelect("f", choices, check_style = "filled"))
  expect_match(html, "style-filled")
})

test_that("glassMultiSelect() rejects invalid check_style", {
  expect_error(glassMultiSelect("f", choices, check_style = "dotted"))
})

# ── show_* flags ──────────────────────────────────────────────────────────────

test_that("glassMultiSelect() show_style_switcher = TRUE renders switcher", {
  html <- as.character(glassMultiSelect("f", choices, show_style_switcher = TRUE))
  expect_match(html, "gt-style-switcher")
})

test_that("glassMultiSelect() show_style_switcher = FALSE omits switcher", {
  html <- as.character(glassMultiSelect("f", choices, show_style_switcher = FALSE))
  expect_false(grepl("gt-style-switcher", html))
})

test_that("glassMultiSelect() show_select_all = FALSE keeps element in DOM hidden", {
  html <- as.character(glassMultiSelect("f", choices, show_select_all = FALSE))
  expect_match(html, "gt-ms-all")
  expect_match(html, "display:none")
})

test_that("glassMultiSelect() show_clear_all = FALSE keeps clear link in DOM", {
  html <- as.character(glassMultiSelect("f", choices, show_clear_all = FALSE))
  expect_match(html, "gt-ms-clear")
  expect_match(html, "display:none")
})

test_that("glassMultiSelect() show_clear_all = TRUE renders clear link", {
  html <- as.character(glassMultiSelect("f", choices, show_clear_all = TRUE))
  expect_match(html, "gt-ms-clear")
})

# ── theming ───────────────────────────────────────────────────────────────────

test_that("glassMultiSelect() dark theme injects CSS accent variable", {
  html <- as.character(glassMultiSelect("f", choices, theme = "dark"))
  expect_match(html, "--ms-accent")
})

test_that("glassMultiSelect() light theme injects light accent color", {
  html <- as.character(glassMultiSelect("f", choices, theme = "light"))
  expect_match(html, "#2563eb")
})

test_that("glassMultiSelect() glass_select_theme() accent appears in HTML", {
  t <- glass_select_theme(accent_color = "#abcdef")
  html <- as.character(glassMultiSelect("f", choices, theme = t))
  expect_match(html, "#abcdef")
})

test_that("glassMultiSelect() errors on invalid theme string", {
  expect_error(glassMultiSelect("f", choices, theme = "monokai"))
})

# ── hues ──────────────────────────────────────────────────────────────────────

test_that("glassMultiSelect() auto-assigns --opt-hue to all options", {
  html <- as.character(glassMultiSelect("f", choices, check_style = "filled"))
  expect_match(html, "--opt-hue")
})

test_that("glassMultiSelect() respects manual named hues", {
  html <- as.character(
    glassMultiSelect(
      "f",
      choices,
      check_style = "filled",
      hues = c(apple = 10L, banana = 50L, cherry = 340L)
    )
  )
  expect_match(html, "--opt-hue:10")
  expect_match(html, "--opt-hue:50")
  expect_match(html, "--opt-hue:340")
})

test_that("glassMultiSelect() accepts unnamed hues of matching length", {
  expect_no_error(
    glassMultiSelect(
      "f",
      choices,
      check_style = "filled",
      hues = c(10L, 50L, 340L)
    )
  )
})

test_that("glassMultiSelect() errors on unnamed hues with wrong length", {
  expect_error(
    glassMultiSelect(
      "f",
      choices,
      check_style = "filled",
      hues = c(10L, 50L)
    )
  )
})

# ── inputId scoping ───────────────────────────────────────────────────────────

test_that("glassMultiSelect() scopes element ids to inputId", {
  html <- as.character(glassMultiSelect("my_filter", choices))
  expect_true(grepl('id="my_filter-wrap"', html, fixed = TRUE))
  expect_true(grepl('id="my_filter-trigger"', html, fixed = TRUE))
  expect_true(grepl('id="my_filter-dropdown"', html, fixed = TRUE))
  expect_true(grepl('id="my_filter-options"', html, fixed = TRUE))
  expect_true(grepl('id="my_filter-count"', html, fixed = TRUE))
  expect_true(grepl('id="my_filter-clear"', html, fixed = TRUE))
})

test_that("glassMultiSelect() sets data-input-id attribute", {
  html <- as.character(glassMultiSelect("my_filter", choices))
  expect_true(grepl('data-input-id="my_filter"', html, fixed = TRUE))
})

# ── glassFilterTags ───────────────────────────────────────────────────────────

test_that("glassFilterTags() sets data-tags-for to inputId", {
  html <- as.character(glassFilterTags("my_filter"))
  expect_true(grepl('data-tags-for="my_filter"', html, fixed = TRUE))
})

test_that("glassFilterTags() includes gt-filter-tags class", {
  html <- as.character(glassFilterTags("f"))
  expect_match(html, "gt-filter-tags")
})

test_that("glassFilterTags() appends extra CSS class", {
  html <- as.character(glassFilterTags("f", class = "my-class"))
  expect_match(html, "my-class")
  expect_match(html, "gt-filter-tags")
})

# ── reactive helper ───────────────────────────────────────────────────────────

test_that("glassMultiSelectValue() returns selected and style reactives", {
  input <- shiny::reactiveValues(
    pick = c("apple", "banana"),
    pick_style = "filled"
  )

  helper <- glassMultiSelectValue(input, "pick")

  expect_true(is.list(helper))
  expect_true(is.function(helper$selected))
  expect_true(is.function(helper$style))

  expect_equal(shiny::isolate(helper$selected()), c("apple", "banana"))
  expect_equal(shiny::isolate(helper$style()), "filled")
})

test_that("glassMultiSelectValue() falls back to empty selection and checkbox style", {
  input <- shiny::reactiveValues()

  helper <- glassMultiSelectValue(input, "pick")

  expect_equal(shiny::isolate(helper$selected()), character(0))
  expect_equal(shiny::isolate(helper$style()), "checkbox")
})
# ── updater ───────────────────────────────────────────────────────────────────

test_that("updateGlassMultiSelect() sends normalized choices", {
  send_mock <- mockery::mock()
  fake_session <- list(sendInputMessage = send_mock)

  updateGlassMultiSelect(fake_session, "pick", choices = choices)

  mockery::expect_called(send_mock, 1)
  args <- mockery::mock_args(send_mock)[[1]]

  expect_equal(args[[1]], "pick")
  expect_true(is.list(args[[2]]$choices))
  expect_equal(args[[2]]$choices[[1]]$label, "Apple")
  expect_equal(args[[2]]$choices[[1]]$value, "apple")
})

test_that("updateGlassMultiSelect() sends selected values unchanged", {
  send_mock <- mockery::mock()
  fake_session <- list(sendInputMessage = send_mock)

  updateGlassMultiSelect(
    fake_session,
    "pick",
    selected = c("apple", "cherry")
  )

  args <- mockery::mock_args(send_mock)[[1]]
  expect_equal(args[[1]], "pick")
  expect_equal(args[[2]]$selected, c("apple", "cherry"))
})

test_that("updateGlassMultiSelect() allows clearing with character(0)", {
  send_mock <- mockery::mock()
  fake_session <- list(sendInputMessage = send_mock)

  updateGlassMultiSelect(
    fake_session,
    "pick",
    selected = character(0)
  )

  args <- mockery::mock_args(send_mock)[[1]]
  expect_equal(args[[2]]$selected, character(0))
})

test_that("updateGlassMultiSelect() sends style when provided", {
  send_mock <- mockery::mock()
  fake_session <- list(sendInputMessage = send_mock)

  updateGlassMultiSelect(
    fake_session,
    "pick",
    check_style = "filled"
  )

  args <- mockery::mock_args(send_mock)[[1]]
  expect_equal(args[[2]]$style, "filled")
})

test_that("updateGlassMultiSelect() rejects invalid style", {
  fake_session <- list(sendInputMessage = function(...) NULL)

  expect_error(
    updateGlassMultiSelect(
      fake_session,
      "pick",
      check_style = "bad-style"
    )
  )
})

test_that("updateGlassMultiSelect() sends empty message when no updates supplied", {
  send_mock <- mockery::mock()
  fake_session <- list(sendInputMessage = send_mock)

  updateGlassMultiSelect(fake_session, "pick")

  args <- mockery::mock_args(send_mock)[[1]]
  expect_equal(args[[1]], "pick")
  expect_equal(args[[2]], list())
})
