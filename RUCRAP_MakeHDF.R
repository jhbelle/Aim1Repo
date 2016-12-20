## ------------------------
## Name: RUCRAP_MakeHDF.R
## Program version: R 3.3.0
## Program dependencies: rhdf5;  
## Data dependencies: Extracted RUC/RAP data (text format); MODIS GeoMeta data files; Subsetted grid point locations;  
## Function File: Functions_RUCRAP_MakeHDF.R
## Author: J.H. Belle
## Purpose: Process RUCRAP text files into daily 24hr files, a Terra file and an Aqua file, each containing 6 fields and spanning the CONUS (defined as: 45, 20, -130, -75. Fields are: rh (median); visibility (median); 10u (median); 10v (median); snow depth (median); precipitation (total*time). For the 24hr files the country is separated into 4 time zones using rough longitude lines and averages/totals are taken over the local 24hr day begininng at midnight(pacific:T=-15-15:Lon=-115--130; mountain:T=-16-16:Lon=-102--115; central:T=-17-17:Lon=-87--102; eastern:T=-18-18:Lon=-75--87. Terra and Aqua files will each contain 14 fields (rh, sp, 10u, 10v, surface cape, surface cin, precipitation rate, snow depth, pbl height, cloudbase height, cloudtop height, visibility, upper cape, and upper cin), and will be matched to either the nearest hourly value or the average of the nearest two hourly values for each granule located in the CONUS as determined from the geometadata file extents, such that a value within +-15 minutes of each overpass is matched or estimated; For locations with multiple possible times, the average of all possibilities will be taken (will iteratively calculate sums and a counter for each location off of a standardized grid and then divide); Will need to run at 130 and 252 resolutions as separate runs with different versions of this script; Will also need to output list of 'missing' files at this resolution; Will allow T/A files to be produced even if 24 hour files lack all hours as long as T/A files can be completed across country
## ------------------------

# Load libraries
library(rhdf5)
source("Functions_RUCRAP_MakeHDF.R")

# ------------
# Define file paths, grid data, and time zones; create starting empty datasets
# ------------

AquaGeoMeta = "/aqua/MODIS_GeoMeta/AQUA/"
TerraGeoMeta = "/aqua/MODIS_GeoMeta/TERRA/"
RUCRAP_2007_2012 = "/aqua/RUC_RAP/OutputTexts/"
RUCRAP_2012_2015 = "/terra/RUCRAP_2012_2016/"
OutputFolder = "/gc_runs/RUCRAP_FinalOutputs/"
GridDat = read.csv("/aqua/Jess/Data/RUCRAP_SubGrid.csv")
# Define time zones
Pacific = subset(GridDat, GridDat$Longitude >= -130 & GridDat$Longitude <= -115)
Mountain = subset(GridDat, GridDat$Longitude > -115 & GridDat$Longitude <= -102)
Central = subset(GridDat, GridDat$Longitude > -102 & GridDat$Longitude <= -87)
Eastern = subset(GridDat, GridDat$Longitude > -87 & GridDat$Longitude <= -75)
FullVarList = c("10u_heightAboveGround", "10v_heightAboveGround", "cape_pressureFromGroundLayer", "cape_surface", "cin_pressureFromGroundLayer", "cin_surface", "h_cloudBase", "h_cloudTop", "hpbl_surface", "prate_surface", "r_heightAboveGround", "sd_surface", "sp_surface", "vis_surface")
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
Pacific_nextDay = makeEmptyDat(Pacific, SubVarList)
PCount_nextDay = makeEmptyDat(Pacific, SubVarList)
Mountain_nextDay = makeEmptyDat(Mountain, SubVarList)
MCount_nextDay = makeEmptyDat(Mountain, SubVarList)
Central_nextDay = makeEmptyDat(Central, SubVarList)
CCount_nextDay = makeEmptyDat(Central, SubVarList)

