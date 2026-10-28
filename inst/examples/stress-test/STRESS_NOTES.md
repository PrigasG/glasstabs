# Stress test findings

Run with `glasstabs::runGlassExample("stress-test")`. Record what breaks below.

Start on **Hostile labels** and verify both values of the **Example theme**
switch before entering the scale tabs. The 100k/50k, disabled-army, and
display-mode controls are intentionally created only while their tab is open;
this keeps the landing page and light-mode review usable without weakening the
individual stress scenarios.

## Theme coverage

- Light page, navigation, watch boxes, inputs, output blocks, and modals:
- Dark mode regression:
- Theme switch while a dropdown is open:

## Scale: single (100k choices)

- Client-mode first paint time:
- Client-mode search lag (typing "999"):
- Server-mode search lag:
- Tab-switch lag with client 100k mounted:

## Scale: multi (50k, all pre-selected)

- Initial render time:
- Selection chip display (count vs soup):
- Select-all latency:
- Dropdown scroll fps:

## Hostile labels

- XSS attempts (any alert = FAIL):
- 10k-char label layout:
- Empty/blank label rows:
- Duplicate labels select correct value?
- RTL alignment:

## Search torture

- Regex metachars (`.*`, `[a-`, `(unclosed`):
- 500-char paste:
- Fast typing lag:
- server_min_chars=3 gating:

## Update barrage

- Update while open:
- 10 <-> 50k swap:
- Selection preserved?
- Memory growth over 60s:

## Disabled army (5k/10k)

- Disabled styling at scale:
- Search skips disabled?
- Select-all excludes disabled?
- Keyboard nav skips disabled?

## Layout gauntlet

- Scroll-trap clipping:
- Bottom-of-page flip:
- Modal dismiss behavior:
- 25 selects input lag:

## Display modes (1k selected)

- Labels mode overflow:
- Summary truncation:
- Count accuracy after select-all + deselect-one:
- Live mode switching:

## Overlay battle

- Modal overlay dismisses open dropdown?
- Flash modal (1.5s) then reopen dropdown works?
- Loading spinner overlay (3s) dismisses dropdown?
- Hand-rolled full-screen div dismisses dropdown?
- Dropdown reopens cleanly after each overlay?
