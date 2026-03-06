#' Animated glass multi-select dropdown filter
#'
#' @param inputId             Shiny input id. Selected values available as
#'   `input$<inputId>` (character vector) and active style as
#'   `input$<inputId>_style`.
#' @param choices             Named or unnamed character vector of choices.
#' @param selected            Initially selected values. Defaults to all.
#' @param placeholder         Trigger label when nothing is selected.
#' @param check_style         One of `"checkbox"` (default), `"check-only"`,
#'   or `"filled"`.
#' @param show_style_switcher Show the Check / Box / Fill switcher row inside
#'   the dropdown? Default `TRUE`. Set `FALSE` to lock the style silently.
#' @param show_select_all     Show the "Select all" row? Default `TRUE`.
#' @param show_clear_all      Show the "Clear all" footer link? Default `TRUE`.
#' @param theme               color theme. One of `"dark"` (default) or
#'   `"light"`, or a [glass_theme()] object for full custom control. You only
#'   need to supply the colors you want to change — everything else falls back
#'   to the dark preset.
#' @param hues                Optional named integer vector of HSL hue angles
#'   (0–360) for the `"filled"` style. Auto-assigned if `NULL`.
#'
#' @examples
#' fruits <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")
#'
#' # Minimal
#' glassMultiSelect("f", fruits)
#'
#' # Lock style, hide all chrome
#' glassMultiSelect("f", fruits,
#'   check_style         = "check-only",
#'   show_style_switcher = FALSE,
#'   show_select_all     = FALSE,
#'   show_clear_all      = FALSE
#' )
#'
#' # Only tweak the accent color — rest stays dark
#' glassMultiSelect("f", fruits,
#'   theme = glass_theme(accent_color = "#f59e0b")
#' )
#'
#' # Light panel
#' glassMultiSelect("f", fruits, theme = "light")
#'
#' # Full custom via glass_theme()
#' glassMultiSelect("f", fruits,
#'   theme = glass_theme(
#'     bg_color     = "#1a0a2e",
#'     border_color = "#a855f7",
#'     text_color   = "#ede9fe",
#'     accent_color = "#a855f7"
#'   )
#' )
#'
#' @return An \code{htmltools::tagList} containing the trigger button, dropdown
#'   panel, and a scoped \code{<style>} block. Embed directly in any Shiny UI
#'   function. The widget registers two Shiny inputs:
#'   \code{input$<inputId>} (character vector of selected values) and
#'   \code{input$<inputId>_style} (active checkbox style string).
#' @export
glassMultiSelect <- function(
    inputId,
    choices,
    selected            = NULL,
    placeholder         = "Filter by Category",
    check_style         = c("checkbox", "check-only", "filled"),
    show_style_switcher = TRUE,
    show_select_all     = TRUE,
    show_clear_all      = TRUE,
    theme               = "dark",
    hues                = NULL
) {
  check_style <- match.arg(check_style)
  colors     <- .ms_resolve_theme(theme)

  # Normalise choices
  if (is.null(names(choices))) names(choices) <- choices
  vals   <- unname(choices)
  labels <- names(choices)
  if (is.null(selected)) selected <- vals

  # Auto hues
  if (is.null(hues)) {
    n    <- length(vals)
    hues <- stats::setNames(
      as.integer(seq(200, 200 + 360 * (n - 1) / n, length.out = n) %% 360),
      vals
    )
  }

  n_total    <- length(vals)
  n_sel      <- length(selected)
  init_label <- .ms_label(vals, labels, selected, placeholder)
  badge_cls  <- if (n_sel < 2 || n_sel == n_total) "gt-ms-badge hidden" else "gt-ms-badge"

  # Scoped CSS variables for this instance
  scope_id  <- paste0(inputId, "-wrap")
  theme_css <- sprintf(
    "#%s{--ms-bg:%s;--ms-border:%s;--ms-text:%s;--ms-accent:%s;}",
    scope_id, colors$bg, colors$border, colors$text, colors$accent
  )

  # Tick SVG
  check_svg <- shiny::tags$svg(
    width = "10", height = "8", viewBox = "0 0 10 8", fill = "none",
    shiny::tags$path(d = "M1 4l2.8 3L9 1", stroke = colors$accent,
      `stroke-width` = "1.8", `stroke-linecap` = "round",
      `stroke-linejoin` = "round")
  )

  # ── Style switcher ────────────────────────────────────────────────────────
  style_btns <- if (isTRUE(show_style_switcher)) {
    shiny::div(class = "gt-style-switcher",
      shiny::div(
        class = paste("gt-style-btn", if (check_style == "check-only") "active" else ""),
        `data-style` = "check-only",
        shiny::tags$svg(class = "gt-sb-icon", viewBox = "0 0 14 14", fill = "none",
          shiny::tags$path(d = "M2 7l3.5 4L12 3", stroke = colors$accent,
            `stroke-width` = "1.9", `stroke-linecap` = "round", `stroke-linejoin` = "round")),
        shiny::tags$span("Check")
      ),
      shiny::div(
        class = paste("gt-style-btn", if (check_style == "checkbox") "active" else ""),
        `data-style` = "checkbox",
        shiny::tags$svg(class = "gt-sb-icon", viewBox = "0 0 14 14", fill = "none",
          shiny::tags$rect(x = "1.5", y = "1.5", width = "11", height = "11", rx = "3",
            stroke = colors$accent, `stroke-width` = "1.6"),
          shiny::tags$path(d = "M3.5 7l2.8 3L10.5 4", stroke = colors$accent,
            `stroke-width` = "1.7", `stroke-linecap` = "round", `stroke-linejoin` = "round")),
        shiny::tags$span("Box")
      ),
      shiny::div(
        class = paste("gt-style-btn", if (check_style == "filled") "active" else ""),
        `data-style` = "filled",
        shiny::tags$svg(class = "gt-sb-icon", viewBox = "0 0 14 14", fill = "none",
          shiny::tags$rect(x = "1.5", y = "1.5", width = "11", height = "11", rx = "3",
            fill = "rgba(80,160,255,0.55)", stroke = "rgba(100,180,255,0.6)", `stroke-width` = "1.4"),
          shiny::tags$path(d = "M3.5 7l2.8 3L10.5 4", stroke = "#fff",
            `stroke-width` = "1.7", `stroke-linecap` = "round", `stroke-linejoin` = "round")),
        shiny::tags$span("Fill")
      )
    )
  } else NULL

  # ── Select all row ────────────────────────────────────────────────────────
  all_cls <- paste(
    "gt-ms-all",
    if (n_sel == n_total) "checked" else if (n_sel > 0) "indeterminate" else ""
  )
  all_row <- if (isTRUE(show_select_all)) {
    shiny::div(class = all_cls, id = paste0(inputId, "-all"),
      shiny::div(class = "gt-ms-check", check_svg),
      shiny::tags$span("Select all")
    )
  } else {
    # Always render the element — JS references it — but hide it
    shiny::div(class = all_cls, id = paste0(inputId, "-all"),
      style = "display:none;",
      shiny::div(class = "gt-ms-check", check_svg),
      shiny::tags$span("Select all")
    )
  }

  # ── Option rows ───────────────────────────────────────────────────────────
  option_rows <- lapply(seq_along(vals), function(i) {
    v   <- vals[i]
    lbl <- labels[i]
    cls <- paste("gt-ms-option", if (v %in% selected) "checked" else "")
    shiny::div(class = cls, `data-value` = v,
      style = paste0("--opt-hue:", hues[[v]], ";"),
      shiny::div(class = "gt-ms-check", check_svg),
      shiny::tags$span(lbl)
    )
  })

  # ── Footer ────────────────────────────────────────────────────────────────
  footer <- shiny::div(class = "gt-ms-footer",
    shiny::tags$span(class = "gt-ms-count", id = paste0(inputId, "-count"),
      paste0(n_sel, " / ", n_total, " selected")),
    if (isTRUE(show_clear_all)) {
      shiny::tags$span(class = "gt-ms-clear", id = paste0(inputId, "-clear"),
        "Clear all")
    } else {
      # Hidden sentinel so JS doesn't throw on getElementById
      shiny::tags$span(class = "gt-ms-clear", id = paste0(inputId, "-clear"),
        style = "display:none;", "Clear all")
    }
  )

  # ── Assemble ──────────────────────────────────────────────────────────────
  wrap_cls <- paste("gt-ms-wrap", paste0("style-", check_style))

  htmltools::tagList(
    shiny::tags$style(theme_css),
    shiny::div(
      class = wrap_cls, id = scope_id,
      `data-input-id`    = inputId,
      `data-placeholder` = placeholder,

      # Trigger
      shiny::div(class = "gt-ms-trigger", id = paste0(inputId, "-trigger"),
        shiny::tags$span(id = paste0(inputId, "-label"), init_label),
        shiny::div(style = "display:flex;align-items:center;gap:6px;",
          shiny::tags$span(class = badge_cls, id = paste0(inputId, "-badge"),
            as.character(n_sel)),
          shiny::tags$svg(class = "gt-ms-chevron", viewBox = "0 0 24 24",
            fill = "none", stroke = "currentColor", `stroke-width` = "2.2",
            shiny::tags$path(`stroke-linecap` = "round",
              `stroke-linejoin` = "round", d = "M19 9l-7 7-7-7"))
        )
      ),

      # Dropdown
      shiny::div(class = "gt-ms-dropdown", id = paste0(inputId, "-dropdown"),
        shiny::div(class = "gt-ms-search",
          shiny::tags$svg(width = "13", height = "13", viewBox = "0 0 24 24",
            fill = "none", stroke = colors$accent, `stroke-width` = "2.2",
            shiny::tags$circle(cx = "11", cy = "11", r = "8"),
            shiny::tags$path(`stroke-linecap` = "round", d = "M21 21l-4.35-4.35")),
          shiny::tags$input(type = "text", id = paste0(inputId, "-search"),
            placeholder = "Search options...", autocomplete = "off")
        ),
        style_btns,
        all_row,
        shiny::div(id = paste0(inputId, "-options"), option_rows),
        footer
      )
    )
  )
}


