## Create DataFrame of Bowl game matchups, and corresponding stats. 
## Scrape list of bowl games
library(rvest)
library(tidyverse)
team_stats <- read_csv("data/final_data/team_games_data.csv")
bowl_game_url <- read_html("https://www.sports-reference.com/cfb/years/2018-bowls.html")
bowl_games = bowl_game_url %>% html_nodes("#bowls") %>% html_table()
bowl_games_df = bowl_games[[1]]
colnames(bowl_games_df) <- c("Date","Time","Bowl",
                             "Team1","Tm1_Pts","Team2","Tm2_Pts","Notes","TV")
bgames_df <- bowl_games_df %>% select(-Tm1_Pts,-Tm2_Pts,-Notes,-TV)

#team_stats <- read_csv("data/team_stats_clean.csv")

team1_lst <- bgames_df$Team1
team2_lst <- bgames_df$Team2

team_lst <- unique(team_stats$Team1)

team1_lst <- gsub("State","St.",team1_lst)
team1_lst <- gsub("Central Florida","UCF",team1_lst)
team1_lst <- gsub("North Carolina St.","NC State",team1_lst)
#team1_lst <- gsub("Army","Army West Point",team1_lst)
team1_lst <- gsub("Brigham Young","BYU",team1_lst)
team1_lst <- gsub("Florida International","FIU",team1_lst)
team1_lst <- gsub("Alabama-Birmingham","UAB",team1_lst)
team1_lst <- gsub("Eastern Michigan","Eastern Mich.",team1_lst)
team1_lst <- gsub("Iowa St.","Iowa State",team1_lst)
team1_lst <- gsub("Michigan St.","Michigan State",team1_lst)
team1_lst <- gsub("Arkansas St.","Arkansas State",team1_lst)
team1_lst <- gsub("Boise St.","Boise State",team1_lst)
team1_lst[team1_lst == "Miami (FL)"] = "Miami (Fla.)"


team1_ind <- which(is.na(match(team1_lst,team_lst)))
team1_lst[team1_ind]





team2_ind <- which(is.na(match(team2_lst,team_lst)))
team2_lst[team2_ind]

team2_lst <- gsub("State","St.",team2_lst)
team2_lst <- gsub("Louisiana St.","LSU",team2_lst)
team2_lst <- gsub("Texas Christian","TCU",team2_lst)
team2_lst <- gsub("Western Michigan","Western Mich.",team2_lst)
team2_lst <- gsub("South Florida","South Fla.",team2_lst)
team2_lst <- gsub("Northern Illinois","Northern Ill.",team2_lst)
team2_lst <- gsub("Georgia Southern","Ga. Southern",team2_lst)
team2_lst <- gsub("Middle Tennessee St.","Middle Tenn.",team2_lst)
team2_lst <- gsub("Oklahoma St.","Oklahoma State",team2_lst)
team2_lst <- gsub("Utah St.","Utah State",team2_lst)
team2_lst <- gsub("San Diego St.","San Diego State",team2_lst)
team2_lst <- gsub("Fresno St.","Fresno State",team2_lst)
team2_lst <- gsub("South Fla.","South Florida",team2_lst)

bgames_df$Team1 <- team1_lst
bgames_df$Team2 <- team2_lst

write_csv(bgames_df,"data/bowl_sched.csv")

#### Find a better way to combine stats for teams when guessing bowl games
