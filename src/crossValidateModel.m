function [cvRMSE, foldRMSE, oofPred] = crossValidateModel(trainFcn, X, y, foldId)
%CROSSVALIDATEMODEL Cross-validate a model over arbitrary fold assignments.
%
%   [cvRMSE, foldRMSE, oofPred] = CROSSVALIDATEMODEL(trainFcn, X, y, foldId)
%
%     trainFcn - handle @(X, y) that returns a fitted model supporting predict
%     X        - predictor table
%     y        - response vector
%     foldId   - one fold label per row; each unique label is held out once
%
%   Returns the overall out-of-fold RMSE, the RMSE of each fold (ordered by
%   unique(foldId)), and the out-of-fold prediction for every row.
%
%   Passing fold labels rather than a cvpartition object lets the same
%   function run both random k-fold CV and grouped CV such as
%   leave-one-year-out (foldId = X.Year_Factor).

    arguments
        trainFcn (1,1) function_handle
        X        table
        y        (:,1) double
        foldId   (:,1) {mustBeEqualLength(foldId, y)}
    end

    folds    = unique(foldId);
    foldRMSE = zeros(numel(folds), 1);
    oofPred  = nan(size(y));

    for k = 1:numel(folds)
        isVal = foldId == folds(k);
        mdl   = trainFcn(X(~isVal, :), y(~isVal));

        oofPred(isVal) = predict(mdl, X(isVal, :));
        foldRMSE(k)    = computeRMSE(y(isVal), oofPred(isVal));
    end

    cvRMSE = computeRMSE(y, oofPred);
end

function mustBeEqualLength(a, b)
    if numel(a) ~= numel(b)
        error("crossValidateModel:lengthMismatch", "foldId must have one entry per row of y.");
    end
end
