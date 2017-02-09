## -------------
## Name: Cloud_Proc.R
## Program version: R 3.2.3
## Dependencies:
## Author: J.H. Belle
## Purpose: Process cloud product results
## -------------

# Read in 24-hour observations
#CalifG24hr <- read.csv("T:/eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24hr.csv", stringsAsFactors = F)
#CalifG24hr$Date2 <- as.Date(CalifG24hr$Date, "%Y-%m-%d")
#CalifG24hr$Year <- as.numeric(as.character(CalifG24hr$Date2, "%Y"))
#CalifG24hr$Jday <- as.numeric(as.character(CalifG24hr$Date2, "%j"))

AtlG24hr <- read.csv("/aqua/Jess/Data/AtlG24hr.csv", stringsAsFactors=F)
AtlG24hr$Date2 <- as.Date(AtlG24hr$Date, "%Y-%m-%d")
AtlG24hr$Year <- as.numeric(as.character(AtlG24hr$Date2, "%Y"))
AtlG24hr$Jday <- as.numeric(as.character(AtlG24hr$Date2, "%j"))

# Define mode function
Mode <- function(x) {
  f <- factor(as.vector(x))
  tf <- tabulate(f)
  Out = as.numeric(levels(f)[tf==max(tf)])
  if (length(Out) > 1) { Out = min(Out) }
  return(Out)
}

# Define function to process cloud observations for each county, site, date, time (Assumes these variables exist in both sets of data)
# Note - cloud top height unscaled; Decided to use 1 km Multi for cloud fractions instead of the 5km cloud fraction
ReadClouds <- function(datline, loc1km="/aqua/Jess/Data/Cld1km/", loc5km="/aqua/Jess/Data/Cld5km/", Scale=0.009999999776482582, AODfill=-9999, CloudHeightFill=-32767, FracFill=127, Radius){
  dat1km <- read.csv(paste(loc1km, "C", datline$County, "S", datline$Site, "Y", datline$Year, "D", datline$Jday, sep = ""), stringsAsFactors = F)
  # Subset to observations within the radius of interest
  dat1km = subset(dat1km, dat1km$DistStation <= Radius)
  # Aggregate multi flag to get the %single cloud; %multicloud; %cloud
  # If clouds exist
  if (sum(dat1km$Multi > 0)){
    dat1km$Multi <- cut(dat1km$Multi, c(-0.5,0.5,1.5,10), c("None", "Single", "Multi"))
    Multitable <- xtabs(~ Multi + Time, dat1km)
    PAnyCld = (Multitable[2,] + Multitable[3,])/(Multitable[1,] + Multitable[2,] + Multitable[3,])
    PSingleCld = Multitable[2,]/(Multitable[2,] + Multitable[3,])
    PMultiCld = Multitable[3,]/(Multitable[2,] + Multitable[3,])
    # Convert fill values to missing
    dat1km$CloudAOD[dat1km$CloudAOD == AODfill] = NA
    dat1km$PCloudAOD[dat1km$PCloudAOD == AODfill] = NA
    dat1km$CloudRadius[dat1km$CloudRadius == AODfill] = NA
    dat1km$CloudWaterPath[dat1km$CloudWaterPath == AODfill] = NA
    # Scale AOD
    dat1km$CloudAOD = dat1km$CloudAOD*Scale
    dat1km$PCloudAOD = dat1km$PCloudAOD*Scale
    dat1km$CloudRadius = dat1km$CloudRadius*Scale
    Time = as.data.frame(as.integer(levels(as.factor(dat1km$Time))))
    colnames(Time) <- c("Time")
    # Aggregate AOD statistics for each timestamp
    if (sum(!is.na(dat1km$CloudAOD)) > 0){
      MCloudAOD <- aggregate(CloudAOD ~ Time, dat1km, median, na.rm=T)
    } else {
      CloudAOD = rep(NA, length(Time))
      MCloudAOD <- cbind.data.frame(Time, CloudAOD)
    }
    Clouds <- merge(Time, MCloudAOD, all=T)
    if (sum(!is.na(dat1km$PCloudAOD)) > 0){
      MPCloudAOD <- aggregate(PCloudAOD ~ Time, dat1km, median, na.rm=T)
    } else {
      PCloudAOD = rep(NA, length(Time))
      MPCloudAOD <- cbind.data.frame(Time, PCloudAOD)
    }
    Clouds <- merge(Clouds, MPCloudAOD, all=T)
    if (sum(!is.na(dat1km$CloudRadius)) > 0){
      MCloudRad <- aggregate(CloudRadius ~ Time, dat1km, median, na.rm=T)
    } else {
      CloudRadius = rep(NA, length(Time))
      MCloudRad <- cbind.data.frame(Time, CloudRadius)
    }
    Clouds <- merge(Clouds, MCloudRad, all=T)
    if (sum(!is.na(dat1km$CloudWaterPath)) > 0){
      MCloudWPath <- aggregate(CloudWaterPath ~ Time, dat1km, median, na.rm=T)
    } else {
      CloudWaterPath = rep(NA, length(Time))
      MCloudWPath <- cbind.data.frame(Time, CloudWaterPath)
    }
    Clouds <- merge(Clouds, MCloudWPath, all=T)
    rm(MCloudAOD, MPCloudAOD, Multitable, MCloudRad, MCloudWPath)
    # Read in 5km dataset
    dat5km <- read.csv(paste(loc5km, "C", datline$County, "S", datline$Site, "Y", datline$Year, "D", datline$Jday, sep = ""), stringsAsFactors = F)
    # Subset to observations within radius of interest
    dat5km = subset(dat5km, dat5km$DistStation <= Radius)
    # Convert fill values to missing
    dat5km$CloudTopHgt[dat5km$CloudTopHgt == CloudHeightFill] = NA
    dat5km$CloudPhase[dat5km$CloudPhase == FracFill] = NA
    dat5km$CloudTopTemp[dat5km$CloudTopTemp == CloudHeightFill] = NA
    dat5km$CloudEmmisivity[dat5km$CloudEmmisivity == FracFill] = NA
    # Calculate statistics for cloud top height
    if (sum(!is.na(dat5km$CloudTopHgt)) > 0){
      MCldHgt <- aggregate(CloudTopHgt ~ Time, dat5km, median, na.rm=T)
    } else {
      CloudTopHgt = rep(NA, length(Time))
      MCldHgt <- cbind.data.frame(Time, CloudTopHgt)
    }
    Clouds <- merge(Clouds, MCldHgt, all=T)
    if (sum(!is.na(dat5km$CloudPhase)) > 0){
      MCldPhase <- aggregate(CloudPhase ~ Time, dat5km, Mode)
    } else {
      CloudPhase = rep(NA, length(Time))
      MCldPhase <- cbind.data.frame(Time, CloudPhase)
    }
    Clouds <- merge(Clouds, MCldPhase, all=T)
    if (sum(!is.na(dat5km$CloudTopTemp)) > 0){
      MCldTemp <- aggregate(CloudTopTemp ~ Time, dat5km, median, na.rm=T)
    } else {
      CloudTopTemp = rep(NA, length(Time))
      MCldTemp <- cbind.data.frame(Time, CloudTopTemp)
    }
    Clouds <- merge(Clouds, MCldTemp, all=T)
    if (sum(!is.na(dat5km$CloudEmmisivity)) > 0){
      MCldEmiss <- aggregate(CloudEmmisivity ~ Time, dat5km, median, na.rm=T)
    } else {
      CloudEmmisivity = rep(NA, length(Time))
      MCldEmiss <- cbind.data.frame(Time, CloudEmmisivity)
    }
    Clouds <- merge(Clouds, MCldEmiss, all=T)
    # Create output dataset
    outDat <- cbind.data.frame(Clouds, PAnyCld, PSingleCld, PMultiCld)
    rm(MCldHgt, MCldPhase, MCldTemp, MCldEmiss, Clouds, PAnyCld, PSingleCld, PMultiCld)
  } else {
    # Need to fix these so includes times
    Time = levels(as.factor(dat1km$Time))
    PAnyCld = rep(0,length(Time))
    PSingleCld = rep(NA, length(Time))
    PMultiCld = rep(NA, length(Time))
    CloudAOD = rep(NA, length(Time))
    PCloudAOD = rep(NA, length(Time))
    CloudTopHgt = rep(NA, length(Time))
    CloudRadius = rep(NA, length(Time))
    CloudWaterPath = rep(NA, length(Time))
    CloudPhase = rep(NA, length(Time))
    CloudTopTemp = rep(NA, length(Time))
    CloudEmmisivity = rep(NA, length(Time))
    outDat <- cbind.data.frame(Time, CloudAOD, PCloudAOD, CloudRadius, CloudWaterPath, CloudTopHgt, CloudPhase, CloudTopTemp, CloudEmmisivity, PAnyCld, PSingleCld, PMultiCld)
  }
  return(outDat)
}


