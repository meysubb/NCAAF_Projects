### use this to tune hyperparameters

library(tfruns)

#runs <- tuning_run("mlp_predictions.R", flags = list(
#  dropout1 = c(0.2, 0.3, 0.4),
#  dropout2 = c(0.2, 0.3, 0.4),
#  dropout3 = c(0.2, 0.3, 0.4),
#  dropout4 = c(0.2, 0.3, 0.4),
#  sgd_opt = c(0.005, 0.01,0.015,0.1,0.15,0.2,0.3),
#  layer1 = c(4,16,32,64),
#  layer2 = c(4,16,32,64),
#  layer3 = c(4,16,32,64),
#  layer4 = c(4,16,32,64) 
#))


tune_mlp <- expand.grid(dropout1 = c(0.2, 0.3, 0.4),
            dropout2 = c(0.2, 0.3, 0.4),
            dropout3 = c(0.2, 0.3, 0.4),
            sgd_opt = c(0.005, 0.01,0.015))


for(i in 1:nrow(tune_mlp)){
  training_run("mlp_predictions.R",flags = list(dropout1 = tune_mlp$dropout1[i],
                                              dropout2 = tune_mlp$dropout2[i],
                                              dropout3 = tune_mlp$dropout3[i],
                                              sgd_opt = tune_mlp$sgd_opt[i]))  
}

### Best MLP model 
### 0.3, 0.3, 0.2, 0.015

#runs[order(runs$eval_acc, decreasing = TRUE), ]
