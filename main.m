%% Predicting Building Energy Consumption (site_eui) - Main Pipeline
% Learn to Hack: MATLAB Edition 2026 - Team MatrixNotFound
%
% Runs the full pipeline end to end. Each stage lives in its own function
% under src/ so it can be read, tested and re-run independently:
%
%   1. loadData            - ingest CSVs and cast column types
%   2. trainModels         - fold-local preprocessing, validation, final fit
%   3. preprocessData      - fit train-only imputation and apply to test
%   4. engineerFeatures    - building age and thermal-load interactions
%   5. writeSubmission     - predict test set and write submission.csv

clear; clc;

projectRoot = fileparts(mfilename("fullpath"));
addpath(fullfile(projectRoot, "src"));

dataDir = fullfile(projectRoot, "data");
rng(42, "twister");   % reproducible CV folds and ensemble training

%% Step 1: Data ingestion and type casting
[trainTbl, testTbl, yTrain, testIds] = loadData(dataDir);

summary(trainTbl(:, ["Year_Factor", "State_Factor", "building_class", "facility_type"]))

%% Step 2: Model selection and validation
% Imputation and feature engineering are learned inside each CV training
% fold to prevent validation data from influencing preprocessing.
[finalModel, cvResults] = trainModels(trainTbl, yTrain);

%% Step 3: Fit preprocessing on all training rows and prepare the test set
[trainTbl, testTbl] = preprocessData(trainTbl, testTbl);
trainTbl = engineerFeatures(trainTbl);
testTbl  = engineerFeatures(testTbl);
fprintf("Engineered features: %d predictors\n", width(trainTbl));

%% Step 4: Write the competition submission
submissionFile = fullfile(projectRoot, "submission.csv");
submission = writeSubmission(finalModel, testTbl, testIds, submissionFile);
