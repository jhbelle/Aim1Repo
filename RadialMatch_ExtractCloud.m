% -----------------------------
% Name: RadialMatch_Extract10km_2011.m
% Date Created: 6/15/14
% Program version: Matlab R2014a
% Author: J.H. Belle
% Depends: vdist.m (contains vdist function - user contributed)
% Purpose: Extract Modis data values within a 27.5 km radius of the station - following Petrenko et. al. 2012,
% from the 10km aerosol product
%     Note: Also extracting the bounding box coordinates for each pixel -
%     this will make it possible to match up other site parameters (land 
%     use, landscape complexity, and NDVI) while accounting for 
%     changes in pixel area over time
% -----------------------------

% -----------------------
% Change these parameters!!!!
% -----------------------
Collocsfile = '/liu_group/remotesensing1/Jess/Data/MODIScollocs11.csv';
Year = 2011;
FPath = '/liu_group/remotesensing3/MODIS_Jess/ladsweb.nascom.nasa.gov/orders/500832418/';
OutpFile = '/liu_group/remotesensing1/Jess/Data/MODISExRadMatch_2011.csv';
% -----------------------


% Import datafile with list of MODIS granules for each site
Collocs11 = fopen(Collocsfile);
formatspec = '%s %f %f %u %s %s %f %f %f %f';
Collocs = textscan(Collocs11, formatspec, 'delimiter', ',', 'treatAsEmpty', 'NA', 'HeaderLines', 1);
% Calculate the total number of granules in this file
NumGrans = length(Collocs{7})*4 - (sum(isnan(Collocs{7})) + sum(isnan(Collocs{8})) + sum(isnan(Collocs{9})) + sum(isnan(Collocs{10})));
Outp = fopen(OutpFile, 'w');
Varnames = {'AeroLoc', 'JulianDate', 'Passtime', 'LatMatch', 'LongMatch', 'DistStation', 'AODdt', 'AODdb', 'AODb', 'AeroType', 'QAdt', 'QAdb', 'QAb', 'UpL_Lat', 'UpL_Long', 'UpR_Lat', 'UpR_Long', 'DL_Lat', 'DL_Long', 'DR_Lat', 'DR_Long'};
formatHeader = '%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s\n';
fprintf(Outp, formatHeader, Varnames{1,:});

