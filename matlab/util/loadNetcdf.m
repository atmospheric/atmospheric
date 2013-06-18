function data = loadNetcdf(filename, fieldsToLoad)
%LOADNETCDF Loads a netcdf file into a Matlab data structure.
%
%SYNTAX:
%  loadNetcdf(filename,fieldsToLoad)
%  loadNetcdf(filename) 
% 
%INPUTS:
%  filename - full path filename
%  fieldsToLoad - cell array of fields to load (by name). Leave empty to
%    load all fields. 
%
%OUTPUTS:
%  data - Matlab data structure of NetCDF contents.
%
%NOTES:
%  - Numerical fill values are replaced with NaN.
%  - Field names and units are preserved from the original CDF file.
%      (with the exception of illegal characters, which are removed.)
%  - Note that VALID_RANGE checking is intentionally NOT ENFORCED.
%
%TODO: 
%  - Include global attributes as additional structure fields.

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================
  
% Open file, get number of records, create output index.
ncId = netcdf.open(filename,'NC_NOWRITE');
[nDims,nVars,~,~] = netcdf.inq(ncId);
  
% If second argument is empty, load all fields and global attributes.
if(~exist('fieldsToLoad','var'))
  % Grab all field names.
  fieldsToLoad = cell(nVars,1);
  for varId = 1:nVars
    [varName,~,~,~] = netcdf.inqVar(ncId,varId-1);
    fieldsToLoad{varId} = varName;
  end
else
  % Allow both cell and string entry
  if(~iscell(fieldsToLoad))
    fieldsToLoad = {fieldsToLoad};  % Convert to cell array.
  end
end

% Load each variable.
for i = 1:length(fieldsToLoad)
  data.(fieldsToLoad{i}) = getVar(ncId,fieldsToLoad{i});
end

% Load dimension information
data.dim.ndim = nDims;
for dimId = 0:(nDims-1)
   [dimName, dimLength] = netcdf.inqDim(ncId,dimId);
   data.dim.(dimName) = dimLength;
end

% Cleanup.
netcdf.close(ncId);
end

%% Helper functions -------------------------------------------------------
function var = getVar(ncId, varName)
%GETVAR Loads a variable, replacing fills with NaN.
  varId = netcdf.inqVarID(ncId,varName);
      
  %Grab all attributes, put into our structure.
  [~,~,~,numAtts] = netcdf.inqVar(ncId,varId);
  for attId = 0:(numAtts-1)
    attName = netcdf.inqAttName(ncId,varId,attId);
    
    % Format name for more-strict Matlab structure requirements.
    myAttName = strrep(attName,'-','minus');
    myAttName = strrep(myAttName,'_FillValue','FillValue');
        
    var.(myAttName) = netcdf.getAtt(ncId,varId,attName);
  end
  
  % Pull the actual data.
  var.data = netcdf.getVar(ncId,varId);
  
  % Flip 2D array data to match Matlab conventions.
  if(size(var.data,2)>1)  
    var.data = var.data';
  end
  
  % Replace fill values with Matlab NaN.
  if(isfield(var,'FillValue') && ~ischar(var.FillValue))
    var.data(var.data == var.FillValue) = NaN;
  end
end
  
