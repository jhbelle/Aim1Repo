## ------------------------
## Name: RUCRAP_MakeHDF.R
## Program version: R 3.3.0
## Program dependencies: rhdf5; plyr
## Data dependencies: Extracted RUC/RAP data (text format); MODIS GeoMeta data files; Subsetted grid point locations;  
## Function File: Functions_RUCRAP_MakeHDF.R
## Author: J.H. Belle
## Purpose: Process RUCRAP text files into daily 24hr files, a Terra file and an Aqua file, each containing 6 fields and spanning the CONUS (defined as: 45, 20, -130, -75. Fields are: rh (median); visibility (median); 10u (median); 10v (median); snow depth (median); precipitation (total*time). For the 24hr files the country is separated into 4 time zones using rough longitude lines and averages/totals are taken over the local 24hr day begininng at midnight(pacific:T=-15-15:Lon=-115--130; mountain:T=-16-16:Lon=-102--115; central:T=-17-17:Lon=-87--102; eastern:T=-18-18:Lon=-75--87. Terra and Aqua files will each contain 14 fields (rh, sp, 10u, 10v, surface cape, surface cin, precipitation rate, snow depth, pbl height, cloudbase height, cloudtop height, visibility, upper cape, and upper cin), and will be matched to either the nearest hourly value or the average of the nearest two hourly values for each granule located in the CONUS as determined from the geometadata file extents, such that a value within +-15 minutes of each overpass is matched or estimated; For locations with multiple possible times, the average of all possibilities will be taken (will iteratively calculate sums and a counter for each location off of a standardized grid and then divide); Will need to run at 130 and 252 resolutions as separate runs with different versions of this script; Will also need to output list of 'missing' files at this resolution; Will allow T/A files to be produced even if 24 hour files lack all hours as long as T/A files can be completed across country
## ------------------------

# Load libraries
library(rhdf5)
library(plyr)
source("/home/jhbelle/Aim1Repo/Functions_RUCRAP_MakeHDF.R")

# ------------
# Define file paths, grid data, and time zones; create starting empty datasets
# ------------

# Define file paths 
RUCRAP_2007_2012 = "/aqua/RUC_RAP/OutputTexts/"
RUCRAP_2012_2015 = "/terra/RUCRAP_2012_2016/"
OutputFolder = "/gc_runs/RUCRAP_FinalOutputs/"
# Open grid data
GridDat = read.csv("/aqua/Jess/Data/RUCRAP_SubGrid.csv")
# Define time zones
Pacific = subset(GridDat, GridDat$Longitude >= -130 & GridDat$Longitude <= -115)
Mountain = subset(GridDat, GridDat$Longitude > -115 & GridDat$Longitude <= -102)
Central = subset(GridDat, GridDat$Longitude > -102 & GridDat$Longitude <= -87)
Eastern = subset(GridDat, GridDat$Longitude > -87 & GridDat$Longitude <= -75)
# Define variable lists for T/A vs. Daily files
SubVarList = c("10u_heightAboveGround", "10v_heightAboveGround", "prate_surface", "r_heightAboveGround", "sd_surface", "vis_surface") 
# Create empty datasets to start time zones
Pacific_curDay = makeEmptyDat(Pacific, SubVarList)
PCount_curDay = makeEmptyDat(Pacific, SubVarList)
Mountain_curDay = makeEmptyDat(Mountain, SubVarList)
MCount_curDay = makeEmptyDat(Mountain, SubVarList)
Central_curDay = makeEmptyDat(Central, SubVarList)
CCount_curDay = makeEmptyDat(Central, SubVarList)
Eastern_curDay = makeEmptyDat(Eastern, SubVarList)
ECount_curDay = makeEmptyDat(Eastern, SubVarList)
# -------------
# Process RUC/RAP text files to hdf
# -------------

