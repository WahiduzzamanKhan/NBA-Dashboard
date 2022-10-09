server <- function(input, output, session){
  output$playerList <- renderDT({
    data <- playerListPerSeason %>%
      filter(NICKNAME == input$nickname & SEASON == input$season) %>%
      select(Players=PLAYER_NAME)

    datatable(
      data = data,
      class = 'compact stripe row-border hover',
      style = 'bootstrap',
      options = list(
        ordering = FALSE,
        info = TRUE,
        bLengthChange = FALSE,
        searching = FALSE
      ),
      filter = 'none',
      selection = 'single'
    )
  })

  output$winLoassbyTeam <- renderPlotly({
    data <- winLossbyTeams %>%
      filter(SEASON >= input$seasonGraph[1] & SEASON <= input$seasonGraph[2]) %>%
      filter(CONFERENCE %in% input$conferenceGraph)

    fig <- plot_ly(
      data = data %>% group_by(CONFERENCE, TEAM) %>% summarise(Win = sum(Win), Loss = sum(Loss)),
      x = ~TEAM,
      y = ~Win,
      type = 'bar',
      name = 'Win'
    ) %>%
      add_trace(
        y = ~Loss,
        name = 'Loss'
      ) %>%
      layout(
        yaxis = list(title = 'Win-Loss'),
        barmode = 'group',
        legend = list(x = 0.9, y = 1)
      )
    fig
  })

  output$winLoassbyConference <- renderPlotly({
    data <- winLossbyTeams %>%
      filter(SEASON >= input$seasonGraph2[1] & SEASON <= input$seasonGraph2[2]) %>%
      select(CONFERENCE, SEASON, Win)

    fig <- plot_ly(
      data = data %>% group_by(CONFERENCE, SEASON) %>% summarise(Win = sum(Win)),
      x = ~SEASON,
      y = ~Win,
      type = 'bar',
      color = ~CONFERENCE,
      colors = 'Set1'
    ) %>%
      layout(
        yaxis = list(title = 'Number of Wins'),
        barmode = 'group',
        legend = list(x = 0.9, y = 1)
      )
    fig
  })

  output$playerComparisonTable <- renderDT({
    t1 <- teams %>% select(TEAM_ID, NICKNAME)
    t2 <- games_details %>% select(TEAM_ID, GAME_ID, `Player Name`=PLAYER_NAME, START_POSITION, MIN, FGM, FG3M, REB, STL, PTS)
    t3 <- games %>% select(GAME_ID, SEASON)

    data <- left_join(t2, t1) %>%
      left_join(t3) %>%
      separate(col = MIN, into = c("minute", "second"), sep = ":", remove = FALSE) %>%
      mutate(minute = as.integer(minute), second = as.integer(minute)) %>%
      mutate(MIN = round(as.numeric(duration(minute = minute, second = second))/60, 2)) %>%
      select(TEAM = NICKNAME, SEASON, everything(), -TEAM_ID, -GAME_ID) %>%
      filter(SEASON >= input$playerComparisonSeason[1] & SEASON <= input$playerComparisonSeason[2]) %>%
      filter(TEAM %in% input$playerComparisonTeam) %>%
      filter(`Player Name` %in% input$playerComparisonPlayers)

    if(input$playerComparisonMeasure=='Total') {
      data <- data %>%
        group_by(`Player Name`) %>%
        summarise(
          `Minutes Played` = sum(MIN, na.rm = T),
          `Goals Made` = sum(FGM, na.rm = T),
          `Three Points` = sum(FG3M, na.rm = T),
          Rebounds = sum(REB, na.rm = T),
          Steals = sum(STL, na.rm = T),
          Points = sum(PTS, na.rm = T)
        )
    }
    else {
      data <- data %>%
        group_by(`Player Name`) %>%
        summarise(
          `Minutes Played` = round(mean(MIN, na.rm = T),2),
          `Goals Made` = round(mean(FGM, na.rm = T),0),
          `Three Points` = round(mean(FG3M, na.rm = T),0),
          Rebounds = round(mean(REB, na.rm = T),0),
          Steals = round(mean(STL, na.rm = T),0),
          Points = round(mean(PTS, na.rm = T),0)
        )
    }

    data <- data %>% select("Player Name", input$playerComparisonAttributes)

    datatable(
      data = data,
      class = 'compact stripe row-border hover',
      style = 'bootstrap',
      options = list(
        ordering = TRUE,
        info = TRUE,
        bLengthChange = TRUE,
        searching = FALSE
      ),
      filter = 'none',
      selection = 'single',
      rownames = FALSE
    )

  })

  output$teamComparisonTable <- renderDT({
    teamId <- teams[,c(2,6)]
    home <- games %>% select(SEASON, contains('HOME'), -HOME_TEAM_ID)
    names(home) <- c('SEASON', 'TEAM_ID', 'PTS', 'FG_PCT', 'FT_PCT', 'FG3_PCT', 'AST', 'REB', 'WIN')
    home <- left_join(teamId, home) %>% select(-TEAM_ID)
    away <- games %>% select(SEASON, contains('AWAY'))
    names(away) <- c('SEASON', 'TEAM_ID', 'PTS', 'FG_PCT', 'FT_PCT', 'FG3_PCT', 'AST', 'REB', 'WIN')
    away <- left_join(teamId, away) %>% select(-TEAM_ID)
    data <- rbind(home, away) %>%
      filter(SEASON >= input$teamComparisonSeason[1] & SEASON <= input$teamComparisonSeason[2]) %>%
      filter(NICKNAME %in% input$teamComparisonTeam) %>%
      group_by(NICKNAME) %>%
      summarise(
        `Total Points` = sum(PTS, na.rm = T),
        `Avg. Points` = round(mean(PTS, na.rm = T),0),
        `Field Goal %` = round(mean(FG_PCT, na.rm = T)*100,2),
        `Free Throw %` = round(mean(FG_PCT, na.rm = T)*100,2),
        `Three Points %` = round(mean(FG_PCT, na.rm = T)*100,2),
        Assists = sum(AST, na.rm = T),
        `Avg. Assists` = round(mean(AST, na.rm = T),0),
        Rebounds = sum(REB, na.rm = T),
        `Avg. Rebounds` = round(mean(REB, na.rm = T),0),
        Wins = sum(WIN, na.rm = T),
        `Win %` = round(mean(WIN, na.rm = T)*100,0)
      ) %>%
      select('NICKNAME', input$teamComparisonAttributes)

    names(data)[1] <- 'Team'

    datatable(
      data = data,
      class = 'compact stripe row-border hover',
      style = 'bootstrap',
      options = list(
        ordering = TRUE,
        info = TRUE,
        bLengthChange = TRUE,
        searching = FALSE
      ),
      filter = 'none',
      selection = 'single',
      rownames = FALSE
    )

  })
}
