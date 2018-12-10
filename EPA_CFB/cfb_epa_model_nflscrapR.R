library(collegeballR)
# year <- expand.grid(yrs=2010:2017,week=1:17)
# year <- year %>% mutate(
#   pbp = purrr::map2(yrs,week,cfb_pbp_data)
# )
#year_df <- year %>% tidyr::unnest(pbp)
#saveRDS(year_df,"data/api_pbpdata.RDS")

year_df <- readRDS("data/api_pbpdata.RDS")

## Process data further
td_plays <- unique(year_df$play_type)[stringr::str_detect(unique(year_df$play_type),"Touchdown")]
scoring_plays <- c(td_plays,"Field Goal Good","Safety")

library(tidyverse)
year_df <- year_df %>% mutate(
  scoring = play_type %in% scoring_plays,
  half = ifelse(period %in% c(1,2),1,2),
  score_type = ifelse(str_detect(play_type,"Field Goal Good"),3,ifelse(str_detect(play_type,"Touchdown"),7,0)),
  score_type = ifelse(str_detect(play_type,"Safety"),2,score_type),
  score_type = ifelse(scoring,score_type,0),
  id = as.numeric(id)
) 


df <- data.frame(years = 2010:2017)
schedule_df <- df %>% mutate(
     pbp = purrr::map(years,cfb_game_info))

schedule_df <- schedule_df %>% tidyr::unnest(pbp)
### Need to identify/create game_ids
### Do a fuzzy match


### Identify scoring plays
unique(year_df$id)
