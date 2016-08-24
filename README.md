# Aim1Repo
Repository for code from aim 1 of dissertation work

## Script order
See RunOrder.sh

## File list

I. Downloading/obtaining satellite and modeled datasets
	1) DL_NED_Atl.sh - Downloads the NED over the study areas included in the study
	2) wget_cloud_atl.sh - Downloads the MODIS cloud product over atlanta
	3) wget_SNODAS.sh - Downloads the SNODAS snow depth product
	4) Retr_RUC.sh - Downloads and processes the RUC/RAP datasets going back to 2002

II. Processing and analysis of EPA data
	1) EPA_Proc.R - Processes EPA 24 hour, 1 hour, speciated 24 hour and spectiated 1 hour data into study-site specific data-sets 
	2) EPA_Anal.R - Exploratory analysis and data cleaning of EPA 24 hour, 1 hour, and speciated 24 hour data
	3) EPA_Colloc.R - Creates datasets of dates and locations to be collocated with MODIS cloud, RUC/RAP, and Lightning products
	Functions_EPA_Proc.R - Function file for EPA_Proc.R, EPA_Anal.R, and EPA_Colloc.R

III. Collocation processing
IV. Gridding
V. Statistical analysis



