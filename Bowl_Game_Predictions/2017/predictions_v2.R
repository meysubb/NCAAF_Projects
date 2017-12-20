library(tidyverse)

ind_game <- read_csv("data/ind_game_data.csv") %>% 
  select(-c(away_team,home_team,away_team_score,home_team_score)) %>% 
  mutate(home_win=as.factor(home_win)) %>% na.omit()

bowl_games <- read_csv("data/bowl_games.csv") 
match_cols <- intersect(colnames(ind_game),colnames(bowl_games))

bowl_games_df <- bowl_games %>% 
  select(-c(away_team,home_team,away_team_score,home_team_score)) %>% 
  select(match_cols)

ind_game_df <- ind_game %>% select(match_cols,home_win)


## Random Forest
## Train/Test Split
set.seed(22) 
sample <- sample.int(n = nrow(ind_game_df), size = floor(.75*nrow(ind_game_df)), replace = F)
train <- ind_game_df[sample, ]
test  <- ind_game_df[-sample, ]

y <- "home_win"
x <- setdiff(names(ind_game_df), y) 

library(h2o)
h2o.init(nthreads = 3, max_mem_size = "6G") 
### Tuning parameters
tunegrid <- expand.grid(.mtry=c(12,15,20), .ntree=c(200,500, 700),.min_rows=c(5,7,10))
tunegrid$acc <- 0

dat_tr <- as.h2o(train)
dat_ts <- as.h2o(test)

for(i in 1:nrow(tunegrid)){
  mtries <- tunegrid$.mtry[i]
  num_trees <- tunegrid$.ntree[i]
  min_rows <- tunegrid$.min_rows[i]
  ptr_statement <- paste0("Working on ",i/nrow(tunegrid)*100, "%", sep=" ")
  
  
  print(ptr_statement)
  rf_fit1 <- h2o.randomForest(x = x,
                              y = y,
                              training_frame = dat_tr,
                              model_id = "rf_fit1",
                              seed = 1,
                              ntrees = num_trees,
                              mtries = mtries,
                              min_rows = min_rows)
  
  y_pred <- h2o.predict(rf_fit1,
                  newdata = dat_ts)
  
  y_pred_df <- as_data_frame(y_pred)
  conf_mat <- table(test$home_win,y_pred_df$predict)
  tunegrid$acc[i] <- sum(diag(conf_mat))/sum(conf_mat)
}

## Best Model accuracy is 15,700,5 (mtry,ntree,min_rows)
best_rf_mod <- h2o.randomForest(x=x,
                                y=y,
                                training_frame = as.h2o(ind_game_df),
                                seed =1,
                                ntrees = 700,
                                mtries=15,
                                min_rows=5)

pred <- h2o.predict(best_rf_mod,
            newdata=as.h2o(bowl_games_df))
pred_df <- as.data.frame(pred)
pred_df <- pred_df %>% mutate(conf = abs(p1 - p0))
colnames(pred_df) <- paste0("rf_",colnames(pred_df))
bowl_game_preds <- cbind(bowl_games,pred_df)


##XGBoost
xg_tunegrid <- expand.grid(.learn_rate=seq(0.1,0.9,by=0.2), .booster=c("gbtree","dart"),.max_depth=c(6,10,20,30))
xg_tunegrid$.booster <- as.character(xg_tunegrid$.booster)
xg_tunegrid$acc <- 0

for(i in 1:nrow(xg_tunegrid)){
  lr <- xg_tunegrid$.learn_rate[i]
  br <- xg_tunegrid$.booster[i]
  md <- xg_tunegrid$.max_depth[i]
  ptr_statement <- paste0("Working on ",i/nrow(xg_tunegrid)*100, "%", sep=" ")
  print(ptr_statement)
  rf_fit2 <- h2o.xgboost(x=x,
                         y=y,
                         training_frame = dat_tr,
                         model_id = "rf_fit1",
                         seed = 1,
                         learn_rate = lr,
                         booster = br,
                         max_depth = md)
  
  y_pred2 <- h2o.predict(rf_fit2,newdata = dat_ts)
  y_pred_df <- as_data_frame(y_pred2)
  conf_mat <- table(test$home_win,y_pred_df$predict)
  xg_tunegrid$acc[i] <- sum(diag(conf_mat))/sum(conf_mat)
}
### 0.5,gbtree,6 - best results 
best_xg_mod <- h2o.xgboost(x=x,
                           y=y,
                           training_frame = as.h2o(ind_game_df),
                           model_id = "rf_fit1",
                           seed = 1,
                           learn_rate = 0.5,
                           booster = "gbtree",
                           max_depth = 6)

pred2 <- h2o.predict(best_xg_mod,
                    newdata=as.h2o(bowl_games_df))
pred2_df <- as.data.frame(pred2)
pred2_df <- pred2_df %>% mutate(conf = abs(p1 - p0))
colnames(pred2_df) <- paste0("xg_",colnames(pred2_df))
bowl_game_preds <- cbind(bowl_game_preds,pred2_df)

### Extract variable importance for main post
varimp_df <- h2o.varimp(best_rf_mod)
varimp_df$model <- "RF"
temp_varimp <- h2o.varimp(best_xg_mod)
temp_varimp$model <- "XGB"
var_df <- rbind(varimp_df,temp_varimp)
saveRDS(var_df,"final/var_df.RDS")


h2o.shutdown()


#### Support Vector Machines for classification
#### Tune the Slack parameter
geomSeries <- function(base, max) {
  base^(0:floor(log(max, base)))
}

svm_grid <- expand.grid(sigma = c(0,0.01, 0.02, 0.025, 0.03, 0.04,
                          0.05, 0.06, 0.07,0.08, 0.09, 0.1, 0.25, 0.5, 0.75,0.9),
                              C = sort(unique(c(geomSeries(base=10, max=10^-5),
                                               geomSeries(base=10, max=10^5)))))

library(caret)
trctrl <- trainControl(method = "repeatedcv", number = 10, repeats = 3,
                       classProbs =  TRUE)

ind_game_df$home_win <- as.factor(make.names(ind_game_df$home_win))
svm_Radial <- train(home_win ~., data = ind_game_df, method = "svmRadial",
                      trControl=trctrl,
                      preProcess = c("center", "scale"),
                      tuneLength = 10,
                      tuneGrid = svm_grid)
svm_Radial

svm_pred <- ifelse(predict(svm_Radial, newdata = bowl_games_df)=="X1",1,0)
svm_pred_probs <- predict(svm_Radial, newdata = bowl_games_df, type = "prob")
svm_df <- cbind(svm_pred,svm_pred_probs)
colnames(svm_df) <- c("svm_pred","svm_prob0","svm_prob1")

bowl_game_preds <- cbind(bowl_game_preds,svm_df)
bowl_game_preds <- bowl_game_preds %>% mutate(
  svm_conf = abs(svm_prob1 - svm_prob0)
)

bowl_game_final_preds <- bowl_game_preds %>% 
  select(away_team,home_team,rf_predict,rf_conf,xg_predict,xg_conf,svm_pred,svm_conf)

saveRDS(bowl_game_preds,"final/raw_bowl_preds.RDS")
saveRDS(bowl_game_final_preds,"final/final_bowl_predictions.RDS")

