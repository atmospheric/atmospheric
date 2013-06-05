function result = interpSinglefile(this,...
  latitude,longitude,altitude,varargin)
%INTERPSINGLEFILE Interpolates the loaded file in three dimensions.
%
% INPUTS:
%   this      - Atmospheric object
%   latitude  - Decimal degrees N
%   longitude - Decimal degrees E
%   altitude  - Feet (or pascals, depending on vertical reference)
%   varargin  - See options below.
%
% PARAMETERS:
%   'method'- Interpolation method.
%      - 'Linear' (DEFAULT)
%      - 'Natural'
%      - 'Nearest'
%
%   'verticalReference' - Select vertical frame of reference.
%      - 'geometricHeight' (DEFAULT)
%      - 'geopotentialHeight'
%      - 'pressureAltitude'
%      - 'pressure'
%
%   'variables' - Which variables to interpolate.
%      - (DEFAULT) variables = {'uComponentWind','vComponentWind'}
%      - Cell array of variable names
%
% OUTPUTS:
%   result - Data structure containing results as fields.  Always contains
%     replicate of lookup latitude, longitude, altitude, and time, as well
%     as booleans indicating withinVertical and withinLateral.

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================

%% Check fixed inputs.
if nargin < 4
  error('Not enough input arguments.')
end
nPts = length(latitude);
validLength = (nPts == length(longitude)) && (nPts == length(altitude));
if ~validLength
  error('Latitude, longitude, and altitude must be same size.')
end
if mod(nargin,2)
  error('Invalid input arg: missing varargin pair.')
end


%% Parse param-arg input pairs.
p = inputParser;
    
% Vertical reference
valid = {'geometricHeight','geopotentialHeight',...
  'pressureAltitude','pressure'};
p.addParamValue('verticalReference','geometricHeight',...
  @(x)any(strcmpi(x,valid)))

% Interpolation methods
valid = {'linear','natural','nearest'};
p.addParamValue('method','linear',@(x)any(strcmpi(x,valid)))
p.addParamValue('timeMethod','N/A')

% Variables to interpolate
p.addParamValue('variables',{'uComponentOfWind';'vComponentOfWind'})
p.addParamValue('verbose','true',@(x)islogical(x))
p.KeepUnmatched = true;
p.parse(varargin{:});
if isempty(p.Results.variables), 
  error('Specify at least one variable to interpolate.')
end
verticalReference = p.Results.verticalReference;

%% Convert pressureAltitude request into pressure lookup.
if strcmp(verticalReference,'pressureAltitude');
  % Right now we use some magic numbers for the standard atmosphere model.
  % Eventually this will move into it's own class, but for now we keep here
  % as a workaround.
  altitude = 1013.25*(1-altitude/145366.45).^(1/0.190284); % In pascals
  verticalReference = 'pressure';
end

%% If we don't have the variables we need, load them now.
varToInterp = p.Results.variables;
if ~iscell(varToInterp), varToInterp = {varToInterp}; end
varNeeded = union(varToInterp, verticalReference);
varToLoad = setdiff(varNeeded, this.variablesLoaded);
if ~isempty(varToLoad)
  this.load(varToLoad);
end


%% For empty files, return a struct of NaN.
if isempty(this)
  result.latitude = latitude;
  result.longitude = longitude;
  result.altitude = altitude;
  result.withinLateral = false(size(latitude));
  result.withinVertical = false(size(latitude));
  result.withinArchive = false(size(latitude));
  for i = 1:length(varToInterp)
    result.(varToInterp{i}) = nan(size(latitude));
  end
  return;
end


%% Perform interpolation
if strcmp(this.product,'gfs')
  % No projection needed for GFS, use lat lon directly.
  longitude = mod((longitude + 360),360); % Enforce 0 to 360.
  xi = interp1(this.longitude(1,:),1:size(this.longitude,2),longitude(:));
  yi = interp1(this.latitude(:,1),1:size(this.latitude,1),latitude(:));
