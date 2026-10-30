# Accessibility, CSP, and dropdown lifecycle

test_that("glass.css uses color-mix only as progressive enhancement", {
  css_path <- file.path("inst", "www", "glass.css")
  if (!file.exists(css_path)) {
    css_path <- system.file("www", "glass.css", package = "glasstabs")
  }

  css <- paste(readLines(css_path, warn = FALSE), collapse = "\n")
  # Ignore comments: only real declarations count.
  css <- gsub("(?s)/\\*.*?\\*/", "", css, perl = TRUE)
  # color-mix() is allowed only where an unsupported browser degrades
  # gracefully: the active-tab inner edge light (the whole box-shadow
  # declaration is dropped, leaving no shadow) and the tab-wrap top border
  # (falls back to the border shorthand color set just above it).
  mix_lines <- grep(
    "color-mix\\(",
    strsplit(css, "\n", fixed = TRUE)[[1]],
    value = TRUE
  )
  expect_true(length(mix_lines) > 0)
  for (line in mix_lines) {
    expect_true(
      grepl("box-shadow:inset", line, fixed = TRUE) ||
        grepl("border-top-color:color-mix", line, fixed = TRUE),
      info = line
    )
  }
  expect_true(grepl("@media (forced-colors: active)", css, fixed = TRUE))
  expect_true(grepl("@media (prefers-reduced-motion: reduce)", css, fixed = TRUE))
  expect_true(grepl("@supports not", css, fixed = TRUE))
  expect_true(grepl("gt-overflow-scroll", css, fixed = TRUE))
  expect_true(grepl(".gt-ms-dropdown{\n  position:absolute", css, fixed = TRUE))
  expect_true(grepl(".gt-gs-dropdown{\n  position:absolute", css, fixed = TRUE))
  expect_true(grepl('[dir="rtl"]', css, fixed = TRUE))
  expect_false(grepl("transform:translate(-50%,-50%) scale", css, fixed = TRUE))
  expect_true(grepl("color-scheme:dark", css, fixed = TRUE))
  expect_true(grepl("color-scheme:light", css, fixed = TRUE))
  expect_true(grepl(".gt-tab-menu-select option", css, fixed = TRUE))
  expect_true(grepl(".gt-gs-trigger:focus-visible", css, fixed = TRUE))
  expect_true(grepl(".gt-ms-search:focus-within", css, fixed = TRUE))
  expect_true(grepl(".gt-ms-dropdown.gt-search-ring", css, fixed = TRUE))
  expect_true(grepl("background:var(--ms-tx-08)", css, fixed = TRUE))
  expect_true(grepl("--ms-focus-ring", css, fixed = TRUE))
})

test_that("select widgets render ARIA combobox/listbox semantics", {
  gs <- as.character(glassSelect("pick", c(Apple = "apple"), selected = "apple"))
  expect_true(grepl('role="combobox"', gs, fixed = TRUE))
  expect_true(grepl('aria-haspopup="listbox"', gs, fixed = TRUE))
  expect_true(grepl('aria-expanded="false"', gs, fixed = TRUE))
  expect_true(grepl('role="listbox"', gs, fixed = TRUE))
  expect_true(grepl('role="option"', gs, fixed = TRUE))
  expect_true(grepl('aria-selected="true"', gs, fixed = TRUE))

  ms <- as.character(glassMultiSelect("filter", c(Apple = "apple"), selected = "apple"))
  expect_true(grepl('role="combobox"', ms, fixed = TRUE))
  expect_true(grepl('aria-controls="filter-dropdown"', ms, fixed = TRUE))
  expect_true(grepl('role="listbox"', ms, fixed = TRUE))
  expect_true(grepl('role="option"', ms, fixed = TRUE))
  expect_true(grepl('aria-selected="true"', ms, fixed = TRUE))
})

test_that("scoped select CSS contains precomputed alpha variables", {
  html <- as.character(glassSelect("pick", c(Apple = "apple")))

  expect_true(grepl("--ms-ac-12:", html, fixed = TRUE))
  expect_true(grepl("--ms-ac-75:", html, fixed = TRUE))
  expect_true(grepl("--ms-tx-03:", html, fixed = TRUE))
  expect_true(grepl("--ms-tx-80:", html, fixed = TRUE))
  expect_true(grepl("--ms-ac-tx-75:", html, fixed = TRUE))
})

