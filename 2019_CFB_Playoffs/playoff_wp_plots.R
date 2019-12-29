library(cfbscrapR)
library(ncaahoopR)
library(dplyr)

lsu_ou = cfb_pbp_data(2019,season_type = 'postseason', week=1,team='LSU',epa_wpa = T)
lsu_color = c("LSU" = ncaa_colors$primary_color[ncaa_colors$ncaa_name=='LSU'])
ou_color = c("OU" = ncaa_colors$primary_color[ncaa_colors$ncaa_name=='Oklahoma'])
plot_wpa(lsu_ou,away_color=ou_color,home_color=lsu_color,winner='home')
ggsave("lsu_wp.jpg",height=9/1.2,width=16/1.2)

lsu_ou_pbp = cfb_pbp_data(2019,season_type = 'postseason', week=1,team='LSU')
plot_pbp_sequencing(lsu_ou_pbp)
ggsave("lsu_pbp.jpg",height=9/1.2,width=16/1.2)



cle_osu = cfb_pbp_data(2019,season_type='postseason',week=1,team='Clemson',epa_wpa=T)
cle_color = c("CLE" = ncaa_colors$primary_color[ncaa_colors$ncaa_name=='Clemson'])
osu_color = c("OSU" = ncaa_colors$primary_color[ncaa_colors$ncaa_name=='Ohio St.'])
plot_wpa(cle_osu,away_color=cle_color,home_color = osu_color,winner='away')
ggsave("cle_wp.jpg",height=9/1.2,width=16/1.2)

cle_osu_pbp = cfb_pbp_data(2019,season_type='postseason',week=1,team='Clemson')
plot_pbp_sequencing(cle_osu_pbp)
ggsave("cle_pbp.jpg",height=9/1.2,width=16/1.2)


bowls = cfb_pbp_data(2019,season_type = 'postseason',week=1,epa_wpa = T)

wp_delt = bowls %>% group_by(game_id,home,away) %>% 
  arrange(new_id,.by_group=T) %>% 
  mutate(
    wp_delta = c(0,abs(diff(away_wp)))
  ) %>% summarize(
    EF = sum(wp_delta)
  ) %>% arrange(-EF)
