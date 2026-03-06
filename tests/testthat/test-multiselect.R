# tests/testthat/test-multiselect.R

choices <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")

# ── return type ───────────────────────────────────────────────────────────────

test_that("glassMultiSelect() returns an htmltools object", {
  ui <- glassMultiSelect("f", choices)
  expect_true(inherits(ui, c("shiny.tag", "shiny.tag.list")))
})

# ── choices ───────────────────────────────────────────────────────────────────

test_that("glassMultiSelect() accepts unnamed choices", {
  expect_no_error(glassMultiSelect("f", c("x", "y", "z")))
})

test_that("glassMultiSelect() renders all option values in HTML", {
  html <- as.character(glassMultiSelect("f", choices))
  expect_true(grepl("apple",  html))
  expect_true(grepl("banana", html))
  expect_true(grepl("cherry", html))
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

# ── check_style ───────────────────────────────────────────────────────────────

test_that("glassMultiSelect() check_style = 'checkbox' adds correct class", {
  html <- as.character(glassMultiSelect("f", choices, check_style = "checkbox"))
  expect_true(grepl("style-checkbox", html))
})

test_that("glassMultiSelect() check_style = 'check-only' adds correct class", {
  html <- as.character(glassMultiSelect("f", choices, check_style = "check-only"))
  expect_true(grepl("style-check-only", html))
})

test_that("glassMultiSelect() check_style = 'filled' adds correct class", {
  html <- as.character(glassMultiSelect("f", choices, check_style = "filled"))
  expect_true(grepl("style-filled", html))
})

test_that("glassMultiSelect() rejects invalid check_style", {
  expect_error(glassMultiSelect("f", choices, check_style = "dotted"))
})

# ── show_* flags ──────────────────────────────────────────────────────────────

test_that("glassMultiSelect() show_style_switcher = TRUE renders switcher", {
  html <- as.character(glassMultiSelect("f", choices, show_style_switcher = TRUE))
  expect_true(grepl("gt-style-switcher", html))
})

test_that("glassMultiSelect() show_style_switcher = FALSE omits switcher", {
  html <- as.character(glassMultiSelect("f", choices, show_style_switcher = FALSE))
  expect_false(grepl("gt-style-switcher", html))
})

test_that("glassMultiSelect() show_select_all = FALSE keeps element in DOM hidden", {
  html <- as.character(glassMultiSelect("f", choices, show_select_all = FALSE))
  expect_true(grepl("gt-ms-all",    html))
  expect_true(grepl("display:none", html))
})

test_that("glassMultiSelect() show_clear_all = FALSE keeps clear link in DOM", {
  html <- as.character(glassMultiSelect("f", choices, show_clear_all = FALSE))
  expect_true(grepl("gt-ms-clear", html))
})

test_that("glassMultiSelect() show_clear_all = TRUE renders clear link", {
  html <- as.character(glassMultiSelect("f", choices, show_clear_all = TRUE))
  expect_true(grepl("gt-ms-clear", html))
})

# ── theming ───────────────────────────────────────────────────────────────────

test_that("glassMultiSelect() dark theme injects CSS accent variable", {
  html <- as.character(glassMultiSelect("f", choices, theme = "dark"))
  expect_true(grepl("--ms-accent", html))
})

test_that("glassMultiSelect() light theme injects light accent color", {
  html <- as.character(glassMultiSelect("f", choices, theme = "light"))
  expect_true(grepl("#2563eb", html))
})

test_that("glassMultiSelect() glass_select_theme() accent appears in HTML", {
  t    <- glass_select_theme(accent_color = "#abcdef")
  html <- as.character(glassMultiSelect("f", choices, theme = t))
  expect_true(grepl("#abcdef", html))
})

test_that("glassMultiSelect() errors on invalid theme string", {
  expect_error(glassMultiSelect("f", choices, theme = "monokai"))
})

# ── hues ──────────────────────────────────────────────────────────────────────

test_that("glassMultiSelect() auto-assigns --opt-hue to all options", {
  html <- as.character(glassMultiSelect("f", choices, check_style = "filled"))
  expect_true(grepl("--opt-hue", html))
})

test_that("glassMultiSelect() respects manual hues", {
  html <- as.character(glassMultiSelect("f", choices,
                                        check_style = "filled",
                                        hues = c(apple = 10L, banana = 50L, cherry = 340L)))
  expect_true(grepl("--opt-hue:10",  html))
  expect_true(grepl("--opt-hue:50",  html))
  expect_true(grepl("--opt-hue:340", html))
})

# ── placeholder ───────────────────────────────────────────────────────────────

test_that("glassMultiSelect() custom placeholder appears when nothing selected", {
  html <- as.character(glassMultiSelect("f", choices,
                                        selected    = character(0),
                                        placeholder = "Choose a fruit"))
  expect_true(grepl("Choose a fruit", html))
})

test_that("glassMultiSelect() shows 'All categories' when all selected", {
  html <- as.character(glassMultiSelect("f", choices))
  expect_true(grepl("All categories", html))
})

# ── inputId scoping ───────────────────────────────────────────────────────────

test_that("glassMultiSelect() scopes element ids to inputId", {
  html <- as.character(glassMultiSelect("my_filter", choices))
  expect_true(grepl('id="my_filter-wrap"',     html, fixed = TRUE))
  expect_true(grepl('id="my_filter-trigger"',  html, fixed = TRUE))
  expect_true(grepl('id="my_filter-dropdown"', html, fixed = TRUE))
})

test_that("glassMultiSelect() sets data-input-id attribute", {
  html <- as.character(glassMultiSelect("my_filter", choices))
  expect_true(grepl('data-input-id="my_filter"', html, fixed = TRUE))
})

# ── glassFilterTags ───────────────────────────────────────────────────────────

test_that("glassFilterTags() returns an htmltools tag", {
  expect_true(inherits(glassFilterTags("f"), "shiny.tag"))
})

test_that("glassFilterTags() sets data-tags-for to inputId", {
  html <- as.character(glassFilterTags("my_filter"))
  expect_true(grepl('data-tags-for="my_filter"', html, fixed = TRUE))
})

test_that("glassFilterTags() includes gt-filter-tags class", {
  html <- as.character(glassFilterTags("f"))
  expect_true(grepl("gt-filter-tags", html))
})

test_that("glassFilterTags() appends extra CSS class", {
  html <- as.character(glassFilterTags("f", class = "my-class"))
  expect_true(grepl("my-class",       html))
  expect_true(grepl("gt-filter-tags", html))
})
