function [filename, filepath] = amdarFilename(fileDate)
%AMDARFILNAME Returns the filename for a given date.
% 
%INPUTS:
%  filedate - Integer in Matlab date format.
%
%OUTPUTS:
%  filename - String
% 
%SYNTAX:
%  filename = amdarFilename(filedate)
%
%NOTES:
%  The filepaths presented here are hard-coded as an example. These should
%  be modified to work with your specific network storage location.

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================

% Files are organized by hour
fileDate = floor(fileDate*24)/24;  

% Provide platform-specific access
if(ispc), basedir = '//samba/data/acars/data/';
else basedir = '/data/acars/data/'; end

% Our naming conventions (based on the date)
filename = datestr(fileDate,'yyyymmdd_HH00');
filepath = fullfile(basedir,datestr(fileDate,'yyyy'),...
  datestr(fileDate,'yyyymmdd'));
