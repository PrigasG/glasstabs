local_browser_pkg_root <- function() {
  old <- Sys.getenv("GLASSTABS_TEST_PKG_ROOT", unset = NA_character_)
  Sys.setenv(GLASSTABS_TEST_PKG_ROOT = normalizePath(test_path("..", "..")))
  withr::defer({
    if (is.na(old)) {
      Sys.unsetenv("GLASSTABS_TEST_PKG_ROOT")
    } else {
      Sys.setenv(GLASSTABS_TEST_PKG_ROOT = old)
    }
  }, testthat::teardown_env())
}

test_that("browser: glassSelect opens and clicking an option updates input", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-glassSelect-click",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#fruit-trigger")
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') !== null")
  expect_true(app$get_js("
    Math.abs(
      document.querySelector('#fruit-dropdown').offsetWidth -
      document.querySelector('#fruit-trigger').offsetWidth
    ) <= 2
  "))
  app$click(selector = "#fruit-dropdown .gt-gs-option[data-value='banana']")
  app$wait_for_idle()

  expect_equal(app$get_value(input = "fruit"), "banana")
})

test_that("browser: glassSelect automatic search responds to threshold updates", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-glassSelect-auto-search",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  expect_true(app$get_js("(function() {
    var input = document.querySelector('#auto_single-search');
    return input.closest('.gt-gs-search').classList.contains('hidden') &&
      input.disabled;
  })()"))

  app$set_inputs(auto_single_show = "click")
  app$wait_for_idle()
  app$wait_for_js("(function() {
    var input = document.querySelector('#auto_single-search');
    return !input.closest('.gt-gs-search').classList.contains('hidden') && !input.disabled;
  })()")

  app$set_inputs(auto_single_hide = "click")
  app$wait_for_idle()
  app$wait_for_js("(function() {
    var input = document.querySelector('#auto_single-search');
    return input.closest('.gt-gs-search').classList.contains('hidden') && input.disabled;
  })()")
})

test_that("browser: glassMultiSelect automatic search responds to threshold updates", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-glassMultiSelect-auto-search",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  expect_true(app$get_js("(function() {
    var input = document.querySelector('#adaptive-search');
    return input.closest('.gt-ms-search').classList.contains('hidden') &&
      input.disabled;
  })()"))

  app$set_inputs(adaptive_show_search = "click")
  app$wait_for_js("(function() {
    var input = document.querySelector('#adaptive-search');
    return !input.closest('.gt-ms-search').classList.contains('hidden') &&
      !input.disabled;
  })()")

  app$set_inputs(adaptive_hide_search = "click")
  app$wait_for_js("(function() {
    var input = document.querySelector('#adaptive-search');
    return input.closest('.gt-ms-search').classList.contains('hidden') &&
      input.disabled;
  })()")
})

test_that("browser: choice-only updates preserve disabled rows", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-preserve-disabled-choices",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$set_inputs(refresh_disabled_choices = "click")
  app$wait_for_idle()

  expect_true(app$get_js("(function() {
    var single = document.querySelector(
      '#disabled_update_single-options .gt-gs-option[data-value=\"banana\"]'
    );
    var multi = document.querySelector(
      '#disabled_update_multi-options .gt-ms-option[data-value=\"banana\"]'
    );
    return single.classList.contains('disabled') &&
      single.getAttribute('aria-disabled') === 'true' &&
      multi.classList.contains('disabled') &&
      multi.getAttribute('aria-disabled') === 'true';
  })()"))
})

test_that("browser: glassMultiSelect toggles choices and updates input", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-glassMultiSelect-toggle",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  expect_equal(app$get_value(input = "cats"), "apple")

  app$click(selector = "#cats-trigger")
  app$wait_for_js("document.querySelector('#cats-dropdown.open') !== null")
  app$click(selector = "#cats-dropdown .gt-ms-option[data-value='cherry']")
  app$wait_for_idle()

  expect_equal(app$get_value(input = "cats"), c("apple", "cherry"))
})

