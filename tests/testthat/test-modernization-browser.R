test_that("browser: modernization preserves order, selection and pane inputs", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  local_browser_pkg_root <- function() {
    old <- Sys.getenv("GLASSTABS_TEST_PKG_ROOT", unset = NA_character_)
    Sys.setenv(GLASSTABS_TEST_PKG_ROOT = normalizePath(test_path("..", "..")))
    withr::defer({
      if (is.na(old)) Sys.unsetenv("GLASSTABS_TEST_PKG_ROOT")
      else Sys.setenv(GLASSTABS_TEST_PKG_ROOT = old)
    }, testthat::teardown_env())
  }
  local_browser_pkg_root()
  app <- shinytest2::AppDriver$new(test_path("apps", "browser-interactions"),
    name = "browser-modernization", height = 900, width = 1000)
  on.exit(app$stop(), add = TRUE)
  app$wait_for_idle()
  app$set_inputs(modern_text = "retained")
  expect_true(app$get_js("
    (function(){
      var root=document.getElementById('modern_tabs-wrap');
      var b=document.getElementById('modern_tabs-tab-b');
      b.scrollIntoView({block:'center'}); b.focus();
      b.dispatchEvent(new KeyboardEvent('keydown',{key:'ArrowLeft',altKey:true,shiftKey:true,bubbles:true}));
      var values=Array.from(root.querySelectorAll('.gt-tab-link')).map(function(l){return l.getAttribute('data-value');});
      return values.join(',')==='b,a,c' &&
        document.getElementById('modern_tabs-tab-a').classList.contains('active') &&
        document.getElementById('modern_text').value==='retained';
    })()
  "))
  app$wait_for_js("(Shiny.shinyapp.$inputValues['modern_tabs-tab_order'] || []).join(',') === 'b,a,c'")
  app$wait_for_idle()
  expect_equal(app$get_value(input = "modern_tabs-active_tab"), "a")
  # Drag/drop events exercise the delegated lifecycle; real mouse and touch
  # ergonomics are also covered in the manual release checklist.
  expect_true(app$get_js("
    (function(){
      var c=document.getElementById('modern_tabs-tab-c');
      var b=document.getElementById('modern_tabs-tab-b');
      var dt=new DataTransfer(), r=b.getBoundingClientRect();
      c.dispatchEvent(new DragEvent('dragstart',{bubbles:true,cancelable:true,dataTransfer:dt}));
      b.dispatchEvent(new DragEvent('dragover',{bubbles:true,cancelable:true,dataTransfer:dt,clientX:r.left+1,clientY:r.top+1}));
      b.dispatchEvent(new DragEvent('drop',{bubbles:true,cancelable:true,dataTransfer:dt}));
      return Array.from(b.parentElement.querySelectorAll('.gt-tab-link')).map(function(l){return l.getAttribute('data-value');}).join(',')==='c,b,a';
    })()
  "))
  app$wait_for_idle()
  expect_equal(unname(unlist(app$get_value(input = "modern_tabs-tab_order"))), c("c", "b", "a"))
  app$set_inputs(modern_append = "click")
  app$wait_for_js("document.getElementById('modern_tabs-tab-d') !== null")
  app$wait_for_idle()
  expect_equal(unname(unlist(app$get_value(input = "modern_tabs-tab_order"))), c("c", "b", "a", "d"))
  expect_true(app$get_js("getComputedStyle(document.querySelector('#one_tab-wrap > .gt-topbar')).display === 'none'"))
  expect_true(app$get_js("
    (function(){
      var a=document.getElementById('modern_small-trigger');
      var b=document.getElementById('modern_large-trigger');
      return getComputedStyle(a).backdropFilter==='none' && b.offsetHeight>a.offsetHeight &&
        getComputedStyle(b).backgroundColor==='rgb(248, 250, 252)';
    })()
  "))
  app$get_js("document.getElementById('modern_large-trigger').scrollIntoView({block:'center'}); true")
  app$click(selector = "#modern_large-trigger")
  app$wait_for_js("document.getElementById('modern_large-dropdown').classList.contains('open')")
  expect_true(app$get_js("
    (function(){var d=document.getElementById('modern_large-dropdown');
      return d.parentElement===document.body && getComputedStyle(d).backgroundColor==='rgb(255, 255, 255)' &&
        getComputedStyle(d).getPropertyValue('--gt-glass-strength').trim()==='0.25';})()
  "))
  app$get_js("document.body.dispatchEvent(new PointerEvent('pointerdown',{bubbles:true})); true")
  app$wait_for_js("document.getElementById('modern_large-dropdown').parentElement.id === 'modern_large-wrap'")
  app$get_js("document.getElementById('modern_small-trigger').scrollIntoView({block:'center'}); true")
  app$click(selector = "#modern_small-trigger")
  app$wait_for_js("document.getElementById('modern_small-dropdown').classList.contains('open')")
  app$get_js("document.body.setAttribute('data-bs-theme','dark'); true")
  app$wait_for_js("!document.getElementById('modern_small-dropdown').classList.contains('theme-light')")
  theme_state <- app$get_js("
    (function(){var d=document.getElementById('modern_small-dropdown'),s=getComputedStyle(d);
      return {open:d.classList.contains('open'),
        blur:s.backdropFilter,maxHeight:s.getPropertyValue('--ms-dropdown-max-height').trim(),
        text:s.getPropertyValue('--ms-text').trim()};})()
  ")
  expect_true(theme_state$open)
  expect_true(theme_state$blur %in% c('', 'none', 'blur(0px)'))
  expect_equal(theme_state$maxHeight, '180px')
  expect_equal(theme_state$text, '#cfe6ff')
  expect_true(app$get_js("document.getElementById('modern_custom_selector-wrap').classList.contains('theme-light')"))
  app$get_js("document.body.setAttribute('data-review-dark', 'true'); true")
  app$wait_for_js("!document.getElementById('modern_custom_selector-wrap').classList.contains('theme-light')")
  for (id in c("scroll_single", "scroll_multi")) {
    app$get_js(sprintf("document.getElementById('%s-trigger').scrollIntoView({block:'center'}); true", id))
    app$click(selector = paste0("#", id, "-trigger"))
    app$wait_for_js(sprintf("document.getElementById('%s-dropdown').classList.contains('open')", id))
    expect_true(app$get_js(sprintf(
      "(function(){var d=document.getElementById('%s-dropdown'), o=document.getElementById('%s-options'); return !d.querySelector('.gt-scroll-cue').classList.contains('hidden') && o.clientHeight<=152 && o.scrollHeight>o.clientHeight;})()",
      id, id
    )))
    app$wait_for_js(sprintf(
      "document.getElementById('%s-dropdown').querySelector('.gt-option-active') !== null",
      id
    ))
    app$get_js(sprintf(
      "(function(){var o=document.getElementById('%s-options'); o.scrollTop=9999; o.dispatchEvent(new Event('scroll')); return true;})()",
      id
    ))
    app$wait_for_js(sprintf("document.getElementById('%s-dropdown').querySelector('.gt-scroll-cue').classList.contains('hidden')", id))
    app$get_js("document.body.dispatchEvent(new PointerEvent('pointerdown',{bubbles:true})); true")
  }
})

test_that("browser: modernization lab uses glass controls and exercises tab layouts", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  app_dir <- system.file("examples", "modernization", package = "glasstabs")
  expect_true(nzchar(app_dir))
  app <- shinytest2::AppDriver$new(app_dir, name = "modernization-lab",
                                   height = 900, width = 1280)
  on.exit(app$stop(), add = TRUE)
  app$wait_for_idle()

  expect_true(app$get_js("
    document.querySelectorAll('.gt-lab-controls .gt-gs-wrap').length >= 20 &&
      Array.from(document.querySelectorAll('.gt-lab-controls select, .gt-lab-controls input'))
        .every(function(el) { return !!el.closest('.gt-gs-wrap'); }) &&
      document.getElementById('native_county') !== null
  "))
  app$click(selector = "#nav_style-trigger")
  app$click(selector = "#nav_style-dropdown [data-value=segmented]")
  app$wait_for_js("document.getElementById('workspace-wrap').classList.contains('style-segmented')")

  app$click(selector = "#tab_count-trigger")
  app$click(selector = "#tab_count-dropdown [data-value=six]")
  app$wait_for_js("document.querySelectorAll('#workspace-wrap > .gt-topbar .gt-tab-link').length === 6")
  app$click(selector = "#transition-trigger")
  app$click(selector = "#transition-dropdown [data-value=slide]")
  app$wait_for_js("document.getElementById('workspace-wrap').classList.contains('transition-slide')")

  app$click(selector = "#tab_align-trigger")
  app$click(selector = "#tab_align-dropdown [data-value=right]")
  app$wait_for_js("document.getElementById('workspace-wrap').classList.contains('gt-align-right')")
  app$click(selector = "#content_padding-trigger")
  app$click(selector = "#content_padding-dropdown [data-value='24px']")
  app$wait_for_js("document.getElementById('workspace-wrap').style.getPropertyValue('--gt-content-padding').trim() === '24px'")
  app$click(selector = "#fill-trigger")
  app$click(selector = "#fill-dropdown [data-value=on]")
  app$wait_for_js("document.getElementById('workspace-wrap').classList.contains('gt-fill')")
  app$click(selector = "#orientation-trigger")
  app$click(selector = "#orientation-dropdown [data-value=vertical]")
  app$wait_for_js("document.getElementById('workspace-wrap').classList.contains('gt-vertical')")
  expect_true(app$get_js("
    document.getElementById('single_demo-wrap').classList.contains('gt-single-tab') &&
      getComputedStyle(document.querySelector('#single_demo-wrap > .gt-topbar')).display === 'none'
  "))

  app$set_inputs(badge = "click")
  app$wait_for_js("document.getElementById('workspace-tab-data').textContent.includes('1')")
  app$click(selector = "#snapshot")
  app$wait_for_js("Shiny.shinyapp.$inputValues.browser_report !== undefined")
  expect_length(app$get_value(input = "browser_report")$errors, 0L)
})
