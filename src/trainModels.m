function [finalModel, cvReport] = trainModels(X, y, options)
%TRAINMODELS Compare candidate models with leave-one-year-out CV, fit the best.
%
%   [finalModel, cvReport] = TRAINMODELS(X, y) expects the raw predictor
%   table from loadData. Imputation and feature engineering are refit inside
%   every training fold (see preparePredictors), so held-out rows never
%   influence the statistics used to fill or transform them.
%
%   VALIDATION DESIGN
%     * Leave-One-Year-Out (LOYO) CV is the model-selection metric. The test
%       set is a single year (7) that never appears in training, so holding
%       out one whole year at a time is the closest simulation of the real
%       task.
%     * Random 5-fold CV is run for the baseline tree only, as evidence. The
%       same building appears in several years, so random folds let a model
%       recognise buildings it has already seen and report an optimistic RMSE.
%
%   MODEL ITERATION (each candidate is one row in the comparison table)
%     1. Regression tree   - single interpretable baseline (fitrtree).
%     2. LSBoost v1        - gradient-boosted trees. Chosen because it handles
%                            mixed numeric/categorical predictors natively,
%                            needs no feature scaling, captures non-linear
%                            interactions (size x climate x building type),
%                            and is robust to the heavy right tail of site_eui.
%     3. LSBoost v2        - regularisation by shrinkage: half the learning
%                            rate, larger minimum leaves, histogram binning.
%                            Targets over-fitting to year-specific patterns.
%     4. LSBoost v3        - feature selection: v1 settings without the 36
%                            monthly temperature columns. Those values are
%                            identical for every building in a state-year, so
%                            they act as a fingerprint the trees can memorise;
%                            in an unseen year the fingerprint never matches.
%                            Aggregate climate (degree days, avg_temp, extreme
%                            day counts, precipitation, snow) is kept.
%
%   ROBUSTNESS
%     Each candidate is cross-validated inside try/catch. A failing candidate
%     is reported and skipped, and the final refit falls back to the next
%     best model, so a submission can always be produced while v1 succeeds.
%
%   OUTPUTS
%     finalModel - compact model (training data stripped) with the lowest
%                  LOYO RMSE, refit on all rows of X
%     cvReport   - struct with the comparison table, per-year RMSE, the
%                  random-vs-LOYO evidence for the tree, the winner's name
%                  and its out-of-fold predictions
%
%   [...] = TRAINMODELS(X, y, ProgressFcn=f) calls f(results, perYearRMSE)
%   after each candidate finishes, with NaN for candidates not yet scored.
%   main.m uses this to update the live dashboard.

    arguments
        X table
        y (:,1) double
        options.ProgressFcn function_handle = @(results, perYearRMSE) []
    end

    candidates = struct( ...
        "name",     {"Regression tree (baseline)", "LSBoost v1 (initial)", ...
                     "LSBoost v2 (shrinkage)",     "LSBoost v3 (feature selection)"}, ...
        "trainFcn", {@trainTree, @trainBoostV1, @trainBoostV2, @trainBoostV3});

    loyoFolds = str2double(string(X.Year_Factor));
    assert(all(isfinite(loyoFolds)), ...
        "trainModels:invalidYear", "Year_Factor must contain numeric year levels.");

    nModels     = numel(candidates);
    years       = unique(loyoFolds);
    loyoRMSE    = nan(nModels, 1);
    perYearRMSE = nan(nModels, numel(years));
    runtimeMin  = nan(nModels, 1);
    oofPred     = cell(nModels, 1);

    % --- Leave-one-year-out CV for every candidate -------------------------
    for m = 1:nModels
        fprintf("\nLOYO cross-validating %s ...\n", candidates(m).name);
        timer = tic;
        try
            [loyoRMSE(m), perYearRMSE(m, :), oofPred{m}] = crossValidateModel( ...
                candidates(m).trainFcn, X, y, loyoFolds, @preparePredictors);
            fprintf("  LOYO RMSE = %.3f\n", loyoRMSE(m));
        catch err
            warning("trainModels:candidateFailed", ...
                "%s failed and is excluded: %s", candidates(m).name, err.message);
        end
        runtimeMin(m) = toc(timer) / 60;
        options.ProgressFcn(table(string({candidates.name})', loyoRMSE, runtimeMin, ...
            VariableNames=["Model", "LOYO_RMSE", "CV_Runtime_min"]), perYearRMSE);
    end

    % --- Evidence: random k-fold is optimistic (baseline tree only) --------
    fprintf("\nRandom 5-fold cross-validating %s ...\n", candidates(1).name);
    treeKFoldRMSE = crossValidateModel(@trainTree, X, y, ...
        randomKFoldIds(height(X), 5), @preparePredictors);

    % --- Report ------------------------------------------------------------
    modelNames = string({candidates.name})';
    results = table(modelNames, loyoRMSE, runtimeMin, ...
        VariableNames=["Model", "LOYO_RMSE", "CV_Runtime_min"]);
    perYear = array2table(perYearRMSE, RowNames=cellstr(modelNames), ...
        VariableNames="Year_" + string(years));
    validationGap = table(["Random 5-fold"; "Leave-one-year-out"], ...
        [treeKFoldRMSE; loyoRMSE(1)], VariableNames=["Scheme", "Tree_RMSE"]);

    fprintf("\n=== Model comparison (leave-one-year-out RMSE) ===\n");
    disp(results)
    fprintf("RMSE on each held-out year:\n");
    disp(perYear)
    fprintf("Why LOYO: random folds understate the baseline tree's error by %.2f\n", ...
        loyoRMSE(1) - treeKFoldRMSE);
    disp(validationGap)

    % --- Refit the best surviving candidate on all training rows -----------
    [preparedX, ~] = preparePredictors(X, X);
    [~, ranking] = sort(loyoRMSE);              % NaN (failed) sorts last
    ranking = ranking(isfinite(loyoRMSE(ranking)));
    assert(~isempty(ranking), "trainModels:allFailed", "Every candidate model failed.");

    finalModel = [];
    for best = ranking'
        fprintf("Refitting %s on all %d training rows ...\n", candidates(best).name, height(X));
        try
            finalModel = compact(candidates(best).trainFcn(preparedX, y));
            break
        catch err
            warning("trainModels:refitFailed", ...
                "Refit of %s failed, trying next best: %s", candidates(best).name, err.message);
        end
    end
    assert(~isempty(finalModel), "trainModels:refitFailed", "No candidate could be refit.");

    cvReport = struct( ...
        "results",               results, ...
        "perYearRMSE",           perYear, ...
        "validationGap",         validationGap, ...
        "bestModelName",         modelNames(best), ...
        "outOfFoldPredictions",  oofPred{best});
    fprintf("Selected model: %s\n", modelNames(best));
