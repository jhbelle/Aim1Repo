## -------------------------
## Function file for CombEPA_MAIAC_Cloud_RUC.R
## -------------------------

## -----------
## Function 1: CombMAIAC - For each EPA observation reads in MAIAC dataset and converts to rows in a dataframe with aggregate statistics over Terra and Aqua passes
## -----------

CombMAIAC <- function(datline, radius=10, dataloc="T://eohprojs/CDC_climatechange/MAIACdat/CalifCollocs/"){
  # A function to read in the MAIAC data file corresponding to the line, aggregate statistics within a radius, and output the resulting datalines
  require(plyr)
  # Read in MAIAC file
  MAIACdat <- try(read.csv(sprintf("%sC%dS%d_%s_%03d.csv", dataloc, datline$County, datline$Site, as.character(datline$Date, "%Y"), as.integer(as.character(datline$Date, "%j"))), stringsAsFactors = F)[,c(6,7,9:11)])
  if (is.data.frame(MAIACdat)){
    # Subset to values with QA > 0 - these are missing due to overpass geometry and don't matter?
    MAIACdat <- subset(MAIACdat, MAIACdat$AODQA > 0)
    # Scale and convert AOD values
    MAIACdat$AOD47 <- as.numeric(MAIACdat$AOD47)*0.001
    MAIACdat$AOD55 <- as.numeric(MAIACdat$AOD55)*0.001
    # Strip any extra white space from AquaTerraFlag
    MAIACdat$AquaTerraFlag <- trimws(MAIACdat$AquaTerraFlag)
    # Create flags from QA codes
    MAIACdat <- adply(MAIACdat, 1, DefQA, qafield="AODQA")
    # Remove old QA field
    MAIACdat$AODQA <- NULL
    # Aggregate values by timestep and T/A flag - need to retain counts
    Outp <- ddply(MAIACdat, .(Time, AquaTerraFlag), AggMAIAC)
    return(Outp)
  }
}

## ------------
## Function 2: ConvQA - Converts the QA value to a binary character string
## ------------

# Define function to convert the QA field from a decimal to a binary string vector
ConvQA <- function(intnum, intlength=16){
  # For binary conversion need remainders from repeatedly dividing the integer value by 2, each remainder is 1 of 16 positions for a 16 bit unsigned integer value
  rem = rep(NA, intlength)
  for (bit in seq(1,intlength)){
    rem[bit] = intnum %% 2
    intnum = intnum %/% 2
  }
  return(as.character(rem))
}

## ------------
## Function 3: DefQA - Converts the QA value to a set of dummy variables
## ------------
# Function to define QA values
DefQA <- function(dat, qafield){
  convqaval <- ConvQA(dat[,c(qafield)])
  # Cloud contamination flags
  Cloudnum <- as.integer(paste(convqaval[3], convqaval[2], convqaval[1], sep=""))
  dat$Partcloud <- ifelse(Cloudnum == 10, 1, 0)
  dat$Cloud <- ifelse(Cloudnum == 11, 1, 0)
  dat$CloudShadow <- ifelse(Cloudnum == 101, 1, 0)
  dat$Fire <- ifelse(Cloudnum == 110, 1, 0)
  dat$Sediment <- ifelse(Cloudnum == 111, 1, 0)
  dat$Clear <- ifelse(Cloudnum == 1, 1, 0)
  # Land/water/snow/ice flags
  LType <- as.integer(paste(convqaval[5], convqaval[4], sep=""))
  dat$Water <- ifelse(LType == 1, 1, 0)
  dat$Snow <- ifelse(LType == 10, 1, 0)
  dat$Ice <- ifelse(LType == 11, 1, 0)
  # Glint flag
  dat$Glint <- as.integer(convqaval[13])
  # Adjacency flags
  Adjnum <- as.integer(paste(convqaval[8], convqaval[7], convqaval[6], sep=""))
  dat$AdjCloud <- ifelse(Adjnum == 1, 1, 0)
  dat$SurCloud <- ifelse(Adjnum == 10, 1, 0)
  dat$OneCloud <- ifelse(Adjnum == 11, 1, 0)
  dat$AdjSnow <- ifelse(Adjnum == 100, 1, 0)
  dat$PrevSnow <- ifelse(Adjnum == 101, 1, 0)
  return(dat)
}

## --------------
## Function 4: AggMAIAC - A function to aggregate the MAIAC statistics
## --------------

