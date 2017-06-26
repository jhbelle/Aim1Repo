## ----------
## Name: Record_PredHarvard.R
## Program version: R 3.3.3
## Dependencies: gam
## Purpose: Record of commands used at the command line on cluster to read in file containing RUC, make predictions using Harvard Model, and save outputs
## ----------

library(gam)

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
Day1dat$PRoadLengt.y = Day1dat$PRoadLength
Day1dat$PercForest.y = Day1dat$PercForest
Day1dat$DOY = Day1dat$Date

mainmodel = readRDS("/aura/mainmodel.Rdata")

Day1dat$Pred = predict(mainmodel, Day1dat, allow.new.levels=T)

Day1PredMain = subset(Day1dat, !is.na(Day1dat$Pred))
write.csv(Day1PredMain, "/aura/Day1PredMain.csv")

Day1PredAlt = subset(Day1dat, is.na(Day1dat$Pred))
Day1PredAlt$DailyMean = rep(22.21, length(Day1PredAlt$Pred))
Day1PredAlt$POINT_X.y.y = Day1PredAlt$POINT_X
Day1PredAlt$POINT_Y.y.y = Day1PredAlt$POINT_Y

harvmodel = readRDS("/aura/harvmodel.Rdata")

harvardmodel2 = gam(pred ~ DailyMean + s(POINT_X, POINT_Y), data=Day1PredMain, method="REML")
Day1PredAlt$PredAlt2 = predict(harvardmodel2, Day1PredAlt)
Day1PredAlt$PredAlt = predict(harvardmodel, Day1PredAlt)^2

write.csv(Day1PredAlt, "/aura/Day1PredAlt.csv")

Cld5km = read.csv("/aura/LinkedValsCloudCalif/DailyGridAOD_2012_001.csv")
Day1PredCld = merge(Day1PredAlt, Cld5km, by.x="InputFID", by.y="US.id")
Cld1kmDat = read.csv("/aura/LinkedFilesCloud/DailyGridAOD_2012_001.csv")
