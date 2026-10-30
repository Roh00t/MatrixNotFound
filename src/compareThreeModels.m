function experiment = compareThreeModels(X,y,years,ids,factors,config,outputDir)
%COMPARETHREEMODELS Controlled feature-selection and estimator comparison.
% M1 = Tree/all cleaned factors; M2 = Tree/selected; M3 = LSBoost/selected.
% No engineered features are added. Both selected models get identical tables.
assert(iscolumn(y) && iscolumn(years) && iscolumn(ids) && ...
    numel(y)==height(X) && numel(years)==height(X) && numel(ids)==height(X) && ...
    all(isfinite(y)) && all(y>=0) && all(isfinite(years)) && ...
    ~any(ismissing(ids)) && numel(unique(ids))==numel(ids), ...
    'BuildingEnergy:ComparisonInputs','Training rows, targets, years and IDs must align.');
validateattributes(config.NumFolds,{'numeric'},{'scalar','integer','>=',2,'<=',height(X)});
assert(isfolder(outputDir),'BuildingEnergy:OutputFolder','Output directory must exist.');
latest = max(years);
assert(any(years<latest),'BuildingEnergy:TemporalSplit','At least two years are required.');
names = ["Model1_All_Tree","Model2_Selected_Tree","Model3_Selected_LSBoost"];
methods = ["Tree","Tree","LSBoost"];
rng(config.Seed,'twister');
partition = cvpartition(height(X),'KFold',config.NumFolds);
foldID = zeros(height(X),1);
oof = NaN(height(X),3);
temporal = NaN(nnz(years==latest),3);
foldRMSE = NaN(config.NumFolds,3);
featureCounts = zeros(config.NumFolds+1,3);
report = table;
for split = 1:config.NumFolds+1
    if split<=config.NumFolds
        fitRows = training(partition,split);
        valRows = test(partition,split);
        foldID(valRows) = split;
        scheme = "Fold " + split;
    else
        fitRows = years<latest;
        valRows = years==latest;
        scheme = "Latest-year holdout";
    end
    fprintf('\n%s: fit %d rows, validate %d rows.\n',scheme,nnz(fitRows),nnz(valRows));
    state = fitPreprocessor(X(fitRows,:));
    allFit = applyPreprocessor(X(fitRows,:),state);
    allVal = applyPreprocessor(X(valRows,:),state);
    selectedFit = selectComparisonFactors(allFit,factors);
    selectedVal = selectComparisonFactors(allVal,factors);
    for candidate = 1:3
        if candidate==1
            fitX = allFit; valX = allVal;
        else
            fitX = selectedFit; valX = selectedVal;
        end
        % Equal tree settings and seed for M1/M2: only input factors change.
        rng(config.Seed+split,'twister');
        timer = tic;
        model = trainCandidate(fitX,y(fitRows),methods(candidate),config);
        prediction = max(0,predict(model,valX));
        m = computeExtendedMetrics(y(valRows),prediction);
        featureCounts(split,candidate) = width(fitX);
        fprintf('  %s: RMSE %.4f, MAE %.4f, R2 %.4f (%0.1fs)\n', ...
            names(candidate),m.RMSE,m.MAE,m.R2,toc(timer));
        if split<=config.NumFolds
            oof(valRows,candidate) = prediction;
            foldRMSE(split,candidate) = m.RMSE;
        else
            temporal(:,candidate) = prediction;
            row = [table("Latest-year holdout",names(candidate),nnz(valRows), ...
                'VariableNames',{'Validation','Model','N'}),m];
            report = [report;row]; %#ok<AGROW>
        end
    end
    save(fullfile(outputDir,'comparison_progress.mat'),'oof','temporal','foldID', ...
        'foldRMSE','featureCounts','config','factors','split','names');
end
for candidate = 1:3
    row = [table("Five-fold OOF",names(candidate),height(X), ...
        'VariableNames',{'Validation','Model','N'}), ...
        computeExtendedMetrics(y,oof(:,candidate))];
    report = [report;row]; %#ok<AGROW>
end
report = sortrows(report,{'Validation','RMSE'});
experiment = struct('Metrics',report,'OOF',oof,'Temporal',temporal, ...
    'FoldID',foldID,'TemporalRows',find(years==latest),'TemporalYear',latest, ...
    'FoldRMSE',foldRMSE,'FeatureCounts',featureCounts,'Names',names, ...
    'SelectedFactors',{cellstr(string(factors))},'Config',config);
writetable(report,fullfile(outputDir,'three_model_metrics.csv'));
oofTable = table(ids,y,foldID,'VariableNames',{'id','actual','fold'});
laterTable = table(ids(years==latest),y(years==latest),'VariableNames',{'id','actual'});
for candidate = 1:3
    key = char(names(candidate)+"_prediction");
    oofTable.(key) = oof(:,candidate);
    laterTable.(key) = temporal(:,candidate);
end
writetable(oofTable,fullfile(outputDir,'oof_predictions.csv'));
writetable(laterTable,fullfile(outputDir,'temporal_predictions.csv'));
save(fullfile(outputDir,'three_model_evaluation.mat'),'experiment','ids','y');
end
