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
#G24 <- subset(G24, G24$Dist < 1000)
# Subset data - remove anything with both AOD values missing - Filter 1
#G24$MissingMAIAC <- ifelse(is.na(G24$AOD47) & is.na(G24$AOD55), 1, 0)
# Get tabulations of MAIAC by missing status and T/A pass
#xtabs(~ MissingMAIAC + AquaTerraFlag, G24)
#xtabs(~AquaTerraFlag, G24)
#aggregate(X24hrPM ~ MissingMAIAC + AquaTerraFlag, G24, mean)
#aggregate(X24hrPM ~ MissingMAIAC + AquaTerraFlag, G24, median)

MissingMAIAC <- subset(G24, is.na(G24$AOD47) & is.na(G24$AOD55))
#hist(MissingMAIAC$Dist)
#summary(MissingMAIAC)
#aggregate(Cloud ~ AquaTerraFlag, MissingMAIAC, mean)
#aggregate(Glint ~ AquaTerraFlag, MissingMAIAC, mean)
# Remove anything with a distance greater than 1 km - not a true collocation and small in number
MissingMAIAC <- subset(MissingMAIAC, MissingMAIAC$Dist < 1000)
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
# Do Cloud top height categories - "None", "Low", "High"
MissingMAIAC$CldHgtCat <- ifelse(is.na(MissingMAIAC$CloudTopHgt), "None", ifelse(MissingMAIAC$CloudTopHgt < 5000, "Low", "High"))
# Make separate Terra and Aqua datasets
Terra <- subset(MissingMAIAC, MissingMAIAC$AquaTerraFlag == "T")
Aqua <- subset(MissingMAIAC, MissingMAIAC$AquaTerraFlag == "A")

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

# Mixture modeling
#Terra2 <- subset(Terra, Terra$CloudCatFin != "NoCld" & !is.na(Terra$hpbl_surface))
Terra2 <- subset(Terra, !is.na(Terra$hpbl_surface))
library(flexmix)
# Full model
TerraMod = stepFlexmix(LogPM ~ as.factor(Month) + as.factor(Year) + r_heightAboveGround + WindSpeed + hpbl_surface + prate_surface + CloudRadius + CloudAOD + CloudEmmisivity | as.factor(CloudCatFin), Terra2, k=seq(1,10))
TerraMod
# Need to separate out all 4 components to get the best performance
TerraMod = flexmix(LogPM ~ as.factor(Month) + as.factor(Year) + CatCloudBase + r_heightAboveGround + WindSpeed + prate_surface + CloudRadius + CloudAOD + CloudEmmisivity + CatCloudBase*CloudRadius + CatCloudBase*CloudAOD + CatCloudBase*CloudEmmisivity | as.factor(CloudPhase), Terra[!is.na(Terra$CloudCat) & !is.na(Terra$sd_surface),], k=4)
TerraMod
summary(as.factor(TerraMod@group[which(TerraMod@cluster==1)]))
summary(as.factor(TerraMod@group[which(TerraMod@cluster==2)]))
summary(as.factor(TerraMod@group[which(TerraMod@cluster==3)]))
summary(as.factor(TerraMod@group[which(TerraMod@cluster==4)]))
summary(TerraMod)
TMrf <- refit(TerraMod)
summary(TMrf)

# Order of components below may differ
ResOut <- cbind.data.frame(unname(TMrf@components[[1]]$Comp.2[,1]), unname(TMrf@components[[1]]$Comp.4[,1]), unname(TMrf@components[[1]]$Comp.3[,1]), unname(TMrf@components[[1]]$Comp.1[,1]), exp(unname(TMrf@components[[1]]$Comp.2[,1])), exp(unname(TMrf@components[[1]]$Comp.4[,1])), exp(unname(TMrf@components[[1]]$Comp.3[,1])), exp(unname(TMrf@components[[1]]$Comp.1[,1])), unname(TMrf@components[[1]]$Comp.2[,2]), unname(TMrf@components[[1]]$Comp.4[,2]), unname(TMrf@components[[1]]$Comp.3[,2]), unname(TMrf@components[[1]]$Comp.1[,2]), unname(TMrf@components[[1]]$Comp.2[,4]), unname(TMrf@components[[1]]$Comp.4[,4]), unname(TMrf@components[[1]]$Comp.3[,4]), unname(TMrf@components[[1]]$Comp.1[,4]))

#write.table(ResOut, "T://eohprojs/CDC_climatechange/Jess/Dissertation/TerraOutCalif.txt", row.names=F, col.names=F)
write.table(ResOut, "T://eohprojs/CDC_climatechange/Jess/Dissertation/TerraOutAtl.txt", row.names=F, col.names=F)

AquaMod = stepFlexmix(LogPM ~ as.factor(Month) + as.factor(Year) + CatCloudBase + r_heightAboveGround + WindSpeed + prate_surface + Snow + CloudRadius + CloudAOD + CloudEmmisivity + CatCloudBase*CloudRadius + CatCloudBase*CloudAOD + CatCloudBase*CloudEmmisivity | as.factor(CloudPhase), Aqua[!is.na(Aqua$sd_surface) & !is.na(Aqua$CloudCat),], k=seq(1,10))
# There's 3 component that would work better than the 4 component, but the 4 component is ok
AquaMod = flexmix(LogPM ~ as.factor(Month) + as.factor(Year) + CatCloudBase + r_heightAboveGround + WindSpeed + prate_surface + Snow + CloudRadius + CloudAOD + CloudEmmisivity + CatCloudBase*CloudRadius + CatCloudBase*CloudAOD + CatCloudBase*CloudEmmisivity | as.factor(CloudPhase), Aqua[!is.na(Aqua$sd_surface) & !is.na(Aqua$CloudCat),], k=4)
AquaMod
summary(as.factor(AquaMod@group[which(AquaMod@cluster==1)]))
summary(as.factor(AquaMod@group[which(AquaMod@cluster==2)]))
summary(as.factor(AquaMod@group[which(AquaMod@cluster==3)]))
summary(as.factor(AquaMod@group[which(AquaMod@cluster==4)]))
summary(AquaMod)
AMrf <- refit(AquaMod)
summary(AMrf)

# Order of components below may differ
ResOut <- cbind.data.frame(unname(AMrf@components[[1]]$Comp.3[,1]), unname(AMrf@components[[1]]$Comp.4[,1]), unname(AMrf@components[[1]]$Comp.2[,1]), unname(AMrf@components[[1]]$Comp.1[,1]), exp(unname(AMrf@components[[1]]$Comp.3[,1])), exp(unname(AMrf@components[[1]]$Comp.4[,1])), exp(unname(AMrf@components[[1]]$Comp.2[,1])), exp(unname(AMrf@components[[1]]$Comp.1[,1])), unname(AMrf@components[[1]]$Comp.3[,2]), unname(AMrf@components[[1]]$Comp.4[,2]), unname(AMrf@components[[1]]$Comp.2[,2]), unname(AMrf@components[[1]]$Comp.1[,2]), unname(AMrf@components[[1]]$Comp.3[,4]), unname(AMrf@components[[1]]$Comp.4[,4]), unname(AMrf@components[[1]]$Comp.2[,4]), unname(AMrf@components[[1]]$Comp.1[,4]))

#write.table(ResOut, "T://eohprojs/CDC_climatechange/Jess/Dissertation/AquaOutCalif.txt", row.names=F, colnames=F)
write.table(ResOut, "T://eohprojs/CDC_climatechange/Jess/Dissertation/AquaOutAtl.txt", row.names=F, col.names=F)

