%% Predicting Building Energy Consumption (site_eui) - Main Pipeline
% Learn to Hack: MATLAB Edition 2026 - Team MatrixNotFound
%
% Runs the full pipeline end to end (about 25-35 minutes on a laptop, most
% of it LSBoost cross-validation). Each stage is a function under src/:
%
%   Step 1    loadData           read CSVs, cast types, align categories
%   Step 2    preprocessData     train-only imputation + missingness flags
%   Step 3    engineerFeatures   building age, thermal load, efficiency scale
%   Step 4    trainModels        tree vs. 3 LSBoost iterations, LOYO CV
%   Step 5    writeSubmission    predict year 7, validate, write CSV
%   Impact    retrofitRadar      rank buildings using more energy than expected
%             makeFigures        presentation figures in figures/
%             makeHeatmaps       matrix diagnostics in figures/
%             makeIterationFigures  model journey and per-year RMSE grid
%             computeExtendedMetrics  MAE, MSE, RMSE, R^2 (out-of-fold)
%             simulateNTULandmarks  what-if for The Hive and The Arc
%   Outputs   writeDashboard     live results page: open dashboard/index.html
%
% Steps 2-3 run inside every cross-validation fold (fit on the training
% fold only) and once more on all training rows to prepare the test set.
%
% Open dashboard/index.html in a browser while this runs: it refreshes
% itself and shows each model's score as soon as it is ready.

clear; clc;
rng(42, "twister");   % reproducible CV folds and ensemble training

projectRoot = fileparts(mfilename("fullpath"));
addpath(fullfile(projectRoot, "src"));

dataDir      = fullfile(projectRoot, "data");
resultsDir   = fullfile(projectRoot, "results");
figuresDir   = fullfile(projectRoot, "figures");
dashboardDir = fullfile(projectRoot, "dashboard");
if ~isfolder(resultsDir)
    mkdir(resultsDir);
end

dash = struct("status", "running", "stage", "Step 1 of 6: loading data", ...
    "step", 0, "totalSteps", 6);
writeDashboard(dashboardDir, dash);

%% Step 1: Data ingestion and type casting
[trainTbl, testTbl, yTrain, testIds] = loadData(dataDir);

summary(trainTbl(:, ["Year_Factor", "State_Factor", "building_class", "facility_type"]))

dash.data  = struct("trainRows", height(trainTbl), "testRows", height(testTbl), ...
    "predictors", width(trainTbl));
dash.years = string(unique(str2double(string(trainTbl.Year_Factor))))';
dash = advanceDashboard(dash, dashboardDir, ...
    "Step 2 of 6: cross-validating 4 models, one held-out year at a time (about 20 minutes)");

%% Step 4: Model selection with leave-one-year-out validation
% The test set is entirely Year_Factor 7, which never appears in training,
% so each candidate is scored by holding out one whole year at a time.
% Preprocessing (Step 2) and feature engineering (Step 3) are refit inside
% every training fold to keep held-out rows from leaking into them.
[finalModel, cvReport] = trainModels(trainTbl, yTrain, ProgressFcn= ...
    @(results, perYearRMSE) writeDashboard(dashboardDir, withModels(dash, results, perYearRMSE)));

dash = withModels(dash, cvReport.results, cvReport.perYearRMSE{:, :});
dash = advanceDashboard(dash, dashboardDir, "Step 3 of 6: preparing the test set");

%% Steps 2-3 for the test set: fit on all training rows, apply to test
[trainPrepared, testPrepared] = preprocessData(trainTbl, testTbl);
trainPrepared = engineerFeatures(trainPrepared);
testPrepared  = engineerFeatures(testPrepared);

dash = advanceDashboard(dash, dashboardDir, "Step 4 of 6: writing and checking submission.csv");

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

dash = advanceDashboard(dash, dashboardDir, "Step 5 of 6: Retrofit Radar and figures");

%% Impact: Retrofit Radar shortlist, presentation figures and heatmaps
% Compare each building's actual EUI with what the model expects for similar
% buildings, rank by excess energy, and save the figures used in the slides.
[shortlist, radar] = retrofitRadar(trainTbl, yTrain, cvReport.outOfFoldPredictions, ...
    fullfile(resultsDir, "retrofit_shortlist.csv"));
makeFigures(cvReport, finalModel, yTrain, shortlist, figuresDir);
makeHeatmaps(trainTbl, trainPrepared, yTrain, cvReport.outOfFoldPredictions, radar, figuresDir);
makeIterationFigures(cvReport, figuresDir);

% Accuracy beyond RMSE, on out-of-fold predictions (data the model never saw).
metrics = computeExtendedMetrics(yTrain, cvReport.outOfFoldPredictions);
writetable(metrics, fullfile(resultsDir, "extended_metrics.csv"));
disp(metrics)

% Local what-if: two NTU landmarks run through the same pipeline.
ntuScenario = simulateNTULandmarks(trainTbl, finalModel, yTrain, figuresDir);
writetable(ntuScenario, fullfile(resultsDir, "ntu_landmarks.csv"));

dash = advanceDashboard(dash, dashboardDir, "Step 6 of 6: exporting ProjectReport.html");

%% Report: export the live-script walkthrough to HTML
% Non-critical: the submission is already written, so a failed export only warns.
try
    export(fullfile(projectRoot, "ProjectReport.m"), fullfile(projectRoot, "ProjectReport.html"), ...
        Format="html", Run=true);
    fprintf("Exported ProjectReport.html\n");
catch err
    warning("main:reportExportFailed", "ProjectReport export failed: %s", err.message);
end

%% Dashboard: publish the final results
% The step pipeline's scores (release/model_comparison.csv) are shown as an
% independent cross-check when that file is present.
dash = summarizeForDashboard(dash, cvReport, yTrain, shortlist, radar, submission, ...
    fullfile(projectRoot, "release", "model_comparison.csv"));
dash.metrics = metrics;
dash.ntu     = ntuScenario;
dash.status = "complete";
dash = advanceDashboard(dash, dashboardDir, "All steps complete");
fprintf("Dashboard ready: %s\n", fullfile(dashboardDir, "index.html"));

% =========================================================================
function dash = advanceDashboard(dash, dashboardDir, stage)
%ADVANCEDASHBOARD Move the dashboard to the next stage and save it.
    dash.step  = min(dash.step + 1, dash.totalSteps);
    dash.stage = stage;
    writeDashboard(dashboardDir, dash);
end

function dash = withModels(dash, results, perYearRMSE)
%WITHMODELS Attach (partial or final) model scores to the dashboard struct.
    dash.modelTable = results;
    dash.perYear    = perYearRMSE;
end
