library(plyr)
library(dplyr)
library(tidyr)
library(reshape)
library(reshape2)
library(ggplot2)
library(lubridate)

getwd()

team_stats_15 <- read.csv(file="2015/tstats_data.tsv", sep="\t", header=TRUE, na.strings="?",stringsAsFactors = FALSE)
summary_stats_15 <- read.csv(file="2015/summary_team_data.tsv", sep="\t", header=TRUE, na.strings="?",stringsAsFactors = FALSE)
record_stats_15 <- read.csv(file="2015/record_data.tsv", sep="\t", header=TRUE, na.strings="?",stringsAsFactors = FALSE)

team_stats_14 <- read.csv(file="2014/tstats_data.tsv", sep="\t", header=TRUE, na.strings="?",stringsAsFactors = FALSE)
summary_stats_14 <- read.csv(file="2014/summary_team_data.tsv", sep="\t", header=TRUE, na.strings="?",stringsAsFactors = FALSE)
record_stats_14 <- read.csv(file="2014/record_data.tsv", sep="\t", header=TRUE, na.strings="?",stringsAsFactors = FALSE)

team_stats_13 <- read.csv(file="2013/tstats_data.tsv", sep="\t", header=TRUE, na.strings="?",stringsAsFactors = FALSE)
summary_stats_13 <- read.csv(file="2013/summary_team_data.tsv", sep="\t", header=TRUE, na.strings="?",stringsAsFactors = FALSE)
record_stats_13 <- read.csv(file="2013/record_data.tsv", sep="\t", header=TRUE, na.strings="?",stringsAsFactors = FALSE)


ts_15_o <- team_stats_15 %>% filter(stats != 'Stat')  %>% select(team,stats,value)
ts_15_o <- spread(ts_15_o, stats, value)
ts_15_o <- merge(ts_15_o,record_stats_15,by.x="team")
colnames(summary_stats_15)[2] <- "team"
ts_15_o <- merge(ts_15_o,summary_stats_15,by.x="team")
ts_15_o$yr <- "2015"

#ts_15_d <- team_stats_15 %>% filter(stats != 'Stat')  %>% select(team,stats,value)
#ts_15_d <- spread(ts_15_d, stats, value)
#ts_15_d <- merge(ts_15_d,record_stats_15,by.x="team")
#ts_15_d$yr <- "2015"


# 2014 
ts_14_o <- team_stats_14 %>% filter(stats != 'Stat')  %>% select(team,stats,value)
ts_14_o <- spread(ts_14_o, stats, value)
ts_14_o <- merge(ts_14_o,record_stats_14,by.x="team")
colnames(summary_stats_14)[2] <- "team"
ts_14_o <- merge(ts_14_o,summary_stats_14,by.x="team")
ts_14_o$yr <- "2014"

#ts_14_d <- team_stats_14 %>% filter(stats != 'Stat')  %>% select(team,stats,value)
#ts_14_d <- spread(ts_14_d, stats, value)
#ts_14_d <- merge(ts_14_d,record_stats_14,by.x="team")
#ts_14_d$yr <- "2014"

# 2013 

ts_13_o <- team_stats_13 %>% filter(stats != 'Stat')  %>% select(team,stats,value)
ts_13_o <- spread(ts_13_o, stats, value)
ts_13_o <- merge(ts_13_o,record_stats_13,by.x="team")
colnames(summary_stats_13)[2] <- "team"
ts_13_o <- merge(ts_13_o,summary_stats_13,by.x="team")
ts_13_o$yr <- "2013"

#ts_13_d <- team_stats_13 %>% filter(stats != 'Stat')  %>% select(team,stats,value)
#ts_13_d$yr <- "2013"
#ts_13_d <- spread(ts_13_d, stats, value)
#ts_13_d <- merge(ts_13_d,record_stats_13,by.x="team")



### Combine Defense and Offense 
o_string <- colnames(ts_13_o)
offense <- merge(ts_15_o,ts_14_o,by=o_string,all=TRUE)
offense <- merge(offense,ts_13_o,by=o_string,all=TRUE)

#d_string <- colnames(ts_13_d)
#defense <- merge(ts_15_d,ts_14_d,by=d_string,all=TRUE)
#defense <- merge(defense,ts_13_d,by=d_string,all=TRUE)

### Clean up workspace/memory
keep <- "offense"
all_vars <- as.data.frame(ls())
colnames(all_vars) <- "var"
purge_vars <- all_vars %>% filter( !(var %in% keep))
rm(all_vars)
for(i in 1:nrow(purge_vars)){
  rm(list = as.character(purge_vars[i,]))
}
rm(purge_vars)

### Move column to last 
movetolast <- function(data, move) {
  data[c(setdiff(names(data), move), move)]
}

#defense <- movetolast(defense,"Time of Possession")
#colnames(defense)[ncol(defense)] <- "T.O.P"
offense <- movetolast(offense,"Time of Possession")
colnames(offense)[ncol(offense)] <- "T.O.P"

## Remove commas
comma_vars <- c("Net_Rush_Yds","Pass_Yds","Plays","opp_Net_Rush_Yds","opp_Pass_Yds","opp_Plays")
offense[,comma_vars] <- lapply(offense[, comma_vars], function(x) gsub(",","",x))

