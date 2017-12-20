library(plyr)
library(dplyr)
library(reshape2)
library(ggplot2)
library(tidyr)
library(lubridate)

## Prepare overall team stats
## Use this as a prediction set. 
team_stats <- read.csv(file="tstats_data.tsv", sep="\t", header=TRUE, na.strings="?",stringsAsFactors = FALSE)
ts <- team_stats %>% filter(stats != 'Stat') %>% select(team,stats,value)
team_stats <- spread(ts, stats, value)
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

record_data <- read.csv(file="record_data.tsv", sep="\t", header=TRUE, na.strings="?",stringsAsFactors = FALSE)
record_data$games <- with(record_data, win+losses)
record_data <- record_data %>% select(team,games)

team_stats <- merge(team_stats,record_data,by="team")
## Filter Team Stats as neccessary 
team_stats_test <- team_stats %>% select(team,games, X3rd.Down.Conversion.Pct,X4th.Down.Conversion.Pct,Fewest.Penalties.Per.Game,Fewest.Penalty.Yards.Per.Game,First.Downs.Offense,Kickoff.Returns, Net.Punting,Passing.Offense,Punt.Returns,Rushing.Offense,Scoring.Offense,Turnover.Margin,Total.Offense)
team_stats_test$First.Downs.Offense <- with(team_stats_test,First.Downs.Offense/games)
team_stats_test$games <- NULL
colnames(team_stats_test) <- c("away_team","away_third_down_conv_pct","away_fourth_down_conv_pct", "away_pen_number","away_pen_yds","away_first_downs","away_kick_re_yds","away_pun_yds","away_pass_yds","away_pun_re_yds","away_rushing_yds","away_team_score","away_turnover_margin","away_tot_offense")

write.csv(team_stats_test,file="tstats_clean_data.csv")

### Individual game_data
game_stats <- read.csv(file="game_data.tsv", sep="\t", header=TRUE, na.strings="?",row.names = NULL,stringsAsFactors = FALSE)
colnames(game_stats)[1:61] <- colnames(game_stats)[2:62]
#colnames(game_stats)[31] <- "away_fourth_down_suc"
game_stats[,62] <- NULL
game_stats$away_third_down_conv_pct <- with(game_stats,away_third_down_suc/away_third_down_attempts)
game_stats$home_third_down_conv_pct <- with(game_stats,home_third_down_suc/home_third_down_attempts)

game_stats$away_fourth_down_conv_pct <- with(game_stats,away_fourth_down_suc/away_fourth_down_attempts)
game_stats$home_fourth_down_conv_pct <- with(game_stats,home_fourth_down_suc/home_fourth_down_attempts)

game_stats$away_turnover_margin <- with(game_stats, away_fumbles_lost+away_passing_interceptions-(home_fumbles_lost+home_passing_interceptions))

game_stats$home_turnover_margin <- -1 * game_stats$away_turnover_margin

## Individual game_scores 
game_scores <- read.csv(file="game_score.tsv", sep="\t", header=TRUE, na.strings="?",row.names = NULL,stringsAsFactors = FALSE)
colnames(game_scores)[1:5] <-colnames(game_scores)[2:6] 
game_scores[,6] <- NULL
game_scores <- game_scores %>% select(game_id,away_team_score,home_team_score)

## Merge game_data and game_scores
game_stats_select <- game_stats %>% select(game_id, away_team_id,away_team,home_team_id,home_team,away_first_downs,away_rushing_yds,away_pass_yds,away_tot_offense,away_turnover_margin,away_pen_number,away_pen_yds,away_pun_yds,away_pun_re_yds,away_kick_re_yds,away_int_re_number,away_third_down_conv_pct,away_fourth_down_conv_pct,home_first_downs,home_rushing_yds,home_pass_yds,home_tot_offense,home_turnover_margin,home_pen_number,home_pen_yds,home_pun_yds,home_pun_re_yds,home_kick_re_number,home_kick_re_yds,home_int_re_number,home_third_down_conv_pct,home_fourth_down_conv_pct)
ind_game_stats <- merge(game_stats_select,game_scores,by="game_id")

ind_game_stats <- ind_game_stats[,-c(1:2,4)]
# 1 <- Home Team won, 0 <- Away Team won
ind_game_stats$home_win <- ifelse(ind_game_stats$home_team_score > ind_game_stats$away_team_score,1,0)
#ind_game_stats$home_win <- as.factor(ind_game_stats$home_win)
ind_game_stats$away_int_re_number <- NULL
ind_game_stats$home_int_re_number <- NULL
ind_game_stats$home_kick_re_number <- NULL

ind_game_stats <- as.data.frame(lapply( ind_game_stats, function(x) ifelse(is.nan(x),0,x)))

## Save RDS 
saveRDS(ind_game_stats,file="Ind_game_data.RDS")
saveRDS(team_stats_test,file="Team_stats.RDS")
