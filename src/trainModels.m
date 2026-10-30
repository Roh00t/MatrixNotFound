function [finalModel, results] = trainModels(X, y)
%TRAINMODELS Compare candidate models under two CV schemes and fit the best.
%
%   [finalModel, results] = TRAINMODELS(X, y) evaluates each candidate
%   model with:
%
%     * Leave-One-Year-Out (LOYO) CV - each Year_Factor is held out in turn.
%       The test set is a single unseen year (7), so this is the scheme that
%       mirrors the real prediction task.
%     * Random 5-fold CV - shown for contrast. The same building appears in
%       several years, so random folds let the model "recognise" buildings
%       it has already seen and report an optimistic RMSE.
%
%   The model with the lowest LOYO RMSE is refitted on all of X and
%   returned as finalModel. results is a table with one row per model.

    arguments
        X table
        y (:,1) double
    end

    modelNames = ["Regression tree (fitrtree)"; "LSBoost ensemble (fitrensemble)"];
    trainFcns  = {@trainTree; @trainBoost};

    loyoFolds   = X.Year_Factor;
    randomFolds = randomKFoldIds(height(X), 5);

    nModels     = numel(modelNames);
    years       = unique(loyoFolds);
    loyoRMSE    = zeros(nModels, 1);
    kfoldRMSE   = zeros(nModels, 1);
    perYearRMSE = zeros(nModels, numel(years));

    for m = 1:nModels
        fprintf("\nCross-validating %s ...\n", modelNames(m));
        [loyoRMSE(m), perYearRMSE(m, :)] = crossValidateModel(trainFcns{m}, X, y, loyoFolds);
        kfoldRMSE(m) = crossValidateModel(trainFcns{m}, X, y, randomFolds);
        fprintf("  LOYO RMSE = %.3f | random 5-fold RMSE = %.3f\n", loyoRMSE(m), kfoldRMSE(m));
    end

    % --- Report ------------------------------------------------------------
    results = table(modelNames, loyoRMSE, kfoldRMSE, loyoRMSE - kfoldRMSE, ...
        VariableNames=["Model", "LOYO_RMSE", "KFold5_RMSE", "Optimism"]);
    disp(results)

    perYear = array2table(perYearRMSE, RowNames=cellstr(modelNames), ...
        VariableNames="Year_" + string(years));
    fprintf("RMSE on each held-out year (LOYO):\n");
    disp(perYear)

    % --- Refit the winner on all training data ----------------------------
    [~, best] = min(loyoRMSE);
    fprintf("Refitting best model (%s) on all %d training rows ...\n", modelNames(best), height(X));
    finalModel = trainFcns{best}(X, y);
end

% =========================================================================
% Candidate models
% =========================================================================
function mdl = trainTree(X, y)
%TRAINTREE Baseline: a single regression tree with default settings.
    mdl = fitrtree(X, y);
end

function mdl = trainBoost(X, y)
%TRAINBOOST Gradient-boosted trees (least-squares boosting).
%   Shallow trees with a modest learning rate and a minimum leaf size are a
%   standard, robust starting point for tabular regression.
    learner = templateTree(MaxNumSplits=63, MinLeafSize=20);
    mdl = fitrensemble(X, y, Method="LSBoost", Learners=learner, ...
        NumLearningCycles=300, LearnRate=0.1);
end

% =========================================================================
% Helpers
% =========================================================================
function foldId = randomKFoldIds(n, k)
%RANDOMKFOLDIDS Fold label (1..k) for each of n rows, using cvpartition.
    partition = cvpartition(n, "KFold", k);
    foldId = zeros(n, 1);
    for f = 1:k
        foldId(test(partition, f)) = f;
    end
end
