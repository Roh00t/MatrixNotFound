%% Controlled comparison requested by the team
% Model 1: Tree with all cleaned predictors and missingness flags.
% Model 2: Same Tree settings with the eight approved factors and their flags.
% Model 3: LSBoost with exactly the same selected inputs as Model 2.
% All models use the same five folds plus the same latest-year holdout.
projectDir = fileparts(fileparts(mfilename('fullpath')));  % repository root (this script lives in crosscheck/)
addpath(fullfile(projectDir,'src'));
if ~exist('dataDir','var'), dataDir = fullfile(projectDir,'data'); end
[XTrain,yTrain,~,trainID,~,~,yearMetadata] = loadBuildingData(dataDir);
selectedFactors = {'floor_area','energy_star_rating','year_built', ...
    'heating_degree_days','cooling_degree_days', ...
    'State_Factor','building_class','facility_type'};
config = buildingConfig;
artifactRoot = fullfile(projectDir,'artifacts');
if ~isfolder(artifactRoot), mkdir(artifactRoot); end
comparisonDir = tempname(artifactRoot); mkdir(comparisonDir);
fprintf('Three-model experiment folder: %s\n',comparisonDir);
fprintf('Selected factors: %s\n',strjoin(selectedFactors,', '));
threeModelResults = compareThreeModels(XTrain,yTrain,yearMetadata.TrainYearFactor, ...
    trainID,selectedFactors,config,comparisonDir);
disp(threeModelResults.Metrics);
% Export metrics, UI data and graphs separately for each model and split.
for k = 1:3
    name = threeModelResults.Names(k);
    exportValidationDiagnostics(yTrain,threeModelResults.OOF(:,k), ...
        fullfile(comparisonDir,name,'oof'),'Model',name,'Validation','Five-fold OOF');
    rows = threeModelResults.TemporalRows;
    exportValidationDiagnostics(yTrain(rows),threeModelResults.Temporal(:,k), ...
        fullfile(comparisonDir,name,'latest_year'), ...
        'Model',name,'Validation','Latest-year holdout');
end
fprintf('Three-model comparison complete. Results and graphs: %s\n',comparisonDir);
fprintf('This experiment did not replace the final model or submission.\n');
