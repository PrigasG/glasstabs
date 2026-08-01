

test_that("glassTabPanel() returns correct class", {
  expect_s3_class(glassTabPanel("a", "Tab A"), "glassTabPanel")
})

test_that("glassTabPanel() stores value and label", {
  p <- glassTabPanel("my_tab", "My Label")
  expect_equal(p$value, "my_tab")
  expect_equal(p$label, "My Label")
})

test_that("glassTabPanel() selected defaults to FALSE", {
  expect_false(glassTabPanel("a", "A")$selected)
})

test_that("glassTabPanel() selected = TRUE is stored", {
  expect_true(glassTabPanel("a", "A", selected = TRUE)$selected)
})

test_that("glassTabPanel() stores content elements", {
  p <- glassTabPanel("a", "A", shiny::p("Hello"), shiny::p("World"))
  expect_length(p$content, 2)
})

test_that("glassTabPanel() accepts empty content", {
  expect_length(glassTabPanel("a", "A")$content, 0)
})


test_that("glassTabsUI() returns an htmltools object", {
  ui <- glassTabsUI("nav",
                    glassTabPanel("a", "A", selected = TRUE),
                    glassTabPanel("b", "B"))
  expect_true(inherits(ui, c("shiny.tag", "shiny.tag.list")))
})

test_that("glassTabsUI() errors with no panels", {
  expect_error(glassTabsUI("nav"), "at least one", class = "glasstabs_error_bad_argument")
})

test_that("glassTabsUI() errors if non-glassTabPanel passed", {
  expect_error(glassTabsUI("nav", "not a panel"), "glassTabPanel", class = "glasstabs_error_bad_argument")
})

test_that("glassTabsUI() errors on invalid selected value", {
  expect_error(
    glassTabsUI("nav",
                glassTabPanel("a", "A"),
                glassTabPanel("b", "B"),
                selected = "zzz"),
    "zzz",
    class = "glasstabs_error_bad_choice"
  )
})

test_that("glassTabsUI() accepts valid selected value without error", {
  expect_no_error(
    glassTabsUI("nav",
                glassTabPanel("a", "A"),
                glassTabPanel("b", "B"),
                selected = "b")
  )
})

test_that("glassTabsUI() accepts dark theme string", {
  expect_no_error(glassTabsUI("nav",
                              glassTabPanel("a", "A", selected = TRUE), theme = "dark"))
})

test_that("glassTabsUI() accepts light theme string", {
  expect_no_error(glassTabsUI("nav",
                              glassTabPanel("a", "A", selected = TRUE), theme = "light"))
})

test_that("glassTabsUI() accepts glass_tab_theme() object", {
  t <- glass_tab_theme(halo_bg = "rgba(255,0,0,0.1)")
  expect_no_error(glassTabsUI("nav",
                              glassTabPanel("a", "A", selected = TRUE), theme = t))
})

test_that("glassTabsUI() accepts auto theme string", {
  expect_no_error(glassTabsUI("nav",
                              glassTabPanel("a", "A", selected = TRUE), theme = "auto"))
})

test_that("glassTabsUI() errors on invalid theme string", {
  expect_error(
    glassTabsUI("nav", glassTabPanel("a", "A", selected = TRUE), theme = "hot-pink"),
    class = "glasstabs_error_bad_theme"
  )
})

test_that("glassTabsUI() renders HTML containing all tab values", {
  html <- as.character(glassTabsUI("nav",
                                   glassTabPanel("overview", "Overview", selected = TRUE),
                                   glassTabPanel("details",  "Details")))
  expect_true(grepl("overview", html))
  expect_true(grepl("details",  html))
})

test_that("glassTabsUI() scoped CSS block contains the widget id", {
  html <- as.character(glassTabsUI("mynav",
                                   glassTabPanel("a", "A", selected = TRUE)))
  expect_true(grepl("mynav-wrap", html))
})

test_that("glassTabsUI() injects all eight CSS variables", {
  html <- as.character(glassTabsUI("nav",
                                   glassTabPanel("a", "A", selected = TRUE)))
  for (v in c("--gt-tab-text:", "--gt-tab-active-text:", "--gt-halo-bg:",
              "--gt-halo-border:", "--gt-content-bg:", "--gt-content-border:",
              "--gt-card-bg:", "--gt-card-text:")) {
    expect_true(grepl(v, html, fixed = TRUE), info = v)
  }
})

