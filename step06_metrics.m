%% Additional presentation metrics: reuse existing validation predictions
% No training. Defaults to the completed Step 4 run used for the release.
% Set evaluationDir explicitly to summarize a different completed run.
projectDir = fileparts(mfilename('fullpath'));
addpath(fullfile(projectDir,'src'));
if ~exist('evaluationDir','var')
    evaluationDir = fullfile(projectDir,'artifacts', ...
        'tpb04c481f_0943_4f76_a49d_83570eed28da');
end
oof = readtable(fullfile(evaluationDir,'oof_predictions.csv'));
temporal = readtable(fullfile(evaluationDir,'temporal_predictions.csv'));
% Verify saved rows/targets against source data before presenting metrics.
train = readtable(fullfile(projectDir,'data','train.csv'));
assert(isequal(oof.id,train.id) && ...
    all(abs(oof.actual-train.site_eui)<=1e-10.*max(1,abs(train.site_eui))), ...
    'BuildingEnergy:MetricProvenance','OOF rows/targets do not match the training CSV.');
latestRows = train.Year_Factor==max(train.Year_Factor);
assert(isequal(temporal.id,train.id(latestRows)) && ...
    all(abs(temporal.actual-train.site_eui(latestRows))<= ...
    1e-10.*max(1,abs(train.site_eui(latestRows)))), ...
    'BuildingEnergy:MetricProvenance','Temporal rows/targets do not match the latest year.');
metricReport = validationMetricTable(oof,temporal);
disp(metricReport);
% Check the same saved run's RMSE before adding new metrics.
comparison = readtable(fullfile(evaluationDir,'model_comparison.csv'));
for k = 1:height(comparison)
    model = string(comparison.Model(k));
    random = metricReport.Validation=="Five-fold OOF" & metricReport.Model==model;
    later = metricReport.Validation=="Latest-year holdout" & metricReport.Model==model;
    assert(abs(metricReport.RMSE(random)-comparison.OOF_RMSE(k))<1e-8 && ...
        abs(metricReport.RMSE(later)-comparison.TemporalRMSE(k))<1e-8, ...
        'BuildingEnergy:MetricMismatch','Recomputed RMSE differs from saved results.');
end
% Keep a new run's metrics beside its own evidence rather than overwriting release.
writetable(metricReport,fullfile(evaluationDir,'validation_metrics.csv'));
fprintf('Metrics saved beside the source evaluation: %s\n',evaluationDir);
fprintf('MSE/RMSE/MAE: lower is better. R2: higher is better; it is not percentage accuracy.\n');
fprintf('Metrics are validation estimates; unlabeled test predictions cannot be scored.\n');
