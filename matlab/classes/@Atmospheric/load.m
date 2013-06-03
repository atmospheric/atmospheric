function this = load(this,fieldsToLoad,enableUnitConversion)
%LOAD Loads the specified fields, loads winds by default.
%
% INPUTS:
%   this - Atmospheric object.
%   fieldsToLoad - Cell array of fields to load.
%   enableUnitConversion - Boolean to enable unit conv. (DEFAULTS to true)
%
% OUTPUTS:
%   this - Atmospheric object
%
% SYNTAX:
%   this = this.load()
%   this = this.load(fields)
%   this = Atmospheric(date).load()
%   this = Atmospheric(date).load(fields)
%   this = Atmospheric(date,outlook).load(fields)
%
% NOTES:
%   By default, load() loads coordinates, winds, and geometric height.
%   Accepts both camel case and NOAA field name conventions.
%   
%   Conversions: (enabled by default)
%   - Wind speeds to knots
%   - Altitudes to feet
%   - Wind speeds aligned to true north
%   - Pressure converted from pascals to millibar
%
%   To disable all conversions, set: 
%     enableUnitConversion = false.
%
% SEE ALSO:
%   Atmospheric

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================

% Validate input.
if nargin < 3, enableUnitConversion = true; end
if nargin < 2
  fieldsToLoad = {'uComponentOfWindHybrid','vComponentOfWindHybrid',...
    'geopotentialHeight'};
end

% Standardize as cell array, boolean.
if ~iscell(fieldsToLoad)
  fieldsToLoad = {fieldsToLoad};
end
if ischar(enableUnitConversion)
  switch lower(enableUnitConversion)
    case 'true', enableUnitConversion = true;
    case 'false', enableUnitConversion = false;
    otherwise, error('Must specify true or false.');
  end
end

% Check that we have a valid Atmospheric object.
if isempty(this.dataset), return, end

% Enforce camel case.
fieldsToLoad = camel(fieldsToLoad);

% Height always specified as geopotential, then compute geometric.
fieldsToLoad = strrep(fieldsToLoad,'geometricHeight','geopotentialHeight');
fieldsToLoad = strrep(fieldsToLoad,'geometricHeightSurface',...
  'geopotentialHeightSurface');


% Can specify static temperature to compute from geopotential temp.
computeStaticTemp = false;
if any(strcmpi(fieldsToLoad,'staticTemperature'))
  if this.camelToNoaa.isKey('virtualPotentialTemperature')    
    fieldsToLoad = setdiff(fieldsToLoad,'staticTemperature'); % Remove
    fieldsToLoad = union(fieldsToLoad,{'pressure',...
      'humidityMixingRatio','virtualPotentialTemperature'});
  else
    fieldsToLoad = setdiff(fieldsToLoad,'staticTemperature');
    fieldsToLoad = union(fieldsToLoad,'temperature');
  end
  computeStaticTemp = true;
end

% Look up corresponding NOAA field names.
noaaFields = cell(size(fieldsToLoad));
for i = 1:length(fieldsToLoad)
  try
    % Some RUC files use uWind, vWind, instead of 'uComponentOfWind', etc.
    if this.camelToNoaa.isKey('uWind') && ...
        strcmp(fieldsToLoad{i},'uComponentOfWind')
      noaaFields{i} = this.camelToNoaa('uWind');
    elseif this.camelToNoaa.isKey('vWind') && ...
        strcmp(fieldsToLoad{i},'vComponentOfWind')
      noaaFields{i} = this.camelToNoaa('vWind');   
    elseif this.camelToNoaa.isKey('uWindSurface') && ...
        strcmp(fieldsToLoad{i},'uComponentOfWindSurface')
      noaaFields{i} = this.camelToNoaa('uWindSurface');
    elseif this.camelToNoaa.isKey('vWindSurface') && ...
        strcmp(fieldsToLoad{i},'vComponentOfWindSurface')
      noaaFields{i} = this.camelToNoaa('vWindSurface');
    else
      % Normal case.
      noaaFields{i} = this.camelToNoaa(fieldsToLoad{i});
    end
    
  catch %#ok<CTCH>
    error(['Field not available: ''%s''\nSee this.variables for a '...
      'complete list of available fields.'], fieldsToLoad{i});
  end
