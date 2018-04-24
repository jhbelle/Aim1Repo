# Aim1Repo
Repository for code from aim 1 of dissertation work

## Script order
See RunOrder.sh

## File list

<<<<<<< HEAD
I. Downloading/obtaining satellite and modeled datasets - all of the below are example pull scripts that download or extract data and are meant to be run from the cluster
	1) DL_NED_Atl.sh - Downloads the NED (National Elevation Dataset) over the study areas included in the study. Record of needed tiles in study areas. Deprecated - NED has been superseded by the 3DEP elevation product, which is currently available for download from the USGS national map portal: https://viewer.nationalmap.gov/basic/?basemap=b1&category=ned,nedsrc&title=3DEP%20View.
	2) wget_cloud.sh; wget_cloud_atl.sh - Downloads the MODIS cloud product over, respectively, San Francisco and atlanta. Deprecated - this is the old way to retrieve ordered data from the laadsweb website (before they switched it to the modaps site). Cloud data can be ordered from: https://ladsweb.modaps.eosdis.nasa.gov/search/, and downloaded using the instructions in the confirmation email, and earthdata login is required. 
	3) Retr_RUC.sh; Retr_RAP.sh - Extracts and processes the RUC/RAP grb datasets going back to 2007 - RUC/RAP grb files can be downloaded from: https://nomads.ncdc.noaa.gov/data/rucanl/. Downloaded and output text datasets for this script have both been deleted and were not saved. Original RUC/RAP grb datasets as downloaded were saved on Big4_112TB_1 and Big4_12_8 
	4) extrlatlonmaiac.pro - extracts lat/lon information from the maiac lat/lon files into text format. North American MAIAC lat/lon files for all grids can be found on the cluster at /aura/MAIAC_NA/. Xia made a map of tiles over the country to use when figuring out which tiles you need for your study area: MAIAC_Tiles_NorthAmerica.jpg 

II. Processing and analysis of EPA data - these files were run locally
	1) EPA_Proc.R - Processes EPA 24 hour, 1 hour, speciated 24 hour and speciated 1 hour data into study-site specific data-sets. Requires the EPA archives composed of annual files downloaded from airdata.gov. These files are currently at T://eohprojs/CDC_climatechange/Jess/Dissertation/EPAarchives/EPA_GroundMonitors. Script depends on functions in Functions_EPA_Proc.R.
	2) EPA_Anal.R - Exploratory analysis and data cleaning of EPA 24 hour, 1 hour, and speciated 24 hour data. Script depends on functions in Functions_EPA_Proc.R. Requires the datasets output from EPA_Proc.R
	3) EPA_Colloc.R - Creates datasets of dates and locations to be collocated with MODIS cloud, RUC/RAP, etc. Scripts depends on Functions in Functions_EPA_Proc.R. Requires the datasets output from EPA_Anal.R.
=======
I. Downloading/obtaining satellite and modeled datasets
	1) DL_NED_Atl.sh - Downloads the NED over the study areas included in the study
	2) wget_cloud_atl.sh - Downloads the MODIS cloud product over atlanta
	3) wget_SNODAS.sh - Downloads the SNODAS snow depth product - Defunct - not using
	4) Retr_RUC.sh - Downloads and processes the RUC/RAP datasets going back to 2002
	5) Retr_RAP.sh - Downloads and processes the RAP datasets with the rap, instead of the ruc2anl prefix
	6) extrlatlonmaiac.pro - extracts lat/lon information from the maiac lat/lon files into text format

II. Processing and analysis of EPA data
	1) EPA_Proc.R - Processes EPA 24 hour, 1 hour, speciated 24 hour and speciated 1 hour data into study-site specific data-sets 
	2) EPA_Anal.R - Exploratory analysis and data cleaning of EPA 24 hour, 1 hour, and speciated 24 hour data
	3) EPA_Colloc.R - Creates datasets of dates and locations to be collocated with MODIS cloud, RUC/RAP, and MAIAC products
>>>>>>> d403058d06a77ac1221ca7b80cf0f217f098d906
	4) Functions_EPA_Proc.R - Function file for EPA_Proc.R, EPA_Anal.R, and EPA_Colloc.R
  5) EPA_Rep.R - Incomplete script - deprecated - deleted from repository

<<<<<<< HEAD
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