test_that("browser: select dropdowns match their fields and stay viewport-safe", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-select-trigger-width",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  expect_true(app$get_js("
    window.__shortSingleInitialWidth =
      document.querySelector('#short_single-wrap').offsetWidth;
    window.__shortSingleInitialWidth > 0;
  "))
  app$click(selector = "#short_single-trigger")
  app$wait_for_js("document.querySelector('#short_single-dropdown.open') !== null")
  expect_true(app$get_js("
    (function() {
      var trigger = document.querySelector('#short_single-trigger');
      var dropdown = document.querySelector('#short_single-dropdown');
      return Math.abs(dropdown.offsetWidth - trigger.offsetWidth) <= 1;
    })()
  "))
  expect_true(app$get_js("
    (function() {
      var words = document.querySelector(
        '#short_single-dropdown [data-value=long_words] > span:last-child'
      );
      var token = document.querySelector(
        '#short_single-dropdown [data-value=long_token] > span:last-child'
      );
      return words.scrollWidth <= words.clientWidth + 1 &&
        token.scrollWidth <= token.clientWidth + 1;
    })()
  "))
  expect_true(app$get_js("
    (function() {
      var label = document.querySelector(
        '#short_single-dropdown [data-value=pathological] > span:last-child'
      );
      var option = label.parentElement;
      return label.textContent.length > 9000 &&
        getComputedStyle(label).webkitLineClamp === '3' &&
        option.offsetHeight < 90;
    })()
  "))

  app$click(selector = "#short_single-dropdown [data-value=pathological]")
  app$wait_for_js("document.querySelector('#short_single-dropdown.open') === null")
  expect_true(app$get_js("
    (function() {
      var field = document.querySelector('#short_single-field');
      var wrap = document.querySelector('#short_single-wrap');
      var label = document.querySelector('#short_single-label');
      return wrap.offsetWidth < field.offsetWidth &&
        Math.abs(wrap.offsetWidth - window.__shortSingleInitialWidth) < 1 &&
        label.scrollWidth > label.clientWidth;
    })()
  "))

  expect_true(app$get_js("
    (function() {
      var trigger = document.querySelector('#short_single-trigger');
      var nativeMatchMedia = window.matchMedia.bind(window);
      window.matchMedia = function(query) {
        if (query === '(hover: hover) and (pointer: fine)') {
          return {matches:true};
        }
        return nativeMatchMedia(query);
      };
      trigger.dispatchEvent(new MouseEvent('mouseenter', {bubbles:true}));
      return trigger.getAttribute('aria-label').length > 9000;
    })()
  "))
  # Same retry treatment as the option tooltip below: the trigger
  # tooltip shows 420 ms after mouseenter, and a slow runner can miss
  # a single 4 s wait. Re-dispatching is idempotent (schedule() clears
  # the previous timer first), and a genuinely broken tooltip fails
  # every attempt.
  trigger_tip_shown <- FALSE
  for (attempt in 1:5) {
    app$get_js("
      (function() {
        var trigger = document.querySelector('#short_single-trigger');
        trigger.dispatchEvent(new MouseEvent('mouseenter', {bubbles:true}));
        return true;
      })()
    ")
    trigger_tip_shown <- tryCatch({
      app$wait_for_js("
        document.querySelector('#short_single-overflow-tooltip.visible') !== null
      ", timeout = 2000)
      TRUE
    }, error = function(e) FALSE)
    if (trigger_tip_shown) break
  }
  expect_true(trigger_tip_shown)
  expect_true(app$get_js("
    (function() {
      var tip = document.querySelector('#short_single-overflow-tooltip');
      var rect = tip.getBoundingClientRect();
      return tip.getAttribute('role') === 'tooltip' &&
        tip.textContent.length === 601 &&
        Number(tip.getAttribute('data-full-length')) > 9000 &&
        getComputedStyle(tip).pointerEvents === 'none' &&
        rect.left >= 11 && rect.right <= window.innerWidth - 11;
    })()
  "))

  # A tooltip from one field must never cover or delay opening another field.
  app$click(selector = "#short_multi-trigger")
  app$wait_for_js("
    document.querySelector('#short_multi-dropdown.open') !== null &&
      !document.querySelector('#short_single-overflow-tooltip.visible')
  ")
  expect_true(app$get_js("
    (function() {
      document.querySelector('#short_multi-wrap')._gt.close();
      return true;
    })()
  "))
  app$wait_for_js("
    document.querySelector('#short_multi-dropdown').parentElement.id ===
      'short_multi-wrap'
  ")

  app$click(selector = "#short_single-trigger")
  app$wait_for_js("document.querySelector('#short_single-dropdown.open') !== null")

  expect_true(app$get_js("
    (function() {
      var field = document.querySelector('#short_single-field');
      field.style.width = '220px';
      window.dispatchEvent(new Event('resize'));
      return true;
    })()
  "))
  # Resize repositions the open dropdown instead of closing it (mobile URL-bar
  # and on-screen keyboard resizes must not strand the user mid-task). The
  # field and panel retain one continuous, equal-width silhouette.
  app$wait_for_js("
    document.querySelector('#short_single-dropdown.open') !== null &&
    Math.abs(
      document.querySelector('#short_single-dropdown').offsetWidth -
      document.querySelector('#short_single-trigger').offsetWidth
    ) <= 1
  ")

  expect_true(app$get_js("
    (function() {
      var field = document.querySelector('#short_single-field');
      field.style.position = 'fixed';
      field.style.right = '0';
      field.style.top = '20px';
      window.dispatchEvent(new Event('resize'));
      return true;
    })()
  "))
  # The open dropdown follows the trigger and stays inside the viewport.
  app$wait_for_js("
    (function() {
      var dropdown = document.querySelector('#short_single-dropdown.open');
      if (!dropdown) return false;
      var rect = dropdown.getBoundingClientRect();
      return rect.left >= 7 && rect.right <= window.innerWidth - 7;
    })()
  ")

  app$click(selector = "#short_multi-trigger")
  app$wait_for_js("document.querySelector('#short_multi-dropdown.open') !== null")
  expect_true(app$get_js("
    (function() {
      var trigger = document.querySelector('#short_multi-trigger');
      var dropdown = document.querySelector('#short_multi-dropdown');
      return Math.abs(dropdown.offsetWidth - trigger.offsetWidth) <= 1 &&
        dropdown.classList.contains('gt-compact-controls');
    })()
  "))
  expect_true(app$get_js("
    (function() {
      var words = document.querySelector(
        '#short_multi-dropdown [data-value=long_words] > span:last-child'
      );
      var token = document.querySelector(
        '#short_multi-dropdown [data-value=long_token] > span:last-child'
      );
      return words.scrollWidth <= words.clientWidth + 1 &&
        token.scrollWidth <= token.clientWidth + 1;
    })()
  "))
  expect_true(app$get_js("
    (function() {
      var label = document.querySelector(
        '#short_multi-dropdown [data-value=pathological] > span:last-child'
      );
      return label.textContent.length > 9000 &&
        getComputedStyle(label).webkitLineClamp === '3' &&
        label.parentElement.offsetHeight < 90;
    })()
  "))
  expect_true(app$get_js("
    (function() {
      var dropdown = document.querySelector('#short_multi-dropdown');
      var buttons = Array.from(dropdown.querySelectorAll('.gt-style-btn'));
      var panel = dropdown.getBoundingClientRect();
      return buttons.length === 3 && buttons.every(function(button) {
        var rect = button.getBoundingClientRect();
        return rect.left >= panel.left && rect.right <= panel.right &&
          button.textContent.trim().length > 0;
      });
    })()
  "))
  expect_true(app$get_js("
    (function() {
      var wrap = document.querySelector('#short_multi-wrap');
      wrap._gt.close();
      wrap._gt.setValue(['long_words', 'pathological'], {notify:false});
      var trigger = document.querySelector('#short_multi-trigger');
      trigger.dispatchEvent(new MouseEvent('mouseenter', {bubbles:true}));
      return trigger.getAttribute('aria-label').length > 9000;
    })()
  "))
  Sys.sleep(0.5)
  expect_false(app$get_js("
    document.querySelector('#short_multi-overflow-tooltip') !== null
  "))

  app$click(selector = "#short_multi-trigger")
  app$wait_for_js("document.querySelector('#short_multi-dropdown.open') !== null")
  expect_true(app$get_js("
    (function() {
      var option = document.querySelector(
        '#short_multi-dropdown [data-value=pathological]'
      );
      option.dispatchEvent(new MouseEvent('mouseenter', {bubbles:true}));
      return option.querySelector('span:last-child').scrollHeight >
        option.querySelector('span:last-child').clientHeight;
    })()
  "))
  # The tooltip appears 180 ms after mouseenter, but a slow runner or a
  # dropdown re-render replacing the option node inside that window can
  # miss a single attempt: re-dispatch mouseenter on the current node
  # until the tooltip shows. A genuinely broken tooltip fails every
  # attempt, so this retries flakiness without masking a real failure.
  tooltip_shown <- FALSE
  for (attempt in 1:5) {
    app$get_js("
      (function() {
        var option = document.querySelector(
          '#short_multi-dropdown [data-value=pathological]'
        );
        option.dispatchEvent(new MouseEvent('mouseenter', {bubbles:true}));
        return true;
      })()
    ")
    tooltip_shown <- tryCatch({
      app$wait_for_js("
        document.querySelector(
          '#short_multi-option-overflow-tooltip.visible'
        ) !== null
      ", timeout = 2000)
      TRUE
    }, error = function(e) FALSE)
    if (tooltip_shown) break
  }
  expect_true(tooltip_shown)
  expect_true(app$get_js("
    (function() {
      var option = document.querySelector(
        '#short_multi-dropdown [data-value=pathological]'
      );
      var tip = document.querySelector(
        '#short_multi-option-overflow-tooltip'
      );
      return tip.textContent.length === 601 &&
        Number(tip.getAttribute('data-full-length')) > 9000 &&
        option.getAttribute('aria-describedby') === tip.id &&
        document.querySelectorAll('.gt-option-overflow-tooltip').length === 1;
    })()
  "))
  app$click(selector = "#short_multi-dropdown [data-value=pathological]")
  app$wait_for_js("
    !document.querySelector('#short_multi-option-overflow-tooltip.visible') &&
      document.querySelector('#short_multi-dropdown.open') !== null
  ")
})

test_that("browser: overflow tooltips respect mode, truncation, and keyboard navigation", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-overflow-tooltip-modes",
    height = 900,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  show_keyboard_tip <- function(dropdown, tooltip) {
    visible <- FALSE
    for (attempt in seq_len(5)) {
      app$get_js(sprintf("(function() {
        document.querySelector('%s').dispatchEvent(
          new KeyboardEvent('keydown', {key:'End', bubbles:true}));
        return true;
      })()", dropdown))
      Sys.sleep(0.35)
      visible <- isTRUE(app$get_js(sprintf(
        "document.querySelector('%s.visible') !== null", tooltip
      )))
      if (visible) break
    }
    expect_true(visible)
  }

  # Short trigger and option labels must not create a visual tooltip.
  expect_true(app$get_js("(function() {
    var trigger = document.querySelector('#short_single-trigger');
    trigger.dispatchEvent(new MouseEvent('mouseenter', {bubbles:true}));
    trigger.click();
    var option = document.querySelector(
      '#short_single-dropdown [data-value=one]'
    );
    option.dispatchEvent(new MouseEvent('mouseenter', {bubbles:true}));
    return true;
  })()"))
  Sys.sleep(0.35)
  expect_false(app$get_js("
    document.querySelector('#short_single-overflow-tooltip.visible') !== null ||
      document.querySelector('#short_single-option-overflow-tooltip.visible') !== null
  "))

  # Both single- and multi-select options reveal clamped text to keyboard users.
  show_keyboard_tip("#short_single-dropdown", "#short_single-option-overflow-tooltip")

  app$click(selector = "#short_multi-trigger")
  app$wait_for_js("document.querySelector('#short_multi-dropdown.open') !== null")
  expect_true(app$get_js("(function() {
    var shortOption = document.querySelector(
      '#short_multi-dropdown [data-value=one]'
    );
    shortOption.dispatchEvent(new MouseEvent('mouseenter', {bubbles:true}));
    return true;
  })()"))
  Sys.sleep(0.35)
  expect_false(app$get_js("
    document.querySelector('#short_multi-option-overflow-tooltip.visible') !== null
  "))
  show_keyboard_tip("#short_multi-dropdown", "#short_multi-option-overflow-tooltip")

  # `never` suppresses both trigger and option tooltips even for extreme text.
  app$click(selector = "#never_single-trigger")
  app$wait_for_js("document.querySelector('#never_single-dropdown.open') !== null")
  expect_true(app$get_js("(function() {
    var trigger = document.querySelector('#never_single-trigger');
    var option = document.querySelector(
      '#never_single-dropdown [data-value=pathological]'
    );
    trigger.dispatchEvent(new MouseEvent('mouseenter', {bubbles:true}));
    option.dispatchEvent(new MouseEvent('mouseenter', {bubbles:true}));
    return true;
  })()"))
  Sys.sleep(0.35)
  expect_false(app$get_js("
    document.querySelector('#never_single-overflow-tooltip.visible') !== null ||
      document.querySelector('#never_single-option-overflow-tooltip.visible') !== null
  "))

  app$click(selector = "#never_multi-trigger")
  app$wait_for_js("document.querySelector('#never_multi-dropdown.open') !== null")
  expect_true(app$get_js("(function() {
    var option = document.querySelector(
      '#never_multi-dropdown [data-value=pathological]'
    );
    option.dispatchEvent(new MouseEvent('mouseenter', {bubbles:true}));
    return true;
  })()"))
  Sys.sleep(0.35)
  expect_false(app$get_js("
    document.querySelector('#never_multi-option-overflow-tooltip.visible') !== null
  "))
})

test_that("browser: tongue can be disabled for detached native-like panels", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-detached-selects",
    height = 900,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#detached_single-trigger")
  app$wait_for_js("document.querySelector('#detached_single-dropdown.open') !== null")
  app$wait_for_js("
    Math.abs(new DOMMatrix(
      getComputedStyle(document.querySelector('#detached_single-dropdown'))
        .transform
    ).m42) < 0.1
  ")
  expect_true(app$get_js("
    document.querySelector('#detached_single-dropdown')
      .classList.contains('gt-no-tongue')
  "))
  expect_true(app$get_js("
    (function() {
      var trigger = document.querySelector('#detached_single-trigger');
      var dropdown = document.querySelector('#detached_single-dropdown');
      var tr = trigger.getBoundingClientRect();
      var dr = dropdown.getBoundingClientRect();
      var gap = dropdown.classList.contains('gt-flip-above')
        ? tr.top - dr.bottom
        : dr.top - tr.bottom;
      return Math.abs(dr.width - tr.width) <= 1 && gap >= 4.5 && gap <= 7.5;
    })()
  "))
  expect_true(app$get_js("
    (function() {
      var dropdown = document.querySelector('#detached_single-dropdown');
      var style = getComputedStyle(dropdown);
      var durations = style.transitionDuration.split(',').map(function(value) {
        value = value.trim();
        return value.endsWith('ms')
          ? parseFloat(value)
          : parseFloat(value) * 1000;
      });
      return Math.max.apply(null, durations) <= 121 &&
        parseFloat(style.borderTopLeftRadius) > 0;
    })()
  "))
  expect_true(app$get_js("
    (function() {
      var trigger = document.querySelector('#detached_single-trigger');
      var label = document.querySelector(
        '#detached_single-field .gt-input-label'
      );
      return parseFloat(getComputedStyle(trigger).borderBottomLeftRadius) > 0 &&
        label.classList.contains('gt-label-regular') &&
        getComputedStyle(label).getPropertyValue('--gt-label-size').trim() ===
          '14px';
    })()
  "))

  Sys.sleep(0.55)
  app$click(selector = "#detached_single-trigger")
  app$wait_for_js("
    document.querySelector('#detached_single-dropdown').parentElement.id ===
      'detached_single-wrap'
  ")

  app$click(selector = "#detached_multi-trigger")
  app$wait_for_js("document.querySelector('#detached_multi-dropdown.open') !== null")
  app$wait_for_js("
    Math.abs(new DOMMatrix(
      getComputedStyle(document.querySelector('#detached_multi-dropdown'))
        .transform
    ).m42) < 0.1
  ")
  expect_true(app$get_js("
    (function() {
      var trigger = document.querySelector('#detached_multi-trigger');
      var dropdown = document.querySelector('#detached_multi-dropdown');
      var label = document.querySelector('#detached_multi-field .gt-input-label');
      var durations = getComputedStyle(dropdown).transitionDuration
        .split(',').map(function(value) {
          value = value.trim();
          return value.endsWith('ms')
            ? parseFloat(value)
            : parseFloat(value) * 1000;
        });
      return dropdown.classList.contains('gt-no-tongue') &&
        Math.abs(dropdown.offsetWidth - trigger.offsetWidth) <= 1 &&
        Math.max.apply(null, durations) <= 121 &&
        !label.classList.contains('gt-label-regular');
    })()
  "))
})

test_that("browser: multiselect refinements update as one transaction", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-multiselect-refinements",
    height = 900,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  expect_equal(app$get_value(input = "adaptive"), c("apple", "banana"))
  expect_equal(app$get_value(output = "adaptive_events"), "0")
  expect_true(app$get_js("
    document.querySelector('#adaptive-wrap .gt-ms-search').classList.contains('hidden') &&
    document.querySelector('#adaptive-label').textContent === 'Apple +1'
  "))

  app$set_inputs(adaptive_expand = "click")
  app$wait_for_js("
    !document.querySelector('#adaptive-wrap .gt-ms-search').classList.contains('hidden') &&
    document.querySelectorAll('#adaptive-wrap .gt-ms-option').length === 5
  ")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "adaptive"), c("apple", "banana"))
  expect_equal(app$get_value(output = "adaptive_events"), "0")

  app$click(selector = "#adaptive-trigger")
  app$wait_for_js("document.querySelector('#adaptive-dropdown.open') !== null")
  expect_true(app$get_js("
    getComputedStyle(document.querySelector('#adaptive-options')).maxHeight === '120px'
  "))

  app$set_inputs(adaptive_silent = "click")
  app$wait_for_js("document.querySelector('#adaptive-label').textContent === 'Cherry'")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "adaptive"), c("apple", "banana"))
  expect_equal(app$get_value(output = "adaptive_events"), "0")
})

test_that("browser: runtime setShape reaches wrapper and teleported dropdown", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-runtime-square-shape",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  expect_true(app$get_js("
    (function() {
      var wrap = document.querySelector('#shape_single-wrap');
      return !!wrap._gt && typeof wrap._gt.setShape === 'function';
    })()
  "))
  expect_true(app$get_js("
    document.querySelector('#shape_single-wrap')._gt.setShape('square');
    document.querySelector('#shape_single-wrap').classList.contains('shape-square');
  "))
  app$wait_for_js("document.querySelector('#shape_single-wrap').classList.contains('shape-square')")

  app$click(selector = "#shape_single-trigger")
  app$wait_for_js("
    (function() {
      var dd = document.querySelector('#shape_single-dropdown.open');
      return !!dd && dd.classList.contains('shape-square') && dd.parentElement === document.body;
    })()
  ")

  expect_true(app$get_js("
    document.querySelector('#shape_single-wrap').classList.contains('shape-square') &&
    document.querySelector('#shape_single-dropdown').classList.contains('shape-square') &&
    document.querySelector('#shape_single-dropdown').parentElement === document.body
  "))
})

test_that("browser: controller close closes an open dropdown and updates open state", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-close-all-selects",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  expect_equal(app$get_value(output = "fruit_open_state"), "closed")

  app$click(selector = "#fruit-trigger")
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') !== null")
  app$wait_for_idle()
  expect_equal(app$get_value(output = "fruit_open_state"), "open")

  expect_true(app$get_js("
    document.querySelector('#fruit-wrap')._gt.close();
    true;
  "))
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') === null")
  app$wait_for_idle()
  expect_equal(app$get_value(output = "fruit_open_state"), "closed")
})

test_that("browser: immediate outside presses close teleported dropdowns", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-immediate-outside-close",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()

  expect_true(app$get_js("
    (function() {
      document.querySelector('#fruit-trigger').click();
      document.body.dispatchEvent(new PointerEvent('pointerdown', {
        bubbles: true,
        composed: true
      }));
      /* Close animates (180ms retract, 250ms teleport fallback), so settled
         must wait past 250ms; 150ms only worked when close teleported
         instantly and no retract was visible. */
      setTimeout(function() {
        document.body.setAttribute('data-gt-close-settled', 'true');
      }, 300);
      return true;
    })()
  "))
  app$wait_for_js("document.body.getAttribute('data-gt-close-settled') === 'true'")

  expect_true(app$get_js("
    (function() {
      var wrap = document.querySelector('#fruit-wrap');
      var dropdown = document.querySelector('#fruit-dropdown');
      return !wrap.classList.contains('gt-layer-active') &&
        !dropdown.classList.contains('open') &&
        dropdown.parentElement === wrap &&
        document.activeElement !== dropdown.querySelector('input');
    })()
  "))
  app$wait_for_idle()
  expect_equal(app$get_value(output = "fruit_open_state"), "closed")
})

test_that("browser: overlay event interception cannot strand dropdowns", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-overlay-dropdown-close",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()

  expect_true(app$get_js("
    (function() {
      var overlay = document.createElement('div');
      overlay.id = 'test-loading-overlay';
      overlay.addEventListener('pointerdown', function(e) {
        e.stopPropagation();
      });
      document.body.appendChild(overlay);

      document.querySelector('#cats-trigger').click();
      overlay.dispatchEvent(new PointerEvent('pointerdown', {
        bubbles: true,
        composed: true
      }));
      /* See above: close animates, so settled must wait past the 250ms
         teleport fallback. */
      setTimeout(function() {
        document.body.setAttribute('data-gt-overlay-close-settled', 'true');
      }, 300);
      return true;
    })()
  "))
  app$wait_for_js("document.body.getAttribute('data-gt-overlay-close-settled') === 'true'")

  expect_true(app$get_js("
    (function() {
      var wrap = document.querySelector('#cats-wrap');
      var dropdown = document.querySelector('#cats-dropdown');
      var overlay = document.querySelector('#test-loading-overlay');
      if (overlay) overlay.remove();
      return !wrap.classList.contains('gt-layer-active') &&
        !dropdown.classList.contains('open') &&
        dropdown.parentElement === wrap &&
        document.activeElement !== dropdown.querySelector('input');
    })()
  "))
})

test_that("browser: presses inside a teleported dropdown keep it open", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-inside-dropdown-press",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#cats-trigger")
  app$wait_for_js("document.querySelector('#cats-dropdown.open') !== null")

  expect_true(app$get_js("
    (function() {
      var option = document.querySelector('#cats-dropdown .gt-ms-option');
      option.dispatchEvent(new PointerEvent('pointerdown', {
        bubbles: true,
        composed: true
      }));
      return document.querySelector('#cats-dropdown.open') !== null &&
        document.querySelector('#cats-wrap').classList.contains('gt-layer-active');
    })()
  "))
})

test_that("browser: a programmatically opened Bootstrap modal closes dropdowns", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-modal-dropdown-close",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#cats-trigger")
  app$wait_for_js("document.querySelector('#cats-dropdown.open') !== null")

  # Drive the input over Shiny's connection instead of clicking the button.
  # No outside pointer press occurs, so the modal lifecycle event owns close.
  app$set_inputs(show_test_modal = "click")
  app$wait_for_js("document.querySelector('.modal.in, .modal.show') !== null")
  # The modal can appear before the close animation finishes, so wait for
  # the panel to return to the wrapper instead of asserting immediately.
  app$wait_for_js("
    document.querySelector('#cats-dropdown').parentElement ===
      document.querySelector('#cats-wrap')
  ")
  expect_true(app$get_js("
    (function() {
      var wrap = document.querySelector('#cats-wrap');
      var dropdown = document.querySelector('#cats-dropdown');
      return !dropdown.classList.contains('open') &&
        !wrap.classList.contains('gt-layer-active') &&
        dropdown.parentElement === wrap;
    })()
  "))
})

test_that("browser: unbinding a tab widget releases its browser resources", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-tab-cleanup",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$wait_for_js("document.querySelector('#mobile_tabs-navbar')._gtTabsInit === true")

  expect_true(app$get_js("
    (function() {
      var wrap = document.querySelector('#mobile_tabs-wrap');
      var navbar = document.querySelector('#mobile_tabs-navbar');
      Shiny.unbindAll(wrap);
      return navbar._gtTabsInit === false &&
        navbar._gtClickHandler === null &&
        navbar._gtKeyHandler === null &&
        navbar._gtResizeObserver === null &&
        navbar._gtHalo === null &&
        navbar._gtTransfer === null;
    })()
  "))
})

test_that("browser: tabs keep focus, scroll, menu state, and dynamic tabs in sync", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-responsive-tabs",
    height = 1100,
    width = 700
  )
  on.exit(app$stop(), add = TRUE)
  app$wait_for_idle()

  expect_true(app$get_js("
    getComputedStyle(document.querySelector('#mobile_tabs-wrap'))
      .getPropertyValue('--gt-focus-ring').trim() === '#f97316'
  "))

  app$wait_for_js("
    document.querySelector('#mobile_tabs-tab-activity').getAttribute('aria-disabled') === 'true'
  ")
  expect_true(app$get_js("
    (function() {
      var activePane = document.querySelector('#mobile_tabs-pane-summary');
      var inactivePane = document.querySelector('#mobile_tabs-pane-activity');
      var inactiveButton = document.querySelector('#inactive_action');
      var first = document.querySelector('#mobile_tabs-tab-summary');
      first.focus();
      first.dispatchEvent(new KeyboardEvent('keydown', {key:'ArrowRight', bubbles:true}));
      var disabledIsFocused = document.activeElement.id === 'mobile_tabs-tab-activity';
      document.activeElement.dispatchEvent(
        new KeyboardEvent('keydown', {key:'Enter', bubbles:true})
      );
      var selectionStayedPut = first.classList.contains('active');
      inactiveButton.focus();
      return activePane.hasAttribute('inert') === false &&
        inactivePane.hasAttribute('inert') &&
        document.activeElement !== inactiveButton &&
        disabledIsFocused && selectionStayedPut;
    })()
  "))

  expect_true(app$get_js("
    (function() {
      var viewport = document.querySelector('#mobile_tabs-wrap .gt-tab-viewport');
      return viewport.scrollWidth > viewport.clientWidth;
    })()
  "))

  expect_true(app$get_js("
    (function() {
      var first = document.querySelector('#mobile_tabs-tab-summary');
      first.focus();
      first.dispatchEvent(new KeyboardEvent('keydown', {key:'End', bubbles:true}));
      return true;
    })()
  "))
  app$wait_for_js("
    document.querySelector('#mobile_tabs-tab-settings').classList.contains('active') &&
    document.activeElement.id === 'mobile_tabs-tab-settings'
  ")
  app$wait_for_js("
    Shiny.shinyapp.$inputValues['mobile_tabs-active_tab'] === 'settings'
  ")
  expect_equal(app$get_value(input = "mobile_tabs-active_tab"), "settings")
  expect_true(app$get_js("
    document.querySelectorAll('#mobile_tabs-navbar .gt-tab-link[tabindex=\"0\"]').length === 1
  "))

  expect_true(app$get_js("
    (function() {
      var pane = document.querySelector('#mobile_tabs-wrap .gt-tab-wrap');
      var start = new Event('touchstart', {bubbles:true});
      Object.defineProperty(start, 'touches', {value:[{clientX:220, clientY:80}]});
      pane.dispatchEvent(start);
      var end = new Event('touchend', {bubbles:true});
      Object.defineProperty(end, 'changedTouches', {value:[{clientX:290, clientY:82}]});
      pane.dispatchEvent(end);
      return true;
    })()
  "))
  app$wait_for_js("document.querySelector('#mobile_tabs-tab-quality').classList.contains('active')")
  app$wait_for_js("
    Shiny.shinyapp.$inputValues['mobile_tabs-active_tab'] === 'quality'
  ")
  expect_equal(app$get_value(input = "mobile_tabs-active_tab"), "quality")
  app$wait_for_js("
    (function() {
      var halo = document.querySelector('#mobile_tabs-wrap .gt-halo').getBoundingClientRect();
      var tab = document.querySelector('#mobile_tabs-tab-quality').getBoundingClientRect();
      return Math.abs(halo.left - tab.left) < 1 &&
        Math.abs(halo.top - tab.top) < 1 &&
        Math.abs(halo.width - tab.width) < 1 &&
        Math.abs(halo.height - tab.height) < 1;
    })()
  ")

  app$set_inputs(append_tab = "click")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "append_tab"), 1)
  app$wait_for_js("document.querySelector('.gt-tab-link[data-value=\"archive\"]') !== null")
  app$wait_for_js("
    Shiny.shinyapp.$inputValues['mobile_tabs-active_tab'] === 'archive'
  ")
  expect_equal(app$get_value(input = "mobile_tabs-active_tab"), "archive")
  expect_true(app$get_js("
    document.querySelector('#mobile_tabs-tab-archive').getAttribute('aria-controls') ===
      'mobile_tabs-pane-archive' &&
    document.querySelector('#mobile_tabs-pane-archive').getAttribute('aria-labelledby') ===
      'mobile_tabs-tab-archive'
  "))

  app$wait_for_js("document.querySelectorAll('#menu_tabs-menu option').length === 2")
  expect_true(app$get_js("
    (function() {
      var menu = document.querySelector('#menu_tabs-menu');
      var option = menu.querySelector('option');
      var menuStyle = getComputedStyle(menu);
      var optionStyle = getComputedStyle(option);
      return menuStyle.colorScheme === 'dark' &&
        optionStyle.backgroundColor === 'rgb(15, 23, 42)' &&
        optionStyle.color === 'rgb(255, 255, 255)';
    })()
  "))
  expect_true(app$get_js("
    (function() {
      var menu = document.querySelector('#menu_tabs-menu');
      menu.value = 'complete';
      menu.dispatchEvent(new Event('change', {bubbles:true}));
      return true;
    })()
  "))
  app$wait_for_js("document.querySelector('#menu_tabs-tab-complete').classList.contains('active')")
  app$wait_for_js("
    Shiny.shinyapp.$inputValues['menu_tabs-active_tab'] === 'complete'
  ")
  expect_equal(app$get_value(input = "menu_tabs-active_tab"), "complete")

  expect_true(app$get_js("
    (function() {
      var quoted = document.getElementById('special_tabs-tab-team\"review');
      quoted.click();
      return true;
    })()
  "))
  app$wait_for_js("
    document.getElementById('special_tabs-tab-team\"review').classList.contains('active')
  ")
  app$wait_for_js("
    Shiny.shinyapp.$inputValues['special_tabs-active_tab'] === 'team\"review'
  ")
  expect_equal(app$get_value(input = "special_tabs-active_tab"), 'team"review')
})

test_that("browser: rapid tab changes settle on one honest state", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-rapid-tabs",
    height = 1000,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)
  app$wait_for_idle()

  expect_true(app$get_js("
    (function() {
      var originalMatchMedia = window.matchMedia.bind(window);
      window.matchMedia = function(query) {
        if (query === '(prefers-reduced-motion: reduce)') {
          return {matches:false,media:query,addListener:function(){},removeListener:function(){}};
        }
        return originalMatchMedia(query);
      };
      document.querySelector('#race_return-tab-b').click();
      setTimeout(function() {
        document.querySelector('#race_return-tab-a').click();
      }, 50);
      setTimeout(function() { window.__raceReturnDone = true; }, 700);
      return true;
    })()
  "))
  app$wait_for_js("window.__raceReturnDone === true")

  expect_true(app$get_js("
    (function() {
      var widget = document.querySelector('#race_return-wrap');
      var tab = document.querySelector('#race_return-tab-a');
      var pane = document.querySelector('#race_return-pane-a');
      var otherPane = document.querySelector('#race_return-pane-b');
      var halo = widget.querySelector('.gt-halo').getBoundingClientRect();
      var rect = tab.getBoundingClientRect();
      return Shiny.shinyapp.$inputValues['race_return-active_tab'] === 'a' &&
        widget.querySelectorAll('.gt-tab-link.active').length === 1 &&
        tab.classList.contains('active') && !pane.hasAttribute('inert') &&
        otherPane.hasAttribute('inert') &&
        Math.abs(halo.left - rect.left) < 1 && Math.abs(halo.top - rect.top) < 1 &&
        Math.abs(halo.width - rect.width) < 1 && Math.abs(halo.height - rect.height) < 1 &&
        widget.querySelector('.gt-transfer').getAnimations().length === 0 &&
        widget.querySelector('.gt-halo').style.opacity === '0.92';
    })()
  "))
  expect_equal(app$get_value(output = "race_return_events"), "")

  expect_true(app$get_js("
    (function() {
      document.querySelector('#race_forward-tab-b').click();
      setTimeout(function() {
        document.querySelector('#race_forward-tab-c').click();
      }, 50);
      setTimeout(function() { window.__raceForwardDone = true; }, 700);
      return true;
    })()
  "))
  app$wait_for_js("window.__raceForwardDone === true")

  expect_true(app$get_js("
    (function() {
      var widget = document.querySelector('#race_forward-wrap');
      var tab = document.querySelector('#race_forward-tab-c');
      var pane = document.querySelector('#race_forward-pane-c');
      var halo = widget.querySelector('.gt-halo').getBoundingClientRect();
      var rect = tab.getBoundingClientRect();
      return Shiny.shinyapp.$inputValues['race_forward-active_tab'] === 'c' &&
        widget.querySelectorAll('.gt-tab-link.active').length === 1 &&
        tab.classList.contains('active') && !pane.hasAttribute('inert') &&
        document.querySelector('#race_forward-pane-a').hasAttribute('inert') &&
        document.querySelector('#race_forward-pane-b').hasAttribute('inert') &&
        Math.abs(halo.left - rect.left) < 1 && Math.abs(halo.top - rect.top) < 1 &&
        Math.abs(halo.width - rect.width) < 1 && Math.abs(halo.height - rect.height) < 1;
    })()
  "))
  expect_equal(app$get_value(output = "race_forward_events"), "c")
})

test_that("browser: select options support arrow keys and Enter", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-select-keyboard",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)
  app$wait_for_idle()

  app$click(selector = "#fruit-trigger")
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') !== null")
  app$wait_for_js("document.activeElement.closest('.gt-gs-search') !== null")
  expect_true(app$get_js("
    (function() {
      var dropdown = document.querySelector('#fruit-dropdown');
      var search = dropdown.querySelector('.gt-gs-search');
      return dropdown.parentElement === document.body &&
        getComputedStyle(dropdown).getPropertyValue('--ms-focus-ring').trim() === '#a21caf' &&
        getComputedStyle(search).outlineColor === 'rgb(162, 28, 175)';
    })()
  "))
  expect_true(app$get_js("
    (function() {
      var search = document.querySelector('#fruit-dropdown input[type=text]');
      search.dispatchEvent(new KeyboardEvent('keydown', {key:'ArrowDown', bubbles:true}));
      search.dispatchEvent(new KeyboardEvent('keydown', {key:'Enter', bubbles:true}));
      return true;
    })()
  "))
  app$wait_for_idle()
  expect_equal(app$get_value(input = "fruit"), "banana")

  app$click(selector = "#cats-trigger")
  app$wait_for_js("document.querySelector('#cats-dropdown.open') !== null")
  expect_true(app$get_js("
    (function() {
      var search = document.querySelector('#cats-dropdown input[type=text]');
      search.dispatchEvent(new KeyboardEvent('keydown', {key:'ArrowDown', bubbles:true}));
      search.dispatchEvent(new KeyboardEvent('keydown', {key:'Enter', bubbles:true}));
      return true;
    })()
  "))
  app$wait_for_idle()
  expect_equal(app$get_value(input = "cats"), c("apple", "banana"))
})

test_that("browser: vertical halo respects motion settings and stays aligned", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-vertical-halo-motion",
    height = 900,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)
  app$wait_for_idle()

  reduced_motion <- isTRUE(app$get_js(
    "window.matchMedia('(prefers-reduced-motion: reduce)').matches"
  ))
  expect_true(app$get_js("
    (function() {
      var viewport = document.querySelector('#vertical_tabs-wrap .gt-tab-viewport').getBoundingClientRect();
      var navbar = document.querySelector('#vertical_tabs-navbar').getBoundingClientRect();
      var first = document.querySelector('#vertical_tabs-tab-first');
      return Math.abs(viewport.right - navbar.right) < 1 &&
        getComputedStyle(first).justifyContent === 'flex-start';
    })()
  "))

  expect_true(app$get_js("
    (function() {
      var halo = document.querySelector('#vertical_tabs-wrap .gt-halo');
      window.__gtVerticalHaloMoved = false;
      halo.addEventListener('transitionrun', function(event) {
        if (event.propertyName === 'top') window.__gtVerticalHaloMoved = true;
      });
      document.querySelector('#vertical_tabs-tab-second').click();
      return true;
    })()
  "))
  if (!reduced_motion) {
    app$wait_for_js("window.__gtVerticalHaloMoved === true")
  }
  app$wait_for_js("
    document.querySelector('#vertical_tabs-tab-second').classList.contains('active')
  ")
  app$wait_for_js("
    (function() {
      var halo = document.querySelector('#vertical_tabs-wrap .gt-halo').getBoundingClientRect();
      var tab = document.querySelector('#vertical_tabs-tab-second').getBoundingClientRect();
      return Math.abs(halo.left - tab.left) < 1 &&
        Math.abs(halo.top - tab.top) < 1 &&
        Math.abs(halo.width - tab.width) < 1 &&
        Math.abs(halo.height - tab.height) < 1;
    })()
  ")
  expect_equal(app$get_value(input = "vertical_tabs-active_tab"), "second")
})

test_that("browser: horizontal tab alignment moves the whole tab group", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-horizontal-tab-alignment",
    height = 900,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)
  app$wait_for_idle()

  expect_true(app$get_js("
    (function() {
      var viewport = document.querySelector('#right_tabs-wrap .gt-tab-viewport').getBoundingClientRect();
      var tabs = document.querySelectorAll('#right_tabs-navbar .gt-tab-link');
      var last = tabs[tabs.length - 1].getBoundingClientRect();
      return Math.abs(viewport.right - last.right) < 1;
    })()
  "))
  expect_true(app$get_js("
    (function() {
      var viewport = document.querySelector('#center_tabs-wrap .gt-tab-viewport').getBoundingClientRect();
      var tabs = document.querySelectorAll('#center_tabs-navbar .gt-tab-link');
      var first = tabs[0].getBoundingClientRect();
      var last = tabs[tabs.length - 1].getBoundingClientRect();
      var groupCenter = (first.left + last.right) / 2;
      var viewportCenter = (viewport.left + viewport.right) / 2;
      return Math.abs(groupCenter - viewportCenter) < 1;
    })()
  "))
  expect_true(app$get_js("
    (function() {
      var first = document.querySelector('#right_tabs-tab-one');
      var second = document.querySelector('#right_tabs-tab-two');
      return getComputedStyle(first).justifyContent === 'flex-start' &&
        Math.abs(first.getBoundingClientRect().width - second.getBoundingClientRect().width) < 1;
    })()
  "))
})

test_that("browser: unrelated Shiny output updates keep select dropdowns open", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-select-unrelated-update",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#fruit-trigger")
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') !== null")

  # Fire a shiny:value on an output that has nothing to do with the dropdown.
  app$click(selector = "#ping_output")
  app$wait_for_js("document.querySelector('#ping_text').textContent.indexOf('ping 1') !== -1")
  app$wait_for_idle()

  expect_true(app$get_js(
    "document.querySelector('#fruit-dropdown.open') !== null"
  ))
})

test_that("browser: window resize keeps select dropdowns open and repositions them", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-select-resize",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#fruit-trigger")
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') !== null")

  app$get_js("window.dispatchEvent(new Event('resize')); 'dispatched'")
  app$wait_for_idle()

  expect_true(app$get_js(
    "document.querySelector('#fruit-dropdown.open') !== null"
  ))
  # The teleported panel still tracks the trigger after the resize, hanging
  # flush off the field with the tongue's 1px border overlap.
  expect_true(app$get_js("
    (function() {
      var trigger = document.querySelector('#fruit-trigger');
      var dropdown = document.querySelector('#fruit-dropdown');
      var tr = trigger.getBoundingClientRect();
      var dr = dropdown.getBoundingClientRect();
      var expectedLeft = Math.max(
        8,
        Math.min(tr.left, window.innerWidth - dr.width - 8)
      );
      return Math.abs(dr.left - expectedLeft) <= 2 &&
        Math.abs(dr.top - (tr.bottom - 1)) <= 2;
    })()
  "))

  expect_true(app$get_js("
    document.documentElement.setAttribute('dir', 'rtl');
    window.dispatchEvent(new Event('resize'));
    true;
  "))
  app$wait_for_js("
    (function() {
      var trigger = document.querySelector('#fruit-trigger');
      var dropdown = document.querySelector('#fruit-dropdown');
      var tr = trigger.getBoundingClientRect();
      var dr = dropdown.getBoundingClientRect();
      var expectedLeft = Math.max(
        8,
        Math.min(tr.right - dr.width, window.innerWidth - dr.width - 8)
      );
      return Math.abs(dr.left - expectedLeft) <= 2;
    })()
  ")
})

test_that("browser: a full-screen overlay dismisses open select dropdowns", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-select-overlay",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#fruit-trigger")
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') !== null")

  # A small floating panel is not a screen overlay: the dropdown stays open.
  app$get_js("
    (function() {
      var d = document.createElement('div');
      d.id = 'test-small-veil';
      d.style.cssText = 'position:fixed;top:10px;left:10px;width:200px;height:100px;z-index:99999;background:red;';
      document.body.appendChild(d);
      return 'added';
    })()
  ")
  Sys.sleep(0.5)
  expect_true(app$get_js("document.querySelector('#fruit-dropdown.open') !== null"))
  app$get_js("document.querySelector('#test-small-veil').remove(); 'removed'")

  # A full-screen loading veil above the dropdown dismisses it.
  app$get_js("
    (function() {
      var d = document.createElement('div');
      d.id = 'test-screen-veil';
      d.style.cssText = 'position:fixed;inset:0;z-index:99999;background:rgba(0,0,0,0.5);';
      document.body.appendChild(d);
      return 'added';
    })()
  ")
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') === null")
  expect_true(app$get_js("document.querySelector('#fruit-dropdown.open') === null"))
  app$get_js("document.querySelector('#test-screen-veil').remove(); 'removed'")
})

test_that("browser: an overlay nested inside an app wrapper dismisses open select dropdowns", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-select-overlay-nested",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#fruit-trigger")
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') !== null")

  # Overlay nested inside a newly inserted application wrapper, not a direct
  # body child: the subtree observer must still find it.
  app$get_js("
    (function() {
      var wrap = document.createElement('div');
      wrap.id = 'test-app-wrapper';
      var veil = document.createElement('div');
      veil.id = 'test-nested-veil';
      veil.style.cssText = 'position:fixed;inset:0;z-index:99999;background:rgba(0,0,0,0.5);';
      wrap.appendChild(veil);
      document.querySelector('.container-fluid').appendChild(wrap);
      return 'added';
    })()
  ")
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') === null")
  expect_true(app$get_js("document.querySelector('#fruit-dropdown.open') === null"))
  app$get_js("document.querySelector('#test-app-wrapper').remove(); 'removed'")
})

test_that("browser: a hidden overlay made visible by a class toggle dismisses open select dropdowns", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-select-overlay-toggle",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  # Pre-existing hidden overlay: present in the DOM but display:none.
  app$get_js("
    (function() {
      var d = document.createElement('div');
      d.id = 'test-toggle-veil';
      d.style.cssText = 'position:fixed;inset:0;z-index:99999;background:rgba(0,0,0,0.5);display:none;';
      document.body.appendChild(d);
      return 'added';
    })()
  ")
  app$click(selector = "#fruit-trigger")
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') !== null")

  # Reveal it with a style change: no new node is inserted.
  app$get_js("document.querySelector('#test-toggle-veil').style.display = 'block'; 'shown'")
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') === null")
  expect_true(app$get_js("document.querySelector('#fruit-dropdown.open') === null"))
  app$get_js("document.querySelector('#test-toggle-veil').remove(); 'removed'")
})

test_that("browser: dropdown opens flush like a tongue from the field", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-dropdown-tongue",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#fruit-trigger")
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') !== null")

  # Panel attaches flush: 1px border overlap, no gap.
  expect_true(app$get_js("
    (function() {
      var trigger = document.querySelector('#fruit-trigger');
      var panel = document.querySelector('#fruit-dropdown');
      var tr = trigger.getBoundingClientRect();
      var pr = panel.getBoundingClientRect();
      return Math.abs(pr.top - (tr.bottom - 1)) <= 2;
    })()
  "))

  # Adjoining corners square off so the two read as one surface.
  expect_true(app$get_js("
    (function() {
      var panel = document.querySelector('#fruit-dropdown');
      var cs = getComputedStyle(panel);
      return cs.borderTopLeftRadius === '0px' && cs.borderTopRightRadius === '0px';
    })()
  "))
  expect_true(app$get_js("
    (function() {
      var trigger = document.querySelector('#fruit-trigger');
      var cs = getComputedStyle(trigger);
      return cs.borderBottomLeftRadius === '0px' && cs.borderBottomRightRadius === '0px';
    })()
  "))

  # The unfurl is scaleY, not the old translateY/scale pop: once closed and
  # settled, the transform is exactly scaleY(0). The old closed state was
  # translateY(-8px) scale(0.96), a different matrix, so this assertion fails
  # on the old animation. The open-state matrix cannot distinguish them
  # (both settle at scale(1)), which is why the closed state is checked.
  # The trigger ignores close clicks within 500 ms of opening, so wait out
  # that guard first, or the close click is swallowed and the panel stays open.
  Sys.sleep(0.6)
  # Closing must animate, not teleport: the panel stays under <body>,
  # attached to the trigger, while it retracts, and only returns to the
  # wrapper once the retract finishes. Moving it back in the same turn as
  # removing `.open` collapses it instantly, so a final-matrix check alone
  # passes even when no transition occurs.
  # The observable is the dwell, not a mid-scale sample: sampling the
  # transform from JS cannot observe a compositor animation while the main
  # thread is blocked (Shiny processing the close blocks it on loaded
  # runners, so fixed-time and interval samples both miss the window). But
  # the dwell is measured on the browser clock: if the panel stays
  # teleported for ~180ms (transitionend) or ~250ms (fallback) instead of
  # teleporting instantly, the retract necessarily ran, because a
  # transitioned property on an element that stays in place cannot jump.
  # The duration is forced inline first: under prefers-reduced-motion the
  # stylesheet collapses transitions to 0.01ms, so without this the dwell
  # would be ~0ms even though the delayed-teleport logic is correct. The
  # inline !important beats the stylesheet !important, making the dwell
  # assertion valid on every runner.
  app$get_js("
    (function() {
      var trigger = document.querySelector('#fruit-trigger');
      var panel = document.querySelector('#fruit-dropdown');
      var closeStarted = Date.now();
      window.__gtCloseReturned = false;
      window.__gtCloseDwell = null;
      panel.style.setProperty('transition-duration', '180ms', 'important');
      trigger.click();
      var iv = setInterval(function() {
        if (document.querySelector('#fruit-dropdown').parentNode !== document.body) {
          window.__gtCloseDwell = Date.now() - closeStarted;
          window.__gtCloseReturned = true;
          clearInterval(iv);
        }
      }, 20);
      return 'sampling';
    })()
  ")
  app$wait_for_js("window.__gtCloseReturned === true")
  close_state <- app$get_js("
    (function() {
      var panel = document.querySelector('#fruit-dropdown');
      return {
        dwell: window.__gtCloseDwell,
        returnedToWrap: panel.parentNode !== document.body,
        closed: !panel.classList.contains('open')
      };
    })()
  ")
  # Not instant (the bug teleports in the same turn, dwell ~0ms) and not
  # stuck (fallback is 250ms; the bound is generous for loaded runners).
  expect_true(!is.null(close_state$dwell) && close_state$dwell >= 100,
              info = paste("dwell ms:", close_state$dwell))
  expect_true(close_state$dwell < 4000)
  expect_true(close_state$returnedToWrap)
  expect_true(close_state$closed)
  app$wait_for_js("
    getComputedStyle(document.querySelector('#fruit-dropdown')).transform ===
      'matrix(1, 0, 0, 0, 0, 0)'
  ")
  expect_true(app$get_js("
    getComputedStyle(document.querySelector('#fruit-dropdown')).transform ===
      'matrix(1, 0, 0, 0, 0, 0)'
  "))
})

test_that("browser: dropdown flipped above the field retracts into the trigger", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-dropdown-flip-above",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  # Pin the trigger to the viewport bottom so no room remains below it; the
  # panel must flip above the field. Scrolling cannot do this for a
  # top-of-page trigger: the target scroll goes negative and clamps to 0,
  # leaving the trigger at the top and the panel opening below. A JS click
  # is used (not app$click) so the driver does not scroll the trigger back
  # into view first. Width and left are preserved so geometry is unchanged.
  app$get_js("
    (function() {
      var trigger = document.querySelector('#fruit-trigger');
      var r = trigger.getBoundingClientRect();
      trigger.style.position = 'fixed';
      trigger.style.left = r.left + 'px';
      trigger.style.bottom = '0px';
      trigger.style.width = r.width + 'px';
      trigger.style.zIndex = '1';
      return 'pinned';
    })()
  ")
  app$get_js("document.querySelector('#fruit-trigger').click(); 'clicked'")
  app$wait_for_js("
    (function() {
      var p = document.querySelector('#fruit-dropdown');
      return p !== null && p.classList.contains('open') &&
        p.classList.contains('gt-flip-above');
    })()
  ")

  # Panel sits above, flush: 1px border overlap with the trigger top.
  expect_true(app$get_js("
    (function() {
      var trigger = document.querySelector('#fruit-trigger');
      var panel = document.querySelector('#fruit-dropdown');
      var tr = trigger.getBoundingClientRect();
      var dr = panel.getBoundingClientRect();
      return Math.abs(dr.bottom - (tr.top + 1)) <= 2;
    })()
  "))

  # Flipped corners: bottom squared, top restored.
  expect_true(app$get_js("
    (function() {
      var cs = getComputedStyle(document.querySelector('#fruit-dropdown'));
      return cs.borderBottomLeftRadius === '0px' &&
        cs.borderBottomRightRadius === '0px' &&
        cs.borderTopLeftRadius === '14px' &&
        cs.borderTopRightRadius === '14px';
    })()
  "))

  # Flipped origin is bottom center, so the panel retracts into the trigger.
  # offsetWidth/offsetHeight are used because transforms do not affect them.
  expect_true(app$get_js("
    (function() {
      var panel = document.querySelector('#fruit-dropdown');
      var parts = getComputedStyle(panel).transformOrigin.split(' ');
      var ox = parseFloat(parts[0]);
      var oy = parseFloat(parts[1]);
      return Math.abs(ox - panel.offsetWidth / 2) <= 2 &&
        Math.abs(oy - panel.offsetHeight) <= 2;
    })()
  "))

  # Flipped dark shadow points upward.
  expect_true(app$get_js("
    getComputedStyle(document.querySelector('#fruit-dropdown')).boxShadow
      .indexOf('-22px') !== -1
  "))

  # Width is untouched by the flip: still the field's width.
  expect_true(app$get_js("
    Math.abs(
      document.querySelector('#fruit-dropdown').offsetWidth -
      document.querySelector('#fruit-trigger').offsetWidth
    ) <= 2
  "))

  # Closing keeps the bottom origin: clicking to close and reading the origin
  # in the same JS turn must still show bottom center. With the origin scoped
  # to `.open`, it would revert to top center the moment `.open` is removed.
  # The assertion also requires `.open` to be gone, so a close click swallowed
  # by the 500 ms open guard fails honestly instead of passing on the still
  # open panel's origin. The guard is waited out first.
  Sys.sleep(0.6)
  expect_true(app$get_js("
    (function() {
      var trigger = document.querySelector('#fruit-trigger');
      var panel = document.querySelector('#fruit-dropdown');
      trigger.click();
      var parts = getComputedStyle(panel).transformOrigin.split(' ');
      var ox = parseFloat(parts[0]);
      var oy = parseFloat(parts[1]);
      return !panel.classList.contains('open') &&
        Math.abs(ox - panel.offsetWidth / 2) <= 2 &&
        Math.abs(oy - panel.offsetHeight) <= 2;
    })()
  "))
})

test_that("browser: flipped light dropdown keeps its upward light shadow", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-dropdown-flip-light",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  # Pin the trigger to the viewport bottom so the panel must flip above the
  # field (see the dark flip test: scrolling cannot do this reliably).
  app$get_js("
    (function() {
      var trigger = document.querySelector('#fruit_light-trigger');
      var r = trigger.getBoundingClientRect();
      trigger.style.position = 'fixed';
      trigger.style.left = r.left + 'px';
      trigger.style.bottom = '0px';
      trigger.style.width = r.width + 'px';
      trigger.style.zIndex = '1';
      return 'pinned';
    })()
  ")
  app$get_js("document.querySelector('#fruit_light-trigger').click(); 'clicked'")
  app$wait_for_js("
    (function() {
      var p = document.querySelector('#fruit_light-dropdown');
      return p !== null && p.classList.contains('open') &&
        p.classList.contains('gt-flip-above');
    })()
  ")

  # The teleported panel carries the light theme itself.
  expect_true(app$get_js("
    document.querySelector('#fruit_light-dropdown').classList.contains('theme-light')
  "))

  # Flipped light shadow points upward with light values, not the dark
  # upward shadow. This fails when the shadow selector expects the panel to
  # still sit beneath the wrap, which teleporting breaks.
  expect_true(app$get_js("
    (function() {
      var shadow = getComputedStyle(
        document.querySelector('#fruit_light-dropdown')
      ).boxShadow;
      return shadow.indexOf('-12px') !== -1 &&
        shadow.indexOf('-22px') === -1;
    })()
  "))
})

test_that("browser: keyboard navigation reaches chrome rows and activates them", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-chrome-keyboard",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  # Keys are dispatched straight to the element whose handler must receive
  # them, and every move is awaited before the next key is sent. The
  # previous version focused the trigger in one JS call and dispatched to
  # document.activeElement in the next, which never opened the dropdown on
  # CI (PR #8 check run 40989737973), and it fired its arrows in a tight
  # loop while the trigger handler defers navigation by 110 ms, so the
  # landing positions were timing-dependent. DOM focus never enters the
  # option list (combobox pattern: the trigger keeps focus and
  # aria-activedescendant tracks the active option), so option moves are
  # awaited on the active option's data-value and chrome moves on
  # document.activeElement, which enterChrome() really focuses.
  key_to <- function(selector, key) {
    app$get_js(sprintf(
      "(function() {
        document.querySelector('%s').dispatchEvent(
          new KeyboardEvent('keydown', {key:'%s', bubbles:true}));
        return true;
      })()",
      selector, key
    ))
  }
  press <- function(key) {
    app$get_js(sprintf(
      "(function() {
        document.activeElement.dispatchEvent(
          new KeyboardEvent('keydown', {key:'%s', bubbles:true}));
        return true;
      })()",
      key
    ))
  }
  active_option_is <- function(dropdown, value) {
    app$wait_for_js(sprintf(
      "document.querySelector('%s .gt-option-active') !== null &&
        document.querySelector('%s .gt-option-active').getAttribute('data-value') === '%s'",
      dropdown, dropdown, value
    ))
  }

  # Multi-select: 4 options, then 3 style buttons, select-all, clear.
  # open()'s 100 ms timer sets the current option to the selection ("one")
  # before the trigger handler's 110 ms deferred navigation runs, so the
  # first arrow from the trigger lands on the second option.
  key_to("#short_multi-trigger", "Enter")
  app$wait_for_js("document.querySelector('#short_multi-dropdown.open') !== null")
  key_to("#short_multi-trigger", "ArrowDown")
  active_option_is("#short_multi-dropdown", "long_words")
  key_to("#short_multi-trigger", "ArrowDown")
  active_option_is("#short_multi-dropdown", "long_token")
  key_to("#short_multi-trigger", "ArrowDown")
  active_option_is("#short_multi-dropdown", "pathological")
  key_to("#short_multi-trigger", "ArrowDown")
  app$wait_for_js("document.activeElement.getAttribute('data-style') === 'check-only'")
  press("ArrowDown")
  app$wait_for_js("document.activeElement.getAttribute('data-style') === 'checkbox'")
  press("ArrowDown")
  app$wait_for_js("document.activeElement.getAttribute('data-style') === 'filled'")
  press("ArrowDown")
  app$wait_for_js("document.activeElement.id === 'short_multi-all'")
  # Activation clicks the explicit target, not activeElement: focus is
  # already proven by the await above, and an explicit target keeps a
  # focus drift from silently activating the wrong control. The DOM
  # assertion comes first: it distinguishes a click-handler failure (DOM
  # unchanged) from a Shiny-sync failure (DOM changed, value stale).
  # NOTE: shinytest2 wraps get_js scripts in a bare block, so a bare
  # `return` outside a function is a syntax error that get_js swallows
  # as NULL — the previous version's clicks never ran, which is why
  # both value assertions failed with unchanged values on CI run
  # 40996074673. Every get_js script here is an IIFE for that reason.
  app$get_js("
    (function() {
      document.querySelector('#short_multi-all').click();
      return true;
    })()
  ")
  app$wait_for_js("
    document.querySelector('#short_multi-all').getAttribute('aria-checked') === 'true'
  ")
  app$wait_for_idle()
  expect_setequal(
    app$get_value(input = "short_multi"),
    c("one", "long_words", "long_token", "pathological")
  )
  press("ArrowDown")
  app$wait_for_js("document.activeElement.id === 'short_multi-clear'")
  press("Escape")
  app$wait_for_js("
    document.querySelector('#short_multi-dropdown.open') === null &&
    document.activeElement.id === 'short_multi-trigger'
  ")

  # Single-select: arrows past the last option land on Clear, and clearing
  # empties the value.
  key_to("#fruit-trigger", "Enter")
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') !== null")
  key_to("#fruit-trigger", "ArrowDown")
  active_option_is("#fruit-dropdown", "banana")
  key_to("#fruit-trigger", "ArrowDown")
  active_option_is("#fruit-dropdown", "cherry")
  key_to("#fruit-trigger", "ArrowDown")
  app$wait_for_js("document.activeElement.id === 'fruit-clear'")
  app$get_js("
    (function() {
      document.querySelector('#fruit-clear').click();
      return true;
    })()
  ")
  app$wait_for_js("
    document.querySelector('#fruit-label').textContent === 'Select an option'
  ")
  app$wait_for_idle()
  expect_null(app$get_value(input = "fruit"))
})

test_that("browser: real Enter and Space activate chrome controls", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-chrome-real-keys",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  # Navigation here stays synthetic: the keyboard test above already proves
  # arrow navigation step by step. Only activation goes through Chrome's
  # real input dispatch, because a programmatic .click() cannot prove that
  # a user pressing Enter or Space reaches the same handler. chromote
  # grafts the live browser's CDP protocol onto the session object, so
  # session$Input$dispatchKeyEvent is the real Input.dispatchKeyEvent
  # method. A press is keyDown followed by keyUp, matching a physical key:
  # buttons activate on Enter keyDown and Space keyUp, so sending both
  # activates each control exactly once.
  session <- app$get_chromote_session()
  # Diagnostic probe: record every keydown reaching the page, capture
  # phase so nothing can swallow it first. A trusted event here can
  # only come from the CDP dispatch (synthetic test events are
  # untrusted), so the assertions below distinguish "the dispatched key
  # never reached the page" from "it arrived but did not activate".
  app$get_js("
    (function() {
      window._gtKeyProbe = [];
      document.addEventListener('keydown', function(e) {
        window._gtKeyProbe.push({
          key: e.key, code: e.code,
          target: (e.target && e.target.id) || '',
          trusted: e.isTrusted
        });
      }, true);
      return true;
    })()
  ")
  # Both virtual key codes: working chromote examples send windows AND
  # native codes, and Chrome's key construction uses the native code on
  # some platforms. Omitting it was the prime suspect when real Enter
  # never activated select-all on CI.
  real_key <- function(key, code, vkey, text = NULL) {
    for (type in c("keyDown", "keyUp")) {
      args <- list(
        type = type, key = key, code = code,
        windowsVirtualKeyCode = vkey,
        nativeVirtualKeyCode = vkey
      )
      if (!is.null(text)) args$text <- text
      do.call(session$Input$dispatchKeyEvent, args)
      # A real key is held briefly; back-to-back dispatches also rule
      # out nothing, but a 100 ms hold matches physical input and costs
      # nothing.
      if (type == "keyDown") Sys.sleep(0.1)
    }
  }
  key_to <- function(selector, key) {
    app$get_js(sprintf(
      "(function() {
        document.querySelector('%s').dispatchEvent(
          new KeyboardEvent('keydown', {key:'%s', bubbles:true}));
        return true;
      })()",
      selector, key
    ))
  }
  press <- function(key) {
    app$get_js(sprintf(
      "(function() {
        document.activeElement.dispatchEvent(
          new KeyboardEvent('keydown', {key:'%s', bubbles:true}));
        return true;
      })()",
      key
    ))
  }
  active_option_is <- function(dropdown, value) {
    app$wait_for_js(sprintf(
      "document.querySelector('%s .gt-option-active') !== null &&
        document.querySelector('%s .gt-option-active').getAttribute('data-value') === '%s'",
      dropdown, dropdown, value
    ))
  }

  # Multi-select: reach select-all, activate it with real Enter, then
  # with real Space. Focus must stay on the button across activation.
  key_to("#short_multi-trigger", "Enter")
  app$wait_for_js("document.querySelector('#short_multi-dropdown.open') !== null")
  key_to("#short_multi-trigger", "ArrowDown")
  active_option_is("#short_multi-dropdown", "long_words")
  key_to("#short_multi-trigger", "ArrowDown")
  active_option_is("#short_multi-dropdown", "long_token")
  key_to("#short_multi-trigger", "ArrowDown")
  active_option_is("#short_multi-dropdown", "pathological")
  key_to("#short_multi-trigger", "ArrowDown")
  app$wait_for_js("document.activeElement.getAttribute('data-style') === 'check-only'")
  press("ArrowDown")
  app$wait_for_js("document.activeElement.getAttribute('data-style') === 'checkbox'")
  press("ArrowDown")
  app$wait_for_js("document.activeElement.getAttribute('data-style') === 'filled'")
  press("ArrowDown")
  app$wait_for_js("document.activeElement.id === 'short_multi-all'")
  real_key("Enter", "Enter", 13, text = "\r")
  # Focus first: if this wait fails the key went to the wrong element;
  # if the next wait fails, focus held but activation did not happen.
  app$wait_for_js("document.activeElement.id === 'short_multi-all'")
  # The dispatched Enter must have reached the page as a trusted event
  # on the button; if this fails, the dispatch itself is the problem.
  expect_true(app$get_js("
    (function() {
      return window._gtKeyProbe.some(function(ev) {
        return ev.key === 'Enter' && ev.target === 'short_multi-all' && ev.trusted;
      });
    })()
  "))
  app$wait_for_js(
    "document.querySelector('#short_multi-all').getAttribute('aria-checked') === 'true'"
  )
  app$wait_for_idle()
  expect_setequal(
    app$get_value(input = "short_multi"),
    c("one", "long_words", "long_token", "pathological")
  )
  real_key(" ", "Space", 32, text = " ")
  app$wait_for_js("document.activeElement.id === 'short_multi-all'")
  expect_true(app$get_js("
    (function() {
      return window._gtKeyProbe.some(function(ev) {
        return ev.key === ' ' && ev.target === 'short_multi-all' && ev.trusted;
      });
    })()
  "))
  app$wait_for_js(
    "document.querySelector('#short_multi-all').getAttribute('aria-checked') === 'false'"
  )
  app$wait_for_idle()
  expect_length(app$get_value(input = "short_multi"), 0)

  # Real Escape closes the dropdown and returns focus to the trigger.
  real_key("Escape", "Escape", 27)
  app$wait_for_js(
    "document.querySelector('#short_multi-dropdown.open') === null &&
    document.activeElement.id === 'short_multi-trigger'"
  )

  # Start the single-select checks in a fresh page. On macOS, switching
  # controls immediately after the real Escape can race the old panel's
  # closing animation and leave the next trigger click ineffective.
  app$stop()
  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-chrome-real-keys-single",
    height = 800,
    width = 1000
  )
  app$wait_for_idle()
  session <- app$get_chromote_session()

  # Single-select: real Enter clears, then real Space clears after
  # re-selecting, each time reaching the placeholder and NULL.
  app$click(selector = "#fruit-trigger")
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') !== null")
  key_to("#fruit-trigger", "ArrowDown")
  active_option_is("#fruit-dropdown", "banana")
  key_to("#fruit-trigger", "ArrowDown")
  active_option_is("#fruit-dropdown", "cherry")
  key_to("#fruit-trigger", "ArrowDown")
  app$wait_for_js("document.activeElement.id === 'fruit-clear'")
  real_key("Enter", "Enter", 13, text = "\r")
  app$wait_for_js(
    "document.querySelector('#fruit-label').textContent === 'Select an option'"
  )
  app$wait_for_idle()
  expect_null(app$get_value(input = "fruit"))

  # Clearing keeps the panel open; clicking its trigger here would close it.
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') !== null")
  app$click(selector = "#fruit-dropdown .gt-gs-option[data-value='apple']")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "fruit"), "apple")
  app$click(selector = "#fruit-trigger")
  app$wait_for_js("document.querySelector('#fruit-dropdown.open') !== null")
  key_to("#fruit-trigger", "ArrowDown")
  active_option_is("#fruit-dropdown", "banana")
  key_to("#fruit-trigger", "ArrowDown")
  active_option_is("#fruit-dropdown", "cherry")
  key_to("#fruit-trigger", "ArrowDown")
  app$wait_for_js("document.activeElement.id === 'fruit-clear'")
  real_key(" ", "Space", 32, text = " ")
  app$wait_for_js(
    "document.querySelector('#fruit-label').textContent === 'Select an option'"
  )
  app$wait_for_idle()
  expect_null(app$get_value(input = "fruit"))
})

test_that("browser: select-all indicator agrees with the select-all click", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-select-all-scope",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#scope_check-trigger")
  app$wait_for_js("document.querySelector('#scope_check-dropdown.open') !== null")

  # Four enabled options selected, one disabled: the indicator must read
  # checked (the toggle set is complete), not indeterminate.
  expect_true(app$get_js("
    (function() {
      var all = document.querySelector('#scope_check-all');
      return all.classList.contains('checked') &&
        all.getAttribute('aria-checked') === 'true';
    })()
  "))
  # And the click must agree with it: everything enabled clears.
  app$click(selector = "#scope_check-all")
  app$wait_for_idle()
  expect_length(app$get_value(input = "scope_check"), 0)

  # Search-filtered scope: only "a" visible and unselected, so the
  # indicator reads unchecked and the click selects just "a".
  app$get_js("
    (function() {
      var search = document.querySelector('#scope_check-dropdown input[type=text]');
      search.focus();
      search.value = 'a';
      search.dispatchEvent(new Event('input', {bubbles: true}));
      return true;
    })()
  ")
  app$wait_for_js("
    [...document.querySelectorAll('#scope_check-dropdown .gt-ms-option')]
      .filter(function (o) { return !o.classList.contains('hidden'); }).length === 1
  ")
  expect_true(app$get_js("
    document.querySelector('#scope_check-all').getAttribute('aria-checked') === 'false'
  "))
  app$click(selector = "#scope_check-all")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "scope_check"), "a")
})

test_that("browser: server search responses carry disabled choices", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-server-disabled",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#server_disabled-trigger")
  app$wait_for_js("document.querySelector('#server_disabled-dropdown.open') !== null")

  # The initial page is the first three choices; zeta is not among them.
  expect_true(app$get_js("
    document.querySelector('#server_disabled-dropdown .gt-ms-option[data-value=\"zeta\"]') === null
  "))
  app$get_js("
    (function() {
      var search = document.querySelector('#server_disabled-dropdown input[type=text]');
      search.focus();
      search.value = 'zeta';
      search.dispatchEvent(new Event('input', {bubbles: true}));
      return true;
    })()
  ")
  app$wait_for_js("
    document.querySelector('#server_disabled-dropdown .gt-ms-option[data-value=\"zeta\"]') !== null
  ")

  # The late-arriving disabled row renders disabled ...
  expect_true(app$get_js("
    (function() {
      var row = document.querySelector('#server_disabled-dropdown .gt-ms-option[data-value=\"zeta\"]');
      return row.classList.contains('disabled') &&
        row.getAttribute('aria-disabled') === 'true';
    })()
  "))
  # ... and clicking it does not select it.
  app$click(selector = "#server_disabled-dropdown .gt-ms-option[data-value=\"zeta\"]")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "server_disabled"), "alpha")
})

test_that("browser: single-select All row survives choices updates", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-all-row-update",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#all_update_single-trigger")
  app$wait_for_js("document.querySelector('#all_update_single-dropdown.open') !== null")
  expect_equal(app$get_js("
    document.querySelectorAll('#all_update_single-dropdown .gt-gs-option[data-value=\"__all__\"]').length
  "), 1)
  expect_equal(app$get_js("
    document.querySelectorAll('#all_update_single-dropdown .gt-gs-option').length
  "), 4)

  # Select "All", then update the choices: the row must survive the
  # rebuild and the active "All" selection must survive with it.
  app$click(selector = "#all_update_single-dropdown .gt-gs-option[data-value=\"__all__\"]")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "all_update_single"), "__all__")
  app$click(selector = "#all_update_single_change")
  app$wait_for_js("
    document.querySelectorAll('#all_update_single-dropdown .gt-gs-option').length === 4 &&
    document.querySelectorAll('#all_update_single-dropdown .gt-gs-option[data-value=\"__all__\"]').length === 1
  ")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "all_update_single"), "__all__")

  # A second identical update must not duplicate the row.
  app$click(selector = "#all_update_single_change")
  app$wait_for_js("
    document.querySelectorAll('#all_update_single-dropdown .gt-gs-option').length === 4 &&
    document.querySelectorAll('#all_update_single-dropdown .gt-gs-option[data-value=\"__all__\"]').length === 1
  ")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "all_update_single"), "__all__")
})

test_that("browser: client search matches option values as well as labels", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-value-search",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  search_for <- function(dropdown, option_class, query) {
    app$get_js(sprintf("
      (function() {
        var search = document.querySelector('#%s-dropdown input[type=text]');
        search.focus();
        search.value = '%s';
        search.dispatchEvent(new Event('input', {bubbles: true}));
        return true;
      })()
    ", dropdown, query))
    app$wait_for_js(sprintf("
      [...document.querySelectorAll('#%s-dropdown .%s')]
        .filter(function (o) { return !o.classList.contains('hidden'); }).length === 1
    ", dropdown, option_class))
  }

  # Single-select: "banana" matches no label, only the value.
  app$wait_for_idle()
  app$click(selector = "#value_search-trigger")
  app$wait_for_js("document.querySelector('#value_search-dropdown.open') !== null")
  search_for("value_search", "gt-gs-option", "banana")
  expect_true(app$get_js("
    (function() {
      var visible = [...document.querySelectorAll('#value_search-dropdown .gt-gs-option')]
        .filter(function (o) { return !o.classList.contains('hidden'); });
      return visible.length === 1 && visible[0].getAttribute('data-value') === 'banana';
    })()
  "))

  # Multi-select: same value-only match.
  app$click(selector = "#value_search_multi-trigger")
  app$wait_for_js("document.querySelector('#value_search_multi-dropdown.open') !== null")
  search_for("value_search_multi", "gt-ms-option", "cherry")
  expect_true(app$get_js("
    (function() {
      var visible = [...document.querySelectorAll('#value_search_multi-dropdown .gt-ms-option')]
        .filter(function (o) { return !o.classList.contains('hidden'); });
      return visible.length === 1 && visible[0].getAttribute('data-value') === 'cherry';
    })()
  "))
})

test_that("browser: sequenced server search applies the latest response", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-server-seq",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#server_disabled-trigger")
  app$wait_for_js("document.querySelector('#server_disabled-dropdown.open') !== null")
  app$get_js("
    (function() {
      var search = document.querySelector('#server_disabled-dropdown input[type=text]');
      search.focus();
      search.value = 'eta';
      search.dispatchEvent(new Event('input', {bubbles: true}));
      return true;
    })()
  ")
  app$wait_for_js("
    document.querySelector('#server_disabled-dropdown .gt-ms-option[data-value=\"eta\"]') !== null
  ")
  app$click(selector = "#server_disabled-dropdown .gt-ms-option[data-value=\"eta\"]")
  app$wait_for_idle()
  # Value order follows the current choice list (getValue returns in
  # choice order, not selection order), and server search reorders that
  # list, so only membership is asserted here.
  expect_setequal(app$get_value(input = "server_disabled"), c("alpha", "eta"))
})

test_that("browser: stuck server search status clears on its own", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-search-timeout",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#server_hung-trigger")
  app$wait_for_js("document.querySelector('#server_hung-dropdown.open') !== null")
  app$get_js("
    (function() {
      var search = document.querySelector('#server_hung-dropdown input[type=text]');
      search.focus();
      search.value = 'zzz';
      search.dispatchEvent(new Event('input', {bubbles: true}));
      return true;
    })()
  ")
  # The widget enters the loading state (no server registration exists, so
  # no response will ever arrive)...
  app$wait_for_js("
    (function() {
      var status = document.querySelector('#server_hung-dropdown .gt-select-status');
      return status !== null && status.textContent === 'Searching...';
    })()
  ")
  # ... and the timeout guard clears it on its own.
  app$wait_for_js("
    (function() {
      var status = document.querySelector('#server_hung-dropdown .gt-select-status');
      return status === null || status.textContent !== 'Searching...';
    })()
  ", timeout = 20000)
})

test_that("browser: stale server response is dropped and the latest guard survives", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-server-stale",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#server_stale-trigger")
  app$wait_for_js("document.querySelector('#server_stale-dropdown.open') !== null")
  search_in <- function(value) {
    app$get_js(sprintf(
      "(function() {
        var search = document.querySelector('#server_stale-dropdown input[type=text]');
        search.focus();
        search.value = '%s';
        search.dispatchEvent(new Event('input', {bubbles: true}));
        return true;
      })()",
      value
    ))
  }
  # The first search answers late (2 s server sleep); the second never
  # answers. Send the second while the first is still in flight.
  search_in("alpha")
  app$wait_for_js("
    (function() {
      var status = document.querySelector('#server_stale-dropdown .gt-select-status');
      return status !== null && status.textContent === 'Searching...';
    })()
  ")
  search_in("beta")
  # Long after the late first response has arrived, it must not have
  # replaced the results, and the second search must still be loading:
  # under the old >= logic the stale response applied and disarmed the
  # guard, so both assertions below fail on it.
  Sys.sleep(4)
  expect_true(app$get_js("
    document.querySelector('#server_stale-dropdown .gt-gs-option[data-value=\"alpha_stale\"]') === null
  "))
  expect_true(app$get_js("
    document.querySelector('#server_stale-dropdown .gt-gs-option[data-value=\"one\"]') !== null &&
    document.querySelector('#server_stale-dropdown .gt-gs-option[data-value=\"two\"]') !== null
  "))
  expect_equal(app$get_js("
    (function() {
      var status = document.querySelector('#server_stale-dropdown .gt-select-status');
      return status === null ? null : status.textContent;
    })()
  "), "Searching...")
  # The second search's own guard still fires on its own schedule.
  app$wait_for_js("
    (function() {
      var status = document.querySelector('#server_stale-dropdown .gt-select-status');
      return status === null || status.textContent !== 'Searching...';
    })()
  ", timeout = 20000)
  expect_true(app$get_js("
    document.querySelector('#server_stale-dropdown .gt-gs-option[data-value=\"one\"]') !== null
  "))
})

test_that("browser: empty-string choice value is distinct from cleared", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-empty-value",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  # Initially selected: the empty-string choice, not "nothing selected".
  expect_equal(app$get_value(input = "empty_val"), "")
  expect_equal(app$get_js("
    document.querySelector('#empty_val-label').textContent
  "), "All statuses")
  app$click(selector = "#empty_val-trigger")
  app$wait_for_js("document.querySelector('#empty_val-dropdown.open') !== null")
  app$click(selector = "#empty_val-dropdown .gt-gs-option[data-value=\"active\"]")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "empty_val"), "active")
  expect_equal(app$get_js("
    document.querySelector('#empty_val-label').textContent
  "), "Active")
  app$click(selector = "#empty_val-trigger")
  app$wait_for_js("document.querySelector('#empty_val-dropdown.open') !== null")
  app$click(selector = "#empty_val-dropdown .gt-gs-option[data-value=\"\"]")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "empty_val"), "")
  expect_equal(app$get_js("
    document.querySelector('#empty_val-label').textContent
  "), "All statuses")
  # Clearing is a different state: NULL value and the placeholder label.
  app$click(selector = "#empty_val-clear")
  app$wait_for_idle()
  expect_null(app$get_value(input = "empty_val"))
  expect_equal(app$get_js("
    document.querySelector('#empty_val-label').textContent
  "), "Select an option")
})

test_that("browser: updateGlassSelect can select an empty-string value", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root()

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-interactions"),
    name = "browser-empty-value-update",
    height = 800,
    width = 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$wait_for_idle()
  app$click(selector = "#empty_val-trigger")
  app$wait_for_js("document.querySelector('#empty_val-dropdown.open') !== null")
  app$click(selector = "#empty_val-dropdown .gt-gs-option[data-value=\"active\"]")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "empty_val"), "active")
  # Select the empty-string choice through the server update path, not a
  # click: the update handler used to convert "" to NULL before the
  # controller ever saw it.
  app$click(selector = "#empty_val_update_empty")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "empty_val"), "")
  expect_equal(app$get_js("
    document.querySelector('#empty_val-label').textContent
  "), "All statuses")
  # Clearing is still a distinct state.
  app$click(selector = "#empty_val-clear")
  app$wait_for_idle()
  expect_null(app$get_value(input = "empty_val"))
  expect_equal(app$get_js("
    document.querySelector('#empty_val-label').textContent
  "), "Select an option")
})
