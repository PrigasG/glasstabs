
choices <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")


test_that("glassSelect() returns an htmltools object", {
  ui <- glassSelect("f", choices)
  expect_true(inherits(ui, c("shiny.tag", "shiny.tag.list")))
})

test_that("glassSelect() can disable the tongue treatment", {
  default <- as.character(glassSelect("f", choices))
  detached <- as.character(glassSelect("f", choices, tongue = FALSE))

  expect_false(grepl("gt-no-tongue", default, fixed = TRUE))
  expect_match(detached, "gt-gs-wrap[^\"]*gt-no-tongue")
  expect_error(
    glassSelect("f", choices, tongue = "no"),
    class = "glasstabs_error_bad_argument"
  )
})

test_that("glassSelect() uses bold labels by default and can opt out", {
  default <- as.character(glassSelect("f", choices, label = "Fruit"))
  regular <- as.character(glassSelect(
    "f", choices, label = "Fruit", label_bold = FALSE
  ))

  expect_match(default, 'class="gt-input-label"')
  expect_false(grepl("gt-label-regular", default, fixed = TRUE))
  expect_match(regular, 'class="gt-input-label gt-label-regular"')
  expect_error(
    glassSelect("f", choices, label_bold = 1),
    class = "glasstabs_error_bad_argument"
  )
})

test_that("glassSelect() supports label size and an optional search ring", {
  default <- as.character(glassSelect("f", choices, label = "Fruit"))
  customized <- as.character(glassSelect(
    "f", choices, label = "Fruit", label_size = "16px",
    search_focus_ring = TRUE
  ))

  expect_match(default, "--gt-label-size:14px", fixed = TRUE)
  expect_false(grepl("gt-search-ring", default, fixed = TRUE))
  expect_match(customized, "--gt-label-size:16px", fixed = TRUE)
  expect_match(customized, "gt-gs-wrap[^\"]*gt-search-ring")
  expect_error(
    glassSelect("f", choices, label_size = "large-ish"),
    class = "glasstabs_error_bad_argument"
  )
  expect_error(
    glassSelect("f", choices, search_focus_ring = "yes"),
    class = "glasstabs_error_bad_argument"
  )
})

test_that("glassSelect() supports a custom dark selector in auto theme mode", {
  html <- as.character(glassSelect(
    "f",
    choices,
    theme = "auto",
    dark_selector = "body.dark-mode"
  ))

  expect_match(html, "body.dark-mode #f-field", fixed = TRUE)
  expect_error(
    glassSelect("f", choices, theme = "auto", dark_selector = ""),
    class = "glasstabs_error_bad_argument"
  )
})

test_that("glassSelect() enables truncation tooltips by default", {
  default <- as.character(glassSelect("f", choices))
  disabled <- as.character(glassSelect(
    "f", choices, overflow_tooltip = "never"
  ))

  expect_match(default, 'data-overflow-tooltip="auto"', fixed = TRUE)
  expect_match(disabled, 'data-overflow-tooltip="never"', fixed = TRUE)
  expect_error(
    glassSelect("f", choices, overflow_tooltip = "always"),
    class = "glasstabs_error_bad_argument"
  )
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
  expect_error(glassSelect("f", NULL), class = "glasstabs_error_bad_choice")
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
    glassSelect("f", choices, selected = c("apple", "banana")),
    class = "glasstabs_error_bad_choice"
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
  expect_match(html, 'data-searchable="never"', fixed = TRUE)
  expect_match(html, 'class="gt-gs-search hidden"', fixed = TRUE)
})

test_that("glassSelect() automatic search follows the choice threshold", {
  five <- stats::setNames(letters[1:5], LETTERS[1:5])
  hidden <- as.character(glassSelect(
    "f", five, searchable = "auto", search_threshold = 6
  ))
  shown <- as.character(glassSelect(
    "f", five, searchable = "auto", search_threshold = 5
  ))

  expect_match(hidden, 'data-searchable="auto"', fixed = TRUE)
  expect_match(hidden, 'data-search-threshold="6"', fixed = TRUE)
  expect_match(hidden, 'class="gt-gs-search hidden"', fixed = TRUE)
  expect_match(shown, 'class="gt-gs-search"', fixed = TRUE)
})