### Change variable types from Characters to Numeric 
len <- ncol(offense)-2
character_vars <- colnames(offense)[2:len]
offense[, character_vars] <- lapply(offense[, character_vars], as.numeric)
offense$T.O.P <- as.POSIXlt(offense$T.O.P, format = "     %M:%S")
t.lub <- ymd_hms(offense$T.O.P)
m.lub <- minute(t.lub) + second(t.lub)/60
offense$T.O.P <- m.lub
colnames(offense) <- make.names(colnames(offense))



#len <- ncol(defense) - 2
#character_vars <- colnames(defense)[2:len]
#defense[,character_vars] <- lapply(defense[, character_vars], as.numeric)
#defense$T.O.P <- as.Date(defense$T.O.P)
#defense$T.O.P <- as.POSIXlt(defense$T.O.P, format = "     %M:%S")
#t.lub <- ymd_hms(defense$T.O.P)
#m.lub <- minute(t.lub) + second(t.lub)/60
#defense$T.O.P <- m.lub
#colnames(defense) <- make.names(colnames(defense))


### Define Conferences 

Pac_12 <- c("Arizona","Arizona St.","California","Colorado","Oregon",
            "Oregon St.","Stanford","UCLA","Southern California","Utah",
            "Washington","Washington St.")
SEC <- c("Alabama","Arkansas","Auburn","Florida","Georgia","Kentucky",
         "LSU","Ole Miss","Mississippi St.","Missouri","South Carolina",
         "Texas A&M","Tennessee","Vanderbilt")
ACC <- c("Boston College","Clemson","Duke","Florida St.","Georgia Tech",
         "Louisville","Miami (FL)","North Carolina","North Carolina St.",
         "Notre Dame","Pittsburgh","Syracuse","Virginia","Virginia Tech",
         "Wake Forest")
Big_12 <- c("Baylor","Iowa St.","Kansas","Kansas St.","Oklahoma","Oklahoma St.",
            "Texas","TCU","Texas Tech","West Virginia")
Big_10 <- c("Illinois","Indiana","Iowa","Maryland","Michigan","Michigan St.",
            "Minnesota","Nebraska","Northwestern","Ohio St.","Penn St.",
            "Purdue","Rutgers","Wisconsin")



offense <- offense %>% mutate(Conference = ifelse(team %in% Pac_12, "Pac-12",
                                       ifelse(team %in% Big_12, "Big-12",
                                              ifelse(team %in% ACC, "ACC",
                                                     ifelse(team %in% Big_10, "Big-10",
                                                            ifelse(team %in% SEC, "SEC",        
                                                                   "Non-Power-5"  ))))))


#defense <- defense %>% mutate(Conference = ifelse(team %in% Pac_12, "Pac-12",
#                                                  ifelse(team %in% Big_12, "Big-12",
#                                                         ifelse(team %in% ACC, "ACC",
#                                                                ifelse(team %in% Big_10, "Big-10",
#                                                                       ifelse(team %in% SEC, "SEC",        
#                                                                              "Non-Power-5"  ))))))

### Filter by colnames 
colnames(offense)


offense_cols <- c("team","team_id","yr","team_games","win","losses","Conference",
                  "Tot_Off_Yards_Per_Game","Passing.Offense","Rushing.Offense","Scoring.Offense",
                  "Plays","Yds_Per_Play","Penalties","Penalties_Per_Game","Penalties_Yds_Per_Game",
                  "X3rd.Down.Conversion.Pct","X4th.Down.Conversion.Pct","First.Downs.Offense","Red.Zone.Offense",
                  "Team.Passing.Efficiency","Turnover.Margin","T.O.P")
defense_cols <- c("team","team_id","yr","team_games","win","losses","Conference",
                  "opp_Tot_Off_Yards_Per_Game","Passing.Yards.Allowed","Rushing.Defense","Scoring.Defense",
                  "opp_Plays","opp_Yds_Per_Play","opp_Penalties","opp_Penalties_Per_Game","opp_Penalties_Yds_Per_Game",
                  "X3rd.Down.Conversion.Pct.Defense","X4th.Down.Conversion.Pct.Defense","First.Downs.Defense","Red.Zone.Defense",
                  "Team.Passing.Efficiency.Defense","Turnover.Margin","T.O.P")
spteams_cols <- c("team","team_id","yr","team_games","win","losses","Conference",
                  "Kickoff.Returns","Punt.Returns","Net.Punting",
                  "Penalties","Penalties_Per_Game","Penalties_Yds_Per_Game",
                  "opp_Plays","opp_Yds_Per_Play","opp_Penalties","opp_Penalties_Per_Game","opp_Penalties_Yds_Per_Game",
                  "Turnover.Margin","T.O.P")

offense_1 <- offense %>% select( which(names(offense) %in% offense_cols))
defense <- offense %>% select( which(names(offense) %in% defense_cols))
special_teams <- offense %>% select( which(names(offense) %in% spteams_cols))
### Save data in RDS format 
setwd("~/Desktop/CFB_Data/R_Data")
saveRDS(defense,file="Def_Data.rds")
saveRDS(offense_1, file="Off_Data.rds")
saveRDS(special_teams, file="Sp_Teams.rds")


