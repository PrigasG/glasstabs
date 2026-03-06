#' Create a custom color theme for glassMultiSelect
#'
#' @param bg_color Background color of the trigger button and dropdown panel.
#' @param border_color Border color.
#' @param text_color Main text color.
#' @param accent_color Accent color used for the animated tick, badge,
#'   checked-state highlights, and the "Clear all" link.
#'
#' @return A named list of class `"glass_select_theme"`.
#' @export
glass_select_theme <- function(
    bg_color = NULL,
    border_color = NULL,
    text_color = NULL,
    accent_color = NULL
) {
  structure(
    list(
      bg_color = bg_color,
      border_color = border_color,
      text_color = text_color,
      accent_color = accent_color
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
    accent = "#7ec3f7"
  )

  light_defaults <- list(
    bg     = "rgba(255,255,255,0.98)",
    border = "rgba(0,0,0,0.12)",
    text   = "#1e293b",
    accent = "#2563eb"
  )

  if (is.null(theme)) {
    return(dark_defaults)
  }

  if (is.character(theme) && length(theme) == 1) {
    if (!theme %in% c("dark", "light")) {
      stop(
        "`theme` must be \"dark\", \"light\", or a glass_select_theme() object.",
        call. = FALSE
      )
    }
    return(if (theme == "light") light_defaults else dark_defaults)
  }

  if (inherits(theme, "glass_select_theme")) {
    base <- dark_defaults
    if (!is.null(theme$bg_color))     base$bg     <- theme$bg_color
    if (!is.null(theme$border_color)) base$border <- theme$border_color
    if (!is.null(theme$text_color))   base$text   <- theme$text_color
    if (!is.null(theme$accent_color)) base$accent <- theme$accent_color
    return(base)
  }

  stop(
    "`theme` must be \"dark\", \"light\", or a glass_select_theme() object.",
    call. = FALSE
  )
}
