function metrics = regressionMetrics(actual, predicted)
%REGRESSIONMETRICS Original-scale validation metrics from paired predictions.
% R2 is 1-SSE/SST, not squared correlation. For a constant actual target,
% R2 is undefined and returned as NaN. Negative R2 is valid and is retained.
assert(isnumeric(actual) && isnumeric(predicted) && iscolumn(actual) && ...
    iscolumn(predicted) && ~isempty(actual) && isequal(size(actual),size(predicted)), ...
    'BuildingEnergy:MetricShape','Metrics require matching nonempty numeric columns.');
assert(all(isfinite(actual)) && all(isfinite(predicted)), ...
    'BuildingEnergy:MetricFinite','Metric inputs must be finite.');
actual = double(actual);
error = actual-double(predicted);
sse = sum(error.^2);
sst = sum((actual-mean(actual)).^2);
rSquared = NaN;
if sst > 0
    rSquared = 1-sse/sst;
end
metrics = table(numel(actual),mean(error.^2),sqrt(mean(error.^2)), ...
    mean(abs(error)),rSquared,'VariableNames',{'N','MSE','RMSE','MAE','R2'});
end
