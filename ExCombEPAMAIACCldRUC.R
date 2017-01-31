## --------------
## Name: ExCombEPAMAIACCldRUC.R
## Program version: R 3.2.3
## Program dependencies:
## Data dependencies:
## Author: J.H. Belle
## Purpose: Examine the 2009-2011 data and start model-building
## --------------

# Read in data
Dat <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24_MAIACCldRUC_10km.csv", stringsAsFactors = F)
Dat$X <- NULL
Dat$Date <- as.Date(Dat$Date, "%Y-%m-%d")
# Lost the monitor values at some point along the way - add back in
EPAdat <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24hr_full.csv", stringsAsFactors = F)[,c("State", "County", "Site", "Date", "X24hrPM")]
EPAdat$Date <- as.Date(EPAdat$Date, "%m/%d/%Y")

G24 <- merge(Dat, EPAdat)
# Add in surface temperatures

#hist(subset(G24$X24hrPM, G24$CloudAOD > 0))

#plot(G24$h_cloudTop, G24$X24hrPM)

G24$h_cloudTop <- ifelse(G24$h_cloudTop <= 0, NA, G24$h_cloudTop)
G24$h_cloudBase <- ifelse(G24$h_cloudBase <= 0, NA, G24$h_cloudBase)

# Convert Cloud AOD to 0 if missing - assuming no clouds
G24$CloudAOD <- ifelse(is.na(G24$CloudAOD), 0, G24$CloudAOD)

# Test a linear model
#GSMod <- lm(X24hrPM ~ CloudAOD + hpbl_surface + cape_surface + sd_surface, G24)
#summary(GSMod)
# Ehh - not great

#plot(G24$AOD55, G24$CloudAOD)

#nrow(subset(G24, G24$AOD55 > 1))
# Remove regular AOD values greater than 5
G24$AOD47 <- ifelse(G24$AOD47 > 5, NA, G24$AOD47)
G24$AOD55 <- ifelse(G24$AOD55 > 5, NA, G24$AOD55)

# Tabulate disagreement between MAIAC and cloud product
cor(G24$Cloud, G24$PAnyCld, use="complete.obs") #0.82correlation

# Tabulate disagreement between MAIAC and RUC
G24$RUCcld <- ifelse(is.na(G24$h_cloudBase) | is.na(G24$h_cloudTop), 0, 1)
cor(G24$RUCcld, G24$Cloud, use="complete.obs")
cor(G24$RUCcld, G24$PAnyCld, use="complete.obs")

# Plot histograms of PM2.5 with varying amounts of cloud - according to MAIAC
#library(ggplot2)
#ggplot(G24, aes(X24hrPM)) + geom_histogram() + facet_grid(RUCcld~.)

# Make MAIAC cloud, glint, and clear into categorical variable
#G24$CldGltClr <- ifelse(G24$Glint > G24$Cloud & G24$Glint > G24$Clear, "Glinty", ifelse(G24$Cloud > G24$Glint & G24$Cloud > G24$Clear, "Cloudy", "Clear"))

#ggplot(G24, aes(X24hrPM)) + geom_histogram(bins=50) + facet_grid(CldGltClr~.)

# Test mixture modeling
#library(mixtools)
#test <- regmixEM(G24$X24hrPM, G24$CloudAOD, addintercept = T)
#test2 <- regmixEM(G24$X24hrPM, G24$Glint, addintercept = T)
#summary(test)
#summary(test2)
#test3 <- regmixEM(G24$X24hrPM, as.matrix(G24[,c("CloudAOD", "Glint")]))
#summary(test3)

# Can't have missing values or don't get convergence on Mix model
G24$PCloudAOD <- ifelse(is.na(G24$PCloudAOD), 0, G24$PCloudAOD)
#G24$h_cloudTop <- ifelse(is.na(G24$h_cloudTop), 0, G24$h_cloudTop)
#G24$h_cloudBase <- ifelse(is.na(G24$h_cloudBase), 0, G24$h_cloudBase)
#G24$CloudTopHgt <- ifelse(is.na(G24$CloudTopHgt, 0, G24$CloudTopHgt))
G24$PAnyCld <- ifelse(is.na(G24$PAnyCld), 0, G24$PAnyCld)
G24$PSingleCld <- ifelse(is.na(G24$PSingleCld), 0, G24$PSingleCld)
G24$PMultiCld <- ifelse(is.na(G24$PMultiCld), 0, G24$PMultiCld)
#G24_NoMiss <- G24[which(complete.cases(G24[,c(1:6,9:46)])),]
#G24_NoMiss$X24hrPM <- ifelse(G24_NoMiss$X24hrPM <= 0, 0.01, G24_NoMiss$X24hrPM)
#G24_NoMiss$LogX24hrPM <- log(G24_NoMiss$X24hrPM)

