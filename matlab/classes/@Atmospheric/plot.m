function h = plot(this,varargin)
%PLOT Plot atmospheric data.
%
% SYNTAX:
%   this = Atmospheric(now)
%   this.load()
%   this.plot()
%   this.plot('variable','temperatureHybrid')
%   this.plot('variable','temperatureHybrid','colormap','jet')
%   this.plot('variable','temperatureHybrid','colormap','jet','level',1)
%
% INPUTS:
%   this - Atmospheric object
%   varargin - parameter, value pairs
% 
% OUTPUTS:
%   h - Figure handle
%
% PARAMETERS:
%   'level' - Integer, vertical slice level to plot for 3D variables
%   'variable' - (DEFAULT = WIND), variable to plot
%   'colormap' - (DEFAULT = blue), matlab colormap
%   'plotcoast' - (DEFAULT = true), boolean, toggle coastline
%   'alpha' - (DEFAULT=0.8), 0.0 to 1.0, controls transparency
%
% NOTES:
%   Auto-loads variables as necessary.  Use 'this.variables' to see
%   available variables.

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================

%% Parse input arguments
% Set the display level based on the total number of vertical levels.
% The magic numbers here were chosen empirically to correspond
% approximately to the jet stream levels, around 300mb.
switch this.verticalLevels
  case 26, defaultLevel = 16;
  case 37, defaultLevel = 21;
  case 50, defaultLevel = 27;
  otherwise, defaultLevel = floor(this.verticalLevels*3/5);
end

% Parse inputs
p = inputParser;
p.addOptional('level',defaultLevel,@(x)isnumeric(x))
p.addOptional('variable','wind')
p.addOptional('colormap','blue')
p.addOptional('plotcoast',true,@(x)islogical(x))
p.addOptional('alpha',0.8,@(x) (0 <= x) && (x <= 1.0))
p.parse(varargin{:});

% Set the colormap.
cmap = p.Results.colormap;
if ischar(cmap)
  switch cmap
    case 'blue', cmap = [(1:-0.01:0)',(1:-0.01:0)',ones(101,1)];
    case 'green',cmap = [(1:-0.01:0)',ones(101,1),(1:-0.01:0)'];
    case 'red',  cmap = [ones(101,1),(1:-0.01:0)',(1:-0.01:0)'];
    otherwise, cmap = colormap(cmap);
  end   
end


%% Select a plane of data.
level = p.Results.level;

% For Hybrid grids, we do a lookup to find the index.
if strcmpi(this.verticalCoordSys,'hybrid')
  level = find(this.hybrid == level);
end

if strcmp(p.Results.variable,'wind')
  uName = ['uComponentOfWind' this.verticalCoordSys];
  vName = ['vComponentOfWind' this.verticalCoordSys];
  if ~any(strcmp(uName,this.variablesLoaded)) || ...
    ~any(strcmp(vName,this.variablesLoaded))
    this.load();
  end
  u = squeeze(this.(uName)(level,:,:));
  v = squeeze(this.(vName)(level,:,:));
  plane = sqrt(u.^2 + v.^2);
else
  % Load the variable if necessary.
  if ~any(strcmp(p.Results.variable,this.variablesLoaded))
    this.load(p.Results.variable);
  end
 
  % Select a single plane for 3D variables.
  if ndims(squeeze(this.(p.Results.variable))) > 2 %#ok<ISMAT>
    plane = double(squeeze(this.(p.Results.variable)(level,:,:)));
  else
    plane = double(squeeze(this.(p.Results.variable)));
  end
end

%% Create the plot
set(gcf,'PaperPositionMode','auto','Position',get(0,'Screensize'),...
  'color','w');
h = axes('box','on','position',[0 0 1 1]);

% Plot coast
if p.Results.plotcoast
  c = load('coast');
  plot([c.long; NaN; c.long+360],[c.lat; NaN; c.lat],'k');
end

% Special plot for the wind.
if strcmp(p.Results.variable,'wind')
  xMin = 0;
  xMax = 100;
  plotImage(this,plane,cmap,xMin,xMax);
  hold on;
  
  % Auto-scale to show as close to 100 arrows per row.
  n = round(max(size(this.longitude))/100);
  
  quiver(this.longitude(n:(2*n):(end-n),n:(2*n):(end-n)),...
    this.latitude(n:(2*n):(end-n),n:(2*n):(end-n)),...
    u(n:(2*n):(end-n),n:(2*n):(end-n)),...
    v(n:(2*n):(end-n),n:(2*n):(end-n)), 0.5, 'k');
