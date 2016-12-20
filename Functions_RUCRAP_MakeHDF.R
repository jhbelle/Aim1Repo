## --------------
## Name: Functions_RUCRAP_MakeHDF.R
## Author: J.H. Belle
## Purpose: Function file for RUCRAP_MakeHDF.R
## --------------

# ---------
# Function 1: MakeEmptyDat - A function that takes in a data frame file, and variable list and creates a data frame with the additional variables added in, with 0 values for all rows
# ---------

MakeEmptyDat <- function(existFrame, varList){
  # Takes as input existFrame, a data frame, and varList a character vector and outputs a data frame expanded to include the new variables
  dat <- cbind.data.frame(existFrame, matrix(0, nrow=nrow(existFrame), ncol=length(varList)))
  colnames(dat) <- c(colnames(existFrame), varList)
  return(dat)
}

# ---------
# Function 2: RetValsGran - A function that takes a line of the MODIS GeoMetadata files, a grid file, and a dataset and returns only the observations that are within the granule
# ---------

RetValsGran <- function(geoLine, gridDat, dat, corLong=360, longVar = "Longitude.", latVar = "Latitude.", gridLat="Latitude.", gridLong= "Longitude"){
  # Takes as input geoLine, a single line from a MODIS GeoMeta data file; gridDat, a grid file consisting of a list of points located in the study area of interest - expected to correspond exactly to the points in dat; dat, a data file containing values at grid points; and corLong, the correction factor to equalize the longitude values between the two sets - RUCRAP uses the 360 degree notation instead of the more common -180 to 180 for longitude.
  # Correct Longitude field in dat
  dat[,longVar] <- dat[,longVar] - corLong
  # Subset dat to geoLine extent
  dat = subset(dat, dat[,latVar] <= geoLine$NorthBoundingCoord & dat[,latVar] >= geoLine$SouthBoundingCoord & dat[,longVar] <= geoLine$EastBoundingCoord & dat[,longVar] >= geoLine$WestBoundingCoord)
  # Merge dat to gridDat
  outDat = merge(gridDat, dat, by.x=c(gridLat, gridLong), by.y=c(latVar, longVar))
  # Output merged data
  return(outDat)
}

# --------
# Function 3:  
# --------
