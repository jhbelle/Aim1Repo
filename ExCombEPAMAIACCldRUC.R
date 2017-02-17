## --------------
## Name: ExCombEPAMAIACCldRUC.R
## Program version: R 3.2.3
## Program dependencies:
## Data dependencies:
## Author: J.H. Belle
## Purpose: Examine the 2009-2011 data and start model-building
## --------------

# Read in data
#Dat <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24_MAIACCldRUC_10km.csv", stringsAsFactors = F)
Dat <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlG24_MAIACCldRUC.csv", stringsAsFactors = F)
Dat$Date <- as.Date(Dat$Date, "%Y-%m-%d")
G24 <- Dat

# Remove regular AOD values less than 0 - these are missing
G24$AOD47 <- ifelse(G24$AOD47 < 0, NA, G24$AOD47)
G24$AOD55 <- ifelse(G24$AOD55 < 0, NA, G24$AOD55)

# Add in surface temperature
#Temps <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifTemps.csv", stringsAsFactors = F)[,c(1:3,8,10)]
#Temps$Date <- as.Date(Temps$Date, "%Y-%m-%d")
#Temps <- aggregate(Temperature ~ State + County + Site + Date, Temps, median)
#G24 <- merge(G24, Temps, all.x=T)

# ---------
# Manual classification
# ---------

# Classify observations into clear, glint, high cloud, medium cloud, low cloud, and thundercloud using MAIAC and RUC
G24$Month <- as.integer(as.character(G24$Date, "%m"))
G24$Year <- as.integer(as.character(G24$Date, "%Y"))
G24$Season <- ifelse(G24$Month == 3 | G24$Month == 4 | G24$Month == 5, "Spring", ifelse(G24$Month == 6 | G24$Month == 7 | G24$Month == 8, "Summer", ifelse(G24$Month == 9 | G24$Month == 10 | G24$Month == 11, "Fall", "Winter")))
G24$X24hrPM <- ifelse(G24$X24hrPM <= 0, 0.01, G24$X24hrPM)
G24$LogPM <- log(G24$X24hrPM)
# Subset data - remove anything with both AOD values missing - Filter 1
MissingMAIAC <- subset(G24, is.na(G24$AOD47) & is.na(G24$AOD55))
hist(MissingMAIAC$Dist)
summary(MissingMAIAC)
# Remove anything with a distance greater than 1 km - not a true collocation and small in number
MissingMAIAC <- subset(MissingMAIAC, MissingMAIAC$Dist < 1000)
# Filter 2: Cloud product - characterize clouds as high, low or none
# Was missing cloud product?
#Clouds <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CloudAgg_10km.csv", stringsAsFactors = F)
Clouds <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CloudAgg_Atl10km.csv", stringsAsFactors = F)
Clouds$Date <- as.Date(Clouds$Date, "%Y-%m-%d")
#Clouds$X <- NULL
MissingMAIAC <- merge(MissingMAIAC, Clouds, all.x=T)
MissingMAIAC$CloudCat <- ifelse(MissingMAIAC$PAnyCld == 0 | is.na(MissingMAIAC$PAnyCld), "None", ifelse(MissingMAIAC$CloudTopHgt < 5000, "Low", ifelse(MissingMAIAC$CloudTopHgt >=5000, "High", "Missing")))
# Filter 3: RUC -
MissingMAIAC$Raining <- ifelse(MissingMAIAC$prate_surface == 0, 0, 1)
MissingMAIAC$Snow <- ifelse(MissingMAIAC$sd_surface == 0, 0, 1)
MissingMAIAC$Multi <- ifelse(MissingMAIAC$PMultiCld == 0, 0, 1)
# Will need to double-check this categorization for each dataset
MissingMAIAC$MAIACcat <- ifelse(MissingMAIAC$Cloud == 1 | MissingMAIAC$Partcloud == 1 | MissingMAIAC$CloudShadow == 1, "Cloud", ifelse(MissingMAIAC$Glint == 1 | MissingMAIAC$Clear == 1 | MissingMAIAC$Snow == 1, "Glint", NA))
# Toss MAIAC variables
MissingMAIAC <- MissingMAIAC[!is.na(MissingMAIAC$MAIACcat),c(1:7,18,26:59)]
MissingMAIAC$CloudAOD <- ifelse(is.na(MissingMAIAC$CloudAOD), 0, MissingMAIAC$CloudAOD)
MissingMAIAC$hpbl_surface <- ifelse(MissingMAIAC$hpbl_surface < 0, 0, MissingMAIAC$hpbl_surface)
MissingMAIAC$WindSpeed <- sqrt(MissingMAIAC$X10u_heightAboveGround^2 + MissingMAIAC$X10v_heightAboveGround^2)
MissingMAIAC$CloudPhase <- ifelse(is.na(MissingMAIAC$CloudPhase), 0, MissingMAIAC$CloudPhase)
MissingMAIAC$CloudEmmisivity <- ifelse(is.na(MissingMAIAC$CloudEmmisivity), 0, MissingMAIAC$CloudEmmisivity)
MissingMAIAC$CloudTopTemp <- ifelse(MissingMAIAC$CloudTopTemp < 0, NA, MissingMAIAC$CloudTopTemp - 15000)
MissingMAIAC$CloudWaterPath <- ifelse(is.na(MissingMAIAC$CloudWaterPath), 0, MissingMAIAC$CloudWaterPath)
MissingMAIAC$CloudRadius <- ifelse(is.na(MissingMAIAC$CloudRadius), 0, MissingMAIAC$CloudRadius)
MissingMAIAC$h_cloudTop <- ifelse(MissingMAIAC$h_cloudTop < 0, NA, MissingMAIAC$h_cloudTop)
MissingMAIAC$h_cloudBase <- ifelse(MissingMAIAC$h_cloudBase < 0, NA, MissingMAIAC$h_cloudBase)
MissingMAIAC$CatCloudBase <- ifelse(is.na(MissingMAIAC$h_cloudBase), "None", ifelse(MissingMAIAC$h_cloudBase < 5000, "Low", ifelse(MissingMAIAC$h_cloudBase >= 5000, "High", NA)))
# Make separate Terra and Aqua datasets
Terra <- subset(MissingMAIAC, MissingMAIAC$AquaTerraFlag == "T")
Aqua <- subset(MissingMAIAC, MissingMAIAC$AquaTerraFlag == "A")

