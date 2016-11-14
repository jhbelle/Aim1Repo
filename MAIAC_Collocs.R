## -------------
# Name: MAIAC_Collocs.R
# Program version: R 3.3.0
# Dependencies: plyr
# Author: J.H. Belle
# Purpose: Process MAIAC collocations and tabulate missingness conditions for each overpass
# --------------

library(plyr)

# Read in datasets
Collocfiles = c("/aqua/Jess/Data/CalifCollocs_h08v04.csv", "/aqua/Jess/Data/CalifCollocs_h08v05.csv")
NearPairs = c("/aqua/Jess/Data/Near40kmh08v04_2.csv", "/aqua/Jess/Data/Near40kmh08v05_2.csv")

# Define function to fix rows so can be made into data frame (my bad - see idl programs - left a hanging comma and rows are quoted)
ProcDat <- function(dat, header){
  outdat = rbind.data.frame(gsub(" ", "",dat), stringsAsFactors=F)[,1:length(header)]
  colnames(outdat) <- header
  return(outdat)
}

# Define function to convert the QA field from a decimal to a binary string vector 
ConvQA <- function(intnum, intlength=16){
  # For binary conversion need remainders from repeatedly dividing the integer value by 2, each remainder is 1 of 16 positions for a 16 bit unsigned integer value
  rem = rep(NA, intlength)
  for (bit in seq(1,intlength)){
    rem[bit] = intnum %% 2    
    intnum = intnum %/% 2
  }
  return(as.character(rem))
}

# Define QA values
DefQA <- function(dat, qafield){
  convqaval <- ConvQA(dat[,c(qafield)])
  # Cloud contamination flags
  Cloudnum <- as.integer(paste(convqaval[3], convqaval[2], convqaval[1], sep=""))
  dat$Partcloud <- ifelse(Cloudnum == 10, 1, 0)
  dat$Cloud <- ifelse(Cloudnum == 11, 1, 0)
  dat$CloudShadow <- ifelse(Cloudnum == 101, 1, 0)
  dat$Fire <- ifelse(Cloudnum == 110, 1, 0)
  dat$Sediment <- ifelse(Cloudnum == 111, 1, 0)
  dat$Clear <- ifelse(Cloudnum == 1, 1, 0)
  # Land/water/snow/ice flags
  LType <- as.integer(paste(convqaval[5], convqaval[4], sep=""))
  dat$Water <- ifelse(LType == 1, 1, 0)
  dat$Snow <- ifelse(LType == 10, 1, 0)
  dat$Ice <- ifelse(LType == 11, 1, 0)
  # Glint flag
  dat$Glint <- as.integer(convqaval[13])
  # Adjacency flags
  Adjnum <- as.integer(paste(convqaval[8], convqaval[7], convqaval[6], sep=""))
  dat$AdjCloud <- ifelse(Adjnum == 1, 1, 0)
  dat$SurCloud <- ifelse(Adjnum == 10, 1, 0)
  dat$OneCloud <- ifelse(Adjnum == 11, 1, 0)
  dat$AdjSnow <- ifelse(Adjnum == 100, 1, 0)
  dat$PrevSnow <- ifelse(Adjnum == 101, 1, 0)
  return(dat)
}

# Process collocation data from text file to data frame
for (i in seq(1:length(Collocfiles))){
  Con = file(Collocfile[i])
  Collocs = strsplit(readLines(Con), ",")
  Header = gsub(" ", "", Collocs[[1]])
  Collocs[[1]] = NULL
  Collocs <- ldply(Collocs, ProcDat, header=Header)
  NearFile <- read.csv(NearPairs[i])
  NearFile <- NearFile[,c("State", "County", "Site", "NEAR_DIST")]
  Collocs <- merge(Collocs, NearFile)
  if (exists("CollocDat")){
      CollocDat = rbind.data.frame(CollocDat, Collocs)
  } else CollocDat = Collocs
}

rm(Con, Collocs, Header, Collocfiles, NearPairs, NearFile)
gc()

# Scale AOD
Scaleval = 0.001
CollocDat$AOD55 <- CollocDat$AOD55*Scaleval
CollocDat$AOD47 <- CollocDat$AOD47*Scaleval

# Convert QA field to dummy vars: a) possible cloud, b) cloud, c) cloud shadow, d) fire, e) sediment, f) clear, h) glint, i) water, j) snow, k) ice, l) Adjacent cloud, m) Surrounded cloud, n) One cloud, o) Adjacent snow, p) Previous snow
# If a-f = 0 then undefined cloudiness; if h = 0, no glint; if i-k=0 then land pixel; if l-p = 0 then no adjacency (normal)



# Loop over radii and create text file for each radius - note that distances in near file are meters
radii = c(5, 10, 20, 30, 40) # km
for (radius in radii){
  
}
