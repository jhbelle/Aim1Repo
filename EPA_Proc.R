## -----------------------
## Name: EPA_Proc.R
## Program version: R 3.2.3
## Dependencies: plyr
## Function file: Functions_EPA_Proc.R
## References:
## Author: J.H. Belle
## Purpose: EPA collocation pre-processing - obtain list of EPA stations located within each study area, and pull data records out for collocations with other data products
##    NOTE: Current study period: 04/01/2007-03/31/2015;
##    NOTE: Processing 24 hour PM, 24 hour Speciated PM, 1 Hr PM, and 1 Hr Speciated separately and including weather data for each observation, if available
## -----------------------

# Read in libraries
library(plyr)
source("T://eohprojs/CDC_climatechange/Jess/Dissertation/Aim1Repo/Functions_EPA_Proc.R")

# Define study areas. Order of coordinates: Longitude west/left side, Longitude east/right side, latitude south/bottom side, latitude north/top side
CalifDef <- c(-122.7, -119.9, 37.0, 40.1) # Larger than final study area - uncertain if lower part of central valley and SanFran itself should be included
CalifDef2 <- c(-122.6, -119.9, 37.0, 40.1)
ColoradoDef <- c(-105.6, -104.2, 38.7, 40.8)
MidwestDef <- c(-87.6, -84.8, 39.0, 41.5)
AtlDef <- c(-85.6, -83.1, 32.2, 34.5)

# Process site information file - read in, remove columns of no interest, remove sites that closed before 04/01/2007
#Sites <- read.csv("T:/eohprojs/CDC_climatechange/Jess/Dissertation/aqs_sites/aqs_sites.csv", stringsAsFactors = F)[,c(1:3,7:18,22)]
#Sites$SiteClosed <- as.Date(Sites$Site.Closed.Date, "%Y-%m-%d")
#Sites$SiteOpen <- ifelse(Sites$Site.Closed.Date == "", T, F)
#Sites <- subset(Sites, Sites$SiteClosed >= as.Date("2007-04-01", "%Y-%m-%d") | Sites$SiteOpen == T)
# Process monitor information file - read in, remove columns of no interest, remove monitors for parameters not of interest
#Monitors <- read.csv("T:/eohprojs/CDC_climatechange/Jess/Dissertation/aqs_monitors/aqs_monitors.csv", stringsAsFactors = F)[,c(1:11,20)]
# Join monitor and site information files - Want one line for every monitor with a site open during the study period
#Joint <- merge(Monitors, Sites, by=c("State.Code", "County.Code", "Site.Number"))
#Joint$State.Code <- as.integer(Joint$State.Code)
# Make sure all datums and lat/lon coordinates are consistent - No longer works - fixed columns read in by Sites after seeing output - All = T
#summary(ifelse(Joint$Latitude.x == Joint$Latitude.y, T, F))
#summary(ifelse(Joint$Longitude.x == Joint$Longitude.y, T, F))
#summary(ifelse(Joint$Datum.x == Joint$Datum.y, T, F))

# Sort sites into study areas
#Atlanta <- SiteSort(Joint, AtlDef)
#California <- SiteSort(Joint, CalifDef)
#Midwest <- SiteSort(Joint, MidwestDef)
#Colorado <- SiteSort(Joint, ColoradoDef)

# Clean up environment
#rm(Sites, CalifDef, ColoradoDef, MidwestDef, AtlDef, Monitors, Joint)
#gc()

## --------------
# 24 hour FRM PM_2.5 observations
## --------------

# Create empty files to write lines to
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "Date", "24hrPM", "MethodCode"), "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlObs24hrFRM.csv", row.names=F, col.names = F, sep=",")
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "Date", "24hrPM", "MethodCode"), "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifObs24hrFRM.csv", row.names=F, col.names = F, sep=",")
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "Date", "24hrPM", "MethodCode"), "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/MdwstObs24hrFRM.csv", row.names=F, col.names = F, sep=",")
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "Date", "24hrPM", "MethodCode"), "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/ColoradoObs24hrFRM.csv", row.names=F, col.names = F, sep=",")

