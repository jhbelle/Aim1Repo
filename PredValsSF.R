## ------------
## Name: PredValsSF.R
## Program version: R 3.3.3
## dependencies: lme4; mgcv
## Purpose: Make predictions using main model, harvard model, and my model
## ------------

# Load libraries
library(lme4)
library(mgcv)

## --------
## Define variables important later
## --------

## Location of main model data
MainModDat = file("/aura/AggregatedDat_NoCld.csv", "r")
# Pull out colnames and define variable types for scan
colnames_MainModDat = scan(MainModDat, nlines=1, what="character", sep=",")
#c("RUCLat", "RUCLon", "InputFID", "index", "lat", "lon", "POINT_X", "POINT_Y", "PercForest", "PRoadLength", "NEIPM", "Elev", "Year", "Date", "Timestamp", "Overpass", "AOD47", "AOD55", "QA", "X10u_heightAboveGround", "X10v_heightAboveGround", "X2t_heightAboveGround", "cape_pressureFromGroundLayer", "cape_surface", "cin_pressureFromGroundLayer", "cin_surface", "h_cloudBase", "h_cloudTop", "hpbl_surface", "prate_surface", "r_heightAboveGround", "sd_surface", "sp_surface", "vis_surface")
types_MainModDat = c("numeric", "numeric", "integer", "integer", rep("numeric", 8), "integer", "integer", "integer", "character", rep("numeric", 18))
# Location of all road length data
RoadLengths = read.csv("/home/jhbelle/Data/SFGridFin/RdLengths_AllRds.csv")[,c("Input_FID", "RdLenkm")]
# Daily means from monitors - using as daily mean in model?
# Location of cloud data
Cloud5kmLoc = "/aura/LinkedValsCloudCalif/"
Cloud1kmLoc = "/aura/MODIScloud_extr_1km/"
CloudLinksLoc = "/aura/LinkedFilesCloud2/"
# Main model definition
mainmodel = readRDS("/aura/mainmodela.Rdata")
# Ice cloud model definition
icemodel = readRDS("/aura/icecloudmodela.Rdata")
# Water cloud model definition
watermodel = readRDS("/aura/watercloudmodela.Rdata")
# Outlocation - Main predictions
MainPredOut = "/aura/MainPredAquaSF/"
# Outlocation - Harvard predictions
HarvPredOut = "/aura/HarvPredAquaSF/"
# Outlocation - Cloud predictions
CloudPredOut = "/aura/CloudPredAquaSF/"
# Set current and enddays
startday = 1
endday = 3
year=2012
# Cloud scale value
scale = 0.009999999776482582
source("/home/jhbelle/Aim1Repo/Functions_PredVals.R")
## --------
# Make predictions and save
## --------

