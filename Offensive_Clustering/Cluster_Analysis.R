library(plyr)
library(dplyr)
library(tidyr)
library(reshape)
library(reshape2)
library(ggplot2)

offense <- readRDS(file = "R_Data/Off_Data.rds")
defense <- readRDS(file = "R_Data/Def_Data.rds")
sp_teams <- readRDS(file = "R_Data/Sp_Teams.rds")

offense$yr <- as.factor(offense$yr)
offense$Conference <- as.factor(offense$Conference)
offense$Yds_Per_Play <- with(offense,(Tot_Off_Yards_Per_Game * (win+losses))/Plays)
offense$Yds_Per_Score <- with(offense, (Tot_Off_Yards_Per_Game)/(Scoring.Offense))
offense$Time_Per_Play <- with(offense, ((T.O.P*60*(win+losses))/Plays))
offense$ratio <- with(offense,Passing.Offense/Rushing.Offense)
offense$Plays_Per_Game <- with(offense, Plays/team_games)

defense$opp_Yds_Per_Play <- with(defense,(opp_Tot_Off_Yards_Per_Game * (win+losses))/opp_Plays)
defense$opp_Yds_Per_Score <- with(defense, (opp_Tot_Off_Yards_Per_Game/Scoring.Defense))
defense$opp_Time_Per_Play <- with(defense, (((60-T.O.P)*60*(win+losses))/opp_Plays))


## Run First Cluster
## Types of Offense
## T.O.P, Plays, Yds_Per_Play, Tot_Off_Yards_Per_Game, 
## X3rd.Down.Conversion.Pct, Red.Zone.Offense, Scoring.Offense
## win,   

offense_style <- offense %>% select(team,Plays_Per_Game,Yds_Per_Play,Yds_Per_Score,Time_Per_Play,
                                    Tot_Off_Yards_Per_Game, ratio,
                                    win,yr,Conference )

#rownames(offense_style) <- offense_style[,1] 
#offense_style <- offense_style[,-1]
#offense_style <- offense_style[,-ncol(offense_style)]

offense_style <- offense_style[,c(1,10,9,8,2,3,4,5,6,7)]
offense_style[,5:10] <- scale(offense_style[,5:10])

set.seed(20)

## Determine optimal number of clusters
## Elbow Method
## Sugesting 3 clusters
wss <- (nrow(offense_style)-1)*sum(apply(offense_style[,5:10],2,var))
for (i in 2:15) wss[i] <- sum(kmeans(offense_style[,5:10],
                                     centers=i)$withinss)

plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")



### Average Silhouette method 
## Suggets 2 clusters.
library(cluster)
k.max <- 15
sil <- rep(0, k.max)
data <- offense_style[,5:10]
# Compute the average silhouette width for 
# k = 2 to k = 15
for(i in 2:k.max){
  km.res <- kmeans(data, centers = i, nstart = 25)
  ss <- silhouette(km.res$cluster, dist(data))
  sil[i] <- mean(ss[, 3])
}
# Plot the  average silhouette width
plot(1:k.max, sil, type = "b", pch = 19, 
     frame = FALSE, xlab = "Number of clusters k")

### Gap Statistic
## Suggests 3 clisters

gap_stat <- clusGap(data, FUN = kmeans, nstart = 25,
                    K.max = 10, B = 50)
plot(gap_stat, frame = FALSE, xlab = "Number of clusters k")
print(gap_stat, method = "firstmax")


ncaa <- kmeans(offense_style[,5:10],3,nstart=25,iter.max=1000)
# Make Conference/Style of Play (Offense)
t <- as.data.frame(table(offense_style$Conference,ncaa$cluster))
t <- spread(t,Var2,Freq)
colnames(t)[1] <- "Conference"


clust_center <- as.data.frame(ncaa$centers)

team <- as.data.frame(ncaa$cluster)
colnames(team) <- "cluster"
team$name <- offense$team
#rownames(team) <-1:nrow(team)
#count(team,vars="cluster")

