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
yr = 2014;
IPath = 'E://MODIScloud_Jess/';
Opath ='E://MODIScloud_extr/';

%yr = 2011; %- pass in through command line for each submission
% -----------------------
% Create cell array containing bounding coordinates for each section -
% arraged w/ one cell per section, each cell a list of (N, W, E, S)
% bounding coordinates in lat/long
SectionCoors = {[40.1, -122.6, -119.9, 37.0]};

% Cycle through each day in year, and get list of files for each
for day=1:100
    filelist = dir(sprintf('%sMOD06_L2.A%u%03d.*.hdf', IPath, yr, day));
    % Initialize output structure for section data
    Varnames = {'Lat', 'Long', 'CloudTopHgt', 'CloudFrac', 'CloudPhase', 'CloudTopTemp', 'CloudEmiss', 'hr', 'min'};
    SectionCell = cell(1,1);
    for f=1:length(filelist)
        % Open each file in list and read in data
        filen = strcat(IPath, filelist(f).name);
        Hr = str2num(filelist(f).name(19:20));
        Min = str2num(filelist(f).name(21:22));
        fileinfo=hdfinfo(filen, 'eos');
        swathname = fileinfo.Swath.Name();
        Lat=hdfread(filen, swathname, 'Fields', 'Latitude');
        Long=hdfread(filen, swathname, 'Fields', 'Longitude');
        CldTopHgt = hdfread(filen, swathname, 'Fields', 'Cloud_Top_Height');
        CldFrac = hdfread(filen, swathname, 'Fields', 'Cloud_Fraction');
        CldPhase = hdfread(filen, swathname, 'Fields', 'Cloud_Phase_Infrared');
        CldTopTemp = hdfread(filen, swathname, 'Fields', 'Cloud_Top_Temperature');
        CldEmis = hdfread(filen, swathname, 'Fields', 'Cloud_Effective_Emissivity');
        for section=1:1
            Coords = SectionCoors{section};
            Long1 = Long>=Coords(2);
            Long2 = Long<=Coords(3);
            LongMask = Long1.*Long2;
            Lat1 = Lat>=Coords(4);
            Lat2 = Lat<=Coords(1);
            LatMask = Lat1.*Lat2;
            Mask = find(int16(LongMask.*LatMask));
	    CTH = CldTopHgt(Mask);
	    CF = CldFrac(Mask);
	    CP = CldPhase(Mask);
	    CTT = CldTopTemp(Mask);
	    CE = CldEmis(Mask); 
            LatPt = Lat(Mask);
            LongPt = Long(Mask);
            HrS = ones(length(Mask),1).*Hr;
            MinS = ones(length(Mask),1).*Min;
            Sectiontable = table(LatPt, LongPt, CTH, CF, CP, CTT, CE, HrS, MinS, 'VariableNames', Varnames);
            SectionCell{1,section} = [SectionCell{1,section};Sectiontable];
        end;  
    end;
    for section=1:1
        writetable(SectionCell{1,section}, sprintf('%sExtr_%i_%03d_S%i_T.csv', Opath, yr, day, section))
    end;  
end;

