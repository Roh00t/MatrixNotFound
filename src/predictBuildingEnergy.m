function predictions = predictBuildingEnergy(bundle, rawPredictors)
%PREDICTBUILDINGENERGY Apply the saved Step 5 bundle without fitting anything.
clean = applyPreprocessor(rawPredictors,bundle.Preprocessor);
features = engineerFeatures(clean);
assert(isequal(features.Properties.VariableNames,bundle.PredictorNames), ...
    'BuildingEnergy:InferenceSchema','Inference feature order differs from training.');
predictions = predict(bundle.Model,features);
assert(iscolumn(predictions) && numel(predictions)==height(rawPredictors) && ...
    all(isfinite(predictions)), 'BuildingEnergy:InvalidPrediction', ...
    'Model produced invalid predictions.');
predictions = max(0,predictions); % Same policy used during Step 4 evaluation.
end
