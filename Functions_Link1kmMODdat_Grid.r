## -----------
## Function file associated with LinkMODdat_Grid.r
## -----------

## Function 1: Extract UID strings from grid file
ExtrUIDs <- function(colstrings){
  require(stringr)
  liststr <- strsplit(colstrings, ",")
  charvec <- str_trim(gsub("[[:punct:]]|c", "", liststr[[1]]))
  return(charvec)
}

## Function 2: Calculate values for each MAIAC pixel
CalcVals <- function(Griddat, MODdat) {
  # Pull UIDs from gridded data
  UIDframe <- cbind.data.frame(ExtrUIDs(Griddat[,3]))
  colnames(UIDframe) <- "UID"
  # Merge Gridded pixels in this MAIAC pixel to MYD/MOD35 data
  Tog <- merge(UIDframe, MODdat, by="UID")
  # Merge in Cloud data from cloud product
  #Tog <- merge(Tog1, Clouddat, by.x=c("Index", "hr", "min"), by.y=c("MaskVal", "hr", "min"))
  # Scale and remove missing values from cloud effective radius and cloud aod
  #Tog$CldEffRad <- ifelse(Tog$CloudEffRad == -9999, NA, Tog$CloudEffRad)*scale
  #Tog$CloudAOD <- ifelse(Tog$CloudAOD == -9999, NA, Tog$CloudAOD)*scale
  # Aggregate cloud AOD and cloud effective radius
  #CER <- mean(Tog$CldEffRad, na.rm=T)
  #CAOD <- mean(Tog$CloudAOD, na.rm=T)
  # Return output
  Outp <- cbind.data.frame(Tog)
  return(Outp)
}
