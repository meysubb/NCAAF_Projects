### Scrape for conference affiliations
library(rvest)
library(stringr)
cfb_url <- "http://stats.ncaa.org/team/schedule_list?academic_year=2018&division=11.0&id=12623&sport_code=MFB"

all_conf <- read_html(cfb_url) %>% html_nodes(".level2 a") %>% html_text() 
conf <- all_conf[175:186]
all_conf_urls <- read_html(cfb_url) %>% html_nodes(".level2 a") %>% html_attr("href")
conf_url <- all_conf_urls[175:186]
conf_url <- str_extract(conf_url,"[0-9]+")


options(stringsAsFactors = FALSE)
conf_df <- data.frame(conf,urls=paste0("http://stats.ncaa.org/team/inst_team_list?academic_year=2018&conf_id=",conf_url,"&division=11&sport_code=MFB"))

### Get list of teams
team_name_conf <- function(ur){
  read_html(ur) %>% html_nodes(".css-panes a") %>% html_text()
}


t <- conf_df %>%
  mutate(teams = purrr::map(urls,team_name_conf))

team_conf <- t %>% select(conf,teams) %>% tidyr::unnest()

p5 <- team_conf %>% filter(conf %in% c("ACC","Big 12","Big Ten","SEC","Pac-12"))

query <- paste0("SELECT id,school,ncaa_name
          FROM team
          WHERE ncaa_name in (",paste(shQuote(p5$teams),collapse = ","),")", "OR school in (",paste(shQuote(p5$teams),collapse = ","),")")

sql_teams <- dbGetQuery(con,query)
saveRDS(sql_teams,"data/team_df.RDS")
### Use the sql_teams dataframe to query all plays/drives from p5. 