# Create empty T/A datasets to start
TerraGridDat = makeEmptyDat(GridDat, FullVarList)
TerraCounts = makeEmptyDat(GridDat, FullVarList)
AquaGridDat = makeEmptyDat(GridDat, FullVarList)
AquaCounts = makeEmptyDat(GridDat, FullVarList)

# -------------
# Process RUC/RAP text files to hdf
# -------------

# Iterate over dates from 2007 - 2015
Days = seq(as.Date("2007/04/01", "%Y/%m/%d"), as.Date("2016/01/01", "%Y/%m/%d"), "days")
for (day in Days){
  # Create year variable
  Year = as.integer(as.character(day, "%Y"))
  # Assign correct RUCRAP text file location for this year
  if (Year <= 2011) { RUCRAPloc = RUCRAP_2007_2012 } else { RUCRAPloc = RUCRAP_2012_2015}
  # Read in T/A GeoMeta data files, filter to day observations taken over the US, and convert StartDateTime to POSIX format
  AGM <- read.csv(sprintf("%s%d/MYD03_%s.txt", AquaGeoMeta, Year, as.character(day, "%Y-%m-%d")), skip=2, stringsAsFactors=F)
  AGM <- subset(AGM, AGM$DayNightFlag == "D" & AGM$EastBoundingCoord >= -130 & AGM$WestBoundingCoord <=-75 & AGM$SouthBoundingCoord <= 45 & AGM$NorthBoundingCoord >= 20)
  AGM$StartDateTime <- strptime(AGM$StartDateTime, "%Y-%m-%d %H:%M")
  TGM <- read.csv(sprintf("%s%d/MOD03_%s.txt", TerraGeoMeta, Year, as.character(day, "%Y-%m-%d")), skip=2, stringsAsFactors=F)
  TGM <- subset(TGM, TGM$DayNightFlag == "D" & TGM$EastBoundingCoord >= -130 & TGM$WestBoundingCoord >=-75 & TGM$SouthBoundingCoord <= 45 & TGM$NorthBoundingCoord >= 20)
  TGM$StartDateTime <- strptime(TGM$StartDateTime, "%Y-%m-%d %H:%M")
  # Iterate over hours
  for (hour in seq(0,23)){
    # Check if files exist for this hour/day - nm - faster to attempt to read files than to search directory
    #DayHrFiles <- list.files(RUCRAPloc, sprintf("ruc2anl_130_%s_%02d_*.txt", as.character(day, "%Y%m%d", hour)))
    # Check for Aqua passes associated with this hour (H-15min <= t < H+45 min)
    APhrs <- subset(AGM, AGM$StartDateTime >= strptime(paste(as.character(day, "%Y/%m/%d"), hour), "%Y/%m/%d %H") - 15*60 & AGM$StartDateTime <= strptime(paste(as.character(day, "%Y/%m/%d"), hour), "%Y/%m/%d %H") + 45*60)
    # Check for Terra passes associated with this hour (H-15min <= t < H+45 min)
    TPhrs <- subset(TGM, TGM$StartDateTime >= strptime(paste(as.character(day, "%Y/%m/%d"), hour), "%Y/%m/%d %H") - 15*60 & TGM$StartDateTime <= strptime(paste(as.character(day, "%Y/%m/%d"), hour), "%Y/%m/%d %H") + 45*60)
    # Create variable list - if any Aqua or Terra passes associated with hour use full list, otherwise only smaller list for 24hr values
    if (nrow(APhrs) > 0 | nrow(TPhrs) > 0){
      ProdTA = T
      varlist = FullVarList
    } else { 
      ProdTA = F
      varlist = SubVarList 
    }
    # Iterate over variables
    for (var in varlist){
      # Read in data
      dat = try(read.table(sprintf("%sruc2anl_130_%s_%02d_%s.txt", RUCRAPloc, as.character(day, "%Y%m%d"), hour, var), header=T)[,1:3], silent=T)
      if (is.data.frame(dat)){
        # If applicable, add to A/T datasets
        if (nrow(APhrs) > 0){
          APOut = ddply(APhrs, .(StartDateTime), RetValsGran, gridDat=GridDat, dat=dat)
          APOut = aggregate(Value. ~ Latitude + Longitude, APOut, sum)
          APCount = aggregate(Value. ~ Latitude + Longitude, APOut, length)
        }
        if (nrow(TPhrs) > 0){
          TPOut = ddply(TPhrs, .(StartDateTime), RetValsGran, gridDat=GridDat, dat=dat)
          TPOut = aggregate(Value. ~ Latitude + Longitude, TPOut, sum)
          TPCount = aggregate(Value. ~ Latitude + Longitude, TPOut, length)
        }
        # Add 24hr vars to appropriate time zone/day combos
        if (var %in% SubVarList){
          if (hour == 16){
            P = Pacific_nextDay
            PCount = PCount_nextDay
            M = Mountain_curDay
            MCount = MCount_curDay
            C = Central_curDay
            CCount = CCount_curDay
            E = Eastern_curDay
            ECount = ECount_curDay
          } else if (hour == 17){
            P = Pacific_nextDay
            PCount = PCount_nextDay
            M = Mountain_nextDay
            MCount = MCount_nextDay
            C = Central_curDay
            CCount = CCount_curDay
            E = Eastern_curDay
            ECount = ECount_curDay
          } else if (hour == 18){
            P = Pacific_nextDay
            PCount = PCount_nextDay
            M = Mountain_nextDay
            MCount = MCount_nextDay
            C = Central_nextDay
            CCount = CCount_nextDay
            E = Eastern_curDay
            ECount = ECount_curDay
          } else {
            P = Pacific_curDay
            PCount = PCount_curDay
            M = Mountain_curDay
            MCount = MCount_curDay
            C = Central_curDay
            CCount = CCount_curDay
            E = Eastern_curDay
            ECount = ECount_curDay
          }
        }
      }
    }
    # If hour is 18 put together and write current day's 24hr file - if number of hours doesn't total 24, don't write and instead write to missing days accounting file
    if (hour == 18){
      # Check if directory exists for this year in Aqua folder, if not create one
      MakeDir = ifelse(!dir.exists(sprintf("%sAqua/%d", OutputFolder, Year)), dir.create(sprintf("%sAqua/%d", OutputFolder, Year)), FALSE)
      # Check if directory exists for this year in Terra folder
      MakeDir = ifelse(!dir.exists(sprintf("%sTerra/%d", OutputFolder, Year)), dir.create(sprintf("%sAqua/%d", OutputFolder, Year)), FALSE)
      # Switch next/current days and overwrite next days with empty datasets
    } else if (hour == 21){
      # If hour is 21, write previous days T/A files - if no counts in cell, convert to NA
      # Check if directory exists for this year in Daily folder
      MakeDir = ifelse(!dir.exists(sprintf("%sDaily/%d", OutputFolder, Year)), dir.create(sprintf("%sAqua/%d", OutputFolder, Year)), FALSE)

    }
  }
  # Roll over APhrs and TPhrs at/near 24 from previous day to next
  hour = 24
  APhrs_prevDay <- subset(AGM, AGM$StartDateTime >= strptime(paste(as.character(day, "%Y/%m/%d"), hour), "%Y/%m/%d %H") - 15*60 & AGM$StartDateTime <= strptime(paste(as.character(day, "%Y/%m/%d"), hour), "%Y/%m/%d %H") + 45*60)
  # Check for Terra passes associated with this hour (H-15min <= t < H+45 min)
  TPhrs_prevDay <- subset(TGM, TGM$StartDateTime >= strptime(paste(as.character(day, "%Y/%m/%d"), hour), "%Y/%m/%d %H") - 15*60 & TGM$StartDateTime <= strptime(paste(as.character(day, "%Y/%m/%d"), hour), "%Y/%m/%d %H") + 45*60)
}