AggMAIAC <- function(dat){
  # Takes in a block of MAIAC data and returns the proper aggregate statistics + the number of observations included in the aggregate
  # Take the means of all columns
  Outp <- as.data.frame(t(apply(dat[,c("AOD47", "AOD55", "Partcloud", "Cloud", "CloudShadow", "Fire", "Sediment", "Clear", "Water", "Snow", "Ice", "Glint", "AdjCloud", "SurCloud", "OneCloud", "AdjSnow", "PrevSnow")], 2, mean, na.rm=T)))
  # Add in the number of observations included in the average so weighted means for T/A can be calculated later
  Outp$Nobs <- nrow(dat)
  return(Outp)
}

## --------------
## Function 5: AggPass - A function to aggregate a variable, taking a weighted average - intended to be used with apply
## --------------

AggPass <- function(x){
  Time = weighted.mean(x$Time, x$Nobs, na.rm=T)
  AOD47 = weighted.mean(x$AOD47, x$Nobs, na.rm=T)
  AOD55 = weighted.mean(x$AOD55, x$Nobs, na.rm=T)
  PartCloud = weighted.mean(x$Partcloud, x$Nobs, na.rm=T)
  Cloud = weighted.mean(x$Cloud, x$Nobs, na.rm=T)
  CloudShadow = weighted.mean(x$CloudShadow, x$Nobs, na.rm=T)
  Fire = weighted.mean(x$Fire, x$Nobs, na.rm=T)
  Sediment = weighted.mean(x$Sediment, x$Nobs, na.rm=T)
  Clear = weighted.mean(x$Clear, x$Nobs, na.rm=T)
  Water = weighted.mean(x$Water, x$Nobs, na.rm=T)
  Snow = weighted.mean(x$Snow, x$Nobs, na.rm=T)
  Ice = weighted.mean(x$Ice, x$Nobs, na.rm=T)
  Glint = weighted.mean(x$Glint, x$Nobs, na.rm=T)
  AdjCloud = weighted.mean(x$AdjCloud, x$Nobs, na.rm=T)
  SurCloud = weighted.mean(x$SurCloud, x$Nobs, na.rm=T)
  OneCloud = weighted.mean(x$OneCloud, x$Nobs, na.rm=T)
  AdjSnow = weighted.mean(x$AdjSnow, x$Nobs, na.rm=T)
  PrevSnow = weighted.mean(x$PrevSnow, x$Nobs, na.rm=T)
  CloudAOD = weighted.mean(x$CloudAOD, x$Nobs, na.rm=T)
  PCloudAOD = weighted.mean(x$PCloudAOD, x$Nobs, na.rm=T)
  CloudTopHgt = weighted.mean(x$CloudTopHgt, x$Nobs, na.rm=T)
  PAnyCld = weighted.mean(x$PAnyCld, x$Nobs, na.rm=T)
  PSingleCld = weighted.mean(x$PSingleCld, x$Nobs, na.rm=T)
  PMultiCld = weighted.mean(x$PMultiCld, x$Nobs, na.rm=T)
  Outp <- cbind.data.frame(Time, AOD47, AOD55, PartCloud, Cloud, CloudShadow, Fire, Sediment, Clear, Water, Snow, Ice, Glint, AdjCloud, SurCloud, OneCloud, AdjSnow, PrevSnow, CloudAOD, PCloudAOD, CloudTopHgt, PAnyCld, PSingleCld, PMultiCld)
  return(Outp)
}

## --------------
## Function 6: AggRUC - A function to bring in the correct RUC/RAP file for each row and aggregate the data from it
## --------------

AggRUC <- function(datline, NearTable, RUCRAPloc="/gc_runs/RUCRAP_FinalOutputs/"){
  require(rhdf5)
  NearLine <- which(NearTable$State == datline$State & NearTable$County == datline$County & NearTable$Site == datline$Site)
  # For each line in the data, need to read in the correct hdf5 file, and pull correct values for this station
  hdfdat <- sprintf("%s%s/%s/RUCRAP_130_%s.h5", RUCRAPloc, ifelse(datline$AquaTerraFlag == "A", "Aqua", "Terra"), as.character(datline$Date, "%Y"), as.character(datline$Date, "%Y%m%d"))
  if (file.exists(hdfdat)){
    # Pull lat/lon info from hdf file - technically can assume that   
    LatLon <- as.data.frame(h5read(hdfdat, "Geolocation"))
    CorIndex <- which(LatLon$Latitude. == NearTable$Latitude_[NearLine] & LatLon$Longitude == NearTable$Longitude_1[NearLine])
    Outp <- cbind.data.frame(datline, as.data.frame(h5read(hdfdat, "Data"))[CorIndex,])
    return(Outp)
  }
}