library(plyr)
#Out5km = ddply(CalifG24hr, .(State, County, Site, Date, X24hrPM), ReadClouds, Radius=5)
#write.csv(Out5km, "E://CloudAgg_5km.csv")

#Out10km = ddply(CalifG24hr, .(State, County, Site, Date, X24hrPM), ReadClouds, Radius=10)
#write.csv(Out10km, "E://CloudAgg_10km.csv")

#Out20km = ddply(CalifG24hr, .(State, County, Site, Date, X24hrPM), ReadClouds, Radius=20)
#write.csv(Out20km, "E://CloudAgg_20km.csv")

#Out30km = ddply(CalifG24hr, .(State, County, Site, Date, X24hrPM), ReadClouds, Radius=30)
#write.csv(Out30km, "E://CloudAgg_30km.csv")

#Out40km = ddply(CalifG24hr, .(State, County, Site, Date, X24hrPM), ReadClouds, Radius=40)
#write.csv(Out40km, "E://CloudAgg_40km.csv")

Out5km = ddply(AtlG24hr, .(State, County, Site, Date, X24hrPM), ReadClouds, Radius=5)
write.csv(Out5km, "/aqua/Jess/Data/CloudAgg_Atl5km.csv", row.names=F)

Out10km = ddply(AtlG24hr, .(State, County, Site, Date, X24hrPM), ReadClouds, Radius=10)
write.csv(Out10km, "/aqua/Jess/Data/CloudAgg_Atl10km.csv", row.names=F)

Out20km = ddply(AtlG24hr, .(State, County, Site, Date, X24hrPM), ReadClouds, Radius=20)
write.csv(Out20km, "/aqua/Jess/Data/CloudAgg_Atl20km.csv", row.names=F)

Out30km = ddply(AtlG24hr, .(State, County, Site, Date, X24hrPM), ReadClouds, Radius=30)
write.csv(Out30km, "/aqua/Jess/Data/CloudAgg_Atl30km.csv", row.names=F)

Out40km = ddply(AtlG24hr, .(State, County, Site, Date, X24hrPM), ReadClouds, Radius=40)
write.csv(Out40km, "/aqua/Jess/Data/CloudAgg_Atl40km.csv", row.names=F)
