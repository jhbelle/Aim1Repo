#!/bin/bash
#$ -N TCldExtrAtl
#matlab -nojvm -nosplash -r "RadialMatch_ExtractCloud"
#Rscript Cloud_Proc.R
matlab -nojvm -nosplash -r "GriddingExtractMODIS10km"
