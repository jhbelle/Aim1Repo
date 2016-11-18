pro ExtrMAIAC, nearFile, collocFile, siteDat, fpath, maiacString
  ; Extracts MAIAC values within pre-calculated radii from station locations using index values
  ; Takes as input 
  ; - nearFile: string: The result of near table operation in arcGIS, followed by table joins using the results of extrlatlonmaiac.pro. Ex. "/aqua/Jess/Data/Near40kmh08v05_2.csv"
  ; - collocFile: string: The full filename and path of the output dataset. Ex. "/aqua/Jess/Data/CalifCollocs_h08v04.csv"
  ; - siteDat: string: The site data containing the EPA station records with dates - currently expected that all sites are in same state. Ex: "/aqua/Jess/Data/CalifG24hr.csv"
  ; - fPath: string: the file path of the MAIAC files, with a folder for each year. Ex: "/terra/MAIAC_Jess/h08v04/"
  ; - maiacString: string: The regex expression for the first part of the maiac files. Ex. "MAIAC[AT]AOT.h08v04."
  ; Open and create text file for data, then close so can reopen as append later when actually needed
  OPENW, 1, collocFile
  PRINTF, 1, "State, County, Site, Juldate, Date, Time, AquaTerraFlag, X24hrPM, AOD47, AOD55, AODQA"
  CLOSE, 1
  ; Read in CalifG24hr.csv
  G24hr = READ_CSV(siteDat, HEADER=G24hrHead)
  ; Get number of rows in file
  sz = size(G24hr.(0))
  ; Read in Near40kmh08v04_2.csv
  Near= READ_CSV(nearFile, HEADER=NearHead)
  ; Loop over rows in CalifG24hr.csv
  FOR I = 0, sz(1)-1 DO BEGIN
    ; Extract date field and calculate the julian day
    CurDate = strsplit(G24hr.(WHERE(G24hrHead EQ "Date"))[I], "-", /EXTRACT)
    Juldate = JULDAY(CurDate[1], CurDate[2], CurDate[0]) - JULDAY(12, 31, CurDate[0]-1)
    ; Identify records in the near table results that are for this station
    Int = cgSetIntersection(WHERE(Near.(WHERE(NearHead EQ "Site")) EQ G24hr.(WHERE(G24hrHead EQ "Site"))[I], countsites), WHERE(Near.(WHERE(NearHead EQ "County")) EQ G24hr.(WHERE(G24hrHead EQ "County"))[I], countcounties), count=Any)
    IF (Any NE 0) AND (countsites NE 0) AND (countcounties NE 0) THEN BEGIN
      ; Get the indexes for the MAIAC file that are within 40 km of this station
      Index = Near.(WHERE(NearHead EQ "index"))[Int]
      ; Get a list of MAIAC files for this day and loop over
      f = FILE_SEARCH(STRING(fPath + CurDate[0] + "/"), STRING(maiacString + CurDate[0] + STRING(FORMAT='(I03)', Juldate) + "*.hdf"))
      FOREACH file, f DO BEGIN
	   ; Open maiac file and extract AOD 47; AOD 55, and the AOD QA field
        FID = EOS_GD_OPEN(file)
        gridID = EOS_GD_ATTACH(FID, "grid1km")
        stat1 = EOS_GD_READFIELD(gridID, "Optical_Depth_047", AOD47)
        stat2 = EOS_GD_READFIELD(gridID, "Optical_Depth_055", AOD55)
        stat3 = EOS_GD_READFIELD(gridID, "AOT_QA", AODQA)
        IF (stat1 EQ 0) AND (stat2 EQ 0) AND (stat3 EQ 0) THEN BEGIN
          ; Get only values that match with this station. Leaving AOD unscaled and the QA codes unconverted to binary
          AOD47 = AOD47[Index]
          AOD55 = AOD55[Index]
          AODQA = AODQA[Index]
          ; Get Time stamp and terra aqua flag fields
          TerraAquaFlag = STRMID(file, 35, 1)
          TStamp = STRMID(file, 54, 4)
          ; Write data to a text file
          OPENU, 2, collocFile, /APPEND
          FOR J = 0, N_ELEMENTS(AODQA)-1 DO BEGIN
            PRINTF, 2, 6, G24hr.(WHERE(G24hrHead EQ "County"))[I], G24hr.(WHERE(G24hrHead EQ "Site"))[I], JulDate, G24hr.(WHERE(G24hrHead EQ "Date"))[I], TStamp, TerraAquaFlag, G24hr.(WHERE(G24hrHead EQ "X24hrPM"))[I], AOD47[J], AOD55[J], AODQA[J], FORMAT='(4(I5, ", "), 3(A15, ", "), D, 3(", ", I5))'
          ENDFOR
          CLOSE, 2
        ENDIF
        ; Close the maiac file
        stat3 = EOS_GD_DETACH(gridID)
        stat4 = EOS_GD_CLOSE(FID)
      ENDFOREACH
    ENDIF
  ENDFOR
end
