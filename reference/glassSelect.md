# Animated glass single-select dropdown

A stylized single-select Shiny input with optional search, clear
control, selection-marker styling, and programmatic updates via
[`updateGlassSelect()`](https://prigasg.github.io/glasstabs/reference/updateGlassSelect.md).

## Usage

``` r
glassSelect(
  inputId,
  choices,
  selected = NULL,
  label = NULL,
  placeholder = "Select an option",
  searchable = TRUE,
  clearable = FALSE,
  include_all = FALSE,
  all_choice_label = "All categories",
  all_choice_value = "__all__",
  check_style = c("checkbox", "check-only", "filled"),
  theme = "dark"
)
```

## Arguments

- inputId:

  Shiny input id.

- choices:

  Named or unnamed character vector of choices.

- selected:

  Initially selected value. Defaults to `NULL`.

- label:

  Optional field label shown above the widget.

- placeholder:

  Trigger label when nothing is selected.

- searchable:

  Logical. Show search input inside dropdown? Default `TRUE`.

- clearable:

  Logical. Show clear control for removing the current selection?
  Default `FALSE`.

- include_all:

  Logical. Prepend an explicit "All" option. Default `FALSE`.

- all_choice_label:

  Label used for the explicit "All" option.

- all_choice_value:

  Value used for the explicit "All" option.

- check_style:

  One of `"checkbox"` (default), `"check-only"`, or `"filled"`.

- theme:

  Color theme. One of `"dark"` (default) or `"light"`, or a
  [`glass_select_theme()`](https://prigasg.github.io/glasstabs/reference/glass_select_theme.md)
  object.

## Value

An
[`htmltools::tagList`](https://rstudio.github.io/htmltools/reference/tagList.html)
containing the single-select trigger, dropdown panel, and scoped
`<style>` block.

## Details

The widget registers one Shiny input:

- `input$<inputId>` : selected value as a length-1 character string, or
  `NULL` when nothing is selected

## Examples

``` r
fruits <- c(Apple = "apple", Banana = "banana", Cherry = "cherry")

glassSelect("fruit", fruits)
#> <style>#fruit-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;}</style>
#> <div class="gt-gs-field" id="fruit-field">
#>   <div class="gt-gs-wrap style-checkbox " id="fruit-wrap" data-input-id="fruit" data-placeholder="Select an option" data-searchable="true" data-clearable="false" data-all-choice-label="All categories" data-all-choice-value="__all__">
#>     <div class="gt-gs-trigger" id="fruit-trigger">
#>       <span id="fruit-label">Select an option</span>
#>       <div style="display:flex;align-items:center;gap:6px;">
#>         <span class="gt-gs-clear" id="fruit-clear" style="display:none;">Clear</span>
#>         <svg class="gt-gs-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
#>           <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
#>         </svg>
#>       </div>
#>     </div>
#>     <div class="gt-gs-dropdown" id="fruit-dropdown">
#>       <div class="gt-gs-search">
#>         <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#7ec3f7" stroke-width="2.2">
#>           <circle cx="11" cy="11" r="8"></circle>
#>           <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
#>         </svg>
#>         <input type="text" id="fruit-search" placeholder="Search options..." autocomplete="off"/>
#>       </div>
#>       <div id="fruit-options">
#>         <div class="gt-gs-option" data-value="apple">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Apple</span>
#>         </div>
#>         <div class="gt-gs-option" data-value="banana">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Banana</span>
#>         </div>
#>         <div class="gt-gs-option" data-value="cherry">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Cherry</span>
#>         </div>
#>       </div>
#>     </div>
#>   </div>
#> </div>

glassSelect(
  "fruit",
  fruits,
  selected = "banana",
  clearable = TRUE
)
#> <style>#fruit-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;}</style>
#> <div class="gt-gs-field" id="fruit-field">
#>   <div class="gt-gs-wrap style-checkbox " id="fruit-wrap" data-input-id="fruit" data-placeholder="Select an option" data-searchable="true" data-clearable="true" data-all-choice-label="All categories" data-all-choice-value="__all__">
#>     <div class="gt-gs-trigger" id="fruit-trigger">
#>       <span id="fruit-label">Banana</span>
#>       <div style="display:flex;align-items:center;gap:6px;">
#>         <span class="gt-gs-clear" id="fruit-clear">Clear</span>
#>         <svg class="gt-gs-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
#>           <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
#>         </svg>
#>       </div>
#>     </div>
#>     <div class="gt-gs-dropdown" id="fruit-dropdown">
#>       <div class="gt-gs-search">
#>         <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#7ec3f7" stroke-width="2.2">
#>           <circle cx="11" cy="11" r="8"></circle>
#>           <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
#>         </svg>
#>         <input type="text" id="fruit-search" placeholder="Search options..." autocomplete="off"/>
#>       </div>
#>       <div id="fruit-options">
#>         <div class="gt-gs-option" data-value="apple">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Apple</span>
#>         </div>
#>         <div class="gt-gs-option selected" data-value="banana">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Banana</span>
#>         </div>
#>         <div class="gt-gs-option" data-value="cherry">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Cherry</span>
#>         </div>
#>       </div>
#>     </div>
#>   </div>
#> </div>

glassSelect(
  "fruit",
  fruits,
  include_all = TRUE,
  all_choice_label = "All fruits",
  all_choice_value = "__all__"
)
#> <style>#fruit-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;}</style>
#> <div class="gt-gs-field" id="fruit-field">
#>   <div class="gt-gs-wrap style-checkbox " id="fruit-wrap" data-input-id="fruit" data-placeholder="Select an option" data-searchable="true" data-clearable="false" data-all-choice-label="All fruits" data-all-choice-value="__all__">
#>     <div class="gt-gs-trigger" id="fruit-trigger">
#>       <span id="fruit-label">Select an option</span>
#>       <div style="display:flex;align-items:center;gap:6px;">
#>         <span class="gt-gs-clear" id="fruit-clear" style="display:none;">Clear</span>
#>         <svg class="gt-gs-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
#>           <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
#>         </svg>
#>       </div>
#>     </div>
#>     <div class="gt-gs-dropdown" id="fruit-dropdown">
#>       <div class="gt-gs-search">
#>         <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#7ec3f7" stroke-width="2.2">
#>           <circle cx="11" cy="11" r="8"></circle>
#>           <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
#>         </svg>
#>         <input type="text" id="fruit-search" placeholder="Search options..." autocomplete="off"/>
#>       </div>
#>       <div id="fruit-options">
#>         <div class="gt-gs-option" data-value="__all__">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>All fruits</span>
#>         </div>
#>         <div class="gt-gs-option" data-value="apple">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Apple</span>
#>         </div>
#>         <div class="gt-gs-option" data-value="banana">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Banana</span>
#>         </div>
#>         <div class="gt-gs-option" data-value="cherry">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Cherry</span>
#>         </div>
#>       </div>
#>     </div>
#>   </div>
#> </div>

glassSelect(
  "fruit",
  fruits,
  check_style = "filled"
)
#> <style>#fruit-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;}</style>
#> <div class="gt-gs-field" id="fruit-field">
#>   <div class="gt-gs-wrap style-filled " id="fruit-wrap" data-input-id="fruit" data-placeholder="Select an option" data-searchable="true" data-clearable="false" data-all-choice-label="All categories" data-all-choice-value="__all__">
#>     <div class="gt-gs-trigger" id="fruit-trigger">
#>       <span id="fruit-label">Select an option</span>
#>       <div style="display:flex;align-items:center;gap:6px;">
#>         <span class="gt-gs-clear" id="fruit-clear" style="display:none;">Clear</span>
#>         <svg class="gt-gs-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
#>           <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
#>         </svg>
#>       </div>
#>     </div>
#>     <div class="gt-gs-dropdown" id="fruit-dropdown">
#>       <div class="gt-gs-search">
#>         <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#7ec3f7" stroke-width="2.2">
#>           <circle cx="11" cy="11" r="8"></circle>
#>           <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
#>         </svg>
#>         <input type="text" id="fruit-search" placeholder="Search options..." autocomplete="off"/>
#>       </div>
#>       <div id="fruit-options">
#>         <div class="gt-gs-option" data-value="apple">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Apple</span>
#>         </div>
#>         <div class="gt-gs-option" data-value="banana">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Banana</span>
#>         </div>
#>         <div class="gt-gs-option" data-value="cherry">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Cherry</span>
#>         </div>
#>       </div>
#>     </div>
#>   </div>
#> </div>
```
