## --------------
## Name: ExCombEPAMAIACCldRUC.R
## Program version: R 3.2.3
## Program dependencies:
## Data dependencies:
## Author: J.H. Belle
## Purpose: Examine the 2009-2011 data and start model-building
## --------------

# Get summary stats from original dataset
#OrigDat <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24hr.csv", stringsAsFactors = F)
OrigDat <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlG24hr.csv", stringsAsFactors = F)
OrigDat$Date <- as.Date(OrigDat$Date, "%Y-%m-%d")
# Need overall and seasonal summaries
OrigDat$Month <- as.integer(as.character(OrigDat$Date, "%m"))
OrigDat$Year <- as.integer(as.character(OrigDat$Date, "%Y"))
OrigDat$Season <- ifelse(OrigDat$Month == 3 | OrigDat$Month == 4 | OrigDat$Month == 5, "Spring", ifelse(OrigDat$Month == 6 | OrigDat$Month == 7 | OrigDat$Month == 8, "Summer", ifelse(OrigDat$Month == 9 | OrigDat$Month == 10 | OrigDat$Month == 11, "Fall", "Winter")))
aggregate(X24hrPM~Season, OrigDat, length)
aggregate(X24hrPM~Season, OrigDat, mean)
aggregate(X24hrPM~Season, OrigDat, median)

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
#aggregate(OrigPM ~ AquaTerraFlag, FirstCollocOnly, mean)
#aggregate(OrigPM ~ AquaTerraFlag, FirstCollocOnly, median)

MissingMAIAC <- subset(FirstCollocOnly, is.na(FirstCollocOnly$AOD47) & is.na(FirstCollocOnly$AOD55))
#xtabs(~AquaTerraFlag, MissingMAIAC)
#xtabs(~AquaTerraFlag + Glint + Cloud, MissingMAIAC)
#aggregate(OrigPM ~ AquaTerraFlag, MissingMAIAC, mean)
#aggregate(OrigPM ~ AquaTerraFlag + Cloud + Glint, MissingMAIAC, mean)
#aggregate(OrigPM ~ AquaTerraFlag, MissingMAIAC, median)
#hist(MissingMAIAC$Dist)
#summary(MissingMAIAC)
#aggregate(Cloud ~ AquaTerraFlag, MissingMAIAC, mean)
#aggregate(Glint ~ AquaTerraFlag, MissingMAIAC, mean)
# Remove anything with a distance greater than 1 km - not a true collocation and small in number
#MissingMAIAC <- subset(MissingMAIAC, MissingMAIAC$Dist < 1000)
# Filter 2: Cloud product - characterize clouds as high, low or none
# Was missing cloud product?
#Clouds <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CloudAgg_10km.csv", stringsAsFactors = F)
Clouds <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CloudAgg_Atl10km.csv", stringsAsFactors = F)
#Clouds <- read.csv("E://CloudAgg_10km.csv")
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
#xtabs(~MAIACcat + AquaTerraFlag, MissingMAIAC)
#aggregate(OrigPM ~ MAIACcat + AquaTerraFlag, MissingMAIAC, mean)
#aggregate(OrigPM ~ MAIACcat + AquaTerraFlag, MissingMAIAC, median)
# Toss MAIAC variables
MissingMAIAC <- MissingMAIAC[!is.na(MissingMAIAC$MAIACcat),c(1:7,18,26:60)]
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
# Make tabulations
#xtabs(~CloudPhase+AquaTerraFlag, MissingMAIAC)
#aggregate(CloudEmmisivity~CloudPhase+AquaTerraFlag, MissingMAIAC, mean, rm.na=T)
#aggregate(CloudRadius~CloudPhase+AquaTerraFlag, MissingMAIAC, mean, rm.na=T)
#aggregate(CloudAOD~CloudPhase+AquaTerraFlag, MissingMAIAC, mean, rm.na=T)
# Need to do tabulations on mismatches in definitions
MissingMAIAC$HasCldEmis <- ifelse(MissingMAIAC$CloudEmmisivity == 0, "NoCld", "YesCld")
MissingMAIAC$HasCldRad <- ifelse(MissingMAIAC$CloudRadius == 0, "NoCld", "YesCld")
MissingMAIAC$HasCldAOD <- ifelse(MissingMAIAC$CloudAOD == 0, "NoCld", "YesCld")
MissingMAIAC$HasCldMODHgt <- ifelse(is.na(MissingMAIAC$CloudTopHgt), "NoCld", "YesCld")
#xtabs(~CatCloudBase + Raining, MissingMAIAC) # Cloud base is unreliable as indicator of cloud?
#xtabs(~ HasCldEmis + HasCldRad + HasCldAOD + HasCldMODHgt, MissingMAIAC)
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
#xtabs(~CloudCatFin + AquaTerraFlag, MissingMAIAC)
#xtabs(~CloudCatFin + AquaTerraFlag + Raining + Season, MissingMAIAC)
#aggregate(OrigPM ~ CloudCatFin + AquaTerraFlag, MissingMAIAC, mean)
#aggregate(OrigPM ~ CloudCatFin + AquaTerraFlag, MissingMAIAC, median)
#aggregate(OrigPM ~ CloudCatFin + AquaTerraFlag, MissingMAIAC, summary)
#ggplot(MissingMAIAC, aes(OrigPM)) + geom_histogram() + facet_grid(CloudCatFin ~ AquaTerraFlag)
# Do Cloud top height categories - "None", "Low", "High"
MissingMAIAC$CldHgtCat <- ifelse(is.na(MissingMAIAC$CloudTopHgt), "None", ifelse(MissingMAIAC$CloudTopHgt < 5000, "Low", "High"))
MissingMAIAC$CloudCatFin2 <- ifelse(MissingMAIAC$MODMAIACRUCCld == "MaybeCld", "MaybeCld", ifelse(MissingMAIAC$MODMAIACRUCCld == "NoCld", "NoCld", MissingMAIAC$CldHgtCat))
MissingMAIAC$pblh = MissingMAIAC$hpbl_surface/1000
MissingMAIAC$prate <- MissingMAIAC$prate_surface*1000
MissingMAIAC$CenteredTemp = MissingMAIAC$X2t_heightAboveGround - 273.15
MissingMAIAC$cape2 = MissingMAIAC$cape_surface/1000
# Add station XY information
Stationlocs <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlStationLocs_XY.csv", stringsAsFactors = F)
CentroidX = 1076436.4 #Atl
CentroidY = -544307.2 #Atl
#Stationlocs <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifStationLocs_XY.csv", stringsAsFactors = F)
#CentroidX = -2179644.1 #Atl
#CentroidY = 258174.0 #Atl
StationLocs = Stationlocs[,c("State", "County", "Site", "POINT_X", "POINT_Y")]
MissingMAIAC <- merge(MissingMAIAC, StationLocs)
MissingMAIAC$CenteredX = MissingMAIAC$POINT_X - CentroidX
MissingMAIAC$CenteredY = MissingMAIAC$POINT_Y - CentroidY
# Make separate Terra and Aqua datasets
Terra <- subset(MissingMAIAC, MissingMAIAC$AquaTerraFlag == "T")
Aqua <- subset(MissingMAIAC, MissingMAIAC$AquaTerraFlag == "A")
#rm(Clouds, Dat, FirstCollocOnly, G24, MissingMAIAC, OrigDat)