# Loop over years, read in data, pull values of interest, and write those lines to the appropriate text file
for (year in seq(2007,2015)){
  Dat <- read.csv(sprintf("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAarchives/EPA_GroundMonitors/PM25_FRM/daily_88101_%d.csv", year), stringsAsFactors = F)[,c(1:8,12,15,17,21)]
  print(nrow(Dat))
  Dat <- subset(Dat, Dat$Observation.Count == 1)[,c(1:9,11,12)]
  write.table(SiteSort(Dat, AtlDef), file="T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlObs24hrFRM.csv", append=T, row.names=F, col.name=F, sep=",")
  write.table(SiteSort(Dat, CalifDef), file="T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifObs24hrFRM.csv", append=T, row.names=F, col.name=F, sep=",")
  write.table(SiteSort(Dat, ColoradoDef), file="T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/ColoradoObs24hrFRM.csv", append=T, row.names=F, col.name=F, sep=",")
  write.table(SiteSort(Dat, MidwestDef), file="T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/MdwstObs24hrFRM.csv", append=T, row.names=F, col.name=F, sep=",")
  rm(Dat)
  gc()
}

## --------------
# 24 hour Non-FRM PM_2.5 observations
## --------------

# Create empty files to write lines to
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "Date", "ObsCount", "24hrPM", "MethodCode"), "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlObs24hrnonFRM.csv", row.names=F, col.names = F, sep=",")
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "Date", "ObsCount", "24hrPM", "MethodCode"), "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifObs24hrnonFRM.csv", row.names=F, col.names = F, sep=",")
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "Date", "ObsCount", "24hrPM", "MethodCode"), "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/MdwstObs24hrnonFRM.csv", row.names=F, col.names = F, sep=",")
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "Date", "ObsCount", "24hrPM", "MethodCode"), "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/ColoradoObs24hrnonFRM.csv", row.names=F, col.names = F, sep=",")

# Loop over years, read in data, pull values of interest, and write those lines to the appropriate text file
for (year in seq(2007,2015)){
  Dat <- read.csv(sprintf("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAarchives/EPA_GroundMonitors/PM25_nonFRM/daily_88502_%d.csv", year), stringsAsFactors = F)[,c(1:8,12,15,17,21)]
  print(nrow(Dat))
  write.table(SiteSort(Dat, AtlDef), file="T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlObs24hrnonFRM.csv", append=T, row.names=F, col.name=F, sep=",")
  write.table(SiteSort(Dat, CalifDef), file="T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifObs24hrnonFRM.csv", append=T, row.names=F, col.name=F, sep=",")
  write.table(SiteSort(Dat, ColoradoDef), file="T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/ColoradoObs24hrnonFRM.csv", append=T, row.names=F, col.name=F, sep=",")
  write.table(SiteSort(Dat, MidwestDef), file="T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/MdwstObs24hrnonFRM.csv", append=T, row.names=F, col.name=F, sep=",")
  rm(Dat)
  gc()
}

## --------------
# Hourly FRM PM_2.5 observations
## --------------

## --------------
# Create empty files to write lines to
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "Date", "Time", "DateGMT", "TimeGMT", "1hrPM", "MDL", "MethodCode"), "/home/jhbelle/EPAdata/AtlObs1hrFRM.csv", row.names=F, col.names = F, sep=",")
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "Date", "Time", "DateGMT", "TimeGMT", "1hrPM", "MDL", "MethodCode"), "/home/jhbelle/EPAdata/CalifObs1hrFRM.csv", row.names=F, col.names = F, sep=",")
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "Date", "Time", "DateGMT", "TimeGMT", "1hrPM", "MDL", "MethodCode"), "/home/jhbelle/EPAdata/MdwstObs1hrFRM.csv", row.names=F, col.names = F, sep=",")
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "Date", "Time", "DateGMT", "TimeGMT", "1hrPM", "MDL", "MethodCode"), "/home/jhbelle/EPAdata/ColoradoObs1hrFRM.csv", row.names=F, col.names = F, sep=",")

