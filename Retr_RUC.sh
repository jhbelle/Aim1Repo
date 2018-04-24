#!/bin/bash

## ---------------------
## Name: Retr_RUC.sh
## Program version: grib_api; bash
## Author: J.H. Belle
## Purpose: Save data of interest from the RUC/RAP archives to text files for later processing
## 
## ---------------------

source /home/jhbelle/.profile # You would source your own profile here - the important line is: export PATH=$PATH:/aqua/Jess/CDO/cdo-install/bin

# Define variables
#var=( sp 10u 10v cape cin prate sd hpbl h h vis cape cin r )
#lev=( surface heightAboveGround heightAboveGround surface surface surface surface surface cloudBase cloudTop surface pressureFromGroundLayer pressureFromGroundLayer heightAboveGround )
#var=( prate )
#lev=( surface )
var=( 2t )
lev=( heightAboveGround )
day=2007-01-01
while [ "$day" != 2012-05-01 ]; do
    #echo $day
    year=$(date +%Y -d "$day")
    month=$(date +%m -d "$day")
    day2=$(date +%d -d "$day")
        # Download RUC/RAP data for hours near or during passes over U.S. and write a text file for each variable and hour of each day (PRES:surface, UGRD:10 m, VGRD:10 m, CAPE:surface, CIN:surface,  PRATE:surface;, SNOD:surface, HPBL:surface, HGT:cloud base, HGT:cloud top, VIS:surface, CAPE:255-0 mb, CIN:255-0 mb)
    filein=/aqua/RUC_RAP/$year$month/$year$month$day2/ruc2anl_130_$year$month$day2
    fileout=/aqua/RUC_RAP/Temps/ruc2anl_130_$year$month$day2 
    for ((i=0; i<=0; i++));
    do  
	for hour in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23;
	do
	    filein+=_$hour
	    filein+=00_000.grb2
    	    fileout+=_$hour
	    fileout+=_${var[$i]}_${lev[$i]}.txt
            grib_get_data -m -9999 -p typeOfLevel,shortName -w shortName=${var[$i]},typeOfLevel=${lev[$i]} $filein>$fileout
	    filein=/aqua/RUC_RAP/$year$month/$year$month$day2/ruc2anl_130_$year$month$day2
            fileout=/aqua/RUC_RAP/Temps/ruc2anl_130_$year$month$day2 
	done
    done
    day=$(date -I -d "$day + 1 day")
done


