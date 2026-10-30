function metrics = computeExtendedMetrics(yTrue, yPred)
%COMPUTEEXTENDEDMETRICS Regression accuracy metrics for one set of predictions.
%
%   metrics = COMPUTEEXTENDEDMETRICS(yTrue, yPred) returns a one-row table:
%
%     MAE   - mean absolute error: the typical miss, in kBtu/ft²/yr
%     MSE   - mean squared error
%     RMSE  - root mean squared error, the competition metric
%     R2    - coefficient of determination: share of the variance in
%             site_eui explained (1 = perfect, 0 = no better than the mean)
%     MedianAE - median absolute error, robust to the extreme consumers
%
%   Call it with out-of-fold predictions so every number describes accuracy
%   on data the model did not see during training.

    arguments
        yTrue (:,1) double
        yPred (:,1) double {mustBeEqualSize(yTrue, yPred)}
    end

    residuals = yTrue - yPred;
    mse = mean(residuals.^2);

    metrics = table( ...
        mean(abs(residuals)), mse, sqrt(mse), ...
        1 - sum(residuals.^2) / sum((yTrue - mean(yTrue)).^2), ...
        median(abs(residuals)), ...
        VariableNames=["MAE", "MSE", "RMSE", "R2", "MedianAE"]);
end

function mustBeEqualSize(a, b)
    if ~isequal(size(a), size(b))
        error("computeExtendedMetrics:sizeMismatch", "yTrue and yPred must be the same size.");
    end
end