yearfile=2012
dayfile=1
for (day in seq(startday, endday)){
  month = as.numeric(as.character(as.Date(sprintf("2012 %i", day), "%Y %j"), "%m"))
  # Read in main file values for this day
  while (yearfile==year & dayfile==day){
      dat = scan(MainModDat, nlines=1, sep=",", what=list(types_MainModDat), quiet=T)[[1]]
      yearfile = as.numeric(dat[13])
      dayfile = as.numeric(dat[14])
      if (exists("daysdat")){
        daysdat = rbind.data.frame(daysdat, dat)
        prevline=dat
      } else if (exists("prevline")){
        daysdat = rbind.data.frame(prevline, dat, stringsAsFactors=F)
        colnames(daysdat) = colnames_MainModDat
        prevline=dat     
      } else prevline=dat
  }
  # Prepare data for model - make sure variable names are right and calculate things like wind speed
  MainDat = PrepMainDat(daysdat, RoadLengths)
  MainDat = subset(MainDat, MainDat$DOY == day)
  # Predict values using model
  MainDat$Pred = predict(mainmodel, MainDat, allow.new.levels=T)
  # Remove any outliers
  MainDat$Pred = ifelse(MainDat$Pred > (mean(MainDat$Pred, na.rm=T) + 5*sd(MainDat$Pred, na.rm=T)), NA, MainDat$Pred)
  # Create and write output dataset with predicted values for each cell where a value exists
  MainOut = subset(MainDat, !is.na(MainDat$Pred))[,c("InputFID", "Pred")]
  if (length(MainOut$Pred) > 0) write.csv(MainOut, sprintf("%sMainPredVals_%i.csv", MainPredOut, day))
  # Create alternative model dataset - include only observations where AOD was missing
  AltDat = subset(MainDat, is.na(MainDat$Pred))
  # Prep for harvard model
  if (length(AltDat$Pred) > 0){
    AltDat$DailyMean = rep(sqrt(mean(MainOut$Pred)), length(AltDat$Pred))
    AltDat$POINT_X.y.y = as.numeric(as.character(AltDat$POINT_X))
    AltDat$POINT_Y.y.y = as.numeric(as.character(AltDat$POINT_Y))
    # Read in appropriate harvard model
    harvmodel = readRDS(sprintf("/aura/harvmodel_%i.Rdata", month))
    # Predict values
    AltDat$PredHarv = predict(harvmodel, AltDat)^2
    # Create and write output dataset with harvard predictions
    HarvOut = AltDat[,c("InputFID", "PredHarv")]
    write.csv(HarvOut, sprintf("%sHarvardOut_%i.csv", HarvPredOut, day))
    # Read in 5 km cloud data and merge to altdat
    Cld5km = read.csv(sprintf("%sDailyGridAOD_%i_%03d.csv", Cloud5kmLoc, year, day))
    CldMainAltDat = merge(AltDat, Cld5km, by.x="InputFID", by.y="US.id")
    # Read in 1 km linkage file and AOD, radius values
    CldLink1km = unique(read.csv(sprintf("%sDailyGridAOD_%i_%03d.csv", CloudLinksLoc, year, day)))
    Cld1kmVals = read.csv(sprintf("%sExtr_%i_%03d_S1_A.csv", Cloud1kmLoc, year, day))
    # Set missing value and scale CAOD and CER
    Cld1kmVals$CloudAOD = ifelse(Cld1kmVals$CloudAOD == -9999, NA, Cld1kmVals$CloudAOD)*scale
    Cld1kmVals$CloudEffRad = ifelse(Cld1kmVals$CloudEffRad == -9999, NA, Cld1kmVals$CloudEffRad)*scale
    # Merge linkage and value files
    Cld1kmDat = merge(CldLink1km, Cld1kmVals, by.x=c("Index", "hr", "min"), by.y=c("MaskVal", "hr", "min")) 
    # Aggregate and merge in cloud AOD
    CloudAOD = aggregate(CloudAOD~US.id, Cld1kmDat, mean, na.rm=T)
    CldMainAltDat = merge(CldMainAltDat, CloudAOD, by.x="InputFID", by.y="US.id")
    # Aggregate and merge in cloud effective radius
    CloudEffRad = aggregate(CloudEffRad~US.id, Cld1kmDat, mean, na.rm=T)
    CldMainAltDat = merge(CldMainAltDat, CloudEffRad, by.x="InputFID", by.y="US.id")
    # Set variables
    CldMainAltDat$cape2.y = as.numeric(as.character(CldMainAltDat$cape_surface))/1000
    CldMainAltDat$Raining.y = ifelse(as.numeric(as.character(CldMainAltDat$prate_surface)) == 0, 0, 1)
    CldMainAltDat$CloudEmmisivity.y = as.numeric(as.character(CldMainAltDat$CE))
    CldMainAltDat$CloudRadius.y = CldMainAltDat$CloudEffRad
    CldMainAltDat$CloudAOD.y = CldMainAltDat$CloudAOD
    # Separate out water clouds
    WaterClouds = subset(CldMainAltDat, CldMainAltDat$CP == 1)
    if (length(WaterClouds$Pred) > 0){
      WaterClouds$PredWatCld = exp(predict(watermodel, WaterClouds))
      WaterOut = WaterClouds[,c("InputFID", "PredHarv", "PredWatCld")]
      write.csv(WaterOut, sprintf("%sWaterCld_%i", CloudPredOut, day))
    }
    # Separate out ice clouds
    IceClouds=subset(CldMainAltDat, CldMainAltDat$CP == 2)
    if (length(IceClouds$Pred) > 0){
      IceClouds$PredIceCld = exp(predict(icemodel, IceClouds))
      IceOut = IceClouds[,c("InputFID", "PredHarv", "PredIceCld")]
      write.csv(IceOut, sprintf("%sIceCld_%i", CloudPredOut, day))
    } 
  }
  # Remove daysdat to move to next day of file
  rm(daysdat)
}
