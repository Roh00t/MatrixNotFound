%% Predicting Building Energy Consumption (site_eui) - Main Pipeline
% Learn to Hack: MATLAB Edition 2026 - Team MatrixNotFound
%
% Runs the full pipeline end to end. Each stage lives in its own function
% under src/ so it can be read, tested and re-run independently:
%
%   1. loadData            - ingest CSVs and cast column types
%   2. preprocessData      - impute missing values, align categories
%   3. engineerFeatures    - building age, thermal-load and wind features
%   4. trainModels         - baseline tree vs. ensembles, 5-fold CV RMSE
%   5. writeSubmission     - predict test set and write submission.csv

clear; clc;

projectRoot = fileparts(mfilename("fullpath"));
addpath(fullfile(projectRoot, "src"));

dataDir = fullfile(projectRoot, "data");
rng(42, "twister");   % reproducible CV folds and ensemble training

%% Step 1: Data ingestion and type casting
[trainTbl, testTbl, yTrain, testIds] = loadData(dataDir);

summary(trainTbl(:, ["Year_Factor", "State_Factor", "building_class", "facility_type"]))

%% Step 2: Preprocessing and imputation
% Fill values are learned on train only; Year_Factor becomes an ordinal
% number because the test set is entirely year 7 (unseen in training).
[trainTbl, testTbl] = preprocessData(trainTbl, testTbl);

%% Step 3: Feature engineering
% Building age, seasonal thermal load, and efficiency-scale interactions.
trainTbl = engineerFeatures(trainTbl);
testTbl  = engineerFeatures(testTbl);
fprintf("Engineered features: %d predictors\n", width(trainTbl));

%% Step 4: Model selection and validation
% Baseline tree vs. LSBoost, scored with Leave-One-Year-Out CV (mirrors the
% unseen test year) and random 5-fold CV (for contrast).
[finalModel, cvResults] = trainModels(trainTbl, yTrain);