test_that("glassTabsUI() custom halo_bg appears in scoped CSS", {
  t    <- glass_tab_theme(halo_bg = "rgba(1,2,3,0.5)")
  html <- as.character(glassTabsUI("nav",
                                    glassTabPanel("a", "A", selected = TRUE), theme = t))
  expect_true(grepl("rgba(1,2,3,0.5)", html, fixed = TRUE))
})

test_that("glassTabsUI() dark_selector uses dark content colors", {
  html <- as.character(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", selected = TRUE),
    theme = "light",
    dark_selector = "body.dark-mode"
  ))

  expect_true(grepl("body.dark-mode #nav-wrap", html, fixed = TRUE))
  expect_true(grepl("--gt-content-bg:transparent", html, fixed = TRUE))
  expect_true(grepl("--gt-card-bg:transparent", html, fixed = TRUE))
  expect_true(grepl("--gt-card-text:#cfe6ff", html, fixed = TRUE))
})

test_that("glassTabsUI() theme auto emits auto class and Bootstrap dark override", {
  html <- as.character(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", selected = TRUE),
    theme = "auto"
  ))

  expect_true(grepl("theme-auto", html, fixed = TRUE))
  expect_true(grepl("theme-light", html, fixed = TRUE))
  expect_true(grepl('[data-bs-theme="dark"] #nav-wrap', html, fixed = TRUE))
})

test_that("glassTabsUI() wrap = TRUE adds gt-container class", {
  html <- as.character(glassTabsUI("nav",
                                   glassTabPanel("a", "A", selected = TRUE), wrap = TRUE))
  expect_true(grepl("gt-container", html))
})

test_that("glassTabsUI() wrap = FALSE omits gt-container class", {
  html <- as.character(glassTabsUI("nav",
                                   glassTabPanel("a", "A", selected = TRUE), wrap = FALSE))
  expect_false(grepl("gt-container", html))
})

test_that("glassTabsUI() renders role=tablist on navbar", {
  html <- as.character(glassTabsUI("nav", glassTabPanel("a", "A", selected = TRUE)))
  expect_true(grepl('role="tablist"', html, fixed = TRUE))
})

test_that("glassTabsUI() renders aria-orientation on navbar", {
  horizontal <- as.character(glassTabsUI("nav", glassTabPanel("a", "A", selected = TRUE)))
  vertical <- as.character(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", selected = TRUE),
    orientation = "vertical"
  ))

  expect_true(grepl('aria-orientation="horizontal"', horizontal, fixed = TRUE))
  expect_true(grepl('aria-orientation="vertical"', vertical, fixed = TRUE))
})

test_that("glassTabsUI() renders role=tab and aria-selected on links", {
  html <- as.character(glassTabsUI("nav",
                                   glassTabPanel("a", "A", selected = TRUE),
                                   glassTabPanel("b", "B")))
  expect_true(grepl('role="tab"',          html, fixed = TRUE))
  expect_true(grepl('aria-selected="true"',  html, fixed = TRUE))
  expect_true(grepl('aria-selected="false"', html, fixed = TRUE))
})

test_that("glassTabsUI() renders role=tabpanel on panes", {
  html <- as.character(glassTabsUI("nav", glassTabPanel("a", "A", selected = TRUE)))
  expect_true(grepl('role="tabpanel"', html, fixed = TRUE))
})

test_that("glassTabsUI() links tabs and panels with roving focus", {
  html <- as.character(glassTabsUI(
    "nav",
    glassTabPanel("first", "First", selected = TRUE),
    glassTabPanel("second", "Second")
  ))

  expect_match(html, 'id="nav-tab-first"[^>]+tabindex="0"')
  expect_match(html, 'id="nav-tab-second"[^>]+tabindex="-1"')
  expect_match(html, 'aria-controls="nav-pane-first"')
  expect_match(html, 'id="nav-pane-first"[^>]+aria-labelledby="nav-tab-first"')
  expect_match(html, 'id="nav-pane-second"[^>]+aria-hidden="true"[^>]+tabindex="-1"')
})

test_that("glassTabsUI() renders each overflow mode and swipe preference", {
  panel <- glassTabPanel("one", "One")

  expect_match(as.character(glassTabsUI("a", panel)), "gt-overflow-scroll")
  expect_match(
    as.character(glassTabsUI("b", panel, overflow = "wrap")),
    "gt-overflow-wrap"
  )
  menu <- as.character(glassTabsUI("c", panel, overflow = "menu"))
  expect_match(menu, "gt-overflow-menu")
  expect_match(menu, "gt-tab-menu-select")
  expect_match(
    as.character(glassTabsUI("d", panel, swipe = TRUE)),
    'data-swipe="true"'
  )
})

