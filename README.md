# Aim1Repo
Repository for code from aim 1 of dissertation work

## Script order
See RunOrder.sh

## File list

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
	4) Functions_EPA_Proc.R - Function file for EPA_Proc.R, EPA_Anal.R, and EPA_Colloc.R
  5) EPA_Rep.R - Incomplete script - deprecated - deleted from repository

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

