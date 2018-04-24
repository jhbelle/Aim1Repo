#!/bin/bash

# Atlanta
#$for tile in "n34w086" "n34w085" "n33w086" "n33w085" "n34w084" "n34w083" "n33w084" "n33w083" "n35w086" "n35w085" "n35w084" "n35w083" "n32w084" "n32w083" "n32w086" "n32w085" "n34w087" "n33w087" "n35w087" "n34w082" "n33w082" "n35w082" "n32w087" "n32w082"
#do	
  #wget -nd --tries=45 https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/13/ArcGrid/$tile.zip
#  mkdir $tile
#  unzip $tile.zip -d $tile
#done

# California
mkdir CaliforniaNED
cd CaliforniaNED
for tile in "n37w119" "n37w120" "n37w121" "n37w122" "n38w119" "n38w120" "n38w121" "n38w122" "n39w119" "n39w120" "n39w121" "n39w122" "n40w119" "n40w120" "n40w121" "n40w122" "n41w119" "n41w120" "n41w121" "n41w122"
do	
  wget -nd --tries=45 https://prd-tnm.s3.amazonaws.com/StagedProducts/Elevation/13/ArcGrid/$tile.zip
  mkdir $tile
  unzip $tile.zip -d $tile
done