xtabs(~ Raining + CloudCat + Multi, Aqua)

# Fit manual models
# Glint/no Cloud
AIC(lm(LogPM ~ as.factor(Month) + r_heightAboveGround + cape_surface + X10u_heightAboveGround + X10v_heightAboveGround + sd_surface + prate_surface + hpbl_surface, subset(Terra, Terra$CloudCat == "None")))
summary(lm(LogPM ~ as.factor(Month) + r_heightAboveGround + cape_surface + X10u_heightAboveGround + X10v_heightAboveGround + sd_surface + prate_surface + hpbl_surface , subset(Aqua, Aqua$CloudCat == "None")))

# Clouds
AIC(lm(LogPM ~ as.factor(Month) + r_heightAboveGround + cape_surface + X10u_heightAboveGround + X10v_heightAboveGround + sd_surface + CloudAOD + prate_surface, subset(Terra, Terra$CloudCat == "High")))
AIC(lm(LogPM ~ as.factor(Month) + r_heightAboveGround + cape_surface + X10u_heightAboveGround + X10v_heightAboveGround + sd_surface + CloudAOD + prate_surface, subset(Terra, Terra$CloudCat == "Low")))
summary(lm(LogPM ~ as.factor(Month) + r_heightAboveGround + cape_surface + X10u_heightAboveGround + X10v_heightAboveGround + sd_surface + CloudAOD + prate_surface, subset(Aqua, Aqua$CloudCat == "High")))
summary(lm(LogPM ~ as.factor(Month) + r_heightAboveGround + cape_surface + X10u_heightAboveGround + X10v_heightAboveGround + sd_surface + CloudAOD + prate_surface + r_heightAboveGround*CloudAOD, subset(Aqua, Aqua$CloudCat == "Low")))

# Mixture modeling

library(flexmix)
# Full model
TerraMod = flexmix(LogPM ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + r_heightAboveGround + WindSpeed + prate_surface + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity | as.factor(CloudPhase), Terra[!is.na(Terra$CloudCat) & !is.na(Terra$sd_surface),], k=4)
TerraMod
summary(TerraMod)
TMrf <- refit(TerraMod)
summary(TMrf)

AquaMod = flexmix(LogPM ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + r_heightAboveGround + WindSpeed + prate_surface + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity | as.factor(CloudPhase), Aqua[!is.na(Aqua$sd_surface) & !is.na(Aqua$CloudCat),], k=4)
AquaMod
summary(AquaMod)
AMrf <- refit(AquaMod)
summary(AMrf)