#test4 <- regmixEM(G24_NoMiss$X24hrPM, G24_NoMiss$cape_surface)
#summary(test4)
#test5 <- regmixEM(G24_NoMiss$LogX24hrPM, as.matrix(G24_NoMiss[,c("cape_surface", "CloudTopHgt", "CloudAOD", "PAnyCld", "Glint", "hpbl_surface", "r_heightAboveGround")]), k=5)
#summary(test5)

# Add in surface temperature
Temps <- read.csv("T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifTemps.csv", stringsAsFactors = F)[,c(1:3,8,10)]
Temps$Date <- as.Date(Temps$Date, "%Y-%m-%d")
Temps <- aggregate(Temperature ~ State + County + Site + Date, Temps, median)
G24 <- merge(G24, Temps)
# ---------
# Manual classification
# ---------

# Classify observations into clear, glint, high cloud, medium cloud, low cloud, and thundercloud using MAIAC and RUC
G24$Month <- as.integer(as.character(G24$Date, "%m"))
G24$Season <- ifelse(G24$Month == 3 | G24$Month == 4 | G24$Month == 5, "Spring", ifelse(G24$Month == 6 | G24$Month == 7 | G24$Month == 8, "Summer", ifelse(G24$Month == 9 | G24$Month == 10 | G24$Month == 11, "Fall", "Winter")))
G24$X24hrPM <- ifelse(G24$X24hrPM <= 0, 0.01, G24$X24hrPM)
G24$LogPM <- log(G24$X24hrPM)
# Subset data
Glinty <- subset(G24, G24$Glint > 0)
G24$CloudSize <- G24$h_cloudTop - G24$h_cloudBase

LowClds <- subset(G24, G24$h_cloudTop < 5000)
MedClds <- subset(G24, G24$h_cloudBase > 4000 & G24$h_cloudBase < 8000 & G24$CloudSize < 6000)
HighClds <- subset(G24, G24$h_cloudBase > 8000)
LargeClds <- subset(G24, G24$CloudSize > 6000)
# Run models on each subset
# Clear - RH; Season/Temp; PBL height, CAPE/CIN; AOD
# Glint - RH; Season/Temp; PBL height; CAPE/CIN;
summary(lm(LogPM ~ Temperature + cin_surface + r_heightAboveGround + hpbl_surface + Season, Glinty))
# High clouds - RH; Season/Temp; PBL height; CAPE/CIN; Cloud AOD; Cloud top height
summary(lm(LogPM ~ Temperature + cape_surface + r_heightAboveGround + hpbl_surface + Season + CloudAOD + prate_surface, HighClds))
# Medium clouds - RH; Season/Temp; PBL height; CAPE/CIN; Cloud AOD; prate; Cloud top height
summary(lm(LogPM ~ Temperature + cape_surface + r_heightAboveGround + hpbl_surface + Season + CloudAOD + prate_surface, MedClds))
# Low clouds - RH; Season/Temp; PBL height; CAPE/CIN; Cloud AOD; prate; Cloud top height
summary(lm(LogPM ~ Temperature + cape_surface + r_heightAboveGround + hpbl_surface + Season + CloudAOD + prate_surface, LowClds))
# Thunderclouds - RH; Season/Temp; PBL height; CAPE/CIN; Cloud AOD;l prate; Cloud top height
summary(lm(LogPM ~ Temperature + cape_surface + r_heightAboveGround + hpbl_surface + Season + CloudAOD + prate_surface, LargeClds))


# Redoing classification of cloudy observations using cloud product definitions
Cloudy <- subset(G24, G24$CloudAOD > 0)
Cloudy$CloudType <- ifelse(Cloudy$CloudTopHgt == 0, "Maybe",  ifelse(Cloudy$CloudTopHgt < 5000, "Low", ifelse(Cloudy$CloudTopHgt < 12000, "Medium", "High")))
summary(lm(LogPM ~ Temperature + cape_surface + r_heightAboveGround + hpbl_surface + Season + CloudAOD + prate_surface + CloudTopHgt, Cloudy))
# ---------
# Mixture modeling - round 2
# ---------

# Test Gamma dist'n
# Test conditioning on manual classifications

