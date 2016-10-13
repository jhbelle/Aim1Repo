pro ExtrLatLonMAIAC, llgrid, outcsv
  ; make sure file is valid and of the correct type, also get grid name
  ngrids = EOS_GD_INQGRID(llgrid, gridlist)
  if (ngrids > 0) THEN BEGIN
    ; Assign id numbers and open/attach file and grid
    FID = EOS_GD_OPEN(llgrid)
    gridID = EOS_GD_ATTACH(FID, gridlist)
    ; Read lat and lon fields into arrays
    EOS_GD_READFIELD(gridID, "lat", lat)
    EOS_GD_READFIELD(gridID, "lon", lon)
    ; Detatch and close file and grid
    EOS_GD_DETACH(gridID)
    EOS_GD_CLOSE(FID)
    ; Reorganize arrays into vectors for lat, lon, row, col, and index
    s = size(lat)
    sz = s[1]*s[2] - 1
    index = INDGEN(s[1]*s[2], /LONG)
    rowcol = ARRAY_INDICES(lat, index)
    rows = REFORM(rowcol[0,0:sz])
    cols = REFORM(rowcol[1,0:sz])
    lat2 = lat[index]
    lon2 = lon[index]
    ; Write csv - not tested: 10/13/2016
    WRITE_CSV, outcsv, index, rows, cols, lat2, lon2, HEADER="index, row, col, lat, lon"
  endif ELSE print, 'No grids in specified file - check filename and type'
end