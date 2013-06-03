function [Zgeoid] = geometricToGeoid(ZgmFt, lat, lon)
%GEOPOTENTIALTOGEOMETRICHEIGHT Height conversion from Zgp to Zgm.
%
% INPUTS:
%   Zgm - Geopotential Height in feet (numeric)
%   Lat - Latitude in degrees (numeric)
%   Lon - Longitude in degrees (numeric)
% 
% OUTPUTS:
%   Zgeoid - Geoid hieght in feet.

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================

feetPerMeter = 3.2808399; % ft/m
geoidData = load('geoid');
geodiff = ltln2val(geoidData.geoid, geoidData.geoidrefvec, lat, lon);
geodiff = reshape(geodiff, size(ZgmFt)) * feetPerMeter;
Zgeoid = ZgmFt - geodiff;
