### Get Game PbP Data ---------------------------------------------
#' @export
pull_game_pbp_data <- function(game_id, con, verbose = FALSE){

  if(verbose){
    print(game_id)
  }

  ## html ----
  espn_pbp <- read_html(paste0("https://www.espn.com/nba/playbyplay/_/gameId/",game_id))
  espn_game_summary <- read_html(paste0("https://www.espn.com/nba/game/_/gameId/",game_id))

  ## game info ----

  teams <- espn_pbp |>
    html_nodes(".competitors")

  home <- teams |>
    html_nodes(".home") |>
    html_nodes("span") |>
    `[`(1:3) |>
    html_text

  away <- teams |>
    html_nodes(".away") |>
    html_nodes("span") |>
    `[`(1:3) |>
    html_text

  game_info <- espn_game_summary |>
    html_nodes(".game-information") |>
    html_nodes(".game-field")

  game_time <- game_info |>
    html_nodes(".game-date-time") |>
    html_node("span") |>
    html_attr("data-date")

  game_odds <- espn_game_summary |>
    html_nodes(".game-information") |>
    html_nodes(".odds") |>
    html_nodes("li") |>
    html_text() |>
    str_split(":") |>
    data.frame() |>
    janitor::row_to_names(1)

  game_capacity <- espn_game_summary |>
    html_nodes(".game-information") |>
    html_nodes(".game-info-note") |>
    html_text() |>
    str_split(":") |>
    data.frame() |>
    janitor::row_to_names(1)

  game_summary <- espn_game_summary |>
    html_nodes(".header") |>
    html_text() |>
    str_split(",") |>
    pluck(1) |>
    pluck(1)

  game_df <- data.frame(
    game_id = game_id,
    game_time = game_time,
    game_info = game_summary[[1]],
    home_team = paste(home[1:2],collapse = " "),
    home_team_abbrev = home[3],
    away_team = paste(away[1:2],collapse = " "),
    away_team_abbrev = away[3],
    game_capacity,
    game_odds
  ) |>
    janitor::clean_names()

  ## pbp info ----

  quarter_tabs <- espn_pbp |>
    html_nodes("#gamepackage-qtrs-wrap") |>
    html_nodes(".webview-internal") |>
    html_attr("href")

  full_game_pbp <- map_dfr(quarter_tabs, function(qtab){
    ## scrape elements for time stamps, play details, and score
    time_stamps <- espn_pbp |>
      html_nodes("div") |>
      html_nodes(qtab) |>
      html_nodes(".time-stamp") |>
      html_text() |>
      as_tibble() |>
      rename(time = value)

    possession_details <- espn_pbp |>
      html_nodes("div") |>
      html_nodes(qtab) |>
      html_nodes(".logo") |>
      html_nodes("img") |>
      html_attr("src") |>
      as_tibble() |>
      rename(possession = value) |>
      mutate(
        possession = basename(possession)
      ) |>
      mutate(
        possession =  str_replace(possession, "(.+)([.]png.+)","\\1")
      )

    play_details <- espn_pbp |>
      html_nodes("div") |>
      html_nodes(qtab) |>
      html_nodes(".game-details") |>
      html_text() |>
      as_tibble() |>
      rename(play_details = value)

    score <- espn_pbp |>
      html_nodes("div") |>
      html_nodes(qtab) |>
      html_nodes(".combined-score") |>
      html_text() |>
      as_tibble() |>
      rename(score = value)

    ## bind data together
    bind_cols(time_stamps, possession_details, play_details, score) |>
      mutate(
        quarter = gsub("#","",qtab)
      )
  }) |>
    mutate(play_id_num = seq_len(nrow(.)))

  dbWriteTable(con, name = paste0("game_pbp_",game_id), full_game_pbp, overwrite = TRUE)


  ## NEW
  comments_table <- data.frame(
    play_id_num = numeric(),
    comment = character()
  )

  dbWriteTable(con, name = paste0("game_comments_",game_id), comments_table, overwrite = TRUE)


  if("game_ids" %in% dbListTables(con)){
    hist_game_table <- dbReadTable(con, "game_ids")
    game_df <- unique(rbind(hist_game_table, game_df))
  }

  dbWriteTable(con, name = "game_ids", game_df, overwrite = TRUE)

}
