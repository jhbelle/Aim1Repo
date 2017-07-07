## ----------
## Name: Record_PredHarvard.R
## Program version: R 3.3.3
## Dependencies: gam
## Purpose: Record of commands used at the command line on cluster to read in file containing RUC, make predictions using Harvard Model, and save outputs
## ----------

<<<<<<< HEAD
=======
library(lme4)
>>>>>>> 1e745f2652fbc3b023dc2a536d347afa4ff52542
library(mgcv)

# Read in dataset - subset to day 1
test = read.csv("/aura/AggregatedDat_NoCld.csv", nrows=82780)
Day1dat = subset(test, test$Date == 1)

# Calculate predictor variable values
Day1dat$AOD55.y = ifelse(Day1dat$AOD55 == -28672, NA, Day1dat$AOD55)*0.001
Day1dat$pblh.y = ifelse(Day1dat$hpbl_surface < 0, NA, Day1dat$hbl_surface)/1000
Day1dat$CenteredTemp.y = Day1dat$X2t_heightAboveGround - 273.15
Day1dat$WindSpeed.y = sqrt(Day1dat$X10u_heightAboveGround^2 + Day1dat$X10v_heightAboveGround^2)
Day1dat$r_heightAboveGround.y = Day1dat$r_heightAboveGround
Day1dat$Elev.y.y = Day1dat$Elev
Day1dat$NEIPM.y = Day1dat$NEIPM
#Day1dat$PRoadLengt.y = Day1dat$PRoadLength
Day1dat$PercForest.y = Day1dat$PercForest
Day1dat$DOY = Day1dat$Date
RoadLengths = read.csv("/home/jhbelle/Data/SFGridFin/RdLengths_AllRds.csv")[,c("Input_FID", "RdLenkm")]
Day1dat = merge(Day1dat, RoadLengths, by.x="InputFID", by.y="Input_FID")

mainmodel = readRDS("/aura/mainmodela.Rdata")

Day1dat$Pred = predict(mainmodel, Day1dat, allow.new.levels=T)
Day1dat$Pred = ifelse(Day1dat$Pred > mean(Day1dat$Pred, na.rm=T) + 5*sd(Day1dat$Pred, na.rm=T), NA, Day1dat$Pred)

Day1PredMain = subset(Day1dat, !is.na(Day1dat$Pred))
write.csv(Day1PredMain, "/aura/Day1PredMain.csv")

Day1PredAlt = subset(Day1dat, is.na(Day1dat$Pred))
Day1PredAlt$DailyMean = rep(22.21, length(Day1PredAlt$Pred))
Day1PredAlt$POINT_X.y.y = Day1PredAlt$POINT_X
Day1PredAlt$POINT_Y.y.y = Day1PredAlt$POINT_Y

harvmodel = readRDS("/aura/harvmodel.Rdata")

<<<<<<< HEAD
harvardmodel2 = gam(pred ~ DailyMean + s(POINT_X, POINT_Y), data=Day1PredMain, method="REML")
Day1PredAlt$PredAlt2 = predict(harvardmodel2, Day1PredAlt)
=======
>>>>>>> 1e745f2652fbc3b023dc2a536d347afa4ff52542
Day1PredAlt$PredAlt = predict(harvmodel, Day1PredAlt)^2

write.csv(Day1PredAlt, "/aura/Day1PredAlt.csv")

Cld5km = read.csv("/aura/LinkedValsCloudCalif/DailyGridAOD_2012_001.csv")
Day1PredCld = merge(Day1PredAlt, Cld5km, by.x="InputFID", by.y="US.id")
<<<<<<< HEAD

=======
Cld1kmDat = read.csv("/aura/LinkedFilesCloud2/DailyGridAOD_2012_001.csv")[,c("US.id", "Index", "hr", "min")]
Cld1kmDat = unique(Cld1kmDat)
Cld1kmVals = read.csv("/aura/MODIScloud_extr_1km/Extr_2012_001_S1_A.csv")
Cld1kmVals$CloudAOD = ifelse(Cld1kmVals$CloudAOD == -9999, NA, Cld1kmVals$CloudAOD)*0.009999999776482582
Cld1kmVals$CloudEffRad = ifelse(Cld1kmVals$CloudEffRad == -9999, NA, Cld1kmVals$CloudEffRad)*0.009999999776482582
Cld1kmDat = merge(Cld1kmDat, Cld1kmVals, by.x=c("Index", "hr", "min"), by.y=c("MaskVal", "hr", "min"))
CloudAOD = aggregate(CloudAOD~US.id, Cld1kmDat, mean, na.rm=T)
Day1PredCld = merge(Day1PredCld, CloudAOD, by.x="InputFID", by.y="US.id")
CloudEffRad = aggregate(CloudEffRad~US.id, Cld1kmDat, mean, na.rm=T)
Day1PredCld = merge(Day1PredCld, CloudEffRad, by.x="InputFID", by.y="US.id")
summary(as.factor(Day1PredCld$CP))
WaterClouds=subset(Day1PredCld, Day1PredCld$CP == 1)
WaterClouds$cape2.y = WaterClouds$cape_surface/1000
WaterClouds$Raining.y = ifelse(WaterClouds$prate_surface == 0, 0, 1)
WaterClouds$CloudEmmisivity.y = WaterClouds$CE
WaterClouds$CloudRadius.y = WaterClouds$CloudEffRad
WaterClouds$CloudAOD.y = WaterClouds$CloudAOD

watermodel = readRDS("/aura/watercloudmodel.Rdata")

WaterClouds$PredWatCld = exp(predict(watermodel, WaterClouds))

WaterClouds$DiffMineHarv = WaterClouds$PredWatCld - WaterClouds$PredAlt

write.csv(WaterClouds, "/aura/Day1PredWaterCld.csv")
>>>>>>> 1e745f2652fbc3b023dc2a536d347afa4ff52542