=======
III. RUC/RAP processing - Converts RUC/RAP from extracted text files to packed HDF formatted files for satellite passes and each 24-hr period
	1) RUCRAP_MakeHDF.R - Creates 24 hr files
	2) RUCRAP_MakeTHDF.R - Creates Terra overpass matched files
	3) RUCRAP_MakeAHDF.R - Creates Aqua overpass matched files
	4) Functions_RUCRAP_MakeHDF.R
	5) RUCRAP_252_MakeAHDF.R - Creates Aqua overpass matched files for 252 RUC/RAP data
	6) RUCRAP_252_MakeTHDF.R - Creates Terra overpass matched files for 252 RUC/RAP data

IV. Collocation processing	
	1) RadialMatch_ExtractCloud.m - Pulls cloud observations within Radii of EPA stations   
	2) Cloud_Proc.R - Combines cloud observations into aggregate values for each collocation and radius
	3) extrmaiac.pro - Extracts maiac observations within radii of EPA stations
	4) MAIAC_Collocs.R - Calculates aggregate MAIAC statistics for each collocation/radius	
	5) EPA_Rep.R - Combines cloud, RUC/RAP, and MAIAC collocations with EPA data and calculates representativeness of overpass times where hourly observations are available
	6) CombEPA_MAIAC_Cloud_RUC.R - Combines EPA data with MAIAC, cloud, and RUC collocations to create analysis dataset
`	7) Functions_CombEPA_MAIAC_Cloud_RUC.R - Function file for CombEPA_MAIAC_Cloud_RUC.R

VI. Gridding for case study predictions
  1) MAIAC processing
    a) procmaiac.pro - Extracts MAIAC data 
    b) qsub_extrmaiac.pro - submission idl pro file for procmaiac.pro - contains record of submissions made of script
  2) Cloud Extraction
    a) GEMOD1km_T.m - Extracts Terra M*D35 values to text file
    b) GriddingExtractMODIS1km.m - Extracts Aqua M*D35 values to text file
    c) GriddingExtractMODIS5km.m - Extracts M*D06 values to text file
  3) Cloud Gridding
    a) ThiessenPolygons.r - Grids 5x5 km cloud grid
    b) ThiessenPolygonsAqua1km.r - Grids 1x1 km Aqua MODIS granules to MAIAC
      i) ThiessenPolygonsAqua1kmSBot.r; ThiessenPolygonsAqua1kmSBot2.r; ThiessenPolygonsAqua1kmSTop.r; ThiessenPolygonsAqua1kmSTop2.r - grid files for 4 sections SF grid split into
    c) ThiessenPolygonsTerra1km.r - Grids 1x1 km Terra MODIS granules to MAIAC
      i) ThiessenPolygonsTerra1kmSBot.r; ThiessenPolygonsTerra1kmSBot2.r; ThiessenPolygonsTerra1kmSTop.r; ThiessenPolygonsTerra1kmSTop2.r - grid files for 4 sections SF grid was split into
    d) Functions_ThiessenPolygons.R - function file for ThiessenPolygons*.r series
  4) Cloud Linkage
    a) Link1kmMODdat.R - Links 1x1 grid results back to values - keeps indexes, but doesn't link to values for Cloud AOD or radius
    b) LinkMODdat.R - Links 5x5 grid results back to values - links to actual values for Cloud phase and cloud emissivity
    c) Functions_LinkMODdat_Grid.r - function file for LinkMODdat.R
    d) Functions_Link1kmMODdat_Grid.r - function file for Link1kmMODdat.R
  5) RUC/RAP processing - run after qsub_extrmaiac.pro
    a) HarvardModel.R - Combines output from procmaiac.pro with RUC/RAP data
    b) Functions_HarvardModel.R - Function file for HarvardModel.R
>>>>>>> d403058d06a77ac1221ca7b80cf0f217f098d906

VII. Statistical analysis - Aim 1
	1) CalcR2_CaseStudy.R - deprecated; deleted - parent of CalcR2_CaseStudyAtl.R and CalcR2_CaseStudySF.R
	2) CalcR2_CaseStudyAtl.R - Calculates R2 values for case study results in Atlanta - my model; harvard model; main model 
	3) CalcR2_CaseStudySF.R -  Calculates R2 values for case study results in San Francisco - my model; harvard model; main model
	4) ExCombEPAMAIACCldRUC.R - Main analysis results for gravimetric EPA observations
	5) ExFitMods.R - Deprecated - deleted - parent of CalcR2_CaseStudy.R 
	6) ExSpec.R - Main analysis results for speciated EPA observations
	9) PredValsSF.R - Child of Record_PredHarvard - used to process predictions over longer time periods
	10) Record_PredHarvard.R - Record of commands run interactively from within R on cluster to create 1 days predictions results for figure 3 in paper  
  11) Figure1.R - Creates figure 2 and supplementary figures
  12) Functions_PredVals.R - Function file for PredValsSF.R

