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

# For each day in the full time series, construct and save a multipart polygon with the MODIS granule boundaries in the CONUS for terra (bounded by: -140 W; -57 E; 56 N; 16 S)


# For each day, construct and save a multipart polygon with the MODIS granule boundaries in the CONUS for aqua (bounded by: -140 W; -57 E; 56 N; 16 S)



# Read in hourly observations
H1hr <- read.csv("/home/jhbelle/EPAdata/CleanedData/H1hr.csv")


# Get list of which granules each station falls under for each day
# Calculate representativeness for terra passtimes
# Write file
# Clean up

# For each day, construct and save a multipart polygon with the MODIS granule boundaries in the CONUS for aqua (bounded by: -140 W; -57 E; 56 N; 16 S)
# Get list of which granules each station falls under for each day
# Calculate representativeness for aqua passtimes
# Write file
# Clean up

