pro ExtrMAIAC
  ; Extracts MAIAC values within pre-calculated radii from station locations using index values
  ; Read in CalifG24hr.csv
  CalifG24hr = READ_CSV("/aqua/Jess/Data/CalifG24hr.csv", HEADER=CalifG24hrHead)
  ; Get number of rows in file
  sz = size(CalifG24hr.(0))
  ; Read in Near40kmh08v04_2.csv
  Near40kmh08v04 = READ_CSV("/aqua/Jess/Data/Near40kmh08v04_2.csv", HEADER=Nearh08v04Head)
  ; Read in Near40kmh08v05_2.csv
  Near40kmh08v05 = READ_CSV("/aqua/Jess/Data/Near40kmh08v05_2.csv", HEADER=Nearh08v05Head)
  ; Loop over rows in CalifG24hr.csv
  FOR I = 0, sz(1)-1 DO BEGIN
    ; Extract date field and calculate the julian day
    CurDate = strsplit(CalifG24hr.(WHERE(CalifG24hrHead EQ "Date"))[I], "-", /EXTRACT)
    Juldate = JULDAY(CurDate[1], CurDate[2], CurDate[0]) - JULDAY(12, 31, CurDate[0]-1)
    ; Identify records in the near table results that are for this station
    Inth08v04 = cgSetIntersection(WHERE(Near40kmh08v04.(WHERE(Nearh08v04Head EQ "Site")) EQ CalifG24hr.(WHERE(CalifG24hrHead EQ "Site"))[I], countsites), WHERE(Near40kmh08v04.(WHERE(Nearh08v04Head EQ "County")) EQ CalifG24hr.(WHERE(CalifG24hrHead EQ "County"))[I], countcounties), count=Anyh08v04)
    IF (Anyh08v04 NE 0) AND (countsites NE 0) AND (countcounties NE 0) THEN BEGIN
      ; Get the indexes for the MAIAC file that are within 40 km of this station
      Indexh08v04 = Near40kmh08v04.(WHERE(Nearh08v04Head EQ "index"))[Inth08v04]
      ; Get a list of MAIAC files for this day and loop over
      fh08v04 = FILE_SEARCH(STRING("/terra/MAIAC_Jess/h08v04/" + CurDate[0] + "/"), STRING("MAIAC[AT]AOT.h08v04." + CurDate[0] + STRING(FORMAT='(I03)', Juldate) + "*.hdf"))
      FOREACH file, fh08v04 DO BEGIN
	; Open maiac file and extract AOD 47; AOD 55, and the AOD QA field
        FID = EOS_GD_OPEN(file)
        gridID = EOS_GD_ATTACH(FID, "grid1km")
        stat1 = EOS_GD_READFIELD(gridID, "Optical_Depth_047", AOD47v04)
        stat2 = EOS_GD_READFIELD(gridID, "Optical_Depth_055", AOD55v04)
        stat3 = EOS_GD_READFIELD(gridID, "AOT_QA", AODQAv04)
        IF (stat1 EQ 0) AND (stat2 EQ 0) AND (stat3 EQ 0) THEN BEGIN
          ; Get only values that match with this station
          AOD47v04 = AOD47v04[Indexh08v04]
          AOD55v04 = AOD55v04[Indexh08v04]
          AODQAv04 = AODQAv04[Indexh08v04]
          TimeStampv04 = STRMID(file, 54, 4)
        ENDIF
      ENDFOREACH
    ENDIF
    ; Repeat above for the h08v05 tiles
    Inth08v05 = cgSetIntersection(WHERE(Near40kmh08v05.(WHERE(Nearh08v05Head EQ "Site")) EQ CalifG24hr.(WHERE(CalifG24hrHead EQ "Site"))[I], countsites2), WHERE(Near40kmh08v05.(WHERE(Nearh08v05Head EQ "County")) EQ CalifG24hr.(WHERE(CalifG24hrHead EQ "County"))[I], countcounties2), count=Anyh08v05)
    IF (Anyh08v05 NE 0) AND (countsites2 NE 0) AND (countcounties2 NE 0) THEN BEGIN
      Indexh08v05 = Near40kmh08v05.(WHERE(Nearh08v05Head EQ "index"))[Inth08v05]
      fh08v05 = FILE_SEARCH(STRING("/terra/MAIAC_Jess/h08v05/" + CurDate[0] + "/"), STRING("MAIAC[AT]AOT.h08v05." + CurDate[0] + STRING(FORMAT='(I03)', Juldate) + "*.hdf"))
      FOREACH, file2, fh08v05 DO BEGIN
        FID = EOS_GD_OPEN(file2)
        gridID = EOS_GD_ATTACH(FID, "grid1km")
        stat1 = EOS_GD_READFIELD(gridID, "Optical_Depth_047", AOD47v05)
        stat2 = EOS_GD_READFIELD(gridID, "Optical_Depth_055", AOD55v05)
        stat3 = EOS_GD_READFIELD(gridID, "AOT_QA", AODQAv05)
        IF (stat1 EQ 0) AND (stat2 EQ 0) AND (stat3 EQ 0) THEN BEGIN
          AOD47v05 = AOD47v05[Indexh08v05]
          AOD55v05 = AOD55v05[Indexh08v05]
          AODQAv05 = AODQAv05[Indexh08v05]
          TimeStampv05 = STRMID(file, 54, 4)
        ENDIF
      ENDFOREACH
    ENDIF
  ENDFOR
end
