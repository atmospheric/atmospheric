function d = load(filenames,fieldsToLoad)
%LOAD Loads Amdar files by name.
%
%SYNTAX: 
%  data = Amdar.load(filenames, fieldsToLoad)
%  data = Amdar.load(filenames)
%
%INPUT:
%  filenames    - Cell array of files to be loaded.
%  fieldsToLoad - (Optional) Cell array of field names to load.
%
%OUTPUT:
%  d - Data structure containing requested fields, combined into a single
%        array containing file info across all files.  
%
%NOTES: 
%  Amdar data is stored in netcdf file format.
%
%  Previous code used the njTBX to read the netcdf files.  This caused
%    problems because the code automatically replaces out-of-limit values
%    with NaN, and we want to see those values. Our code uses the MATLAB 
%    built-in libraries for accessing .netcdf files.  This requires 
%    extra steps but gives more robust results.
%
%  Output from multiple files is combined into a single array, to enable
%    easier filtering based on time/region/etc. 
%
%SEE ALSO: 
%  Amdar, filterByIndex, filterByRegion, getInfo, loadByDate,
%  segmentFlights


% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================

%% Set default lookup fields.
if(~exist('fieldsToLoad','var'))
  fieldsToLoad = {
    'latitude';...
    'longitude';...
    'altitude';...
    'GPSaltitude';...
    'trueAirSpeed';...
    'timeObs';...
    'windSpeed';...
    'windDir';...
    'en_tailNumber';...
  };
end

%% Format string inputs as a cell.
if(~iscell(filenames)), filenames = {filenames}; end
if(~iscell(fieldsToLoad)), fieldsToLoad = {fieldsToLoad}; end

%% Count n = total number of records for all files.
n = 0;
for i = 1:length(filenames)
  nc=loadNetcdf(filenames{i},{});
  n = n+nc.dim.recNum;
end

%% Dynamically preallocate output data structure.
for i = 1:length(fieldsToLoad)
  d.(fieldsToLoad{i}) = nan(n,1);
end

%% Read in Amdar data.
startPoint = 1;
fprintf('Loading %d ACARS files.\n',length(filenames));
for i = 1:length(filenames)
  nc = loadNetcdf(filenames{i},fieldsToLoad);
  nRecords = nc.dim.recNum;
  
  idx = startPoint:(startPoint+nRecords-1);
  for j = 1:length(fieldsToLoad)
    if(strcmp(fieldsToLoad{j},'en_tailNumber'))
      % Special handling for encrypted flight numbers.
      d.en_tailNumber(idx) = ...
        str2num(nc.en_tailNumber.data(:,4:11)); %#ok<ST2NM>
    else
      d.(fieldsToLoad{j})(idx)      = nc.(fieldsToLoad{j}).data;
    end
  end
  
  startPoint = startPoint+nRecords;
  fprintf('.'); if ~mod(i,40),fprintf('\n'); end % Status. 
end
  
% %% Unit conversion.
d.timeObs = d.timeObs/(24*60*60) + datenum(1970,1,1); % Matlab date format.
