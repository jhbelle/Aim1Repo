## -------------
## Name: Cloud_Proc.R
## Program version: R 3.2.3
## Dependencies:
## Author: J.H. Belle
## Purpose: Process cloud product results
## -------------

# Read in 24-hour observations
CalifG24hr <- read.csv("T:/eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24hr.csv", stringsAsFactors = F)
CalifG24hr$Date2 <- as.Date(CalifG24hr$Date, "%Y-%m-%d")
CalifG24hr$Year <- as.numeric(as.character(CalifG24hr$Date2, "%Y"))
CalifG24hr$Jday <- as.numeric(as.character(CalifG24hr$Date2, "%j"))

# Define function to process cloud observations for each county, site, date, time (Assumes these variables exist in both sets of data)
# Note - cloud top height unscaled; Decided to use 1 km Multi for cloud fractions instead of the 5km cloud fraction
ReadClouds <- function(datline, loc1km="E://CalifCloudCollocs1km/", loc5km="E://CalifCloudCollocs5km/", Scale=0.009999999776482582, AODfill=-9999, CloudHeightFill=-32767, FracFill=127, Radius){
  dat1km <- read.csv(paste(loc1km, "C", datline$County, "S", datline$Site, "Y", datline$Year, "D", datline$Jday, sep = ""), stringsAsFactors = F)
  # Subset to observations within the radius of interest
  dat1km = subset(dat1km, dat1km$DistStation <= Radius)
  # Aggregate multi flag to get the %single cloud; %multicloud; %cloud
  if (sum(dat1km$Multi > 0)){
    dat1km$Multi <- cut(dat1km$Multi, c(-0.5,0.5,1.5,10), c("None", "Single", "Multi"))
    Multitable <- xtabs(~ Multi + Time, dat1km)
    PAnyCld = (Multitable[2,] + Multitable[3,])/(Multitable[1,] + Multitable[2,] + Multitable[3,])
    PSingleCld = Multitable[2,]/(Multitable[2,] + Multitable[3,])
    PMultiCld = Multitable[3,]/(Multitable[2,] + Multitable[3,])
    # Convert fill values to missing
    dat1km$CloudAOD[dat1km$CloudAOD == AODfill] = NA
    dat1km$PCloudAOD[dat1km$PCloudAOD == AODfill] = NA
    # Scale AOD
    dat1km$CloudAOD = dat1km$CloudAOD*Scale
    dat1km$PCloudAOD = dat1km$PCloudAOD*Scale
    Time = as.data.frame(as.integer(levels(as.factor(dat1km$Time))))
    colnames(Time) <- c("Time")
    # Aggregate AOD statistics for each timestamp
    if (sum(!is.na(dat1km$CloudAOD)) > 0){
      MCloudAOD <- aggregate(CloudAOD ~ Time, dat1km, median)
    } else {
      CloudAOD = rep(NA, length(Time))
      MCloudAOD <- cbind.data.frame(Time, CloudAOD)
    }
    Clouds <- merge(Time, MCloudAOD, all=T)
    if (sum(!is.na(dat1km$PCloudAOD)) > 0){
      MPCloudAOD <- aggregate(PCloudAOD ~ Time, dat1km, median)
    } else {
      PCloudAOD = rep(NA, length(Time))
      MPCloudAOD <- cbind.data.frame(Time, PCloudAOD)
    }
    Clouds <- merge(Clouds, MPCloudAOD, all=T)
    rm(MCloudAOD, MPCloudAOD, Multitable)
    # Read in 5km dataset
    dat5km <- read.csv(paste(loc5km, "C", datline$County, "S", datline$Site, "Y", datline$Year, "D", datline$Jday, sep = ""), stringsAsFactors = F)
    # Subset to observations within radius of interest
    dat5km = subset(dat5km, dat5km$DistStation <= Radius)
    # Convert fill values to missing
    dat5km$CloudTopHgt[dat5km$CloudTopHgt == CloudHeightFill] = NA
    # Calculate statistics for cloud top height
    if (sum(!is.na(dat5km$CloudTopHgt)) > 0){
      MCldHgt <- aggregate(CloudTopHgt ~ Time, dat5km, median)
    } else {
      CloudTopHgt = rep(NA, length(Time))
      MCldHgt <- cbind.data.frame(Time, CloudTopHgt)
    }
    Clouds <- merge(Clouds, MCldHgt, all=T)
    # Create output dataset
    outDat <- cbind.data.frame(Clouds, PAnyCld, PSingleCld, PMultiCld)
    rm(MCldHgt, Clouds, PAnyCld, PSingleCld, PMultiCld)
  } else {
    # Need to fix these so includes times
    Time = levels(as.factor(dat1km$Time))
    PAnyCld = rep(0,length(Time))
    PSingleCld = rep(NA, length(Time))
    PMultiCld = rep(NA, length(Time))
    CloudAOD = rep(NA, length(Time))
    PCloudAOD = rep(NA, length(Time))
    CloudTopHgt = rep(NA, length(Time))
    outDat <- cbind.data.frame(Time, CloudAOD, PCloudAOD, CloudTopHgt, PAnyCld, PSingleCld, PMultiCld)
  }
  return(outDat)
}


library(plyr)
Out5km = ddply(CalifG24hr, .(State, County, Site, Date, X24hrPM), ReadClouds, Radius=5)
write.csv(Out5km, "E://CloudAgg_5km.csv")

Out10km = ddply(CalifG24hr, .(State, County, Site, Date, X24hrPM), ReadClouds, Radius=10)
write.csv(Out10km, "E://CloudAgg_10km.csv")

Out20km = ddply(CalifG24hr, .(State, County, Site, Date, X24hrPM), ReadClouds, Radius=20)
write.csv(Out20km, "E://CloudAgg_20km.csv")

Out30km = ddply(CalifG24hr, .(State, County, Site, Date, X24hrPM), ReadClouds, Radius=30)
write.csv(Out30km, "E://CloudAgg_30km.csv")

Out40km = ddply(CalifG24hr, .(State, County, Site, Date, X24hrPM), ReadClouds, Radius=40)
write.csv(Out40km, "E://CloudAgg_40km.csv")
