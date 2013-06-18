function filtered = filterByRegion(amdarData,...
  minLatitude,maxLatitude,minLongitude,maxLongitude)
%FILTERBYREGION Prunes the data based on region of interest.
%
%SYNTAX: 
%  filtered = Amdar.filterByRegion(amdarData, minLatitude, maxLatitude,...
%               minLongitude, maxLongitude); 
%
%INPUTS:
%  amdarData    - Structure containing input Amdar data.
%  minLatitude  - Decimal degrees N
%  maxLatitude  - Decimal degrees N
%  minLongitude - Decimal degrees E
%  maxLongitude - Decimal degrees E
%
%OUTPUTS:
%  filtered - Structure containing filtered Amdar data.
%
%SEE ALSO: 
%  Amdar, filterByIndex, getInfo, load, loadByDate, segmentFlights

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================
assert(isfield(amdarData,'latitude') && isfield(amdarData,'longitude'),...
  'Input track data must include latitude and longitude fields.');

%% Find valid range based on latitude and longiutde requirements.
validLat=(amdarData.latitude > minLatitude) & ...
  (amdarData.latitude < maxLatitude);
validLon=(amdarData.longitude > minLongitude) & ...
  (amdarData.longitude < maxLongitude);
validRange = validLat & validLon;

filtered = Amdar.filterByIndex(amdarData,validRange);

end