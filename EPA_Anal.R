## -----------------------
## Name: EPA_ANAL.R
## Program version: R 3.2.3
## Dependencies: plyr
## Function file: Functions_EPA_Proc.R
## References:
## Author: J.H. Belle
## Purpose: EPA collocation pre-processing - obtain list of EPA stations located within each study area, and pull data records out for collocations with other data products
##    NOTE: Current study period: 04/01/2007-03/31/2015;
##    NOTE: Processing 24 hour PM, 24 hour Speciated PM, 1 Hr PM, and 1 Hr Speciated separately and including weather data for each observation, if available
## -----------------------

setwd("/home/jhbelle/Aim1Repo/")
# Read in libraries
library(plyr)
source("Functions_EPA_Proc.R")


## -----------------
# Mapping and site analysis - hourly to 24 hr comparisons
## -----------------

# Atlanta - read in Atl datasets
Atl24 <- read.csv("/home/jhbelle/EPAdata/AtlObs24hrFRM.csv", stringsAsFactors = F)
# Remove any duplicated records from Atl24 and rewrite file
Atl24 <- unique(Atl24)
# Read in 1 hour data
Atl1 <- read.csv("/home/jhbelle/EPAdata/AtlObs1hrFRM.csv", stringsAsFactors = F)
Atl1$Date <- as.Date(Atl1$Date, "%Y-%m-%d")
Atl1 <- subset(Atl1, Atl1$Date > as.Date("2007-04-01", "%Y-%m-%d") & Atl1$Date < as.Date("2015-03-31", "%Y-%m-%d"))

Comp1hr24hr(Atl1, Atl24)
# At each site need: seasonal mean PM2.5 value, number of observations of each type, number of unique days with observations of each type, mean absolute square difference between hourly and 24 hour results and between speciated and non-speciated results, date range, method mode
# At each site and POC, calculate overall and seasonal mean PM2.5, number of observations, and number of unique days with observations, method mode, and date range
# A few site/POCs have discrepancy between number of records and number of unique days - multiple records on same day - true duplicates
# Number of monthly records ranges from 2300 to 3000, with the highest numbers over the summer; Average concentrations range from 10.5 to 14, with a peak in June, and the lowest values over the winter
# Values are avaiable over the full time period. Concentrations ranging from 10 to 15.5, and decreasing linearly with time; fewer observations are available over last few years.
# Plot hourly concentrations
# At this site, concentrations tend to be lower during the day and higher at night - visible on both mean and median, clearer on median; concentration values range from 11.5 - 13 micrograms/m^3; Maximum hourly concentrations are ~40-80 micrograms/m^3, little diurnal variation; Highest numbers of obserations, by hour are over night, more observations are missing during day - 10 am is lowest; Minimum values are negative 2-5 - MDL = 5, negative values allowed? Number of obserations at each hour are ~1500
# Plot hourly concentrations by season
# Seasonal diurnal patterns differ substantially in Atlanta; In spring, mean concentrations range from 9.5 to 12 and peak around midnight, with lows midmorning; In summer, mean concentrations range from 11.5 to 14, peak in the afternoon, and are lowest in early morning; In fall, mean concentrations range from 12.5 to 15, with peaks around midnight, and lows in midmorning or late afternoon; In winter, concentrations range from 10 to 13 with a peak slightly after midnight, and lows in late afternoon.
# Plot monthly concentrations
#Monthly concentration averages range from 11-14, are lowest in April, and highest in november; Months have between 2400 and 3600 records a piece, with the lowest in November and the highest in March, but no clear pattern, other than fewer observations months 9-12.
# Data exists for years 2011-2015; concentrations are highest in 2012 (13.5), but generally decrease linearly from 12.5 to 11.5 over time period.
ggplot(Atl24, aes(x=as.Date(Atl24$Date, "%Y-%m-%d"), y=X24hrPM)) + stat_summary(geom="line", fun.y="median") + ylab(expression("24 hour " * PM[2.5] * " (" * mu * "g" * "/" * m^3 * ")" )) + xlab("Date") + ggtitle(expression("Atlanta " * PM[2.5] * " Measurements")) + theme_classic()
Atl1$Timeday <- as.integer(substr(Atl1$Time, 1, 2))
ggplot(subset(Atl1, substr(Atl1$Date, 1, 7)=="2011-10"), aes(y=X1hrPM, x=Timeday)) + stat_summary(geom="line", fun.y="median") + ylim(0,13) + ylab(expression("1 hour " * PM[2.5] * " (" * mu * "g" * "/" * m^3 * ")" )) + xlab("Hour of day") + ggtitle(expression("Average" * PM[2.5] * " Diurnal pattern in Atlanta, October 2011")) + theme_classic()

Atl24$Year <- as.numeric(substr(Atl24$Date, 1, 4))
aggregate(X24hrPM ~ Year, Atl24, mean)
Atl24$Month <- as.numeric(substr(Atl24$Date, 6, 7))
aggregate(X24hrPM ~ Month, Atl24, mean)
aggregate(X1hrPM ~ Time, Atl1, mean)

# Create estimate of daily average PM2.5 values to compare with those from 24 hour monitor
# Match to same POC and compare values
# Absolute differences in daily averages average 0.06017, with a median of 0.04783, and a max of 22.79
# RMSE = 0.5814
# Match to other POC at same site and compare values
# Absolute differences in daily averages average 3.097, with a median of 2.618, and a max of 14.9; Differences average -2.3 (1hr PM 24 hour means higher)
# RMSE = 3.8944
# POC2
# Absolute differences in daily averages average 3.12, with a median of 2.414 and a max of 21.52; Mean difference is -1.705 (1 hour means larger)
# RMSE = 13.6340

# California - read in datasets
Calif24 <- read.csv("/home/jhbelle/EPAdata/CalifObs24hrFRM.csv", stringsAsFactors = F)
# Remove any duplicated records and rewrite file
Calif24 <- unique(Calif24)
# Read in 1 hour data
Calif1 <- read.csv("/home/jhbelle/EPAdata/CalifObs1hrFRM.csv", stringsAsFactors = F)
Calif1$Date <- as.Date(Calif1$Date, "%Y-%m-%d")
Calif1 <- subset(Calif1, Calif1$Date > as.Date("2007-04-01", "%Y-%m-%d") & Calif1$Date < as.Date("2015-03-31", "%Y-%m-%d"))