#xtabs(~ Raining + CloudCat + Multi, Aqua)

# Fit manual models
# Glint/no Cloud
#AIC(lm(LogPM ~ as.factor(Month) + r_heightAboveGround + cape_surface + X10u_heightAboveGround + X10v_heightAboveGround + sd_surface + prate_surface + hpbl_surface, subset(Terra, Terra$CloudCat == "None")))
#summary(lm(LogPM ~ as.factor(Month) + r_heightAboveGround + cape_surface + X10u_heightAboveGround + X10v_heightAboveGround + sd_surface + prate_surface + hpbl_surface , subset(Aqua, Aqua$CloudCat == "None")))

# Clouds
#AIC(lm(LogPM ~ as.factor(Month) + r_heightAboveGround + cape_surface + X10u_heightAboveGround + X10v_heightAboveGround + sd_surface + CloudAOD + prate_surface, subset(Terra, Terra$CloudCat == "High")))
#AIC(lm(LogPM ~ as.factor(Month) + r_heightAboveGround + cape_surface + X10u_heightAboveGround + X10v_heightAboveGround + sd_surface + CloudAOD + prate_surface, subset(Terra, Terra$CloudCat == "Low")))
#summary(lm(LogPM ~ as.factor(Month) + r_heightAboveGround + cape_surface + X10u_heightAboveGround + X10v_heightAboveGround + sd_surface + CloudAOD + prate_surface, subset(Aqua, Aqua$CloudCat == "High")))
#summary(lm(LogPM ~ as.factor(Month) + r_heightAboveGround + cape_surface + X10u_heightAboveGround + X10v_heightAboveGround + sd_surface + CloudAOD + prate_surface + r_heightAboveGround*CloudAOD, subset(Aqua, Aqua$CloudCat == "Low")))

