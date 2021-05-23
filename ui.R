ui <- navbarPage(
  title = 'NBA Dashboard',
  collapsible = TRUE,
  position = 'static-top',
  theme = 'style.css',

  tabPanel(
    title = 'Performance Graphs',
    value = 'tab1',
    fluidRow(
      column(
        width = 4,
        h2('Player List'),
        pickerInput(
          inputId = 'nickname',
          label = 'Select Team',
          choices = sort(unique(playerListPerSeason$NICKNAME)),
          selected = playerListPerSeason$NICKNAME[1],
          width = '100%',
          options = list(
            size = 6
          )
        ),
        pickerInput(
          inputId = 'season',
          label = 'Select Season',
          choices = unique(playerListPerSeason$SEASON),
          selected = playerListPerSeason$SEASON[1],
          width = '100%',
          options = list(
            size = 6
          )
        ),
        DTOutput('playerList')
      ),

      column(
        width = 8,
        h2('Win-Loss by Team'),
        column(
          width = 10,
          withSpinner(plotlyOutput('winLoassbyTeam', height = '540px'), type = 8)
        ),
        column(
          width = 2,
          sliderInput(
            inputId = 'seasonGraph',
            label = "Select Seasons",
            min = min(winLossbyTeams$SEASON),
            max = max(winLossbyTeams$SEASON),
            value = c(min(winLossbyTeams$SEASON), max(winLossbyTeams$SEASON)),
            step = 1
          ),
          pickerInput(
            inputId = "conferenceGraph",
            label = "Select Conference",
            choices = unique(winLossbyTeams$CONFERENCE),
            selected = unique(winLossbyTeams$CONFERENCE),
            options = list(
              `actions-box` = TRUE
            ),
            multiple = TRUE
          )
        ),

        column(
          width = 10,
          h2('Wins by Conference'),
          withSpinner(plotlyOutput('winLoassbyConference', height = '540px'), type = 8)
        ),
        column(
          width = 2,
          sliderInput(
            inputId = 'seasonGraph2',
            label = "Select Seasons",
            min = min(winLossbyTeams$SEASON),
            max = max(winLossbyTeams$SEASON),
            value = c(min(winLossbyTeams$SEASON), max(winLossbyTeams$SEASON)),
            step = 1
          )
        )
      )
    )
  ),

  tabPanel(
    title = 'Comparison',
    value = 'tab2',
    tabsetPanel(
      tabPanel(
        title = 'Compare Players',
        fluidRow(
          column(
            width = 3,
            sliderInput(
              inputId = 'playerComparisonSeason',
              label = "Select Seasons",
              min = min(winLossbyTeams$SEASON),
              max = max(winLossbyTeams$SEASON),
              value = c(min(winLossbyTeams$SEASON), max(winLossbyTeams$SEASON)),
              step = 1,
              width = '100%'
            ),
            pickerInput(
              inputId = 'playerComparisonTeam',
              label = 'Select Team',
              choices = sort(unique(playerListPerSeason$NICKNAME)),
              selected = sort(unique(playerListPerSeason$NICKNAME)),
              width = '100%',
              options = list(
                size = 6,
                `actions-box` = TRUE
              ),
              multiple = TRUE
            )
          ),
          column(
            width = 3,
            checkboxGroupButtons(
              inputId = 'playerComparisonAttributes',
              label = 'Select attributes to show',
              choices = c('Minutes Played', 'Goals Made', 'Three Points', 'Rebounds', 'Steals', 'Points'),
              selected = c('Minutes Played', 'Goals Made', 'Three Points', 'Rebounds', 'Steals', 'Points'),
              individual = TRUE,
              checkIcon = list(
                yes = icon("ok",
                           lib = "glyphicon"),
                no = icon("remove",
                          lib = "glyphicon")
              ),
              width = '100%'
            ),
            radioButtons(
              inputId = 'playerComparisonMeasure',
              label = 'Measure',
              choices = c('Total', 'Average'),
              selected = 'Total',
              inline = TRUE
            )
          ),
          column(
            width = 3,
            pickerInput(
              inputId = 'playerComparisonPlayers',
              label = 'Select Players',
              choices = sort(unique(players$PLAYER_NAME)),
              selected = sort(unique(players$PLAYER_NAME)),
              width = '100%',
              options = list(
                size = 6,
                `actions-box` = TRUE,
                `live-search` = TRUE
              ),
              multiple = TRUE
            )
          ),
          column(
            width = 3,

          )
        ),
        hr(),
        withSpinner(DTOutput('playerComparisonTable'), type = 8)
      ),

      tabPanel(
        title = 'Compare Team',
        fluidRow(
          column(
            width = 3,
            sliderInput(
              inputId = 'teamComparisonSeason',
              label = "Select Seasons",
              min = min(winLossbyTeams$SEASON),
              max = max(winLossbyTeams$SEASON),
              value = c(min(winLossbyTeams$SEASON), max(winLossbyTeams$SEASON)),
              step = 1,
              width = '100%'
            ),
            pickerInput(
              inputId = 'teamComparisonTeam',
              label = 'Select Team',
              choices = sort(unique(playerListPerSeason$NICKNAME)),
              selected = sort(unique(playerListPerSeason$NICKNAME)),
              width = '100%',
              options = list(
                size = 6,
                `actions-box` = TRUE
              ),
              multiple = TRUE
            )
          ),
          column(
            width = 3,
            checkboxGroupButtons(
              inputId = 'teamComparisonAttributes',
              label = 'Select attributes to show',
              choices = c('Total Points', 'Avg. Points', 'Field Goal %', 'Free Throw %', 'Three Points %', 'Assists', 'Avg. Assists', 'Rebounds', 'Rebounds', 'Wins', 'Win %'),
              selected = c('Total Points', 'Avg. Points', 'Field Goal %', 'Free Throw %', 'Three Points %', 'Assists', 'Avg. Assists', 'Rebounds', 'Rebounds', 'Wins', 'Win %'),
              individual = TRUE,
              checkIcon = list(
                yes = icon("ok",
                           lib = "glyphicon"),
                no = icon("remove",
                          lib = "glyphicon")
              ),
              width = '100%'
            )
          ),
          column(
            width = 3,

          ),
          column(
            width = 3,

          )
        ),
        hr(),
        withSpinner(DTOutput('teamComparisonTable'), type = 8)
      )
    )
  )
)