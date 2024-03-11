# Write several games to database ---------------------------------------------
populate_db_table <- function(){

db_con <- duckdb(
  here::here("app/static/nba_playoffs.db")
)
on.exit(##disconnect
  dbDisconnect(db_con)
)

## write table
walk(
  c(
    "401327715", ## Miami Heat @ Milwaukee Bucks (1st Rd | Game 1 Eastern Conference Playoffs, 2021)
    "401327878", ## Miami Heat @ Milwaukee Bucks (1st Rd | Game 2 Eastern Conference Playoffs, 2021)
    "401327879", ## Miami Heat @ Milwaukee Bucks (1st Rd | Game 3 Eastern Conference Playoffs, 2021)
    "401327870" ## Denver Nuggets @ Portland Trail Blazers (1st Rd | Game 4 Western Conference Playoffs, 2021)
  ),
  pull_game_pbp_data,
  db_con
)

dbListTables(db_con)


}
