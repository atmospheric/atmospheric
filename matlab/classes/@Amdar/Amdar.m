classdef Amdar
methods (Static) % All methods static, by design.
  [d,netcdfInfo] = loadByDate(startDate,endDate,fieldsToLoad)

  filtered = filterByRegion(trackData,...
    minLatitude,maxLatitude,minLongitude,maxLongitude)
  
  amdarData = filterByIndex(amdarData,index)
  
  flightData = segmentFlights(flightData,minSamp,secThresh,...
    aptThreshNM,altThreshMetersAboveMSL)
	
  d = load(filenames,fields)
  d = getInfo(filename)
end

end

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================
