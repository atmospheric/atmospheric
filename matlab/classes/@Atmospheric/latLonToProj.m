function [x,y] = latLonToProj(obj,latitude,longitude)
%LATLONTOPROJ Project from (latitude,longitude) to (x,y).
%
% SYNAX:
%   [x,y] = obj.projToLatLon(lat,lon)
%   [x,y] = projToLatLon(obj,lat,lon)
%
% INPUTS:
%   latitude  - Decimal degrees N
%   longitude - Decimal degrees E
%
% OUTPUTS:
%   x - projected coordinate
%   y - projected coordainte
%
% NOTES:
%   Uses Java Netcdf methods for projection.
%
% SEE ALSO: 
%   projToLatLon

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================

latlon = [latitude(:)'; longitude(:)'];
xy = obj.projection.latLonToProj(latlon);
x = reshape(xy(1,:),size(latitude));
y = reshape(xy(2,:),size(latitude));