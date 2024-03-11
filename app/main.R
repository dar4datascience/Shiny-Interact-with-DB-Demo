box::use(
  shiny[div, moduleServer, NS, renderUI, tags, uiOutput, markdown],
  bslib[bs_theme, page_navbar,
        nav_panel, card, card_header, card_footer, card_body],
)

box::use(
  app/view/games_explorer,
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  page_navbar(
    title = "Shiny Interact with DB🛢",
    selected = "How to Use?🛢",
    collapsible = TRUE,
    theme = bs_theme(bootswatch = "pulse",
                     "navbar-bg" = "#593176"),
    sidebar = NULL,
    nav_panel(
      title = "How to Use?🛢",
      card(
        markdown(
          mds = c(
            "Instructions: 🛢 ",
            "# How to Use?",
            "1. **Select Game**: Choose a game from the dropdown menu labeled 'Select Game.'",
            "2. **Data Loading**: Once you select a game, the app will automatically load the relevant data associated with that game.",
            "3. **View Data**: After the data is loaded, you'll see a table displayed in the main panel of the app. This table represents the play-by-play (pbp) data for the selected game.",
            "4. **Edit Data**: You can edit the data directly in the table by clicking on any cell and making changes. This feature allows you to update or modify the play-by-play data as needed.",
            "5. **Commit Changes**: If you make any changes to the data, a 'click to save comments' button will appear below the table. Click this button to commit your changes and save them to the database.",
            "6. **Wait for Confirmation**: After clicking the 'commit' button, wait for the app to confirm that your changes have been successfully saved to the database.",
            "7. **Repeat as Needed**: You can repeat this process for different games by selecting a new game from the dropdown menu and following steps 3 to 6.",
            "8. **Enjoy Using the App**!",
            "<br><br>",
            "![test image](https://www.iliketowastemytime.com/sites/default/files/best-gifs-pt6-nonono-cat.gif)"
          )

        )
      )

    ),
    nav_panel(
      title = "Demo",
      card(
        full_screen = TRUE,
        card_header("2021 Playoffs"),
        card_body(games_explorer$ui(ns("games_explorer"))
        ),
        card_footer(
          "Data from TidyX"
        )
      )
    )
  )

}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {

    games_explorer$server("games_explorer")

  })
}
