2017 Bowl Predictions
================
Meyappan Subbaiah
December 10, 2017

-   [Bowl Predictions](#bowl-predictions)
-   [Algorithm 1 - Random Forest vs. Algorithm 2 - XGboost](#algorithm-1---random-forest-vs.-algorithm-2---xgboost)
-   [Predictions](#predictions)
-   [Final Results](#final-results)

Last year at work, I was part of the college bowl pick'em. Nothing new, I used to do the CFB bowl pick'ems with my college roommates and others. But last year, I decided to scrape the data and use different Machine Learning (ML) algorithms to predict winners.

Note: I treated this as a classification problem, 1 - Win, 0 - Lose. For those curious about the ML algorithms and the parameters selected, I'll be writing up a follow-up post. Should be out soon.

Bowl Predictions
----------------

Prediction ac curacies will be updated as bowl season progresses. I'm going to include 4 different set of predictions:
1. Personal picks,
2. Algorithm 1 - Random forest,
3. Algorithm 2 - XGBoost,
4. Algorithm 3 - Support Vector Machines (SVM)

Let's look at what each algorithm thinks is important. These were all the possible stats available for all 128 teams in NCAA-FBS (Division I).

    ##  [1] "3rd Down Conversion Pct"         "3rd Down Conversion Pct Defense"
    ##  [3] "4th Down Conversion Pct"         "4th Down Conversion Pct Defense"
    ##  [5] "Fewest Penalties Per Game"       "Fewest Penalty Yards Per Game"  
    ##  [7] "First Downs Defense"             "First Downs Offense"            
    ##  [9] "Kickoff Returns"                 "Net Punting"                    
    ## [11] "Passing Offense"                 "Passing Yards Allowed"          
    ## [13] "Punt Returns"                    "Red Zone Defense"               
    ## [15] "Red Zone Offense"                "Rushing Defense"                
    ## [17] "Rushing Offense"                 "Scoring Defense"                
    ## [19] "Scoring Offense"                 "Team Passing Efficiency"        
    ## [21] "Team Passing Efficiency Defense" "T.O.P"                          
    ## [23] "Total Defense"                   "Total Offense"                  
    ## [25] "Turnover Margin"

Algorithm 1 - Random Forest vs. Algorithm 2 - XGboost
-----------------------------------------------------

Random Forests (RF) are an ensemble learning method using decision trees. The model has the capability to select and identify the important variables. XGboost is an *extreme gradient boosting* method applied to decision trees. Similarly to RF it also has the capability to identify important variables.

Let's see what we've got here.

![](writeup_2_files/figure-markdown_github/plots-1.png)

Before we dive into this, the models were run to classify/predict whether the home team wins. Above we see the top 10 stats that each model thinks is important to predict home team wins. They both tend to cover the same spectrum, interestingly enough XGB doesn't consider the home\_turnover\_margin in the top 10 variables.

I'd say overall, it tends to do a good job since it captures **(1) turnovers, (2) offensive capabillity, (3) special teams (field position), and (4) clutch conversions (third down %)**. You can also argue/point out that it captures defense since turnovers and the number of total yards the other team gains.

For Support Vector Machines (Algorithm 3 - SVM), they are a bit more complex, and hence don't provide straight forward variable importance. If you want some more detail on this, look for the follow up post.

Anyways let's take a look at the predictions.

Predictions
-----------

<table class="table table-hover" style="font-size: 10px; width: auto !important; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;font-weight: bold;color: white;background-color: #D7261E;">
Away Team
</th>
<th style="text-align:left;font-weight: bold;color: white;background-color: #D7261E;">
Home Team
</th>
<th style="text-align:left;font-weight: bold;color: white;background-color: #D7261E;">
Algorithm 1
</th>
<th style="text-align:left;font-weight: bold;color: white;background-color: #D7261E;">
A1 - Confidence
</th>
<th style="text-align:left;font-weight: bold;color: white;background-color: #D7261E;">
Algorithm 2
</th>
<th style="text-align:left;font-weight: bold;color: white;background-color: #D7261E;">
A2 - Confidence
</th>
<th style="text-align:left;font-weight: bold;color: white;background-color: #D7261E;">
Algorithm 3
</th>
<th style="text-align:left;font-weight: bold;color: white;background-color: #D7261E;">
A3 - Confidence
</th>
<th style="text-align:left;font-weight: bold;color: white;background-color: #D7261E;">
Actual
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
Troy
</td>
<td style="text-align:left;">
North Texas
</td>
<td style="text-align:left;">
<span style="color: red;">North Texas</span>
</td>
<td style="text-align:left;">
0.74
</td>
<td style="text-align:left;">
<span style="color: red;">North Texas</span>
</td>
<td style="text-align:left;">
0.99
</td>
<td style="text-align:left;">
<span style="color: red;">North Texas</span>
</td>
<td style="text-align:left;">
0.77
</td>
<td style="text-align:left;">
Troy
</td>
</tr>
<tr>
<td style="text-align:left;">
Georgia St.
</td>
<td style="text-align:left;">
Western Ky.
</td>
<td style="text-align:left;">
<span style="color: red;">Western Ky.</span>
</td>
<td style="text-align:left;">
0.02
</td>
<td style="text-align:left;">
<span style="color: green;">Georgia St.</span>
</td>
<td style="text-align:left;">
0.11
</td>
<td style="text-align:left;">
<span style="color: red;">Western Ky.</span>
</td>
<td style="text-align:left;">
0.44
</td>
<td style="text-align:left;">
Georgia St.
</td>
</tr>
<tr>
<td style="text-align:left;">
Boise St.
</td>
<td style="text-align:left;">
Oregon
</td>
<td style="text-align:left;">
<span style="color: red;">Oregon</span>
</td>
<td style="text-align:left;">
0.81
</td>
<td style="text-align:left;">
<span style="color: red;">Oregon</span>
</td>
<td style="text-align:left;">
0.99
</td>
<td style="text-align:left;">
<span style="color: red;">Oregon</span>
</td>
<td style="text-align:left;">
0.66
</td>
<td style="text-align:left;">
Boise St.
</td>
</tr>
<tr>
<td style="text-align:left;">
Marshall
</td>
<td style="text-align:left;">
Colorado St.
</td>
<td style="text-align:left;">
<span style="color: red;">Colorado St.</span>
</td>
<td style="text-align:left;">
0.83
</td>
<td style="text-align:left;">
<span style="color: green;">Marshall</span>
</td>
<td style="text-align:left;">
0.88
</td>
<td style="text-align:left;">
<span style="color: red;">Colorado St.</span>
</td>
<td style="text-align:left;">
0.79
</td>
<td style="text-align:left;">
Marshall
</td>
</tr>
<tr>
<td style="text-align:left;">
Fla. Atlantic
</td>
<td style="text-align:left;">
Akron
</td>
<td style="text-align:left;">
<span style="color: green;">Fla. Atlantic</span>
</td>
<td style="text-align:left;">
0.77
</td>
<td style="text-align:left;">
<span style="color: green;">Fla. Atlantic</span>
</td>
<td style="text-align:left;">
0.97
</td>
<td style="text-align:left;">
<span style="color: green;">Fla. Atlantic</span>
</td>
<td style="text-align:left;">
0.71
</td>
<td style="text-align:left;">
Fla. Atlantic
</td>
</tr>
<tr>
<td style="text-align:left;">
SMU
</td>
<td style="text-align:left;">
Louisiana Tech
</td>
<td style="text-align:left;">
<span style="color: red;">SMU</span>
</td>
<td style="text-align:left;">
0.19
</td>
<td style="text-align:left;">
<span style="color: red;">SMU</span>
</td>
<td style="text-align:left;">
0.79
</td>
<td style="text-align:left;">
<span style="color: green;">Louisiana Tech</span>
</td>
<td style="text-align:left;">
0.05
</td>
<td style="text-align:left;">
Louisiana Tech
</td>
</tr>
<tr>
<td style="text-align:left;">
Temple
</td>
<td style="text-align:left;">
FIU
</td>
<td style="text-align:left;">
<span style="color: red;">FIU</span>
</td>
<td style="text-align:left;">
0.68
</td>
<td style="text-align:left;">
<span style="color: green;">Temple</span>
</td>
<td style="text-align:left;">
0.50
</td>
<td style="text-align:left;">
<span style="color: red;">FIU</span>
</td>
<td style="text-align:left;">
0.37
</td>
<td style="text-align:left;">
Temple
</td>
</tr>
<tr>
<td style="text-align:left;">
UAB
</td>
<td style="text-align:left;">
Ohio
</td>
<td style="text-align:left;">
<span style="color: green;">Ohio</span>
</td>
<td style="text-align:left;">
0.60
</td>
<td style="text-align:left;">
<span style="color: green;">Ohio</span>
</td>
<td style="text-align:left;">
0.99
</td>
<td style="text-align:left;">
<span style="color: green;">Ohio</span>
</td>
<td style="text-align:left;">
0.64
</td>
<td style="text-align:left;">
Ohio
</td>
</tr>
<tr>
<td style="text-align:left;">
Wyoming
</td>
<td style="text-align:left;">
Central Mich.
</td>
<td style="text-align:left;">
<span style="color: red;">Central Mich.</span>
</td>
<td style="text-align:left;">
0.36
</td>
<td style="text-align:left;">
<span style="color: red;">Central Mich.</span>
</td>
<td style="text-align:left;">
1.00
</td>
<td style="text-align:left;">
<span style="color: red;">Central Mich.</span>
</td>
<td style="text-align:left;">
0.75
</td>
<td style="text-align:left;">
Wyoming
</td>
</tr>
<tr>
<td style="text-align:left;">
South Fla.
</td>
<td style="text-align:left;">
Texas Tech
</td>
<td style="text-align:left;">
<span style="color: green;">South Fla.</span>
</td>
<td style="text-align:left;">
0.30
</td>
<td style="text-align:left;">
<span style="color: green;">South Fla.</span>
</td>
<td style="text-align:left;">
0.68
</td>
<td style="text-align:left;">
<span style="color: green;">South Fla.</span>
</td>
<td style="text-align:left;">
0.34
</td>
<td style="text-align:left;">
South Fla.
</td>
</tr>
<tr>
<td style="text-align:left;">
Army West Point
</td>
<td style="text-align:left;">
San Diego St.
</td>
<td style="text-align:left;">
<span style="color: green;">Army West Point</span>
</td>
<td style="text-align:left;">
0.19
</td>
<td style="text-align:left;">
<span style="color: green;">Army West Point</span>
</td>
<td style="text-align:left;">
0.37
</td>
<td style="text-align:left;">
<span style="color: green;">Army West Point</span>
</td>
<td style="text-align:left;">
0.38
</td>
<td style="text-align:left;">
Army West Point
</td>
</tr>
<tr>
<td style="text-align:left;">
Appalachian St.
</td>
<td style="text-align:left;">
Toledo
</td>
<td style="text-align:left;">
<span style="color: red;">Toledo</span>
</td>
<td style="text-align:left;">
0.54
</td>
<td style="text-align:left;">
<span style="color: green;">Appalachian St.</span>
</td>
<td style="text-align:left;">
0.84
</td>
<td style="text-align:left;">
<span style="color: red;">Toledo</span>
</td>
<td style="text-align:left;">
0.43
</td>
<td style="text-align:left;">
Appalachian St.
</td>
</tr>
<tr>
<td style="text-align:left;">
Fresno St.
</td>
<td style="text-align:left;">
Houston
</td>
<td style="text-align:left;">
<span style="color: red;">Houston</span>
</td>
<td style="text-align:left;">
0.80
</td>
<td style="text-align:left;">
<span style="color: red;">Houston</span>
</td>
<td style="text-align:left;">
1.00
</td>
<td style="text-align:left;">
<span style="color: red;">Houston</span>
</td>
<td style="text-align:left;">
0.73
</td>
<td style="text-align:left;">
Fresno St.
</td>
</tr>
<tr>
<td style="text-align:left;">
West Virginia
</td>
<td style="text-align:left;">
Utah
</td>
<td style="text-align:left;">
<span style="color: green;">Utah</span>
</td>
<td style="text-align:left;">
0.39
</td>
<td style="text-align:left;">
<span style="color: red;">West Virginia</span>
</td>
<td style="text-align:left;">
0.98
</td>
<td style="text-align:left;">
<span style="color: red;">West Virginia</span>
</td>
<td style="text-align:left;">
0.07
</td>
<td style="text-align:left;">
Utah
</td>
</tr>
<tr>
<td style="text-align:left;">
Duke
</td>
<td style="text-align:left;">
Northern Ill.
</td>
<td style="text-align:left;">
<span style="color: red;">Northern Ill.</span>
</td>
<td style="text-align:left;">
0.65
</td>
<td style="text-align:left;">
<span style="color: red;">Northern Ill.</span>
</td>
<td style="text-align:left;">
0.96
</td>
<td style="text-align:left;">
<span style="color: red;">Northern Ill.</span>
</td>
<td style="text-align:left;">
0.45
</td>
<td style="text-align:left;">
Duke
</td>
</tr>
<tr>
<td style="text-align:left;">
UCLA
</td>
<td style="text-align:left;">
Kansas St.
</td>
<td style="text-align:left;">
<span style="color: red;">UCLA</span>
</td>
<td style="text-align:left;">
0.80
</td>
<td style="text-align:left;">
<span style="color: red;">UCLA</span>
</td>
<td style="text-align:left;">
0.99
</td>
<td style="text-align:left;">
<span style="color: red;">UCLA</span>
</td>
<td style="text-align:left;">
0.35
</td>
<td style="text-align:left;">
Kansas St.
</td>
</tr>
<tr>
<td style="text-align:left;">
Florida St.
</td>
<td style="text-align:left;">
Southern Miss.
</td>
<td style="text-align:left;">
<span style="color: red;">Southern Miss.</span>
</td>
<td style="text-align:left;">
0.50
</td>
<td style="text-align:left;">
<span style="color: red;">Southern Miss.</span>
</td>
<td style="text-align:left;">
0.96
</td>
<td style="text-align:left;">
<span style="color: red;">Southern Miss.</span>
</td>
<td style="text-align:left;">
0.49
</td>
<td style="text-align:left;">
Florida St.
</td>
</tr>
<tr>
<td style="text-align:left;">
Boston College
</td>
<td style="text-align:left;">
Iowa
</td>
<td style="text-align:left;">
<span style="color: red;">Boston College</span>
</td>
<td style="text-align:left;">
0.37
</td>
<td style="text-align:left;">
<span style="color: red;">Boston College</span>
</td>
<td style="text-align:left;">
0.41
</td>
<td style="text-align:left;">
<span style="color: red;">Boston College</span>
</td>
<td style="text-align:left;">
0.09
</td>
<td style="text-align:left;">
Iowa
</td>
</tr>
<tr>
<td style="text-align:left;">
Arizona
</td>
<td style="text-align:left;">
Purdue
</td>
<td style="text-align:left;">
<span style="color: red;">Arizona</span>
</td>
<td style="text-align:left;">
0.27
</td>
<td style="text-align:left;">
<span style="color: red;">Arizona</span>
</td>
<td style="text-align:left;">
0.44
</td>
<td style="text-align:left;">
<span style="color: red;">Arizona</span>
</td>
<td style="text-align:left;">
0.79
</td>
<td style="text-align:left;">
Purdue
</td>
</tr>
<tr>
<td style="text-align:left;">
Texas
</td>
<td style="text-align:left;">
Missouri
</td>
<td style="text-align:left;">
<span style="color: red;">Missouri</span>
</td>
<td style="text-align:left;">
0.75
</td>
<td style="text-align:left;">
<span style="color: red;">Missouri</span>
</td>
<td style="text-align:left;">
1.00
</td>
<td style="text-align:left;">
<span style="color: red;">Missouri</span>
</td>
<td style="text-align:left;">
0.84
</td>
<td style="text-align:left;">
Texas
</td>
</tr>
<tr>
<td style="text-align:left;">
Virginia
</td>
<td style="text-align:left;">
Navy
</td>
<td style="text-align:left;">
<span style="color: green;">Navy</span>
</td>
<td style="text-align:left;">
0.90
</td>
<td style="text-align:left;">
<span style="color: green;">Navy</span>
</td>
<td style="text-align:left;">
1.00
</td>
<td style="text-align:left;">
<span style="color: green;">Navy</span>
</td>
<td style="text-align:left;">
0.92
</td>
<td style="text-align:left;">
Navy
</td>
</tr>
<tr>
<td style="text-align:left;">
Oklahoma St.
</td>
<td style="text-align:left;">
Virginia Tech
</td>
<td style="text-align:left;">
<span style="color: green;">Oklahoma St.</span>
</td>
<td style="text-align:left;">
0.33
</td>
<td style="text-align:left;">
<span style="color: green;">Oklahoma St.</span>
</td>
<td style="text-align:left;">
0.82
</td>
<td style="text-align:left;">
<span style="color: green;">Oklahoma St.</span>
</td>
<td style="text-align:left;">
0.43
</td>
<td style="text-align:left;">
Oklahoma St.
</td>
</tr>
<tr>
<td style="text-align:left;">
Stanford
</td>
<td style="text-align:left;">
TCU
</td>
<td style="text-align:left;">
<span style="color: green;">TCU</span>
</td>
<td style="text-align:left;">
0.50
</td>
<td style="text-align:left;">
<span style="color: green;">TCU</span>
</td>
<td style="text-align:left;">
0.99
</td>
<td style="text-align:left;">
<span style="color: green;">TCU</span>
</td>
<td style="text-align:left;">
0.54
</td>
<td style="text-align:left;">
TCU
</td>
</tr>
<tr>
<td style="text-align:left;">
Michigan St.
</td>
<td style="text-align:left;">
Washington St.
</td>
<td style="text-align:left;">
<span style="color: red;">Washington St.</span>
</td>
<td style="text-align:left;">
0.48
</td>
<td style="text-align:left;">
<span style="color: red;">Washington St.</span>
</td>
<td style="text-align:left;">
1.00
</td>
<td style="text-align:left;">
<span style="color: red;">Washington St.</span>
</td>
<td style="text-align:left;">
0.51
</td>
<td style="text-align:left;">
Michigan St.
</td>
</tr>
<tr>
<td style="text-align:left;">
Wake Forest
</td>
<td style="text-align:left;">
Texas A&M
</td>
<td style="text-align:left;">
<span style="color: red;">Texas A&M</span>
</td>
<td style="text-align:left;">
0.16
</td>
<td style="text-align:left;">
<span style="color: green;">Wake Forest</span>
</td>
<td style="text-align:left;">
0.55
</td>
<td style="text-align:left;">
<span style="color: red;">Texas A&M</span>
</td>
<td style="text-align:left;">
0.19
</td>
<td style="text-align:left;">
Wake Forest
</td>
</tr>
<tr>
<td style="text-align:left;">
Kentucky
</td>
<td style="text-align:left;">
Northwestern
</td>
<td style="text-align:left;">
<span style="color: green;">Northwestern</span>
</td>
<td style="text-align:left;">
0.69
</td>
<td style="text-align:left;">
<span style="color: green;">Northwestern</span>
</td>
<td style="text-align:left;">
0.99
</td>
<td style="text-align:left;">
<span style="color: green;">Northwestern</span>
</td>
<td style="text-align:left;">
0.34
</td>
<td style="text-align:left;">
Northwestern
</td>
</tr>
<tr>
<td style="text-align:left;">
New Mexico St.
</td>
<td style="text-align:left;">
Utah St.
</td>
<td style="text-align:left;">
<span style="color: red;">Utah St.</span>
</td>
<td style="text-align:left;">
0.52
</td>
<td style="text-align:left;">
<span style="color: green;">New Mexico St.</span>
</td>
<td style="text-align:left;">
0.94
</td>
<td style="text-align:left;">
<span style="color: red;">Utah St.</span>
</td>
<td style="text-align:left;">
0.23
</td>
<td style="text-align:left;">
New Mexico St.
</td>
</tr>
<tr>
<td style="text-align:left;">
Ohio St.
</td>
<td style="text-align:left;">
Southern California
</td>
<td style="text-align:left;">
<span style="color: red;">Southern California</span>
</td>
<td style="text-align:left;">
0.29
</td>
<td style="text-align:left;">
<span style="color: green;">Ohio St.</span>
</td>
<td style="text-align:left;">
0.50
</td>
<td style="text-align:left;">
<span style="color: green;">Ohio St.</span>
</td>
<td style="text-align:left;">
0.17
</td>
<td style="text-align:left;">
Ohio St.
</td>
</tr>
<tr>
<td style="text-align:left;">
Louisville
</td>
<td style="text-align:left;">
Mississippi St.
</td>
<td style="text-align:left;">
<span style="color: green;">Mississippi St.</span>
</td>
<td style="text-align:left;">
0.26
</td>
<td style="text-align:left;">
<span style="color: green;">Mississippi St.</span>
</td>
<td style="text-align:left;">
0.97
</td>
<td style="text-align:left;">
<span style="color: red;">Louisville</span>
</td>
<td style="text-align:left;">
0.19
</td>
<td style="text-align:left;">
Mississippi St.
</td>
</tr>
<tr>
<td style="text-align:left;">
Iowa St.
</td>
<td style="text-align:left;">
Memphis
</td>
<td style="text-align:left;">
<span style="color: red;">Memphis</span>
</td>
<td style="text-align:left;">
0.39
</td>
<td style="text-align:left;">
<span style="color: red;">Memphis</span>
</td>
<td style="text-align:left;">
1.00
</td>
<td style="text-align:left;">
<span style="color: red;">Memphis</span>
</td>
<td style="text-align:left;">
0.79
</td>
<td style="text-align:left;">
Iowa St.
</td>
</tr>
<tr>
<td style="text-align:left;">
Washington
</td>
<td style="text-align:left;">
Penn St.
</td>
<td style="text-align:left;">
<span style="color: green;">Penn St.</span>
</td>
<td style="text-align:left;">
0.01
</td>
<td style="text-align:left;">
<span style="color: green;">Penn St.</span>
</td>
<td style="text-align:left;">
1.00
</td>
<td style="text-align:left;">
<span style="color: green;">Penn St.</span>
</td>
<td style="text-align:left;">
0.37
</td>
<td style="text-align:left;">
Penn St.
</td>
</tr>
<tr>
<td style="text-align:left;">
Miami (FL)
</td>
<td style="text-align:left;">
Wisconsin
</td>
<td style="text-align:left;">
<span style="color: green;">Wisconsin</span>
</td>
<td style="text-align:left;">
0.82
</td>
<td style="text-align:left;">
<span style="color: green;">Wisconsin</span>
</td>
<td style="text-align:left;">
1.00
</td>
<td style="text-align:left;">
<span style="color: green;">Wisconsin</span>
</td>
<td style="text-align:left;">
0.78
</td>
<td style="text-align:left;">
Wisconsin
</td>
</tr>
<tr>
<td style="text-align:left;">
Michigan
</td>
<td style="text-align:left;">
South Carolina
</td>
<td style="text-align:left;">
<span style="color: red;">Michigan</span>
</td>
<td style="text-align:left;">
0.42
</td>
<td style="text-align:left;">
<span style="color: red;">Michigan</span>
</td>
<td style="text-align:left;">
0.64
</td>
<td style="text-align:left;">
<span style="color: red;">Michigan</span>
</td>
<td style="text-align:left;">
0.04
</td>
<td style="text-align:left;">
South Carolina
</td>
</tr>
<tr>
<td style="text-align:left;">
Auburn
</td>
<td style="text-align:left;">
UCF
</td>
<td style="text-align:left;">
<span style="color: green;">UCF</span>
</td>
<td style="text-align:left;">
0.01
</td>
<td style="text-align:left;">
<span style="color: green;">UCF</span>
</td>
<td style="text-align:left;">
0.98
</td>
<td style="text-align:left;">
<span style="color: green;">UCF</span>
</td>
<td style="text-align:left;">
0.14
</td>
<td style="text-align:left;">
UCF
</td>
</tr>
<tr>
<td style="text-align:left;">
Notre Dame
</td>
<td style="text-align:left;">
LSU
</td>
<td style="text-align:left;">
<span style="color: green;">Notre Dame</span>
</td>
<td style="text-align:left;">
0.16
</td>
<td style="text-align:left;">
<span style="color: green;">Notre Dame</span>
</td>
<td style="text-align:left;">
0.68
</td>
<td style="text-align:left;">
<span style="color: green;">Notre Dame</span>
</td>
<td style="text-align:left;">
0.34
</td>
<td style="text-align:left;">
Notre Dame
</td>
</tr>
<tr>
<td style="text-align:left;">
Oklahoma
</td>
<td style="text-align:left;">
Georgia
</td>
<td style="text-align:left;">
<span style="color: green;">Georgia</span>
</td>
<td style="text-align:left;">
0.30
</td>
<td style="text-align:left;">
<span style="color: red;">Oklahoma</span>
</td>
<td style="text-align:left;">
0.89
</td>
<td style="text-align:left;">
<span style="color: red;">Oklahoma</span>
</td>
<td style="text-align:left;">
0.13
</td>
<td style="text-align:left;">
Georgia
</td>
</tr>
<tr>
<td style="text-align:left;">
Clemson
</td>
<td style="text-align:left;">
Alabama
</td>
<td style="text-align:left;">
<span style="color: green;">Alabama</span>
</td>
<td style="text-align:left;">
0.00
</td>
<td style="text-align:left;">
<span style="color: green;">Alabama</span>
</td>
<td style="text-align:left;">
0.99
</td>
<td style="text-align:left;">
<span style="color: green;">Alabama</span>
</td>
<td style="text-align:left;">
0.18
</td>
<td style="text-align:left;">
Alabama
</td>
</tr>
</tbody>
</table>
Note, the confidence of each prediction is also provided using the probability the model provided in predicting a home win or away win. I'll update this

I'm quite unhappy with a few picks:
(1) UCLA over Kansas St, I'm a huge Bill Synder fan.
(2) TCU over Stanford, picking against the ground game of Stanford?
(3) Also the confidence in Bama beating Clemson, scares me. 99% for XGB? JEEZ

I wish I had some conference and scheduled based statistics as well. I'd love to incorporate SOS, power-5 opponents, etc. There are probably a million different things that can be useful. As I continue this yearly, I'll look for more statistics to include. Let me know if you think there are any that I should consider!

Final Results
-------------

Algorithm 1 - 16/37 = 43.2%
Algorithm 2 - 21/37 = 56.7%
Algorithm 3 - 15/37 = 43.2%

None of these are truly fantastic. I would like to break the 60% threshold. Just like last year, there's a lot left to learn going forward. I'll take a stab at this again for the 2018 bowl season. So long folks!

Congrats to Alabama! TUAAAAAAAA!
