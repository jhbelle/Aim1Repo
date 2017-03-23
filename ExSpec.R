## ---------------
## Name ExSpec.R
## Program Version: R
## Dependencies:
## Author: J.H. Belle
## Purpose: To combine the 24hr Gravimetric observations including MAIAC, Cloud, and RUC data with the speciated observations and analyze the result
## ----------------

# Speciated
S24 <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/S24hr.csv", stringsAsFactors = F)
S24 <- subset(S24, S24$StudyArea == "Calif")
S24$Date <- as.Date(S24$Date, "%Y-%m-%d")
S24$X <- NULL
S24$Month <- as.integer(as.character(S24$Date, "%m"))
S24$Year <- as.integer(as.character(S24$Date, "%Y"))
S24$Season <- ifelse(S24$Month == 3 | S24$Month == 4 | S24$Month == 5, "Spring", ifelse(S24$Month == 6 | S24$Month == 7 | S24$Month == 8, "Summer", ifelse(S24$Month == 9 | S24$Month == 10 | S24$Month == 11, "Fall", "Winter")))
#aggregate(X24hrPM~Season, S24, length)
#aggregate(X24hrPM~Season, S24, mean)
#aggregate(X24hrPM~Season, S24, median)
#summary(S24[,9:16])
#summary(S24[,17:23]*100)
#summary(S24[S24$Season == "Winter",17:23]*100)
#summary(S24[S24$Season == "Winter",9:16])
#summary(S24[S24$Season == "Spring",17:23]*100)
#summary(S24[S24$Season == "Spring",9:16])
#summary(S24[S24$Season == "Summer",17:23]*100)
#summary(S24[S24$Season == "Summer",9:16])
#summary(S24[S24$Season == "Fall",17:23]*100)
#summary(S24[S24$Season == "Fall",9:16])
# Read in the Gravimetric observations, speciated data, and Cloud data
# Gravimetric
Dat <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24_MAIACCldRUC_10km.csv", stringsAsFactors = F)
#Dat <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlG24_MAIACCldRUC.csv", stringsAsFactors = F)
Dat$Date <- as.Date(Dat$Date, "%Y-%m-%d")
G24 <- Dat
# Remove regular AOD values less than 0 - these are missing
G24$AOD47 <- ifelse(G24$AOD47 < 0, NA, G24$AOD47)
G24$AOD55 <- ifelse(G24$AOD55 < 0, NA, G24$AOD55)

# Merge in Speciated data - based on Date only
G24 <- merge(G24, S24, by=c("State", "County", "Site", "Date", "X24hrPM"))

# Classify observations into clear, glint, high cloud, medium cloud, low cloud, and thundercloud using MAIAC and RUC
G24$Month <- as.integer(as.character(G24$Date, "%m"))
G24$Year <- as.integer(as.character(G24$Date, "%Y"))
G24$Season <- ifelse(G24$Month == 3 | G24$Month == 4 | G24$Month == 5, "Spring", ifelse(G24$Month == 6 | G24$Month == 7 | G24$Month == 8, "Summer", ifelse(G24$Month == 9 | G24$Month == 10 | G24$Month == 11, "Fall", "Winter")))
G24$OrigPM <- G24$X24hrPM
G24$X24hrPM <- ifelse(G24$X24hrPM <= 0, 0.01, G24$X24hrPM)
G24$LogPM <- log(G24$X24hrPM)
G24 <- subset(G24, G24$Dist < 1000)
# Remove duplicate MAIAC collocations
takefirst <- function(datblock){ return(datblock[1,])}
library(plyr)
FirstCollocOnly <- ddply(G24, .(State, County, Site, Date, AquaTerraFlag), takefirst)
# Subset data - remove anything with both AOD values missing - Filter 1
#G24$MissingMAIAC <- ifelse(is.na(G24$AOD47) & is.na(G24$AOD55), 1, 0)
# Get tabulations of MAIAC by missing status and T/A pass
#xtabs(~ MissingMAIAC + AquaTerraFlag, G24)
#xtabs(~AquaTerraFlag, FirstCollocOnly)
#str(FirstCollocOnly)
#summary(FirstCollocOnly[FirstCollocOnly$AquaTerraFlag == "A",52:58]*100)
#summary(FirstCollocOnly[FirstCollocOnly$AquaTerraFlag == "T",52:58]*100)

