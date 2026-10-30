%% STEP 1: Load and inspect the building data
projectDir = fileparts(fileparts(mfilename('fullpath')));  % repository root (this script lives in crosscheck/)
addpath(fullfile(projectDir,'src'));
if ~exist('dataDir','var')
    dataDir = fullfile(projectDir,'data');
end
[XTrain,yTrain,XTest,trainID,testID,ingestionReport,yearMetadata] = loadBuildingData(dataDir);
disp(ingestionReport);
fprintf('Loaded %d training rows, %d test rows, %d predictors.\n',height(XTrain),height(XTest),width(XTrain));
