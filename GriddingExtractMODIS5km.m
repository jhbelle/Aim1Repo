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
yr = 2012;
IPath = '/aqua/MODIS_Cld_Jess/';
Opath ='/aqua/MODIS_Cld_Jess/Extractions_1km_Aqua/';

%yr = 2011; %- pass in through command line for each submission
% -----------------------
% Create cell array containing bounding coordinates for each section -
% arraged w/ one cell per section, each cell a list of (N, W, E, S)
% bounding coordinates in lat/long


% Cycle through each day in year, and get list of files for each
for day=1:5
    filelist = dir(sprintf('%sMYD06_L2.A%u%03d.*.hdf', IPath, yr, day));
    % Initialize output structure for section data
    Varnames = {'MaskVal', 'CloudEffRad', 'CloudAOD', 'CloudWaterPath', 'hr', 'min'};
    SectionCell = cell(1,1);
    for f=1:length(filelist)
        % Open each file in list and read in data
        filen = strcat(IPath, filelist(f).name);
        Hr = str2num(filelist(f).name(19:20));
        Min = str2num(filelist(f).name(21:22));
        fileinfo=hdfinfo(filen, 'eos');
        swathname = fileinfo.Swath.Name();
        CldEffRad = hdfread(filen, swathname, 'Fields', 'Cloud_Effective_Radius');
        CldAOD = hdfread(filen, swathname, 'Fields', 'Cloud_Optical_Thickness');
        CldWatPath = hdfread(filen, swathname, 'Fields', 'Cloud_Water_Path');
        for section=1:1
            [l,w] = size(CldEffRad);
            Mask = transpose(1:(l*w));
            CER = CldEffRad(Mask);
            CA = CldAOD(Mask);
            CWP = CldWatPath(Mask);
            HrS = ones(length(Mask),1).*Hr;
            MinS = ones(length(Mask),1).*Min;
            Sectiontable = table(Mask, CER, CA, CWP, HrS, MinS, 'VariableNames', Varnames);
            SectionCell{1,section} = [SectionCell{1,section};Sectiontable];
        end;  
    end;
    for section=1:1
        writetable(SectionCell{1,section}, sprintf('%sExtr_%i_%03d_S%i_A.csv', Opath, yr, day, section))
    end;  
end;

