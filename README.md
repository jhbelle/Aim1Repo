# Aim1Repo
Repository for code from aim 1 of dissertation work

## Script order
See RunOrder.sh

## File list

I. Downloading/obtaining satellite and modeled datasets - all of the below are example pull scripts that download or extract data and are meant to be run from the cluster
	1) DL_NED_Atl.sh - Downloads the NED (National Elevation Dataset) over the study areas included in the study. Record of needed tiles in study areas. Deprecated - NED has been superseded by the 3DEP elevation product, which is currently available for download from the USGS national map portal: https://viewer.nationalmap.gov/basic/?basemap=b1&category=ned,nedsrc&title=3DEP%20View.
	2) wget_cloud.sh; wget_cloud_atl.sh - Downloads the MODIS cloud product over, respectively, San Francisco and atlanta. Deprecated - this is the old way to retrieve ordered data from the laadsweb website (before they switched it to the modaps site). Cloud data can be ordered from: https://ladsweb.modaps.eosdis.nasa.gov/search/, and downloaded using the instructions in the confirmation email, and earthdata login is required. 
	3) Retr_RUC.sh; Retr_RAP.sh - Extracts and processes the RUC/RAP grb datasets going back to 2007 - RUC/RAP grb files can be downloaded from: https://nomads.ncdc.noaa.gov/data/rucanl/. Downloaded and output text datasets for this script have both been deleted and were not saved. Original RUC/RAP grb datasets as downloaded were saved on Big4_112TB_1 and Big4_12_8 
	4) extrlatlonmaiac.pro - extracts lat/lon information from the maiac lat/lon files into text format. North American MAIAC lat/lon files for all grids can be found on the cluster at /aura/MAIAC_NA/. Xia made a map of tiles over the country to use when figuring out which tiles you need for your study area: MAIAC_Tiles_NorthAmerica.jpg 

II. Processing and analysis of EPA data - these files were run locally
	1) EPA_Proc.R - Processes EPA 24 hour, 1 hour, speciated 24 hour and speciated 1 hour data into study-site specific data-sets. Requires the EPA archives composed of annual files downloaded from airdata.gov. These files are currently at T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAarchives/EPA_GroundMonitors. Script depends on functions in Functions_EPA_Proc.R.
	2) EPA_Anal.R - Exploratory analysis and data cleaning of EPA 24 hour, 1 hour, and speciated 24 hour data. Script depends on functions in Functions_EPA_Proc.R. Requires the datasets output from EPA_Proc.R
	3) EPA_Colloc.R - Creates datasets of dates and locations to be collocated with MODIS cloud, RUC/RAP, etc. Scripts depends on Functions in Functions_EPA_Proc.R. Requires the datasets output from EPA_Anal.R.
	4) Functions_EPA_Proc.R - Function file for EPA_Proc.R, EPA_Anal.R, and EPA_Colloc.R

III. RUC/RAP processing - Converts RUC/RAP from extracted text files to packed HDF5 formatted files for satellite passes and each 24-hr period - HDF5 outputs from these scripts are located on the cluster at "/gc_runs/RUCRAP_FinalOutputs" - This folder contains its own readme, an example access script, variable lists, and grid files describing the RUC/RAP datafiles. 
	1) RUCRAP_MakeHDF.R - Creates 24 hr files - Too many days were partially incomplete to run and get reasonable results - was never processed  through to final files
	2) RUCRAP_MakeTHDF.R - Creates Terra overpass matched files from 130 km grid files
	3) RUCRAP_MakeAHDF.R - Creates Aqua overpass matched files from 130 km grid files
	4) RUCRAP_252_MakeAHDF.R; RUCRAP_252_MakeTHDF.R - Processes lower resolution 252 km grid files from the RUC/RAP 
	5) qsub_RUCRAP_MakeAHDF.sh; qsub_RUCRAP_MakeTHDF.sh; qsub_RUCRAP_MakeHDF.sh - Bash submission scripts for RUCRAP_MakeAHDF.R, RUCRAP_MakeTHDF.R and RUCRAP_MakeHDF.R

IV. Collocation processing	
	1) RadialMatch_ExtractCloud.m - Pulls cloud observations within Radii of EPA stations
	2) vdist.m - distance function called by RadialMatch_ExtractCloud.m - obtained from outside source - does distance calculations on a sphere   
	3) Cloud_Proc.R - Combines cloud observations into aggregate values for each collocation and radius (5 km, 10km, 15km, 20 km,30km, and 40 km) at both the california and atlanta sites
	4) extrmaiac.pro - Extracts maiac observations within radii of EPA stations
	5) cgsetintersection.pro - function file called from extrmaiac.pro
	6) qsub_extrmaiac.pro - IDL submission script for extrmaiac.pro, contains examples of use of extrmaiac.pro
	7) qsub_extrmaiac.sh - bash submission script for qsub_extrmaiac.pro
	8) MAIAC_Collocs.R - Calculates aggregate MAIAC statistics for each collocation/radius
		

VI. Gridding - 1x1 km and 5x5 km cloud product extraction, gridding, and linkage
	1) GriddingExtractMODIS5km.m - Extracts all 5 km parameters from M*D06_L2 files.
	2) GriddingExtractMODIS1km.m; GEMOD1km_T.m - Extracts all 1 km parameters from both M*D06_L2 and M*D03 files (contain lat/lon grid information)
	3) qsub_1kmExtr.sh; qsub_1kmExtrT.sh - Bash submission scripts for GriddingExtractMODIS1km.m and GEMOD1km_T.m, respectively
	4) ThiessenPolygons.R - Grids the 5 km parameters extracted by GriddingExtractMODIS5km.m
	5) ThiessenPolygonsAqua1kmSBot.R; ThiessenPolygonsAqua1kmSBot2.R; ThiessenPolygonsAqua1kmSTop.R; ThiessenPolygonsAqwua1kmSTop2.R - Grids the 1 km parameters for the Aqua overpass extracted by GriddingExtractMODIS1km.m
	6) ThiessenPolygonsTerra1kmSBot.R; ThiessenPolygonsTerra1kmSBot2.R, ThiessenPolygonsTerra1kmSTop.R; ThiessenPolygonsTerra1kmSTop2.R - Grids the 1 km parameters for the Terra overpass extracted by GEMOD1km_T.m
	7) LinkMODdat.R - Links the grid output from the 5x5 km grid to the extracted values, outputting final datasets containing aggregate values  
	8) Link1kmMODdat.R - 


VII. Statistical analysis - Aim 1

