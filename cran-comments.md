## R CMD check results

0 errors | 0 warnings | 0 notes

Tested on:
- local macOS: R 4.4.x
- GitHub Actions CI: macOS, Windows, Ubuntu on R release and devel
- win-builder: R release and devel

## Resubmission

This is a resubmission.

## Changes in this version
 
This release adds server-side tab management helpers and improves dynamic tab
behavior, alongside JavaScript reliability improvements for the select widgets.

Changes include:

- New exported tab helpers:
  `updateGlassTabsUI()`, `showGlassTab()`, `hideGlassTab()`,
  `appendGlassTab()`, and `removeGlassTab()`.
- `glassTabsUI()` now validates invalid `selected` tab ids early.
- The tab widget now reports its initial active tab to Shiny on first render,
  improving `glassTabsServer()` behavior.
- Added ARIA roles and selected-state attributes to tab navigation markup.
- Improved runtime tab behavior for hide/show/append/remove flows and rapid
  successive tab updates.
- The JavaScript engine for `glassSelect()` and `glassMultiSelect()` was
  refactored to improve reliability in dynamic Shiny UI contexts
  (`renderUI()`, `conditionalPanel()`, `shinyjs::show()`/`hide()`).
- Opening a dropdown now closes any other open glasstabs dropdown, fixing a
  visual stacking issue where multiple dropdowns could appear simultaneously.
- Added a cheatsheet vignette and a smoke-test example app documenting the new
  tab-management features and common usage patterns.

