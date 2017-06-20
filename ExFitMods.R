## --------------
## Name: ExCombEPAMAIACCldRUC.R
## Program version: R 3.2.3
## Program dependencies:
## Data dependencies:
## Author: J.H. Belle
## Purpose: Examine the 2009-2011 data and start model-building
## --------------

# Read in data
Dat <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24_MAIACCldRUC_10km.csv", stringsAsFactors = F)
#Dat <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlG24_MAIACCldRUC.csv", stringsAsFactors = F)
Dat$Date <- as.Date(Dat$Date, "%Y-%m-%d")
G24 <- Dat

# Remove regular AOD values less than 0 - these are missing
G24$AOD47 <- ifelse(G24$AOD47 < 0, NA, G24$AOD47)
G24$AOD55 <- ifelse(G24$AOD55 < 0, NA, G24$AOD55)

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


MissingMAIAC <- subset(FirstCollocOnly, !is.na(FirstCollocOnly$AOD47) & !is.na(FirstCollocOnly$AOD55))

#Clouds <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CloudAgg_10km.csv", stringsAsFactors = F)
#Clouds <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CloudAgg_Atl10km.csv", stringsAsFactors = F)
Clouds <- read.csv("E://CloudAgg_10km.csv")
Clouds$Date <- as.Date(Clouds$Date, "%Y-%m-%d")
Clouds$X <- NULL
MissingMAIAC <- merge(MissingMAIAC, Clouds, all.x=T)
MissingMAIAC$CloudCat <- ifelse(MissingMAIAC$PAnyCld == 0 | is.na(MissingMAIAC$PAnyCld), "None", ifelse(MissingMAIAC$CloudTopHgt < 5000, "Low", ifelse(MissingMAIAC$CloudTopHgt >=5000, "High", "Missing")))
# Filter 3: RUC -
MissingMAIAC$Raining <- ifelse(MissingMAIAC$prate_surface == 0, 0, 1)
MissingMAIAC$Snow <- ifelse(MissingMAIAC$sd_surface == 0, 0, 1)
MissingMAIAC$Multi <- ifelse(MissingMAIAC$PMultiCld == 0, 0, 1)
# Will need to double-check this categorization for each dataset
MissingMAIAC$MAIACcat <- ifelse(MissingMAIAC$Cloud == 1 | MissingMAIAC$Partcloud == 1 | MissingMAIAC$CloudShadow == 1, "Cloud", ifelse(MissingMAIAC$Glint == 1 | MissingMAIAC$Clear == 1 | MissingMAIAC$Snow == 1, "Glint", NA))
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
MissingMAIAC$HasCldEmis <- ifelse(MissingMAIAC$CloudEmmisivity == 0, "NoCld", "YesCld")
MissingMAIAC$HasCldRad <- ifelse(MissingMAIAC$CloudRadius == 0, "NoCld", "YesCld")
MissingMAIAC$HasCldAOD <- ifelse(MissingMAIAC$CloudAOD == 0, "NoCld", "YesCld")
MissingMAIAC$HasCldMODHgt <- ifelse(is.na(MissingMAIAC$CloudTopHgt), "NoCld", "YesCld")
MissingMAIAC$MODCld <- ifelse(MissingMAIAC$HasCldEmis == "YesCld" & MissingMAIAC$HasCldRad == "YesCld" & MissingMAIAC$HasCldAOD == "YesCld" & MissingMAIAC$HasCldMODHgt == "YesCld", "YesCld", ifelse(MissingMAIAC$HasCldEmis == "NoCld" & MissingMAIAC$HasCldRad == "NoCld" & MissingMAIAC$HasCldAOD == "NoCld" & MissingMAIAC$HasCldMODHgt == "NoCld", "NoCld", "MaybeCld"))
xtabs(~ MODCld + CloudPhase, MissingMAIAC)
MissingMAIAC$MODCld2 <- ifelse(MissingMAIAC$CloudPhase == 0 & MissingMAIAC$MODCld == "YesCld", "MaybeCld", MissingMAIAC$MODCld)
#xtabs(~ MODCld2 + Raining, MissingMAIAC)
MissingMAIAC$MODRUCCld <- ifelse(MissingMAIAC$MODCld2 == "NoCld" & MissingMAIAC$Raining == 1, "MaybeCld", MissingMAIAC$MODCld2)
#xtabs(~ MODRUCCld + MAIACcat, MissingMAIAC)
MissingMAIAC$MODMAIACRUCCld <- ifelse((MissingMAIAC$MODRUCCld == "NoCld" & MissingMAIAC$MAIACcat == "Cloud") | (MissingMAIAC$MODRUCCld == "YesCld" & MissingMAIAC$MAIACcat == "Glint"), "MaybeCld", MissingMAIAC$MODRUCCld)
MissingMAIAC$MODMAIACRUCCld <- ifelse((MissingMAIAC$MODRUCCld == "NoCld" & MissingMAIAC$MAIACcat == "Cloud"), "MaybeCld", MissingMAIAC$MODRUCCld)
#summary(as.factor(MissingMAIAC$MODMAIACRUCCld))
# NA's in MODMAIACRUCCld variable are missing RUC information - remove
MissingMAIAC <- subset(MissingMAIAC, !is.na(MissingMAIAC$MODMAIACRUCCld))
# Make a categorical variable that combines the Yes Clouds in MODMAIACRUCCld with Cloud Phase
MissingMAIAC$CloudCatFin <- ifelse(MissingMAIAC$MODMAIACRUCCld == "MaybeCld", "MaybeCld", ifelse(MissingMAIAC$MODMAIACRUCCld == "NoCld", "NoCld", ifelse(MissingMAIAC$CloudPhase == 1, "WaterCld", ifelse(MissingMAIAC$CloudPhase == 2, "IceCld", "UndetCld"))))
xtabs(~CloudCatFin + AquaTerraFlag, MissingMAIAC)
MissingMAIAC$CldHgtCat <- ifelse(is.na(MissingMAIAC$CloudTopHgt), "None", ifelse(MissingMAIAC$CloudTopHgt < 5000, "Low", "High"))
MissingMAIAC$CloudCatFin2 <- ifelse(MissingMAIAC$MODMAIACRUCCld == "MaybeCld", "MaybeCld", ifelse(MissingMAIAC$MODMAIACRUCCld == "NoCld", "NoCld", MissingMAIAC$CldHgtCat))
MissingMAIAC$pblh = MissingMAIAC$hpbl_surface/1000
MissingMAIAC$prate <- MissingMAIAC$prate_surface*1000
MissingMAIAC$CenteredTemp = MissingMAIAC$X2t_heightAboveGround - 273.15
MissingMAIAC$cape2 = MissingMAIAC$cape_surface/1000
# Add station XY information
#Stationlocs <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlStationLocs_XY.csv", stringsAsFactors = F)
#CentroidX = 1076436.4 #Atl
#CentroidY = -544307.2 #Atl
Stationlocs <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifStationLocs_XY.csv", stringsAsFactors = F)
CentroidX = -2179644.1 #SF
CentroidY = 258174.0 #SF
StationLocs = Stationlocs[,c("State", "County", "Site", "POINT_X", "POINT_Y", "RASTERVALU")]
MissingMAIAC <- merge(MissingMAIAC, StationLocs)
MissingMAIAC$CenteredX = MissingMAIAC$POINT_X - CentroidX
MissingMAIAC$CenteredY = MissingMAIAC$POINT_Y - CentroidY
MissingMAIAC$Elev = MissingMAIAC$RASTERVALU/1000
SpatialVars = read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/SFMAIACgrid_Pred/SFGridFin/FinGridJoined.csv", stringsAsFactors = F)[,c("InputFID", "PercForest", "PRoadLengt", "NEIPM", "Elev")]
EPAtoMAIAC = read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/SFMAIACgrid_Pred/SFGridFin/EPAtoMAIAC.csv", stringsAsFactors = F)[,c("State", "County", "Site", "Input_FID")]
SpatialVars = merge(SpatialVars, EPAtoMAIAC, by.x="InputFID", by.y="Input_FID")
MissingMAIAC = merge(MissingMAIAC, SpatialVars, by=c("State", "County", "Site"))
MissingMAIAC$Elev.y= MissingMAIAC$Elev.y/1000
# Make separate Terra and Aqua datasets
Terra <- subset(MissingMAIAC, MissingMAIAC$AquaTerraFlag == "T" & !is.na(MissingMAIAC$CenteredTemp) & (as.character(MissingMAIAC$Date, "%Y") == "2012" | as.character(MissingMAIAC$Date, "%Y")=="2013" | as.character(MissingMAIAC$Date, "%Y") == "2014"))
Aqua <- subset(MissingMAIAC, MissingMAIAC$AquaTerraFlag == "A" & (as.character(MissingMAIAC$Date, "%Y") == "2012" | as.character(MissingMAIAC$Date, "%Y")=="2013" | as.character(MissingMAIAC$Date, "%Y") == "2014"))
#rm(Clouds, Dat, FirstCollocOnly, G24, MissingMAIAC, OrigDat)

library(MuMIn)
library(piecewiseSEM)
library(lme4)
# Test fit
mod = lmer(X24hrPM~AOD55 + pblh + CenteredTemp + WindSpeed + r_heightAboveGround + Elev.y + NEIPM + PRoadLengt + PercForest + (1+AOD55+WindSpeed|Date), Terra)
mod = lmer(X24hrPM ~ AOD55 + (1+AOD55|Date), Terra)
AIC(mod)
summary(mod)
r.squaredGLMM(mod)

moda = lmer(X24hrPM~AOD55 + pblh + CenteredTemp + WindSpeed + r_heightAboveGround + Elev.y + NEIPM + PRoadLengt + PercForest + (1+AOD55+WindSpeed|Date), Aqua)
moda = lmer(X24hrPM~AOD55 + (1+AOD55|Date), Aqua)
AIC(moda)
summary(moda)
r.squaredGLMM(moda)

