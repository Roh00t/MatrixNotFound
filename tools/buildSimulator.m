%% Build the 3D simulator's model file from saved results
% Exports the winning model to dashboard/model.js so dashboard/simulator.html
% can run it in the browser. Run after main.m has produced
% results/pipelineResults.mat and results/ntu_landmarks.csv; takes about a
% minute and retrains nothing.
%
% The 3D building models themselves are prepared once with Blender:
%   /Applications/Blender.app/Contents/MacOS/Blender -b -P tools/prepare_models.py
% Then check the browser model against MATLAB with:
%   node tests/web/checkPredict.mjs

projectRoot = fileparts(fileparts(mfilename("fullpath")));
addpath(fullfile(projectRoot, "src"));

saved = load(fullfile(projectRoot, "results", "pipelineResults.mat"), "finalModel");
[trainTbl, testTbl, yTrain] = loadData(fullfile(projectRoot, "data"));

[~, testPrepared] = preprocessData(trainTbl, testTbl);
testPrepared = engineerLegacyFeatures(testPrepared);

exportModelForWeb(saved.finalModel, trainTbl, yTrain, testPrepared, ...
    fullfile(projectRoot, "results", "ntu_landmarks.csv"), ...
    fullfile(projectRoot, "dashboard", "model.js"), ...
    fullfile(projectRoot, "tests", "web", "model_check.json"));
