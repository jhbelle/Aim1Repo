% -----------------------------
% Name: RadialMatch_Extract10km_2011.m
% Date Created: 6/15/14
% Program version: Matlab R2014a
% Author: J.H. Belle
% Depends: 
% Purpose: Extract Lat/Long, AOD and QA values for gridding to CMAQ grid.
%   - Note, this script is designed to split the output files into 9
%   section files for each day. To do this each output file will need to be
%   opened as append and points put into each section accordingly -
%   sections overlap
% -----------------------------

% -----------------------
% Change these parameters!!!!
% -----------------------
yr = 2014
IPath = '/gc_runs/MYD03_Calif/';
Opath ='/gc_runs/MYD03_Calif/Extractions_Aqua_STop2/';

%yr = 2011; %- pass in through command line for each submission
% -----------------------
% Create cell array containing bounding coordinates for each section -
% arraged w/ one cell per section, each cell a list of (N, W, E, S)
% bounding coordinates in lat/long
SectionCoors = {[40.1, -121.4, -119.8, 38.5]};

% Cycle through each day in year, and get list of files for each
for day=100:365
    filelist = dir(sprintf('%sMYD03.A%u%03d.*.hdf', IPath, yr, day))
    % Initialize output structure for section data
    Varnames = {'Lat', 'Long', 'SensorZenith', 'SolarZenith', 'Index', 'hr', 'min'};
    SectionCell = cell(1,1);
    for f=1:length(filelist)
        % Open each file in list and read in data
        filen = strcat(IPath, filelist(f).name);
        Hr = str2num(filelist(f).name(16:17));
        Min = str2num(filelist(f).name(18:19));
        fileinfo=hdfinfo(filen, 'eos');
        swathname = fileinfo.Swath.Name();
        Lat=hdfread(filen, swathname, 'Fields', 'Latitude');
        Long=hdfread(filen, swathname, 'Fields', 'Longitude');
        SenZen = hdfread(filen, swathname, 'Fields', 'SensorZenith');
        SolZen = hdfread(filen, swathname, 'Fields', 'SolarZenith');
        for section=1:1
            Coords = SectionCoors{section};
            Long1 = Long>=Coords(2);
            Long2 = Long<=Coords(3);
            LongMask = Long1.*Long2;
            Lat1 = Lat>=Coords(4);
            Lat2 = Lat<=Coords(1);
            LatMask = Lat1.*Lat2;
            Mask = find(int16(LongMask.*LatMask));
	    SenZ = SenZen(Mask);
	    SolZ = SolZen(Mask); 
            LatPt = Lat(Mask);
            LongPt = Long(Mask);
            HrS = ones(length(Mask),1).*Hr;
            MinS = ones(length(Mask),1).*Min;
            Sectiontable = table(LatPt, LongPt, SenZ, SolZ, Mask, HrS, MinS, 'VariableNames', Varnames);
            SectionCell{1,section} = [SectionCell{1,section};Sectiontable];
        end;  
    end;
    for section=1:1
        writetable(SectionCell{1,section}, sprintf('%sExtr_%i_%03d_S%i.csv', Opath, yr, day, section))
    end;  
end;

