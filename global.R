library(shiny)
library(DT)
library(readr)
library(dplyr)
library(plotly)
library(shinyWidgets)
library(lubridate)
library(shinycssloaders)

games <- read_csv("games.csv") %>%
  mutate(AWAY_TEAM_WINS = if_else(HOME_TEAM_WINS==1, 0, 1))
games_details <- read_csv("games_details.csv")
players <- read_csv("players.csv")
teams <- read_csv("teams.csv")
ranking <- read_csv("ranking.csv")

playerListPerSeason <- full_join(teams, players) %>% select(NICKNAME, PLAYER_NAME, SEASON)

temp <- ranking %>% group_by(SEASON_ID, TEAM) %>% summarise(last = max(STANDINGSDATE))

ranking <- left_join(ranking, temp) %>% filter(STANDINGSDATE == last) %>% select(-last)

rm(temp)

winLossbyTeams <- ranking %>%
  left_join(teams[,c(2,6)]) %>%
  mutate(TEAM = NICKNAME) %>%
  select(SEASON_ID, CONFERENCE, TEAM, W, L) %>%
  mutate(SEASON = as.integer(substr(SEASON_ID, start = 2, stop = 5))) %>%
  select(-SEASON_ID) %>%
  group_by(CONFERENCE, TEAM, SEASON) %>%
  summarise(Win = sum(W), Loss = sum(L)) %>%
  ungroup()

