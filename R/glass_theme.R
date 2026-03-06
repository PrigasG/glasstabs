#' Create a custom color theme for glasstabs widgets
#'
#' A helper function — inspired by ggplot2's `theme()` — that lets you
#' override only the colors you care about. Any argument you leave out
#' falls back to sensible defaults so you are never forced to supply all
#' four values.
#'
#' Pass the result directly to the `theme` argument of [glassMultiSelect()].
#'
#' @param bg_color     Background color of the trigger button and dropdown
#'   panel. Default: `NULL` (inherits the dark preset).
#' @param border_color Border color. Default: `NULL`.
#' @param text_color   Main text color. Default: `NULL`.
#' @param accent_color Accent color used for the animated tick, badge,
#'   checked-state highlights, and the "Clear all" link. Default: `NULL`.
#'
#' @return A named list of class `"glass_theme"` consumed by
#'   [glassMultiSelect()].
#'
#' @examples
#' # Only change the accent — everything else stays dark
#' glassMultiSelect("x", c(A = "a", B = "b"),
#'   theme = glass_theme(accent_color = "#f59e0b")
#' )
#'
#' # Light panel, blue accent
#' glassMultiSelect("x", c(A = "a", B = "b"),
#'   theme = glass_theme(
#'     bg_color     = "rgba(255,255,255,0.98)",
#'     border_color = "rgba(0,0,0,0.10)",
#'     text_color   = "#1e293b",
#'     accent_color = "#2563eb"
#'   )
#' )
#'
#' @export
glass_theme <- function(bg_color     = NULL,
                        border_color = NULL,
                        text_color   = NULL,
                        accent_color = NULL) {
  structure(
    list(
      bg_color     = bg_color,
      border_color = border_color,
      text_color   = text_color,
      accent_color = accent_color
    ),
    class = "glass_theme"
  )
}


# Internal: resolve final colors from theme arg
# theme can be "dark", "light", or a glass_theme() object
.ms_resolve_theme <- function(theme) {
  # Presets
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

  # String shortcuts
  if (is.character(theme) && length(theme) == 1) {
    theme <- match.arg(theme, c("dark", "light"))
    return(if (theme == "light") light_defaults else dark_defaults)
  }

  # glass_theme() object — merge over dark defaults
  if (inherits(theme, "glass_theme")) {
    base <- dark_defaults
    if (!is.null(theme$bg_color))     base$bg     <- theme$bg_color
    if (!is.null(theme$border_color)) base$border <- theme$border_color
    if (!is.null(theme$text_color))   base$text   <- theme$text_color
    if (!is.null(theme$accent_color)) base$accent <- theme$accent_color
    return(base)
  }

  stop(
    "`theme` must be \"dark\", \"light\", or a glass_theme() object.",
    call. = FALSE
  )
}