# Run comparisons
Comp1hr24hr(Calif1, Calif24)
# 24 hr summary: 117 24 hr monitors, with average values between 6 and 35 micrograms/m^3; Seasonal variability ranges from site to site, with lows in spring/summer; Many missing methods codes; Number of recorded observations per site ranges from 2 to 2813, with most having a few hundred, but many with over 1000.
# 24 hr plots: Average PM values range from 7 to 18 over months of the year, with the lowest averages in April, and the highest in January; Results above suggest this may be driven by a few sites; Number of records shows little to no clear pattern by month, with lowest number of records in fall; Number of records increases by year from around 5000 to 20,000 by 2014; Average PM values decrease with year, from ~13 to ~9.
# 1 hr summary: 56 1 hr monitors, with average values betweeen 5 and 35 micrograms/m^3; Seasonal variability shows lows in spring and summer (more spring) and highs in winter; Number of days with records ranges from 31 to 2,415; Date ranges tended to start at later dates than the 24hr monitors; Mostly Beta attenuation methods used, but one monitor uses 184 (also beta attenuation, but a different model)
# Overall 1 hr summary: 1 hr values range ffrom -5 to 207, with a mean of 9.9, a median of 7.7, and most sites and days having 24 hours of data included in the average.
# Overall hourly plots: twice-daily peak in concentrations - 1st at 10 am, 2nd at 8 pm, low at 4 am; Median values range from 6 to 8. Similar pattern seen in means, with concentrations higher (8.5 to 11), lows at 4-5 am and 3-4 pm, second peak higher than first in day. Max values are 200-800, no clear pattern with time of day. Min values are all -10 (limit of detection). Number of records per hour ranges from 72,400 to 73,600, with low around 10 am.
# Seasonal hourly plots: Spring - peak at 10 am (8), low at 4 am (6), nighttime peak much less (7.5); Summer - peak at 10 am (9), low at 4 am (7), second daily peak very minor; Fall - clear twice daily peak (12), with overall minimum at 4 am (9), and second minimum at 4 pm (9.5); Winter - clear twice-daily minimums (5 am and 3 pm), with overall maximum at 9 pm (18) and small max (14) at 10 am.
# Plot - values by month and year: Number of records by month shows little clear pattern, but Oct, Feb, and Nov are lower than rest; Mean PM values peak in January (17), witha minimum in March (7), only Nov, Dec and Jan are over 10; Mean PM values decrease with year from 15 in 2008 to 9 in 2015; Number of records increases with year.

# Recheck Comparisons to 24 hr values - no scientific notation - hard to interpret
# Many differences are fairly small (~0.05) other are 1-3 micrograms/m^3 with beta methods having higher mean pm; RMSEs from 0.05 to over 6. Presumably small differences are only observed when 24 hour values is beta attenuation based - need to be able to check this


# Midwest - read in datasets
Mdwst24 <- read.csv("/home/jhbelle/EPAdata/MdwstObs24hrFRM.csv", stringsAsFactors = F)
# Remove any duplicated records and rewrite file
Mdwst24 <- unique(Mdwst24)
# Read in 1 hour data
Mdwst1 <- read.csv("/home/jhbelle/EPAdata/MdwstObs1hrFRM.csv", stringsAsFactors = F)
Mdwst1$Date <- as.Date(Mdwst1$Date, "%Y-%m-%d")
Mdwst1 <- subset(Mdwst1, Mdwst1$Date > as.Date("2007-04-01", "%Y-%m-%d") & Mdwst1$Date < as.Date("2015-03-31", "%Y-%m-%d"))
# Run comparisons
Comp1hr24hr(Mdwst1, Mdwst24)
# No hourly observations in Midwest - may need to redefine study area - Moved to Indiana
# 24 hour plots - Iowa/Illinois - averages range from 8 to 14 from month to month, with the highest concentrations in winter, and the lowest in october, number of observations relatively stable across months with 2,100 to 2,400 observations per month, mean values decrease with year.
# 24hour table - Indiana: 44 24 hour monitors in study area with mean values from 9 to 13, and multiple methods of collection (145=gravimetric, 181=TOEM, 118=gravimetric, NA, 170=Beta attenuation, 184=Beta attenuation); Range of start dates, many in 2007; number of days per monitor ranges from 51 to 3,021; Lows are typically seen in the fall and spring, with highs in the winter or summer, depending on station; Many of these averages are far higher than at other sites
# 1hr table - Indiana: 15 hourly monitors, start dates range from 2009 to 2013; Number of days ranges from a few hundred to thousands ,with up to ~50,000 records; values are comparable to 24 hour monitors, but with more summer highs;  Mixure of beta attenuation and TEOM methods
# 24 hour plots: Little clear pattern on monthly mean PM values, lows in april and october (<10), highs in february, july, and december (>13), other months in the middle; number of values by month ranges from 3,100 to 3,600 with no clear pattern, but octover is missing most; number of values increases with year, lowest in 2008 (3000), highest in 2014(6000); Concentrations decrease with year from above 14 to below 11
# Overall hourly summary table: mean PM values range from -3.8 to 113.55, with a mean of 11,7 and a median of 10.6; the number of records per day are primarily 24
# Hourly plots: Median hourly pm values ranged from 9 to 11 with a peak at 7-8 am, and a second at 9-12 pm and a daily low at 4 pm; Mean values show identical pattern, but values range from 10.5 to 12.5; maximum values range from 80 to 400, with peaks from 10pm to 1 am; Minimum values are all negative with no clear pattern; Number of values by hour is lowest at 10 am (18,600) and over 19,000 from 5pm to 6 am
# Seasonal hourly plots: In spring, hourly values range from 9.5 to 11.5, with peaks at 7 am and 8-9 pm and a minimum at 5 pm; In summer, concentrations peak at 10 pm (14) and hit a daily minimum from 3-6pm (11.5), with a small peaks (13) at 7 am; In fall, concentrations peak at 8 am and 8 pm (12) with a daily minimum at 4 pm (9); In winter nighttime concentrations (13) are lower relative to early morning (14), with the daily minimum at 4pm (11)
# Hourly plots: concentrations by month shows no clear trend, with concentrations ranging from 9.5 to 13.5, lows in april and octover, and highs in february, july, and december; number of pm values by month ranges from 34,000 to 42,000 with the fewest in october, september, and november; concentrations decrease with year and the number of values increases
# Difference tables: mean differences are typically negative, and tend to be higher when comparing hourly measurements to 24hour gravimetric (1-2.5 versus 0.05) ones; RMSEs follow same pattern, with values from 0.05 to 2 for same type comparisons, and 1.8 to 6.5 for two type comparisons

# Colorado - read in datasets
Colorado24 <- read.csv("/home/jhbelle/EPAdata/ColoradoObs24hrFRM.csv", stringsAsFactors = F)
# Remove any duplicated records and rewrite file
Colorado24 <- unique(Colorado24)
# Read in 1 hour data
Colorado1 <- read.csv("/home/jhbelle/EPAdata/ColoradoObs1hrFRM.csv", stringsAsFactors = F)
Colorado1$Date <- as.Date(Colorado1$Date, "%Y-%m-%d")
Colorado1 <- subset(Colorado1, Colorado1$Date > as.Date("2007-04-01", "%Y-%m-%d") & Colorado1$Date < as.Date("2015-03-31", "%Y-%m-%d"))
# Run comparisons
Comp1hr24hr(Colorado1, Colorado24)
# 24 hour summary - 24 monitors. Mean values range from 3.5 to 10, with the lowest values in the spring, and the highest in winter - although a few stations show the reverse pattern, with the lowest values in winter and the highest in summer;
# 24 hour plots - Months with highest values - Feb and Dec (9); Lowest in April and May (6), and remaining observation 7-8 micrograms/m^3; Number of obserations per month ranged from 1,350 to 1,650 - lowest in Feb and Dec; Typical years had ~2000 observations, 2014 had most; No obvious trand in concentrations values from year to year - except 2007 was ~9, while remaining years ~7.5.
# 1 hour summary - 5 sites taking hourly measurements, although earliest date is 2013, and 3 didn't open until 2015; Most used method code 195 - Laser light scattering; 3/5 stations had no data for at least 1 season; At two monitors with full year coverage, lows were observed in fall and spring, slight elevations in summer, and highs in winter;
# Overall 1 hr summary: Mean 24hr values from hourly monitors ranged from 1.3 to 75, with a mean of 8.7 and a median of 7; Majority of days had 24 hours of observations
# Overall hourly plots: peak median concentrations at ~7 am (8.5), lowest at 4 pm (5), with nighttime concentrations in the middle - small peak at 8 pm; mean hourly concentrations very similar to medians, but with slightly higher values - ranging from 7 to 10.5; Max values actually showed same diurnal patterns and were in range from 65 to 95; minimum values only go down to 0.1 - no negatives, but all are less than 1; number of PM values by hour ranges from 1,910 to 1,940 with the fewest number from 8am to noon
# Seasonal hourly plots: In spring, mean hourly concentrations range from 6.5 to 10, with a peak around 7 am, and a minimum at 5 pm, although outside of morning peak, concentrations were typically below 8; In summer, mean hourly concentrations ranged from 6.5 to 11; with a peak at 6 am and a minimum at 5 pm, although nightime concentrations were generally higher than in spring, increasing gradually from 5 pm to 7 am, with a slight peak around midnight; Fall concentrations ranged from 6.5 to 10; with a peak at 7 am, a minimum at 4 pm, and a second peak at 8 pm; In winter, concentrations ranged from 10 to 13, with a peak at 8 am (13.2), a second peak at 8 pm (13), and a minimum at 4 am.
# Other plots: Large variability in numbers of observations by month - results from issues with late start dates of hourly monitors relative to study period; Monthly values peaked in dec and feb; PM values decreased with year, but only from 8.9 to 8.5; number of values per year increased from 2013 to 2015, from <10,000 to over 20,000.
# Comparisons to 24-hour values: Differences with gravimetric monitors were smaller than with the beta-attenuation monitors, and some medians were positive, although absolute differnce magnitudes were generally larger; RMSEs were similar to previous - ~2


