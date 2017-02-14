## ----------------
## Functions_EPA_Proc.R
## ----------------

# --------
# Function 1: SortSite - A function to create a list of observations within a study site area
#   NOTE: Study site defined using a vector of coordinates: c(Longitude west/left side, Longitude east/right side, latitude south/bottom side, latitude north/top side)
#   NOTE: Coordinates are assumed to be in the same datum and (optionally) projection as the siteDef coordinates
# --------

SiteSort <- function(dat, siteDef, datLatField="Latitude", datLonField="Longitude"){
  # dat is assumed to be a dataframe, siteDef a vector of coordinates, and datLatField/datLonField are each strings with the field names in dat that correspond to lat/long
  Outp <- subset(dat, dat[datLonField] <= siteDef[2] & dat[datLonField] >= siteDef[1] & dat[datLatField] <= siteDef[4] & dat[datLatField] >= siteDef[3])
  return(Outp)
}


# --------
# Function 2: SiteMappingSummary - A function to calculate statistics needed for mapping/tables of EPA sites in each study area
# --------

SiteMappingSummary <- function(dat, FieldPM, Fieldmethod, FieldDate){
  # Function is intended for use with plyr and takes as input a data frame. Output consists of a data frame with a record for each the grouping and data for mean pm, seasonal mean pm, number of observations, number of days with records, date range and method mode.
  require("modeest")
  Month = as.integer(format(as.Date(dat[,FieldDate], "%Y-%m-%d"), "%m"))
  Season = ifelse(Month==1|Month==2|Month==12, "Winter", ifelse(Month==3|Month==4|Month==5, "Spring", ifelse(Month==6|Month==7|Month==8, "Summer", "Fall")))
  DateDate = as.Date(dat[,FieldDate], "%Y-%m-%d")
  SeasonMeans <- aggregate(dat[,FieldPM], by=list(Season), mean)
  Outp <- cbind.data.frame(mean(dat[,FieldPM]), t(SeasonMeans$x), length(!is.na(dat[,FieldPM])), length(unique(dat[,FieldDate])), min(DateDate), max(DateDate), mfv(dat[,Fieldmethod]))
  colnames(Outp) <- c("MeanPM", t(SeasonMeans[,1]), "NRecs", "NDays", "FirstDateData", "LastDateData", "MethodMode")
  return(Outp)
}

# --------
# Function 4: Comp1hr24hr - A function to  run through the analysis comparing the 1 hr and 24 hr observations - produces plots, prints tables, etc.
# --------

