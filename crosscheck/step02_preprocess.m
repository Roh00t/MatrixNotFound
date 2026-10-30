%% STEP 2: Learn and apply missing-value cleaning
% Run this saved script by name from MATLAB, as with step01_ingest.
projectDir = fileparts(fileparts(mfilename('fullpath')));  % repository root (this script lives in crosscheck/)
addpath(fullfile(projectDir, 'src'));
if ~exist('dataDir', 'var')
    dataDir = fullfile(projectDir, 'data');
end
[XTrain, yTrain, XTest, trainID, testID, ingestionReport, yearMetadata] = ...
    loadBuildingData(dataDir);

% This full-training fit previews cleaning for final inference.
% For model evaluation, fit a NEW state on each fold's training rows only.
preprocessor = fitPreprocessor(XTrain);
[XTrainClean, trainCleaningReport] = applyPreprocessor(XTrain, preprocessor);
[XTestClean, testCleaningReport] = applyPreprocessor(XTest, preprocessor);
cleaningReport = table(trainCleaningReport.Predictor, ...
    trainCleaningReport.ValuesFilledOrMapped, ...
    testCleaningReport.ValuesFilledOrMapped, ...
    'VariableNames', {'Predictor','TrainRepaired','TestRepaired'});
disp(cleaningReport);
fprintf('Cleaned %d training rows and %d test rows; %d model inputs.\n', ...
    height(XTrainClean), height(XTestClean), width(XTrainClean));
fprintf('Year_Factor excluded from model inputs; raw values saved in yearMetadata.\n');
fprintf('Excluded all-missing training columns: %s\n', ...
    strjoin(preprocessor.DroppedNames, ', '));
fprintf('Step 2 complete. Original CSV files were not modified.\n');
