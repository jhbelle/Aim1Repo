## -------------
## Name: Cloud_Proc.R
## Program version: R 3.2.3
## Dependencies:
## Author: J.H. Belle
## Purpose: Process cloud product results
## -------------

# Read in 24-hour observations
CalifG24hr <- read.csv("T:/eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24hr.csv", stringsAsFactors = F)
CalifG24hr$Date2 <- as.Date(CalifG24hr$Date, "%Y-%m-%d")
CalifG24hr$Year <- as.numeric(as.character(CalifG24hr$Date2, "%Y"))
CalifG24hr$Jday <- as.numeric(as.character(CalifG24hr$Date2, "%j"))

# Define function to process cloud observations for each county, site, date, time (Assumes these variables exist in both sets of data)
# Note - cloud top height unscaled
ReadClouds <- function(datline, loc1km="E://CalifCloudCollocs1km/", loc5km="E://CalifCloudCollocs5km/", Scale=0.009999999776482582, AODfill=-9999, CloudHeightFill=-32767, FracFill=127){
  dat1km <- read.csv(paste(loc1km, "C", datline$County, "S", datline$Site, "Y", datline$Year, "D", datline$Jday, sep = ""), stringsAsFactors = F)

  dat5km <- read.csv(paste(loc5km, "C", datline$County, "S", datline$Site, "Y", datline$Year, "D", datline$Jday, sep = ""), stringsAsFactors = F)

}

# Define aggregation function