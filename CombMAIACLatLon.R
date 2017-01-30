## ---------------------
## Name: CombMAIACLatLon.R
## Program version: R 3.2.3
## Author: J.H. Belle
## Purpose: Combine all the MAIAC lat/lon tiles into 1 file
## ---------------------

for (h in seq(0,4)){
  for (v in seq(0,5)){
    Dat <- read.csv(sprintf("T://eohprojs/CDC_climatechange/MAIACdat/MAIACLatLon.h%02dv%02d.csv", h, v), stringsAsFactors = F)
    Dat$Tile <- sprintf("h%02dv%02d", h, v)
    if (exists("MAIACll")){
      MAIACll <- rbind.data.frame(MAIACll, Dat)
    } else {
      MAIACll = Dat
    }
  }
}
write.csv(MAIACll, "T://eohprojs/CDC_climatechange/MAIACdat/MAIACtiles_GIS/MAIACLatLonAll.csv")
