function tests = testExportBuildingSubmission
tests = functiontests(localfunctions);
end
function testRoundTripAndBadPredictions(testCase)
addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))),'src'));
folder = tempname; mkdir(folder);
cleanup = onCleanup(@() rmdir(folder,'s')); %#ok<NASGU>
ids = [21;7];
sampleFile = fullfile(folder,'sample.csv');
outputFile = fullfile(folder,'submission.csv');
writetable(table(ids,zeros(2,1),'VariableNames',{'id','site_eui'}),sampleFile);
result = exportBuildingSubmission(ids,[12.3;45.6],sampleFile,outputFile);
verifyEqual(testCase,result.id,ids);
verifyError(testCase,@() exportBuildingSubmission(ids,[NaN;1],sampleFile,outputFile), ...
    'BuildingEnergy:SubmissionValues');
verifyError(testCase,@() exportBuildingSubmission(flipud(ids),[1;2],sampleFile,outputFile), ...
    'BuildingEnergy:SubmissionTemplate');
end
