function [d,netcdfInfo] = loadByDate(startDate,endDate,varargin)
%LOADBYDATE Loads the Amdar files for the date range of interest.
% 
%INPUTS:
%  startDate - Integer in Matlab date format.
%  endDate - Integer in Matlab date format.
%  varargin - Optional arguments, passed to Amdar.load()
%
%OUTPUTS:
%  d - Structure containing Amdar info.
%  netcdfInfo - Arracy containing information about the Netcdf fields.
% 
%SYNTAX:
%  [d,netcdfInfo] = loadByDate(startDate,endDate,varargin)
%  [d,netcdfInfo] = loadByDate(startDate,endDate)
%  d = loadByDate(startDate,endDate,varargin)
%  d = loadByDate(startDate,endDate)
%
%NOTES:
%  Algorithm
%   1) Constructs file names for all hour increments in the date range.
%   2) Checks that all files exist.
%   2) Downloads local copy of all files from the samba share drive.
%   3) Gunzips all local copies (within Matlab's 'tempdir').
%   4) Reads in data using Amdar.load()
%   5) Cleans up tempDir cached copies.
%
%SEE ALSO: 
%  Amdar, filterByIndex, filterByRegion, getInfo, load, segmentFlights

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================

%% Round to nearest hour.
startDate = floor(startDate*24)/24;  
endDate = floor(endDate*24)/24;
lookupTime = startDate:1/24:endDate;

% For very very large requests, break into smaller requests and concat.
if length(lookupTime) > 168 % One week of data.
  nRequests = ceil(length(lookupTime) / 168);
  disp(['Managing as ' num2str(nRequests) ' requests.'])
  res = cell(nRequests,1);
  for i = 1:nRequests;
    sd = lookupTime((i-1)*168+1);
    ed = lookupTime(min(i*168, length(lookupTime)));
    [res{i},netcdfInfo] = Amdar.loadByDate(sd,ed,varargin{:});
    disp(['Completed ' num2str(i) ' of ' num2str(nRequests)])
  end
  
  % Combine results.
  d = vertcatStruct(res);
  return
end

%% Find filenames.
nFiles = length(lookupTime);
remoteZip   = cell(nFiles,1); 
localZip    = cell(nFiles,1);
localNetcdf = cell(nFiles,1);
for i = 1:nFiles
  [filename, remoteDir] = amdarFilename(lookupTime(i));
  remoteZip{i} = fullfile( remoteDir, [filename '.gz'] );
  localZip{i} = fullfile( tempdir, [filename '.gz'] );
  localNetcdf{i} = fullfile( tempdir, filename );
end

%% Make a local copy all files.
disp(['Downloading local cache of ' num2str(nFiles) ' files.']);
for i = 1:nFiles
  try 
    copyfile(remoteZip{i},localZip{i});
    fprintf('.'); if ~mod(i,40),fprintf('\n'); end % Status.
  catch ME
    checkForSamba();
    rethrow(ME);
  end  
end
disp('Done.');

%% Unzip local cache
curDir = pwd;
cd(tempdir);  %Work in the temp directory.
disp(['Unzipping local cache of ' num2str(nFiles) ' files.']);
for i = 1:nFiles

  % Somewhat faster using 7z executable, but increases dependencies and
  % doesn't work on all systems.  Use built-in gunzip for now.
  % gzipLoc = which('7z.exe');
  % cmd = [gzipLoc ' x -y ' localZip{i}];
  % [~,~] = dos(cmd);
  gunzip(localZip{i},tempdir);
  delete(localZip{i});
  fprintf('.'); if ~mod(i,40),fprintf('\n'); end % Status.
end
cd(curDir); % Return to our previous directory.
disp('Done.');


%% Robustly load all files.
try 
  d = Amdar.load(localNetcdf,varargin{:});
catch ME 
  %% Cleanup if we fail to load a file.
  for i = 1:nFiles
    try  %#ok<TRYNC>
      delete(localNetcdf{i});
    end
  end
  rethrow(ME);
end

%% Return info about available data fields.
if nargout > 1
	netcdfInfo = loadNetcdf(localNetcdf{1});
end

%% Cleanup.
for i = 1:nFiles
  delete(localNetcdf{i});
end

end

