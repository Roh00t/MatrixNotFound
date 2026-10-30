%% STEP 1: Load and validate the WiDS building energy data
% Place train.csv and test.csv in the data folder beside this script.
% Alternatively, define dataDir before running this script.
projectDir = fileparts(mfilename('fullpath'));
addpath(fullfile(projectDir, 'src'));
if ~exist('dataDir', 'var')
    dataDir = fullfile(projectDir, 'data');
end

% IDs are retained for submission but excluded from model predictors.
[XTrain, yTrain, XTest, trainID, testID, ingestionReport] = ...
    loadBuildingData(dataDir);
disp(ingestionReport);
fprintf('Loaded %d training rows, %d test rows, and %d predictors.\n', ...
    height(XTrain), height(XTest), width(XTrain));
