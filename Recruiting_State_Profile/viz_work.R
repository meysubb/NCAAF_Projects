library(tidyverse)
library(cfbscrapR)
library(ggmap)
library(ggridges)
library(ggrepel)
library(patchwork)



years <- 2000:2020

year_df <- as.data.frame(years)
colnames(year_df) <- "year"

recruiting_info <- year_df %>%
  mutate(
    rec_info = purrr::map(year,cfb_recruiting_player)
  )

recruiting_raw <- recruiting_info %>% tidyr::unnest() %>%
  mutate(
    blue_chip = if_else(stars>=4,T,F)
  )

state_viz <- function(raw_recruit_df,state_abbr,min_year,max_year){
  state_yrs <- recruiting_raw %>% filter(state_province==state_abbr,year>min_year)
  
  file_name <- paste0(state_abbr,"_lat_long.RDS")
  
  if(!file.exists(file_name)){
    ## use the us census geocoder and not google maps
    city_blue_chip <- state_yrs %>% group_by(city) %>%
      summarize(blue_cnt = sum(blue_chip)) %>%
      mutate(adr = paste0(city,", ",state_abbr),
             lat_long = geocode(adr))
    
    city_deets <- city_blue_chip %>% select(city,lat_long) 
    city_deets <- bind_cols(city_deets[1], reduce(city_deets[-1], tibble))
    saveRDS(city_deets,file_name)
  }
  if(file.exists(file_name)){
    city_deets <- readRDS(file_name)
  }
  
  state_yrs <- state_yrs %>% left_join(city_deets)
  blue_chip_state <- state_yrs %>% filter(blue_chip)

  ind = which(state.abb == state_abbr)
  state_name = state.name[ind]
  
  state_plot <- create_state_plot(state_name,blue_chip_state)
  bubble_plot <- create_bubble_plot(blue_chip_state,state_yrs)
  density_plot <- create_density_plot(state_yrs)
  
  ## combine final plot
  #p = state_plot | (bubble_plot / density_plot) 
  p = state_plot / (bubble_plot | density_plot)
  
  p + plot_annotation(title = paste0(state_name,' Recruiting Profile'), 
                      caption = '@msubbaiah1',
                      theme = theme(plot.title = element_text(size = 20)))
}


create_state_plot <- function(state_name,state_recruit_blue_chip_data){
  state_plot_df = map_data('state', region = state_name)
  
  # where are blue chip recruits going
  plot <- ggplot() + 
    geom_polygon(data=state_plot_df, aes(x=long, y=lat,group=group),colour="black", fill="white" ) + 
    stat_bin_hex(data=state_recruit_blue_chip_data,aes(x=lon,y=lat)) + 
    scale_fill_viridis_c(
      option="B",
    ) +  
    labs(title = "Where do blue chip recruits come from?") + 
    theme_void(base_size = 16) 
  return(plot)
}
  
create_bubble_plot <- function(state_recruit_blue_chip_data,state_recruit_total_data){
  # what top schools are dominating the state
  blue_chip_schools <-
    state_recruit_blue_chip_data %>% group_by(committed_to) %>%
    summarise(cnt = n()) %>% ungroup() %>%
    mutate(pct = cnt / sum(cnt),
           rank = rank(desc(pct))) %>% filter(!is.na(committed_to)) %>% arrange(pct) %>%
    mutate(team_names = fct_inorder(committed_to)) %>% filter(rank <= 10)
  
  schools <- state_recruit_total_data %>% group_by(committed_to) %>%
    summarise(cnt = n()) %>% ungroup() %>%
    mutate(pct = cnt / sum(cnt),
           rank = rank(pct)) %>% filter(!is.na(committed_to)) %>% arrange(pct) %>%
    mutate(team_names = fct_inorder(committed_to))
  
  colnames(schools)[2:3] <- paste0("all_",colnames(schools)[2:3])
  
  blue_chip_schoolsv2 <- blue_chip_schools %>% left_join(schools %>% select(-rank,-committed_to))
  
  max_x <- max(blue_chip_schoolsv2$all_cnt)
  min_x <- max(blue_chip_schoolsv2$cnt)
  
  plot <- ggplot() +
    # remove axes and superfluous grids
    theme_classic(base_size = 16) +
    theme(
      axis.title = element_blank(),
      axis.ticks.y = element_blank(),
      axis.line = element_blank()
    ) +
    # add a dummy point for scaling purposes
    geom_point(
      data = blue_chip_schoolsv2,
      aes(x = nrow(blue_chip_schoolsv2) - 1, y = team_names),
      size = 0,
      col = "white"
    ) +
    # add the horizontal discipline lines
    geom_hline(yintercept = 1:nrow(blue_chip_schoolsv2),
               col = "grey80") +
    # add a point for each male success rate
    geom_point(
      data = blue_chip_schoolsv2,
      aes(x = cnt, y = team_names),
      size = 11,
      col = "#9DBEBB"
    )  +
    geom_point(
      data = blue_chip_schoolsv2,
      aes(x = all_cnt, y = team_names),
      size = 11,
      col = "#468189"
    ) +
    geom_text(data = blue_chip_schoolsv2,
              aes(x = cnt, y = team_names,
                  label = cnt),
              col = "black") +
    geom_text(data = blue_chip_schoolsv2,
              aes(x = all_cnt, y = team_names,
                  label = all_cnt),
              col = "black") +
    geom_text(aes(
      x = x,
      y = y,
      label = label,
      col = label
    ),
    data.frame(
      x = c(min_x, max_x),
      y = nrow(blue_chip_schoolsv2) + 1,
      label = c("Blue Chip", "Total")
    ),
    size = 6) +
    scale_color_manual(values = c("#9DBEBB", "#468189"), guide = "none") +
    scale_y_discrete(expand = c(0.2, 0)) +
    labs(title = "Where do recruits go?") 
  return(plot)
}
  
create_density_plot <- function(state_recruit_total_data){
  team_info <- cfb_team_info()
  logos <- team_info %>% unnest_wider(logos,names_sep = "_") %>% select(school,logo = logos_1)
  # distribution of talent in the state
  rec_plot_data <- state_recruit_total_data %>%
    left_join(logos, by = c("committed_to" = "school")) %>%
    mutate(position = case_when(position == "DUAL" ~ "QB",
                                position == "PRO" ~ "QB",
                                position == "OT" ~ "OL",
                                position == "OG" ~ "OL",
                                position == "OC" ~ "OL",
                                position == "LS" ~ "OL",
                                position == "APB" ~ "RB",
                                position == "FB" ~ "RB",
                                position == "OLB" ~ "LB",
                                position == "ILB" ~ "LB",
                                position == "WDE" ~ "DE",
                                position == "SDE" ~ "DE",
                                position == "P" ~ "P/K",
                                position == "K" ~ "P/K",
                                TRUE ~ position),
           position = factor(position,
                             levels = c("QB","RB","WR","TE",
                                        "ATH","OL","DE","DT",
                                        "LB","CB","S","P/K")))
  
  max <- rec_plot_data %>% group_by(year,position) %>% filter(rating == max(rating))
  
  plot <- rec_plot_data %>%
    ggplot(aes(x = rating,y = reorder(position, desc(position)),fill=position)) +
    facet_wrap(~year1) + 
    geom_density_ridges(jittered_points = TRUE,alpha=0.7)  + 
    theme_ridges( center_axis_labels = TRUE) + 
    scale_fill_discrete(guide=FALSE) + 
    ggimage::geom_image(data = max,
                        aes(image = logo),
                        asp = 1.618 , size = .07) + 
    labs(y="",x="247 Sports Composite ")
  return(plot)
}