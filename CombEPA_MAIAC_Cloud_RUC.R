## -------------------
## Name: CombEPA_MAIAC_Cloud_RUC.R
## Program version: R 3.2.3
## Program Dependencies: plyr
## Function file:
## Data dependencies:
## Author: J.H. Belle
## Purpose: Combine EPA data with MAIAC, cloud product, and RUC outputs - Starting at 40 km
## --------------------

## -----
## Combine EPA with cloud and MAIAC - run locally first time
## -----

# Read in EPA observations
#G24 <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24hr.csv", stringsAsFactors = F)
#G24$Date <- as.Date(G24$Date, "%Y-%m-%d")

# Add in MAIAC data - takes around 6 hours to run for 1 year - No RAM issues
#G24 <- ddply(G24, .(State, County, Site, Date, X24hrPM), CombMAIAC)
#write.csv(G24, "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24_MAIACinc_2009.csv")
#G24 <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24_MAIACinc_2009.csv", stringsAsFactors = F)

# Read in cloud data
#Cld40km = read.csv("E://CloudAgg_40km.csv", stringsAsFactors = F)

# Merge cloud data
#G24_MAIAC_Cld <- merge(G24, Cld40km, by=c("State", "County", "Site", "Date", "Time", "X24hrPM"), all.x=T)
#G24_MAIAC_Cld$X.x <- NULL
#G24_MAIAC_Cld$X.y <- NULL
# Save a copy of this dataset
#write.csv(G24_MAIAC_Cld, "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24_MAIACCldinc_2009.csv")

# Aggregate to T/A passes in each day/station
#G24PassAgg <- ddply(G24_MAIAC_Cld, .(State, County, Site, Date, AquaTerraFlag), AggPass)

# Save dataset
#write.csv(G24PassAgg, "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24_MAIACCldAgg_2009.csv")

## -----------
# Add in RUC/RAP observations - run on cluster
## -----------
G24 <- read.csv("/aqua/Jess/Data/CalifG24_MAIACCldAgg_2009.csv", stringsAsFactors=F)
G24$Date <- as.Date(G24$Date, "%Y-%m-%d")
NearTab <- read.csv("/aqua/Jess/Data/Nearest_RUCRAP.csv", stringsAsFactors=F)

library(plyr)
source("/home/jhbelle/Aim1Repo/Functions_CombEPA_MAIAC_Cloud_RUC.R")

G24_MAIACCldRUC <- ddply(G24, .(State, County, Site, Date, AquaTerraFlag), AggRUC, NearTable=NearTab)
write.csv(G24_MAIACCldRUC, "/aqua/Jess/Data/CalifG24_MAIACCldRUC_2009.csv", row.names=F)