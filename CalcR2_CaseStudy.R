## -------------
## Name: CalcR2_CaseStudy.R
## Program version: R 3.2.3
## Dependencies:
## Author: J.H. Belle
## Purpose: Run CV R2 analysis on no gap-filling, my gap-filling, and harvard gap-filling models relating AOD to PM
## -------------


# Read in data
#Dat <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24_MAIACCldRUC_10km.csv", stringsAsFactors = F)
Dat <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlG24_MAIACCldRUC.csv", stringsAsFactors = F)
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


MissingMAIAC <- FirstCollocOnly

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
MissingMAIAC$DOY = as.integer(as.character(MissingMAIAC$Date, "%j"))
# Add station XY information
Stationlocs <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlStationLocs_XY.csv", stringsAsFactors = F)
CentroidX = 1076436.4 #Atl
CentroidY = -544307.2 #Atl
#Stationlocs <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifStationLocs_XY.csv", stringsAsFactors = F)
#CentroidX = -2179644.1 #SF
#CentroidY = 258174.0 #SF
StationLocs = Stationlocs[,c("State", "County", "Site", "POINT_X", "POINT_Y", "RASTERVALU")]
MissingMAIAC <- merge(MissingMAIAC, StationLocs)
MissingMAIAC$CenteredX = MissingMAIAC$POINT_X - CentroidX
MissingMAIAC$CenteredY = MissingMAIAC$POINT_Y - CentroidY
MissingMAIAC$Elev = MissingMAIAC$RASTERVALU/1000
#SpatialVars = read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/SFMAIACgrid_Pred/SFGridFin/FinGridJoined.csv", stringsAsFactors = F)[,c("InputFID", "PercForest", "PRoadLengt", "NEIPM", "Elev", "POINT_X", "POINT_Y")]
#EPAtoMAIAC = read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/SFMAIACgrid_Pred/SFGridFin/EPAtoMAIAC.csv", stringsAsFactors = F)[,c("State", "County", "Site", "Input_FID")]
#SpatialVars = merge(SpatialVars, EPAtoMAIAC, by.x="InputFID", by.y="Input_FID")
#MissingMAIAC = merge(MissingMAIAC, SpatialVars, by=c("State", "County", "Site"))
#MissingMAIAC$Elev.y= MissingMAIAC$Elev.y/1000
#MissingMAIAC$PRoadLengt = MissingMAIAC$PRoadLengt/1000

SpatialVars = read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/AtlMAIACgrid_Pred/FinalCopy_AtlPolys/FinGridJoined2.csv", stringsAsFactors = F)[,c("InputFID", "RdLen", "Elev", "PForst", "NEIPM")]
EPAtoMAIAC = read.csv("T:/eohprojs/CDC_climatechange/Jess/Dissertation/AtlMAIACgrid_Pred/FinalCopy_AtlPolys/EPAtoMAIAC.csv", stringsAsFactors = F)[,c("State", "County", "Site", "Input_FID")]
SpatialVars = merge(SpatialVars, EPAtoMAIAC, by.x="InputFID", by.y="Input_FID")
MissingMAIAC = merge(MissingMAIAC, SpatialVars, by=c("State", "County", "Site"))
# Make Single observation for each date
#MissingMAIAC = subset(MissingMAIAC, !is.na(MissingMAIAC$CenteredTemp))[,c("State", "County", "Site", "Date", "X24hrPM", "AquaTerraFlag", "AOD55", "r_heightAboveGround", "LogPM", "CloudAOD", "CloudRadius", "CloudEmmisivity", "Raining", "WindSpeed", "CloudCatFin", "pblh", "CenteredTemp", "cape2", "POINT_X.y", "POINT_Y.y", "Elev.y", "PercForest", "PRoadLengt", "NEIPM")]
MissingMAIAC = subset(MissingMAIAC, !is.na(MissingMAIAC$CenteredTemp))[,c("State", "County", "Site", "InputFID", "Date", "X24hrPM", "AquaTerraFlag", "AOD55", "r_heightAboveGround", "LogPM", "CloudAOD", "CloudRadius", "CloudEmmisivity", "Raining", "WindSpeed", "CloudCatFin", "pblh", "CenteredTemp", "cape2", "POINT_X", "POINT_Y", "Elev.y", "PForst", "RdLen", "NEIPM")]
colnames(MissingMAIAC) <- c("State", "County", "Site", "InputFID", "Date", "X24hrPM", "AquaTerraFlag", "AOD55", "r_heightAboveGround", "LogPM", "CloudAOD", "CloudRadius", "CloudEmmisivity", "Raining", "WindSpeed", "CloudCatFin", "pblh", "CenteredTemp", "cape2", "POINT_X.y", "POINT_Y.y", "Elev.y", "PercForest", "PRoadLengt", "NEIPM")
Terra = subset(MissingMAIAC, MissingMAIAC$AquaTerraFlag == "T")
Aqua = subset(MissingMAIAC, MissingMAIAC$AquaTerraFlag == "A")

