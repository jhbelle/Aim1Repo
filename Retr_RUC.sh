#!/bin/bash

## ---------------------
## Name: Retr_RUC.sh
## Program version: CDO ; bash
## Author: J.H. Belle
## Purpose: Download, subset, and save the RUC/RAP archives over times/places with MODIS and/or MISR overpasses
## ---------------------

day=2002-05-01
while [ "$day" != 2016-01-01 ]; do
    echo $day
    year=$(date +%Y -d "$day")
    if [ -f /aqua/MODIS_GeoMeta/TERRA/$year/MOD03_$day.txt ]
    then
        # Read in MODIS geoMeta data file - TERRA
        
        # Pull out list of granules taken during the day and over the CONUS (-130 W; -75 E; 45 N; 20 S)

        # Download RUC/RAP data for hours near or during passes over U.S. and compile into a single netcdf for day (PRES:surface, UGRD:10 m, VGRD:10 m, CAPE:surface, CIN:surface,  PRATE:surface;, SNOD:surface, HPBL:surface, HGT:cloud base, HGT:cloud top, VIS:surface, CAPE:255-0 mb, CIN:255-0 mb) 
        
        # Save file

    fi
    day=$(date -I -d "$day + 1 day")
done


