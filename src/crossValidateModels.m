function results = crossValidateModels(X, y, rawYears, config, outputDir)
%CROSSVALIDATEMODELS Honest out-of-fold predictions plus a later-year check.
% No test rows are accepted here. Cleaning is refitted for every split.
validateattributes(config.NumFolds,{'numeric'}, ...
    {'scalar','integer','>=',2,'<=',height(X)});
validateattributes(config.Seed,{'numeric'},{'scalar','integer','nonnegative'});
assert(isfolder(outputDir),'BuildingEnergy:OutputFolder', ...
    'Create the output directory before cross-validation.');
assert(iscolumn(y) && numel(y)==height(X) && all(isfinite(y)) && all(y>=0), ...
    'BuildingEnergy:TrainingTarget', 'Invalid training target.');
assert(iscolumn(rawYears) && numel(rawYears)==height(X) && ...
    all(isfinite(rawYears)), 'BuildingEnergy:TrainingYears', ...
    'Raw year metadata must be finite and aligned with training rows.');
names = ["Mean","Tree","Bag","LSBoost"];
rng(config.Seed,'twister');
partition = cvpartition(height(X),'KFold',config.NumFolds);
foldID = zeros(height(X),1);
oof = NaN(height(X),numel(names));
foldRMSE = NaN(config.NumFolds,numel(names));
foldSeconds = zeros(config.NumFolds,numel(names));
for fold = 1:config.NumFolds
    fitRows = training(partition,fold);
    valRows = test(partition,fold);
    foldID(valRows) = fold;
    fprintf('\nFold %d/%d: fitting cleaning on %d rows, validating %d rows.\n', ...
        fold,config.NumFolds,nnz(fitRows),nnz(valRows));
    state = fitPreprocessor(X(fitRows,:));
    fitX = engineerFeatures(applyPreprocessor(X(fitRows,:),state));
    valX = engineerFeatures(applyPreprocessor(X(valRows,:),state));
    for candidate = 1:numel(names)
        rng(config.Seed + fold*100 + candidate,'twister');
        timer = tic;
        model = trainCandidate(fitX,y(fitRows),names(candidate),config);
        prediction = candidatePredict(model,valX,names(candidate));
        oof(valRows,candidate) = prediction;
        foldRMSE(fold,candidate) = rmse(y(valRows),prediction);
        foldSeconds(fold,candidate) = toc(timer);
        fprintf('  %-8s RMSE %.4f (%0.1f seconds)\n',names(candidate), ...
            foldRMSE(fold,candidate),foldSeconds(fold,candidate));
    end
    % Preserve completed folds if a later fit fails or execution is interrupted.
    save(fullfile(outputDir,'cv_progress.mat'),'oof','foldID', ...
        'foldRMSE','foldSeconds','config','fold','names');
end

% Train on all earlier years and check the latest labeled year (year 6 here).
latestYear = max(rawYears);
fitRows = rawYears < latestYear;
valRows = rawYears == latestYear;
assert(any(fitRows) && any(valRows), 'BuildingEnergy:TemporalSplit', ...
    'Temporal validation requires at least two observed years.');
fprintf('\nTemporal check: earlier years -> year factor %g.\n',latestYear);
state = fitPreprocessor(X(fitRows,:));
fitX = engineerFeatures(applyPreprocessor(X(fitRows,:),state));
valX = engineerFeatures(applyPreprocessor(X(valRows,:),state));
temporalPrediction = NaN(nnz(valRows),numel(names));
temporalRMSE = zeros(numel(names),1);
for candidate = 1:numel(names)
    rng(config.Seed + 1000 + candidate,'twister');
    model = trainCandidate(fitX,y(fitRows),names(candidate),config);
    temporalPrediction(:,candidate) = candidatePredict(model,valX,names(candidate));
    temporalRMSE(candidate) = rmse(y(valRows),temporalPrediction(:,candidate));
    fprintf('  %-8s temporal RMSE %.4f\n',names(candidate),temporalRMSE(candidate));
end

pooled = zeros(numel(names),1);
mae = pooled;
for candidate = 1:numel(names)
    pooled(candidate) = rmse(y,oof(:,candidate));
    mae(candidate) = mean(abs(y-oof(:,candidate)));
end
summary = table(names',pooled,mae,mean(foldRMSE,1)',std(foldRMSE,0,1)', ...
    temporalRMSE,sum(foldSeconds,1)', 'VariableNames', ...
    {'Model','OOF_RMSE','OOF_MAE','MeanFoldRMSE','StdFoldRMSE', ...
    'TemporalRMSE','CVModelSeconds'});
% Rank by pooled OOF score; final selection must also review temporal behavior.
summary = sortrows(summary,'OOF_RMSE');
results = struct('Summary',summary,'Names',names,'OOF',oof,'FoldID',foldID, ...
    'FoldRMSE',foldRMSE,'FoldSeconds',foldSeconds, ...
    'TemporalRows',find(valRows),'TemporalPredictions',temporalPrediction, ...
    'TemporalYear',latestYear,'Config',config);
end

function prediction = candidatePredict(model, X, name)
if name == "Mean"
    prediction = repmat(model,height(X),1);
else
    prediction = predict(model,X);
end
assert(iscolumn(prediction) && numel(prediction)==height(X) && ...
    all(isfinite(prediction)), 'BuildingEnergy:InvalidPrediction', ...
    'Candidate %s produced invalid predictions.',name);
% Apply this same nonnegative policy during eventual final inference.
prediction = max(0,prediction);
end