# Iterate over dates from 2007 - 2015
Days = seq(as.Date("2007/04/01", "%Y/%m/%d"), as.Date("2007/04/02", "%Y/%m/%d"), "days")
for (i in seq(1, length(Days))){
  # Create year variable
  day = Days[i]
  Year = as.integer(as.character(day, "%Y"))
  # Assign correct RUCRAP text file location for this year
  if (Year <= 2011) { RUCRAPloc = RUCRAP_2007_2012 } else { RUCRAPloc = RUCRAP_2012_2015}
  # Iterate over hours
  for (hour in seq(0,23)){
    varlist = SubVarList	
    # Iterate over variables
    for (var in varlist){
      # Read in data
      dat = try(read.table(sprintf("%sruc2anl_130_%s_%02d_%s.txt", RUCRAPloc, as.character(day, "%Y%m%d"), hour, var), header=T)[,1:3], silent=T)
      if (is.data.frame(dat)){
	# Make column names consistent with the grid file and remove missing values from the dataset
	colnames(dat) <- c("Latitude.", "Longitude", "Value.")
	dat <- subset(dat, dat$Value. != -9999)
        # Add 24hr vars to appropriate time zone/day combos
        if (var %in% SubVarList){
          if (hour == 16){
            Pacific_nextDay = makeEmptyDat(Pacific, SubVarList)
       	    PCount_nextDay = makeEmptyDat(Pacific, SubVarList)
            Pacific_nextDay = AddVals(Pacific_nextDay, dat, var, corLong=360)
            PCount_nextDay = AddVals(PCount_nextDay, dat, var, corLong=360)
            Mountain_curDay = AddVals(Mountain_curDay, dat, var, corLong=360)
            MCount_curDay = AddVals(MCount_curDay, dat, var, corLong=360)
            Central_curDay = AddVals(Central_curDay, dat, var, corLong=360)
            CCount_curDay = AddVals(CCount_curDay, dat, var, corLong=360)
            Eastern_curDay = AddVals(Eastern_curDay, dat, var, corLong=360)
            ECount_curDay = AddVals(ECount_curDay, dat, var, corLong=360)
          } else if (hour == 17){
            Pacific_nextDay = AddVals(Pacific_nextDay, dat, var, corLong=360)
            PCount_nextDay = AddVals(PCount_nextDay, dat, var, corLong=360)
            Mountain_nextDay = makeEmptyDat(Mountain, SubVarList)
            MCount_nextDay = makeEmptyDat(Mountain, SubVarList)
            Mountain_nextDay = AddVals(Mountain_nextDay, dat, var, corLong=360)
            MCount_nextDay = AddVals(MCount_nextDay, dat, var, corLong=360)
            Central_curDay = AddVals(Central_curDay, dat, var, corLong=360)
            CCount_curDay = AddVals(CCount_curDay, dat, var, corLong=360)
            Eastern_curDay = AddVals(Eastern_curDay, dat, var, corLong=360)
            ECount_curDay = AddVals(ECount_curDay, dat, var, corLong=360)
          } else if (hour == 18){
            Pacific_nextDay = AddVals(Pacific_nextDay, dat, var, corLong=360)
            PCount_nextDay = AddVals(PCount_nextDay, dat, var, corLong=360)
            Mountain_nextDay = AddVals(Mountain_nextDay, dat, var, corLong=360)
            MCount_nextDay = AddVals(MCount_nextDay, dat, var, corLong=360)
            Central_nextDay = makeEmptyDat(Mountain, SubVarList)
            CCount_nextDay = makeEmptyDat(Mountain, SubVarList)
            Central_nextDay = AddVals(Central_nextDay, dat, var, corLong=360)
            CCount_nextDay = AddVals(CCount_nextDay, dat, var, corLong=360)
            Eastern_curDay = AddVals(Eastern_curDay, dat, var, corLong=360)
            ECount_curDay = AddVals(ECount_curDay, dat, var, corLong=360) 
          } else {
	    Pacific_curDay = AddVals(Pacific_curDay, dat, var, corLong=360)
	    PCount_curDay = AddVals(PCount_curDay, dat, var, corLong=360)
            Mountain_curDay = AddVals(Mountain_curDay, dat, var, corLong=360)
            MCount_curDay = AddVals(MCount_curDay, dat, var, corLong=360)
            Central_curDay = AddVals(Central_curDay, dat, var, corLong=360)
            CCount_curDay = AddVals(CCount_curDay, dat, var, corLong=360)
            Eastern_curDay = AddVals(Eastern_curDay, dat, var, corLong=360)
            ECount_curDay = AddVals(ECount_curDay, dat, var, corLong=360)
          }
        }
      }
    }
    # If hour is 19 put together and write current day's 24hr file - if number of hours doesn't total 24, don't write and instead write to missing days accounting file
    if (hour == 19){
      # Check if 24 hours exist in day
      if (min(ECount_curDay[,3:ncol(ECount_curDay)]) >=24){
        # Check if directory exists for this year in Daily folder
        MakeDir = ifelse(!dir.exists(sprintf("%sDaily/%d", OutputFolder, Year)), dir.create(sprintf("%sDaily/%d", OutputFolder, Year)), FALSE)
        # Combine current day files into single file
        DayOut = rbind.data.frame(Pacific_curDay, Mountain_curDay, Central_curDay, Eastern_curDay)
        DayOut = merge(GridDat, DayOut, by=c("Longitude", "Latitude."), all.x=T)
        DayCount = rbind.data.frame(PCount_curDay, MCount_curDay, CCount_curDay, ECount_curDay)
        DayCount = merge(GridDat, DayCount, by=c("Longitude", "Latitude."), all.x=T)
        # Divide summed values by counts
        DayOut[,3:ncol(DayOut)] = DayOut[,3:ncol(DayOut)]/DayCount[,3:ncol(DayCount)]
        # Add count field for prate_surface (needed to calcualate total precipitation over day = 60*count*prate)
        DayOut$Prate_Count = DayCount$prate_surface
        # Write HDF file
        writeHDF(DayOut, sprintf("%sDaily/%d/RUCRAP_130_%s.h5", OutputFolder, Year, as.character(day, "%Y%m%d")))
        # Clean up
        rm(DayOut, DayCount)
      }
      # Switch next/current days
      Pacific_curDay = Pacific_nextDay
      PCount_curDay = PCount_nextDay
      Mountain_curDay = Mountain_nextDay
      MCount_curDay = MCount_nextDay
      Central_curDay = Central_nextDay
      CCount_curDay = CCount_nextDay
      Eastern_curDay = makeEmptyDat(Eastern, SubVarList)
      ECount_curDay = makeEmptyDat(Eastern, SubVarList)
    } 
  }
}