Comp1hr24hr <- function(Atl1, Atl24){
  # Summarize 24 hr data
  Summary24 <- ddply(Atl24, .(State, County, Site, POC, Latitude, Longitude, Datum), SiteMappingSummary, FieldPM="X24hrPM", Fieldmethod="MethodCode", FieldDate="Date")
  # Plot 24 hr data by month and year
  Atl24$Month <- as.integer(format(as.Date(Atl24$Date, "%Y-%m-%d"), "%m"))
  plot(aggregate(X24hrPM ~ Atl24$Month, Atl24, mean), main="Monthly mean PM values from 24 hr averages")
  plot(aggregate(X24hrPM ~ Atl24$Month, Atl24, length), main="MOnthly number of PM values from 24 hr averages")
  Atl24$Year <- as.integer(format(as.Date(Atl24$Date, "%Y-%m-%d"), "%Y"))
  plot(aggregate(X24hrPM ~ Atl24$Year, Atl24, length), main="Number of yearly PM values from 24 hour averages")
  plot(aggregate(X24hrPM ~ Atl24$Year, Atl24, mean), main="Yearly mean PM values from 24 hour averages")
  # Summarize 1 hr data
  Summary1 <- ddply(Atl1, .(State, County, Site, POC, Latitude, Longitude, Datum), SiteMappingSummary, FieldPM="X1hrPM", Fieldmethod="MethodCode", FieldDate="Date")
  # Plot hourly concentrations
  plot(aggregate(X1hrPM ~ as.integer(substr(Time, 1,2)), Atl1, median), main="Median hourly PM values")
  plot(aggregate(X1hrPM ~ as.integer(substr(Time, 1,2)), Atl1, mean), main="Mean hourly PM values")
  plot(aggregate(X1hrPM ~ as.integer(substr(Time, 1,2)), Atl1, max), main="Max hourly PM values")
  plot(aggregate(X1hrPM ~ as.integer(substr(Time, 1,2)), Atl1, min), main="Min hourly PM values")
  plot(aggregate(X1hrPM ~ as.integer(substr(Time, 1,2)), Atl1, length), main="Number of hourly PM values")
  # Plot hourly concentrations by season
  Atl1$Month <- as.integer(format(as.Date(Atl1$Date, "%Y-%m-%d"), "%m"))
  plot(aggregate(X1hrPM ~ as.integer(substr(Time, 1,2)), subset(Atl1,  Atl1$Month == 3 | Atl1$Month == 4 | Atl1$Month == 5), mean), main="Mean hourly PM values in Spring")
  plot(aggregate(X1hrPM ~ as.integer(substr(Time, 1,2)), subset(Atl1,  Atl1$Month == 6 | Atl1$Month == 7 | Atl1$Month == 8), mean), main="Mean hourly PM values in Summer")
  plot(aggregate(X1hrPM ~ as.integer(substr(Time, 1,2)), subset(Atl1,  Atl1$Month == 9 | Atl1$Month == 10 | Atl1$Month == 11), mean), main="Mean hourly PM values in Fall")
  plot(aggregate(X1hrPM ~ as.integer(substr(Time, 1,2)), subset(Atl1,  Atl1$Month == 2 | Atl1$Month == 1 | Atl1$Month == 12), mean), main="Mean hourly PM values in Winter")
  plot(aggregate(X1hrPM ~ Atl1$Month, Atl1, length), main = "Number of PM values by month")
  plot(aggregate(X1hrPM ~ Atl1$Month, Atl1, mean), main="PM values by month")
  Atl1$Year <- as.integer(format(as.Date(Atl1$Date, "%Y-%m-%d"), "%Y"))
  plot(aggregate(X1hrPM ~ Atl1$Year, Atl1, mean), main="PM values by year")
  plot(aggregate(X1hrPM ~ Atl1$Year, Atl1, length), main="Number of PM values by year")
  # Create estimate of daily average PM2.5 values to compare with those from 24 hour monitor
  Daily1 <- aggregate(X1hrPM ~ State + County + Site + POC + Latitude + Longitude + Datum + Date, Atl1, mean)
  Daily1length <- aggregate(X1hrPM ~ State + County + Site + POC + Latitude + Longitude + Datum + Date, Atl1, length)
  Daily1 <- merge(Daily1, Daily1length, by=c("State", "County", "Site", "POC", "Latitude", "Longitude", "Datum", "Date"), suffixes = c(".mean", ".nrecs"))
  SummaryDailyVals <- summary(Daily1[,9:10])
  # Match to same POC and compare values
  CompPOCs <- merge(Atl24, Daily1, by=c("State", "County", "Site", "Latitude", "Longitude", "Datum", "Date"))
  CompPOCs$Diffs <- CompPOCs$X24hrPM - CompPOCs$X1hrPM.mean
  CompPOCs$DiffsSq <- CompPOCs$Diffs^2
  SummaryDiffs <- aggregate(Diffs~State + County + Site + POC.x, CompPOCs, summary)
  SummaryAbsDiffs <- aggregate(abs(Diffs)~State + County + Site + POC.x, CompPOCs, summary)
  RMSE <- sqrt(aggregate(DiffsSq ~ State + County + Site + POC.x, CompPOCs, mean))
  return(list(Summary24, Summary1, SummaryDailyVals, SummaryDiffs, SummaryAbsDiffs, RMSE))
}

# --------
# Function 5: POCsort - a function designed to take in blocks of observations. If n=1, use value, if n > 1, use value of interest equal to 1 only
# --------

POCsort <- function(dat, varint="POC"){
  if (nrow(dat) > 1){
    dat <- dat[which.min(dat[,varint]),]
  }
  return(dat)
}

