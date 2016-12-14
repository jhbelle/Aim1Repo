## -------------
## Name: Cloud_Anal.R
## Program version: R 3.2.3
## Data dependencies: CloudAgg_5km.csv; CloudAgg_10km.csv; CloudAgg_20km.csv; CloudAgg_30km.csv; CloudAgg_40km.csv (output from Cloud_Proc.R)
## Author: J.H. Belle
## Purpose: Analyze Cloud product collocation results.
## -------------

setwd("E://")

# 5 km radius
Cld5km = read.csv("CloudAgg_5km.csv", stringsAsFactors = F)

# 40 km radius
Cld40km = read.csv("CloudAgg_40km.csv", stringsAsFactors = F)
