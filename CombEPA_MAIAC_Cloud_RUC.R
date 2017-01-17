## -------------------
## Name: CombEPA_MAIAC_Cloud_RUC.R
## Program version: R 3.2.3
## Program Dependencies: plyr
## Function file:
## Data dependencies:
## Author: J.H. Belle
## Purpose: Combine EPA data with MAIAC, cloud product, and RUC outputs - Starting at 40 km
## --------------------

# Read in EPA observations
G24 <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24hr.csv", stringsAsFactors = F)
G24$Date <- as.Date(G24$Date, "%Y-%m-%d")

# Add in MAIAC data
G24 <- ddply(G24, .(State, County, Site, Date, X24hrPM), CombMAIAC)

# Read in cloud data


# Merge cloud data

# Save a copy of this dataset