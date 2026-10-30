%% STEP 5: Fit the selected bagging model and create a validated submission
% Runs independently of previous workspace variables. Does not rerun CV.
% Uses the same 200-tree bagging specification evaluated in Step 4.
projectDir = fileparts(mfilename('fullpath'));
addpath(fullfile(projectDir,'src'));
assert(~isempty(which('fitrensemble')), 'BuildingEnergy:ToolboxRequired', ...
    'Statistics and Machine Learning Toolbox is required.');
if ~exist('dataDir','var')
    dataDir = fullfile(projectDir,'data');
end
[XTrain,yTrain,XTest,trainID,testID,~,yearMetadata] = loadBuildingData(dataDir);
sampleFile = fullfile(dataDir,'sample_solution.csv');
assert(isfile(sampleFile),'BuildingEnergy:MissingSample','Sample solution CSV is missing.');
sample = readtable(sampleFile);
assert(isequal(sample.id,testID),'BuildingEnergy:SampleIDs', ...
    'Sample IDs differ from test order. Resolve before training.');
artifactRoot = fullfile(projectDir,'artifacts');
if ~isfolder(artifactRoot), mkdir(artifactRoot); end
finalOutputDir = tempname(artifactRoot);
mkdir(finalOutputDir);
fprintf('Final outputs folder: %s\n',finalOutputDir);
fprintf('Fitting preprocessing on all %d labeled buildings.\n',height(XTrain));
preprocessor = fitPreprocessor(XTrain);
trainingFeatures = engineerFeatures(applyPreprocessor(XTrain,preprocessor));
config = struct('Seed',2026,'BagCycles',200,'BoostCycles',300, ...
    'NonnegativePredictions',true);
rng(config.Seed,'twister');
timer = tic;
fprintf('Training final Bag model (200 trees). Please leave MATLAB running.\n');
model = trainCandidate(trainingFeatures,yTrain,"Bag",config);
bundle = struct;
bundle.SchemaVersion = 1;
bundle.Model = compact(model);
bundle.ModelName = "Bag";
bundle.Preprocessor = preprocessor;
bundle.PredictorNames = trainingFeatures.Properties.VariableNames;
bundle.Config = config;
bundle.TrainingRows = height(XTrain);
bundle.TrainingIDs = trainID;
bundle.TrainingYearFactors = unique(yearMetadata.TrainYearFactor);
bundle.MATLABVersion = version;
bundle.ToolboxVersions = ver;
bundle.CreatedAt = char(datetime('now','TimeZone','Asia/Kuala_Lumpur'));
bundle.SelectionReason = 'Bag selected for better latest-year validation despite slightly worse random CV RMSE.';
fprintf('Predicting %d test buildings.\n',height(XTest));
testPredictions = predictBuildingEnergy(bundle,XTest);
bundlePath = fullfile(finalOutputDir,'final_bundle.mat');
save(bundlePath,'bundle','-v7.3');
% Prove saved preprocessing/model can reproduce the predictions after reload.
reloaded = load(bundlePath,'bundle');
reloadedPredictions = predictBuildingEnergy(reloaded.bundle,XTest);
assert(all(abs(testPredictions-reloadedPredictions)<= ...
    1e-12.*max(1,abs(testPredictions))), ...
    'BuildingEnergy:BundleReload','Saved model predictions changed after reload.');
submissionPath = fullfile(finalOutputDir,'submission.csv');
submission = exportBuildingSubmission(testID,reloadedPredictions,sampleFile,submissionPath);
fprintf('\nStep 5 complete in %.1f seconds.\n',toc(timer));
fprintf('Verified %d rows; columns id,site_eui; matching IDs; finite predictions.\n',height(submission));
fprintf('Submission CSV: %s\n',submissionPath);
fprintf('Reusable model: %s\n',bundlePath);
disp(submission(1:min(5,height(submission)),:));
fprintf('The CSV is saved locally; it has not been uploaded to any competition.\n');
