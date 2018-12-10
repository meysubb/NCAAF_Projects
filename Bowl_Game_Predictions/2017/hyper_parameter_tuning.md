---
layout: post
title: "pRedictive models for CFB bowl season"
description: "CFB model building"
category: sports analytics
tags: [college football, R, python, college sports]
comments: false
---
-   [Data](#data)
-   [Methods](#methods)
-   [Models](#models)
    -   [Random Forests (RF)](#random-forests-rf)
    -   [XGBoost (XGB)](#xgboost-xgb)
    -   [Support Vector Machines (SVM)](#support-vector-machines-svm)
-   [Concerns](#concerns)

I've always loved college sports, especially college football. Bowl season is arguably the closest thing to March Madness when it comes to building a bracket or in this case participating in a pick'em. I've done pick'ems in the past with friends and co-workers. Last year, I ventured out to build and use ML models to predict the outcomes.

However, at the time I didn't really have as much of an expertise in hyperparmater tuning or what the pitfalls of many models might be. Having started a Business Analytics program this past year, I'm much more familiar with all my potential ML models and tuning parameters.

I decided to try to predict outcomes again this year and am going to use this post to describe the process. For those interested in what the predictions look like, you can find them [here](http://meysubb.github.io/sports%20analytics/2017/12/20/CFB_Bowl_Predictions.html).

Data
----

Let's first take a look at the data. The data includes

``` r
dim(ind_game_df)
```

    ## [1] 773  25

``` r
colnames(ind_game_df)
```

    ##  [1] "away_first_downs"          "away_rushing_yds"         
    ##  [3] "away_pass_yds"             "away_tot_offense"         
    ##  [5] "away_pen_number"           "away_pen_yds"             
    ##  [7] "away_pun_yds"              "away_pun_re_yds"          
    ##  [9] "away_kick_re_yds"          "home_first_downs"         
    ## [11] "home_rushing_yds"          "home_pass_yds"            
    ## [13] "home_tot_offense"          "home_pen_number"          
    ## [15] "home_pen_yds"              "home_pun_yds"             
    ## [17] "home_pun_re_yds"           "home_kick_re_yds"         
    ## [19] "away_third_down_conv_pct"  "home_third_down_conv_pct"
    ## [21] "away_fourth_down_conv_pct" "home_fourth_down_conv_pct"
    ## [23] "away_turnover_margin"      "home_turnover_margin"     
    ## [25] "home_win"

There's about 20 or so columns making it hard to fit the table on one page, so I'll just go with the column names above. The training data contains statistics for all Division 1 NCAA games, this includes games against FCS opponents. Data covers 773 games for the 2017 season.

``` r
dim(bowl_games_df)
```

    ## [1] 37 24

The bowl game data had the same columns as the training set. Each team was pitted against each other and their stats over the course of the season were predicted on. All the statistics here were averages over the season. This is inconsistent to predict using the averages but build using individual game statistics. At the moment, I'm not sure how to handle this. I'll address further concerns a bit later.

Note that not all bowl games are included, data was missing for certain opponents. I predicted the outcome of 37 bowl games, there are 39 bowl games in total + the playoff championship.

Methods
-------

I decided to run three different models to compare prediction accuracy. The models built are Random Forests, XGBoost and Support Vector Machines (SVMs). I decided to approach this problem as a classification instead of a prediction. I'll try and keep the model building part short!

The original training data was split into a training and validation set to identify the proper parameters for each method. I used a 75-25 split.

``` r
set.seed(22)
sample <- sample.int(n = nrow(ind_game_df), size = floor(.75*nrow(ind_game_df)), replace = F)
train <- ind_game_df[sample, ]
test  <- ind_game_df[-sample, ]

y <- "home_win"
x <- setdiff(names(ind_game_df), y)
```

Models
------

I'm going to use the `h20` package to build my tree based methods. In the past, I've found them to be more computationally efficient by leveraging parallel proccesses.

### Random Forests (RF)

For RF, a grid-search approach was taken to identify the optimal `mtry`, `ntree`, and `min_rows`. Optimal values were selected to ensure the highest out-of-sample accuracy.

``` r
library(h2o)
h2o.init(nthreads = 3, max_mem_size = "6G")
# hide progress bar for markdown
h2o.no_progress()
```

``` r
tunegrid <- expand.grid(.mtry=c(12,15,20), .ntree=c(200,500, 700),.min_rows=c(5,7,10))
tunegrid$acc <- 0

dat_tr <- as.h2o(train)
dat_ts <- as.h2o(test)

for(i in 1:nrow(tunegrid)){
  mtries <- tunegrid$.mtry[i]
  num_trees <- tunegrid$.ntree[i]
  min_rows <- tunegrid$.min_rows[i]
  ptr_statement <- paste0("Working on ",i/nrow(tunegrid)*100, "%", sep=" ")
  #print(ptr_statement)
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
```

<iframe src="/images/plots/rf_cv.html"
    style="max-width = 100%"
    sandbox="allow-same-origin allow-scripts"
    width="100%"
    height="600"
    scrolling="no"
    seamless="seamless"
    frameborder="0">
</iframe>

### XGBoost (XGB)

Simiarly for XGBoost, a grid-search approach was taken to identify the optimal `learn_rate`, `max depth`, and `booster`. Note for classification models, only gbtree and dart are valid booster functions.

``` r
xg_tunegrid <- expand.grid(.learn_rate=seq(0.1,0.9,by=0.2), .booster=c("gbtree","dart"),.max_depth=c(6,10,20,30))
xg_tunegrid$.booster <- as.character(xg_tunegrid$.booster)
xg_tunegrid$acc <- 0

for(i in 1:nrow(xg_tunegrid)){
  lr <- xg_tunegrid$.learn_rate[i]
  br <- xg_tunegrid$.booster[i]
  md <- xg_tunegrid$.max_depth[i]
  ptr_statement <- paste0("Working on ",i/nrow(xg_tunegrid)*100, "%", sep=" ")
  #print(ptr_statement)
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
```

<iframe src="/images/plots/xg_cv.html"
    style="max-width = 100%"
    sandbox="allow-same-origin allow-scripts"
    width="100%"
    height="600"
    scrolling="no"
    seamless="seamless"
    frameborder="0">
</iframe>

### Support Vector Machines (SVM)

H2o doesn't support SVM, hence my use of caret. I've been meaning to trying caret anyways. I really do wish there was a parallel to sklearn in R. Maybe caret is that?

Lastly for SVM, a grid-search approach was taken to identify the optimal `sigma` and `slack (C)`

``` r
library(doParallel)
registerDoParallel(cores=3)
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
### come back and print just the best value
#svm_Radial
```

<iframe src="/images/plots/Static_JSON_bokeh.html"
    style="max-width = 100%"
    sandbox="allow-same-origin allow-scripts"
    width="100%"
    height="600"
    scrolling="no"
    seamless="seamless"
    frameborder="0">
</iframe>

Concerns
--------

Caveat: I used home and away as just placeholders to allow me to pit teams against each other. There was no in-built
