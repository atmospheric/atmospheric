function amdarData = filterByIndex(amdarData,index)
%FILTERBYINDEX Prunes the data based on the index.
%  We use a dynamic fields approach to handle arbitrary field names.
%
%SYNTAX: 
%  amdarData = Amdar.filterByIndex(amdarData, amdarData.altitude > 2000); 
%
%INPUTS:
%  amdarData - structure containing Amdar data.
%  index - Boolean index, true = keep data.
%  
%OUTPUTS:
%  amdarData - structure containing Amdar data, pruned in place.
%
%EXAMPLE:
%  Suppose we want to find all data points above a certain altitude.
%  We can filter by index with the command:
%  
%    d = Amdar.filterByIndex(amdarData, amdarData.altitude > 2000);
%

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================

%% Use dynamic field names to loop over all fields in the structure.
fieldNames = fields(amdarData);
nIndex = length(index);
for i = 1:length(fieldNames)
  fn = fieldNames{i};  
  % Prune fields having the same length as our index.
  if(length(amdarData.(fn)) == nIndex)
    if(ischar(amdarData.(fn)))
      amdarData.(fn) = amdarData.(fn)(index,:);
    else
      amdarData.(fn) = amdarData.(fn)(index);
    end
  end
end
end