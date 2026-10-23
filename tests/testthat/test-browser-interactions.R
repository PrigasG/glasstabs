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
  app$click(selector = "#fruit-dropdown .gt-gs-option[data-value='banana']")
  app$wait_for_idle()

  expect_equal(app$get_value(input = "fruit"), "banana")
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

test_that("browser: narrow select dropdowns resize and wrap long labels", {
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
  app$click(selector = "#short_single-trigger")
  app$wait_for_js("document.querySelector('#short_single-dropdown.open') !== null")
  expect_true(app$get_js("
    (function() {
      var trigger = document.querySelector('#short_single-trigger');
      var dropdown = document.querySelector('#short_single-dropdown');
      return Math.abs(trigger.offsetWidth - dropdown.offsetWidth) <= 1;
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
      return words.offsetHeight > 20 && token.scrollWidth <= token.clientWidth + 1;
    })()
  "))

  expect_true(app$get_js("
    (function() {
      var field = document.querySelector('#short_single-field');
      field.style.width = '220px';
      window.dispatchEvent(new Event('resize'));
      return true;
    })()
  "))
  # Resize repositions the open dropdown to follow the trigger instead of
  # closing it (mobile URL-bar and on-screen keyboard resizes must not strand
  # the user mid-task), so it stays open and tracks the new trigger width.
  app$wait_for_js("
    document.querySelector('#short_single-dropdown.open') !== null &&
    Math.abs(
      document.querySelector('#short_single-trigger').offsetWidth -
      document.querySelector('#short_single-dropdown').offsetWidth
    ) <= 1 && document.querySelector('#short_single-dropdown').offsetWidth >= 219
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
      return Math.abs(trigger.offsetWidth - dropdown.offsetWidth) <= 1;
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
      return words.offsetHeight > 20 && token.scrollWidth <= token.clientWidth + 1;
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
      setTimeout(function() {
        document.body.setAttribute('data-gt-close-settled', 'true');
      }, 150);
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
      setTimeout(function() {
        document.body.setAttribute('data-gt-overlay-close-settled', 'true');
      }, 150);
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
  # The teleported panel still tracks the trigger after the resize.
  expect_true(app$get_js("
    (function() {
      var trigger = document.querySelector('#fruit-trigger');
      var dropdown = document.querySelector('#fruit-dropdown');
      var tr = trigger.getBoundingClientRect();
      var dr = dropdown.getBoundingClientRect();
      return Math.abs(dr.left - (tr.right - dr.width)) <= 2 &&
        dr.top >= tr.bottom;
    })()
  "))
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
