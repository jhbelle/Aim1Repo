## -------------
## Name: LinkMODdat_Grid.r
## Program version: R 3.1.0
## Dependencies: plyr, stringr
## Function file: Functions_LinkMODdat_Grid.r
## Author: J.H. Belle
## Purpose: Calculate AOD averages for each CMAQ grid cell, using the lists of pixel UID's generated by the gridding process
## -------------
## Load libraries and functions
library(plyr)
library(stringr)
source("/home/jhbelle/Aim1Repo/Functions_LinkMODdat_Grid.r")
# ----
# Define relevant parameters
# ----
## These values are passed in through the command line
#args = commandArgs(trailingOnly=T)
#Endday = as.numeric(args[2])
#Startday = as.numeric(args[1])
Endday=2
Startday=1
## Year
Year = 2012
TAflag="A"
ListBroken = c()
## Location of MODIS files - extracted from hdf section-specific csvs using GriddingExtractMODIS10km.m
MODpath = "/aqua/MODIS_Cld_Jess/Extractions_5km_Aqua/"
## Location of grid
GridPath = "/aqua/MODIS_Cld_Jess/Gridded_5km_Aqua/"
## Location of output files
OutPath = "/home/jhbelle/Links5kmCld/"
## Scale value for AOD - from MODIS hdf files
Emisscale = 0.009999999776482582
# --------
# Load in csv files for each section - Gridding results and MODIS data, and calculate desired values
# --------
for (Day in Startday:Endday){
  for (section in 1:1){
    #print(section)
    ## Read in MODIS data, and create necessary variables - timestamp, UIDs and scaled AOD values
    Mod <- read.csv(sprintf("%sExtr_%i_%03d_S%i.csv", MODpath, Year, Day, section))
    Mod$timestamp <- paste(sprintf("%02d:%02d", as.integer(Mod$hr), as.integer(Mod$min)))
    Mod$UID <- sprintf("G%i_%03d_%s_P%f_%f", Year, Day, Mod$timestamp, Mod$Lat, Mod$Long)
    Mod$UID <- gsub("[[:punct:]]", "", Mod$UID)
    ## If the gridding output file exists (a few days/sections had no data and files for those days weren't created during gridding), read it in
    Grid <- try(read.csv(sprintf("%sOutp_%i_%03d_S%i_%s.csv", GridPath, Year, Day, section, TAflag), stringsAsFactors=FALSE))
    if (is.data.frame(Grid)) {
      ## Summarize MODIS data in each cell of the CMAQ grid - function CalcVals defined in function file
      CombOut <- ddply(Grid, .(US.id), CalcVals, MODdat=Mod, scale=Emisscale)
      rm(Mod, Grid)
      gc()
      ## Join output to that from previous section, if it exists
      if (exists("OutpDay")){
        OutpDay <- rbind.data.frame(OutpDay, CombOut)
      } else {
        OutpDay <- CombOut
      }
      rm(CombOut)
      gc()
    }
  }
  ## Write output csv
  write.csv(OutpDay, sprintf("%sDailyGridAOD_%i_%03d.csv", OutPath, Year, Day))
  rm(OutpDay)
}
