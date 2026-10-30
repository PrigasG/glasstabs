## Submission

This is glasstabs 0.4.1. The previous CRAN version is 0.4.0.

## Changes in this version (0.4.1)

This update stabilizes select input behavior and accessibility. It improves
keyboard access and ARIA state for dropdown controls, corrects selection and
server-search behavior, and adds guidance for selection semantics, modules,
linked filters, migration, and troubleshooting.

- Select chrome controls are real keyboard-accessible buttons with complete
  ARIA state; select-all uses one consistent enabled-and-visible scope.
- Server search ignores stale responses, guards unanswered searches, and
  supports disabled choices as they arrive.
- Single-select preserves the synthetic All row on updates and distinguishes
  an empty-string choice from clearing the input.
- Documentation adds runnable module, linked-filter, migration, gallery,
  troubleshooting, and deployment guides.

See NEWS.md for the full list.