#summary(lm(LogPM ~ as.factor(Month) + as.factor(Year) + CenteredTemp + r_heightAboveGround + WindSpeed + pblh + cape2, Terra))
#confint(lm(LogPM ~ as.factor(Month) + as.factor(Year) + CenteredTemp + r_heightAboveGround + WindSpeed + pblh + cape2, Terra))
#summary(lm(LogPM ~ as.factor(Month) + as.factor(Year) + CenteredTemp + r_heightAboveGround + WindSpeed + pblh + cape2, Aqua))

# Mixture modeling
Terra2 <- subset(Terra, Terra$CloudCatFin != "NoCld" & !is.na(Terra$X2t_heightAboveGround))
#Terra2 <- subset(Terra, (Terra$CloudCatFin == "IceCld" | Terra$CloudCatFin == "WaterCld") & !is.na(Terra$X2t_heightAboveGround))
#Terra2 <- subset(Terra, !is.na(Terra$hpbl_surface))

#library(flexmix)
# Full model
#TerraMod = stepFlexmix(LogPM ~ as.factor(Month) + as.factor(Year) + CenteredTemp + r_heightAboveGround + WindSpeed + cape2 + pblh + Raining + CloudEmmisivity + CloudRadius + CloudAOD + as.factor(CloudCatFin), Terra2, k=seq(1,6))
#TerraMod
#TerraMod = stepFlexmix(LogPM ~ as.factor(Month) + as.factor(Year) + r_heightAboveGround + CenteredTemp + pblh + WindSpeed + Raining + CloudAOD + CloudRadius | as.factor(CloudCatFin), Terra2, k=seq(1,10))
#TerraMod
# Need to separate out all 4 components to get the best performance
#TerraMod = flexmix(LogPM ~ as.factor(Month) + as.factor(Year) + CenteredTemp + r_heightAboveGround + WindSpeed + cape2 + pblh + Raining + CloudEmmisivity + CloudRadius + CloudAOD, Terra2, k=4)
#TerraMod
#summary(TerraMod)


TestMod = lmer(LogPM ~ CenteredTemp + r_heightAboveGround + WindSpeed + cape2 + pblh + Raining + CloudEmmisivity + CloudRadius + CloudAOD + CenteredX + CenteredY + CenteredX^2 + CenteredY^2 + CenteredX*CenteredY + (1+CenteredTemp|Date), data=Terra2[Terra2$CloudCatFin == "IceCld",])
summary(TestMod)
rsquared(list(TestMod))
TestMod = lmer(LogPM ~ CenteredTemp + r_heightAboveGround + WindSpeed + cape2 + pblh + Raining + CloudEmmisivity + CloudRadius + CloudAOD + CenteredX + CenteredY + CenteredX^2 + CenteredY^2 + CenteredX*CenteredY + (1+CenteredTemp|Date), data=Terra2[Terra2$CloudCatFin == "WaterCld",])
summary(TestMod)
rsquared(list(TestMod))
TestMod = lmer(LogPM ~ CenteredTemp + r_heightAboveGround + WindSpeed + cape2 + pblh + Raining + CloudEmmisivity + CloudRadius + CloudAOD + CenteredX + CenteredY + CenteredX^2 + CenteredY^2 + CenteredX*CenteredY + (1+CenteredTemp|Date), data=Terra2[Terra2$CloudCatFin == "MaybeCld" | Terra2$CloudCatFin == "UndetCld",])
summary(TestMod)
rsquared(list(TestMod))

#Terra3 <- Terra[Terra$CloudCatFin != "NoCld",]
#Terra3$CloudCat3 <- ifelse(Terra3$CloudCatFin == "UndetCld", "MaybeCld", Terra3$CloudCatFin)

#TerraMod = flexmix(.~.|as.factor(CloudCat3), k=3, model=FLXMRlmm(LogPM ~ CenteredTemp + r_heightAboveGround + WindSpeed + cape2 + pblh + Raining + CloudEmmisivity + CloudRadius + CloudAOD, random=~Year/Month), data=Terra3[!is.na(Terra3$X2t_heightAboveGround),])


#summary(as.factor(Terra2$CloudCatFin[which(TerraMod@cluster==1)]))
#summary(as.factor(Terra2$CloudCatFin[which(TerraMod@cluster==2)]))
#summary(as.factor(TerraMod@group[which(TerraMod@cluster==3)]))
#summary(as.factor(TerraMod@group[which(TerraMod@cluster==4)]))

#TMrf <- refit(TerraMod)
#summary(TMrf)

#TerraMod = flexmix(LogPM ~ as.factor(Month) + as.factor(Year) + r_heightAboveGround + CenteredTemp + pblh + cape2 + WindSpeed + Raining + CloudAOD + CloudRadius | as.factor(CloudCatFin), Terra2, k=4)
#TerraMod
#summary(TerraMod)

