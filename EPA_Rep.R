## -----------------------
## Name: EPA_Rep.R
## Program version: R 3.2.3
## Dependencies: plyr
## Function file: Functions_EPA_Proc.R
## References:
## Author: J.H. Belle
## Purpose: Process representativeness values from EPA hourly observation locations and times and MODIS geometadata files available from ladsweb. Each 'representativeness values is the percent difference from the 24 hour average of the hourly observations
##    NOTE: Current study period: 04/01/2007-03/31/2015;
##    NOTE: Processing 24 hour PM, 24 hour Speciated PM, 1 Hr PM, and 1 Hr Speciated separately and including weather data for each observation, if available
## -----------------------

# Load libraries
library(plyr)
source("Functions_EPA_Proc.R")

# For each day, construct and save a multipart polygon with the MODIS granule boundaries in the CONUS for aqua (bounded by: -140 W; -57 E; 56 N; 16 S)
Dates <- seq(as.Date("2002/1/1"), as.Date("2016/8/1"), by="days")
for (day in Dates){
  ModGeo <- read.csv("/aqua/MODIS_GeoMeta/TERRA/2003/MOD03_2003-01-01.txt", skip=2, header=T)
  InUSD <- subset(ModGeo, ModGeo$DayNightFlag == "D" & ModGeo$EastBoundingCoord > -140 & ModGeo$WestBoundingCoord < -57 & ModGeo$NorthBoundingCoord > 16 & ModGeo$SouthBoundingCoord < 56)[,c(1,2,10:17)]
  if (nrow(InUSD) > 0){
    for (i in nrow(InUSD)){
      coords <- Polygon(cbind.data.frame(as.numeric(InUSD[i,c(3:6,3)]), as.numeric(InUSD[i,c(7:10,7)])), hole=F)

    }
    # Create SP
    polys <- SpatialPolygons(mapply(function(poly, id) {
      xy <- matrix(poly, ncol=2, byrow=TRUE)
      Polygons(list(Polygon(xy)), ID=id)
    }, split(InUSD, row(InUSD)), ID))

    # Create SPDF
    polys.df <- SpatialPolygonsDataFrame(polys, data.frame(id=ID, row.names=ID))
  }

}
# Above was run on cluster

# Read in hourly observations
#H1hr <- read.csv("/home/jhbelle/EPAdata/CleanedData/H1hr.csv")


# Get list of which granules each station falls under for each day
# Calculate representativeness for terra passtimes
# Write file
# Clean up

# For each day, construct and save a multipart polygon with the MODIS granule boundaries in the CONUS for aqua (bounded by: -140 W; -57 E; 56 N; 16 S)
# Get list of which granules each station falls under for each day
# Calculate representativeness for aqua passtimes
# Write file
# Clean up

