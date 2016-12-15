## --------------
## Name: Functions_RUCRAP_MakeHDF.R
## Author: J.H. Belle
## Purpose: Function file for RUCRAP_MakeHDF.R
## --------------

# ---------
# Function 1: MakeEmptyDat - A function that takes in a data frame file, and variable list and creates a data frame with the additional variables added in, with 0 values for all rows
# ---------

MakeEmptyDat <- function(existFrame, varList){
  # Takes as input existFrame, a data frame, and varList a character vector and outputs a data frame expanded to include the new variables
  dat <- cbind.data.frame(existFrame, matrix(0, nrow=nrow(existFrame), ncol=length(varList)))
  colnames(dat) <- c(colnames(existFrame), varList)
  return(dat)
}

# ---------
# Function 2: 
# ---------
