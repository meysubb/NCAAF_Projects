### MLP Hypertuning 
### sigmoid activation for classifcation
### softmax for predictions of class probabilities 
library(tidyverse)
ind_game <- read_csv("data/ind_game_data.csv") %>% 
  select(-c(away_team,home_team,away_team_score,home_team_score)) %>% 
  mutate(home_win=as.factor(home_win)) %>% na.omit()

bowl_games <- read_csv("data/bowl_games.csv") 
match_cols <- intersect(colnames(ind_game),colnames(bowl_games))

#bowl_games_df <- bowl_games %>% 
#  select(-c(away_team,home_team,away_team_score,home_team_score)) %>% 
#  select(match_cols)

ind_game_df <- ind_game %>% select(match_cols,home_win)


set.seed(22) 
sample <- sample.int(n = nrow(ind_game_df), size = floor(.75*nrow(ind_game_df)), replace = F)
train <- ind_game_df[sample, ]
test  <- ind_game_df[-sample, ]

Y_train <- as.matrix(train %>% select(home_win))
X_train <- as.matrix(train %>% select(-home_win))
Y_train <- as.numeric(Y_train)

y_test <- as.matrix(test %>% select(home_win))
y_test <- as.numeric(y_test)
x_test <- as.matrix(test %>% select(-home_win))


library(keras)


# Hyperparameter flags ---------------------------------------------------

FLAGS <- flags(
  flag_numeric("dropout1", 0.3),
  flag_numeric("dropout2", 0.3),
  flag_numeric("dropout3",0.3),
  flag_numeric("sgd_opt",0.01)
)


model <- keras_model_sequential()

model %>% 
  layer_dense(units = 64, activation = 'relu', input_shape = c(24)) %>% 
  layer_dropout(rate = FLAGS$dropout1) %>% 
  layer_dense(units = 64, activation = 'relu') %>% 
  layer_dropout(rate = FLAGS$dropout2) %>% 
  layer_dense(units = 64, activation = 'relu') %>% 
  layer_dropout(rate= FLAGS$dropout3) %>% 
  layer_dense(units = 1, activation = 'sigmoid') %>% 
  compile(
    loss = 'binary_crossentropy',
    optimizer = optimizer_adam(lr=FLAGS$sgd_opt),
    metrics = c('accuracy')
  )

# train 
model %>% fit(X_train, Y_train, epochs = 35, batch_size = 256)

score = model %>% evaluate(x_test, y_test, batch_size=256)


#### On second thought, there really aren't enough observations
#### Data is too small to use deep learning methods.
### MLP Generation 

library(keras)

model <- keras_model_sequential()

### Best MLP model 
### 0.3, 0.3, 0.2, 0.015
model %>% 
  layer_dense(units = 64, activation = 'relu', input_shape = c(24)) %>% 
  layer_dropout(rate = 0.4) %>% 
  layer_dense(units = 64, activation = 'relu') %>% 
  layer_dropout(rate = 0.2) %>% 
  layer_dense(units = 64, activation = 'relu') %>% 
  layer_dropout(rate= 0.2) %>% 
  layer_dense(units = 1, activation = 'sigmoid') %>% 
  compile(
    loss = 'binary_crossentropy',
    optimizer = optimizer_adam(lr=0.005),
    metrics = c('accuracy')
  )

# train 
y_train <- as.matrix(ind_game_df$home_win)
y_train <- as.factor(y_train)
X_train <- as.matrix(ind_game_df %>% select(-home_win))
model %>% fit(X_train, y_train, epochs = 35, batch_size = 128)


y_pred <- predict_classes(model,x=as.matrix(bowl_games_df), batch_size = 128, verbose = 0)
predict_proba(model,x=as.matrix(bowl_games_df), batch_size = 32, verbose = 0)


