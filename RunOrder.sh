#!/bin/bash

## ----------------------
## Name: RunOrder.sh
## Program version: Bash
## Dependencies: R, CDO (compiled with support for hdf5, netcdf, grib); IDL; Matlab
## Author: J.H. Belle
## Purpose: Specifies run order of scripts in Aim1Repo
## ----------------------

## ----------
## Diagram - Function files are left out of this list and may be called from within the cited scripts; qsub****.sh cluster submission files are also ignored with the contents listed in the Bash section missing download scripts imply manual download of data via web download or sftp transfer
## Note: Open file in full screen to view diagram
## ----------

#  _____________________	_________________________________	______________________________	 _________________________	___________________
#  | EPA data  	       |	| MODIS cloud 			 |	| RUC/RAP 	       	      |	| MAIAC  		 |	| NED		   |
#  | 	- EPA_Proc.R   |	|   - wget_cloud_atl.sh 	 |	|  - wgetRUCRAP.sh 	      |	|  - extrlatlonmaiac.pro |	|  - DL_NED_Atl.sh |
#  | 	- EPA_Anal.R   |	|   - RadialMatch_ExtractCloud.m |	|  - Retr_RUC.sh 	      |	|  - extrmaiac.pro	 |	|__________________|
#  | 	- EPA_Colloc.R |	|   - Cloud_Proc.R		 |	|  - Retr_RAP.sh	      |	|  - MAIAC_Collocs.R	 |		/
#  |	- EPA_Rep.R    |	|   - Cloud_Anal.R		 |      |  - RUCRAP_MakeHDF.R	      |	|________________________|	       /
#  |___________________|	|________________________________|	|  - RUCRAP_MakeAHDF.R	      |		/			      /
#                    \			\				|  - RUCRAP_MakeTHDF.R	      |	       /			     /
#		       \		  \				|_____________________________|	     /				   /
#			\		   \					|			    /				  /	
#			 \__________________\___________________________________|__________________________/_____________________________/



## ----------
## Bash
## ----------

# EPA data
Rscript EPA_Proc.R # Creates study-site specific data files of all EPA observations over 2007-2015; EPA observations downloaded as national annual summary files from AirData website
Rscript EPA_Anal.R # Compares hourly to 24hr and speciated to 24 hr results as a sanity check and so cleaning can be done; Does mass reconstruction for speciated observations; Cleans and outputs final datasets by type of EPA observations for full study period - This file outputs the G24hr csv file used for cloud, RUC/RAP and MAIAC collocations
Rscript EPA_Colloc.R # Makes a text file for use in mapping stations in ArcGIS - used to create figure 1 showing station locations at study areas
 

# MODIS cloud
sh wget_cloud_atl.sh # Downloads cloud product - not actually versioned as part of directory - see data location for script
matlab -nojvm -nosplash -r "RadialMatch_ExtractCloud.m" # Collocates cloud product and EPA stations using radius-based collocation method
Rscript Cloud_Proc.R # Processes daily cloud files to get aggregate statistics for each collocation; Creates dummy variables for information in QA codes. Creates separate file for each radius of interest: 5, 10, 20, 30, 40
Rscript Cloud_Anal.R # Takes a look at the cloud collocation statistics

# RUC/RAP
sh wgetRUCRAP.sh # Downloads RUC/RAP observations from html site - Not actually versioned as part of repository - see data location for this script - multiple data locations: /aqua/RUC_RAP; /terra/RUC_RAP_252; /terra/RUC_RAP_252_grb1
sh Retr_RUC.sh # Unpacks data from hourly grb files into text files for later reconstitution - Script was run multiple times see version history if interested
sh Retr_RAP.sh # Same as Retr_RUC but for files with prefix rap instead of ruc2anl
Rscript RUCRAP_MakeHDF.R # Processes RUC/RAP text files into 24-hour RUC RAP statistics, packed as hdf5; 2D with 2 groups: geolocation: Data - rough accounting of time zones
Rscript RUCRAP_MakeAHDF.R # Processes RUC/RAP text files into spatio-temporally Aqua overpass-matched averages at each location on the CONUS grid
Rscript RUCRAP_MakeTHDF.R # Processes RUC/RAP text files into spatio-temporally Terra overpass-matched averages at each location on the CONUS grid


# MAIAC
# NOTE: next two commands are intended to be run from IDL command line
ExtrLatLonMAIAC, "MAIACLatlon.h01v04.hdf", "MAIACLatlonon.h01v04.csv" # Extracts the lat lon information from the MODIS MAIAC lat lon files and outputs to a text file with the IDL-specific referencing indexes
extrmaiac, "T:/eohprojs/CDC_climatechange/MAIACdat/Near40kmh01v04_2.csv", "T:/eohprojs/CDC_climatechange/MAIACdat/CalifCollocs/", "T:/eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24hr.csv", "T:/eohprojs/CDC_climatechange/MAIACdat/", "MAIAC[AT]AOT.h01v04.", 49, 68 # Processes collocations with MAIAC data; Near40kmh01v04 is a text file created from running a nearest neighbor table in ArcGIS off of the station locations from EPA_Colloc.R and the lat/lon indexing information from ExtrLatLonMAIAC, and then table joining the information from both tables back into the result
Rscript MAIAC_Collocs.R # Processes collocated MAIAC observations to get aggregate statistics within radii of each station

# NED
sh DL_NED_Atl.sh # Note tiles were downloaded in batch and then mosaiced using ArcGIS for each study area; Elevation information was joined to the text file created with EPA_Colloc.R to get station elevations 
# Highly unlikely this information will be used in the study