## -----------------
# Mapping and site analysis - 24 hr speciated to not comparisons
## -----------------

# Atlanta - read in Atl datasets
Atl24 <- read.csv("/home/jhbelle/EPAdata/AtlObs24hrFRM.csv", stringsAsFactors = F)
# Remove any duplicated records from Atl24 and rewrite file
Atl24 <- unique(Atl24)
# Need to handle cases with multiple monitors at a single site
# Remove the observations from the beta attenuation monitor - known to be biased high - just removing all POC=3 observations since the only one in the speciated dataset with that value is the one we don't want
#Atl24 <- subset(Atl24, Atl24$POC != 3)
# Need one value per station per day - use POC 1 preferentially; POC 2 if POC 1 is absent
Atl24 <- ddply(Atl24, .(State, County, Site, Date), POCsort)
Atl24$Date <- as.Date(Atl24$Date, "%Y-%m-%d")
Atl24 <- subset(Atl24, Atl24$Date > as.Date("2007-04-01", "%Y-%m-%d") & Atl24$Date < as.Date("2015-03-31", "%Y-%m-%d"))
# Read in speciated data from CSN
AtlSpec24 <- read.csv("/home/jhbelle/EPAdata/AtlObs24hrFRMSpec.csv", stringsAsFactors = F)
# Read in blank values for EC/OC correction
AtlBlanks <- read.csv("/home/jhbelle/EPAdata/AtlObs24hrFRMBlanks.csv", stringsAsFactors = F)
AtlBlanks$Date2 <- as.character(as.Date(AtlBlanks$Date, "%Y-%m-%d"), "%m")
# Calculate monthly/year average blank values associated with 88370 and 88380 observations - where average is taken across study area
MonthBlanks <- aggregate(AtlBlanks$BlankValue, by=list(AtlBlanks$Date2, AtlBlanks$ParameterCode), mean, na.rm=T)
colnames(MonthBlanks) <- c("YrMo", "ParameterCode", "BlankValue")
MonthBlanks <- reshape(MonthBlanks, timevar="ParameterCode", idvar="YrMo", direction = "wide")
MonthBlanks$BlankValue.Improve <- c(1.1, 1.3, 1.2, 1.4, 1.6, 1.7, 1.8, 1.9, 1.5, 1.2, 1.0, 1.1)
rm(AtlBlanks)
# Calculate mass fractions - parameter names: Sulfate=1.375*88403, Nitrate=1.29*88306, OC=1.8*(88320 | (88370 - blank) | ((88305 + 88307) - 1.3*(88307) - a_i)/1.2), Crustal=2.2*88104 + 2.49*88165 + 1.63*88111 + 2.42*88126 + 1.94*88161, Salt=1.8*88115, EC=1.3*(88307) | 88321 | (88380 - blank_88380), Other=Remaining fraction (may be negative)
# Subset EPA data to only include parameters of interest
AtlSpec24 <- subset(AtlSpec24, AtlSpec24$ParameterCode %in% c(88403, 88306, 88320, 88370, 88305, 88307, 88104, 88165, 88111, 88126, 88161, 88115, 88321, 88380))[,c(1:4,10,11)]
AtlSpec <- MassRecon(AtlSpec24, Atl24, MonthBlanks)
SpecTables(AtlSpec)
## Plot 1 - mass fractions (daily), no axis restrictions: There are a few days with outlandishly large/negative othe fractions and large/negative OM fractions. These are observations where the gravimetric mass is far smaller than the reconstructed mass. 3 worst are from same station. Should consider eliminating the worst of these observations at a minimum.
## Table 1 - mass and mass fraction summary: Dates range from 01/03/2007 - 08/10/2015; 24hour pm has a median of 10.7, and a mean of 11.94; sulfate has a mean mass of 3.4 and a median of 2.8; Nitrate has a mean mass of 0.7 and a median of 0.5; Salt has a mean mass of 0.03 (median 0.01); Soil has a mean of 0.7, median 0.4; EC has a mean mass of 0.8, median 0.6; OC has a mean mass of 5.1, median 4.4 - PM in atlanta is predominantly OC and sulfate, with very little salt and moderate amounts of soil, nitrate, and EC; Reconstructed masses were 10.7, median 9.5, slightly lower than the gravimetric masses. Other fractions ranged from -12 to 47 micrograms/m^3, with a mean of 1.21, and a median of 1; Sulfate fractions were around 30%, nitrate 5%, salt < 1%, soil 5%, ec 6%, OC 40%, and other 9%; Estimates for the other fraction were consistent with previous studies, with most values being putting the reconstructed mass within +/-20% of gravimetric values.
## Plot 2 - mass fractions (daily), y axis restricted: Lot of day-to-day variability in these values; soil fraction occasionally shoots up, often countered by negative other fractions - possible contamination with PM10?; See a number of days where nitrates spike; sulfate and OM fractions are relatively consistent, but with a lot of what looks like random variability; Occasionally have more sulfates than OM
## Table 2 - summary mass and mass fractions by month: There are a lot more negative other fractions in the winter months and mean values increase from around 0% to 17% in august - expected these results; There are maximum OC and sulfate fractions greater than 100% of gravimetric value
## Table 3 - median masses and mass fractions by month of year: sulfate masses range from 1.97 in january to 3.66 in june, with summer generally higher than winter values; Sulfate fr4actions also follow same pattern, but with less variability since 24hour masses also decrease in winter and increase in summer; sulfate mass fractions range from 23% in january to 31% in september; Nitrate masses follow the opposite pattern, with masses peaking in winter months at 1 in february, while masses are lowest in august and september at 0.3; Nitrate fractions are highest in january (11%) and lowest summer (2-3%); Salt masses are small, but seem to be highest in spring and late fall/early winter, but are still only 0.01 micrograms/m^3; salt fractions are highest in winter and spring, going just over 1%; Soil masses are highest in summer (july 0.8) and lowest in winter (december (0.2)); soil fractions range from 2.5% to 6.6% and peak in summer; EC values range from 0.45 to 0.92 and are lowest in summer (july) and highest in fall/winter (november); EC fractions follow the same pattern, ranging from 4-8.4%; OC values range from 5.6 (november) to 3.7 (september) and don't really follow a clear pattern; OC fractions range from 35% to 51% and are generally lower in the summer and higher in winter and fall; Other masses range from 0.01 (january) to 2.2 (june and august) and are generally higher in the summer and lower in the winter; Other fractions correspondingly are higher in the summer (19%) and lower in the winter (< 1%); 24 hour values range from ~9 in december and january to 12.5 in august, while reconstructed masses range from 10.8 (june) to 1.4 (september)
## Plot 3 - masses by month (smoothed), by station: Stations show different patterns, but are generally alike; OC decreases in later summer and is highest in spring; sulfate increases in the summer; other/water increases in the summer; nitrated decrease in summer, and soil increase in early summer. Typically, OC is highest, followed by sulfate, although in summer at a few stations, sulfate dominates
## Plot 4 - fractions by month and station (smoothed): mass fractions follow patterns: OC decreases in summer; sulfate remains fairly stable, but is lower in summer; soil and other fractions increase in the summer, with soil peaking earlier than other; nitrate fraction decreases in summer
## Table 4 - summary of variables by station: station 13 89 2 has the most extreme other/oc/sulfate fraction values; A few EC and OC masses are negative, likely a result of blank corrections - should go back and make these 0; The downtown atlanta station has consistently higher Other fractions than the other sites (median 14, other medians 6-9)- while these are consistently more positive than at other stations, this one also has smallest negative other fraction.
## Table 5 - median values for variables by station: One station has higher concentrations and masses of constiutuents, except for lower soil and EC masses - this station also had shorter time series, only running over 2008; Otherwise, differences exist, but nothing alluding to a particular problem
length(unique(AtlSpec$Date)) # There are 898 distinct days with speciated data
length(unique(Atl24$Date)) # There are 3,163 distinct days with gravimetric observations
# 5 stations running speciated observations at any particular day