# --------
# Function 6: MassRecon - A function designed to perform mass reconstruction on speciated PM2.5 observations.
# --------

MassRecon <- function(DatSpec, Dat24hr, DatBlanks){
  DatSpec$Date <- as.Date(DatSpec$Date, "%Y-%m-%d")
  DatSpec$X24hrPMSpec <- as.numeric(DatSpec$X24hrPMSpec)
  DatSpecWide <- reshape(DatSpec, timevar="ParameterCode", idvar=c("State", "County", "Site", "Date"), direction= "wide")
  DatSpecWide$Sulfate <- 1.375*DatSpecWide$X24hrPMSpec.88403
  DatSpecWide$Nitrate <- 1.29*DatSpecWide$X24hrPMSpec.88306
  DatSpecWide$Salt <- 1.8*DatSpecWide$X24hrPMSpec.88115
  DatSpecWide$Soil <- 2.2*DatSpecWide$X24hrPMSpec.88104 + 2.49*DatSpecWide$X24hrPMSpec.88165 + 1.63*DatSpecWide$X24hrPMSpec.88111 + 2.42*DatSpecWide$X24hrPMSpec.88126 + 1.94*DatSpecWide$X24hrPMSpec.88161
  DatSpecWide$YrMo <- as.character(as.Date(DatSpecWide$Date, "%Y-%m-%d"), "%m")
  DatSpecWide <- merge(DatSpecWide, DatBlanks, by="YrMo", all.x=T)
  DatSpecWide$BlankCor88370 <- DatSpecWide$X24hrPMSpec.88370 - DatSpecWide$BlankValue.88370
  DatSpecWide$BlankCor88370 <- ifelse(DatSpecWide$BlankCor88370 < 0, 0, DatSpecWide$BlankCor88370)
  DatSpecWide$BlankCor88380 <- DatSpecWide$X24hrPMSpec.88380 - DatSpecWide$BlankValue.88380
  DatSpecWide$BlankCor88380 <- ifelse(DatSpecWide$BlankCor88380 < 0, 0, DatSpecWide$BlankCor88380)
  DatSpecWide$EC <- ifelse(!is.na(DatSpecWide$X24hrPMSpec.88321), DatSpecWide$X24hrPMSpec.88321, ifelse(!is.na(DatSpecWide$BlankCor88380), DatSpecWide$BlankCor88380, 1.3*DatSpecWide$X24hrPMSpec.88307))
  DatSpecWide$OC <- 1.8*(ifelse(!is.na(DatSpecWide$X24hrPMSpec.88320), DatSpecWide$X24hrPMSpec.88320, ifelse(!is.na(DatSpecWide$BlankCor88370), DatSpecWide$BlankCor88370, (DatSpecWide$X24hrPMSpec.88305 + DatSpecWide$X24hrPMSpec.88307 - DatSpecWide$EC - DatSpecWide$BlankValue.Improve)/1.2)))
  DatSpec <- DatSpecWide[,c(2:5,20:23,29,30)]
  rm(DatSpecWide, DatBlanks)
  DatSpec$ReconMass <- DatSpec$Sulfate + DatSpec$Nitrate + DatSpec$Salt + DatSpec$Soil + DatSpec$EC + DatSpec$OC # 3,504 speciated observations, of which 334 were missing data for at least one species
  DatSpec <- merge(Dat24hr[,c(1:3,6:10)], DatSpec[!is.na(DatSpec$ReconMass),], by=c("State", "County", "Site", "Date"), all.y=T) # Only 2,586 could be matched to a gravimetric observation? Remaining gravimetric observations are missing
  DatSpec$Other <- DatSpec$X24hrPM - DatSpec$ReconMass
  Fracs <- DatSpec[,c(9:14,16)]/DatSpec$X24hrPM
  colnames(Fracs) <- c("SulfateFrac", "NitrateFrac", "SaltFrac", "SoilFrac", "ECFrac", "OCFrac", "OtherFrac")
  DatSpec <- cbind.data.frame(DatSpec, Fracs)
  return(DatSpec)
}

