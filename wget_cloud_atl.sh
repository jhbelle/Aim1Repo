#!/bin/bash
cd /liu_group/remotesensing1/MODIS_Cloud/AtlantaArea

wget -nd --tries=45 ftp://ladsweb.nascom.nasa.gov/orders/501022391/MOD06_L2.*
wget -nd --tries=45 ftp://ladsweb.nascom.nasa.gov/orders/501022392/MOD06_L2.*
