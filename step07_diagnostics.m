%% Metrics and predicted-versus-actual graphs without retraining
projectDir = fileparts(mfilename('fullpath'));
addpath(fullfile(projectDir,'src'));
run(fullfile(projectDir,'step06_metrics.m')); % checks prediction provenance
diagnosticsDir = fullfile(evaluationDir,'diagnostics');
oofSummary = exportValidationDiagnostics(oof.actual,oof.Bag_prediction, ...
    fullfile(diagnosticsDir,'bag_oof'),'Model','Bag','Validation','Five-fold OOF');
temporalSummary = exportValidationDiagnostics(temporal.actual,temporal.Bag_prediction, ...
    fullfile(diagnosticsDir,'bag_latest_year'), ...
    'Model','Bag','Validation','Latest-year holdout');
fprintf('Diagnostics saved to: %s\n',diagnosticsDir);
fprintf('Give your UI teammate validation_summary.json and plot_points.csv from each folder.\n');
fprintf('PNG graphs are ready for the presentation. No models were retrained.\n');
