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
	3) EPA_Colloc.R - Creates datasets of dates and locations to be collocated with MODIS cloud, RUC/RAP, and Lightning products
	4) Functions_EPA_Proc.R - Function file for EPA_Proc.R, EPA_Anal.R, and EPA_Colloc.R

III. RUC/RAP processing - Converts RUC/RAP from extracted text files to packed HDF formatted files for satellite passes and each 24-hr period
	1) RUCRAP_MakeHDF.R - Creates 24 hr files
	2) RUCRAP_MakeTHDF.R - Creates Terra overpass matched files
	3) RUCRAP_MakeAHDF.R - Creates Aqua overpass matched files

IV. Collocation processing	
	1) RadialMatch_ExtractCloud.m - Pulls cloud observations within Radii of EPA stations   
	2) Cloud_Proc.R - Combines cloud observations into aggregate values for each collocation and radius
	3) CDO_ProcRUCRAPCollocs.sh - Collocates RUC/RAP data and EPA observationss, taking the 130 RUC/RAP observations if they exist and the 252 observations if not
	4) extrmaiac.pro - Extracts maiac observations within radii of EPA stations
	5) MAIAC_Collocs.R - Calculates aggregate MAIAC statistics for each collocation/radius	
	6) EPA_Rep.R - Combines cloud, RUC/RAP, and MAIAC collocations with EPA data and calculates representativeness of overpass times where hourly observations are available

VI. Gridding
VII. Statistical analysis - Aim 1