test_that("glassSelect() validates search settings", {
  expect_error(
    glassSelect("f", choices, searchable = "sometimes"),
    class = "glasstabs_error_bad_argument"
  )
  expect_error(
    glassSelect("f", choices, search_threshold = 0),
    class = "glasstabs_error_bad_argument"
  )
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

test_that("glassSelect() auto theme emits auto class and Bootstrap dark override", {
  html <- as.character(glassSelect("f", choices, theme = "auto"))
  expect_match(html, "theme-auto", fixed = TRUE)
  expect_match(html, "theme-light", fixed = TRUE)
  expect_match(html, 'data-bs-theme="dark"', fixed = TRUE)
})

test_that("glassSelect() glass_select_theme() accent appears in HTML", {
  t <- glass_select_theme(accent_color = "#abcdef")
  html <- as.character(glassSelect("f", choices, theme = t))
  expect_match(html, "#abcdef")
})

test_that("glassSelect() custom focus ring appears in HTML", {
  theme <- glass_select_theme(focus_ring = "#a21caf")
  html <- as.character(glassSelect("f", choices, theme = theme))
  expect_match(html, "--ms-focus-ring:#a21caf", fixed = TRUE)
})

test_that("glassSelect() errors on invalid theme string", {
  expect_error(glassSelect("f", choices, theme = "monokai"), class = "glasstabs_error_bad_theme")
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
  expect_true(grepl('data-searchable="never"', html, fixed = TRUE))
  expect_true(grepl('data-clearable="true"', html, fixed = TRUE))
})

test_that("glassSelect() rejects invalid logical arguments", {
  for (argument in c("clearable", "include_all", "disabled", "server")) {
    args <- list(inputId = "f", choices = choices)
    args[[argument]] <- "yes"
    expect_error(
      do.call(glassSelect, args),
      class = "glasstabs_error_bad_argument",
      info = argument
    )
  }
})

test_that("glassSelect() rejects missing selected values", {
  expect_error(
    glassSelect("f", choices, selected = NA_character_),
    class = "glasstabs_error_bad_choice"
  )
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
  expect_false("disabled" %in% names(args[[2]]$choices[[1]]))
})

test_that("updateGlassSelect() sends disabled choice state only when requested", {
  send_mock <- mockery::mock()
  fake_session <- list(sendInputMessage = send_mock)

  updateGlassSelect(fake_session, "pick", choices = choices, disabled_choices = "banana")

  rows <- mockery::mock_args(send_mock)[[1]][[2]]$choices
  expect_false(rows[[1]]$disabled)
  expect_true(rows[[2]]$disabled)
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
  expect_error(updateGlassSelect(fake_session, "pick", shape = "oval"), class = "glasstabs_error_bad_argument")
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
    updateGlassSelect(fake_session, "pick", selected = c("apple", "banana")),
    class = "glasstabs_error_bad_choice"
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

test_that("updateGlassSelect() sends automatic search settings", {
  send_mock <- mockery::mock()
  fake_session <- list(sendInputMessage = send_mock)

  updateGlassSelect(
    fake_session,
    "pick",
    searchable = "auto",
    search_threshold = 5
  )

  data <- mockery::mock_args(send_mock)[[1]][[2]]
  expect_equal(data$searchable, "auto")
  expect_equal(data$search_threshold, 5L)
})

test_that("updateGlassSelect() uses the namespaced custom-message path for Shiny sessions", {
  send_mock <- mockery::mock()
  fake_session <- list(
    sendCustomMessage = send_mock,
    ns = function(id) paste0("module-", id)
  )

  updateGlassSelect(fake_session, "pick", search_threshold = 5)

  args <- mockery::mock_args(send_mock)[[1]]
  expect_equal(args[[1]], "glasstabs_update_select")
  expect_equal(args[[2]]$inputId, "module-pick")
  expect_equal(args[[2]]$data$search_threshold, 5L)
})

test_that("updateGlassSelect() validates session, disabled, and selection", {
  expect_error(
    updateGlassSelect(list(), "pick", selected = "apple"),
    class = "glasstabs_error_no_session"
  )
  fake_session <- list(sendInputMessage = function(...) NULL)
  expect_error(
    updateGlassSelect(fake_session, "pick", disabled = "yes"),
    class = "glasstabs_error_bad_argument"
  )
  expect_error(
    updateGlassSelect(fake_session, "pick", selected = NA_character_),
    class = "glasstabs_error_bad_choice"
  )
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
  expect_error(glassSelect("f", choices, shape = "circle"), class = "glasstabs_error_bad_argument")
})


test_that("glassSelect() rejects duplicate choice values", {
  expect_error(
    glassSelect("f", c(a = "x", b = "x")),
    class = "glasstabs_error_bad_choice"
  )
})

test_that("glassMultiSelect() rejects duplicate choice values", {
  expect_error(
    glassMultiSelect("f", c(a = "x", b = "x")),
    class = "glasstabs_error_bad_choice"
  )
})

test_that("glassSelect() renders a configurable no-matches text", {
  html <- as.character(
    glassSelect("s", c(a = "x", b = "y"), no_matches_text = "Nothing here")
  )
  expect_true(grepl('data-no-matches-text="Nothing here"', html, fixed = TRUE))
})

test_that("glassSelect() defaults no-matches text to 'No matches'", {
  html <- as.character(glassSelect("s", c(a = "x", b = "y")))
  expect_true(grepl('data-no-matches-text="No matches"', html, fixed = TRUE))
})

test_that("glassSelect() rejects a non-string no_matches_text", {
  expect_error(
    glassSelect("s", c(a = "x"), no_matches_text = 42),
    class = "glasstabs_error_bad_argument"
  )
  expect_error(
    glassSelect("s", c(a = "x"), no_matches_text = NA_character_),
    class = "glasstabs_error_bad_argument"
  )
})
