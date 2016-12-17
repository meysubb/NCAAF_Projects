setwd("/Users/meyappans/Desktop/CFB_Bowl/data")
# Non-Factor, Provides Win % Confidence
ind_game_stats <- readRDS(file="Ind_game_data.RDS")
ind_game_stats$away_team <- NULL
ind_game_stats$home_team <- NULL 
## Drop scores, as they are too influential in determing who wins
## If you don't drop this, model picks whoever scores more over the course of the 
## season. This isn't neccessarily who is going to win always. 
ind_game_stats$away_team_score <- NULL
ind_game_stats$home_team_score <- NULL
# Factor, Provides Win (Yes or No)
ind_game_stats_fac <- ind_game_stats
ind_game_stats_fac$home_win <- as.factor(ind_game_stats_fac$home_win)
## Load bowl_game data
bowl_game_stats <- readRDS(file="bowl_games.RDS")
sapply(bowl_game_stats,class)
gbm <- bowl_game_stats


### RF
library(randomForest)
fit <- randomForest(home_win ~ ., ind_game_stats,ntree=500,na.action = na.exclude)
fit_fac <- randomForest(home_win ~ ., ind_game_stats_fac,ntree=500,na.action = na.exclude)
summary(fit)
summary(fit_fac)
#Predict Output 
bowl_game_stats$home_win_pct <- as.vector(predict(fit,bowl_game_stats))
bowl_game_stats$home_win <- as.vector.factor(predict(fit_fac,bowl_game_stats))
bowl_game_stats$conf <- ifelse(bowl_game_stats$home_win == 1, bowl_game_stats$home_win_pct, 1-bowl_game_stats$home_win_pct)

### GBM
library(caret)
library(gbm)
fitControl <- trainControl( method = "repeatedcv", number = 4, repeats = 4)
gbm_fit_fac <- train(home_win ~ ., data = ind_game_stats_fac, method = "gbm", trControl = fitControl,verbose = FALSE,na.action = na.exclude)

predictions <- predict(gbm_fit_fac,bowl_game_stats,type= "prob") 
gbm <- cbind(gbm,predictions)
gbm$gbm_home_win <- ifelse(gbm$`1`>gbm$`0`,1,0)
gbm$gbm_win_pct <- ifelse(gbm$gbm_home_win == 1,gbm$`1`,gbm$`0`)

bowl_game_stats <- cbind(bowl_game_stats,gbm$gbm_home_win,gbm$gbm_win_pct)
colnames(bowl_game_stats)[32:33] <- c("gbm_home_win","gbm_win_pct")

library(dplyr)
bowl_final_pred <- bowl_game_stats %>% select(away_team,home_team,home_win,conf,gbm_home_win,gbm_win_pct)

saveRDS(bowl_final_pred,file="bowl_predictions.RDS")

#ind_game_stats$home_win <- as.factor(ind_game_stats$home_win) 
#bowl_games$away_team <- NULL
#bowl_games$home_team <- NULL
