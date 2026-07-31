#' @noRd
.gt_tab_link <- function(panel, is_active, data_ns, preserve_inactive_space = FALSE) {
  class <- if (is_active) {
    "gt-tab-link active"
  } else if (preserve_inactive_space) {
    "gt-tab-link "
  } else {
    "gt-tab-link"
  }
  label_content <- if (!is.null(panel$icon)) {
    list(
      shiny::tags$span(class = "gt-tab-icon", panel$icon),
      shiny::tags$span(class = "gt-tab-label", panel$label)
    )
  } else {
    list(panel$label)
  }

  do.call(
    shiny::tags$div,
    c(
      list(
        class = class,
        `data-value` = panel$value,
        `data-ns` = data_ns,
        role = "tab",
        tabindex = "0",
        `aria-selected` = if (is_active) "true" else "false"
      ),
      label_content
    )
  )
}

#' @noRd
.gt_tab_pane <- function(panel, is_active, id, preserve_inactive_space = FALSE) {
  class <- if (is_active) {
    "gt-tab-pane active"
  } else if (preserve_inactive_space) {
    "gt-tab-pane "
  } else {
    "gt-tab-pane"
  }

  shiny::div(
    class = class,
    id = id,
    role = "tabpanel",
    do.call(shiny::div, c(list(class = "gt-card"), panel$content))
  )
}

#' @noRd
.gt_tab_theme_css <- function(theme, scope_id, selector = NULL) {
  scope <- if (is.null(selector)) paste0("#", scope_id) else paste0(selector, " #", scope_id)
  sprintf(
    "%s{--gt-tab-text:%s;--gt-tab-active-text:%s;--gt-halo-bg:%s;--gt-halo-border:%s;--gt-halo-shadow:%s;--gt-content-bg:%s;--gt-content-border:%s;--gt-card-bg:%s;--gt-card-text:%s;}",
    scope,
    theme$tab_text,
    theme$tab_active_text,
    theme$halo_bg,
    theme$halo_border,
    theme$halo_shadow,
    theme$content_bg,
    theme$content_border,
    theme$card_bg,
    theme$card_text
  )
}
