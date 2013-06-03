function [latitude,longitude] = projToLatLon(obj,x,y)
%PROJTOLATLON Project from (x,y) to (latitude,longitude).
%
% SYNAX:
%   [lat,lon] = obj.projToLatLon(x,)
%   [lat,lon] = projToLatLon(obj,x,y)
%
% INPUTS:
%   x - Projected coordinate
%   y - Projected coordinate
%
% OUTPUTS:
%   latitude  - Decimal degrees N
%   longitude - Decimal degrees E
%
% NOTES:
%   Uses Java Netcdf methods for projection.
%
% SEE ALSO: 
%   latLonToProj

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================
xy = [x(:)'; y(:)'];
latlon = obj.projection.projToLatLon(xy);
latitude = reshape(latlon(1,:),size(x));
longitude = reshape(latlon(2,:),size(x));

% Enforce longitudes between -180 and 180
longitude = mod(longitude + 180,360) - 180;