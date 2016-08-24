#!/bin/bash
wget -nd -r --tries=45 "ftp://sidads.colorado.edu/DATASETS/NOAA/G02158/masked/200*"
wget -nd -r --tries=45 "ftp://sidads.colorado.edu/DATASETS/NOAA/G02158/masked/201[0123]"