MissingMAIAC <- subset(FirstCollocOnly, is.na(FirstCollocOnly$AOD47) & is.na(FirstCollocOnly$AOD55))
#xtabs(~AquaTerraFlag, MissingMAIAC)
#summary(MissingMAIAC[MissingMAIAC$AquaTerraFlag == "A",52:58]*100)
#summary(MissingMAIAC[MissingMAIAC$AquaTerraFlag == "T",52:58]*100)
# Filter 2: Cloud product - characterize clouds as high, low or none
# Was missing cloud product?
#Clouds <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CloudAgg_10km.csv", stringsAsFactors = F)
#Clouds <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CloudAgg_Atl10km.csv", stringsAsFactors = F)
Clouds <- read.csv("E://CloudAgg_10km.csv")
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
#xtabs(~MAIACcat + AquaTerraFlag, MissingMAIAC)
#summary(MissingMAIAC[MissingMAIAC$AquaTerraFlag == "A" & MissingMAIAC$MAIACcat == "Cloud",52:58]*100)
#summary(MissingMAIAC[MissingMAIAC$AquaTerraFlag == "T" & MissingMAIAC$MAIACcat == "Cloud",52:58]*100)
#summary(MissingMAIAC[MissingMAIAC$AquaTerraFlag == "A" & MissingMAIAC$MAIACcat == "Glint",52:58]*100)
#summary(MissingMAIAC[MissingMAIAC$AquaTerraFlag == "T" & MissingMAIAC$MAIACcat == "Glint",52:58]*100)

