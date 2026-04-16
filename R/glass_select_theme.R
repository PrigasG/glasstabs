#' Create a custom color theme for glass select widgets
#'
#' All color arguments accept any valid CSS color string (hex, `rgb()`,
#' `rgba()`, named colors). Unset fields inherit from the `mode` base preset.
#'
#' @param mode         Base preset. One of `"dark"` (default) or `"light"`.
#'   Custom colors are layered on top.
#' @param bg_color     Background of the trigger button and dropdown panel.
#' @param border_color Border color of the trigger and dropdown.
#' @param text_color   Main text color for options and the trigger label.
#' @param accent_color Highlight color for checkmarks, badges, and selected
#'   states. Also used for the focus ring.
#' @param label_color  Widget label color. Defaults to `text_color` when `NULL`.
#'
#' @return A named list of class `"glass_select_theme"` for passing to the
#'   `theme` argument of [glassMultiSelect()] or [glassSelect()].
#'
#' @examples
#' # Teal accent on a dark base
#' teal_theme <- glass_select_theme(
#'   mode         = "dark",
#'   accent_color = "#2dd4bf",
#'   bg_color     = "rgba(9, 20, 42, 0.97)"
#' )
#'
#' # Light mode with a custom purple accent
#' purple_light <- glass_select_theme(
#'   mode         = "light",
#'   accent_color = "#7c3aed",
#'   border_color = "rgba(124, 58, 237, 0.35)"
#' )
#'
#' if (interactive()) {
#'   library(shiny)
#'   choices <- c(Revenue = "rev", Orders = "ord", Returns = "ret")
#'   ui <- fluidPage(
#'     useGlassTabs(),
#'     glassMultiSelect("metric", choices, theme = teal_theme),
#'     glassSelect("region", c(All = "all", North = "n", South = "s"),
#'                 theme = purple_light)
#'   )
#'   server <- function(input, output, session) {}
#'   shinyApp(ui, server)
#' }
#'
#' @export
glass_select_theme <- function(
    mode = c("dark", "light"),
    bg_color = NULL,
    border_color = NULL,
    text_color = NULL,
    accent_color = NULL,
    label_color = NULL
) {
  mode <- match.arg(mode)

  structure(
    list(
      mode = mode,
      bg_color = bg_color,
      border_color = border_color,
      text_color = text_color,
      accent_color = accent_color,
      label_color = label_color
    ),
    class = "glass_select_theme"
  )
}


# Internal: resolve final colors from theme arg
# theme can be "dark", "light", or a glass_select_theme() object
.ms_resolve_theme <- function(theme = NULL) {
  dark_defaults <- list(
    bg     = "rgba(9,20,42,0.97)",
    border = "rgba(255,255,255,0.10)",
    text   = "#cfe6ff",
    accent = "#7ec3f7",
    label  = "#cfe6ff"
  )

  light_defaults <- list(
    bg     = "rgba(255,255,255,0.98)",
    border = "rgba(0,0,0,0.12)",
    text   = "#111111",
    accent = "#2563eb",
    label  = "#111111"
  )

  if (is.null(theme)) {
    return(dark_defaults)
  }

  if (is.character(theme) && length(theme) == 1) {
    if (!theme %in% c("dark", "light")) {
      stop(
        sprintf(
          paste0(
            "`theme = \"%s\"` is not a valid preset.\n",
            "Use theme = \"dark\", theme = \"light\", or a glass_select_theme() object.\n",
            "See ?glass_select_theme for custom colours."
          ),
          theme
        ),
        call. = FALSE
      )
    }
    return(if (theme == "light") light_defaults else dark_defaults)
  }

  if (inherits(theme, "glass_select_theme")) {
    base_mode <- if (is.null(theme$mode)) "dark" else theme$mode
    base <- if (identical(base_mode, "light")) light_defaults else dark_defaults

    if (!is.null(theme$bg_color))     base$bg     <- theme$bg_color
    if (!is.null(theme$border_color)) base$border <- theme$border_color
    if (!is.null(theme$text_color))   base$text   <- theme$text_color
    if (!is.null(theme$accent_color)) base$accent <- theme$accent_color
    if (!is.null(theme$label_color))  base$label  <- theme$label_color
    if (is.null(theme$label_color) && !is.null(theme$text_color)) {
      base$label <- theme$text_color
    }

    return(base)
  }

  stop(
    sprintf(
      paste0(
        "`theme` must be \"dark\", \"light\", or a glass_select_theme() object, got %s.\n",
        "See ?glass_select_theme for custom theming."
      ),
      class(theme)[1]
    ),
    call. = FALSE
  )
}
