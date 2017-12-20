
library(tidyverse)
library(lubridate)
library(reshape2)
library(ggplot2)

## Prepare overall team stats
## Use this as a prediction set. 
team_stats <- read_tsv(file="data/tstats_data.tsv") %>% 
  filter(stats != 'Stat') %>% select(team,stats,value)
team_stats <- spread(team_stats, stats, value)
colnames(team_stats)[23] <- "T.O.P"
### Change variable types from Characters to Numeric 
len <- ncol(team_stats)-2
character_vars <- colnames(team_stats)[2:len]
team_stats$T.O.P <- as.POSIXlt(team_stats$T.O.P, format = "     %M:%S")
t.lub <- ymd_hms(team_stats$T.O.P)
m.lub <- minute(t.lub) + second(t.lub)/60
team_stats$T.O.P <- m.lub
team_stats[, character_vars] <- lapply(team_stats[, character_vars], as.numeric)
colnames(team_stats) <- make.names(colnames(team_stats))

## Add record_data 

record_data <- read_tsv(file="data/record_data.tsv")
record_data <- record_data %>% mutate(
  games = win+losses
) %>% select(team,games) %>% inner_join(.,team_stats)


## Filter Team Stats as neccessary 
team_stats_test <- record_data %>% 
  select(team,games, X3rd.Down.Conversion.Pct,X4th.Down.Conversion.Pct,
         Fewest.Penalties.Per.Game,Fewest.Penalty.Yards.Per.Game,First.Downs.Offense,
         Kickoff.Returns, Net.Punting,Passing.Offense,Punt.Returns,Rushing.Offense,
         Scoring.Offense,Turnover.Margin,Total.Offense) %>% 
  mutate(First.Downs.Offense = First.Downs.Offense/games,
         games=NULL)

colnames(team_stats_test) <- c("away_team","away_third_down_conv_pct","away_fourth_down_conv_pct", "away_pen_number","away_pen_yds","away_first_downs","away_kick_re_yds","away_pun_yds","away_pass_yds","away_pun_re_yds","away_rushing_yds","away_team_score","away_turnover_margin","away_tot_offense")



### Individual game_data
game_stats <- read.csv(file="data/game_data.tsv",sep="\t",header=TRUE, na.strings="?",row.names = NULL,stringsAsFactors = FALSE)
colnames(game_stats)[1:61] <- colnames(game_stats)[2:62]
game_stats[,62] <- NULL

game_stats <- game_stats %>% 
  mutate(away_third_down_conv_pct = away_third_down_suc/away_third_down_attempts,
         home_third_down_conv_pct = home_third_down_suc/home_third_down_attempts,
         away_fourth_down_conv_pct = away_fourth_down_suc/away_fourth_down_attempts,
         home_fourth_down_conv_pct = home_fourth_down_suc/home_fourth_down_attempts,
         away_turnover_margin = away_fumbles_lost+away_passing_interceptions-(home_fumbles_lost+home_passing_interceptions),
         home_turnover_margin = -1 * away_turnover_margin)


## Individual game_scores 
game_scores <- read.csv(file="data/game_score.tsv", sep="\t", header=TRUE, na.strings="?",row.names = NULL,stringsAsFactors = FALSE)
colnames(game_scores)[1:5] <-colnames(game_scores)[2:6] 
game_scores[,6] <- NULL

game_scores <- game_scores %>% select(game_id,away_team_score,home_team_score)

## Merge game_data and game_scores
game_stats_select <- game_stats %>% select(game_id, away_team_id,away_team,
                                           home_team_id,home_team,away_first_downs,away_rushing_yds,away_pass_yds,away_tot_offense,away_turnover_margin,away_pen_number,away_pen_yds,away_pun_yds,away_pun_re_yds,away_kick_re_yds,
                                           away_int_re_number,away_third_down_conv_pct,away_fourth_down_conv_pct,home_first_downs,home_rushing_yds,home_pass_yds,home_tot_offense,home_turnover_margin,home_pen_number,home_pen_yds,
                                           home_pun_yds,home_pun_re_yds,home_kick_re_number,home_kick_re_yds,home_int_re_number,home_third_down_conv_pct,home_fourth_down_conv_pct)
ind_game_stats <- inner_join(game_scores,game_stats)


ind_game_stats <- ind_game_stats[,-c(1,4)]
# 1 <- Home Team won, 0 <- Away Team won
ind_game_stats <- ind_game_stats %>% mutate(
  home_win = ifelse(home_team_score>away_team_score,1,0)
) %>% select(-away_int_re_number,home_int_re_number,home_kick_re_number)


ind_game_stats <- as.data.frame(lapply( ind_game_stats, function(x) ifelse(is.nan(x),0,x)))
ind_game_stats <- as.data.frame(lapply(ind_game_stats, as.numeric))
ind_game_stats <- as.data.frame(lapply( ind_game_stats, function(x) ifelse(is.nan(x),0,x)))

write.csv(ind_game_stats,"data/ind_game_data.csv",row.names=FALSE)
write.csv(team_stats_test,"data/team_stats_clean.csv",row.names=FALSE)