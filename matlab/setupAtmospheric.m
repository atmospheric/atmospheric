function setupAtmospheric
%SETUPATMOSPHERIC Sets up the Atmospheric Toolbox.
%
% SYNTAX:
%   To install the toolbox, add the following to lines to your startup.m:
%
%     cd('c:\your_toolbox_location');
%     setupAtmospheric();

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================

% Matlab defaults to use hardware acceleration for openGL. This causes
% rendering instability if the hardware does not support alpha blending.
% The toolbox sets Matlab openGL to use software emulation, which is tested
% and more stable. The openGL mode should be set before any graphics are
% generated; otherwise it requires a fresh restart of Matlab.
opengl('software');

% Configure nctoolbox
myloc = pwd;
home = fileparts(which(mfilename));
try
  cd(fullfile('external','nctoolbox-20130305'))
  setup_nctoolbox()
  cd(myloc)
catch ME
  error('Unable to find relative path to nctoolbox.')
end

%% Add required classpaths
addpath(fullfile(home))
addpath(fullfile(home,'classes'))
addpath(fullfile(home,'test'))
addpath(fullfile(home,'util'))
addpath(fullfile(home,'external','cm_and_cb_utilities'))
addpath(fullfile(home,'external','colormaps'))
addpath(fullfile(home,'external','xunit','xunit'))

%% Suppress Netcdf Logger output
org.apache.log4j.BasicConfigurator.configure();
logger = org.apache.log4j.Logger.getRootLogger();
logger.setLevel(org.apache.log4j.Level.OFF);

disp('ATMOSPHERIC added to Matlab path')