classdef TestAtmospheric < TestCase
%TESTATMOSPHERIC Unit tests for the Atmospheric class
%
% SYNTAX:
%   TestAtmospheric.all();
%
% NOTES:
%  - Tests the basic properties defined by the Atmospheric() constructor.
%  - Truth values are determined from direct examination of the detailed
%     Netcdf metadata dump, as provided by Atmospheric.details()

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
  rucIsobaric40kmA = Atmospheric(AtmoSampleData.rucIsobaric40kmA);
  rucIsobaric40kmB = Atmospheric(AtmoSampleData.rucIsobaric40kmB);
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
function test_Atmospheric_emptyConstructor(self) %#ok<*MANU,*DEFNU>
  atmo = Atmospheric();
  assert(isempty(atmo.forecastDate))
  assert(isempty(atmo.forecastOutlook))
  assert(isempty(atmo.variables))
  assert(isempty(atmo.latitude))
  assert(isempty(atmo.longitude))
  assert(isempty(atmo.projectedDate))
end

%% GFS Highres
function test_Atmospheric_idGfsHighres_A(self)
  assert(strcmpi(self.gfsHighres.product,'gfs'))
end
function test_Atmospheric_idGfsHighres_B(self)
  assert(strcmpi(self.gfsHighres.verticalCoordSys,'isobaric'))
end
function test_Atmospheric_idGfsHighres_C(self)
  assert(self.gfsHighres.verticalLevels == 26)
end
function test_Atmospheric_idGfsHighres_D(self)
  assert(self.gfsHighres.forecastDate == datenum(2013,6,3,12,0,0))
end

%% GFS Lowres
function test_Atmospheric_idGfsLoweres_A(self)
  assert(strcmpi(self.gfsLowres.product,'gfs'))
end
function test_Atmospheric_idGfsLoweres_B(self)
  assert(strcmpi(self.gfsLowres.verticalCoordSys,'isobaric'))
end
function test_Atmospheric_idGfsLoweres_C(self)
  assert(self.gfsLowres.verticalLevels == 26)
end
function test_Atmospheric_idGfsLowhres_D(self)
  assert(self.gfsLowres.forecastDate == datenum(2007,1,18,0,0,0))
end

%% NAM
function test_Atmospheric_idNam_A(self)
  assert(strcmpi(self.namIsobaric.product,'nam'))
end
function test_Atmospheric_idNam_B(self)
  assert(strcmpi(self.namIsobaric.verticalCoordSys,'isobaric'))
end
function test_Atmospheric_idNam_C(self)
  assert(self.namIsobaric.verticalLevels == 42)
end
function test_Atmospheric_idNamIsobaric_D(self)
  assert(self.namIsobaric.forecastDate == datenum(2013,6,2,18,0,0))
end

%% RUC Isobaric 13km
function test_Atmospheric_idRucIsobaric13_A(self)
  assert(strcmpi(self.rucIsobaric13km.product,'ruc'))
end
function test_Atmospheric_idRucIsobaric13_B(self)
  assert(strcmpi(self.rucIsobaric13km.verticalCoordSys,'isobaric'))
end
function test_Atmospheric_idRucIsobaric13_C(self)
  assert(self.rucIsobaric13km.verticalLevels == 37)
end
function test_Atmospheric_idRucIsobaric13_D(self)
  assert(self.rucIsobaric13km.forecastDate == datenum(2010,2,19,7,0,0))
end

%% RUC Isobaric 40km
function test_Atmospheric_idRucIsobaric40_A(self)
  assert(strcmpi(self.rucIsobaric40kmA.product,'ruc'))
end
function test_Atmospheric_idRucIsobaric40_B(self)
  assert(strcmpi(self.rucIsobaric40kmA.verticalCoordSys,'isobaric'))
end
function test_Atmospheric_idRucIsobaric40_C(self)
  assert(self.rucIsobaric40kmA.verticalLevels == 37)
end
function test_Atmospheric_idRucIsobaric40_D(self)
  assert(self.rucIsobaric40kmA.forecastDate == datenum(2011,4,30,7,0,0))
end

%% RUC Hybrid 13km
function test_Atmospheric_idRucHybrid13_A(self)
  assert(strcmpi(self.rucHybrid13km.product,'ruc'))
end
function test_Atmospheric_idRucHybrid13_B(self)
  assert(strcmpi(self.rucHybrid13km.verticalCoordSys,'hybrid'))
end
function test_Atmospheric_idRucHybrid13_C(self)
  assert(self.rucHybrid13km.verticalLevels == 50)
end
function test_Atmospheric_idRucHybrid13_D(self)
  assert(self.rucHybrid13km.forecastDate == datenum(2012,1,19,0,0,0))
end

%% RUC Hybrid 20km
function test_Atmospheric_idRucHybrid20_A(self)
  assert(strcmpi(self.rucHybrid20km.product,'ruc'));
end
function test_Atmospheric_idRucHybrid20_B(self)
  assert(strcmpi(self.rucHybrid20km.verticalCoordSys,'hybrid'));
end
function test_Atmospheric_idRucHybrid20_C(self)
  assert(self.rucHybrid20km.verticalLevels == 50);
end
function test_Atmospheric_idRucHybrid20_D(self)
  assert(self.rucHybrid20km.forecastDate == datenum(2005,1,13,6,0,0))
end

%% RAP Hybrid 13km
function test_Atmospheric_idRapHybrid13_A(self)
  assert(strcmpi(self.rapHybrid13km.product,'rap'));
end
function test_Atmospheric_idRapHybrid13_B(self)
  assert(strcmpi(self.rapHybrid13km.verticalCoordSys,'hybrid'));
end
function test_Atmospheric_idRapHybrid13_C(self)
  assert(self.rapHybrid13km.verticalLevels == 50);
end
function test_Atmospheric_idRapHybrid13_D(self)
  assert(self.rapHybrid13km.forecastDate == datenum(2013,6,2,19,0,0))
end

%% RAP Isobaric 13km
function test_Atmospheric_idRapIsobaric13_A(self)
  assert(strcmpi(self.rapIsobaric13km.product,'rap'));
end
function test_Atmospheric_idRapIsobaric13_B(self)
  assert(strcmpi(self.rapIsobaric13km.verticalCoordSys,'isobaric'));
end
function test_Atmospheric_idRapIsobaric13_C(self)
  assert(self.rapIsobaric13km.verticalLevels == 37);
end
function test_Atmospheric_idRapIsobaric13_D(self)
  assert(self.rapIsobaric13km.forecastDate == datenum(2013,6,2,19,0,0))
end


end
end
