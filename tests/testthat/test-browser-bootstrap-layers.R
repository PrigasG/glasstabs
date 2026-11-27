test_that("browser: dropdowns remain usable inside Bootstrap focus layers", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("bslib")
  withr::local_envvar(GLASSTABS_TEST_PKG_ROOT = normalizePath(test_path("..", "..")))

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-bootstrap-layers"),
    name = "browser-bootstrap-focus-layers",
    height = 900,
    width = 1280
  )
  on.exit(app$stop(), add = TRUE)
  app$wait_for_idle()

  app$get_js("
    bootstrap.Offcanvas.getOrCreateInstance(document.getElementById('test_offcanvas')).show();
    true
  ")
  app$wait_for_js("document.getElementById('test_offcanvas').classList.contains('show')")
  Sys.sleep(0.4)
  for (id in c("off_single", "off_multi")) {
    app$click(selector = paste0("#", id, "-trigger"))
    app$wait_for_js(sprintf("document.getElementById('%s-dropdown').classList.contains('open')", id))
    app$wait_for_js(sprintf("
      document.activeElement === document.querySelector('#%s-dropdown input[type=text]')
    ", id))
    expect_true(app$get_js(sprintf("
      (function() {
        var panel = document.getElementById('%s-dropdown');
        var rect = panel.getBoundingClientRect();
        return panel.parentElement.id === 'test_offcanvas' &&
          rect.left >= -2 && rect.right <= innerWidth + 2 &&
          rect.top >= -2 && rect.bottom <= innerHeight + 2;
      })()
    ", id)))
  }
  app$get_js("
    bootstrap.Offcanvas.getInstance(document.getElementById('test_offcanvas')).hide();
    true
  ")
  app$wait_for_js("!document.getElementById('test_offcanvas').classList.contains('show')")
  app$wait_for_js("!document.getElementById('off_multi-dropdown').classList.contains('open')")

  app$set_inputs(open_modal = "click")
  app$wait_for_js("document.querySelector('.modal.show #modal_single-trigger') !== null")
  for (id in c("modal_single", "modal_multi")) {
    app$click(selector = paste0("#", id, "-trigger"))
    app$wait_for_js(sprintf("document.getElementById('%s-dropdown').classList.contains('open')", id))
    app$wait_for_js(sprintf("
      document.activeElement === document.querySelector('#%s-dropdown input[type=text]')
    ", id))
    expect_true(app$get_js(sprintf("
      document.getElementById('%s-dropdown').parentElement.classList.contains('modal')
    ", id)))
  }
  app$get_js("Shiny.modal.remove(); true")
  app$wait_for_js("document.getElementById('modal_multi-wrap') === null")
})
