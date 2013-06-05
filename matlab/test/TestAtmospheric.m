classdef TestAtmospheric < TestCase
%TESTATMOSPHERIC Unit tests for the Atmospheric class
%
% SYNTAX:
%   TestAtmospheric.all

% Copyright 2013, The MITRE Corporation.  All rights reserved.
%==========================================================================
properties
  gfsHighres = Atmospheric(AtmoSampleData.gfsHighresIsobaric);
  gfsLowres = Atmospheric(AtmoSampleData.gfsLowresIsobaric);
  
  namIsobaric = Atmospheric(AtmoSampleData.namIsobaric);
  
  rapHybrid13km = Atmospheric(AtmoSampleData.rapHybrid13km);
  rapIsobaric13km = Atmospheric(AtmoSampleData.rapIsobaric13km);   
  
  rucHybrid13km = Atmospheric(AtmoSampleData.rucHybrid13km);
  rucHybrid20km = Atmospheric(AtmoSampleData.rucHybrid20km);
  rucIsobaric13km = Atmospheric(AtmoSampleData.rucIsobaric13km);
end

methods (Static)
  function allPassed = all()
    allPassed = TestSuite('TestAtmospheric').run;
  end
end

methods
function self = TestAtmospheric(name)
  if(~exist('AtmoSampleData','class'))
    error('Atmo:pathdef',['Unable to locate class ''AtmoSampleData'', ' ...
     'required for testing. Please clone from ' ...
     'https://github.com/atmospheric/sampledata and add to your ' ...
     'Matlab classpath.'])
  end  
    
  % Test suite constructor, required by XUnit test framework.
  self = self@TestCase(name);
end        

%% Test constructor
function test_Atmospheric_constructor(self) %#ok<*MANU,*DEFNU>
  atmo = Atmospheric();
  assert(isempty(atmo.forecastDate))
  assert(isempty(atmo.forecastOutlook))
  assert(isempty(atmo.variables))
  assert(isempty(atmo.latitude))
  assert(isempty(atmo.longitude))
  assert(isempty(atmo.projectedDate))
end

function test_Atmospheric_idGfs(self)
  assert(strcmp(self.gfsHighres.product,'gfs'));
end

function test_Atmospheric_idGfsB(self)
  assert(strcmp(self.gfsLowres.product,'gfs'));
end

function test_Atmospheric_idNam(self)
  assert(strcmp(self.namIsobaric.product,'nam'));
end

function test_Atmospheric_idRuc(self)
  assert(strcmp(self.rucIsobaric13km.product,'ruc'));
end

% function test_Atmospheric_A(self)
%   atmo = Atmospheric(self.typeA);
%   assert(atmo.forecastDate == self.typeA)
%   assert(atmo.projectedDate == self.typeA)
%   assert(length(atmo.variables) == 66)
% end
% function test_Atmospheric_B(self)
%   atmo = Atmospheric(self.typeB);
%   assert(atmo.forecastDate == self.typeB)
%   assert(atmo.projectedDate == self.typeB)
%   assert(length(atmo.variables) == 92)
% end
% function test_Atmospheric_C(self)
%   atmo = Atmospheric(self.typeC);
%   assert(atmo.forecastDate == self.typeC)
%   assert(atmo.projectedDate == self.typeC)
%   assert(length(atmo.variables) == 70)
% end
% function test_Atmospheric_D(self)
%   atmo = Atmospheric(self.typeD);
%   assert(atmo.forecastDate == self.typeD)
%   assert(atmo.projectedDate == self.typeD)
%   assert(length(atmo.variables) == 69)
% end

end
end