# Colorado - read in Colorado datasets
Col24 <- read.csv("/home/jhbelle/EPAdata/ColoradoObs24hrFRM.csv", stringsAsFactors = F)
# Remove any duplicated records from Col24 and rewrite file
Col24 <- unique(Col24)
# Need to handle cases with multiple monitors at a single site
# Remove the observations from the beta attenuation monitors - known to be biased high - All are POC=3 observations
Col24 <- subset(Col24, Col24$POC != 3)
# Need one value per station per day - use POC 1 preferentially; POC 2 if POC 1 is absent
Col24 <- ddply(Col24, .(State, County, Site, Date), POCsort)
Col24$Date <- as.Date(Col24$Date, "%Y-%m-%d")
Col24 <- subset(Col24, Col24$Date > as.Date("2007-04-01", "%Y-%m-%d") & Col24$Date < as.Date("2015-03-31", "%Y-%m-%d"))
# Read in speciated data from CSN
ColSpec24 <- read.csv("/home/jhbelle/EPAdata/ColoradoObs24hrFRMSpec.csv", stringsAsFactors = F)
# Read in blank values for EC/OC correction
ColBlanks <- read.csv("/home/jhbelle/EPAdata/ColoradoObs24hrFRMBlanks.csv", stringsAsFactors = F)
ColBlanks$Date2 <- as.character(as.Date(ColBlanks$Date, "%Y-%m-%d"), "%m")
# Calculate monthly/year average blank values associated with 88370 and 88380 observations - where average is taken across study area
MonthBlanks <- aggregate(ColBlanks$BlankValue, by=list(ColBlanks$Date2, ColBlanks$ParameterCode), mean, na.rm=T)
colnames(MonthBlanks) <- c("YrMo", "ParameterCode", "BlankValue")
MonthBlanks <- reshape(MonthBlanks, timevar="ParameterCode", idvar="YrMo", direction = "wide")
MonthBlanks$BlankValue.Improve <- c(1.1, 1.3, 1.2, 1.4, 1.6, 1.7, 1.8, 1.9, 1.5, 1.2, 1.0, 1.1)
rm(ColBlanks)
# Calculate mass fractions - parameter names: Sulfate=1.375*88403, Nitrate=1.29*88306, OC=1.8*(88320 | (88370 - blank) | ((88305 + 88307) - 1.3*(88307) - a_i)/1.2), Crustal=2.2*88104 + 2.49*88165 + 1.63*88111 + 2.42*88126 + 1.94*88161, Salt=1.8*88115, EC=1.3*(88307) | 88321 | (88380 - blank_88380), Other=Remaining fraction (may be negative)
# Subset EPA data to only include parameters of interest
ColSpec24 <- subset(ColSpec24, ColSpec24$ParameterCode %in% c(88403, 88306, 88320, 88370, 88305, 88307, 88104, 88165, 88111, 88126, 88161, 88115, 88321, 88380))[,c(1:4,10,11)]
ColSpec <- MassRecon(ColSpec24, Col24, MonthBlanks)
SpecTables(ColSpec)
# At most have 3 stations running speciated results at a given point in time, only 2 prior to 2010
length(unique(ColSpec$Date)) # 856 unique days with speciated observations
length(unique(Col24$Date)) # 3,103 unique days with gravimetric observations
## Plot 1 - mass fractions (daily), no axis restrictions: Again, a few observations have other and/or OM and/or soil fractions greater than +/- 100% of the gravimetric value
## Table 1 - mass and mass fraction summary: Dates range from 01/03/2007 to 2015/08/10; 24 hour values range from 0.6 to 51, with a mean of 8.04 and a median of 6.8; Reconstructed masses range from 1.02 to 45, with a mean of 8.2 and a median of 7; Sulfate masses had a mean of 1.11 and median of 0.93; sulfate fractions ranged from 0 to 62% with a mean of 15.4% and a median of 14.3%; Nitrate masses ranged from 0.005 to 30.7 with a mean of 1.84 and a median of 0.93; Nitrate fractions ranged from 0% to 107% with a mean of 21% and a median of 16%; Salt masses ranged from 0.004 to 1.9 with a mean of 0.05 and a median of 0.01; Salt fractions ranged from <1% to 29%, with a mean and median <1%; Soil masses ranged from 0.04 to 18.4 with a mean of 1.3 and median of 0.98; Soil fractions ranged from <1% to 330%, with a mean of 18.5% and a median of 14.8%; EC masses ranged from 0 to 8.9 with a mean of 0.84 and a median of 0.68; EC fractions ranged from 0 to 164% with a mean of 11% and median 10%; OC masses ranged from -0.72 to 16.4, with a mean of 3.01 and a median of 2.63; OC fractions ranged from -30% to 301%; with a mean and median of 40%; Other masses ranged from -13.4 to 14.5 with a mean of 0.16 and a median of -0.17; Other fractions ranged from -380% to 67% with a mean of -6% and median -3%
## Plot 2 - mass fractions (daily), y axis restricted: Most days have a negative other fraction; see periodic spikes in soil fractions and nitrate; Primarily OM dominant with occasional nitrate or soil dominance; Soil fractions large relative to other study areas
## Table 2 - summary mass and mass fractions by month: Lot of negative other fractions; See clear seasonality in Nitrate and other; Nitrate volatilization seems to be a larger problem here + drier conditions; Have maximum fractions for soil, nitrate, EC, and OC greater than 100%;
## Table 3 - median masses and mass fractions by month of year: Monthly gravimetric masses are lowest in spring, range from 5.6 in march to 8.1 in november and july; reconstructed masses follow the same general pattern, ranging from 5.7 in may to 9.4 in december; sulfate masses were highest in summer (1.14 in july) and lowest in winter (0.56in january); fulfate fractions were highest in spring (20% in april and may) and lowest in winter (8% in december and january); nitrate masses were highest in winter (2.7 in february) and lowest in summer (0.5 in august); nitrate fractions were lowest in summer (7%) and highest in winter (40% in feb); salt masses and mass fractions were both typically less than 1, salt masses and fractions were slightly higher in winter; soil masses were highest in summer (1.6 in june) and lowest in january and february (0.5); soil fractions ranged from 7% in february to 16-17% in spring and fall; EC masses are typically less than one, but are lowest in spring (0.5 in april and may) and highest in late fall and winter (~1); EC fractions are lowest in spring and summer (8-7%) and highest in fall and winter (13-14%); OC masses are lowest in spring  and highest in winter (1.7 in spring, 3-3.5 in winter); OC fractions range from 30% in spring to 45% in august and december; Other masses are typically less than +/- 1 and are positive in summer and negaive throughout the rest of hte year; Others masses are lowest in january (-0.8); Other fractions range from -11% in january to 5% in june and july
## Plot 3 - masses by month (smoothed), by station: Patterns are similar at all 4 stations; Nitrate masses peaked in february and slightly around may; OM peaks in summer and remains high through early winter when it peaks again around december; OM is lowest in spring; soil is relatively stable throughout the year, with slightly higher mass concentrations in spring and fall; sulfate is also relatively stable, with values lower than om, soil, and nitrate most of the year; other peaks in summer, but is negative throughout most of the winter months
## Plot 4 - fractions by month and station (smoothed): OM dominates throughout the entire year at all but two stations during winter months when nitrate dominates; nitrate fractions peak in winter and spring; OM over summer to fall and early winter; soil in spring and fall; and other over summer
## Table 4 - summary of variables by station: maximum nitrate, soil, EC and OC fractions greater than 100% are only found at 2 stations; the remaining two have masses within a reasonable range; Other fractions are primarily negative at all 4 stations
## Table 5 - median values for variables by station: sulfate mass concentrations and fractions are smaller at one station than at the other three, this same station also has the lowest PM masses and is likely a more rural site; nitrate varies from station to station, median masses from 1.3 to 0.6 and fractions from 10 to 22%; salt fractions are all < 1, but are 2x the others at one station; soil is relatively similar across stations, ranging from 13.5 to 15.7; EC from 7.8 - 11.5%; OC from 34.5 to 46.7%; other from -2.7% to -6.1%
Col24$Year <- as.numeric(substr(Col24$Date, 1, 4))
aggregate(X24hrPM ~ Year, Col24, mean)
Col24$Month <- as.numeric(substr(Col24$Date, 6, 7))
aggregate(X24hrPM ~ Month, Col24, mean)
aggregate(X1hrPM ~ Time, Colorado1, mean)

