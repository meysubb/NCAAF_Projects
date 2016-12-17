## Create DataFrame of Bowl game matchups, and corresponding stats. 
setwd("/Users/meyappans/Desktop/CFB_Bowl/data")
team_stats <- readRDS(file="Team_stats.RDS")

## Scrape list of bowl games
library(rvest)
bowl_game_url <- read_html("http://www.ncaa.com/sports/football/bowls")
bowl_games = html_table(html_nodes(bowl_game_url, "table")[[1]])
bowl_games <- bowl_games %>% select(`BOWL/TITLE GAME`,SITE,MATCHUP)
# returns string w/o leading or trailing whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)
bowl_games$away_team <- trim(gsub("vs.*","",bowl_games$MATCHUP))
bowl_games$home_team <- trim(gsub(".*vs.","",bowl_games$MATCHUP))

## Clean list of teams
home_team_list <- unique(bowl_games$home_team)
home_team_list <- gsub("State","St.",home_team_list)
home_team_list[6] <- "Southern Miss."
home_team_list[14] <- "Middle Tenn."
home_team_list[29] <- "South Ala."
home_team_list[20] <- "Washington St."
home_team_list[40] <- "Southern California"
away_team_list <- unique(bowl_games$away_team)
away_team_list <- gsub("State","St.",away_team_list)
away_team_list <- gsub("Michigan","Mich.",away_team_list)
#away_team_list[7] <- "Central Mich."
away_team_list[8] <- "Western Ky."
away_team_list[17] <- "North Carolina St."
away_team_list[18] <- "Army West Point"
away_team_list[23] <- "Miami (FL)"

## Check to see if matches exist across both games
home_team_list <- home_team_list[match(home_team_list,team_stats$away_team) & match(away_team_list,team_stats$away_team)]
home_team_list <- home_team_list[!is.na(home_team_list)]
away_team_list <- away_team_list[match(away_team_list,team_stats$away_team) & match(away_team_list,team_stats$away_team)]
away_team_list <- away_team_list[!is.na(away_team_list)]

away_team_stats <- team_stats %>% filter(away_team %in% away_team_list)
away_team_stats <- away_team_stats[match(away_team_list,away_team_stats$away_team),]
home_team_stats <- team_stats %>% filter(away_team %in% home_team_list)
home_team_stats <- home_team_stats[match(home_team_list,home_team_stats$away_team),]
colnames(home_team_stats) <- gsub("away","home",colnames(home_team_stats))

combined_teams <- cbind(away_team_stats,home_team_stats)
bowl_game_stats <- combined_teams %>% select(away_team,home_team,away_first_downs,away_rushing_yds,away_pass_yds,away_tot_offense,away_turnover_margin,away_pen_number,away_pen_yds,away_pun_yds,away_pun_re_yds,away_kick_re_yds,away_third_down_conv_pct,away_fourth_down_conv_pct,home_team,home_team,home_first_downs,home_rushing_yds,home_pass_yds,home_tot_offense,home_turnover_margin,home_pen_number,home_pen_yds,home_pun_yds,home_pun_re_yds,home_kick_re_yds,home_third_down_conv_pct,home_fourth_down_conv_pct,away_team_score,home_team_score)

bowl_game_stats$away_tot_offense <- as.numeric(bowl_game_stats$away_tot_offense)
bowl_game_stats$away_turnover_margin <- as.numeric(bowl_game_stats$away_turnover_margin)
bowl_game_stats$home_tot_offense <- as.numeric(bowl_game_stats$home_tot_offense)
bowl_game_stats$home_turnover_margin <- as.numeric(bowl_game_stats$home_turnover_margin)
saveRDS(bowl_game_stats,file="bowl_games.RDS")

