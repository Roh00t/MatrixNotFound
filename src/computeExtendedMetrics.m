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

    % Shared checks reject NaN/Inf and empty inputs; constant-target R2 is NaN.
    core = regressionMetrics(yTrue,yPred);
    residuals = yTrue-yPred;
    metrics = core(:,{'MAE','MSE','RMSE','R2'});
    metrics.MedianAE = median(abs(residuals));
    metrics.P90AE = prctile(abs(residuals),90);
    % Positive bias means predictions are too high on average.
    metrics.MeanBias = mean(yPred-yTrue);
end

function mustBeEqualSize(a, b)
    if ~isequal(size(a), size(b))
        error("computeExtendedMetrics:sizeMismatch", "yTrue and yPred must be the same size.");
    end
end