test_that("glassTabsUI() explains invalid responsive arguments", {
  panel <- glassTabPanel("one", "One")

  expect_error(
    glassTabsUI("tabs", panel, overflow = "collapse"),
    "scroll.*wrap.*menu",
    class = "glasstabs_error_bad_argument"
  )
  expect_error(
    glassTabsUI("tabs", panel, swipe = "yes"),
    "TRUE or FALSE",
    class = "glasstabs_error_bad_argument"
  )
})

test_that("glassTabsUI() first panel is active by default", {
  html <- as.character(glassTabsUI("nav",
                                   glassTabPanel("first",  "First"),
                                   glassTabPanel("second", "Second")))
  expect_true(grepl("gt-tab-pane active", html))
})

test_that("glassTabsUI() respects explicit selected argument", {
  html <- as.character(glassTabsUI("nav",
                                   glassTabPanel("first",  "First"),
                                   glassTabPanel("second", "Second"),
                                   selected = "second"))
  expect_true(grepl('data-value="second"', html, fixed = TRUE))
})

test_that("glassTabsUI() indicator and orientation classes are emitted", {
  solid <- as.character(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", selected = TRUE),
    indicator = "solid"
  ))
  underline_vertical <- as.character(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", selected = TRUE),
    indicator = "underline",
    orientation = "vertical"
  ))
  glass <- as.character(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", selected = TRUE),
    indicator = "glass"
  ))

  expect_true(grepl("indicator-solid", solid, fixed = TRUE))
  expect_true(grepl("indicator-underline", underline_vertical, fixed = TRUE))
  expect_true(grepl("gt-vertical", underline_vertical, fixed = TRUE))
  expect_false(grepl("indicator-glass", glass, fixed = TRUE))
})

test_that("glassTabsUI() tab and text alignment classes are emitted", {
  centered <- as.character(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", selected = TRUE)
  ))
  left <- as.character(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", selected = TRUE),
    tab_align = "left"
  ))
  right <- as.character(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", selected = TRUE),
    tab_align = "right",
    text_align = "left"
  ))

  expect_true(grepl("gt-align-center", centered, fixed = TRUE))
  expect_true(grepl("gt-text-align-center", centered, fixed = TRUE))
  expect_true(grepl("gt-align-left", left, fixed = TRUE))
  expect_true(grepl("gt-align-right", right, fixed = TRUE))
  expect_true(grepl("gt-text-align-left", right, fixed = TRUE))
})

test_that("glassTabsUI() rejects invalid indicator, orientation, and tab alignment", {
  expect_error(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", selected = TRUE),
    indicator = "neon"
  ), class = "glasstabs_error_bad_argument")
  expect_error(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", selected = TRUE),
    orientation = "diagonal"
  ), class = "glasstabs_error_bad_argument")
  expect_error(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", selected = TRUE),
    tab_align = "wide"
  ), class = "glasstabs_error_bad_argument")
  expect_error(glassTabsUI(
    "nav",
    glassTabPanel("a", "A", selected = TRUE),
    text_align = "wide"
  ), class = "glasstabs_error_bad_argument")
  expect_error(
    glassTabsUI(
      "nav",
      glassTabPanel("a", "A", selected = TRUE),
      orientation = "vertical",
      overflow = "menu"
    ),
    "available only for horizontal tabs",
    class = "glasstabs_error_bad_choice"
  )
})


test_that("updateGlassTabsUI() sends correct custom message", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) {
      msgs[[length(msgs) + 1]] <<- list(type = type, message = message)
    },
    ns = shiny::NS(NULL)
  )

  updateGlassTabsUI(fake_session, "tabs", selected = "b")

  expect_length(msgs, 1)
  expect_equal(msgs[[1]]$type, "glasstabs_update_tabs")
  expect_equal(msgs[[1]]$message$ns, "tabs")
  expect_equal(msgs[[1]]$message$selected, "b")
})

