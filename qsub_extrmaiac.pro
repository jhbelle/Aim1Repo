
;cd, "T:\eohprojs\CDC_climatechange\Jess\Dissertation\Aim1Repo"
;extrmaiac, "T:/eohprojs/CDC_climatechange/MAIACdat/Near40kmh01v04_2.csv", "T:/eohprojs/CDC_climatechange/MAIACdat/CalifCollocs/", "T:/eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24hr.csv", "T:/eohprojs/CDC_climatechange/MAIACdat/", "MAIAC[AT]AOT.h01v04.", 49, 68

; New submission - 2010-2011 file
;extrmaiac, "T:/eohprojs/CDC_climatechange/MAIACdat/Near40kmh01v04_2.csv", "C:/Jess_output/", "T:/eohprojs/CDC_climatechange/Jess/Dissertation/EPAcleaned/CalifG24hr_2010_2011.csv", "T:/eohprojs/CDC_climatechange/MAIACdat/", "MAIAC[AT]AOT.h01v04.", 49, 68

; New submission - all years processing on cluster
;cd, "/home/jhbelle/Aim1Repo/"
;extrmaiac, "/aqua/Jess/Data/Near40kmh01v04_2.csv", "/terra/CalifCollocs_MAIACJess/", "/aqua/Jess/Data/CalifG24hr.csv", "/terra/MAIACdat/", "MAIAC[AT]AOT.h01v04.", 26, 45

; New submission - Atlanta
;extrmaiac, "/aqua/Jess/Data/Near40kmh04v04.csv", "/gc_runs/AtlCollocs_MAIACh04v04/", "/aqua/Jess/Data/AtlG24hr.csv", "/terra/MAIAC_h04v04/", "MAIAC[AT]AOT.h04v04.", 30, 49 

;extrmaiac, "/aqua/Jess/Data/Near40kmh04v05.csv", "/gc_runs/AtlCollocs_MAIACh04v05/", "/aqua/Jess/Data/AtlG24hr.csv", "/terra/MAIAC_h04v05/", "MAIAC[AT]AOT.h04v05.", 30, 49 

;procMAIAC, '/home/jhbelle/Data/SFGridFin/FinGridJoined.csv', 2012, 1, 366, '/terra/MAIACdat/2012/', '/aura/MAIACoutputs_GriddedSummed/A2012/', 'MAIACAAOT.h01v04.', 26, 45

;procMAIAC, '/home/jhbelle/Data/SFGridFin/FinGridJoined.csv', 2013, 1, 365, '/terra/MAIACdat/2013/', '/aura/MAIACoutputs_GriddedSummed/A2013/', 'MAIACAAOT.h01v04.', 26, 45

;procMAIAC, '/home/jhbelle/Data/SFGridFin/FinGridJoined.csv', 2014, 1, 365, '/terra/MAIACdat/2014/', '/aura/MAIACoutputs_GriddedSummed/A2014/', 'MAIACAAOT.h01v04.', 26, 45

;procMAIAC, '/home/jhbelle/Data/SFGridFin/FinGridJoined.csv', 2012, 1, 366, '/terra/MAIACdat/2012/', '/aura/MAIACoutputs_GriddedSummed/T2012/', 'MAIACTAOT.h01v04.', 26, 45

;procMAIAC, '/home/jhbelle/Data/SFGridFin/FinGridJoined.csv', 2013, 1, 365, '/terra/MAIACdat/2013/', '/aura/MAIACoutputs_GriddedSummed/T2013/', 'MAIACTAOT.h01v04.', 26, 45

;procMAIAC, '/home/jhbelle/Data/SFGridFin/FinGridJoined.csv', 2014, 1, 365, '/terra/MAIACdat/2014/', '/aura/MAIACoutputs_GriddedSummed/T2014/', 'MAIACTAOT.h01v04.', 26, 45

;procMAIAC, '/home/jhbelle/Data/FinalCopy_AtlPolys/FinGridJoined2_h04v04.csv', 2012, 1, 2, '/home/jhbelle/Data/Transfer_MAIAC/', '/home/jhbelle/Data/Transfer_MAIAC/', 'MAIACAAOT.h04v04.', 26,59 

procMAIAC, '/home/jhbelle/Data/FinalCopy_AtlPolys/FinGridJoined2_h04v05.csv', 2012, 1, 2, '/home/jhbelle/Data/Transfer_MAIAC/', '/home/jhbelle/Data/Transfer_MAIAC/', 'MAIACAAOT.h04v05.', 26, 59
