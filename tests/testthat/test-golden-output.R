golden_session <- function(prefix = NULL) {
  messages <- list()

  list(
    messages = function() messages,
    ns = shiny::NS(prefix),
    sendCustomMessage = function(type, message) {
      messages[[length(messages) + 1L]] <<- list(
        method = "sendCustomMessage",
        type = type,
        message = message
      )
    },
    sendInputMessage = function(inputId, message) {
      messages[[length(messages) + 1L]] <<- list(
        method = "sendInputMessage",
        inputId = inputId,
        message = message
      )
    }
  )
}

test_that("representative widget HTML remains byte-stable", {
  choices <- c(Apple = "apple", Banana = "banana")
  configurations <- expand.grid(
    theme = c("dark", "light", "auto"),
    shape = c("rounded", "square"),
    stringsAsFactors = FALSE
  )

  expect_snapshot({
    for (i in seq_len(nrow(configurations))) {
      theme <- configurations$theme[[i]]
      shape <- configurations$shape[[i]]
      cat("\nTABS:", theme, shape, "\n")
      cat(as.character(glassTabsUI(
        "tabs",
        glassTabPanel("one", "One", shiny::p("First"), selected = TRUE),
        glassTabPanel("two", "Two", shiny::p("Second"), icon = shiny::icon("table")),
        theme = theme,
        shape = shape
      )))
      cat("\nMULTISELECT:", theme, shape, "\n")
      cat(as.character(glassMultiSelect(
        "multi",
        choices,
        selected = "apple",
        theme = theme,
        shape = shape
      )))
      cat("\nSELECT:", theme, shape, "\n")
      cat(as.character(glassSelect(
        "single",
        choices,
        selected = "banana",
        theme = theme,
        shape = shape
      )))
      cat("\n")
    }
  })
})

test_that("side-effect message payloads remain byte-stable", {
  session <- golden_session("mod")
  tab <- glassTabPanel("new", "New", shiny::p("Content"), icon = shiny::icon("table"))
  choices <- c(Apple = "apple", Banana = "banana")

  updateGlassTabsUI(session, "tabs", "new")
  updateGlassTabBadge(session, "tabs", "new", 7L)
  showGlassTab(session, "tabs", "new")
  hideGlassTab(session, "tabs", "new")
  disableGlassTab(session, "tabs", "new")
  enableGlassTab(session, "tabs", "new")
  appendGlassTab(session, "tabs", tab, select = TRUE)
  removeGlassTab(session, "tabs", "new")
  updateGlassMultiSelect(session, "multi", choices, selected = "apple", shape = "square")
  updateGlassSelect(session, "single", choices, selected = "banana", shape = "square")
  closeGlassSelect(session, "single")
  closeGlassMultiSelect(session, "multi")
  closeAllGlassSelects(session)

  expect_snapshot_value(session$messages(), style = "json2")
})

test_that("input-message fallback payloads remain byte-stable", {
  session <- golden_session()
  session$sendCustomMessage <- NULL
  session$ns <- NULL
  choices <- c(Apple = "apple", Banana = "banana")

  updateGlassMultiSelect(session, "multi", choices, selected = character(0))
  updateGlassSelect(session, "single", choices, selected = character(0))
  closeGlassSelect(session, "single")
  closeGlassMultiSelect(session, "multi")

  expect_snapshot_value(session$messages(), style = "json2")
})
