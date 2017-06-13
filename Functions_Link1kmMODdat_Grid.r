## -----------
## Function file associated with LinkMODdat_Grid.r
## -----------

## Function 1: Extract UID strings from grid file
ExtrUIDs <- function(colstrings){
  liststr <- strsplit(colstrings, ",")
  charvec <- str_trim(gsub("[[:punct:]]|c", "", liststr[[1]]))
  return(charvec)
}

## Function 2: Calculate values for each MAIAC pixel
CalcVals <- function(Griddat, MODdat, scale) {
  require(modeest)
  UIDframe <- cbind.data.frame(ExtrUIDs(Griddat[,3]))
  colnames(UIDframe) <- "UID"
  #UIDframe <- as.data.frame(UIDframe[which(!(substr(UIDframe$UID, 7, 15) %in% rmlist)),])
  #colnames(UIDframe) <- "UID"
  Tog <- merge(UIDframe, MODdat, by="UID")
  Tog$CloudPhase <- ifelse(Tog$CloudPhase == 0, NA, Tog$CloudPhase)
  Tog$CloudEmiss <- ifelse(Tog$CloudEmiss==127, NA, Tog$CloudEmiss)*scale
  CP <- mfv(Tog$CloudPhase)
  CE <- mean(Tog$CloudEmiss, na.rm=T)
  Outp <- cbind.data.frame(CP, CE)
  return(Outp)
}
