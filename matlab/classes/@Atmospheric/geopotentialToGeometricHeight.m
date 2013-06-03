function [Zgm] = geopotentialToGeometricHeight(Zgp, Lat)
%GEOPOTENTIALTOGEOMETRICHEIGHT Height conversion from Zgp to Zgm.
%
% INPUTS:
%   Zgp - Geopotential Height in meters (numeric)
%   Lat - Latitude in degrees (numeric)
%   
% OUTPUTS:
%   Zgm -  Geometric Height in meters (numeric)
%
% NOTES:
%   Validated by .... ........ on  dd month yyyy
%       Method: Verifed that geopotential and geometric heights are similar
%       near 45 degrees of latitude and as much as 120 meters different
%       near the equator at altitudes of 20 km. Also verified that
%       geometric height is generally higher than geopotential height.
%       Lastly, checked consistancy of units and accuracy of constants.
%
%   References: 
%       The math needed to make this conversion can be found at
%       http://www.ofcm.gov/fmh3/text/appendd.htm. Other references
%       include: http://www.mathpages.com/home/kmath054.htm and
%       http://mtp.jpl.nasa.gov/notes/altitude/altitude.html

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================

% TODO: These constants should go in class definition.
%
% Local variables:
%  g    - Gravity (numeric)
%  Glat - Gravity at a given latitude (numeric)
%  Rlat - Radius of the Earth at a given latitude (numeric)
%  Gr   - Gravity Ratio = Glat*Rlat/g (numeric)

Zgm = zeros(size(Zgp));
g = 9.80665; % numeric in m/s2
Rlat = 6378137./(1.006803-0.006706*(sind(Lat(:))).^2); % numeric in meters
Glat = 9.80616*(1-0.002637236*(cosd(2*Lat(:)))+0.000005821355*...
  (cosd(2*Lat(:))).^2); % numeric in m/s2
Gr = Glat(:).*Rlat(:)/g; % numeric meters
Zgm(:) = Zgp(:).*Rlat(:)./(Gr(:)-Zgp(:)); % numeric in meters