else
  [a,b] = this.latLonToProj(latitude(:), longitude(:));
  xi = interp1(this.x,1:length(this.x),a);
  yi = interp1(this.y,1:length(this.y),b);
end

zi = double(altitude);
z = double(this.(verticalReference));
method = p.Results.method;

% Loop over all variables.
for i = 1:length(varToInterp) 
  variable = double(this.(varToInterp{i})); 
  res = nan(size(latitude));
  withinLateral = false(size(latitude));
  withinVertical = false(size(latitude));
   
  % Loop over all sample points
  for j = 1:length(xi)  
    [res(j),withinLateral(j),withinVertical(j)] = ...
      interpSinglePoint(z,variable,xi(j),yi(j),zi(j),method);
  end
  result.(varToInterp{i}) = res;  
end
result.latitude = latitude;
result.longitude = longitude;
result.altitude = altitude;
result.withinLateral = withinLateral;
result.withinVertical = withinVertical;
result.withinArchive = true(size(latitude));

end

function [result,withinLateral,withinVertical] = ...
    interpSinglePoint(z,v,xi,yi,zi,method)
%INTERPSINGLEPOINT Interpolates a single point.
%
% This method is similar to the built-in interp3(), except that it can
% accomodate scattered sample-point spacing in the vertical dimension.
%
% By DEFAULT, returns:
%  NaN for locataions outside the lateral bounds.
%  Interpolates to the nearest plane for values outside the linear bounds.
  withinLateral = false;
  withinVertical = false;
  result = nan;
  
  if ~isnan(xi) && ~isnan(yi)
    switch ndims(v)
      case 1
        error('Single-dimension interpolation not supported.')
      case 2
        %% 2D interpolation
        method = strrep(method,'natural','linear'); % Natural not avail.
        result = interp2(v,xi,yi,method);
      case 3
        %% 3D interpolation
        % Index into the four vertical columns surrounding our point.
        % Here be some code dragons:
        %  - Create an additional vertical level above, and below.
        %  - Set the z for these levels to a very large & very small #.
        %  - This effecitvely sets extrapval = nearestNeighbor.
        %  - Avoids the need for conditional checks.
        %
        % Oddly, Matlab has some numerical precision issues whereby setting
        % the the outer values to too large a number results in the
        % interpolation returning NaN instead of the interp value. Hence
        % we use the values of -2e6 and 2e6 rather than 1e20 to avoid this
        % built-in precision issue.
        nPlanes = size(v,1);
        [a, b, c]=meshgrid(floor(xi):(floor(xi)+1),...
          floor(yi):(floor(yi)+1), [1 1:nPlanes nPlanes]);
        
        % Check if we're within lateral bounds
        if max(a(:)) > size(v,3) || max(b(:)) > size(v,2)
          return;
        end     
        withinLateral = true;
        
        % Check if we're within vertical bounds
        Zidx=sub2ind(size(v),c(:),b(:),a(:));        
        z = z(Zidx);
        if z(1) < z(end)
          lowerPlane = max(z(1:4));
          upperPlane = min(z(end-3:end));        
          withinVertical = lowerPlane <= zi && zi <= upperPlane;
          z(1:4) = -2e6;
          z(end-3:end) = 2e6;    
        else
          upperPlane = min(z(1:4));
          lowerPlane = min(z(end-3:end));        
          withinVertical = lowerPlane <= zi && zi <= upperPlane;
          z(1:4) = 1e6;
          z(end-3:end) = -1e6;      
        end
        
        % Interpolate using TriScatteredInterp; This can't be done using 
        % the normal interp3() method because we have variable-spaced 
        % sampling in the vertical dimension.
        f = TriScatteredInterp(a(:),b(:),z,double(v(Zidx)),method);
        result = f(xi,yi,zi);

      otherwise
        error('%d-D interpolation not yet supported.',ndims(v))
    end
  end
end
