## ---------------
## Name ExSpec.R
## Program Version: R 
## Dependencies:
## Author: J.H. Belle
## Purpose: To combine the 24hr Gravimetric observations including MAIAC, Cloud, and RUC data with the speciated observations and analyze the result 
## ----------------

# Read in the Gravimetric observations, speciated data, and Cloud data
# Gravimetric
G24 <- read.csv("/home/jhbelle/EPAdata/CleanedData/AtlG24_MAIACCldRUC.csv", stringsAsFactors = F)
G24$Date <- as.Date(G24$Date, "%Y-%m-%d")
# Remove regular AOD values less than 0 - these are missing
G24$AOD47 <- ifelse(G24$AOD47 < 0, NA, G24$AOD47)
G24$AOD55 <- ifelse(G24$AOD55 < 0, NA, G24$AOD55)
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
# Cloud
Clouds <- read.csv("/home/jhbelle/EPAdata/CleanedData/CloudAgg_Atl10km.csv", stringsAsFactors = F)
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
  
# Speciated
S24 <- read.csv("/home/jhbelle/EPAdata/CleanedData/S24hr.csv", stringsAsFactors = F)
S24 <- subset(S24, S24$StudyArea == "Atl")
S24$Date <- as.Date(S24$Date, "%Y-%m-%d")
S24$X <- NULL

# Merge in Speciated data - based on Date only
HasSpec <- merge(MissingMAIAC, S24, by=c("State", "County", "Site", "Date", "X24hrPM"))

# Make separate Terra and Aqua datasets
Terra <- subset(HasSpec, HasSpec$AquaTerraFlag == "T")
Aqua <- subset(HasSpec, HasSpec$AquaTerraFlag == "A")

## ---------
## Modeling - Individual-level (Preliminary) - treating fractions as separate y variables
## ---------

summary(lm(SulfateFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra))
summary(lm(SulfateFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua))

summary(lm(SulfateFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra[Terra$CloudPhase == 6,]))
summary(lm(SulfateFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua[Aqua$CloudPhase == 6,]))

summary(lm(NitrateFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra))
summary(lm(NitrateFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua))

summary(lm(NitrateFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra[Terra$CloudPhase == 2,]))
summary(lm(NitrateFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua[Aqua$CloudPhase == 2,]))

summary(lm(SaltFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra))
summary(lm(SaltFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua))

summary(lm(SaltFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra[Terra$CloudPhase == 2,]))
summary(lm(SaltFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua[Aqua$CloudPhase == 2,]))

summary(lm(SoilFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra))
summary(lm(SoilFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua))

summary(lm(SoilFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra[Terra$CloudPhase == 2,]))
summary(lm(SoilFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua[Aqua$CloudPhase == 6,]))

summary(lm(ECFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra))
summary(lm(ECFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua))

summary(lm(ECFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra[Terra$CloudPhase == 2,]))
summary(lm(ECFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua[Aqua$CloudPhase == 6,]))

summary(lm(OCFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra))
summary(lm(OCFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua))

summary(lm(OCFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra[Terra$CloudPhase == 6,]))
summary(lm(OCFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua[Aqua$CloudPhase == 6,]))

summary(lm(OtherFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra))
summary(lm(OtherFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua))

summary(lm(OtherFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra[Terra$CloudPhase == 0,]))
summary(lm(OtherFrac*100 ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua[Aqua$CloudPhase == 1,]))


summary(lm(Sulfate ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra))
summary(lm(Sulfate ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua))

summary(lm(Sulfate ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra[Terra$CloudPhase == 6,]))
summary(lm(Sulfate ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua[Aqua$CloudPhase == 6,]))

summary(lm(Nitrate ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra))
summary(lm(Nitrate ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua))

summary(lm(Nitrate ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra[Terra$CloudPhase == 2,]))
summary(lm(Nitrate ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua[Aqua$CloudPhase == 2,]))

summary(lm(Salt ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra))
summary(lm(Salt ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua))

summary(lm(Salt ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra[Terra$CloudPhase == 2,]))
summary(lm(Salt ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua[Aqua$CloudPhase == 2,]))

summary(lm(Soil ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra))
summary(lm(Soil ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua))

summary(lm(Soil ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra[Terra$CloudPhase == 2,]))
summary(lm(Soil ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua[Aqua$CloudPhase == 6,]))

summary(lm(EC ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra))
summary(lm(EC ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua))

summary(lm(EC ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra[Terra$CloudPhase == 2,]))
summary(lm(EC ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua[Aqua$CloudPhase == 6,]))

summary(lm(OC ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra))
summary(lm(OC ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua))

summary(lm(OC ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra[Terra$CloudPhase == 6,]))
summary(lm(OC ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua[Aqua$CloudPhase == 6,]))

summary(lm(Other ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra))
summary(lm(Other ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua))

summary(lm(Other ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Terra[Terra$CloudPhase == 0,]))
summary(lm(Other ~ as.factor(Month) + as.factor(Year) + as.factor(CatCloudBase) + WindSpeed + prate_surface + r_heightAboveGround + sd_surface + CloudRadius + CloudAOD + CloudEmmisivity, Aqua[Aqua$CloudPhase == 1,]))

## -------
## Include hourly observations
## -------

H1 <- read.csv("/home/jhbelle/EPAdata/CleanedData/H1hr.csv", stringsAsFactors = F)
H1$Date <- as.Date(H1$Date, "%Y-%m-%d")
H1$X <- NULL
H1 <- subset(H1, H1$StudyArea == "Atl")
H1 <- H1[,c(1:3,9:13)]
# Merge into original G24 - based on date + location - keep all H1 observations
HasHourly <- merge(H1, G24, by=c("State", "County", "Site", "Date"))
library(plyr)

CalcReps <- function(datblock){
  # Datblock consists of a block of data for a single day and MODIS overpass time
  # Convert Hourly GMT times to numeric
  datblock$TimeGMT <- as.numeric(substr(datblock$TimeGMT, 1, 2))
  # Round MODIS times
  datblock$MODtime <- as.numeric(substr(as.character(datblock$Time.y), 1, 2)) + ifelse(as.numeric(substr(as.character(datblock$Time.y), 3, 4)) > 30, 1, 0)
  # Calculate passtime representativeness
  datblock$Mean24hr <- mean(datblock$X1hrPM)
  datblock <- datblock[which(datblock$TimeGMT==datblock$MODtime),]
  datblock$Rep <- (datblock$X1hrPM - datblock$Mean24hr)/datblock$Mean24hr
  # Return data frame
  return(datblock)
}

library(plyr)
RepsCalced <- ddply(HasHourly, .(Date, Time.y, AquaTerraFlag), CalcReps)
RepsCalced$HasAOD <- ifelse(is.na(RepsCalced$AOD47) | is.na(RepsCalced$AOD55), 0, 1)
aggregate(Rep*100 ~ AquaTerraFlag + HasAOD + Glint + Cloud + Month, RepsCalced, median)