# Indiana - read in Midwest datasets
Mdwst24 <- read.csv("/home/jhbelle/EPAdata/MdwstObs24hrFRM.csv", stringsAsFactors = F)
# Remove any duplicated records from Mdwst24 and rewrite file
Mdwst24 <- unique(Mdwst24)
# Need to handle cases with multiple monitors at a single site
# Remove the observations from the beta attenuation monitors - known to be biased high - All are POC=3 observations
Mdwst24 <- subset(Mdwst24, Mdwst24$POC != 3)
# Need one value per station per day - use POC 1 preferentially; POC 2 if POC 1 is absent
Mdwst24 <- ddply(Mdwst24, .(State, County, Site, Date), POCsort)
Mdwst24$Date <- as.Date(Mdwst24$Date, "%Y-%m-%d")
Mdwst24 <- subset(Mdwst24, Mdwst24$Date > as.Date("2007-04-01", "%Y-%m-%d") & Mdwst24$Date < as.Date("2015-03-31", "%Y-%m-%d"))
# Read in speciated data from CSN
MdwstSpec24 <- read.csv("/home/jhbelle/EPAdata/MdwstObs24hrFRMSpec.csv", stringsAsFactors = F)
# Read in blank values for EC/OC correction
MdwstBlanks <- read.csv("/home/jhbelle/EPAdata/MdwstObs24hrFRMBlanks.csv", stringsAsFactors = F)
MdwstBlanks$Date2 <- as.character(as.Date(MdwstBlanks$Date, "%Y-%m-%d"), "%m")
# Calculate monthly/year average blank values associated with 88370 and 88380 observations - where average is taken across study area
MonthBlanks <- aggregate(MdwstBlanks$BlankValue, by=list(MdwstBlanks$Date2, MdwstBlanks$ParameterCode), mean, na.rm=T)
colnames(MonthBlanks) <- c("YrMo", "ParameterCode", "BlankValue")
MonthBlanks <- reshape(MonthBlanks, timevar="ParameterCode", idvar="YrMo", direction = "wide")
MonthBlanks$BlankValue.Improve <- c(1.1, 1.3, 1.2, 1.4, 1.6, 1.7, 1.8, 1.9, 1.5, 1.2, 1.0, 1.1)
rm(MdwstBlanks)
# Calculate mass fractions - parameter names: Sulfate=1.375*88403, Nitrate=1.29*88306, OC=1.8*(88320 | (88370 - blank) | ((88305 + 88307) - 1.3*(88307) - a_i)/1.2), Crustal=2.2*88104 + 2.49*88165 + 1.63*88111 + 2.42*88126 + 1.94*88161, Salt=1.8*88115, EC=1.3*(88307) | 88321 | (88380 - blank_88380), Other=Remaining fraction (may be negative)
# Subset EPA data to only include parameters of interest
MdwstSpec24 <- subset(MdwstSpec24, MdwstSpec24$ParameterCode %in% c(88403, 88306, 88320, 88370, 88305, 88307, 88104, 88165, 88111, 88126, 88161, 88115, 88321, 88380))[,c(1:4,10,11)]
MdwstSpec24 <- rbind.data.frame(MdwstSpec24, c(18, 65, "3", 88321, "2007-01-06", NA))
MdwstSpec24 <- rbind.data.frame(MdwstSpec24, c(18, 65, "3", 88320, "2007-01-06", NA))
MdwstSpec <- MassRecon(MdwstSpec24, Mdwst24, MonthBlanks) # This is broken?
SpecTables(MdwstSpec)
# Have two stations with complete time series - no IMPROVE monitors?
length(unique(MdwstSpec$Date)) # 887 distinct days
length(unique(Mdwst24$Date)) # 3225 distinct days with gravimetric measurements
## Plot 1 - mass fractions (daily), no axis restrictions: Again, some outliers in both time series; Will be eliminating some observations where gravimetric mass is suspect and dividing by reconstructed mass/eliminating other fraction
## Table 1 - mass and mass fraction summary: Dates range from 2007/01/06 to 2015/08/10; 24 hour PM ranged from 0.9 to 62.6 with a mean of 11.7 and a median of 10.5; Reconstructed masses ranged from 1.15 to 38.9 with a mean of 10.9 and a median of 9.9; Sulfate masses ranged from 0.08 to 23.2 with a mean of 3.9 and a median of 3.1; Sulfate fractions ranged from 1.4% to 151% with a mean of 33% and median 32%; Nitrate masses ranged from 0.01 to 24.8 with a mean of 2.7 and median 1.5; nitrate fractions ranged from <1% to 73% with a mean of 22.8% and median 19%; Salt masses were typically less than 1, but the maximum was 5.5; while the salt fraction ranged from < 1% to 42%, but with a mean and median <1%; Soil masses ranged from 0.04 to 6.03 with a mean of 0.42 and median 0.32; Soil fractions ranged from <1% to 77% with a mean of 4.2% and median 3.2%; EC masses ranged from 0 to 3.65 with a mean of 0.56and median 0.46; EC fractions ranged from 0 to 54% with a mean of 5.2% and median 4.6%; OC masses ranged from -0.68 to 16.4 with a mean of 3.3 and median 2.9; Other masses range from -24.4 to 41.5 with a mean of 0.77 and median 0.59; Other fractions range from -281% to 66% with a mean of 2.8 and median 6.3%; Majority of other fractions were within +/-20% of gravimetric value
quantile(MdwstSpec$OtherFrac, probs=c(0.05, 0.95))*100 # 95% interval - -20.1 to 24.8%
## Plot 2 - mass fractions (daily), y axis restricted: More Nitrate and sulfate dominant than OM, these two just have more variability throughout the year; Soil fractions remain relatively small; Other fraction varies seasonally and daily
## Table 2 - summary mass and mass fractions by month: April and July have sulfate > 100%; April, July, and september has OC fractions >100%; These months + Dec have other fractions < -100%
## Table 3 - median masses and mass fractions by month of year: 24 hour PM was lowest in the spring and fall and highest in the winter and summer, ranging from 7.8 to 13.25; Reconstructed masses followed this same pattern, ranging from 7.6 to 11.6; Sulfate masses increased from 2.4 in October to 4.5 in august, and were highest in late summer and lowest in the fall and spring; Sulfate fractions were highest in september (40%) and lowest in january and february (24%); Nitrate masses were lowest in summer (0.6 in august) and highest in winter (4.9 in February); Nitrate fractions varies substantially throughout the year, from 5% in august to 40% in february; Salt masses fractions were low, but about double in winter as in summer, but less than 1% of mass; Soil masses were less than 1, and lowest in winter and highest in spring; Soil fractions ranged from 5% in spring to 2% in winter; EC masses ranged from 0.4 in winter months to 0.6 in summer months; EC fractions were between 3 and 6.3%, and were highest in fall and lowest in winter; OC masses ranged from 2.3 in winter and spring to 3.7 in summer; OC fractions ranged from ~20% in winter to ~30% in summer and fall; The other masses were positive and larger in summer months, smaller and/or negative in the spring and fall, and moderately large in the winter months; Other mass fractions followed the same pattern, ranging from -0.6% in april to 14% in july
## Plot 3 - masses by month (smoothed), by station: Nitrate mass peaks in winter and is larger at peak than sulfate and OM; Sulfate peaks in later summer while OM is smoother throughout year, but peaks slightly at late summer/fall; The other mass is highest in summer and lowest in spring and fall, when it is typically negative; soild is higher in the spring/early summer but is fairly stable
## Plot 4 - fractions by month and station (smoothed): Nitrate peaks in winter, Sulfate in summer, these two species, together, dominate over OM; OM peaks late summer/fall; other in summer; soil is lowest in winter
## Table 4 - summary of variables by station: Both stations have mass fractions >+/-100%
## Table 5 - median values for variables by station: Fractions are fairly similar between stations, although one station has more OC, and lower fractions of nitrate and sulfate
Mdwst24$Year <- as.numeric(substr(Mdwst24$Date, 1, 4))
aggregate(X24hrPM ~ Year, Mdwst24, mean)
Mdwst24$Month <- as.numeric(substr(Mdwst24$Date, 6, 7))
aggregate(X24hrPM ~ Month, Mdwst24, mean)
aggregate(X1hrPM ~ Time, Mdwst1, mean)