test_that("inline style tags honor glasstabs.csp_nonce option", {
  old <- getOption("glasstabs.csp_nonce")
  on.exit(options(glasstabs.csp_nonce = old), add = TRUE)

  options(glasstabs.csp_nonce = "nonce-123")
  html <- as.character(glassSelect("pick", c(Apple = "apple")))

  expect_true(grepl('nonce="nonce-123"', html, fixed = TRUE))
})

test_that("glass.js keeps ARIA and focus state in sync", {
  js_path <- file.path("inst", "www", "glass.js")
  if (!file.exists(js_path)) {
    js_path <- system.file("www", "glass.js", package = "glasstabs")
  }

  js <- paste(readLines(js_path, warn = FALSE), collapse = "\n")
  expect_true(grepl("aria-expanded", js, fixed = TRUE))
  expect_true(grepl("aria-selected", js, fixed = TRUE))
  expect_true(grepl("--ms-ac-12", js, fixed = TRUE))
  expect_true(grepl("--ms-tx-80", js, fixed = TRUE))
  expect_true(grepl("glassTabsBinding", js, fixed = TRUE))
  expect_true(grepl("MutationObserver", js, fixed = TRUE))
  expect_true(grepl("closeAndReturnFocus", js, fixed = TRUE))
  expect_true(grepl("asValueArray(data.selected)", js, fixed = TRUE))
  expect_true(grepl("glasstabs_update_multiselect", js, fixed = TRUE))
  expect_true(grepl("applyMultiSelectUpdate(msg, attempt + 1)", js, fixed = TRUE))
  expect_true(grepl("applyMultiSelectUpdate(msg, 0); }, 50)", js, fixed = TRUE))
  expect_true(grepl("shiny:sessioninitialized.glasstabs", js, fixed = TRUE))
  expect_true(grepl("e.key === 'Escape' || e.key === 'Tab'", js, fixed = TRUE))
  expect_true(grepl("trigger.focus()", js, fixed = TRUE))
  expect_true(grepl("createOptionNavigator", js, fixed = TRUE))
  expect_true(grepl("'--ms-focus-ring'", js, fixed = TRUE))
  expect_true(grepl("function commitSwitch", js, fixed = TRUE))
  expect_true(grepl("e.key === 'Home'", js, fixed = TRUE))
  expect_true(grepl("prefers-reduced-motion: reduce", js, fixed = TRUE))
  expect_true(grepl("touchstart", js, fixed = TRUE))
  expect_true(grepl("gt-badge-updated", js, fixed = TRUE))
  expect_true(grepl(
    "glasstabs_close_selects', function (msg)",
    js,
    fixed = TRUE
  ))
})

test_that("closeGlass* helpers send dropdown close messages", {
  msgs <- list()
  fake_session <- list(
    ns = function(id) paste0("ns-", id),
    sendInputMessage = function(inputId, message) {
      msgs[[length(msgs) + 1]] <<- list(inputId = inputId, message = message)
    },
    sendCustomMessage = function(type, message) {
      msgs[[length(msgs) + 1]] <<- list(type = type, message = message)
    }
  )

  expect_invisible(closeGlassSelect(fake_session, "region"))
  expect_equal(msgs[[1]]$inputId, "region")
  expect_equal(msgs[[1]]$message, list(close = TRUE))

  expect_invisible(closeGlassMultiSelect(fake_session, "filters"))
  expect_equal(msgs[[2]]$inputId, "filters")
  expect_equal(msgs[[2]]$message, list(close = TRUE))

  expect_invisible(closeAllGlassSelects(fake_session))
  expect_equal(msgs[[3]]$type, "glasstabs_close_selects")
  expect_equal(msgs[[3]]$message, list())
})

test_that("closeGlass* helpers reject non-character input ids", {
  fake_session <- list(sendInputMessage = function(...) NULL)

  expect_error(
    closeGlassSelect(fake_session, 1),
    class = "glasstabs_error_bad_argument"
  )
  expect_error(
    closeGlassMultiSelect(fake_session, NA_character_),
    class = "glasstabs_error_bad_argument"
  )
})

test_that("glass.js exposes close lifecycle hooks for select dropdowns", {
  js_path <- file.path("inst", "www", "glass.js")
  if (!file.exists(js_path)) {
    js_path <- system.file("www", "glass.js", package = "glasstabs")
  }

  js <- paste(readLines(js_path, warn = FALSE), collapse = "\n")
  expect_true(grepl("setDropdownOpenState", js, fixed = TRUE))
  expect_true(grepl("inputId + '_open'", js, fixed = TRUE))
  expect_true(grepl("glasstabs_close_select", js, fixed = TRUE))
  expect_true(grepl("glasstabs_close_selects", js, fixed = TRUE))
  expect_true(grepl("hasOwn(data, 'close')", js, fixed = TRUE))
  expect_true(grepl("document.addEventListener('pointerdown'", js, fixed = TRUE))
  expect_true(grepl("document.addEventListener('shiny:value'", js, fixed = TRUE))
  expect_true(grepl("document.addEventListener('shiny:disconnected'", js, fixed = TRUE))
})

