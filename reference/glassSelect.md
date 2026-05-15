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
#> <style>#fruit-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;--ms-ac-12:rgba(126,195,247,0.120);--ms-ac-16:rgba(126,195,247,0.160);--ms-ac-18:rgba(126,195,247,0.180);--ms-ac-22:rgba(126,195,247,0.220);--ms-ac-28:rgba(126,195,247,0.280);--ms-ac-32:rgba(126,195,247,0.320);--ms-ac-40:rgba(126,195,247,0.400);--ms-ac-55:rgba(126,195,247,0.550);--ms-ac-60:rgba(126,195,247,0.600);--ms-ac-75:rgba(126,195,247,0.750);--ms-tx-03:rgba(207,230,255,0.030);--ms-tx-04:rgba(207,230,255,0.040);--ms-tx-05:rgba(207,230,255,0.050);--ms-tx-06:rgba(207,230,255,0.060);--ms-tx-08:rgba(207,230,255,0.080);--ms-tx-35:rgba(207,230,255,0.350);--ms-tx-45:rgba(207,230,255,0.450);--ms-tx-50:rgba(207,230,255,0.500);--ms-tx-80:rgba(207,230,255,0.800);--ms-ac-tx-75:rgba(146,204,249,1.000);}</style>
#> <div class="gt-gs-field" id="fruit-field">
#>   <div class="gt-gs-wrap style-checkbox " id="fruit-wrap" data-input-id="fruit" data-placeholder="Select an option" data-searchable="true" data-clearable="false" data-all-choice-label="All categories" data-all-choice-value="__all__">
#>     <div class="gt-gs-trigger" id="fruit-trigger" role="combobox" tabindex="0" aria-haspopup="listbox" aria-expanded="false" aria-controls="fruit-dropdown">
#>       <span id="fruit-label">Select an option</span>
#>       <div style="display:flex;align-items:center;gap:6px;">
#>         <span class="gt-gs-clear" id="fruit-clear" style="display:none;">Clear</span>
#>         <svg class="gt-gs-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
#>           <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
#>         </svg>
#>       </div>
#>     </div>
#>     <div class="gt-gs-dropdown" id="fruit-dropdown" role="listbox">
#>       <div class="gt-gs-search">
#>         <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#7ec3f7" stroke-width="2.2">
#>           <circle cx="11" cy="11" r="8"></circle>
#>           <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
#>         </svg>
#>         <input type="text" id="fruit-search" placeholder="Search options..." autocomplete="off"/>
#>       </div>
#>       <div id="fruit-options">
#>         <div class="gt-gs-option" data-value="apple" role="option" aria-selected="false">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Apple</span>
#>         </div>
#>         <div class="gt-gs-option" data-value="banana" role="option" aria-selected="false">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Banana</span>
#>         </div>
#>         <div class="gt-gs-option" data-value="cherry" role="option" aria-selected="false">
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
#> <style>#fruit-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;--ms-ac-12:rgba(126,195,247,0.120);--ms-ac-16:rgba(126,195,247,0.160);--ms-ac-18:rgba(126,195,247,0.180);--ms-ac-22:rgba(126,195,247,0.220);--ms-ac-28:rgba(126,195,247,0.280);--ms-ac-32:rgba(126,195,247,0.320);--ms-ac-40:rgba(126,195,247,0.400);--ms-ac-55:rgba(126,195,247,0.550);--ms-ac-60:rgba(126,195,247,0.600);--ms-ac-75:rgba(126,195,247,0.750);--ms-tx-03:rgba(207,230,255,0.030);--ms-tx-04:rgba(207,230,255,0.040);--ms-tx-05:rgba(207,230,255,0.050);--ms-tx-06:rgba(207,230,255,0.060);--ms-tx-08:rgba(207,230,255,0.080);--ms-tx-35:rgba(207,230,255,0.350);--ms-tx-45:rgba(207,230,255,0.450);--ms-tx-50:rgba(207,230,255,0.500);--ms-tx-80:rgba(207,230,255,0.800);--ms-ac-tx-75:rgba(146,204,249,1.000);}</style>
#> <div class="gt-gs-field" id="fruit-field">
#>   <div class="gt-gs-wrap style-checkbox " id="fruit-wrap" data-input-id="fruit" data-placeholder="Select an option" data-searchable="true" data-clearable="true" data-all-choice-label="All categories" data-all-choice-value="__all__">
#>     <div class="gt-gs-trigger" id="fruit-trigger" role="combobox" tabindex="0" aria-haspopup="listbox" aria-expanded="false" aria-controls="fruit-dropdown">
#>       <span id="fruit-label">Banana</span>
#>       <div style="display:flex;align-items:center;gap:6px;">
#>         <span class="gt-gs-clear" id="fruit-clear">Clear</span>
#>         <svg class="gt-gs-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
#>           <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
#>         </svg>
#>       </div>
#>     </div>
#>     <div class="gt-gs-dropdown" id="fruit-dropdown" role="listbox">
#>       <div class="gt-gs-search">
#>         <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#7ec3f7" stroke-width="2.2">
#>           <circle cx="11" cy="11" r="8"></circle>
#>           <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
#>         </svg>
#>         <input type="text" id="fruit-search" placeholder="Search options..." autocomplete="off"/>
#>       </div>
#>       <div id="fruit-options">
#>         <div class="gt-gs-option" data-value="apple" role="option" aria-selected="false">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Apple</span>
#>         </div>
#>         <div class="gt-gs-option selected" data-value="banana" role="option" aria-selected="true">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Banana</span>
#>         </div>
#>         <div class="gt-gs-option" data-value="cherry" role="option" aria-selected="false">
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
#> <style>#fruit-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;--ms-ac-12:rgba(126,195,247,0.120);--ms-ac-16:rgba(126,195,247,0.160);--ms-ac-18:rgba(126,195,247,0.180);--ms-ac-22:rgba(126,195,247,0.220);--ms-ac-28:rgba(126,195,247,0.280);--ms-ac-32:rgba(126,195,247,0.320);--ms-ac-40:rgba(126,195,247,0.400);--ms-ac-55:rgba(126,195,247,0.550);--ms-ac-60:rgba(126,195,247,0.600);--ms-ac-75:rgba(126,195,247,0.750);--ms-tx-03:rgba(207,230,255,0.030);--ms-tx-04:rgba(207,230,255,0.040);--ms-tx-05:rgba(207,230,255,0.050);--ms-tx-06:rgba(207,230,255,0.060);--ms-tx-08:rgba(207,230,255,0.080);--ms-tx-35:rgba(207,230,255,0.350);--ms-tx-45:rgba(207,230,255,0.450);--ms-tx-50:rgba(207,230,255,0.500);--ms-tx-80:rgba(207,230,255,0.800);--ms-ac-tx-75:rgba(146,204,249,1.000);}</style>
#> <div class="gt-gs-field" id="fruit-field">
#>   <div class="gt-gs-wrap style-checkbox " id="fruit-wrap" data-input-id="fruit" data-placeholder="Select an option" data-searchable="true" data-clearable="false" data-all-choice-label="All fruits" data-all-choice-value="__all__">
#>     <div class="gt-gs-trigger" id="fruit-trigger" role="combobox" tabindex="0" aria-haspopup="listbox" aria-expanded="false" aria-controls="fruit-dropdown">
#>       <span id="fruit-label">Select an option</span>
#>       <div style="display:flex;align-items:center;gap:6px;">
#>         <span class="gt-gs-clear" id="fruit-clear" style="display:none;">Clear</span>
#>         <svg class="gt-gs-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
#>           <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
#>         </svg>
#>       </div>
#>     </div>
#>     <div class="gt-gs-dropdown" id="fruit-dropdown" role="listbox">
#>       <div class="gt-gs-search">
#>         <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#7ec3f7" stroke-width="2.2">
#>           <circle cx="11" cy="11" r="8"></circle>
#>           <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
#>         </svg>
#>         <input type="text" id="fruit-search" placeholder="Search options..." autocomplete="off"/>
#>       </div>
#>       <div id="fruit-options">
#>         <div class="gt-gs-option" data-value="__all__" role="option" aria-selected="false">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>All fruits</span>
#>         </div>
#>         <div class="gt-gs-option" data-value="apple" role="option" aria-selected="false">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Apple</span>
#>         </div>
#>         <div class="gt-gs-option" data-value="banana" role="option" aria-selected="false">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Banana</span>
#>         </div>
#>         <div class="gt-gs-option" data-value="cherry" role="option" aria-selected="false">
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
#> <style>#fruit-field{--ms-bg:rgba(9,20,42,0.97);--ms-border:rgba(255,255,255,0.10);--ms-text:#cfe6ff;--ms-accent:#7ec3f7;--ms-label:#cfe6ff;--ms-ac-12:rgba(126,195,247,0.120);--ms-ac-16:rgba(126,195,247,0.160);--ms-ac-18:rgba(126,195,247,0.180);--ms-ac-22:rgba(126,195,247,0.220);--ms-ac-28:rgba(126,195,247,0.280);--ms-ac-32:rgba(126,195,247,0.320);--ms-ac-40:rgba(126,195,247,0.400);--ms-ac-55:rgba(126,195,247,0.550);--ms-ac-60:rgba(126,195,247,0.600);--ms-ac-75:rgba(126,195,247,0.750);--ms-tx-03:rgba(207,230,255,0.030);--ms-tx-04:rgba(207,230,255,0.040);--ms-tx-05:rgba(207,230,255,0.050);--ms-tx-06:rgba(207,230,255,0.060);--ms-tx-08:rgba(207,230,255,0.080);--ms-tx-35:rgba(207,230,255,0.350);--ms-tx-45:rgba(207,230,255,0.450);--ms-tx-50:rgba(207,230,255,0.500);--ms-tx-80:rgba(207,230,255,0.800);--ms-ac-tx-75:rgba(146,204,249,1.000);}</style>
#> <div class="gt-gs-field" id="fruit-field">
#>   <div class="gt-gs-wrap style-filled " id="fruit-wrap" data-input-id="fruit" data-placeholder="Select an option" data-searchable="true" data-clearable="false" data-all-choice-label="All categories" data-all-choice-value="__all__">
#>     <div class="gt-gs-trigger" id="fruit-trigger" role="combobox" tabindex="0" aria-haspopup="listbox" aria-expanded="false" aria-controls="fruit-dropdown">
#>       <span id="fruit-label">Select an option</span>
#>       <div style="display:flex;align-items:center;gap:6px;">
#>         <span class="gt-gs-clear" id="fruit-clear" style="display:none;">Clear</span>
#>         <svg class="gt-gs-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
#>           <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"></path>
#>         </svg>
#>       </div>
#>     </div>
#>     <div class="gt-gs-dropdown" id="fruit-dropdown" role="listbox">
#>       <div class="gt-gs-search">
#>         <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#7ec3f7" stroke-width="2.2">
#>           <circle cx="11" cy="11" r="8"></circle>
#>           <path stroke-linecap="round" d="M21 21l-4.35-4.35"></path>
#>         </svg>
#>         <input type="text" id="fruit-search" placeholder="Search options..." autocomplete="off"/>
#>       </div>
#>       <div id="fruit-options">
#>         <div class="gt-gs-option" data-value="apple" role="option" aria-selected="false">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Apple</span>
#>         </div>
#>         <div class="gt-gs-option" data-value="banana" role="option" aria-selected="false">
#>           <div class="gt-gs-check">
#>             <svg width="10" height="8" viewBox="0 0 10 8" fill="none">
#>               <path d="M1 4l2.8 3L9 1" stroke="#7ec3f7" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"></path>
#>             </svg>
#>           </div>
#>           <span>Banana</span>
#>         </div>
#>         <div class="gt-gs-option" data-value="cherry" role="option" aria-selected="false">
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
