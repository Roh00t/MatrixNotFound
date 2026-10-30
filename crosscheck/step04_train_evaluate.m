%% STEP 4: Compare models using five-fold and later-year validation
% This can take a while: 18 nontrivial fits (3 models x 6 splits).
% Progress is printed after each fit and saved after every completed fold.
% Do NOT use the full-training cleaned preview tables from Steps 2/3 here.
projectDir = fileparts(fileparts(mfilename('fullpath')));  % repository root (this script lives in crosscheck/)
addpath(fullfile(projectDir,'src'));
assert(~isempty(which('fitrensemble')) && ~isempty(which('cvpartition')), ...
    'BuildingEnergy:ToolboxRequired', ...
    'Statistics and Machine Learning Toolbox is required for Step 4.');
if ~exist('dataDir','var')
    dataDir = fullfile(projectDir,'data');
end
[XTrain,yTrain,~,trainID,~,~,yearMetadata] = loadBuildingData(dataDir);
config = buildingConfig;
if ~isfolder(fullfile(projectDir,'artifacts'))
    mkdir(fullfile(projectDir,'artifacts'));
end
outputDir = tempname(fullfile(projectDir,'artifacts'));
mkdir(outputDir);
fprintf('Results folder: %s\n',outputDir);
save(fullfile(outputDir,'config.mat'),'config');
results = crossValidateModels(XTrain,yTrain, ...
    yearMetadata.TrainYearFactor,config,outputDir);
disp(results.Summary);
writetable(results.Summary,fullfile(outputDir,'model_comparison.csv'));
oofTable = table(trainID,yTrain,results.FoldID, ...
    'VariableNames',{'id','actual','fold'});
for candidate = 1:numel(results.Names)
    name = char(results.Names(candidate));
    oofTable.([name '_prediction']) = results.OOF(:,candidate);
end
writetable(oofTable,fullfile(outputDir,'oof_predictions.csv'));
rows = results.TemporalRows;
temporalTable = table(trainID(rows),yTrain(rows), ...
    'VariableNames',{'id','actual'});
for candidate = 1:numel(results.Names)
    name = char(results.Names(candidate));
    temporalTable.([name '_prediction']) = results.TemporalPredictions(:,candidate);
end
writetable(temporalTable,fullfile(outputDir,'temporal_predictions.csv'));
metricReport = validationMetricTable(oofTable,temporalTable);
writetable(metricReport,fullfile(outputDir,'validation_metrics.csv'));
save(fullfile(outputDir,'evaluation.mat'),'results','trainID','yTrain');
fprintf('\nStep 4 complete. Lower RMSE is better.\n');
fprintf('Review BOTH OOF_RMSE and TemporalRMSE before choosing the final model.\n');
fprintf('These are validation scores, not training scores or independent test scores.\n');
fprintf('No final model or submission has been created yet.\n');
