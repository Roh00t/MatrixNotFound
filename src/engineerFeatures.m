function [features, report] = engineerFeatures(X)
%ENGINEERFEATURES Add deterministic structural and thermal features.
% Accepts cleaned predictors only; never reads targets or fits statistics.
% During CV, first clean using fold-training statistics, then call this function.
% Added features are hypotheses: validation must establish their usefulness.
arguments
    X table
end
assert(~ismember('Year_Factor',X.Properties.VariableNames), ...
    'BuildingEnergy:UnpreparedFeatures', ...
    'Use applyPreprocessor first. The alternate main workflow uses engineerLegacyFeatures.');
required = {'floor_area','heating_degree_days','cooling_degree_days'};
assert(all(ismember(required, X.Properties.VariableNames)), ...
    'BuildingEnergy:FeatureInputs', ...
    'Features require floor_area, heating_degree_days and cooling_degree_days.');
for k = 1:numel(required)
    values = X.(required{k});
    assert(isnumeric(values) && iscolumn(values) && ...
        all(isfinite(values)) && all(values >= 0), ...
        'BuildingEnergy:InvalidFeatureInput', ...
        '%s must be a finite nonnegative numeric column.', required{k});
end
newNames = {'log_floor_area','area_heating_load','area_cooling_load', ...
    'total_degree_days','heating_degree_fraction'};
assert(~any(ismember(newNames, X.Properties.VariableNames)), ...
    'BuildingEnergy:FeatureCollision', ...
    'Engineered features already exist; supply the cleaned input table.');

area = double(X.floor_area);
heating = double(X.heating_degree_days);
cooling = double(X.cooling_degree_days);
total = heating + cooling;
fraction = zeros(height(X),1);
hasLoad = total > 0;
fraction(hasLoad) = heating(hasLoad) ./ total(hasLoad);
% When both degree-day values are zero, define the heating fraction as zero.
added = [log1p(area), area .* heating, area .* cooling, total, fraction];
assert(all(isfinite(added),'all'), 'BuildingEnergy:FeatureOverflow', ...
    'Feature calculations produced nonfinite values. Inspect the source data.');
features = [X, array2table(added,'VariableNames',newNames)];

% A compact audit describes the new columns without modifying source values.
report = table(string(newNames(:)), min(added,[],1)', ...
    median(added,1)', max(added,[],1)', ...
    'VariableNames', {'Feature','Minimum','Median','Maximum'});
% No building_age: the calendar mapping of Year_Factor is unverified.
% No wind components: units, sentinels and direction convention are unverified.
% Area interactions are proxies, not physical estimates of total energy use.
end