end

% =========================================================================
% Candidate models
% =========================================================================
function mdl = trainTree(X, y)
%TRAINTREE Baseline: a single regression tree with default settings.
    mdl = fitrtree(X, y);
end

function mdl = trainBoostV1(X, y)
%TRAINBOOSTV1 Initial LSBoost: 300 shallow trees, learning rate 0.1.
    mdl = fitBoost(X, y, NumTrees=300, LearnRate=0.1, MinLeafSize=20);
end

function mdl = trainBoostV2(X, y)
%TRAINBOOSTV2 Shrinkage: lower learning rate, larger leaves, binned splits.
%   A smaller learning rate makes each tree a smaller correction, and a
%   minimum leaf of 50 buildings stops leaves from fitting a handful of
%   unusual rows. 400 trees keep total learning (trees x rate) comparable
%   to v1 within the hackathon compute budget. NumBins=50 bins numeric
%   predictors into quantiles, which speeds up fitting on 75k rows.
    mdl = fitBoost(X, y, NumTrees=400, LearnRate=0.05, MinLeafSize=50, NumBins=50);
end

function mdl = trainBoostV3(X, y)
%TRAINBOOSTV3 Feature selection: v1 without monthly temperature columns.
    X = removevars(X, monthlyTemperatureVars());
    mdl = trainBoostV1(X, y);
end

function mdl = fitBoost(X, y, opts)
%FITBOOST Least-squares boosted regression trees with shared tree settings.
    arguments
        X table
        y (:,1) double
        opts.NumTrees    (1,1) double
        opts.LearnRate   (1,1) double
        opts.MinLeafSize (1,1) double
        opts.NumBins     double = []    % [] = no binning (fitrensemble default)
    end
    learner = templateTree(MaxNumSplits=63, MinLeafSize=opts.MinLeafSize);
    mdl = fitrensemble(X, y, Method="LSBoost", Learners=learner, ...
        NumLearningCycles=opts.NumTrees, LearnRate=opts.LearnRate, NumBins=opts.NumBins);
end

% =========================================================================
% Helpers
% =========================================================================
function names = monthlyTemperatureVars()
%MONTHLYTEMPERATUREVARS The 36 columns <month>_<min|avg|max>_temp.
    months = ["january", "february", "march", "april", "may", "june", "july", ...
              "august", "september", "october", "november", "december"];
    names = months' + "_" + ["min", "avg", "max"] + "_temp";
    names = reshape(names', 1, []);
end

function foldId = randomKFoldIds(n, k)
%RANDOMKFOLDIDS Fold label (1..k) for each of n rows, using cvpartition.
    partition = cvpartition(n, "KFold", k);
    foldId = zeros(n, 1);
    for f = 1:k
        foldId(test(partition, f)) = f;
    end
end

function [trainTbl, validationTbl] = preparePredictors(trainTbl, validationTbl)
%PREPAREPREDICTORS Fit fold-local preprocessing and engineer both partitions.
    [trainTbl, validationTbl] = preprocessData(trainTbl, validationTbl);
    trainTbl      = engineerFeatures(trainTbl);
    validationTbl = engineerFeatures(validationTbl);
end
