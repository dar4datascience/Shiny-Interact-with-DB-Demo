box::use(
  shiny[NS, mainPanel, uiOutput,
        moduleServer, reactiveValues, req, observeEvent, renderUI, actionButton],
  bslib[layout_sidebar, sidebar],
  shinyWidgets[pickerInput],
  DT[DTOutput, renderDT, dataTableProxy],
)

box::use(
  app/logic/pull_games_available[games_available],
  app/logic/db_connect_utils[pull_data_from_game_selection, proxy_update_datatable, commit_changes_2_db]
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(

                sidebar = sidebar(
                  pickerInput(
                    inputId = ns("game_selection"),
                    label = "Select Game:",
                    choices = games_available
                  ),
                  uiOutput(outputId = ns("commit_button_display")
                  )
                ),
                  DTOutput(outputId = ns("pbp_table")
                           )
                )

}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {

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
      actionButton(session$ns("commit"), "click to save comments")
    }
  })

  ## commit updates and share comments
  observeEvent(input$commit, {
    commit_changes_2_db(displayedData)

  })
})
}

