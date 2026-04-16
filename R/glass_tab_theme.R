#' Create a custom color theme for glassTabsUI
#'
#' @param tab_text Inactive tab text color.
#' @param tab_active_text Active tab text color.
#' @param halo_bg Halo background.
#' @param halo_border Halo border.
#' @param content_bg Tab content background.
#' @param content_border Tab content border.
#' @param card_bg Inner card background.
#' @param card_text Inner card text color.
#'
#' @return A named list of class `"glass_tab_theme"`.
#' @export
glass_tab_theme <- function(
    tab_text = NULL,
    tab_active_text = NULL,
    halo_bg = NULL,
    halo_border = NULL,
    content_bg = NULL,
    content_border = NULL,
    card_bg = NULL,
    card_text = NULL
) {
  structure(
    list(
      tab_text = tab_text,
      tab_active_text = tab_active_text,
      halo_bg = halo_bg,
      halo_border = halo_border,
      content_bg = content_bg,
      content_border = content_border,
      card_bg = card_bg,
      card_text = card_text
    ),
    class = "glass_tab_theme"
  )
}

# Internal helper: resolve final tab theme values
# @noRd
.tab_resolve_theme <- function(theme = NULL) {
  dark_defaults <- list(
    tab_text        = "rgba(207,230,255,0.78)",
    tab_active_text = "#ffffff",
    halo_bg         = "rgba(126,195,247,0.16)",
    halo_border     = "rgba(126,195,247,0.38)",
    halo_shadow     = "inset 0 1px 0 rgba(255,255,255,.22),inset 0 -1px 0 rgba(255,255,255,.06),0 6px 20px rgba(0,0,0,.38),0 0 0 1px rgba(255,255,255,.03)",
    content_bg      = "rgba(9,20,42,0.72)",
    content_border  = "rgba(255,255,255,0.10)",
    card_bg         = "rgba(255,255,255,0.03)",
    card_text       = "#cfe6ff"
  )

  light_defaults <- list(
    tab_text        = "#334155",
    tab_active_text = "#0f172a",
    halo_bg         = "rgba(37,99,235,0.13)",
    halo_border     = "rgba(37,99,235,0.42)",
    halo_shadow     = "inset 0 1px 0 rgba(255,255,255,.60),0 4px 12px rgba(37,99,235,.12),0 0 0 1px rgba(37,99,235,.05)",
    content_bg      = "rgba(255,255,255,0.92)",
    content_border  = "rgba(0,0,0,0.10)",
    card_bg         = "rgba(248,250,252,0.80)",
    card_text       = "#1e293b"
  )

  if (is.null(theme)) {
    return(dark_defaults)
  }

  if (is.character(theme) && length(theme) == 1) {
    if (!theme %in% c("dark", "light")) {
      stop(
        "`theme` must be \"dark\", \"light\", or a glass_tab_theme() object.",
        call. = FALSE
      )
    }
    return(if (theme == "light") light_defaults else dark_defaults)
  }

  if (inherits(theme, "glass_tab_theme")) {
    base <- dark_defaults
    if (!is.null(theme$tab_text))        base$tab_text        <- theme$tab_text
    if (!is.null(theme$tab_active_text)) base$tab_active_text <- theme$tab_active_text
    if (!is.null(theme$halo_bg))         base$halo_bg         <- theme$halo_bg
    if (!is.null(theme$halo_border))     base$halo_border     <- theme$halo_border
    if (!is.null(theme$content_bg))      base$content_bg      <- theme$content_bg
    if (!is.null(theme$content_border))  base$content_border  <- theme$content_border
    if (!is.null(theme$card_bg))         base$card_bg         <- theme$card_bg
    if (!is.null(theme$card_text))       base$card_text       <- theme$card_text
    return(base)
  }

  stop(
    "`theme` must be \"dark\", \"light\", or a glass_tab_theme() object.",
    call. = FALSE
  )
}
