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

III. RUC/RAP processing - Converts RUC/RAP from extracted text files to packed HDF formatted files for satellite passes and each 24-hr period
	1) RUCRAP_MakeHDF.R - Creates 24 hr files
	2) RUCRAP_MakeTHDF.R - Creates Terra overpass matched files
	3) RUCRAP_MakeAHDF.R - Creates Aqua overpass matched files
	4) Functions_RUCRAP_MakeHDF.R
	5) RUCRAP_252_MakeAHDF.R
	6) RUCRAP_252_MakeTHDF.R

IV. Collocation processing	
	1) RadialMatch_ExtractCloud.m - Pulls cloud observations within Radii of EPA stations   
	2) Cloud_Proc.R - Combines cloud observations into aggregate values for each collocation and radius
	3) extrmaiac.pro - Extracts maiac observations within radii of EPA stations
	4) MAIAC_Collocs.R - Calculates aggregate MAIAC statistics for each collocation/radius	
	5) EPA_Rep.R - Combines cloud, RUC/RAP, and MAIAC collocations with EPA data and calculates representativeness of overpass times where hourly observations are available
	6) CombEPA_MAIAC_Cloud_RUC.R
`	7) Functions_CombEPA_MAIAC_Cloud_RUC.R

VI. Gridding
	1) GEMOD1km_T.m
	2) GriddingExtractMODIS1km.m
	3) GriddingExtractMODIS5km.m
	4) procmaiac.pro
	5) Functions_Link1kmMODdat_Grid.r
	6) Functions_LinkMODdat_Grid.r
	7) Functions_ThiessenPolygons.R
	8) Link1kmMODdat.R
	9) LinkMODdat.R
	10) MAIAC_Collocs
	11) ThiessenPolygons*.r 

VII. Statistical analysis - Aim 1
	1) CalcR2_CaseStudy.R
	2) CalcR2_CaseStudyAtl.R
	3) CalcR2_CaseStudySF.R
	4) ExCombEPAMAIACCldRUC.R
	5) ExFitMods.R
	6) ExSpec.R
	7) HarvardModel.R
	8) Functions_HarvardModel.R
	9) PredValsSF.R
	10) Record_PredHarvard.R

