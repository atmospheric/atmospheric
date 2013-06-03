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
    source
    forecastDate
    forecastOutlook
    variables
    variablesLoaded
    latitude
    longitude
    windsAlignedToTrueNorth = false;
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
        % Identify data source based on filename.
        %   Ideally this could be distinguished from the netcdf 
        %   metadata, but I can't find where this info is saved.  -CMW
        [~,fn] = fileparts(filename);
        if ~isempty(regexp(fn,'ruc','once'))
          obj.source = 'ruc';
        elseif ~isempty(regexp(fn,'rap','once'))
          obj.source = 'rap';
        elseif ~isempty(regexp(fn,'gfs','once'))
          obj.source = 'gfs';
        elseif ~isempty(regexpi(fn,'hrrr','once'))
          obj.source = 'hrrr';
        else
          obj.source = '';
        end
        
        % Load basic file info.
        obj.dataset = ncdataset(filename);
        if ~isempty(obj.dataset)
          % Define dates from NOAA metadata.
          %str = attribute(obj.dataset,'_CoordinateModelRunDate');
          %obj.forecastDate = datenum(str([1:10,12:19]),...
          %  'yyyy-mm-ddHH:MM:SS');
          obj.forecastOutlook = double(obj.dataset.data('time'));  
          if ~isempty(length(obj.forecastOutlook))
            obj.forecastOutlook = obj.forecastOutlook(1);
          end
          
          % Define coordinates and transforms.
          switch obj.source
            case {'ruc','rap','hrrr'}
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

  % Copyright 2012, The MITRE Corporation.  All rights reserved.
end