test_that("teleported select dropdowns clamp to the viewport", {
  js <- paste(readLines(system.file("www", "glass.js", package = "glasstabs"), warn = FALSE), collapse = "\n")

  expect_true(grepl("positionTeleportedDropdown", js, fixed = TRUE))
  expect_true(grepl("window.innerWidth", js, fixed = TRUE))
  expect_true(grepl("dropdown.style.maxWidth", js, fixed = TRUE))
  expect_true(grepl("dropdown.style.minWidth", js, fixed = TRUE))
})

test_that("teleported select dropdowns match their trigger width", {
  js <- paste(readLines(system.file("www", "glass.js", package = "glasstabs"), warn = FALSE), collapse = "\n")

  expect_true(grepl("var triggerWidth = Math.ceil(rect.width || 160)", js, fixed = TRUE))
  expect_true(grepl("var dropdownWidth = Math.min(triggerWidth, maxWidth)", js, fixed = TRUE))
  expect_true(grepl("dropdown.style.width = dropdownWidth + 'px'", js, fixed = TRUE))
  expect_true(grepl("dropdown.offsetWidth", js, fixed = TRUE))
  expect_true(grepl("gt-compact-controls", js, fixed = TRUE))
})

test_that("detached select dropdowns use a short native-like transition", {
  js <- paste(readLines(system.file("www", "glass.js", package = "glasstabs"), warn = FALSE), collapse = "\n")
  css <- paste(readLines(system.file("www", "glass.css", package = "glasstabs"), warn = FALSE), collapse = "\n")

  expect_true(grepl("'gt-no-tongue'", js, fixed = TRUE))
  expect_true(grepl("var overlap = tongue ? 1 : -6", js, fixed = TRUE))
  expect_true(grepl("wrap.classList.contains('gt-no-tongue')", js, fixed = TRUE))
  expect_true(grepl(".gt-ms-dropdown.gt-no-tongue", css, fixed = TRUE))
  expect_true(grepl(".gt-gs-dropdown.gt-no-tongue", css, fixed = TRUE))
  expect_true(grepl("transform:translateY(-4px)", css, fixed = TRUE))
  expect_true(grepl("transition:opacity 100ms ease-out,transform 120ms ease-out", css, fixed = TRUE))
  expect_true(grepl("transform:translateY(4px)", css, fixed = TRUE))
})

test_that("single-color filled multi-selects use the theme accent", {
  css <- paste(readLines(system.file("www", "glass.css", package = "glasstabs"), warn = FALSE), collapse = "\n")
  js <- paste(readLines(system.file("www", "glass.js", package = "glasstabs"), warn = FALSE), collapse = "\n")

  expect_true(grepl(".gt-ms-dropdown.fill-single.style-filled", css, fixed = TRUE))
  expect_true(grepl("background:var(--ms-accent)!important", css, fixed = TRUE))
  expect_true(grepl("'fill-single'", js, fixed = TRUE))
  expect_true(grepl("'gt-search-ring'", js, fixed = TRUE))
  expect_true(grepl("createOverflowTooltip", js, fixed = TRUE))
  expect_true(grepl("scrollWidth > labelEl.clientWidth + 1", js, fixed = TRUE))
  expect_true(grepl(".gt-overflow-tooltip", css, fixed = TRUE))
  expect_true(grepl("max-width:min(36rem,calc(100vw - 24px))", css, fixed = TRUE))
})

test_that("glass.js does not ship debug-only message handlers", {
  js_path <- file.path("inst", "www", "glass.js")
  if (!file.exists(js_path)) {
    js_path <- system.file("www", "glass.js", package = "glasstabs")
  }

  js <- paste(readLines(js_path, warn = FALSE), collapse = "\n")
  expect_false(grepl("glasstabs_debug_ping", js, fixed = TRUE))
  expect_false(grepl("glasstabs_debug_handlers_registered", js, fixed = TRUE))
})

