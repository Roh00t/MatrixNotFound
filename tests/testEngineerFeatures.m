function tests = testEngineerFeatures
tests = functiontests(localfunctions);
end

function testFormulasAndZeroLoad(testCase)
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'src'));
X = table([100;200;0],[10;0;0],[5;0;4], ...
    'VariableNames',{'floor_area','heating_degree_days','cooling_degree_days'});
[actual, report] = engineerFeatures(X);
verifyEqual(testCase,actual.area_heating_load,[1000;0;0]);
verifyEqual(testCase,actual.area_cooling_load,[500;0;0]);
verifyEqual(testCase,actual.total_degree_days,[15;0;4]);
verifyEqual(testCase,actual.heating_degree_fraction,[2/3;0;0],'AbsTol',1e-12);
verifyEqual(testCase,actual.log_floor_area,log1p([100;200;0]));
verifyEqual(testCase,actual(:,X.Properties.VariableNames),X);
verifyEqual(testCase,height(report),5);
verifyError(testCase,@() engineerFeatures(actual),'BuildingEnergy:FeatureCollision');
end

function testRejectInvalidInputs(testCase)
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'src'));
X = table(-1,10,5, ...
    'VariableNames',{'floor_area','heating_degree_days','cooling_degree_days'});
verifyError(testCase,@() engineerFeatures(X),'BuildingEnergy:InvalidFeatureInput');
X.floor_area = NaN;
verifyError(testCase,@() engineerFeatures(X),'BuildingEnergy:InvalidFeatureInput');
end
