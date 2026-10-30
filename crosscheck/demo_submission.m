%% Quick judging demo: inspect saved evidence without retraining
% Uses the packaged step-pipeline outputs, not alternate workflow results.
projectDir = fileparts(fileparts(mfilename('fullpath')));  % repository root (this script lives in crosscheck/)
submissionFile = fullfile(projectDir,'release','crosscheck_bag_submission.csv');
if ~isfile(submissionFile)
    submissionFile = fullfile(projectDir,'release','submission.csv');
end
submission = readtable(submissionFile);
sample = readtable(fullfile(projectDir,'data','sample_solution.csv'));
assert(isequal(submission.Properties.VariableNames,{'id','site_eui'}) && ...
    isequal(submission.id,sample.id) && all(isfinite(submission.site_eui)) && ...
    all(submission.site_eui>=0), 'BuildingEnergy:DemoSubmission', ...
    'Packaged submission failed schema, ID, or prediction checks.');
comparison = readtable(fullfile(projectDir,'release','model_comparison.csv'));
disp(comparison(:,{'Model','OOF_RMSE','TemporalRMSE'}));
metricsFile = fullfile(projectDir,'release','validation_metrics.csv');
if isfile(metricsFile)
    metricReport = readtable(metricsFile);
    fprintf('Selected Bag model: additional validation metrics\n');
    disp(metricReport(string(metricReport.Model)=="Bag",:));
end
fprintf('Selected model: Bag (200 trees); strongest latest-year check.\n');
fprintf('Validated %d packaged predictions; no training was needed.\n',height(submission));
disp(submission(1:min(5,height(submission)),:));
fprintf('Scores are validation estimates; test targets are unavailable.\n');