#' Server logic for glassMultiSelect
#'
#' A convenience wrapper that exposes the widget's current state as typed
#' reactives. The underlying Shiny inputs are also available directly as
#' \code{input$<inputId>} and \code{input$<inputId>_style}.
#'
#' @param inputId The same \code{inputId} passed to
#'   \code{\link{glassMultiSelect}}.
#'
#' @return A list with two elements:
#'   \describe{
#'     \item{\code{selected}}{Reactive character vector of currently selected values.}
#'     \item{\code{style}}{Reactive string — the active checkbox style
#'       (\code{"checkbox"}, \code{"check-only"}, or \code{"filled"}).}
#'   }
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     glassMultiSelect("cats", c(A = "a", B = "b", C = "c"))
#'   )
#'   server <- function(input, output, session) {
#'     ms <- glassMultiSelectServer("cats")
#'     observe(message("Selected: ", paste(ms$selected(), collapse = ", ")))
#'   }
#'   shinyApp(ui, server)
#' }
#'
#' @export
glassMultiSelectServer <- function(inputId) {
  shiny::moduleServer(inputId, function(input, output, session) {
    list(
      selected = shiny::reactive(input[[inputId]]),
      style    = shiny::reactive(input[[paste0(inputId, "_style")]])
    )
  })
}

.ms_label <- function(vals, labels, selected, placeholder) {
  n <- length(selected)
  if (n == 0)            return(placeholder)
  if (n == length(vals)) return("All categories")
  if (n == 1)            return(labels[match(selected, vals)])
  "Multiple selection"
}