CombTA = merge(Terra, Aqua, by=c("State", "County", "Site", "InputFID", "Date", "X24hrPM"))
CombTA$CrossValSet = sample(1:10, length(CombTA$County), replace=T)
CombTA$rownames = rownames(CombTA)
CombTA$DOY = as.integer(as.character(CombTA$Date, "%j"))
CombTA$Year = as.integer(as.character(CombTA$Date, "%Y"))
CombTA = subset(CombTA, CombTA$Year == 2012 | CombTA$Year == 2013 | CombTA$Year == 2014)
## --------
## No gap-filling model
## --------

library(MuMIn)
library(piecewiseSEM)
library(lme4)

# Fit models
for (i in seq(1,10)){
  mod = lmer(X24hrPM~AOD55.x + pblh.x + CenteredTemp.x + WindSpeed.x + r_heightAboveGround.x + Elev.y.x + NEIPM.x + PRoadLengt.x + PercForest.x + (1+AOD55.x|DOY), CombTA[CombTA$CrossValSet != i,])
  moda = lmer(X24hrPM~AOD55.y + pblh.y + CenteredTemp.y + WindSpeed.y + r_heightAboveGround.y + Elev.y.y + NEIPM.y + PRoadLengt.y + PercForest.y + (1+AOD55.y|DOY), CombTA[CombTA$CrossValSet != i,])
  predvalsT = predict(mod, CombTA[CombTA$CrossValSet == i,], allow.new.levels=T)
  predvalsA = predict(moda, CombTA[CombTA$CrossValSet == i,], allow.new.levels=T)
  if (exists("PredA")){ PredA = c(PredA, predvalsA) } else PredA = predvalsA
  if (exists("PredT")){ PredT = c(PredT, predvalsT) } else PredT = predvalsT
}

# Add predicted values into main dataset
PredA = cbind.data.frame(names(PredA), PredA)
colnames(PredA) <- c("rownames", "PredA")
PredA$rownames = as.character(PredA$rownames)
CombTA = merge(CombTA, PredA)
PredT = cbind.data.frame(names(PredT), PredT)
colnames(PredT) <- c("rownames", "PredT")
PredT$rownames = as.character(PredT$rownames)
CombTA = merge(CombTA, PredT)
# Average T + A
CombTA$CVPredNoGapFill = rowMeans(CombTA[,c("PredA", "PredT")], na.rm=T)
# Calculate R2
summary(lm(X24hrPM~CVPredNoGapFill, CombTA, na.action = "na.omit"))
rm(PredT, PredA)

## --------
# My gap fill
## --------

for (i in seq(1,10)){
  cloudt_w = try(lmer(LogPM.x ~ CenteredTemp.x + r_heightAboveGround.x + WindSpeed.x + cape2.x + pblh.x + Raining.x + CloudEmmisivity.x + CloudRadius.x + CloudAOD.x + (1|Date), CombTA[(CombTA$CrossValSet != i & CombTA$CloudCatFin.x == "WaterCld"),], na.action="na.omit"))
  cloudt_i = try(lmer(LogPM.x ~ CenteredTemp.x + r_heightAboveGround.x + WindSpeed.x + cape2.x + pblh.x + Raining.x + CloudEmmisivity.x + CloudRadius.x + CloudAOD.x + (1|Date), CombTA[CombTA$CrossValSet != i & CombTA$CloudCatFin.x == "IceCld",]))
  #cloudt_o = try(lmer(LogPM.x ~ CenteredTemp.x + r_heightAboveGround.x + WindSpeed.x + cape2.x + pblh.x + Raining.x + CloudEmmisivity.x + CloudRadius.x + CloudAOD.x + (1|Date), CombTA[CombTA$CrossValSet != i & (CombTA$CloudCatFin.x == "UndetCld" | CombTA$CloudCatFin.x == "MaybeCld"),]))
  clouda_w = try(lmer(LogPM.y ~ CenteredTemp.y + r_heightAboveGround.y + WindSpeed.y + cape2.y + pblh.y + Raining.y + CloudEmmisivity.y + CloudRadius.y + CloudAOD.y + (1|Date), CombTA[CombTA$CrossValSet != i & CombTA$CloudCatFin.y == "WaterCld",]))
  clouda_i = try(lmer(LogPM.y ~ CenteredTemp.y + r_heightAboveGround.y + WindSpeed.y + cape2.y + pblh.y + Raining.y + CloudEmmisivity.y + CloudRadius.y + CloudAOD.y + (1|Date), CombTA[CombTA$CrossValSet != i & CombTA$CloudCatFin.y == "IceCld",]))
  #clouda_o = try(lmer(LogPM.y ~ CenteredTemp.y + r_heightAboveGround.y + WindSpeed.y + cape2.y + pblh.y + Raining.y + CloudEmmisivity.y + CloudRadius.y + CloudAOD.y + (1|Date), CombTA[CombTA$CrossValSet != i & (CombTA$CloudCatFin.y == "UndetCld" | CombTA$CloudCatFin.y == "MaybeCld"),]))
  if (isLMM(cloudt_w)) predctw = predict(cloudt_w, CombTA[CombTA$CrossValSet == i & CombTA$CloudCatFin.x == "WaterCld",], allow.new.levels=T)
  if (isLMM(cloudt_i)) predcti = predict(cloudt_i, CombTA[CombTA$CrossValSet == i & CombTA$CloudCatFin.x == "IceCld",], allow.new.levels=T)
  if (isLMM(cloudt_o)) predcto = predict(cloudt_o, CombTA[CombTA$CrossValSet == i & (CombTA$CloudCatFin.x == "UnDetCld" | CombTA$CloudCatFin.x == "MaybeCld"),], allow.new.levels=T)
  if (isLMM(clouda_w)) predcaw = predict(clouda_w, CombTA[CombTA$CrossValSet == i & CombTA$CloudCatFin.y == "WaterCld",], allow.new.levels=T)
  if (isLMM(clouda_i)) predcai = predict(clouda_i, CombTA[CombTA$CrossValSet == i & CombTA$CloudCatFin.y == "IceCld",], allow.new.levels=T)
  if (isLMM(clouda_o)) predcao = predict(clouda_o, CombTA[CombTA$CrossValSet == i & (CombTA$CloudCatFin.y == "UnDetCld" | CombTA$CloudCatFin.y == "MaybeCld"),], allow.new.levels=T)
  if (exists("PredTw")){ PredTw = c(PredTw, predctw) } else PredTw = predctw
  if (exists("PredTi")){ PredTi = c(PredTi, predcti) } else PredTi = predcti
  if (exists("PredTo")){ PredTo = c(PredTo, predcto) } else PredTo = predcto
  if (exists("PredAw")){ PredAw = c(PredAw, predcaw) } else PredAw = predcaw
  if (exists("PredAi")){ PredAi = c(PredAi, predcai) } else PredAi = predcai
  if (exists("PredAo")){ PredAo = c(PredAo, predcao) } else PredAo = predcao
}