else
  xMin = max(min(plane(~isnan(plane(:)))),0);
  xMax = max(plane(~isnan(plane(:))));
  if xMin == xMax, xMax = xMin + 1; end % Requires increasing val.
  plotImage(this,plane,cmap,xMin,xMax);
end

%% Label and other stuff.
set(gca,'xtickmode','auto','ytickmode','auto','xgrid','on','ygrid','on');
axis([min(this.longitude(:)), max(this.longitude(:)), ...
  min(this.latitude(:)),max(this.latitude(:))])
xlabel('Longitude Degrees E','fontsize',12,'fontweight','bold');
ylabel('Latitude Degrees N','fontsize',12,'fontweight','bold');
set(gca,'Units','normalized');
pos=get(gca,'Position');
gh = axes('position',[(pos(1)),pos(2),pos(3),0.06],...
  'xtick',[],'ytick',[],'visible','off');
lab = sprintf('%s %sZ,  %02d Hour Outlook,  Level %02d',...
  upper(this.product), datestr(this.forecastDate,'dd-mmm-yyyy HH:MM:SS'),...
  this.forecastOutlook, p.Results.level);
 
text(0.5,0.5,lab,...
  'FontWeight','bold','fontsize',14,'Margin',6,...
  'HorizontalAlignment','Center','Parent',gh,...
  'BackgroundColor','w','EdgeColor','k');

text(0.97,0.4,getUnits(this,p.Results.variable), ...
  'FontWeight','bold','fontsize',12,'Margin',6,...
  'HorizontalAlignment','Center','Parent',gh,...
  'BackgroundColor','none','EdgeColor','none');

set(gcf,'CurrentAxes',h);  % Restore current axes.

colormap(cmap);
lim = legendTickValues(xMin,xMax);
hcb = colorbar('East','YLim',[xMin xMax],'ytick',lim,'YtickLabel', lim, ...
  'fontSize',12,'fontweight','bold');
loc = get(hcb,'Position');
set(hcb,'Position',[loc(1)-0.01,loc(2)+0.04,loc(3),loc(4)/2]);
set(findobj(get(hcb,'children'),'-property','alphaData'),'alphaData',0.8);
cbfreeze;
h = gcf;
end

function plotImage(this,mag,cmap,xMin,xMax)
hold on;
x = this.longitude;
y = this.latitude;
z = -0.2*ones(size(this.latitude));
cdata = real2rgb(mag,cmap, [xMin xMax]);
surface(x,y,z,cdata,'EdgeColor','none','FaceColor','texturemap', ...
  'CDataMapping','direct','parent',gca,'hittest','off');
alpha(0.8);
hold off;
end

function val = legendTickValues(xMin,xMax)
% Workaround to pick somewhat reasonable values for the legend.
% Our strategy is to pick the tick values that give us closest to 5 points.
% Probably faster/smarter ways of doing this, but seems to work ok.
xRange = xMax - xMin;
maxRange = 10^(ceil(log(xRange)/log(10)));
a = ((xMin - mod(xMin,maxRange/10))+maxRange/10):maxRange/10:xMax;
b = ((xMin - mod(xMin,maxRange/20))+maxRange/20):maxRange/20:xMax;
c = ((xMin - mod(xMin,maxRange/50))+maxRange/50):maxRange/50:xMax;
[~,select] = min([abs(length(a)-5),abs(length(b)-5),abs(length(c)-5)]);
if select == 1
  val = unique([xMin a xMax]);
elseif select == 2
  val = unique([xMin b xMax]);
else
  val = unique([xMin c xMax]);
end
end

function units = getUnits(this,variable)
switch variable
  case 'wind', units = 'Knots';
  case 'pressure', units = 'mb';
  case 'pressureSurface', units = 'mb';
  case 'geometricHeight', units = 'Feet';
  case 'geometricHeightSurface', units = 'Feet';
  case 'geopotentialHeight', units = 'Feet';
  case 'geopotentialHeightSurface', units = 'Feet';
  otherwise
    try
      var = this.dataset.netcdf.findVariable(this.camelToNoaa(variable));
      units = char(var.findAttribute('units').getStringValue());
    catch exception %#ok<NASGU>
      units  = '';
    end
end
end