# Loop over years, read in data, pull values of interest, and write those lines to the appropriate text file
# NOTE: No hourly observations in 2007
for (year in seq(2008,2015)){
  Dat <- read.csv(sprintf("/home/jhbelle/EPAdata/USEPA1hr/hourly_88101_%d.csv", year), stringsAsFactors = F)[,c(1:8,10:14,16,20)]
  print(nrow(Dat))
  write.table(SiteSort(Dat, AtlDef), file="/home/jhbelle/EPAdata/AtlObs1hrFRM.csv", append=T, row.names=F, col.name=F, sep=",")
  write.table(SiteSort(Dat, CalifDef), file="/home/jhbelle/EPAdata/CalifObs1hrFRM.csv", append=T, row.names=F, col.name=F, sep=",")
  write.table(SiteSort(Dat, ColoradoDef), file="/home/jhbelle/EPAdata/ColoradoObs1hrFRM.csv", append=T, row.names=F, col.name=F, sep=",")
  write.table(SiteSort(Dat, MidwestDef), file="/home/jhbelle/EPAdata/MdwstObs1hrFRM.csv", append=T, row.names=F, col.name=F, sep=",")
  rm(Dat)
  gc()
}

## --------------
# 24 Hr Speciated FRM PM_2.5 observations
## --------------

# Create empty files to write lines to
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "ParameterName", "Date", "24hrPMSpec", "MethodCode"), "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlObs24hrFRMSpec.csv", row.names=F, col.names = F, sep=",")
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "ParameterName", "Date", "24hrPMSpec", "MethodCode"), "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifObs24hrFRMSpec.csv", row.names=F, col.names = F, sep=",")
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "ParameterName", "Date", "24hrPMSpec", "MethodCode"), "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/MdwstObs24hrFRMSpec.csv", row.names=F, col.names = F, sep=",")
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "ParameterName", "Date", "24hrPMSpec", "MethodCode"), "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/ColoradoObs24hrFRMSpec.csv", row.names=F, col.names = F, sep=",")

# Loop over years, read in data, pull values of interest, and write those lines to the appropriate text file
for (year in seq(2007,2015)){
  Dat <- read.csv(sprintf("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAarchives/EPA_GroundMonitors/PM25_SPEC/daily_SPEC_%d.csv", year, year), stringsAsFactors = F)[,c(1:9,12,15,17,21)]
  print(nrow(Dat))
  Dat <- subset(Dat, Dat$Observation.Count == 1)[,c(1:10,12,13)]
  write.table(SiteSort(Dat, AtlDef), file="T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlObs24hrFRMSpec.csv", append=T, row.names=F, col.name=F, sep=",")
  write.table(SiteSort(Dat, CalifDef), file="T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifObs24hrFRMSpec.csv", append=T, row.names=F, col.name=F, sep=",")
  write.table(SiteSort(Dat, ColoradoDef), file="T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/ColoradoObs24hrFRMSpec.csv", append=T, row.names=F, col.name=F, sep=",")
  write.table(SiteSort(Dat, MidwestDef), file="T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/MdwstObs24hrFRMSpec.csv", append=T, row.names=F, col.name=F, sep=",")
  rm(Dat)
  gc()
}


## --------------
# 24 Hr Speciated FRM PM_2.5 blanks
## --------------

# Create empty files to write lines to
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Date", "BlankValue"), "/home/jhbelle/EPAdata/AtlObs24hrFRMBlanks.csv", row.names=F, col.names = F, sep=",")
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Date", "BlankValue"), "/home/jhbelle/EPAdata/CalifObs24hrFRMBlanks.csv", row.names=F, col.names = F, sep=",")
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Date", "BlankValue"), "/home/jhbelle/EPAdata/MdwstObs24hrFRMBlanks.csv", row.names=F, col.names = F, sep=",")
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Date", "BlankValue"), "/home/jhbelle/EPAdata/ColoradoObs24hrFRMBlanks.csv", row.names=F, col.names = F, sep=",")

# Loop over years, read in data, pull values of interest, and write those lines to the appropriate text file
for (year in seq(2007,2015)){
  Dat <- read.csv(sprintf("/home/jhbelle/EPAdata/USEPABlanks/blanks_all_%d.csv", year, year), stringsAsFactors = F)[,c(1:7,10:13)]
  print(nrow(Dat))
  Dat <- subset(Dat, (Dat$Parameter.Code == 88370 | Dat$Parameter.Code == 88380) & (Dat$Blank.Type == "FIELD" | Dat$Blank.Type == "FIELD 24HR"))[,c(1:7,9,11)]
  Dat$Longitude = as.integer(Dat$Longitude)
  Dat$Latitude = as.integer(Dat$Latitude)
  write.table(SiteSort(Dat, AtlDef), file="/home/jhbelle/EPAdata/AtlObs24hrFRMBlanks.csv", append=T, row.names=F, col.name=F, sep=",")
  write.table(SiteSort(Dat, CalifDef), file="/home/jhbelle/EPAdata/CalifObs24hrFRMBlanks.csv", append=T, row.names=F, col.name=F, sep=",")
  write.table(SiteSort(Dat, ColoradoDef), file="/home/jhbelle/EPAdata/ColoradoObs24hrFRMBlanks.csv", append=T, row.names=F, col.name=F, sep=",")
  write.table(SiteSort(Dat, MidwestDef), file="/home/jhbelle/EPAdata/MdwstObs24hrFRMBlanks.csv", append=T, row.names=F, col.name=F, sep=",")
  rm(Dat)
  gc()
}

