## -----------------------
## Name: EPA_Colloc.R
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
source("Functions_EPA_Proc.R")

## --------------
## Prep and write files for collocations
## --------------
#For each region, need list of all monitors and days with a 24hour gravimetric average

## --------------
## Make file of station locations and capabilities for mapping
## --------------

MonDat <- rbind.data.frame(SiteCharMaps(Atl24, Atl1, AtlSpec), SiteCharMaps(Col24, Colorado1, ColSpec), SiteCharMaps(Mdwst24, Mdwst1, MdwstSpec), SiteCharMaps(Calif24, Calif1, CalifSpec))
MonDat$Cat <- ifelse(MonDat$HasSpec == 1 & MonDat$HasHourly == 1, "24 hour, 1 hour, and Speciated", ifelse(MonDat$HasSpec == 1 & MonDat$HasHourly == 0, "24 hour and Speciated", ifelse(MonDat$HasSpec == 0 & MonDat$HasHourly == 1, "24 hour and 1 hour", "24 hour only")))
write.csv(MonDat, "T:/eohprojs/CDC_climatechange/Jess/Dissertation/Imagery/MonitorData.csv")
