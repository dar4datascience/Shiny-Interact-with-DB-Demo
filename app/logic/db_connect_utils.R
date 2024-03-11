pull_data_from_game_selection <- function(game_selection,
                                          displayedData){

  ## connect to database
  db_con <- dbConnect(
    drv = duckdb::duckdb(),
    here::here("app/static/nba_playoffs.db")
  )

  ##disconnect when reactive finishes
  on.exit(dbDisconnect(db_con, shutdown = TRUE))

  game_id <- tbl(db_con, "game_ids") |>
    filter( game_info == !!game_selection) |>
    pull(game_id)

  comments <- tbl(db_con, paste0("game_comments_",game_id))

  pbp <- tbl(db_con, paste0("game_pbp_",game_id)) |>
    left_join(comments, by = "play_id_num") |>
    arrange(play_id_num)

  displayedData$game_id <- game_id
  displayedData$comments <- comments |> collect()
  displayedData$pbp <- pbp |> collect()

  displayedData$comment_commit_up_to_date <- TRUE

}


proxy_update_datatable <- function(proxy, pbp_table_cell_edit, displayedData){

  info = pbp_table_cell_edit
  i = info$row
  j = info$col + 1  # column index offset by 1
  v = info$value

  ## only comment column can be edited
  if(colnames(displayedData$pbp)[j] == "comment"){

    # get play number to change
    play_num <- displayedData$pbp$play_id_num[i]

    displayedData$comments <- bind_rows(
      displayedData$comments[!displayedData$comments$play_id_num == play_num,],
      data.frame(
        play_id_num = play_num,
        comment = v
      )
    )

    displayedData$pbp <- displayedData$pbp |>
      select(-comment) |>
      left_join(displayedData$comments, by = "play_id_num") |>
      arrange(play_id_num)

    displayedData$comment_commit_up_to_date <- FALSE

  }
  replaceData(proxy, displayedData$pbp, resetPaging = FALSE, rownames = FALSE)
}


commit_changes_2_db <- function(displayedData){
  db_con <- dbConnect(
    drv = duckdb::duckdb(),
    here::here("app/static/nba_playoffs.db")
  )

  ##disconnect when reactive finishes
  on.exit(dbDisconnect(db_con, shutdown = TRUE))

  dbWriteTable(
    db_con,
    name = paste0("game_comments_", displayedData$game_id),
    as.data.frame(displayedData$comments),
    overwrite = TRUE
  )

  displayedData$comment_commit_up_to_date <- TRUE


}
