# Animated glass multi-select dropdown filter

A stylized multi-select Shiny input with optional search, style
switching, select-all behavior, and programmatic updates via
[`updateGlassMultiSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassMultiSelect.md).

## Usage

``` r
glassMultiSelect(
  inputId,
  choices,
  selected = NULL,
  label = NULL,
  placeholder = "Filter by Category",
  all_label = "All categories",
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

  Shiny input id.

- choices:

  Named or unnamed character vector of choices.

- selected:

  Initially selected values. Defaults to all choices when `NULL`.

- label:

  Optional field label shown above the widget.

- placeholder:

  Trigger label when nothing is selected.

- all_label:

  Label shown when all choices are selected.

- check_style:

  One of `"checkbox"` (default), `"check-only"`, or `"filled"`.

- show_style_switcher:

  Show the Check / Box / Fill switcher row inside the dropdown? Default
  `TRUE`.

- show_select_all:

  Show the "Select all" row? Default `TRUE`.

- show_clear_all:

  Show the "Clear all" footer link? Default `TRUE`.

- theme:

  Color theme. One of `"dark"` (default) or `"light"`, or a
  [`glass_select_theme()`](https://prigasg.github.io/glasstabs/reference/glass_select_theme.md)
  object.

- hues:

  Optional named integer vector of HSL hue angles (0 to 360) for the
  `"filled"` style. Auto-assigned if `NULL`.

## Value

An
[`htmltools::tagList`](https://rstudio.github.io/htmltools/reference/tagList.html)
containing the trigger button, dropdown panel, and scoped `<style>`
block.

## Details

The widget registers two Shiny inputs:

- `input$<inputId>` : character vector of selected values

- `input$<inputId>_style` : active style string (`"checkbox"`,
  `"check-only"`, or `"filled"`)

By default, when `selected = NULL`, all choices are initially selected.
This preserves the existing package behavior.

## Examples

``` r
fruits <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")

# Minimal
glassMultiSelect("f", fruits)
#> <style>#f-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;}</style>
#> <div class="gt-ms-field" id="f-field">
#>   <div class="gt-ms-wrap style-checkbox " id="f-wrap" data-input-id="f" data-placeholder="Filter by Category" data-all-label="All categories">
#>     <div class="gt-ms-trigger" id="f-trigger">
#>       <span id="f-label">All categories</span>
#>       <div style="display:flex;align-items:center;gap:6px;">
#>         <span class="gt-ms-badge hidden" id="f-badge">3</span>
#>         <svg class="gt-ms-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
#>           <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
#>         </svg>
#>       </div>
#>     </div>
#>     <div class="gt-ms-dropdown" id="f-dropdown">
#>       <div class="gt-ms-search">
#>         <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#7ec3f7" stroke-width="2.2">
#>           <circle cx="11" cy="11" r="8"></circle>
#>           <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
#>         </svg>
#>         <input type="text" id="f-search" placeholder="Search options..." autocomplete="off"/>
#>       </div>
#>       <div class="gt-style-switcher">
#>         <div class="gt-style-btn " data-style="check-only">
#>           <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>             <path d="M2 7l3.5 4L12 3" stroke="#7ec3f7" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>           <span>Check</span>
#>         </div>
#>         <div class="gt-style-btn active" data-style="checkbox">
#>           <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>             <rect x="1.5" y="1.5" width="11" height="11" rx="3" stroke="#7ec3f7" stroke-width="1.6"></rect>
#>             <path d="M3.5 7l2.8 3L10.5 4" stroke="#7ec3f7" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>           <span>Box</span>
#>         </div>
#>         <div class="gt-style-btn " data-style="filled">
#>           <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>             <rect x="1.5" y="1.5" width="11" height="11" rx="3" fill="#7ec3f7" fill-opacity="0.45" stroke="#7ec3f7" stroke-opacity="0.75" stroke-width="1.4"></rect>
#>           </svg>
#>           <span>Fill</span>
#>         </div>
#>       </div>
#>       <div class="gt-ms-all checked" id="f-all">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Select all</span>
#>       </div>
#>       <div id="f-options">
#>         <div class="gt-ms-option checked" data-value="apple" style="--opt-hue:200;">
#>           <div class="gt-ms-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Apple</span>
#>         </div>
#>         <div class="gt-ms-option checked" data-value="banana" style="--opt-hue:320;">
#>           <div class="gt-ms-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Banana</span>
#>         </div>
#>         <div class="gt-ms-option checked" data-value="cherry" style="--opt-hue:80;">
#>           <div class="gt-ms-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Cherry</span>
#>         </div>
#>       </div>
#>       <div class="gt-ms-footer">
#>         <span class="gt-ms-count" id="f-count">3 / 3 selected</span>
#>         <span class="gt-ms-clear" id="f-clear">Clear all</span>
#>       </div>
#>     </div>
#>   </div>
#> </div>

# Lock style, hide extra controls
glassMultiSelect(
  "f",
  fruits,
  check_style = "check-only",
  show_style_switcher = FALSE,
  show_select_all = FALSE,
  show_clear_all = FALSE
)
#> <style>#f-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;}</style>
#> <div class="gt-ms-field" id="f-field">
#>   <div class="gt-ms-wrap style-check-only " id="f-wrap" data-input-id="f" data-placeholder="Filter by Category" data-all-label="All categories">
#>     <div class="gt-ms-trigger" id="f-trigger">
#>       <span id="f-label">All categories</span>
#>       <div style="display:flex;align-items:center;gap:6px;">
#>         <span class="gt-ms-badge hidden" id="f-badge">3</span>
#>         <svg class="gt-ms-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
#>           <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
#>         </svg>
#>       </div>
#>     </div>
#>     <div class="gt-ms-dropdown" id="f-dropdown">
#>       <div class="gt-ms-search">
#>         <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#7ec3f7" stroke-width="2.2">
#>           <circle cx="11" cy="11" r="8"></circle>
#>           <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
#>         </svg>
#>         <input type="text" id="f-search" placeholder="Search options..." autocomplete="off"/>
#>       </div>
#>       <div class="gt-ms-all checked" id="f-all" style="display:none;">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Select all</span>
#>       </div>
#>       <div id="f-options">
#>         <div class="gt-ms-option checked" data-value="apple" style="--opt-hue:200;">
#>           <div class="gt-ms-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Apple</span>
#>         </div>
#>         <div class="gt-ms-option checked" data-value="banana" style="--opt-hue:320;">
#>           <div class="gt-ms-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Banana</span>
#>         </div>
#>         <div class="gt-ms-option checked" data-value="cherry" style="--opt-hue:80;">
#>           <div class="gt-ms-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Cherry</span>
#>         </div>
#>       </div>
#>       <div class="gt-ms-footer">
#>         <span class="gt-ms-count" id="f-count">3 / 3 selected</span>
#>         <span class="gt-ms-clear" id="f-clear" style="display:none;">Clear all</span>
#>       </div>
#>     </div>
#>   </div>
#> </div>

# Light theme
glassMultiSelect("f", fruits, theme = "light")
#> <style>#f-field{--ms-bg:rgba(255,255,255,0.98);--ms-border:rgba(0,0,0,0.12);--ms-text:#111111;--ms-accent:#2563eb;--ms-label:#111111;}</style>
#> <div class="gt-ms-field" id="f-field">
#>   <div class="gt-ms-wrap style-checkbox theme-light" id="f-wrap" data-input-id="f" data-placeholder="Filter by Category" data-all-label="All categories">
#>     <div class="gt-ms-trigger" id="f-trigger">
#>       <span id="f-label">All categories</span>
#>       <div style="display:flex;align-items:center;gap:6px;">
#>         <span class="gt-ms-badge hidden" id="f-badge">3</span>
#>         <svg class="gt-ms-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
#>           <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
#>         </svg>
#>       </div>
#>     </div>
#>     <div class="gt-ms-dropdown" id="f-dropdown">
#>       <div class="gt-ms-search">
#>         <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2.2">
#>           <circle cx="11" cy="11" r="8"></circle>
#>           <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
#>         </svg>
#>         <input type="text" id="f-search" placeholder="Search options..." autocomplete="off"/>
#>       </div>
#>       <div class="gt-style-switcher">
#>         <div class="gt-style-btn " data-style="check-only">
#>           <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>             <path d="M2 7l3.5 4L12 3" stroke="#2563eb" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>           <span>Check</span>
#>         </div>
#>         <div class="gt-style-btn active" data-style="checkbox">
#>           <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>             <rect x="1.5" y="1.5" width="11" height="11" rx="3" stroke="#2563eb" stroke-width="1.6"></rect>
#>             <path d="M3.5 7l2.8 3L10.5 4" stroke="#2563eb" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>           <span>Box</span>
#>         </div>
#>         <div class="gt-style-btn " data-style="filled">
#>           <svg class="gt-sb-icon" viewBox="0 0 14 14" fill="none">
#>             <rect x="1.5" y="1.5" width="11" height="11" rx="3" fill="#2563eb" fill-opacity="0.45" stroke="#2563eb" stroke-opacity="0.75" stroke-width="1.4"></rect>
#>           </svg>
#>           <span>Fill</span>
#>         </div>
#>       </div>
#>       <div class="gt-ms-all checked" id="f-all">
#>         <div class="gt-ms-check">
#>           <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>             <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>           </svg>
#>         </div>
#>         <span>Select all</span>
#>       </div>
#>       <div id="f-options">
#>         <div class="gt-ms-option checked" data-value="apple" style="--opt-hue:200;">
#>           <div class="gt-ms-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Apple</span>
#>         </div>
#>         <div class="gt-ms-option checked" data-value="banana" style="--opt-hue:320;">
#>           <div class="gt-ms-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Banana</span>
#>         </div>
#>         <div class="gt-ms-option checked" data-value="cherry" style="--opt-hue:80;">
#>           <div class="gt-ms-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#2563eb" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Cherry</span>
#>         </div>
#>       </div>
#>       <div class="gt-ms-footer">
#>         <span class="gt-ms-count" id="f-count">3 / 3 selected</span>
#>         <span class="gt-ms-clear" id="f-clear">Clear all</span>
#>       </div>
#>     </div>
#>   </div>
#> </div>
```
