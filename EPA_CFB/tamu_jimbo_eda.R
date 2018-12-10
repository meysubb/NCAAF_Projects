teams_df <- readRDS("data/team_df.RDS")
library(RPostgreSQL)
library(dplyr)

dbname <- "cfb"
user <- "meyappansubbaiah"
host <- "localhost"


pg = dbDriver("PostgreSQL")

con = dbConnect(pg, user, password="",
                host="localhost", port=5432, dbname)


drive_query <- paste0("SELECT gt.game_id, d.offense_id, d.defense_id, d.scoring, d.start_yardline, d.end_yardline, d.plays,d.yards,dr.name, d.start_time, d.end_time,d.id as drive_id
FROM game_team gt
                      LEFT JOIN game g ON (gt.game_id = g.id)
                      LEFT JOIN drive d ON (gt.game_id = d.game_id)
                      LEFT JOIN drive_result dr ON (d.result_id = dr.id)
                      WHERE season>=2010 AND team_id in (",paste(teams_df$id,collapse=","),")")

drives_df = dbGetQuery(con, drive_query)
# jimbo_clean_drives <- jimbo_drives_fsu %>% filter( (!str_detect(name, 'END')),offense_id==52)


play_query <- paste("SELECT gt.game_id, p.offense_id, p.defense_id, p.home_score,p.away_score,p.period,p.clock,p.distance,p.down,p.yard_line,p.yards_gained,p.scoring,p.play_text,pt.text, d.id as drive_id
FROM game_team gt
                    LEFT JOIN game g ON (gt.game_id = g.id)
                    LEFT JOIN drive d ON (gt.game_id = d.game_id)
                    LEFT JOIN play p ON (d.id = p.drive_id)
                    LEFT JOIN play_type pt ON (p.play_type_id = pt.id)
                    WHERE season>=2010 AND team_id in (",paste(teams_df$id,collapse=","),")")
plays_df <- dbGetQuery(con,play_query)

# jimbo_plays <- jimbo_plays %>% group_by(drive_id) %>% mutate(
#   row_n = row_number()
# ) %>% filter( row_n==n()) %>% select(drive_id,home_score,away_score,period)

to_types <- c("FUMBLE","INT","INT TD","FUMBLE TD","FUMBLE RETURN TD")

## check for safety's and add two points for that
library(stringr)
fsu_j <- drives_df %>% inner_join(plays_df) %>% ungroup() %>% select(game_id,drive_id,offense_id,defense_id,scoring,name,home_score,away_score,start_time,end_time,period,plays) %>% mutate(
  turnovers = name %in% to_types,
  score_off_to = lead(scoring) & turnovers,
  score_type = ifelse(str_detect(name,"FG"),3,ifelse(str_detect(name,"TD"),7,0)),
  score_type = ifelse(scoring,score_type,0),
  to_score = ifelse(turnovers,lead(score_type),0)
)

### Remove the end of half and end of game records
### Maybe take this from the last play (name) and find a way to combine the two columns
### remove these drives (because thy aren't useful unless scoring and its close?)
### Identify the type of scores, so you can add up how much they scored
### maybe the other goal is to see scored possessions vs wasted possessions

test <- fsu_j %>% group_by(offense_id) %>% summarize(
  drives = n(),
  to = sum(turnovers),
  pts_given_off_to=sum(to_score),
  pts_scored = sum(score_type))


### Create Functions, and find ways to create a true number etc. 