end


%% Load specified fields.  
for i = 1:length(fieldsToLoad)
  data = this.dataset.data(noaaFields{i});
  if ~isfield(this,fieldsToLoad{i}) && ~isprop(this,fieldsToLoad{i})
    addprop(this,fieldsToLoad{i});
  end
  this.(fieldsToLoad{i}) = squeeze(data); 
end
this.variablesLoaded = union(this.variablesLoaded,fieldsToLoad)';


%% Automatic unit conversions.
if enableUnitConversion
  % Convert geopotentialHeight to geometricHeight
  % (Must be done before we convert to feet).
  if any(strcmpi(fieldsToLoad,'geopotentialHeight'))
    nLevels = size(this.geopotentialHeight,1);
    tmpLat = shiftdim(repmat(this.latitude,[1 1 nLevels]),2);
    tmpLon = shiftdim(repmat(this.longitude,[1 1 nLevels]),2);
    if ~isprop(this,'geometricHeight')
      addprop(this,'geometricHeight');
    end
    this.geometricHeight = Atmospheric.geopotentialToGeometricHeight(...
      this.geopotentialHeight,tmpLat) * this.feetPerMeter;
    this.variablesLoaded = union(this.variablesLoaded,'geometricHeight');
%     addprop(this,'geoidHeight');
%     this.geoidHeight = Atmospheric.geometricToGeoid(...
%       this.geometricHeight, tmpLat, tmpLon);
%     this.variablesLoaded = union(this.variablesLoaded,{'geometricHeight', 'geoidHeight'});
  end
  
  % Align winds to true north.
  if any(strcmp(fieldsToLoad,'uComponentOfWind')) && ...
      any(strcmp(fieldsToLoad,'vComponentOfWind'))
    this.alignTrueNorth();
  end
  
  % Convert to feet to meters, pascals to millibar, knots to m/s.
  for i = 1:length(fieldsToLoad)
    f = fieldsToLoad{i};
    switch f
      case {'geometricHeight','geometricHeightSurface',...
          'geopotentialHeight','geopotentialHeightSurface'}
        this.(f) = this.(f) * this.feetPerMeter;
        
      case {'uComponentOfWind','uComponentOfWindSurface',...
          'vComponentOfWind','vComponentOfWindSurface'}
        this.(f) = this.(f) * this.knotsSecondPerMeter;
        
      case {'pressure','pressureSurface'}
        this.(f) = this.(f) / 100;
    end
  end
  
  % Bug fix for GFS, we replicate pressure to be full grid dimensions.
  % Same fix also applies to isobaric files.
  if any(strcmp(fieldsToLoad,'pressure')) && ...
      (length(this.pressure(:)) == 37 || strcmp(this.source,'gfs') ...
      || length(this.pressure(:)) == 35) 
    [nX,nY] = size(this.latitude);
     this.pressure = reshape(repmat(this.pressure,nX,nY), ...
       [length(this.pressure), nX, nY]);
  end
  
  % Compute static temperature from virtual potential temperature.
  if computeStaticTemp
    if ~isprop(this,'staticTemperature')
      addprop(this,'staticTemperature');
    end
    
    if isprop(this,'virtualPotentialTemperature')
      % Conversion magic.
      this.staticTemperature = this.virtualPotentialTemperature ./ ...
        (1+0.51*this.humidityMixingRatio)./(1000/this.pressure).^0.286;
    else
      % No need to convert, this is already a static temp.
      this.staticTemperature = this.temperature;
    end
  end
end
