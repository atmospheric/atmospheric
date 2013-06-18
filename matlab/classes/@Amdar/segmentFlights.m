function flightData = segmentFlights(flightData,minSamp,secThresh,...
  aptThreshNM,altThreshMetersAboveMSL)
%SEGMENTFLIGHTS Assigns unique flight ID's to the Amdar track data.
% 
%SYNTAX:
%  flightData = segmentFlights(flightData,minSamp,secThresh,aptThreshNM,...
%                 altThreshMetersAboveMSL);
%  flightData = segmentFlights(flightData,minSamp,secThresh,aptThreshNM)
%  flightData = segmentFlights(flightData,minSamp,secThresh)
%  flightData = segmentFlights(flightData,minSamp)
%  flightData = segmentFlights(flightData)
%
%INPUTS:
%  amdarData - structure containing Amdar data, must have en_tailNumber ID.
%  minSamp   - Optional, number of samples required for flight 
%  secThresh - Optional, minimum time between two flights
%  aptThreshNM - Optional, maximum distance from airport
%  altThreshMetersAboveMSL - Maximum altitude for initial/final point
%
%OUTPUTS:
%  amdarData - with field several new fields:
%    .flightID - Unique flight ID for each segment (even partial segments).
%    .depAirport - 3 Letter code for departure airport.
%    .arrAirport - 3 Letter code for arrival airport.
%    .hasAirport - 1 if we have airport data, 0 otherwise.
%
%SEE ALSO: 
%  Amdar, filterByIndex, filterByRegion, getInfo, load, loadByDate

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================

%% Apply default Segmentation parameters if not set.
if(~exist('secThresh','var'))
  secThresh = 25/(24*60); % 25 min in Days.
end
if(~exist('minSamp','var'))
  minSamp = 10;
end
if(~exist('aptThreshNM','var'))
  aptThreshNM = 3;  % Distance in NM from Airport.
end
if(~exist('altThreshMetersAboveMSL','var'))
  altThreshMetersAboveMSL = 1000;
end

%% Create new structure fields.
n = length(flightData.en_tailNumber);
flightData.flightID = nan(n,1);
flightData.depAirport = repmat(' ',n,3);
flightData.arrAirport = repmat(' ',n,3);
flightData.hasAirport = zeros(n,1);

%% Load airport data.
filename = 'airportstop100.txt';
fid = fopen(filename,'r');
tmp=textscan(fid,'%.8f,%.8f,%3s','Whitespace','\n');
fclose(fid);
aptLat = tmp{1};
aptLon = tmp{2};
aptName = tmp{3};


%% Loop over each unique aircraft.
id = 1;
uTail = unique(flightData.en_tailNumber);
for i = 1:length(uTail);
  % Pull out lat, long, alt, time for a given aircraft.
  idx = find(flightData.en_tailNumber == uTail(i));
  lat = flightData.latitude(idx);
  lon = flightData.longitude(idx);
  alt = flightData.altitude(idx);
  time = flightData.timeObs(idx);
  
  % Segment based on time.
  segment = find(diff(time) > secThresh);  % Identify end points.
  segment = [0 segment' length(time)];
  
  % Iterate over each segment, checking whether we have enough info to
  % assign an airport match.
  for j = 2:length(segment);
    sIdx = segment(j-1)+1;
    eIdx = segment(j);
    r = idx(sIdx:eIdx);
    
    % Require at least 'minSamp' samples.
    if( (eIdx - sIdx + 1) > minSamp)
      
      % Require start and end altitudes are below altThresh.
      if( (alt(sIdx) < altThreshMetersAboveMSL) && ...
          (alt(eIdx) < altThreshMetersAboveMSL))
        
        % Require that all lat/long/alt/time entries are valid.
        if(~(any(isnan([lat lon alt time]))))
          
          % Find closest dep and arrival airports, among busiest 100.
          [a,b] = min(Geo.distance(lat(sIdx),lon(sIdx),aptLat,aptLon));
          depApt = aptName{b};
          [c,d] = min(Geo.distance(lat(eIdx),lon(eIdx),aptLat,aptLon));
          arrApt = aptName{d};
          
          % Require that we are within threshold distance of each airport.
          %   and that our departure Airport is not our arrival Airport.
          if((a < aptThreshNM)&&(c < aptThreshNM)&&~strcmp(arrApt,depApt))
            
            % Assign the airports to this track.
            % disp(['Flight ' num2str(id) ': ' arrApt ' to ' depApt]);
            flightData.depAirport(r,:) = repmat(depApt,length(r),1);
            flightData.arrAirport(r,:) = repmat(arrApt,length(r),1);
            flightData.hasAirport(r) = 1;
          end
        end
      end
    end
    flightData.flightID(r) = id;
    id = id + 1;
  end
end
fprintf('Valid US Airport for %f%% of samples.\n',...
  100*sum(flightData.hasAirport)/numel(flightData.hasAirport));

  
  