# --------
# Function 7: SpecTables - creates summary tables and plots from speciated data
# --------

SpecTables <- function(DatSpec){
  require(ggplot2)
  OverallSumTab = summary(DatSpec)
  Months <- as.integer(as.character(DatSpec$Date, "%m"))
  MonthSumTab = 100*aggregate(DatSpec[8:23], by=list(Months), summary)
  MonthMedianTab = 100*aggregate(DatSpec[8:23], by=list(Months), median)
  SiteSummaryTab = 100*aggregate(DatSpec[8:23], by=list(DatSpec$State, DatSpec$County, DatSpec$Site), summary)
  SiteMedianTab = 100*aggregate(DatSpec[8:23], by=list(DatSpec$State, DatSpec$County, DatSpec$Site), median)
  DatSpec$Loc <- sprintf("%02d-%03d-%02d", DatSpec$State, DatSpec$County, DatSpec$Site)
  PltAll <- ggplot(DatSpec, aes(x=Date)) + geom_line(aes(y=SulfateFrac*100), color="yellow") + geom_line(aes(y=NitrateFrac*100), color="red") + geom_line(aes(y=SoilFrac*100), color="blue") + geom_line(aes(y=OCFrac*100), color="green") + geom_line(aes(y=OtherFrac*100), color="gray50") + facet_grid(Loc~.)
  PltAll_Resr <- ggplot(DatSpec, aes(x=Date)) + geom_line(aes(y=SulfateFrac*100), color="yellow") + geom_line(aes(y=NitrateFrac*100), color="red") + geom_line(aes(y=SoilFrac*100), color="blue") + geom_line(aes(y=OCFrac*100), color="green") + geom_line(aes(y=OtherFrac*100), color="gray50") + ylim(-50,120) + facet_grid(Loc~.)
  PltSmoothMonths <- ggplot(DatSpec, aes(x=as.numeric(as.character(Date, "%m")))) + geom_smooth(aes(y=SulfateFrac*100), color="yellow", se=F) + geom_smooth(aes(y=NitrateFrac*100), color="red", se=F) + geom_smooth(aes(y=SoilFrac*100), color="blue", se=F) + geom_smooth(aes(y=OCFrac*100), color="green", se=F) + geom_smooth(aes(y=OtherFrac*100), color="gray50", se=F) + ylim(0,100) + facet_grid(Loc~.)
  PltSmoothMonthsVals <- ggplot(DatSpec, aes(x=as.numeric(as.character(Date, "%m")))) + geom_smooth(aes(y=Sulfate), color="yellow", se=F) + geom_smooth(aes(y=Nitrate), color="red", se=F) + geom_smooth(aes(y=Soil), color="blue", se=F) + geom_smooth(aes(y=OC), color="green", se=F) + geom_smooth(aes(y=Other), color="gray50", se=F) + facet_grid(Loc~.)
  return(list(OverallSumTab, MonthSumTab, MonthMedianTab, SiteSummaryTab, SiteMedianTab, PltAll, PltAll_Resr, PltSmoothMonthsVals, PltSmoothMonths))
}

# ---------
# Function 8: SiteCharMaps - creates table of sites with a note for whether each site has hourly or speciated data in addition to 24 hour values
# ---------

SiteCharMaps <- function(Dat24, Dat1, DatSpec){
  Mon24 <- aggregate(X24hrPM ~ State + County + Site + Latitude + Longitude + Datum, Dat24, mean)
  Mon1 <- unique(Dat1[,1:3])
  Mon1$HasHourly = 1
  Mon <- merge(Mon24, Mon1, all.x=T)
  Mon$HasHourly <- ifelse(is.na(Mon$HasHourly), 0, Mon$HasHourly)
  MonSpec <- unique(DatSpec[,1:3])
  MonSpec$HasSpec = rep(1, nrow(MonSpec))
  Mon <- merge(Mon, MonSpec, all.x=T)
  Mon$HasSpec <- ifelse(is.na(Mon$HasSpec), 0, Mon$HasSpec)
  return(Mon)
}
