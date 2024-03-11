library(DBI)
library(duckdb)

db_con <- dbConnect(
  drv = duckdb(),
  #here::here("app/static/nba_playoffs.db")
)


## create connection
duckdb::dbSendQuery(db_con,
                    "INSTALL sqlite;
LOAD sqlite;"
)
