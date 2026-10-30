%% STEP 3: Add useful building and weather clues
% Run this saved script by name. It runs Step 2 first for a reproducible preview.
% Original CSVs are never modified. No model is trained in this step.
projectDir = fileparts(fileparts(mfilename('fullpath')));  % repository root (this script lives in crosscheck/)
run(fullfile(projectDir, 'crosscheck', 'step02_preprocess.m'));

[XTrainFeatures, trainFeatureReport] = engineerFeatures(XTrainClean);
[XTestFeatures, testFeatureReport] = engineerFeatures(XTestClean);
assert(isequal(XTrainFeatures.Properties.VariableNames, ...
    XTestFeatures.Properties.VariableNames), ...
    'BuildingEnergy:FeatureSchema', 'Train and test feature names must match.');
fprintf('\nNew training feature ranges:\n');
disp(trainFeatureReport);
fprintf('New test feature ranges:\n');
disp(testFeatureReport);
fprintf('Step 3 complete: %d training rows, %d test rows, %d model inputs.\n', ...
    height(XTrainFeatures), height(XTestFeatures), width(XTrainFeatures));
fprintf('Added %d features. No building age or wind components were assumed.\n', ...
    height(trainFeatureReport));
fprintf('For validation, repeat cleaning inside each fold before engineering features.\n');
