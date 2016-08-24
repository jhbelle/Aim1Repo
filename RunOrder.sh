#!/bin/bash

## ----------------------
## Name: RunOrder.sh
## Program version: Bash
## Dependencies: R, CDO (compiled with support for hdf5, netcdf, grib)
## Author: J.H. Belle
## Purpose: Specifies run order of scripts in Aim1Repo
## ----------------------

## ----------
## Diagram
## ----------

#  _____________________	_________________________	__________________	__________
#  | EPA data  	       |	| MODIS cloud 		|	| RUC/RAP 	 |	| MAIAC  |
#  | 	- EPA_Proc.R   |	|   - wget_cloud_atl.sh |	|  - Retr_RUC.sh |
#  | 	- EPA_Anal.R   |	|_______________________|	|________________|
#  | 	- EPA_Colloc.R |		|
#  |___________________|		|
#                    \			|
#		      \			|
#		       \		|
#			\		|
#			 \______________|



## ----------
## Bash
## ----------

# EPA data
Rscript EPA_Proc.R
Rscript EPA_Anal.R
Rscript EPA_Colloc.R

# MODIS cloud
sh wget_cloud_atl.sh

# RUC/RAP
sh Retr_RUC.sh