test_that("select chrome controls are real buttons with keyboard semantics", {
  # Single-select: label association, search name, clear button.
  gs <- as.character(glassSelect(
    "pick",
    c(Apple = "apple", Banana = "banana"),
    label = "Fruit",
    selected = "apple",
    clearable = TRUE
  ))
  expect_true(grepl('id="pick-field-label"', gs, fixed = TRUE))
  expect_true(grepl('aria-labelledby="pick-field-label"', gs, fixed = TRUE))
  expect_true(grepl('aria-label="Search options"', gs, fixed = TRUE))
  expect_true(grepl(
    '<button type="button" tabindex="-1" class="gt-gs-clear"',
    gs, fixed = TRUE
  ))
  expect_false(grepl('<span class="gt-gs-clear"', gs, fixed = TRUE))
  # No label: the trigger falls back to its own text span as its name.
  gs_no_label <- as.character(glassSelect(
    "pick2",
    c(Apple = "apple"),
    selected = "apple",
    clearable = TRUE
  ))
  expect_false(grepl('id="pick2-field-label"', gs_no_label, fixed = TRUE))
  expect_true(grepl('aria-labelledby="pick2-label"', gs_no_label, fixed = TRUE))

  # Multi-select: multiselectable listbox, switcher buttons, tri-state
  # select-all, clear button.
  ms <- as.character(glassMultiSelect(
    "filter",
    c(Apple = "apple", Banana = "banana"),
    label = "Fruit",
    selected = "apple"
  ))
  expect_true(grepl('id="filter-field-label"', ms, fixed = TRUE))
  expect_true(grepl('aria-labelledby="filter-field-label"', ms, fixed = TRUE))
  expect_true(grepl('aria-multiselectable="true"', ms, fixed = TRUE))
  expect_true(grepl('aria-label="Search options"', ms, fixed = TRUE))
  expect_true(grepl('role="group"', ms, fixed = TRUE))
  expect_true(grepl(
    '<button type="button" tabindex="-1" class="gt-style-btn',
    ms, fixed = TRUE
  ))
  expect_true(grepl('aria-pressed="true"', ms, fixed = TRUE))
  expect_true(grepl('aria-pressed="false"', ms, fixed = TRUE))
  # One of two selected: the select-all row reports mixed, and it is a
  # checkbox now, not an option carrying aria-selected.
  expect_true(grepl('role="checkbox"', ms, fixed = TRUE))
  expect_true(grepl('aria-checked="mixed"', ms, fixed = TRUE))
  expect_false(grepl('gt-ms-all"[^>]*aria-selected', ms))
  expect_true(grepl(
    '<button type="button" tabindex="-1" class="gt-ms-clear"',
    ms, fixed = TRUE
  ))
  expect_false(grepl('<span class="gt-ms-clear"', ms, fixed = TRUE))
  expect_false(grepl('<div class="gt-style-btn"', ms, fixed = TRUE))

  # All selected / none selected: checked true / false.
  ms_all <- as.character(glassMultiSelect(
    "fall",
    c(Apple = "apple", Banana = "banana"),
    selected = c("apple", "banana")
  ))
  expect_true(grepl('aria-checked="true"', ms_all, fixed = TRUE))
  ms_none <- as.character(glassMultiSelect(
    "fnone",
    c(Apple = "apple", Banana = "banana"),
    selected = character(0)
  ))
  expect_true(grepl('aria-checked="false"', ms_none, fixed = TRUE))

  # Chrome buttons carry a visible keyboard focus ring, and the JS keeps
  # chrome navigation state (focus index, pressed/checked attributes).
  css_path <- file.path("inst", "www", "glass.css")
  if (!file.exists(css_path)) {
    css_path <- system.file("www", "glass.css", package = "glasstabs")
  }
  css <- paste(readLines(css_path, warn = FALSE), collapse = "\n")
  expect_true(grepl(".gt-style-btn:focus-visible", css, fixed = TRUE))
  expect_true(grepl(".gt-ms-all:focus-visible", css, fixed = TRUE))
  expect_true(grepl(".gt-ms-clear:focus-visible", css, fixed = TRUE))
  expect_true(grepl(".gt-gs-clear:focus-visible", css, fixed = TRUE))

  js_path <- file.path("inst", "www", "glass.js")
  if (!file.exists(js_path)) {
    js_path <- system.file("www", "glass.js", package = "glasstabs")
  }
  js <- paste(readLines(js_path, warn = FALSE), collapse = "\n")
  expect_true(grepl("handleChromeAwareNav", js, fixed = TRUE))
  expect_true(grepl("aria-checked", js, fixed = TRUE))
  expect_true(grepl("aria-pressed", js, fixed = TRUE))
  expect_true(grepl("chromeIndex", js, fixed = TRUE))
})
