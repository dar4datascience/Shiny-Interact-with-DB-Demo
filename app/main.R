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
    theme = bs_theme(bootswatch = "superhero"),
    sidebar = NULL,
    nav_panel(
      title = "How to Use?🛢",
      card(
        markdown(
          mds = c(
            "Instructions: 🛢 ",
            "# How to Use?",
            "1. **Enter City**: Type the name of the city you want to map in the text field.",
            "2. **Click 'Map it!'**: Press the button to generate the map.",
            "3. **Wait**: The map will take a moment to load.",
            "4. **Explore**: Once loaded, interact with the map to see details about the city.",
            "5. **Enjoy**",
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
