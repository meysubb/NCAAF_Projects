scored_drives <- drives_df %>% inner_join(plays_df) %>% ungroup() %>% select(game_id,drive_id,offense_id,defense_id,scoring,name,home_score,away_score,start_time,end_time,period,plays) %>% mutate(
  score_type = ifelse(str_detect(name,"FG"),3,ifelse(str_detect(name,"TD"),7,0)),
  score_type = ifelse(scoring,score_type,0)
) %>% filter(scoring==T) %>% select(drive_id,score_type)

#### need to clean this up, its acting weird. 
identify_scores <- plays_df %>% left_join(scored_drives) %>% mutate(
  score_type = ifelse(scoring==T,score_type,0)
) %>% select(down,distance,yard_line,score_type,scoring,game_id,offense_id,defense_id) %>% filter(down>0 & distance>0)

calculate_epa <- function(df,team_id,team=F){
  ### identify all scored plays
  ### maybe do this per team? or something?
  ### think about how to scale this up
  ### need to come back to this, only lift up points if it belongs to the same game
  empty_df <- data.frame()
  scor_ind <- which(df$scoring==TRUE)
  for(i in scor_ind) {
    ## if first index in scor_ind
    if(which(i==scor_ind)==1){
      subset_df <- df[1:i,]
      score <- subset_df %>% filter(scoring==T) %>% select(score_type) %>% pull()
      subset_df$epa <- score
      sum_df <- subset_df %>% select(-scoring) %>%
        group_by(down,distance,yard_line) %>% 
        summarize(
          sum_pts = sum(epa),
          cnt = n())
    }else{
      i_prev <- scor_ind[which(i==scor_ind) - 1] + 1
      subset_df <- df[i_prev:i,]
      score <- subset_df %>% filter(scoring==T) %>% select(score_type) %>% pull()
      ## deals with scoring events that occur in different games 
      ## example what if there is no score after a few drives in the 4th, next scoring 
      ## opportunity occurs in the next game, so we use this to filter it out
      ### game in which they scored
      game <- subset_df %>% filter(scoring==T) %>% select(game_id) %>% pull()
      ### which team scored
      offense <- subset_df %>% filter(scoring==T) %>% select(offense_id) %>% pull()
      ## initialize all as 0
      subset_df$epa <- 0
      offense_score <- (subset_df$game_id) == game & (subset_df$offense_id == offense)
      defense_score <- !offense_score
      subset_df[offense_score,"epa"] <- score
      subset_df[defense_score,"epa"] <- -1 * score
      ### Filte for your team (if you are being team specific)
      if(team){
        subset_df <- subset_df %>% filter(offense_id==team_id)
      }
      sum_df <- subset_df %>% select(-scoring) %>%
        group_by(down,distance,yard_line) %>% 
        summarize(
          sum_pts = sum(epa),
          cnt = n())
    }
    empty_df <- bind_rows(empty_df,sum_df)
    }
  return(empty_df)
}

test <- calculate_epa(identify_scores,team_id = 52)
### need to verify if this works. and from here process it
test_more <- test %>% group_by(down,distance,yard_line) %>% 
  summarise_all(funs(sum(.,na.rm = T))) %>% mutate(avg_pts = sum_pts/cnt)

first_downs <- test_more 
s <- loess(avg_pts ~ yard_line, data=first_downs)
pred_s <- predict(s)

plot(x=first_downs$yard_line,y=first_downs$avg_pts, type="p", main="Loess Smoothing and Prediction", xlab="Yards", ylab="EPA")
lines(pred_s, x=first_downs$distance, col="red")
