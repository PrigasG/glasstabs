test_that("browser: Bootstrap 3 modal keeps select searches inside its focus boundary", {
  skip_on_covr()
  skip_if_not_installed("shinytest2")
  withr::local_envvar(GLASSTABS_TEST_PKG_ROOT = normalizePath(test_path("..", "..")))

  app <- shinytest2::AppDriver$new(
    test_path("apps", "browser-bootstrap3-modal"),
    name = "browser-bootstrap3-modal",
    height = 800,
    width = 1100
  )
  on.exit(app$stop(), add = TRUE)
  app$set_inputs(open_modal = "click")
  app$wait_for_js("document.querySelector('.modal.in #modal_single-trigger') !== null")

  for (id in c("modal_single", "modal_multi")) {
    app$click(selector = paste0("#", id, "-trigger"))
    app$wait_for_js(sprintf("document.getElementById('%s-dropdown').classList.contains('open')", id))
    app$click(selector = paste0("#", id, "-dropdown input[type=text]"))
    app$wait_for_js(sprintf("document.activeElement === document.querySelector('#%s-dropdown input[type=text]')", id))
    expect_true(app$get_js(sprintf("(function(){
      var panel=document.getElementById('%s-dropdown');
      return panel.parentElement.classList.contains('modal') &&
        panel.parentElement.classList.contains('in') &&
        document.activeElement===panel.querySelector('input[type=text]');
    })()", id)))
  }

  app$get_js("Shiny.modal.remove(); true")
  app$wait_for_js("document.getElementById('modal_multi-dropdown') === null")
})
