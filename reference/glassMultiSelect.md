# Animated glass multi-select dropdown filter

Animated glass multi-select dropdown filter

## Usage

``` r
glassMultiSelect(
  inputId,
  choices,
  selected = NULL,
  placeholder = "Filter by Category",
  check_style = c("checkbox", "check-only", "filled"),
  show_style_switcher = TRUE,
  show_select_all = TRUE,
  show_clear_all = TRUE,
  theme = "dark",
  hues = NULL
)
```

## Arguments

- inputId:

  Shiny input id. Selected values available as `input$<inputId>`
  (character vector) and active style as `input$<inputId>_style`.

- choices:

  Named or unnamed character vector of choices.

- selected:

  Initially selected values. Defaults to all.

- placeholder:

  Trigger label when nothing is selected.

- check_style:

  One of `"checkbox"` (default), `"check-only"`, or `"filled"`.

- show_style_switcher:

  Show the Check / Box / Fill switcher row inside the dropdown? Default
  `TRUE`. Set `FALSE` to lock the style silently.

- show_select_all:

  Show the "Select all" row? Default `TRUE`.

- show_clear_all:

  Show the "Clear all" footer link? Default `TRUE`.

- theme:

  color theme. One of `"dark"` (default) or `"light"`, or a
  [`glass_select_theme()`](https://prigasg.github.io/glasstabs/reference/glass_select_theme.md)
  object for full custom control. You only need to supply the colors you
  want to change — everything else falls back to the dark preset.

- hues:

  Optional named integer vector of HSL hue angles (0–360) for the
  `"filled"` style. Auto-assigned if `NULL`.

## Value

An
[`htmltools::tagList`](https://rstudio.github.io/htmltools/reference/tagList.html)
containing the trigger button, dropdown panel, and a scoped `<style>`
block. Embed directly in any Shiny UI function. The widget registers two
Shiny inputs: `input$<inputId>` (character vector of selected values)
and `input$<inputId>_style` (active checkbox style string).

## Examples

``` r
fruits <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")

# Minimal
glassMultiSelect("f", fruits)
#> <style>#f-wrap{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;}</style>
#> <div class="gt-ms-wrap style-checkbox" id="f-wrap" data-input-id="f" data-placeholder="Filter by Category">
#>   <div class="gt-ms-trigger" id="f-trigger">
#>     <span id="f-label">All categories</span>
#>     <div style="display:flex;align-items:center;gap:6px;">
#>       <span class="gt-ms-badge hidden" id="f-badge">3</span>
#>       <svg class="gt-ms-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
#>         <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
#>       </svg>
#>     </div>
#>   </div>
#>   <div class="gt-ms-dropdown" id="f-dropdown">
#>     <div class="gt-ms-search">
#>       <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#7ec3f7" stroke-width="2.2">
#>         <circle cx="11" cy="11" r="8"></circle>
#>         <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
#>       </svg>
#>       <input type="text" id="f-search" placeholder="Search options..." autocomplete="off"/>
#>     </div>
#>     <div class="gt-style-switcher">
#>       <div class="gt-style-btn " data-style="check-only">
#>         <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>           <path d="M2 7l3.5 4L12 3" stroke="#7ec3f7" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>         <span>Check</span>
#>       </div>
#>       <div class="gt-style-btn active" data-style="checkbox">
#>         <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>           <rect x="1.5" y="1.5" width="11" height="11" rx="3" stroke="#7ec3f7" stroke-width="1.6"></rect>
#>           <path d="M3.5 7l2.8 3L10.5 4" stroke="#7ec3f7" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>         <span>Box</span>
#>       </div>
#>       <div class="gt-style-btn " data-style="filled">
#>         <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>           <rect x="1.5" y="1.5" width="11" height="11" rx="3" fill="rgba(80,160,255,0.55)" stroke="rgba(100,180,255,0.6)" stroke-width="1.4"></rect>
#>           <path d="M3.5 7l2.8 3L10.5 4" stroke="#fff" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>         <span>Fill</span>
#>       </div>
#>     </div>
#>     <div class="gt-ms-all checked" id="f-all">
#>       <div class="gt-ms-check">
#>         <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>           <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>       </div>
#>       <span>Select all</span>
#>     </div>
#>     <div id="f-options">
#>       <div class="gt-ms-option checked" data-value="apple" style="--opt-hue:200;">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Apple</span>
#>       </div>
#>       <div class="gt-ms-option checked" data-value="banana" style="--opt-hue:320;">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Banana</span>
#>       </div>
#>       <div class="gt-ms-option checked" data-value="cherry" style="--opt-hue:80;">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Cherry</span>
#>       </div>
#>     </div>
#>     <div class="gt-ms-footer">
#>       <span class="gt-ms-count" id="f-count">3 / 3 selected</span>
#>       <span class="gt-ms-clear" id="f-clear">Clear all</span>
#>     </div>
#>   </div>
#> </div>

# Lock style, hide all chrome
glassMultiSelect("f", fruits,
  check_style         = "check-only",
  show_style_switcher = FALSE,
  show_select_all     = FALSE,
  show_clear_all      = FALSE
)
#> <style>#f-wrap{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;}</style>
#> <div class="gt-ms-wrap style-check-only" id="f-wrap" data-input-id="f" data-placeholder="Filter by Category">
#>   <div class="gt-ms-trigger" id="f-trigger">
#>     <span id="f-label">All categories</span>
#>     <div style="display:flex;align-items:center;gap:6px;">
#>       <span class="gt-ms-badge hidden" id="f-badge">3</span>
#>       <svg class="gt-ms-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
#>         <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
#>       </svg>
#>     </div>
#>   </div>
#>   <div class="gt-ms-dropdown" id="f-dropdown">
#>     <div class="gt-ms-search">
#>       <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#7ec3f7" stroke-width="2.2">
#>         <circle cx="11" cy="11" r="8"></circle>
#>         <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
#>       </svg>
#>       <input type="text" id="f-search" placeholder="Search options..." autocomplete="off"/>
#>     </div>
#>     <div class="gt-ms-all checked" id="f-all" style="display:none;">
#>       <div class="gt-ms-check">
#>         <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>           <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>       </div>
#>       <span>Select all</span>
#>     </div>
#>     <div id="f-options">
#>       <div class="gt-ms-option checked" data-value="apple" style="--opt-hue:200;">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Apple</span>
#>       </div>
#>       <div class="gt-ms-option checked" data-value="banana" style="--opt-hue:320;">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Banana</span>
#>       </div>
#>       <div class="gt-ms-option checked" data-value="cherry" style="--opt-hue:80;">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Cherry</span>
#>       </div>
#>     </div>
#>     <div class="gt-ms-footer">
#>       <span class="gt-ms-count" id="f-count">3 / 3 selected</span>
#>       <span class="gt-ms-clear" id="f-clear" style="display:none;">Clear all</span>
#>     </div>
#>   </div>
#> </div>

# Only tweak the accent color — rest stays dark
glassMultiSelect("f", fruits,
  theme = glass_select_theme(accent_color = "#f59e0b")
)
#> <style>#f-wrap{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#f59e0b;}</style>
#> <div class="gt-ms-wrap style-checkbox" id="f-wrap" data-input-id="f" data-placeholder="Filter by Category">
#>   <div class="gt-ms-trigger" id="f-trigger">
#>     <span id="f-label">All categories</span>
#>     <div style="display:flex;align-items:center;gap:6px;">
#>       <span class="gt-ms-badge hidden" id="f-badge">3</span>
#>       <svg class="gt-ms-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
#>         <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
#>       </svg>
#>     </div>
#>   </div>
#>   <div class="gt-ms-dropdown" id="f-dropdown">
#>     <div class="gt-ms-search">
#>       <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#f59e0b" stroke-width="2.2">
#>         <circle cx="11" cy="11" r="8"></circle>
#>         <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
#>       </svg>
#>       <input type="text" id="f-search" placeholder="Search options..." autocomplete="off"/>
#>     </div>
#>     <div class="gt-style-switcher">
#>       <div class="gt-style-btn " data-style="check-only">
#>         <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>           <path d="M2 7l3.5 4L12 3" stroke="#f59e0b" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>         <span>Check</span>
#>       </div>
#>       <div class="gt-style-btn active" data-style="checkbox">
#>         <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>           <rect x="1.5" y="1.5" width="11" height="11" rx="3" stroke="#f59e0b" stroke-width="1.6"></rect>
#>           <path d="M3.5 7l2.8 3L10.5 4" stroke="#f59e0b" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>         <span>Box</span>
#>       </div>
#>       <div class="gt-style-btn " data-style="filled">
#>         <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>           <rect x="1.5" y="1.5" width="11" height="11" rx="3" fill="rgba(80,160,255,0.55)" stroke="rgba(100,180,255,0.6)" stroke-width="1.4"></rect>
#>           <path d="M3.5 7l2.8 3L10.5 4" stroke="#fff" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>         <span>Fill</span>
#>       </div>
#>     </div>
#>     <div class="gt-ms-all checked" id="f-all">
#>       <div class="gt-ms-check">
#>         <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>           <path d="M1 4l2.8 3L9 1" stroke="#f59e0b" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>       </div>
#>       <span>Select all</span>
#>     </div>
#>     <div id="f-options">
#>       <div class="gt-ms-option checked" data-value="apple" style="--opt-hue:200;">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#f59e0b" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Apple</span>
#>       </div>
#>       <div class="gt-ms-option checked" data-value="banana" style="--opt-hue:320;">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#f59e0b" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Banana</span>
#>       </div>
#>       <div class="gt-ms-option checked" data-value="cherry" style="--opt-hue:80;">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#f59e0b" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Cherry</span>
#>       </div>
#>     </div>
#>     <div class="gt-ms-footer">
#>       <span class="gt-ms-count" id="f-count">3 / 3 selected</span>
#>       <span class="gt-ms-clear" id="f-clear">Clear all</span>
#>     </div>
#>   </div>
#> </div>

# Light panel
glassMultiSelect("f", fruits, theme = "light")
#> <style>#f-wrap{--ms-bg:rgba(255,255,255,0.98);--ms-border:rgba(0,0,0,0.12);--ms-text:#1e293b;--ms-accent:#2563eb;}</style>
#> <div class="gt-ms-wrap style-checkbox" id="f-wrap" data-input-id="f" data-placeholder="Filter by Category">
#>   <div class="gt-ms-trigger" id="f-trigger">
#>     <span id="f-label">All categories</span>
#>     <div style="display:flex;align-items:center;gap:6px;">
#>       <span class="gt-ms-badge hidden" id="f-badge">3</span>
#>       <svg class="gt-ms-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
#>         <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
#>       </svg>
#>     </div>
#>   </div>
#>   <div class="gt-ms-dropdown" id="f-dropdown">
#>     <div class="gt-ms-search">
#>       <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2.2">
#>         <circle cx="11" cy="11" r="8"></circle>
#>         <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
#>       </svg>
#>       <input type="text" id="f-search" placeholder="Search options..." autocomplete="off"/>
#>     </div>
#>     <div class="gt-style-switcher">
#>       <div class="gt-style-btn " data-style="check-only">
#>         <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>           <path d="M2 7l3.5 4L12 3" stroke="#2563eb" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>         <span>Check</span>
#>       </div>
#>       <div class="gt-style-btn active" data-style="checkbox">
#>         <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>           <rect x="1.5" y="1.5" width="11" height="11" rx="3" stroke="#2563eb" stroke-width="1.6"></rect>
#>           <path d="M3.5 7l2.8 3L10.5 4" stroke="#2563eb" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>         <span>Box</span>
#>       </div>
#>       <div class="gt-style-btn " data-style="filled">
#>         <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>           <rect x="1.5" y="1.5" width="11" height="11" rx="3" fill="rgba(80,160,255,0.55)" stroke="rgba(100,180,255,0.6)" stroke-width="1.4"></rect>
#>           <path d="M3.5 7l2.8 3L10.5 4" stroke="#fff" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>         <span>Fill</span>
#>       </div>
#>     </div>
#>     <div class="gt-ms-all checked" id="f-all">
#>       <div class="gt-ms-check">
#>         <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>           <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>       </div>
#>       <span>Select all</span>
#>     </div>
#>     <div id="f-options">
#>       <div class="gt-ms-option checked" data-value="apple" style="--opt-hue:200;">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Apple</span>
#>       </div>
#>       <div class="gt-ms-option checked" data-value="banana" style="--opt-hue:320;">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Banana</span>
#>       </div>
#>       <div class="gt-ms-option checked" data-value="cherry" style="--opt-hue:80;">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Cherry</span>
#>       </div>
#>     </div>
#>     <div class="gt-ms-footer">
#>       <span class="gt-ms-count" id="f-count">3 / 3 selected</span>
#>       <span class="gt-ms-clear" id="f-clear">Clear all</span>
#>     </div>
#>   </div>
#> </div>

# Full custom via glass_select_theme()
glassMultiSelect("f", fruits,
  theme = glass_select_theme(
    bg_color     = "#1a0a2e",
    border_color = "#a855f7",
    text_color   = "#ede9fe",
    accent_color = "#a855f7"
  )
)
#> <style>#f-wrap{--ms-bg:#1a0a2e;--ms-border:#a855f7;--ms-text:#ede9fe;--ms-accent:#a855f7;}</style>
#> <div class="gt-ms-wrap style-checkbox" id="f-wrap" data-input-id="f" data-placeholder="Filter by Category">
#>   <div class="gt-ms-trigger" id="f-trigger">
#>     <span id="f-label">All categories</span>
#>     <div style="display:flex;align-items:center;gap:6px;">
#>       <span class="gt-ms-badge hidden" id="f-badge">3</span>
#>       <svg class="gt-ms-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
#>         <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
#>       </svg>
#>     </div>
#>   </div>
#>   <div class="gt-ms-dropdown" id="f-dropdown">
#>     <div class="gt-ms-search">
#>       <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#a855f7" stroke-width="2.2">
#>         <circle cx="11" cy="11" r="8"></circle>
#>         <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
#>       </svg>
#>       <input type="text" id="f-search" placeholder="Search options..." autocomplete="off"/>
#>     </div>
#>     <div class="gt-style-switcher">
#>       <div class="gt-style-btn " data-style="check-only">
#>         <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>           <path d="M2 7l3.5 4L12 3" stroke="#a855f7" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>         <span>Check</span>
#>       </div>
#>       <div class="gt-style-btn active" data-style="checkbox">
#>         <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>           <rect x="1.5" y="1.5" width="11" height="11" rx="3" stroke="#a855f7" stroke-width="1.6"></rect>
#>           <path d="M3.5 7l2.8 3L10.5 4" stroke="#a855f7" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>         <span>Box</span>
#>       </div>
#>       <div class="gt-style-btn " data-style="filled">
#>         <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>           <rect x="1.5" y="1.5" width="11" height="11" rx="3" fill="rgba(80,160,255,0.55)" stroke="rgba(100,180,255,0.6)" stroke-width="1.4"></rect>
#>           <path d="M3.5 7l2.8 3L10.5 4" stroke="#fff" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>         <span>Fill</span>
#>       </div>
#>     </div>
#>     <div class="gt-ms-all checked" id="f-all">
#>       <div class="gt-ms-check">
#>         <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>           <path d="M1 4l2.8 3L9 1" stroke="#a855f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>         </svg>
#>       </div>
#>       <span>Select all</span>
#>     </div>
#>     <div id="f-options">
#>       <div class="gt-ms-option checked" data-value="apple" style="--opt-hue:200;">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#a855f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Apple</span>
#>       </div>
#>       <div class="gt-ms-option checked" data-value="banana" style="--opt-hue:320;">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#a855f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Banana</span>
#>       </div>
#>       <div class="gt-ms-option checked" data-value="cherry" style="--opt-hue:80;">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#a855f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Cherry</span>
#>       </div>
#>     </div>
#>     <div class="gt-ms-footer">
#>       <span class="gt-ms-count" id="f-count">3 / 3 selected</span>
#>       <span class="gt-ms-clear" id="f-clear">Clear all</span>
#>     </div>
#>   </div>
#> </div>
```