# California - read in California datasets
Calif24 <- read.csv("/home/jhbelle/EPAdata/CalifObs24hrFRM.csv", stringsAsFactors = F)
# Remove any duplicated records from Calif24 and rewrite file
Calif24 <- unique(Calif24)
# Need to handle cases with multiple monitors at a single site
# Remove the observations from the beta attenuation monitors - known to be biased high - All are POC=3 observations
Calif24 <- subset(Calif24, Calif24$POC != 3)
# Need one value per station per day - use POC 1 preferentially; POC 2 if POC 1 is absent
Calif24 <- ddply(Calif24, .(State, County, Site, Date), POCsort)
Calif24$Date <- as.Date(Calif24$Date, "%Y-%m-%d")
Calif24 <- subset(Calif24, Calif24$Date > as.Date("2007-04-01", "%Y-%m-%d") & Calif24$Date < as.Date("2015-03-31", "%Y-%m-%d"))
# Read in speciated data from CSN
CalifSpec24 <- read.csv("/home/jhbelle/EPAdata/CalifObs24hrFRMSpec.csv", stringsAsFactors = F)
# Read in blank values for EC/OC correction
CalifBlanks <- read.csv("/home/jhbelle/EPAdata/CalifObs24hrFRMBlanks.csv", stringsAsFactors = F)
CalifBlanks$Date2 <- as.character(as.Date(CalifBlanks$Date, "%Y-%m-%d"), "%m")
# Calculate monthly/year average blank values associated with 88370 and 88380 observations - where average is taken across study area
MonthBlanks <- aggregate(CalifBlanks$BlankValue, by=list(CalifBlanks$Date2, CalifBlanks$ParameterCode), mean, na.rm=T)
colnames(MonthBlanks) <- c("YrMo", "ParameterCode", "BlankValue")
MonthBlanks <- reshape(MonthBlanks, timevar="ParameterCode", idvar="YrMo", direction = "wide")
MonthBlanks$BlankValue.Improve <- c(1.1, 1.3, 1.2, 1.4, 1.6, 1.7, 1.8, 1.9, 1.5, 1.2, 1.0, 1.1)
rm(CalifBlanks)
# Calculate mass fractions - parameter names: Sulfate=1.375*88403, Nitrate=1.29*88306, OC=1.8*(88320 | (88370 - blank) | ((88305 + 88307) - 1.3*(88307) - a_i)/1.2), Crustal=2.2*88104 + 2.49*88165 + 1.63*88111 + 2.42*88126 + 1.94*88161, Salt=1.8*88115, EC=1.3*(88307) | 88321 | (88380 - blank_88380), Other=Remaining fraction (may be negative)
# Subset EPA data to only include parameters of interest
CalifSpec24 <- subset(CalifSpec24, CalifSpec24$ParameterCode %in% c(88403, 88306, 88320, 88370, 88305, 88307, 88104, 88165, 88111, 88126, 88161, 88115, 88321, 88380))[,c(1:4,10,11)]
CalifSpec <- MassRecon(CalifSpec24, Calif24, MonthBlanks)
SpecTables(CalifSpec)
# 15 sites, some with highly suspect results (OC fractions consistently over 100, or extended gaps in data record)
length(unique(CalifSpec$Date)) # 1,074 days with speciated data
length(unique(Calif24$Date)) # 3,226 days with gravimetric data
## Plot 1 - mass fractions (daily), no axis restrictions: A handful of days/stations have observations with values far exceeding 100% for mass fractions of other, OM, and nitrate
## Table 1 - mass and mass fraction summary: 24 hour PM concentrations range from 0.8 to 195 with a mean of 11.8 and median 8.2; Reconstructed masses ranged from 0.7 to 120 with a mean of 12.2 and median 8.5; Sulfate masses ranged from 0.003 to 34.9 with a mean of 1.3 and median 1.1; Sulfate fractions ranged from <1% to 160% with a mean of 15.2% and median 14.1%; Nitrate masses ranged from 0.005 to 91.2 with a mean of 3.3 and median 1.3; Nitate fractions ranged from <1% to 200% with a mean of 22% and median 16.8%; Salte masses ranged from 0.002 to 5.9 with a mean of 0.14 and median 0.02; Salt fractions ranged from <1% to 45%, with a mean of 1.6% and a median of <1%; Soil masses ranged from 0.04 to 26.2 with a mean of 0.8 and median 0.5; soil fractions ranged from <1% to 140% with a mean of 9.6% and median 6.7%; EC masses ranged from 0 to 8.1, with a mean of 0.8 and median 0.5; EC fractions ranged from 0 to 230% with a mean of 7.6% and median 6.2%; OC masses ranged from -1.1 to 75 with a mean of 5.8 and median 3.9; OC fractions ranged from -24% to 870% with a mean of 53% and median 48%; Other masses ranged from -35 to 171, with a mean of -0.4 and median -0.3; Other fractions ranged from -1000% to 87% with a mean of -8.8% and median -3.6%; the IQR encompasses other fractions from -18% to +8%
quantile(CalifSpec$OtherFrac, probs=c(0.05, 0.95))*100 # Ranged from -54.7% to 24.1%
## Plot 2 - mass fractions (daily), y axis restricted: Time series for a few stations (06-063) may need to be removed - inconsistent and most values for OM far too high; Otherwise largely OM dominant with seasonal nitrate and occasional Sulfate spikes; Most other fractions appear negative with seasonal variability
## Table 2 - summary mass and mass fractions by month: Have fractions of Sulfate, nitrate, soil, EC and OC over 100%; Other fractions largely negative and every month has other values -<100%
## Table 3 - median masses and mass fractions by month of year: 24 hour PM concentrations ranged from 6.1 in april to 20.6 in january and were generally highest in winter months; Reconstructed masses ranged from 6.3 in April to 21.2 in January and were highest in winter months; Sulfate masses ranged from 0.6 in February to 1.5 in July; Sulfate fractions 4.5% in january and december to ~20% in april - july; Nitrate masses ranged from 6.1 in January to 0.8 in June; Nitrate fractions ranged from 33% in january to 10% in july and august; Salt masses were all < 1 microgra/m^3, but were highest in december and january and lowest in summer and fall; Salt fractions were less than 1%; Soil masses ranged from 0.4 in december to 0.9 in september; Soil fractions ranged from 2.4% in december and january to 10-11% april, may, august, and september; EC masses ranged from 1.5 in January to 0.3 in may and june; EC fractions are fairly stable throughout the year, ranging from 4% in summer months to 8% in winter months; OC masses range from 2.5 in may to 9 in january; OC fractions range from ~40% in spring, to ~50% in winter, spring, and fall, to ~60% in november; Other masses are negative most months, and range from -75 in february, march, october, and november to +20-30 in summer; Other fractions range from -12% in march to +4% in july
## Plot 3 - masses by month (smoothed), by station: Difficult to see, some stations have unusually large OM values (20-40) in winter
## Plot 4 - fractions by month and station (smoothed): OM lowest in summer and/or spring; Nitrate highest in winter; OM dominates, followed by nitrate
# Plot 3 - not by station using averages at each month
ggplot(CalifSpec, aes(x=as.numeric(as.character(Date, "%m")))) + stat_summary(aes(y=Sulfate), na.rm=T, color="yellow", fun.y="median", geom="line") + stat_summary(aes(y=Nitrate), na.rm=T, color="red", fun.y="median", geom="line") + stat_summary(aes(y=Soil), na.rm=T, color="blue", fun.y="median", geom="line") + stat_summary(aes(y=EC), na.rm=T, fun.y="median", geom="line") + stat_summary(aes(y=OC), na.rm=T, color="green", fun.y="median", geom="line") + stat_summary(aes(y=Other), na.rm=T, color="gray", fun.y="median", geom="line")
# Sulfate increases in summer months; Nitrate increases drastically in winter months, as does OM; EC follows a similar pattern but is less extreme; Soil is relatively stable, increasing slightly over summer; Other is highest in summer and lowest in fall; Other is only positive in the summer months
# Plot 4 - not by station using averages at each month
ggplot(CalifSpec, aes(x=as.numeric(as.character(Date, "%m")))) + stat_summary(aes(y=SulfateFrac), na.rm=T, color="yellow", fun.y="median", geom="line") + stat_summary(aes(y=NitrateFrac), na.rm=T, color="red", fun.y="median", geom="line") + stat_summary(aes(y=SoilFrac), na.rm=T, color="blue", fun.y="median", geom="line") + stat_summary(aes(y=ECFrac), na.rm=T, fun.y="median", geom="line") + stat_summary(aes(y=OCFrac), na.rm=T, color="green", fun.y="median", geom="line") + stat_summary(aes(y=OtherFrac), na.rm=T, color="gray", fun.y="median", geom="line")
# OM fraction is lowest in may and highest in february and november; The OM fraction is the largest in all months; Nitrate fraction increases in winter months and make up a larger proportion of mass than sulfate in most non-summer months; Sulfate fraction is highest in the summer months and lowest in the winter; EC fraction is slightly higher in winter months than in summer; Soil fraction peaks in september and is lowest in winter months; Other fraction peaks in summer (only positive fractions), and again in january/december, and is lowest in fall/spring when it is negative by ~10%
## Table 4 - summary of variables by station: All months have OC fractions maximum > 100%; Mixed bag for others
## Table 5 - median values for variables by station: A few stations have much higher salt concentrations, although average fractions at these stations only reach 1-2%; Most species have normal variability; 2 sites in same county in california have OC masses twice what they are in other stations, and OC fractions averaging >100%.


