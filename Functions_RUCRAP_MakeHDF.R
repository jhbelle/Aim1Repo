## --------------
## Name: Functions_RUCRAP_MakeHDF.R
## Author: J.H. Belle
## Purpose: Function file for RUCRAP_MakeHDF.R
## --------------

# ---------
# Function 1: MakeEmptyDat - A function that takes in a data frame file, and variable list and creates a data frame with the additional variables added in, with 0 values for all rows
# ---------

MakeEmptyDat <- function(existFrame, varList){
  # Takes as input existFrame, a data frame, and varList, a character vector, and outputs a data frame expanded to include the new variables
  dat <- cbind.data.frame(existFrame, matrix(0, nrow=nrow(existFrame), ncol=length(varList)))
  colnames(dat) <- c(colnames(existFrame), varList)
  return(dat)
}

# ---------
# Function 2: RetValsGran - A function that takes a line of the MODIS GeoMetadata files, a grid file, and a dataset and returns only the observations in the dataset that are within the granule and grid
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
# Function 3: AddVals - A function that adds values of a specified variable from one dataset into another
# --------

AddVals <- function(baseDat, addDat, varInt, corLong=0, addLong="Longitude.", addLat="Latitude."){
  # Takes as input baseDat, a dataset that you would like to add the values in addDat to, addDat, the values to add to baseDat, varInt, the variable to add the values to. Assumed addition is by x/y coordinates. Assumes that baseDat requires no aggregation
  # Correct Longitude field in addDat, set corLong to 0 if no correction is needed
  addDat[,addLong] <- addDat[,addLong] - corLong
  # Aggregate addDat to make sure only one observation per location
  addDat <- aggregate(Value. ~ Latitude. + Longitude., addDat, sum)
  # Merge base and addDats, keeping all base observations
  outDat <- merge(baseDat, addDat, by.x=c(), by.y=c(), all.x=T)
  # Add new values to appropriate column
  outDat[,varInt] = outDat[,varInt] + outDat$Value.
  # Remove additional variable 
  outDat$Value. <- NULL
  # Return baseDat with values added in
  return(outDat)
}

# ---------
# Function 4: WriteHDF - A function to write an hdf5 file, given a data frame. Assumes that geolocation fields exist; writes data in table format, not as 2D matrices, Chunking information can be provided
# ---------

WriteHDF <- function(writeDat, fileName, geoLocFields=c("Latitude.", "Longitude")){
  # Takes as input a dataset to write to an hdf file and the name of the file to write
  require(rhdf5)
  # Create file
  h5createFile(fileName)
  # Create groups - one for data one for geolocation, as per MODIS
  h5createGroup(fileName, 'Geolocation')
  h5createGroup(fileName, 'Data')
  # Write geolocation fields
  for (field in geoLocFields){
    geoloc = h5write(writeDat[,field], fileName, sprintf("/Geolocation/%s", field))
    H5Dclose(geoloc)
  }
  # Get list of variables in writeDat that are not in geoLocFields
  varlist = subset(colnames(writeDat), !('%in%'(colnames(writeDat), geoLocFields)))
  # Write variables
  for (var in varlist){
    vals = h5write(writeDat[,var], fileName, sprintf("/Data/%s", var), write.attributes=T)
    H5Dclose(vals)
  }
  # Close file
  H5close()
}
