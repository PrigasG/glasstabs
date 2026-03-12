#' Create a custom color theme for glass select widgets
#'
#' @param mode Base theme preset. One of \code{"dark"} (default) or
#'   \code{"light"}. Custom colors are applied on top of this base mode.
#' @param bg_color Background color of the trigger button and dropdown panel.
#' @param border_color Border color.
#' @param text_color Main text color.
#' @param accent_color Accent color used for the animated tick, badge,
#'   checked-state highlights, and clear controls.
#' @param label_color Optional label color. If `NULL`, the label defaults to
#'   `text_color`.
#'
#' @return A named list of class \code{"glass_select_theme"}.
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
        "`theme` must be \"dark\", \"light\", or a glass_select_theme() object.",
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
    "`theme` must be \"dark\", \"light\", or a glass_select_theme() object.",
    call. = FALSE
  )
}
