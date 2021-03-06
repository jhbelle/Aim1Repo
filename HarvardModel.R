## --------------
## Name: HarvardModel.R
## Program version: R  3.3.2
## Dependencies: plyr, data.table, rhdf5
## Author: J.H. Belle
## Purpose: Combine MAIAC, EPA observations, and  RUC/RAP together into a single dataset, and use to fit/predict the base PM2.5 concentrations when AOD exists, and also run the Harvard gap-filling model to predict PM2.5 when AOD does not exist
## --------------

## ---------
# Setup
## ---------

# Load libraries
library(plyr)
library(data.table)
library(rhdf5)
#library(doMC)
# Source function file
source("/home/jhbelle/Aim1Repo/Functions_HarvardModel.R")
# EPA data
#EPAdat = read.csv("/home/jhbelle/Data/CalifG24hr.csv", stringsAsFactors=F)
# Near table
#NearMAIACEPA = read.csv("/home/jhbelle/Data/SFGridFin/EPAtoMAIAC.csv", stringsAsFactors=F)
# MAIAC location
MAIACloc = "/home/jhbelle/Data/Transfer_MAIAC/"
# TA flag
TAflag="A"
# RUC location
RUCloc = "/gc_runs/RUCRAP_FinalOutputs/"
RUCfolder = ifelse(TAflag=="A", "Aqua", ifelse(TAflag=="T", "Terra", print("WTF")))
# Startdate
Startdate = as.Date("2012-01-01", "%Y-%m-%d")
# Enddate
Enddate = as.Date("2012-01-02", "%Y-%m-%d")
# Location of saved aggregated outputs
OutAgg = "/aura/AggregatedDat_NoCld_Atl.csv"

# Set up threading for ddply
#registerDoMC(8)
#getDoParWorkers()

## -------
# Aggregate datasets
## -------

for (day in seq(Startdate, Enddate, "day")){
  Day = as.Date(day, origin=as.Date("1970-01-01", "%Y-%m-%d"))
  # Get list of MAIAC files on this day
  filelist = list.files(path=sprintf("%s", MAIACloc), pattern=sprintf("MAIACdat_%s_*", as.character(Day, "%Y%03j")), full.names=T)
  # Read in MAIAC data joining together all files for day
  for (file in filelist){
    if (exists("MAIACdat")){
      MAIACdat1 = read.csv(file, stringsAsFactors=F)
      MAIACdat = rbind.data.frame(MAIACdat, MAIACdat1)
    } else { MAIACdat = read.csv(file, stringsAsFactors=F) }
  }
  if (exists("MAIACdat")){
    # Open RUC data file and Lat/Lon
    hdfdat <- sprintf("%s%s/%s/RUCRAP_130_%s.h5", RUCloc, RUCfolder, as.character(Day, "%Y"), as.character(Day, "%Y%02m%02d"))
    if (file.exists(hdfdat)){
      # Pull RUC lat lon      
      LatLonRUC <- as.data.frame(h5read(hdfdat, "Geolocation"))
      # Do aggregation with RUC data
      RUCLatLongs = unique(MAIACdat[,c("RUCLat", "RUCLon")])
      Rucvars = adply(RUCLatLongs, 1, GetRUCVals, hdfdat=hdfdat, RUClatlon=LatLonRUC)
      OutIncRUC = merge(MAIACdat, Rucvars)
      # Write output to file

      if (file.exists(OutAgg)){
        fwrite(OutIncRUC, OutAgg, append=T)
      } else { fwrite(OutIncRUC, OutAgg) }
    }
  }
  rm (filelist, MAIACdat, MAIACdat1, hdfdat, LatLonRUC, OutIncRUC)
}

warnings()
