## ----------------
## Functions_HarvardModel.R
## ----------------


## Function 1: AggMAIACRUC - A function that aggregates the MAIAC and RUC observations for each MAIAC pixel

AggMAIACRUC <- function(datblock, day, RUClatlon, RUCdat){
  require(rhdf5)  
  # Aggregate MAIAC data
  InputFID = datblock$InputFID[1]
  # Spatial vars
  POINT_X = datblock$POINT_X[1]
  POINT_Y = datblock$POINT_Y[1]
  PercForest = datblock$PercForest[1]
  PRoadLength = datblock$PRoadLength[1]
  RUCLat = datblock$RUCLat[1]
  RUCLon = datblock$RUCLon[1]
  NEIPM = datblock$NEIPM[1]
  Elev = datblock$Elev[1]
  Year = datblock$Year[1]
  Day = as.character(day, "%Y-%m-%d")
  Overpass = trimws(datblock$Overpass[1])
  # AOD
  datblock$AOD55 = ifelse(datblock$AOD55 == -28672, NA, datblock$AOD55)*0.001
  AOD = mean(datblock$AOD55, na.rm=T)
  # Pull in RUC data
  CorIndex <- which(RUClatlon$Latitude. == RUCLat & RUClatlon$Longitude == RUCLon)
  RUCvars = as.data.frame(h5read(hdfdat, "Data"))[CorIndex,]
  # Add in EPA data 
  #if (InputFID %in% NearMAIACEPA$Input_FID){
  #  State = NearMAIACEPA$State[NearMAIACEPA$Input_FID == InputFID]
  #  County = NearMAIACEPA$County[NearMAIACEPA$Input_FID == InputFID]
  #  Site = NearMAIACEPA$Site[NearMAIACEPA$Input_FID == InputFID]
  #  EPAPM = EPAdat$X24hrPM[EPAdat$State == State & EPAdat$County == County & EPAdat$Site == Site & EPAdat$Date == Day]
  #} else { EPAPM = NA }
  Outp <- try(cbind.data.frame(InputFID, POINT_X, POINT_Y, PercForest, PRoadLength, RUCLat, RUCLon, NEIPM, Elev, Year, Day, Overpass, AOD, RUCvars))
  if (is.data.frame(Outp)) return(Outp)
}

GetRUCVals <- function(datblock, hdfdat, RUClatlon){ 
    Index = which(RUClatlon$Latitude. == datblock$RUCLat & RUClatlon$Longitude == datblock$RUCLon)
    outdat = as.data.frame(h5read(hdfdat, "Data"))[Index,] 
    return(outdat)
  }