## --------------
## Data cleaning
## --------------
# Need to scrub out values where the gravimetric and/or speciated total masses are suspect - i.e. A large difference in gravimetric mass between POC values; An extremely high other mass in the previous analysis; QAC notes
# Also review mass fractions >100% of gravimetric value
AtlGE100 <- ifelse(AtlSpec$SulfateFrac > 1 | AtlSpec$NitrateFrac > 1 | AtlSpec$SoilFrac > 1 | AtlSpec$ECFrac > 100 | AtlSpec$OCFrac > 100 | AtlSpec$OtherFrac < -1 | AtlSpec$OtherFrac > 1, 1, 0)
SubAtlProb <- subset(AtlSpec, AtlGE100 == 1)
View(SubAtlProb) # 10 observations meet criteria, most have unusually low 24 hour masses
#Atl24 <- read.csv("/home/jhbelle/EPAdata/AtlObs24hrFRM.csv", stringsAsFactors = F)
# Remove any duplicated records from Atl24 and rewrite file
#Atl24 <- unique(Atl24)
# Need to handle cases with multiple monitors at a single site
# Remove the observations from the beta attenuation monitor - known to be biased high - just removing all POC=3 observations since the only one in the speciated dataset with that value is the one we don't want
#Atl24 <- subset(Atl24, Atl24$POC != 3)
#Atl24$Date <- as.Date(Atl24$Date, "%Y-%m-%d")
Atl <- merge(Atl24, SubAtlProb, by=c("State", "County", "Site", "Date"), all.y=T)
View(Atl) # 3 had discrepancies between different POCs
AtlSpecClean <- subset(AtlSpec, AtlGE100 == 0)
AtlSpecClean[,17:22] <- AtlSpecClean[,c(9:14)]/AtlSpecClean$ReconMass
summary(AtlSpecClean)
aggregate(AtlSpecClean$OtherFrac*100, list(as.character(AtlSpecClean$Date, "%m")), mean)
AtlSpec_2 <- AtlSpecClean[,c(4,17:22)]
summary(AtlSpec_2[,2:7]*100)
aggregate(AtlSpec_2[,2:7]*100, list(as.character(AtlSpec_2$Date, "%m")), mean)

