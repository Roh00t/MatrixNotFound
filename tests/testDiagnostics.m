function tests = testDiagnostics
tests = functiontests(localfunctions);
end
function testMetricsAndUIContract(testCase)
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'src'));
folder = tempname; mkdir(folder);
cleanup = onCleanup(@() rmdir(folder,'s')); %#ok<NASGU>
summary = exportValidationDiagnostics([1;2;3],[1;2;4],folder,'MakePlots',false);
verifyEqual(testCase,summary.Metrics.R2,0.5,'AbsTol',1e-12);
verifyEqual(testCase,summary.Metrics.MedianAE,0);
verifyEqual(testCase,summary.Metrics.MeanBias,1/3,'AbsTol',1e-12);
saved = jsondecode(fileread(fullfile(folder,'validation_summary.json')));
verifyEqual(testCase,saved.N,3);
verifyEqual(testCase,numel(saved.Points),3);
verifyEqual(testCase,[saved.Points.SourceRow]',[1;2;3]);
savedPoints = readtable(fullfile(folder,'plot_points.csv'));
verifyEqual(testCase,savedPoints.Properties.VariableNames, ...
    {'SourceRow','Actual','Predicted','Residual'});
verifyFalse(testCase,saved.MeasuredTestAccuracy);
m = computeExtendedMetrics([2;2],[2;3]);
verifyTrue(testCase,isnan(m.R2));
verifyError(testCase,@() computeExtendedMetrics([1;2],[NaN;2]),'BuildingEnergy:MetricFinite');
end
