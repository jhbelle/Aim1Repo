#!/bin/bash
#$ -N CldAggAtl
#matlab -nojvm -nosplash -r "RadialMatch_ExtractCloud"
Rscript Cloud_Proc.R
#matlab -nojvm -nosplash -r "GriddingExtractMODIS5km"
