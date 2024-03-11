box::use(
  DBI[dbConnect, dbDisconnect],
  duckdb[duckdb],
  here[here],
  dplyr[tbl, pull]
)
#' @export
pull_games_available <- function(){
db_con <- dbConnect(
  drv = duckdb(),
  here("app/static/nba_playoffs.db")
)

on.exit(##disconnect
  dbDisconnect(db_con, shutdown = TRUE))

games_available <- tbl(db_con, "game_ids") |>
  pull(game_info)

return(games_available)

}

#' @export
games_available <- pull_games_available()

