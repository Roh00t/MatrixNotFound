function tests = testRMSE
tests = functiontests(localfunctions);
end
function testKnownError(testCase)
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'src'));
verifyEqual(testCase,rmse([0;0],[3;4]),sqrt(12.5),'AbsTol',1e-12);
verifyError(testCase,@() rmse([1;2],[1,2]),'BuildingEnergy:MetricShape');
verifyError(testCase,@() rmse([1;2],[1;NaN]),'BuildingEnergy:MetricFinite');
end