AtlSpecPlt <- reshape(AtlSpec_2, direction="long", varying=list(2:7))
ggplot(AtlSpecPlt, aes(x=as.integer(as.character(Date, "%m")), color=as.factor(time), y=SulfateFrac)) + stat_summary(geom="line", fun.y = "mean", size=2) + ylab("Proportion of mass") + scale_x_continuous("Month of year", breaks=c(2,6,10)) + ggtitle(expression("Average " * PM[2.5] * " Composition")) + scale_color_discrete("Species", labels = c("1"=expression("Sulfate, " * SO[4]), "2"=expression("Nitrate, " * NO[3]), "3"="Salt, NaCl", "4"="Soil", "5"="EC", "6"="OC")) + theme_classic()


ColGE100 <- ifelse(ColSpec$SulfateFrac > 1 | ColSpec$NitrateFrac > 1 | ColSpec$SoilFrac > 1 | ColSpec$ECFrac > 100 | ColSpec$OCFrac > 100 | ColSpec$OtherFrac < -1 | ColSpec$OtherFrac > 1, 1, 0)
SubColProb <- subset(ColSpec, ColGE100 == 1)
Col24$Date <- as.Date(Col24$Date, "%Y-%m-%d")
Col <- merge(Col24, SubColProb, by=c("State", "County", "Site", "Date"), all.y=T)
View(Col) # 3 had discrepancies between different POCs
ColSpecClean <- subset(ColSpec, ColGE100 == 0)
ColSpec[,17:22] <- ColSpec[,c(9:14)]/ColSpec$ReconMass
summary(ColSpecClean[,9:14])
aggregate(ColSpecClean$OtherFrac*100, list(as.character(ColSpecClean$Date, "%m")), mean)
ColSpec_2 <- ColSpecClean[,c(4,17:22)]
summary(ColSpec_2[,2:7]*100)
aggregate(ColSpec_2[,2:7]*100, list(as.character(ColSpec_2$Date, "%m")), mean)

CalifGE100 <- ifelse(CalifSpec$SulfateFrac > 1 | CalifSpec$NitrateFrac > 1 | CalifSpec$SoilFrac > 1 | CalifSpec$ECFrac > 100 | CalifSpec$OCFrac > 100 | CalifSpec$OtherFrac < -1 | CalifSpec$OtherFrac > 1, 1, 0)
SubCalifProb <- subset(CalifSpec, CalifGE100 == 1)
Calif24$Date <- as.Date(Calif24$Date, "%Y-%m-%d")
Calif <- merge(Calif24, SubCalifProb, by=c("State", "County", "Site", "Date"), all.y=T)
View(Calif) # 3 had discrepancies between different POCs
CalifSpecClean <- subset(CalifSpec, CalifGE100 == 0 & CalifSpec$County != 63)
CalifSpec[,17:22] <- CalifSpec[,c(9:14)]/CalifSpec$ReconMass
summary(CalifSpecClean[,9:14])
aggregate(CalifSpecClean$OtherFrac*100, list(as.character(CalifSpecClean$Date, "%m")), mean)
CalifSpec_2 <- CalifSpecClean[,c(4,17:22)]
summary(CalifSpec_2[,2:7]*100)
aggregate(CalifSpec_2[,2:7]*100, list(as.character(CalifSpec_2$Date, "%m")), mean)

MdwstGE100 <- ifelse(MdwstSpec$SulfateFrac > 1 | MdwstSpec$NitrateFrac > 1 | MdwstSpec$SoilFrac > 1 | MdwstSpec$ECFrac > 100 | MdwstSpec$OCFrac > 100 | MdwstSpec$OtherFrac < -1 | MdwstSpec$OtherFrac > 1, 1, 0)
SubMdwstProb <- subset(MdwstSpec, MdwstGE100 == 1)
Mdwst24$Date <- as.Date(Mdwst24$Date, "%Y-%m-%d")
Mdwst <- merge(Mdwst24, SubMdwstProb, by=c("State", "County", "Site", "Date"), all.y=T)
View(Mdwst) # 3 had discrepancies between different POCs
MdwstSpecClean <- subset(MdwstSpec, MdwstGE100 == 0)
MdwstSpec[,17:22] <- MdwstSpec[,c(9:14)]/MdwstSpec$ReconMass
summary(MdwstSpecClean[9:14])
summary(MdwstSpecClean$OtherFrac*100)
aggregate(MdwstSpecClean$OtherFrac*100, list(as.character(MdwstSpecClean$Date, "%m")),mean)
MdwstSpec_2 <- MdwstSpecClean[,c(4,17:22)]
summary(MdwstSpec_2[,2:7]*100)
aggregate(MdwstSpec_2[,2:7]*100, list(as.character(MdwstSpec_2$Date, "%m")), mean)

## ---------------
## Write cleaned files to disk - combine all study sites into single files
## ---------------

# 24 hour observations
G24hr <- rbind.data.frame(Atl24[,1:11], Col24[,1:11], Mdwst24[,1:11], Calif24[,1:11])
G24hr$StudyArea <- c(rep("Atl", nrow(Atl24)), rep("Col", nrow(Col24)), rep("Mdwst", nrow(Mdwst24)), rep("Calif", nrow(Calif24)))
#ggplot(G24hr, aes(x=Date, color=StudyArea, y=X24hrPM)) + stat_summary(geom="line", fun.y="mean")
write.csv(G24hr, "/home/jhbelle/EPAdata/CleanedData/G24hr.csv")

# 1 hour observations
H1hr <- rbind.data.frame(Atl1[,1:15], Colorado1, Mdwst1, Calif1)
H1hr$StudyArea <- c(rep("Atl", nrow(Atl1)), rep("Col", nrow(Colorado1)), rep("Mdwst", nrow(Mdwst1)), rep("Calif", nrow(Calif1)))
#ggplot(O1hr, aes(x=Date, color=StudyArea, y=X1hrPM)) + stat_summary(geom="line", fun.y="mean")
write.csv(H1hr, "/home/jhbelle/EPAdata/CleanedData/H1hr.csv")

# Speciated observations 
S24hr <- rbind.data.frame(AtlSpecClean, ColSpecClean, MdwstSpecClean, CalifSpecClean)
S24hr$StudyArea <- c(rep("Atl", nrow(AtlSpecClean)), rep("Col", nrow(ColSpecClean)), rep("Mdwst", nrow(MdwstSpecClean)), rep("Calif", nrow(CalifSpecClean)))
write.csv(S24hr, "/home/jhbelle/EPAdata/CleanedData/S24hr.csv")
