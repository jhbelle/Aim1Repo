pro ExtrLatLonMAIAC, llgrid, outcsv
  ; A function to extract the lat/lon values from a lat/lon grid associated with MAIAC tiles mapped on the MODIS sinusoidal grid
  ; Takes as input the name and filepath of the lat/long grid and the name and filepath of the csv you would like to output and outputs a csv containing the lat/long values
  ; Usage example: ExtrLatLonMAIAC, '/aura/MAIAC_NA/MAIACLatlon.h00v00.hdf', '/aura/MAIAC_NA/MAIACLatlon.h00v00.csv'
  
  ; make sure file is valid and of the correct type, also get grid name
  ngrids = EOS_GD_INQGRID(llgrid, gridlist)
  if (ngrids > 0) THEN BEGIN
    ; Assign id numbers and open/attach file and grid
    FID = EOS_GD_OPEN(llgrid)
    gridID = EOS_GD_ATTACH(FID, gridlist)
    ; Read lat and lon fields into arrays
    stat1 = EOS_GD_READFIELD(gridID, "lat", lat)
    stat2 = EOS_GD_READFIELD(gridID, "lon", lon)
    ; Detatch and close file and grid
    stat3 = EOS_GD_DETACH(gridID)
    stat4 = EOS_GD_CLOSE(FID)
    ; Reorganize arrays into vectors for lat, lon, row, col, and index
    s = size(lat)
    sz = s[1]*s[2] - 1
    index = INDGEN(s[1]*s[2], /LONG) ; Note - /LONG should be changed to a larger format size for future use - large index values came out truncated and I had to resort to row/column indexes
    rowcol = ARRAY_INDICES(lat, index)
    rows = REFORM(rowcol[0,0:sz])
    cols = REFORM(rowcol[1,0:sz])
    lat2 = lat[index]
    lon2 = lon[index]
    ; Write csv
    WRITE_CSV, outcsv, TRANSPOSE([[index], [rows], [cols], [lat2], [lon2]]), HEADER=["index", "row", "col", "lat", "lon"]
  endif ELSE print, 'No grids in specified file - check filename and type'
end
