classdef Atmospheric < dynamicprops
  properties(Constant,Hidden)
    % Conversion constants
    knotsSecondPerMeter = 1.94384449; % knots / (m/s)
    feetPerMeter = 3.2808399; % ft/m
    gravity = 9.80665; % m/s2
    pascalsPerInHg = 3386; % Pa/inHg
    millibarsPerPascal = .01; %mbar/Pa
  end
  properties(Hidden)
    dataset
    projection
    x
    y    
    noaaToCamel
    camelToNoaa
  end
  properties
    product
    forecastDate
    forecastOutlook
    verticalCoordSys
    verticalLevels
    variables
    variablesLoaded
    windsAlignedToTrueNorth = false;
    latitude
    longitude
  end
  properties(Dependent)
    projectedDate
  end
  
  methods
    function obj = Atmospheric(varargin)
      % Call with 0, 1, or n arguments
      if nargin == 0
        filename = '';
      elseif ischar(varargin{1})
        filename = varargin{1};
      else
        filename = Atmospheric.getFilename(varargin{:});
      end
      
      if ~isempty(filename)        
        % Load basic file info.
        obj.dataset = ncdataset(filename);
        if ~isempty(obj.dataset)
            
          % Define Date based on Netcdf units for "Date". All in GMT.
          import ucar.nc2.time.CalendarDateUnit;
          dateUnits = obj.dataset.netcdf.findVariable('time').getUnitsString;
          ncDate = CalendarDateUnit.of(java.lang.String('gregorian'),...
              dateUnits);
          baseDate = ncDate.getBaseCalendarDate();
          epochTime = baseDate.getMillis(); % in UTC
          obj.forecastDate = datenum('1970', 'yyyy') + epochTime / 864e5;

          % Forecast outlook is a bit easier.
          obj.forecastOutlook = double(obj.dataset.data('time'));  
          if ~isempty(length(obj.forecastOutlook))
            obj.forecastOutlook = obj.forecastOutlook(1);
          end
          
          % Identify NOAA product type
          % (Keyword search over the Netcdf global attributes)
          attr = char(obj.dataset.netcdf.getGlobalAttributes().toString);
          knownTypes = '(gfs)|(rap)|(ruc)|(nam)|(hrrr)';
          tok = regexpi(attr,knownTypes,'once','tokens');
          if ~isempty(tok)
            obj.product = lower(tok{1});
          else
            obj.product = '';
          end
          
          % Fix known bug in RapidRefresh metadata- the metadata still
          % indicated "Ruc" even after the transition to RAP.
          if strcmp(obj.product,'ruc') && ...
              obj.forecastDate > datenum(2012,5,1)
            obj.product = 'rap';
          end
                    
          % Define coordinates and transforms.
          switch obj.product
            case {'ruc','rap','hrrr','nam'}
              obj.x = obj.dataset.data('x');
              obj.y = obj.dataset.data('y');
              transform = obj.dataset.netcdf.getCoordinateTransforms.get(0);
              obj.projection = transform.getProjection();
              [a,b] = meshgrid(obj.x,obj.y);
              [obj.latitude,obj.longitude] = obj.projToLatLon(a,b);
            case 'gfs'
              lat = obj.dataset.data('lat');
              lon = obj.dataset.data('lon');
              [obj.longitude,obj.latitude] = meshgrid(lon,lat);
              obj.x = [];
              obj.y = [];
            otherwise
              warning('Unknown data source.')
          end
         
          % Define field maps, available variables.
          noaa = obj.dataset.variables;
          cc = camel(noaa);
          obj.noaaToCamel = containers.Map(noaa,cc,'UniformValues',true);
          obj.camelToNoaa = containers.Map(cc,noaa,'UniformValues',true);
          obj.variables = sort(cc);
          
          % Define Vertical Coordinate System based on netcdf.
          obj.verticalLevels = 0;
          obj.verticalCoordSys = '';
          knownTypes = '(hybrid)|(isobaric)';
          attr = char(obj.dataset.netcdf.getCoordinateSystems.toString);
          tok = regexpi(attr,knownTypes,'once','tokens');
          if ~isempty(tok), 
            % Capitalize the first letter, for use later in retrieving
            % grids such as 'uComponentOfWindHybrid'.
            capitalized = regexprep(tok{1},'(\<\w)','${upper($1)}');
            obj.verticalCoordSys = capitalized;

            % Load the vertical levels as the grid having the largest size.
            grids = regexpi(obj.variables,['^(' capitalized '.*)'],...
              'tokens');
            grids = vertcat(grids{:});
            grids = vertcat(grids{:}); % Additional cell-derefence

            for i = 1:length(grids)
              obj.load(grids{i});
              obj.verticalLevels = max(obj.verticalLevels, ...
                length(obj.(grids{i})));
            end
          end
        end
      end
    end

    function t = get.projectedDate(obj)
    %GET.PROJECTEDDATE Defines dependent property: projectedDate
      t = obj.forecastDate+obj.forecastOutlook/24;
    end

    function val = isempty(this)
    %ISEMPTY Overrides the built-in to check if we have a valid dataset.
      val = isempty(this.dataset);
    end
    
    function str = details(this)
    %DETAILS Returns the Netcdf details as a string.
      str = this.dataset.netcdf.toString;
    end

    % Projection functions
    [lat,lon] = projToLatLon(obj,x,y)
    [x,y] = latLonToProj(obj,lat,lon)    
    
    h = plot(this,varargin)
  end
  
  methods(Static)
    filename = getFilename(inputDate,varargin)
    Zgm = geopotentialToGeometricHeight(Zgp, Lat)
    Zgeoid = geometricToGeoid(ZgmFt, lat, lon)
  end

  % Copyright 2013, The MITRE Corporation.  All rights reserved.
end