RowOut = 1;
for i=1:length(Collocs{1})
    Granshere = 4 - (sum(isnan(Collocs{7}(i))) + sum(isnan(Collocs{8}(i))) + sum(isnan(Collocs{9}(i))) + sum(isnan(Collocs{10}(i))));
    for j=1:Granshere
        AeroLoc = cellstr(Collocs{1}{i});
        JulDay = sprintf('%03d', Collocs{4}(i));
        Grantime = sprintf('%04d', Collocs{6+j}(i));
        filen1 = dir(sprintf('%sMYD04_L2.A%u%s.%s.006.*.hdf', FPath, Year, JulDay, Grantime));
        filen = strcat(FPath, filen1.name);
        if length(filen1) == 1
            fileinfo=hdfinfo(filen, 'eos');
            swathname = fileinfo.Swath.Name();

            Lat=hdfread(filen, swathname, 'Fields', 'Latitude');
            Long=hdfread(filen, swathname, 'Fields', 'Longitude');
            RefLat = ones(size(Lat))*Collocs{2}(i);
            RefLon = ones(size(Long))*Collocs{3}(i);
            Dists = arrayfun(@vdist, Lat, Long, RefLat, RefLon);
            Mask = find(Dists/1000 < 27.5);
            NumPix = length(Mask)
            AODdt=hdfread(filen, swathname, 'Fields', 'Image_Optical_Depth_Land_And_Ocean');
            AODdb=hdfread(filen, swathname, 'Fields', 'Deep_Blue_Aerosol_Optical_Depth_550_Land');
            AODb = hdfread(filen, swathname, 'Fields', 'AOD_550_Dark_Target_Deep_Blue_Combined');
            AeroType = hdfread(filen, swathname, 'Fields', 'Aerosol_Type_Land');
            QAdt = hdfread(filen, swathname, 'Fields', 'Land_Ocean_Quality_Flag');
            QAdb = hdfread(filen, swathname, 'Fields', 'Deep_Blue_Aerosol_Optical_Depth_550_Land_QA_Flag');
            QAb = hdfread(filen, swathname, 'Fields', 'AOD_550_Dark_Target_Deep_Blue_Combined_QA_Flag');
            
            for k=1:NumPix
                Index = Mask(k);
                [row, col] = ind2sub(size(Lat), Index);
                [Trows, Tcols] = size(Lat);
                if (row < Trows)&& (row > 1) && (col < Tcols) && (col > 1) 
                    UpL_Lat = (Lat(row-1, col) + Lat(row, col-1))/2;
                    UpL_Long = (Long(row-1, col) + Long(row, col-1))/2;
                    UpR_Lat = (Lat(row-1, col) + Lat(row, col+1))/2;
                    UpR_Long = (Long(row-1, col) + Long(row, col+1))/2;
                    DL_Lat = (Lat(row+1, col) + Lat(row, col-1))/2;
                    DL_Long = (Long(row+1, col) + Long(row, col-1))/2;
                    DR_Lat = (Lat(row+1, col) + Lat(row, col+1))/2;
                    DR_Long = (Long(row+1, col) + Long(row, col+1))/2;
                elseif (row == Trows) && (col < Tcols) && (col > 1)
                    UpL_Lat = (Lat(row-1, col) + Lat(row, col-1))/2;
                    UpL_Long = (Long(row-1, col) + Long(row, col-1))/2;
                    UpR_Lat = (Lat(row-1, col) + Lat(row, col+1))/2;
                    UpR_Long = (Long(row-1, col) + Long(row, col+1))/2;
                    DR_Lat = Lat(row, col) + (Lat(row, col) - UpL_Lat);
                    DR_Long = Long(row, col) + (Long(row, col) - UpL_Long);
                    DL_Lat = Lat(row, col) + (Lat(row, col) - UpR_Lat);
                    DL_Long = Long(row, col) + (Long(row, col) - UpR_Long);
                elseif (row == 1) && (col < Tcols) && (col > 1)
                    DL_Lat = (Lat(row+1, col) + Lat(row, col-1))/2;
                    DL_Long = (Long(row+1, col) + Long(row, col-1))/2;
                    DR_Lat = (Lat(row+1, col) + Lat(row, col+1))/2;
                    DR_Long = (Long(row+1, col) + Long(row, col+1))/2;
                    UpL_Lat = Lat(row, col) + (Lat(row, col) - DR_Lat);
                    UpL_Long = Long(row, col) + (Long(row, col) - DR_Long);
                    UpR_Lat = Lat(row, col) + (Lat(row, col) - DL_Lat);
                    UpR_Long = Long(row, col) + (Long(row, col) - DL_Long);
                elseif (col == Tcols) && (row > 1) && (row < Trows)
                    UpL_Lat = (Lat(row-1, col) + Lat(row, col-1))/2;
                    UpL_Long = (Long(row-1, col) + Long(row, col-1))/2;
                    DL_Lat = (Lat(row+1, col) + Lat(row, col-1))/2;
                    DL_Long = (Long(row+1, col) + Long(row, col-1))/2;
                    UpR_Lat = Lat(row, col) + (Lat(row, col) - DL_Lat);
                    UpR_Long = Long(row, col) + (Long(row, col) - DL_Long);
                    DR_Lat = Lat(row, col) + (Lat(row, col) - UpL_Lat);
                    DR_Long = Long(row, col) + (Long(row, col) - UpL_Long);
                elseif (col == 1) && (row > 1) && (row < Trows)
                    UpR_Lat = (Lat(row-1, col) + Lat(row, col+1))/2;
                    UpR_Long = (Long(row-1, col) + Long(row, col+1))/2;
                    DR_Lat = (Lat(row+1, col) + Lat(row, col+1))/2;
                    DR_Long = (Long(row+1, col) + Long(row, col+1))/2;
                    UpL_Lat = Lat(row, col) + (Lat(row, col) - DR_Lat);
                    UpL_Long = Long(row, col) + (Long(row, col) - DR_Long);
                    DL_Lat = Lat(row, col) + (Lat(row, col) - UpR_Lat);
                    DL_Long = Long(row, col) + (Long(row, col) - UpR_Long);
                else
                    UpL_Lat = NaN;
                    UpL_Long = NaN;
                    UpR_Lat = NaN;
                    UpR_Long = NaN;
                    DL_Lat = NaN;
                    DL_Long = NaN;
                    DR_Lat = NaN;
                    DR_Long = NaN;
                end
                DistStation = Dists(Index);
                LongMatchO = Long(Index);
                LatMatchO = Lat(Index);
                AODdtO = AODdt(Index);
                AODdbO = AODdb(Index);
                AODbO = AODb(Index);
                AeroTypeO = AeroType(Index);
                QAdtO = QAdt(Index);
                QAdbO = QAdb(Index);
                QAbO = QAb(Index);
                rowfile = {AeroLoc{:}, JulDay, Grantime, LatMatchO, LongMatchO, DistStation, AODdtO, AODdbO, AODbO, AeroTypeO, QAdtO, QAdbO, QAbO, UpL_Lat, UpL_Long, UpR_Lat, UpR_Long, DL_Lat, DL_Long, DR_Lat, DR_Long};
                rowform = '%s, %s, %s, %f, %f, %f, %i, %i, %i, %i, %i, %i, %i, %f, %f, %f, %f, %f, %f, %f, %f\n';
                fprintf(Outp, rowform, rowfile{1,:});
            end
        else
            rowfile = {AeroLoc{:}, JulDay, Grantime, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN};
            rowform = '%s, %s, %s, %f, %f, %f, %i, %i, %i, %i, %i, %i, %i, %f, %f, %f, %f, %f, %f, %f, %f\n';
            fprintf(Outp, rowform, rowfile{1,:});
        end
        RowOut = RowOut + 1;
    end;
end;
fclose(Outp);