test_that("updateGlassTabsUI() namespaces id via session$ns", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) {
      msgs[[length(msgs) + 1]] <<- list(type = type, message = message)
    },
    ns = shiny::NS("mymodule")
  )

  updateGlassTabsUI(fake_session, "tabs", selected = "overview")

  expect_equal(msgs[[1]]$message$ns, "mymodule-tabs")
  expect_equal(msgs[[1]]$message$selected, "overview")
})


test_that("showGlassTab() sends correct message", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS(NULL)
  )
  showGlassTab(fake_session, "tabs", "b")
  expect_equal(msgs[[1]]$type, "glasstabs_show_tab")
  expect_equal(msgs[[1]]$message$ns, "tabs")
  expect_equal(msgs[[1]]$message$value, "b")
})

test_that("hideGlassTab() sends correct message", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS(NULL)
  )
  hideGlassTab(fake_session, "tabs", "b")
  expect_equal(msgs[[1]]$type, "glasstabs_hide_tab")
  expect_equal(msgs[[1]]$message$ns, "tabs")
  expect_equal(msgs[[1]]$message$value, "b")
})

test_that("showGlassTab() and hideGlassTab() namespace via session$ns", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS("mod")
  )
  showGlassTab(fake_session, "tabs", "b")
  hideGlassTab(fake_session, "tabs", "b")
  expect_equal(msgs[[1]]$message$ns, "mod-tabs")
  expect_equal(msgs[[2]]$message$ns, "mod-tabs")
})


test_that("appendGlassTab() errors on non-glassTabPanel input", {
  fake_session <- list(
    sendCustomMessage = function(...) NULL,
    ns = shiny::NS(NULL)
  )
  expect_error(
    appendGlassTab(fake_session, "tabs", "not a panel"),
    "glassTabPanel",
    class = "glasstabs_error_bad_argument"
  )
})

test_that("appendGlassTab() sends correct message fields", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS(NULL)
  )
  tab <- glassTabPanel("new", "New Tab", shiny::p("Content"))
  appendGlassTab(fake_session, "tabs", tab)

  expect_equal(msgs[[1]]$type, "glasstabs_append_tab")
  expect_equal(msgs[[1]]$message$value, "new")
  expect_equal(msgs[[1]]$message$ns, "tabs")
  expect_false(msgs[[1]]$message$select)
  expect_true(nchar(msgs[[1]]$message$link_html) > 0)
  expect_true(nchar(msgs[[1]]$message$pane_html) > 0)
})

test_that("appendGlassTab() select = TRUE is passed through", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS(NULL)
  )
  appendGlassTab(fake_session, "tabs", glassTabPanel("x", "X"), select = TRUE)
  expect_true(msgs[[1]]$message$select)
})

test_that("appendGlassTab() link_html contains correct data-value", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS(NULL)
  )
  appendGlassTab(fake_session, "tabs", glassTabPanel("mytab", "My Tab"))
  expect_true(grepl('data-value="mytab"', msgs[[1]]$message$link_html, fixed = TRUE))
})

test_that("appendGlassTab() preserves icon markup", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS(NULL)
  )
  appendGlassTab(
    fake_session,
    "tabs",
    glassTabPanel("mytab", "My Tab", icon = shiny::icon("table"))
  )

  expect_true(grepl("gt-tab-icon", msgs[[1]]$message$link_html, fixed = TRUE))
  expect_true(grepl("gt-tab-label", msgs[[1]]$message$link_html, fixed = TRUE))
})

test_that("appendGlassTab() pane_html contains namespaced id", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS("mod")
  )
  appendGlassTab(fake_session, "tabs", glassTabPanel("mytab", "My Tab"))
  expect_true(grepl("mod-tabs-pane-mytab", msgs[[1]]$message$pane_html, fixed = TRUE))
})

test_that("removeGlassTab() sends correct message", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS(NULL)
  )
  removeGlassTab(fake_session, "tabs", "old")
  expect_equal(msgs[[1]]$type, "glasstabs_remove_tab")
  expect_equal(msgs[[1]]$message$ns, "tabs")
  expect_equal(msgs[[1]]$message$value, "old")
})

test_that("removeGlassTab() namespaces via session$ns", {
  msgs <- list()
  fake_session <- list(
    sendCustomMessage = function(type, message) msgs[[length(msgs) + 1]] <<- list(type = type, message = message),
    ns = shiny::NS("mod")
  )
  removeGlassTab(fake_session, "tabs", "old")
  expect_equal(msgs[[1]]$message$ns, "mod-tabs")
})
