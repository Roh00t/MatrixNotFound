%% Predicting Building Energy Consumption (site_eui) - Main Pipeline
% Learn to Hack: MATLAB Edition 2026 - Team MatrixNotFound
%
% Runs the full pipeline end to end (about 30-40 minutes on a laptop, most
% of it LSBoost cross-validation). Each stage is a function under src/:
%
%   Step 1    loadData           read CSVs, cast types, align categories
%   Step 2    preprocessData     train-only imputation + missingness flags
%   Step 3    engineerFeatures   building age, thermal load, efficiency scale
%   Step 4    trainModels        tree vs. 3 LSBoost iterations, LOYO CV
%   Step 5    writeSubmission    predict year 7, validate, write CSV
%   Impact    retrofitRadar      rank buildings using more energy than expected
%             makeFigures        save presentation figures to figures/
%
% Steps 2-3 run inside every cross-validation fold (fit on the training
% fold only) and once more on all training rows to prepare the test set.

clear; clc;
rng(42, "twister");   % reproducible CV folds and ensemble training

projectRoot = fileparts(mfilename("fullpath"));
addpath(fullfile(projectRoot, "src"));

dataDir    = fullfile(projectRoot, "data");
resultsDir = fullfile(projectRoot, "results");
if ~isfolder(resultsDir)
    mkdir(resultsDir);
end

%% Step 1: Data ingestion and type casting
[trainTbl, testTbl, yTrain, testIds] = loadData(dataDir);

summary(trainTbl(:, ["Year_Factor", "State_Factor", "building_class", "facility_type"]))

%% Step 4: Model selection with leave-one-year-out validation
% The test set is entirely Year_Factor 7, which never appears in training,
% so each candidate is scored by holding out one whole year at a time.
% Preprocessing (Step 2) and feature engineering (Step 3) are refit inside
% every training fold to keep held-out rows from leaking into them.
[finalModel, cvReport] = trainModels(trainTbl, yTrain);

%% Steps 2-3 for the test set: fit on all training rows, apply to test
[~, testPrepared] = preprocessData(trainTbl, testTbl);
testPrepared = engineerFeatures(testPrepared);

%% Step 5: Predict the test set and write the submission
submission = writeSubmission(finalModel, testPrepared, testIds, ...
    fullfile(projectRoot, "submission.csv"));

sampleSolution = readtable(fullfile(dataDir, "sample_solution.csv"));
assert(isequal(submission.id, sampleSolution.id), ...
    "main:idMismatch", "Submission ids do not match sample_solution.csv.");

% Save only what later analysis needs: the compact winning model, the
% comparison tables, and out-of-fold predictions (no ensembles of losers).
save(fullfile(resultsDir, "pipelineResults.mat"), "finalModel", "cvReport", "yTrain");
fprintf("Saved results to %s\n", fullfile(resultsDir, "pipelineResults.mat"));

%% Impact: Retrofit Radar shortlist and presentation figures
% Compare each building's actual EUI with what the model expects for similar
% buildings, rank by excess energy, and save the figures used in the slides.
shortlist = retrofitRadar(trainTbl, yTrain, cvReport.outOfFoldPredictions, ...
    fullfile(resultsDir, "retrofit_shortlist.csv"));
makeFigures(cvReport, finalModel, yTrain, shortlist, fullfile(projectRoot, "figures"));

%% Report: export the live-script walkthrough to HTML
% Non-critical: the submission is already written, so a failed export only warns.
try
    export(fullfile(projectRoot, "ProjectReport.m"), fullfile(projectRoot, "ProjectReport.html"), ...
        Format="html", Run=true);
    fprintf("Exported ProjectReport.html\n");
catch err
    warning("main:reportExportFailed", "ProjectReport export failed: %s", err.message);
end
