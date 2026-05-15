package_name <- "glasstabs"

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

fetch_downloads <- function(package = package_name, from = Sys.Date() - 180, to = Sys.Date()) {
  from <- as.Date(from)
  query <- sprintf(
    "https://cranlogs.r-pkg.org/downloads/daily/%s:%s/%s",
    format(from, "%Y-%m-%d"),
    format(as.Date(to), "%Y-%m-%d"),
    utils::URLencode(package, reserved = TRUE)
  )

  response <- jsonlite::fromJSON(query, simplifyVector = FALSE)
  stats <- response[[1]]
  downloads <- stats$downloads

  if (!length(downloads)) {
    return(data.frame(
      date = as.Date(character()),
      package = character(),
      count = numeric(),
      stringsAsFactors = FALSE
    ))
  }

  data.frame(
    date = as.Date(vapply(downloads, function(x) x$day, character(1))),
    package = stats$package %||% package,
    count = vapply(downloads, function(x) as.numeric(x$downloads), numeric(1)),
    stringsAsFactors = FALSE
  )
}

counts_cols <- function(x) {
  intersect(c("count", "downloads"), names(x))
}

download_count_col <- function(x) {
  cols <- counts_cols(x)
  if (!length(cols)) {
    stop("Download data did not include a count column.", call. = FALSE)
  }
  cols[[1]]
}

summarise_downloads <- function(stats) {
  if (!nrow(stats)) {
    return(list(
      package = package_name,
      latest_date = NA,
      latest_downloads = 0,
      total_downloads = 0,
      downloads_7 = 0,
      downloads_30 = 0
    ))
  }

  count_col <- download_count_col(stats)
  today <- max(stats$date, na.rm = TRUE)
  last_7_start <- today - 6
  last_30_start <- today - 29

  list(
    package = unique(stats$package)[1],
    latest_date = today,
    latest_downloads = stats[[count_col]][stats$date == today][1],
    total_downloads = sum(stats[[count_col]], na.rm = TRUE),
    downloads_7 = sum(stats[[count_col]][stats$date >= last_7_start], na.rm = TRUE),
    downloads_30 = sum(stats[[count_col]][stats$date >= last_30_start], na.rm = TRUE)
  )
}

metric_card <- function(title, value, subtitle = NULL) {
  bs4Dash::bs4Card(
    title = title,
    width = 3,
    solidHeader = FALSE,
    status = "light",
    shiny::div(
      style = "font-size: 1.8rem; font-weight: 700; line-height: 1.1;",
      value
    ),
    if (!is.null(subtitle)) {
      shiny::div(
        style = "margin-top: 0.4rem; color: #6b7280;",
        subtitle
      )
    }
  )
}

ui <- bs4Dash::bs4DashPage(
  title = sprintf("%s Downloads", package_name),
  header = bs4Dash::bs4DashNavbar(
    title = "CRAN Download Tracker"
  ),
  sidebar = bs4Dash::bs4DashSidebar(
    skin = "light",
    bs4Dash::bs4SidebarMenu(
      bs4Dash::bs4SidebarMenuItem(
        "Downloads",
        tabName = "downloads",
        icon = shiny::icon("chart-line")
      )
    )
  ),
  body = bs4Dash::bs4DashBody(
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::tags$div(
          style = "padding: 12px 0 4px 0;",
          shiny::tags$h2(sprintf("%s CRAN Downloads", package_name)),
          shiny::tags$p(
            style = "color: #6b7280;",
            "Data source: cranlogs daily download feed."
          )
        )
      )
    ),
    shiny::fluidRow(
      shiny::column(
        width = 4,
        shiny::dateInput(
          "from_date",
          "Track from",
          value = Sys.Date() - 180
        )
      ),
      shiny::column(
        width = 4,
        shiny::actionButton("refresh", "Refresh", icon = shiny::icon("rotate-right"))
      )
    ),
    shiny::br(),
    shiny::uiOutput("metrics"),
    shiny::fluidRow(
      bs4Dash::bs4Card(
        title = "Daily Downloads",
        width = 8,
        shiny::plotOutput("downloads_plot", height = 320)
      ),
      bs4Dash::bs4Card(
        title = "Recent Data",
        width = 4,
        shiny::tableOutput("recent_table")
      )
    )
  ),
  footer = bs4Dash::bs4DashFooter(
    left = "Maintainer tool",
    right = format(Sys.Date(), "%Y-%m-%d")
  )
)

server <- function(input, output, session) {
  trigger <- shiny::reactiveVal(0)

  shiny::observeEvent(input$refresh, {
    trigger(trigger() + 1)
  })

  stats_data <- shiny::reactive({
    trigger()
    fetch_downloads(from = input$from_date)
  })

  stats_summary <- shiny::reactive({
    summarise_downloads(stats_data())
  })

  output$metrics <- shiny::renderUI({
    summary <- stats_summary()
    shiny::fluidRow(
      metric_card("Total", format(summary$total_downloads, big.mark = ",")),
      metric_card("Last 30 Days", format(summary$downloads_30, big.mark = ",")),
      metric_card("Last 7 Days", format(summary$downloads_7, big.mark = ",")),
      metric_card(
        "Latest Day",
        format(summary$latest_downloads, big.mark = ","),
        if (is.na(summary$latest_date)) "No data yet" else format(summary$latest_date, "%Y-%m-%d")
      )
    )
  })

  output$downloads_plot <- shiny::renderPlot({
    stats <- stats_data()
    shiny::validate(shiny::need(nrow(stats) > 0, "CRAN download data is not available yet."))
    count_col <- download_count_col(stats)
    graphics::plot(
      stats$date,
      stats[[count_col]],
      type = "l",
      lwd = 2,
      col = "#2f6f8f",
      xlab = "Date",
      ylab = "Downloads",
      main = sprintf("%s daily CRAN downloads", package_name)
    )
    graphics::abline(h = pretty(stats[[count_col]]), col = "#eceff4", lty = "dotted")
  })

  output$recent_table <- shiny::renderTable({
    stats <- stats_data()
    shiny::validate(shiny::need(nrow(stats) > 0, "No CRAN download data yet."))
    count_col <- download_count_col(stats)
    recent <- utils::head(stats[order(stats$date, decreasing = TRUE), c("date", count_col)], 10)
    names(recent) <- c("date", "downloads")
    recent
  }, striped = TRUE, bordered = TRUE, spacing = "s")
}

app <- shiny::shinyApp(ui, server)