## Split By clusters
off <- offense %>% select(team,Plays_Per_Game,Yds_Per_Play,Yds_Per_Score,T.O.P,Time_Per_Play,
                      Tot_Off_Yards_Per_Game, Rushing.Offense,Passing.Offense,ratio,
                      win,yr,Conference )
off <- off[,c(1,11,12,13,10,2,3,4,5,6,7,8,9)]

#off$ratio <- with(offense,Passing.Offense/Rushing.Offense)
off$cluster <- as.factor(team$cluster)


# Clusters
clusters <- split(off, off$cluster)
# Cluster 1
cluster_1 <- clusters$`1`
# Cluster 2
cluster_2 <- clusters$`2`
# Cluster 3
cluster_3 <- clusters$`3`
library(fBasics)
cluster_1_stat_set <- cluster_1[,c(2,5:13)]
cluster_1_stats <- data.frame(t(basicStats(cluster_1_stat_set)[c("Minimum","Maximum", "Mean","Median","Stdev"),]))

cluster_2_stat_set <- cluster_2[,c(2,5:13)]
cluster_2_stats <- data.frame(t(basicStats(cluster_2_stat_set)[c("Minimum","Maximum", "Mean","Median","Stdev"),]))

cluster_3_stat_set  <- cluster_3[,c(2,5:13)]
cluster_3_stats <- data.frame(t(basicStats(cluster_3_stat_set)[c("Minimum","Maximum", "Mean","Median","Stdev"),]))

detach("package:fBasics", unload=TRUE)
rm(cluster_1_stat_set,cluster_2_stat_set,cluster_3_stat_set,clusters,team)


library(ggplot2)
# Plot Time Per Play vs Pass/Rush Ratio 

median <- ddply(off, ~cluster, numcolwise(median))

ggplot(off) + geom_point(aes(x=Passing.Offense,y=Rushing.Offense,color=cluster)) +
  labs(x="Passing Yards",y="Rushing Yards") 

ggplot(off) + geom_point(aes(x=T.O.P,y=Yds_Per_Play,color=cluster)) + 
  labs(x="Time of Possession",y="Yards Per Play")

ggplot(off) + geom_point(aes(x=Time_Per_Play,y=Tot_Off_Yards_Per_Game,color=cluster)) + 
  labs(x="Time Per Play",y="Total Offensive Yards (Per Game)") 

ggplot(off) + geom_point(aes(x=Plays_Per_Game,y=Time_Per_Play,color=cluster))


ggplot(off) + geom_point(aes(x=Time_Per_Play,y=ratio,color=cluster)) + 
  #facet_grid(~cluster) + 
  scale_y_continuous(limits = c(0,5)) + 
  labs(x="Time Per Play (Secs)",y="Ratio (Passing Yds/Rushing Yds)")


  

ggplot(off,aes(win)) + 
  geom_histogram() + 
  facet_wrap(~cluster) +
  geom_vline(data=median, 
             mapping=aes(xintercept=win), color="red") + 
  geom_text(data=median,aes(x=12,y=20,label=paste0("Median: ",win),inherit.aes = FALSE,color="red")) + 
  scale_color_discrete(guide=FALSE) + 
  labs(title = "Distribution of Wins by Cluster (2013-2015)",x = "Wins", y = "Frequency") + 
  theme_bw()


power5_off <- off %>% dplyr::filter( Conference != "Non-Power-5")
count <- ddply(power5_off, Conference~cluster,count)
saveRDS(count,file="R_Data/count.rds")
# Cluster Win distribution by Conference. 
ggplot(power5_off,aes(win)) + 
  geom_histogram(aes(fill = ..count..)) + 
  facet_grid(Conference~cluster) + 
  scale_color_discrete(guide=FALSE) + 
  labs(title = "Distribution of Wins by Cluster and Conference (2013-2015)",x = "Wins", y = "Frequency") + 
  theme_bw() +
  geom_text(data=count,aes(x=12,y=5,label=n,inherit.aes = FALSE,color="blue")) + 
  scale_fill_continuous(low="red", limits=c(0,6))
  #geom_text(stat='bin',aes(label=..count..),vjust=-1)


### Another Clustering Method 
### PCA
