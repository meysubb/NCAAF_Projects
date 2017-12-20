library(tidyverse)

## Lasso 
library(glmnet)
grid <- 10^seq(10,-2,length = 100)
ind_game_mat <- model.matrix(home_win~.,ind_game_df)
ind_game_mat <- ind_game_mat[,-1]
model_lasso <- glmnet(ind_game_mat,ind_game_df$home_win,
                      alpha=1,lambda=grid,thresh = 1e-12,family="binomial")
cv_model_lasso <- cv.glmnet(ind_game_mat,ind_game_df$home_win,
                            alpha=1,lambda=grid,thresh = 1e-12,family="binomial")
l_lambda_min <- cv_model_lasso$lambda.min

coeffs <- coef(model_lasso, s=l_lambda_min)
sel_coefs <- c(dimnames(coeffs)[[1]][which(coeffs != 0)],"home_win")
sel_coefs <- sel_coefs[-1]

bowl_games_mat <- as.matrix(bowl_games_df)

lasso_prob <- predict(cv_model_lasso,newx = bowl_games_mat,s=l_lambda_min,type="response")

