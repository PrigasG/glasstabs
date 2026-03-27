## R CMD check results

0 errors | 0 warnings | 0 notes

Tested on:
- local macOS: R 4.4.x
- GitHub Actions CI: macOS, Windows, Ubuntu on R release and devel
- win-builder: R release and devel

## Resubmission

This is a resubmission.

## Changes in this version

This release is a JavaScript and CSS update only. No R functions, 
signatures, or exported APIs were changed.
 
The JavaScript engine for `glassSelect()` and `glassMultiSelect()` was
refactored to improve reliability in dynamic Shiny UI contexts
(`renderUI()`, `conditionalPanel()`, `shinyjs::show()`/`hide()`):
  
- Removed a broad `shiny:value` DOM rescan that caused unnecessary 
  re-initialization after unrelated Shiny output updates.
- Added proper widget teardown (`destroy()`) to prevent document-level 
  event listener leaks in long-running sessions.
- Widgets now emit their initial value to Shiny immediately after 
  initialization, fixing a class of timing bugs with `conditionalPanel()`.
- Opening a dropdown now closes any other open glasstabs dropdown, 
  fixing a visual stacking issue where multiple dropdowns could appear 
  simultaneously.
- Widget state is now maintained internally in JavaScript rather than 
  derived from DOM classes, improving performance and predictability.
- Search input is debounced and filters against cached lowercase labels.
- CSS additions: scroll containers for long option lists, styled 
  scrollbars, and `.gt-loading` / `.gt-disabled` utility classes.

