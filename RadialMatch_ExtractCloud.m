% -----------------------------
% Name: RadialMatch_ExtractCloud.m
% Program version: Matlab R2015a
% Author: J.H. Belle
% Depends: vdist.m (contains vdist function - user contributed)
% Purpose: Extract Modis cloud data values within a 40 km radius of each EPA station from the 1km cloud product
% -----------------------------

% -----------------------
% Change these parameters!!!!
% -----------------------
Collocsfile = '/aqua/Jess/Data/AtlG24hr.csv';
FPath = '/aqua/MODIS_Cld_Jess/';
OutpFile1km = '/aqua/Jess/Data/Cld1km/';
OutpFile5km = '/aqua/Jess/Data/Cld5km/';
% -----------------------

% Open collocation file
Colloc = fopen(Collocsfile);
formatspec = '%f %f %f %f %f %s %f';
Collocs = textscan(Colloc, formatspec, 'delimiter', ',', 'treatAsEmpty', 'NA', 'HeaderLines', 1);

% Loop over collocations to extract
for i=1:length(Collocs{1})
%for i=1:1
% Pull out needed values to ID this record and find matching MODIS
    % files
    State = Collocs{1}(i);
    County = Collocs{2}(i);
    Site = Collocs{3}(i);
    Date = cellstr(Collocs{6}{i});
    Year = str2num(Date{1}(2:5));
    JulDay = juliandate(datetime(Year, str2num(Date{1}(7:8)), str2num(Date{1}(10:11)))) - juliandate(datetime(Year-1, 12, 31));
    % Open 1 km output file and write header
    Outp1km = fopen(sprintf('%sC%dS%dY%dD%d', OutpFile1km, County, Site, Year, JulDay), 'w');
    Varnames = {'State', 'County', 'Site', 'Date', 'Time', 'Row', 'Col', 'DistStation', 'Multi', 'CloudAOD', 'PCloudAOD', 'CloudRadius', 'CloudWaterPath'};
    formatHeader = '%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s\n';
    fprintf(Outp1km, formatHeader, Varnames{1,:});
    % Open 5km output file and write header
    Outp5km = fopen(sprintf('%sC%dS%dY%dD%d', OutpFile5km, County, Site, Year, JulDay), 'w');
    Varnames = {'State', 'County', 'Site', 'Date', 'Time', 'LatMatch', 'LongMatch', 'DistStation', 'CloudTopHgt', 'CloudFrac', 'CloudPhase', 'CloudTopTemp', ' CloudEmmisivity'};
    formatHeader = '%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s\n';
    fprintf(Outp5km, formatHeader, Varnames{1,:});
    % Get list of MODIS files for this day
    filen1 = dir(sprintf('%sM*D06_L2.A%d%03d.*.hdf', FPath, Year, JulDay));
    for j=1:length(filen1)
        Time = filen1(j).name(19:22);
        fileinfo = hdfinfo(sprintf('%s%s', FPath, filen1(j).name), 'eos');
        swathname = fileinfo.Swath.Name();
        Lat5km=hdfread(fileinfo.Filename, swathname, 'Fields', 'Latitude');
        Long5km=hdfread(fileinfo.Filename, swathname, 'Fields', 'Longitude');
        RefLat = ones(size(Lat5km))*Collocs{4}(i);
        RefLon = ones(size(Long5km))*Collocs{5}(i);
        % Calculate distances from each MODIS midpoint to the EPA station
        % in km
	    if (min(Lat5km) > -900 & min(Long5km) > -900)
            Dists5km = arrayfun(@vdist, Lat5km, Long5km, RefLat, RefLon)/1000;
            % Extract fields of interest from MODIS file
            Multi=hdfread(fileinfo.Filename, swathname, 'Fields', 'Cloud_Multi_Layer_Flag');
            TopHgt=hdfread(fileinfo.Filename, swathname, 'Fields', 'Cloud_Top_Height');
            CloudFrac = hdfread(fileinfo.Filename, swathname, 'Fields', 'Cloud_Fraction');
            CloudAOT = hdfread(fileinfo.Filename, swathname, 'Fields', 'Cloud_Optical_Thickness');
            CloudAOT_PCL = hdfread(fileinfo.Filename, swathname, 'Fields', 'Cloud_Optical_Thickness_PCL');
	        CloudEffRad = hdfread(fileinfo.Filename, swathname, 'Fields', 'Cloud_Effective_Radius');
	        CloudPhase = hdfread(fileinfo.Filename, swathname, 'Fields', 'Cloud_Phase_Infrared');
	        CloudTopTemp = hdfread(fileinfo.Filename, swathname, 'Fields', 'Cloud_Top_Temperature');
	        CloudEmis = hdfread(fileinfo.Filename, swathname, 'Fields', 'Cloud_Effective_Emissivity');
	        CloudWaterPath = hdfread(fileinfo.Filename, swathname, 'Fields', 'Cloud_Water_Path');
            % Make masks for 1km and 5km indexes
            Index5km = find(Dists5km < 40);
            Dists1km = repelem(Dists5km,5,5);
            [row1km, col1km] = find(Dists1km < 40);
            % Write 5 km files
            for k=1:length(Index5km)
                Index = Index5km(k);
                rowfile = {State, County, Site, Date{:}, Time, Lat5km(Index), Long5km(Index), Dists5km(Index), TopHgt(Index), CloudFrac(Index), CloudPhase(Index), CloudTopTemp(Index), CloudEmis(Index)};
                rowform = '%i, %i, %i, %s, %s, %f, %f, %f, %f, %f, %f, %f, %f\n';
                fprintf(Outp5km, rowform, rowfile{1,:});
            end
            for l=1:length(row1km)
                row = row1km(l);
                col = col1km(l);
                rowfile = {State, County, Site, Date{:}, Time, row, col, Dists1km(row, col), Multi(row,col), CloudAOT(row,col), CloudAOT_PCL(row,col), CloudEffRad(row,col), CloudWaterPath(row,col)};
                rowform = '%i, %i, %i, %s, %s, %i, %i, %f, %f, %f, %f, %f, %f\n';
                fprintf(Outp1km, rowform, rowfile{1,:});
            end
        end
    end;
    fclose(Outp1km);
    fclose(Outp5km);
end;


