
pull_games_available <- function(){
db_con <- dbConnect(
  drv = duckdb::duckdb(),
  here::here("app/static/nba_playoffs.db")
)

on.exit(##disconnect
  dbDisconnect(db_con, shutdown = TRUE))

games_available <- tbl(db_con, "game_ids") |>
  pull(game_info)



}
