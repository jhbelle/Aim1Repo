#!/bin/bash

## ---------------------
## Name: Retr_RUC.sh
## Program version: grib_api; bash
## Author: J.H. Belle
## Purpose: Download, subset, and save the RUC/RAP archives over times/places with MODIS and/or MISR overpasses
## ---------------------

day=2002-05-01
while [ "$day" != 2016-01-01 ]; do
    echo $day
    year=$(date +%Y -d "$day")
    dlurl=
        # Download RUC/RAP data for hours near or during passes over U.S. and write a text file for each variable and hour of each day (PRES:surface, UGRD:10 m, VGRD:10 m, CAPE:surface, CIN:surface,  PRATE:surface;, SNOD:surface, HPBL:surface, HGT:cloud base, HGT:cloud top, VIS:surface, CAPE:255-0 mb, CIN:255-0 mb) 
    for var in     
        grib_get_data -w shortname=$var $filein>$fileout

    fi
    day=$(date -I -d "$day + 1 day")
done


