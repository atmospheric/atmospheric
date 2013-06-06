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

% Test the basic properties for each file type.
function test_Atmospheric_idGfs(self)
  assert(strcmpi(self.gfsHighres.product,'gfs'))
  assert(strcmpi(self.gfsHighres.verticalCoordSys,'isobaric'))
  assert(self.gfsHighres.verticalLevels == 26)
end

function test_Atmospheric_idGfsB(self)
  assert(strcmpi(self.gfsLowres.product,'gfs'));
  assert(strcmpi(self.gfsLowres.verticalCoordSys,'isobaric'));
  assert(self.gfsLowres.verticalLevels == 26)
end

function test_Atmospheric_idNam(self)
  assert(strcmpi(self.namIsobaric.product,'nam'));
  assert(strcmpi(self.namIsobaric.verticalCoordSys,'isobaric'));
  assert(self.namIsobaric.verticalLevels == 42);
end

function test_Atmospheric_idRuc(self)
  assert(strcmpi(self.rucIsobaric13km.product,'ruc'));
  assert(strcmpi(self.rucIsobaric13km.verticalCoordSys,'isobaric'));
  assert(self.rucIsobaric13km.verticalLevels == 37);
end

end
end
