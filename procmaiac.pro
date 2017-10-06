pro procMaiac, FinGridJoined, yrint, startday, endday, fileloc, outloc, maiacString, LocTAFlag, LocTStamp
  ; Takes as input the bounding coordinates for the study area, the year and days of interest, and the file input and output locations
  ; Produces a csv for each day containing all maiac data within the bounding box
  ; Open FinGridJoined with information needed later
  Dat = READ_CSV(FinGridJoined, HEADER=DatHead)
  Index=Dat.(WHERE(DatHead EQ 'index'))
  ; Create list of days to loop over
  FOR day = startday, endday DO BEGIN
    f = FILE_SEARCH(STRING(fileloc + maiacString + STRING(FORMAT='(I04)', yrint) + STRING(FORMAT='(I03)', day) + "*.hdf"))
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
        TerraAquaFlag = STRMID(file, LocTAFlag, 1)
        TStamp = STRMID(file, LocTStamp, 4)
	; Open file to append to later
  	OPENW, 1, outloc + 'MAIACdat_' + STRING(FORMAT='(I04)', yrint) + STRING(FORMAT='(I03)', day) + '_' + TStamp + '.csv'
  	PRINTF, 1, "InputFID, index, lat, lon, POINT_X, POINT_Y, PercForest, PRoadLength, RUCLat, RUCLon, NEIPM, Elev, Year, Date, Timestamp, Overpass, AOD47, AOD55, QA"
        FOR J = 0, N_ELEMENTS(AODQA)-1 DO BEGIN
          PRINTF, 1, Dat.(WHERE(DatHead EQ "InputFID"))[J], Dat.(WHERE(DatHead EQ "index"))[J], Dat.(WHERE(DatHead EQ "lat"))[J], Dat.(WHERE(DatHead EQ "lon"))[J], Dat.(WHERE(DatHead EQ "POINT_X"))[J], Dat.(WHERE(DatHead EQ "POINT_Y"))[J], Dat.(WHERE(DatHead EQ "PForst"))[J], Dat.(WHERE(DatHead EQ "RdLen"))[J], Dat.(WHERE(DatHead EQ "RUCLat"))[J], Dat.(WHERE(DatHead EQ "RUCLon"))[J], Dat.(WHERE(DatHead EQ "NEIPM"))[J], Dat.(WHERE(DatHead EQ "Elev"))[J], yrint, day, TStamp, TerraAquaFlag, AOD47[J], AOD55[J], AODQA[J], FORMAT='(I10, 11(", ", D), 2(", ", I5), 2(", ", A15), 3(", ", I15))'
        ENDFOR
        CLOSE, 1
      ENDIF
      ; Close the maiac file
      stat3 = EOS_GD_DETACH(gridID)
      stat4 = EOS_GD_CLOSE(FID)
    ENDFOREACH
  ENDFOR
end
