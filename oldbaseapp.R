

## TidyX Episode 75: Joins with Databases - Shiny

### Packages ---------------------------------------------
library(dplyr)
library(stringr)
library(purrr)
library(htmltools)
library(rvest)
library(janitor)
library(duckdb)
library(DBI)
library(shiny)
library(shinyWidgets)
library(DT)
source("app/logic/db_connect_utils.R")
source("app/logic/pull_games_available.R")

games_available <- pull_games_available()

### Shiny app with an auto refresh
ui <- fluidPage(title = "2021 Playoffs",

                sidebarPanel(
                  pickerInput(
                    inputId = "game_selection",
                    label = "Select Game:",
                    choices = games_available
                  ),
                ),

                mainPanel(
                  DTOutput(outputId = "pbp_table"),
                  uiOutput(outputId = "commit_button_display")
                ))


server <- function(input, output, session) {
  displayedData <- reactiveValues()


  # Game Selection ----------------------------------------------------------


  observeEvent(input$game_selection, {
    req(input$game_selection)

    pull_data_from_game_selection(input$game_selection, displayedData)

  })


  # Render Datatable ---------------------------------------------------------


  ## Data rendering
  output$pbp_table <- renderDT({
    displayedData$pbp
  },
  selection = 'none',
  rownames = FALSE,
  editable = TRUE)


  # Reactive Update Tabel ---------------------------------------------------


  ## when updated,
  proxy = dataTableProxy('pbp_table')

  observeEvent(input$pbp_table_cell_edit, {
    # Update table
    proxy_update_datatable(proxy,
                           input$pbp_table_cell_edit,
                           displayedData)
  })


  # Commit changes ----------------------------------------------------------



  output$commit_button_display <- renderUI({
    if (!displayedData$comment_commit_up_to_date) {
      actionButton("commit", "click to save comments")
    }
  })

  ## commit updates and share comments
  observeEvent(input$commit, {
    commit_changes_2_db(displayedData)

  })

}


shinyApp(ui, server)