# Toss MAIAC variables
MissingMAIAC <- MissingMAIAC[!is.na(MissingMAIAC$MAIACcat),c(1:7,18,26:79)]
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
MissingMAIAC$CatCloudBase <- factor(MissingMAIAC$CatCloudBase, levels=c("None", "Low", "High"))
# Need to do tabulations on mismatches in definitions
MissingMAIAC$HasCldEmis <- ifelse(MissingMAIAC$CloudEmmisivity == 0, "NoCld", "YesCld")
MissingMAIAC$HasCldRad <- ifelse(MissingMAIAC$CloudRadius == 0, "NoCld", "YesCld")
MissingMAIAC$HasCldAOD <- ifelse(MissingMAIAC$CloudAOD == 0, "NoCld", "YesCld")
MissingMAIAC$HasCldMODHgt <- ifelse(is.na(MissingMAIAC$CloudTopHgt), "NoCld", "YesCld")
xtabs(~CatCloudBase + Raining, MissingMAIAC) # Cloud base is unreliable as indicator of cloud?
xtabs(~ HasCldEmis + HasCldRad + HasCldAOD + HasCldMODHgt, MissingMAIAC)
MissingMAIAC$MODCld <- ifelse(MissingMAIAC$HasCldEmis == "YesCld" & MissingMAIAC$HasCldRad == "YesCld" & MissingMAIAC$HasCldAOD == "YesCld" & MissingMAIAC$HasCldMODHgt == "YesCld", "YesCld", ifelse(MissingMAIAC$HasCldEmis == "NoCld" & MissingMAIAC$HasCldRad == "NoCld" & MissingMAIAC$HasCldAOD == "NoCld" & MissingMAIAC$HasCldMODHgt == "NoCld", "NoCld", "MaybeCld"))
xtabs(~ MODCld + CloudPhase, MissingMAIAC)
MissingMAIAC$MODCld2 <- ifelse(MissingMAIAC$CloudPhase == 0 & MissingMAIAC$MODCld == "YesCld", "MaybeCld", MissingMAIAC$MODCld)
xtabs(~ MODCld2 + Raining, MissingMAIAC)
MissingMAIAC$MODRUCCld <- ifelse(MissingMAIAC$MODCld2 == "NoCld" & MissingMAIAC$Raining == 1, "MaybeCld", MissingMAIAC$MODCld2)
xtabs(~ MODRUCCld + MAIACcat, MissingMAIAC)
MissingMAIAC$MODMAIACRUCCld <- ifelse((MissingMAIAC$MODRUCCld == "NoCld" & MissingMAIAC$MAIACcat == "Cloud") | (MissingMAIAC$MODRUCCld == "YesCld" & MissingMAIAC$MAIACcat == "Glint"), "MaybeCld", MissingMAIAC$MODRUCCld)
summary(as.factor(MissingMAIAC$MODMAIACRUCCld))
# NA's in MODMAIACRUCCld variable are missing RUC information - remove
MissingMAIAC <- subset(MissingMAIAC, !is.na(MissingMAIAC$MODMAIACRUCCld))
# Make a categorical variable that combines the Yes Clouds in MODMAIACRUCCld with Cloud Phase
MissingMAIAC$CloudCatFin <- ifelse(MissingMAIAC$MODMAIACRUCCld == "MaybeCld", "MaybeCld", ifelse(MissingMAIAC$MODMAIACRUCCld == "NoCld", "NoCld", ifelse(MissingMAIAC$CloudPhase == 1, "WaterCld", ifelse(MissingMAIAC$CloudPhase == 2, "IceCld", "UndetCld"))))
xtabs(~CloudCatFin + AquaTerraFlag, MissingMAIAC)
#summary(MissingMAIAC[MissingMAIAC$AquaTerraFlag == "A" & MissingMAIAC$CloudCatFin == "NoCld",35:41]*100)
#summary(MissingMAIAC[MissingMAIAC$AquaTerraFlag == "T" & MissingMAIAC$CloudCatFin == "NoCld",35:41]*100)
#summary(MissingMAIAC[MissingMAIAC$AquaTerraFlag == "A" & MissingMAIAC$CloudCatFin == "MaybeCld",35:41]*100)
#summary(MissingMAIAC[MissingMAIAC$AquaTerraFlag == "T" & MissingMAIAC$CloudCatFin == "MaybeCld",35:41]*100)
#summary(MissingMAIAC[MissingMAIAC$AquaTerraFlag == "A" & MissingMAIAC$CloudCatFin == "UndetCld",35:41]*100)
#summary(MissingMAIAC[MissingMAIAC$AquaTerraFlag == "T" & MissingMAIAC$CloudCatFin == "UndetCld",35:41]*100)
#summary(MissingMAIAC[MissingMAIAC$AquaTerraFlag == "A" & MissingMAIAC$CloudCatFin == "IceCld",35:41]*100)
#summary(MissingMAIAC[MissingMAIAC$AquaTerraFlag == "T" & MissingMAIAC$CloudCatFin == "IceCld",35:41]*100)
##summary(MissingMAIAC[MissingMAIAC$AquaTerraFlag == "A" & MissingMAIAC$CloudCatFin == "WaterCld",35:41]*100)
#summary(MissingMAIAC[MissingMAIAC$AquaTerraFlag == "T" & MissingMAIAC$CloudCatFin == "WaterCld",35:41]*100)
# Do Cloud top height categories - "None", "Low", "High"
MissingMAIAC$CldHgtCat <- ifelse(is.na(MissingMAIAC$CloudTopHgt), "None", ifelse(MissingMAIAC$CloudTopHgt < 5000, "Low", "High"))
MissingMAIAC$CloudCatFin2 <- ifelse(MissingMAIAC$MODMAIACRUCCld == "MaybeCld", "MaybeCld", ifelse(MissingMAIAC$MODMAIACRUCCld == "NoCld", "NoCld", MissingMAIAC$CldHgtCat))
# Make separate Terra and Aqua datasets
Terra <- subset(MissingMAIAC, MissingMAIAC$AquaTerraFlag == "T")
Aqua <- subset(MissingMAIAC, MissingMAIAC$AquaTerraFlag == "A")
rm(Clouds, Dat, FirstCollocOnly, G24, MissingMAIAC, S24)

## ---------
## Modeling - Individual-level (Preliminary) - treating fractions as separate y variables
## ---------



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