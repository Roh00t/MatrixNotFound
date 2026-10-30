function tests = testRegressionMetrics
tests = functiontests(localfunctions);
end
function testKnownValues(testCase)
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'src'));
m = regressionMetrics([1;2;3],[1;2;4]);
verifyEqual(testCase,m.MSE,1/3,'AbsTol',1e-12);
verifyEqual(testCase,m.MAE,1/3,'AbsTol',1e-12);
verifyEqual(testCase,m.RMSE,sqrt(1/3),'AbsTol',1e-12);
verifyEqual(testCase,m.R2,0.5,'AbsTol',1e-12);
m = regressionMetrics([2;2],[2;3]);
verifyTrue(testCase,isnan(m.R2));
m = regressionMetrics([1;2;3],[10;10;10]);
verifyLessThan(testCase,m.R2,0);
verifyError(testCase,@() regressionMetrics([1;2],[1,2]),'BuildingEnergy:MetricShape');
verifyError(testCase,@() regressionMetrics([1;2],[1;Inf]),'BuildingEnergy:MetricFinite');
end