#summary(as.factor(TerraMod@group[which(TerraMod@cluster==1)]))
#summary(as.factor(TerraMod@group[which(TerraMod@cluster==2)]))
#summary(as.factor(TerraMod@group[which(TerraMod@cluster==3)]))
#summary(as.factor(TerraMod@group[which(TerraMod@cluster==4)]))

#TMrf <- refit(TerraMod)
#summary(TMrf)


Aqua2 <- subset(Aqua, Aqua$CloudCatFin != "NoCld" & !is.na(Aqua$X2t_heightAboveGround))
#Aqua2 <- subset(Aqua, (Aqua$CloudCatFin == "IceCld" | Aqua$CloudCatFin == "WaterCld") & !is.na(Aqua$X2t_heightAboveGround))

TestMod = lmer(LogPM ~ CenteredTemp + r_heightAboveGround + WindSpeed + cape2 + pblh + Raining + CloudEmmisivity + CloudRadius + CloudAOD + CenteredX + CenteredY + CenteredX^2 + CenteredY^2 + CenteredX*CenteredY + (1+CenteredTemp|Date), data=Aqua2[Aqua2$CloudCatFin == "UndetCld" | Aqua2$CloudCatFin == "MaybeCld",])
summary(TestMod)
rsquared(list(TestMod))

TestMod = lmer(LogPM ~ CenteredTemp + r_heightAboveGround + WindSpeed + cape2 + pblh + Raining + CloudEmmisivity + CloudRadius + CloudAOD + CenteredX + CenteredY + CenteredX^2 + CenteredY^2 + CenteredX*CenteredY + (1+CenteredTemp|Date), data=Aqua2[Aqua2$CloudCatFin == "IceCld",])
summary(TestMod)
rsquared(list(TestMod))

TestMod = lmer(LogPM ~ CenteredTemp + r_heightAboveGround + WindSpeed + cape2 + pblh + Raining + CloudEmmisivity + CloudRadius + CloudAOD + CenteredX + CenteredY + CenteredX^2 + CenteredY^2 + CenteredX*CenteredY + (1+CenteredTemp|Date), data=Aqua2[Aqua2$CloudCatFin == "WaterCld",])
summary(TestMod)
rsquared(list(TestMod))

#AquaMod = stepFlexmix(LogPM ~ as.factor(Month) + as.factor(Year) + Raining + WindSpeed + r_heightAboveGround + CenteredTemp + CloudEmmisivity + CloudRadius + CloudAOD | as.factor(CloudCatFin), Aqua2, k=seq(1,10))
#AquaMod
#AquaMod = stepFlexmix(LogPM ~ as.factor(Month) + as.factor(Year) + Raining + WindSpeed + r_heightAboveGround + CenteredTemp + cape2 + CloudAOD + CloudRadius | as.factor(CloudCatFin), Aqua2, k=seq(1,10))
#AquaMod
# There's 3 component that would work better than the 4 component, but the 4 component is ok
#AquaMod = flexmix(LogPM ~ as.factor(Month) + as.factor(Year) + CenteredTemp + r_heightAboveGround + WindSpeed + cape2 + pblh + Raining + CloudEmmisivity + CloudRadius | as.factor(CloudCatFin), Aqua2, k=4)
#AquaMod = flexmix(LogPM ~ as.factor(Month) + as.factor(Year) + CenteredTemp + r_heightAboveGround + WindSpeed + cape2 + pblh + Raining + CloudAOD + CloudRadius + CloudEmmisivity | as.factor(CloudCatFin), Aqua2, k=4)
#AquaMod
#summary(AquaMod)

#summary(as.factor(AquaMod@group[which(AquaMod@cluster==1)]))
#summary(as.factor(AquaMod@group[which(AquaMod@cluster==2)]))
#summary(as.factor(AquaMod@group[which(AquaMod@cluster==3)]))
#summary(as.factor(AquaMod@group[which(AquaMod@cluster==4)]))
#summary(as.factor(AquaMod@group[which(AquaMod@cluster==5)]))

#AMrf <- refit(AquaMod)
#summary(AMrf)

