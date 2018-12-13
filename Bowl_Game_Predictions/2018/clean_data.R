library(tidyverse)
library(lubridate)
library(reshape2)
library(ggplot2)

## Prepare overall team stats
## Use this as a prediction set. 
clean_dat <- function(team_stats,record_data,game_stats,game_scores){
  team_stats <- team_stats %>% filter(stats != 'Stat') %>% select(team,stats,value)
  
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
  
  ### include record data
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
  
  colnames(team_stats_test)[2:14] <- paste0("Team1_",colnames(team_stats_test)[2:14]) 
  
  colnames(game_stats)[1:61] <- colnames(game_stats)[2:62]
  game_stats[,62] <- NULL
  
  game_stats <- game_stats %>% 
    mutate(away_third_down_conv_pct = away_third_down_suc/away_third_down_attempts,
           home_third_down_conv_pct = home_third_down_suc/home_third_down_attempts,
           away_fourth_down_conv_pct = away_fourth_down_suc/away_fourth_down_attempts,
           home_fourth_down_conv_pct = home_fourth_down_suc/home_fourth_down_attempts,
           away_turnover_margin = away_fumbles_lost+away_passing_interceptions-(home_fumbles_lost+home_passing_interceptions),
           home_turnover_margin = -1 * away_turnover_margin)
  
  colnames(game_scores)[1:5] <-colnames(game_scores)[2:6] 
  game_scores[,6] <- NULL
  
  game_scores <- game_scores %>% select(game_id,away_team_score,home_team_score)
  
  ## Merge game_data and game_scores
  ind_game_stats <- inner_join(game_scores,game_stats)
  
  ind_game_stats <- ind_game_stats %>% mutate(
    home_win = ifelse(home_team_score>away_team_score,1,0)
  ) %>% select(-away_int_re_number,home_int_re_number,home_kick_re_number)
  
  
  
  ind_game_stats <- ind_game_stats %>% mutate_if(is.numeric,function(x) ifelse(is.nan(x),0,x))
  
  cnames <- gsub("away","Team1",colnames(ind_game_stats))
  cnames <- gsub("home","Team2",cnames)
  cnames[c(5,34)] <- c("Team1","Team2")
  colnames(ind_game_stats) <- cnames
  
  final_rest <- list(ind_game_stats,team_stats_test)
  names(final_rest) <- c("Ind_Game","Avg_Team_Stats")
  
  return(final_rest)
}


### 2018

t_stats <- read_tsv(file="data/raw_data/tstats_data_18.tsv") 
r_data <- read_tsv(file="data/raw_data//record_data_18.tsv")
g_stats <- read.csv(file="data/raw_data/game_data_18.tsv",sep="\t",header=TRUE, 
                       na.strings="?",row.names = NULL,stringsAsFactors = FALSE)
g_scores <- read.csv(file="data/raw_data/game_score_18.tsv", sep="\t", header=TRUE, 
                        na.strings="?",row.names = NULL,stringsAsFactors = FALSE)

dat_18 <- clean_dat(t_stats,r_data,g_stats,g_scores)

t_stats <- read_tsv(file="data/raw_data/tstats_data_17.tsv") 
r_data <- read_tsv(file="data/raw_data//record_data_17.tsv")
g_stats <- read.csv(file="data/raw_data/game_data_17.tsv",sep="\t",header=TRUE, 
                       na.strings="?",row.names = NULL,stringsAsFactors = FALSE)
g_scores <- read.csv(file="data/raw_data/game_score_17.tsv", sep="\t", header=TRUE, 
                        na.strings="?",row.names = NULL,stringsAsFactors = FALSE)
dat_17 <- clean_dat(t_stats,r_data,g_stats,g_scores)

t_stats <- read_tsv(file="data/raw_data/tstats_data_16.tsv") 
r_data <- read_tsv(file="data/raw_data//record_data_16.tsv")
g_stats <- read.csv(file="data/raw_data/game_data_16.tsv",sep="\t",header=TRUE, 
                    na.strings="?",row.names = NULL,stringsAsFactors = FALSE)
g_scores <- read.csv(file="data/raw_data/game_score_16.tsv", sep="\t", header=TRUE, 
                     na.strings="?",row.names = NULL,stringsAsFactors = FALSE)
dat_16 <- clean_dat(t_stats,r_data,g_stats,g_scores)


ind_18 <- dat_18[[1]]
ind_17 <- dat_17[[1]]
ind_16 <- dat_16[[1]]

ind_game_stats <- rbind(ind_18,ind_17,ind_16)

write_csv(ind_game_stats,"data/final_data/all_games_16_18.csv")
write_csv(ind_18,"data/final_data/ind_games_18.csv")