## --------------
# Hourly Speciated FRM PM_2.5 observations
## --------------

#write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "ParameterName", "Date", "Time", "DateGMT", "TimeGMT", "1hrPMSpec", "Units", "MDL", "MethodCode", "MethodName"), "/home/jhbelle/EPAdata/AtlObs1hrFRMSpec.csv", row.names=F, col.names = F, sep=",")
#write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "ParameterName", "Date", "Time", "DateGMT", "TimeGMT", "1hrPMSpec", "Units", "MDL", "MethodCode", "MethodName"), "/home/jhbelle/EPAdata/CalifObs1hrFRMSpec.csv", row.names=F, col.names = F, sep=",")
#write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "ParameterName", "Date", "Time", "DateGMT", "TimeGMT", "1hrPMSpec", "Units", "MDL", "MethodCode", "MethodName"), "/home/jhbelle/EPAdata/MdwstObs1hrFRMSpec.csv", row.names=F, col.names = F, sep=",")
#write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Datum", "ParameterName", "Date", "Time", "DateGMT", "TimeGMT", "1hrPMSpec", "Units", "MDL", "MethodCode", "MethodName"), "/home/jhbelle/EPAdata/ColoradoObs1hrFRMSpec.csv", row.names=F, col.names = F, sep=",")

# Loop over years, read in data, pull values of interest, and write those lines to the appropriate text file
# NOTE: No hourly observations in 2007
#for (year in seq(2007,2015)){
#  Dat <- read.csv(sprintf("T:/EohProjs/CDC_climatechange/Jess/Dissertation/USEPASpeciatedPM/hourly_SPEC_%d/hourly_SPEC_%d.csv", year, year), stringsAsFactors = F)[,c(1:16,20,21)]
#  Dat$Longitude = as.integer(Dat$Longitude)
#  Dat$Latitude = as.integer(Dat$Latitude)
#  write.table(SiteSort(Dat, AtlDef), file="/home/jhbelle/EPAdata/AtlObs1hrFRMSpec.csv", append=T, row.names=F, col.name=F, sep=",")
#  write.table(SiteSort(Dat, CalifDef), file="/home/jhbelle/EPAdata/CalifObs1hrFRMSpec.csv", append=T, row.names=F, col.name=F, sep=",")
#  write.table(SiteSort(Dat, ColoradoDef), file="/home/jhbelle/EPAdata/ColoradoObs1hrFRMSpec.csv", append=T, row.names=F, col.name=F, sep=",")
#  write.table(SiteSort(Dat, MidwestDef), file="/home/jhbelle/EPAdata/MdwstObs1hrFRMSpec.csv", append=T, row.names=F, col.name=F, sep=",")
#  rm(Dat)
#  gc()
#}

## ---------------
## 24-hr temperature
## ---------------

write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Date", "Units", "Temperature"), "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlTemps.csv", row.names=F, col.names = F, sep=",")
write.table(cbind("State", "County", "Site", "ParameterCode", "POC", "Latitude", "Longitude", "Date", "Units", "Temperature"), "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifTemps.csv", row.names=F, col.names = F, sep=",")

# Loop over years, read in data, pull values of interest, and write those lines to the appropriate text file
for (year in seq(2007,2015)){
  Dat <- read.csv(sprintf("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAarchives/EPA_GroundMonitors/Temp/daily_TEMP_%d.csv", year, year), stringsAsFactors = F)[,c(1:7,12,13,17)]
  write.table(SiteSort(Dat, AtlDef), "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/AtlTemps.csv", append=T, row.names=F, col.name=F, sep=",")
  write.table(SiteSort(Dat, CalifDef), "T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifTemps.csv", append=T, row.names=F, col.name=F, sep=",")
  rm(Dat)
  gc()
}