# Order of components below may differ
#ResOut <- cbind.data.frame(unname(AMrf@components[[1]]$Comp.3[,1]), unname(AMrf@components[[1]]$Comp.4[,1]), unname(AMrf@components[[1]]$Comp.2[,1]), unname(AMrf@components[[1]]$Comp.1[,1]), exp(unname(AMrf@components[[1]]$Comp.3[,1])), exp(unname(AMrf@components[[1]]$Comp.4[,1])), exp(unname(AMrf@components[[1]]$Comp.2[,1])), exp(unname(AMrf@components[[1]]$Comp.1[,1])), unname(AMrf@components[[1]]$Comp.3[,2]), unname(AMrf@components[[1]]$Comp.4[,2]), unname(AMrf@components[[1]]$Comp.2[,2]), unname(AMrf@components[[1]]$Comp.1[,2]), unname(AMrf@components[[1]]$Comp.3[,4]), unname(AMrf@components[[1]]$Comp.4[,4]), unname(AMrf@components[[1]]$Comp.2[,4]), unname(AMrf@components[[1]]$Comp.1[,4]))

#write.table(ResOut, "T://eohprojs/CDC_climatechange/Jess/Dissertation/AquaOutCalif.txt", row.names=F, colnames=F)
#write.table(ResOut, "T://eohprojs/CDC_climatechange/Jess/Dissertation/AquaOutAtl.txt", row.names=F, col.names=F)

ConvDat <- function(data, AQ, Mod, PMSpec="TotMass", site){
  TerraIceMod = lmer(LogPM ~ CenteredTemp + r_heightAboveGround + WindSpeed + cape2 + pblh + Raining + CloudEmmisivity + CloudRadius + CloudAOD + (1|Year/Month) + (1|County/Site), data=data)
  TerraIceCoefs = as.data.frame(summary(TerraIceMod)$coefficients)
  TerraIceCoefs$Vars = as.vector(dimnames(summary(TerraIceMod)$coefficients)[[1]])
  TerraIceCIs = as.data.frame(confint(TerraIceMod))
  TerraIceCIs$Vars = as.vector(dimnames(confint(TerraIceMod))[[1]])
  TerraIce = merge(TerraIceCoefs, TerraIceCIs, by="Vars")
  TerraIce$AQ <- rep(AQ, nrow(TerraIce))
  TerraIce$Mod <- rep(Mod, nrow(TerraIce))
  TerraIce$PMSpec <- rep(PMSpec, nrow(TerraIce))
  TerraIce$Site <- rep(site, nrow(TerraIce))
  return(TerraIce)
}

Terra2 <- subset(Terra, Terra$CloudCatFin != "NoCld" & !is.na(Terra$X2t_heightAboveGround))

#TIceAtl = ConvDat(Terra2[Terra2$CloudCatFin == "IceCld",], "T", "Ice", site="Atl")
#TWaterAtl = ConvDat(Terra2[Terra2$CloudCatFin == "WaterCld",], "T", "Water", site="Atl")
#TPossAtl = ConvDat(Terra2[Terra2$CloudCatFin == "UndetCld" | Terra2$CloudCatFin == "MaybeCld",], "T", "Maybe", site="Atl")

TIceSF = ConvDat(Terra2[Terra2$CloudCatFin == "IceCld",], "T", "Ice", site="SF")
TWaterSF = ConvDat(Terra2[Terra2$CloudCatFin == "WaterCld",], "T", "Water", site="SF")
TPossSF = ConvDat(Terra2[Terra2$CloudCatFin == "UndetCld" | Terra2$CloudCatFin == "MaybeCld",], "T", "Maybe", site="SF")

Aqua2 <- subset(Aqua, Aqua$CloudCatFin != "NoCld" & !is.na(Aqua$X2t_heightAboveGround))

#AIceAtl = ConvDat(Aqua2[Aqua2$CloudCatFin == "IceCld",], "A", "Ice", site="Atl")
#AWaterAtl = ConvDat(Aqua2[Aqua2$CloudCatFin == "WaterCld",], "A", "Water", site="Atl")
#APossAtl = ConvDat(Aqua2[Aqua2$CloudCatFin == "UndetCld" | Aqua2$CloudCatFin == "MaybeCld",], "A", "Maybe", site="Atl")

AIceSF = ConvDat(Aqua2[Aqua2$CloudCatFin == "IceCld",], "A", "Ice", site="SF")
AWaterSF = ConvDat(Aqua2[Aqua2$CloudCatFin == "WaterCld",], "A", "Water", site="SF")
APossSF = ConvDat(Aqua2[Aqua2$CloudCatFin == "UndetCld" | Aqua2$CloudCatFin == "MaybeCld",], "A", "Maybe", site="SF")

#TotMassAtl = rbind.data.frame(TIceAtl, TWaterAtl, TPossAtl, AIceAtl, AWaterAtl, APossAtl)
TotMassSF = rbind.data.frame(TIceSF, TWaterSF, TPossSF, AIceSF, AWaterSF, APossSF)

