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
