### -----------
# Functions_PredVals.R
### -----------

## ------
# Function 1: PrepMainDat - Get right variable names and calculate things like windspeed for main model
## ------

PrepMainDat = function(dat1day, roadlengths){
  dat1day$AOD55.y = ifelse(as.numeric(as.character(dat1day$AOD55)) == -28672, NA, as.numeric(as.character(dat1day$AOD55)))*0.001
  dat1day$pblh.y = ifelse(as.numeric(as.character(dat1day$hpbl_surface)) < 0, NA, as.numeric(as.character(dat1day$hpbl_surface)))/1000
  dat1day$CenteredTemp.y = as.numeric(as.character(dat1day$X2t_heightAboveGround)) - 273.15
  dat1day$WindSpeed.y = sqrt(as.numeric(as.character(dat1day$X10u_heightAboveGround))^2 + as.numeric(as.character(dat1day$X10v_heightAboveGround))^2)
  dat1day$r_heightAboveGround.y = as.numeric(as.character(dat1day$r_heightAboveGround))
  dat1day$Elev.y.y = as.numeric(as.character(dat1day$Elev))
  dat1day$NEIPM.y = as.numeric(as.character(dat1day$NEIPM))
  dat1day$PercForest.y = as.numeric(as.character(dat1day$PercForest))
  dat1day$DOY = as.numeric(as.character(dat1day$Date))
  dat1day = merge(dat1day, roadlengths, by.x="InputFID", by.y="Input_FID")
  return(dat1day)
}

## ------
# Function 2: PrepCloudDat - Get right variables names and calculate cloud parameters for cloud model
## ------

PrepMainDat2 = function(dat1day){
  dat1day$AOD55.y = ifelse(as.numeric(as.character(dat1day$AOD55)) == -28672, NA, as.numeric(as.character(dat1day$AOD55)))*0.001
  dat1day$pblh.y = ifelse(as.numeric(as.character(dat1day$hpbl_surface)) < 0, NA, as.numeric(as.character(dat1day$hpbl_surface)))/1000
  dat1day$CenteredTemp.y = as.numeric(as.character(dat1day$X2t_heightAboveGround)) - 273.15
  dat1day$WindSpeed.y = sqrt(as.numeric(as.character(dat1day$X10u_heightAboveGround))^2 + as.numeric(as.character(dat1day$X10v_heightAboveGround))^2)
  dat1day$r_heightAboveGround.y = as.numeric(as.character(dat1day$r_heightAboveGround))
  dat1day$Elev.y.y = as.numeric(as.character(dat1day$Elev))
  dat1day$NEIPM.y = as.numeric(as.character(dat1day$NEIPM))
  dat1day$PercForest.y = as.numeric(as.character(dat1day$PercForest))
  dat1day$DOY = as.numeric(as.character(dat1day$Date))
  dat1day$PRoadLengt.y = dat1day$PRoadLength
  return(dat1day)
}