PredTw = cbind.data.frame(names(PredTw), exp(PredTw))
colnames(PredTw) <- c("rownames", "PredTw")
PredTw$rownames = as.character(PredTw$rownames)
CombTA = merge(CombTA, PredTw, all.x=T)

PredTi = cbind.data.frame(names(PredTi), exp(PredTi))
colnames(PredTi) <- c("rownames", "PredTi")
PredTi$rownames = as.character(PredTi$rownames)
CombTA = merge(CombTA, PredTi, all.x=T)

PredTo = cbind.data.frame(names(PredTo), exp(PredTo))
colnames(PredTo) <- c("rownames", "PredTo")
PredTo$rownames = as.character(PredTo$rownames)
CombTA = merge(CombTA, PredTo, all.x=T)

PredAw = cbind.data.frame(names(PredAw), exp(PredAw))
colnames(PredAw) <- c("rownames", "PredAw")
PredAw$rownames = as.character(PredAw$rownames)
CombTA = merge(CombTA, PredAw, all.x=T)

PredAi = cbind.data.frame(names(PredAi), exp(PredAi))
colnames(PredAi) <- c("rownames", "PredAi")
PredAi$rownames = as.character(PredAi$rownames)
CombTA = merge(CombTA, PredAi, all.x=T)

PredAo = cbind.data.frame(names(PredAo), exp(PredAo))
colnames(PredAo) <- c("rownames", "PredAo")
PredAo$rownames = as.character(PredAo$rownames)
CombTA = merge(CombTA, PredAo, all.x=T)
rm(PredTw, PredTi, PredTo, PredAw, PredAi, PredAo)

CombTA$PredCldA = rowSums(CombTA[,c("PredAw", "PredAi", "PredAo")], na.rm = T)
CombTA$PredCldA = ifelse(CombTA$PredCldA == 0, NA, CombTA$PredCldA)
CombTA$PredCldT = rowSums(CombTA[,c("PredTw", "PredTi", "PredTo")], na.rm = T)
CombTA$PredCldT = ifelse(CombTA$PredCldT == 0, NA, CombTA$PredCldT)

CombTA$PredWCld = rowMeans(CombTA[,c("PredCldA", "PredCldT", "PredT", "PredA")], na.rm=T)

summary(lm(X24hrPM~PredWCld, CombTA))

## -------
# Harvard gap fill
## -------

DailyMean = aggregate(X24hrPM~Date, CombTA, mean)
colnames(DailyMean) <- c("Date", "DailyMean")
CombTA = merge(CombTA, DailyMean, by="Date")

for (i in seq(1,10)){
  harvt = gam(X24hrPM~DailyMean + s(POINT_X.y.y, POINT_Y.y.y) + s(InputFID) + s(InputFID, DailyMean), data=CombTA[CombTA$CrossValSet != i,])
  pred = predict(harvt, CombTA[CombTA$CrossValSet == i,], type="response")
}
