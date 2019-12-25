library(cfbscrapR)
# load for ncaa colors
library(ncaahoopR)
library(dplyr)
options(stringsAsFactors = F)

year = 2019
weeks = 1:14
teams = c("Ohio State", "Clemson", "Oklahoma", "LSU")
df = expand.grid(year, weeks, teams)
colnames(df) = c("year", "week", "team")
df$team <- as.character(df$team)

df2 = df %>% mutate(pbp = purrr::pmap(
  list(x = year,
       y = week,
       z = team),
  .f = function(x, y, z) {
    cfb_pbp_data(
      year = x,
      week = y,
      team = z,
      epa_wpa = T
    )
  }
))


df3 = df2 %>% tidyr::unnest(pbp)

df4 = df3 %>%
  mutate("team_win_prob" = case_when(home == team ~ home_wp,
                                     away == team ~ away_wp))


colors = ncaa_colors$primary_color[ncaa_colors$ncaa_name %in% c('Oklahoma', 'LSU', 'Clemson', 'Ohio St.')]

ggplot(df4, aes(x = adj_TimeSecsRem, y = team_win_prob)) +
  facet_wrap( ~ team) +
  geom_line(aes(group = game_id), alpha = 0.2) +
  geom_smooth(aes(color = team)) +
  scale_x_reverse(breaks = seq(0, 3600, 300)) +
  scale_y_continuous(labels = scales::percent) +
  scale_color_manual(values = colors) +
  theme_bw(base_size = 16) +
  theme(legend.position = "none") +
  labs(
    x = "Time Remaining (seconds)",
    y = "Win Probability",
    title = "Win Probability Over Course of the Season",
    caption = "Data from collegefootballdataAPI, Plot by @msubbaiah1"
  )
ggsave("cfp_teams.png", height = 9 / 1.2, width = 16 / 1.2)

