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
AquaGeoMeta = "/aqua/MODIS_GeoMeta/AQUA/"
RUCRAPloc = "/aqua/RUC_RAP/Prates/"
OutputFolder = "/gc_runs/RUCRAP_FinalOutputs/"
# Open grid data
GridDat = read.csv("/aqua/Jess/Data/RUCRAP_SubGrid.csv")
# Define variable lists for T/A vs. Daily files
#FullVarList = c("10u_heightAboveGround", "10v_heightAboveGround", "cape_pressureFromGroundLayer", "cape_surface", "cin_pressureFromGroundLayer", "cin_surface", "h_cloudBase", "h_cloudTop", "hpbl_surface", "prate_surface", "r_heightAboveGround", "sd_surface", "sp_surface", "vis_surface")
FullVarList = c("prate_surface")
# Create empty T/A datasets to start
AquaGridDat = makeEmptyDat(GridDat, FullVarList)
AquaCounts = makeEmptyDat(GridDat, FullVarList)
# -------------
# Process RUC/RAP text files to hdf
# -------------

# Iterate over dates from 2007 - 2015
Days = seq(as.Date("2010/12/30", "%Y/%m/%d"), as.Date("2016/01/01", "%Y/%m/%d"), "days")
for (i in seq(1, length(Days))){
  # Create year variable
  day = Days[i]
  Year = as.integer(as.character(day, "%Y"))
  # Read in T/A GeoMeta data files, filter to day observations taken over the US, and convert StartDateTime to POSIX format; Also need to bind in the previous days observations that were within 15 min of midnight to current days data
  AGM <- read.csv(sprintf("%s%d/MYD03_%s.txt", AquaGeoMeta, Year, as.character(day, "%Y-%m-%d")), skip=2, stringsAsFactors=F)
  AGM <- subset(AGM, AGM$DayNightFlag == "D" & AGM$EastBoundingCoord >= -130 & AGM$WestBoundingCoord <=-75 & AGM$SouthBoundingCoord <= 45 & AGM$NorthBoundingCoord >= 20)
  AGM$StartDateTime <- strptime(AGM$StartDateTime, "%Y-%m-%d %H:%M")
  if (exists("AGM_prevDay")){ AGM <- rbind.data.frame(AGM, AGM_prevDay) }
  # Iterate over hours
  for (hour in seq(0,23)){
    # Check if files exist for this hour/day - nm - faster to attempt to read files than to search directory
    #DayHrFiles <- list.files(RUCRAPloc, sprintf("ruc2anl_130_%s_%02d_*.txt", as.character(day, "%Y%m%d", hour)))
    # Check for Aqua passes associated with this hour (H-15min <= t < H+45 min)
    APhrs <- subset(AGM, AGM$StartDateTime >= strptime(paste(as.character(day, "%Y/%m/%d"), hour), "%Y/%m/%d %H") - 15*60 & AGM$StartDateTime <= strptime(paste(as.character(day, "%Y/%m/%d"), hour), "%Y/%m/%d %H") + 45*60)
    # Create variable list - if any Aqua or Terra passes associated with hour use full list, otherwise only smaller list for 24hr values
    varlist = FullVarList
    if (nrow(APhrs) > 0){
      # Iterate over variables
      for (var in varlist){
        # Read in data
        dat = try(read.table(sprintf("%sruc2anl_130_%s_%02d_%s.txt", RUCRAPloc, as.character(day, "%Y%m%d"), hour, var), header=T)[,1:3], silent=T)
        if (is.data.frame(dat)){
	  # Make column names consistent with the grid file and remove missing values from the dataset
	  colnames(dat) <- c("Latitude.", "Longitude", "Value.")
	  dat <- subset(dat, dat$Value. != -9999)
          # If applicable, add to A/T datasets
          for (j in seq(1, nrow(APhrs))){
            APOut = RetValsGran(APhrs[j,], GridDat, dat)
            if (nrow(APOut) > 0){
              APCount = aggregate(Value. ~ Latitude. + Longitude, APOut, length)
              APOut = aggregate(Value. ~ Latitude. + Longitude, APOut, sum)
              AquaGridDat = AddVals(AquaGridDat, APOut, var)
              AquaCounts = AddVals(AquaCounts, APCount, var)
            }
            rm(APOut, APCount)
          }
        }
      }
    }
    if (hour == 2){
      # If hour is 21, write previous days T/A files - if no counts in cell, convert to NA
      if (max(AquaCounts[,3:ncol(AquaCounts)]) > 0){
        # Check if directory exists for this year in Aqua folder, if not create one
        #MakeDir = ifelse(!dir.exists(sprintf("%sAqua/%d", OutputFolder, Year)), dir.create(sprintf("%sAqua/%d", OutputFolder, Year)), FALSE)  
        # Divide values by counts
        AquaGridDat[,3:ncol(AquaGridDat)] = AquaGridDat[,3:ncol(AquaGridDat)]/AquaCounts[,3:ncol(AquaCounts)]
        # Write HDF file
        writeHDF2(AquaGridDat, sprintf("%sAqua/%d/RUCRAP_130_%s.h5", OutputFolder, Year, as.character(day-1, "%Y%m%d")))
      } 
      # Create empty T/A datasets to restart
      AquaGridDat = makeEmptyDat(GridDat, FullVarList)
      AquaCounts = makeEmptyDat(GridDat, FullVarList)
    }
  }
  # Roll over APhrs and TPhrs at/near GMT midnight from previous day to next
  hour = 24
  AGM_prevDay <- subset(AGM, AGM$StartDateTime >= strptime(paste(as.character(day, "%Y/%m/%d"), hour), "%Y/%m/%d %H") - 15*60 & AGM$StartDateTime <= strptime(paste(as.character(day, "%Y/%m/%d"), hour), "%Y/%m/%d %H") + 45*60)
}

