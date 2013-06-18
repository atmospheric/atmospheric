function d = getInfo(filename)
%GETINFO Loads all the fields for a single Amdar file, prints info.
%  This method to provide a means for exploring available data fields,
%  identifying units, and reading other metadata associated with the file.
% 
%SYNTAX:
%  d = Amdar.getInfo(filename)
%
%INPUT:
%  filenames - Cell array of files to be loaded.  
%
%OUTPUT:
%  d - Structure containing all fields of file (including metadata).
%
%NOTES:
%  Private function.  To access this information publicly, call:
%
%    [d,netcdfInfo] = loadByDate(...)
%  
%  Also note that this function requires using the uncompressed netcdf file
%  (if you call directly with the .gz file, it will fail).  Uncompress
%  first using the command 'unzip'.

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================

d = loadNetcdf(filename);
f = fields(d);

% Loop over top level field names.
for i = 1:length(f);
  disp([  f{i} ':']);
  try 
    
    % Expand subfields.
    subFields = fields(d.(f{i}));
    for j = 1:length(subFields)
      if(~strcmpi(subFields{j},'data'))
        
        % Print subfield data.
        fprintf(['  ' subFields{j} ' = ']);
        sf = d.(f{i}).(subFields{j});
        if(ischar(sf))
          fprintf(['"' sf '"\n']);
        else
          fprintf([num2str(sf) '\n']);
        end
        
      end
    end
  catch %#ok<CTCH>
  end
end
    
end