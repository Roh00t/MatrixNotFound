function state = fitPreprocessor(X)
%FITPREPROCESSOR Learn cleaning statistics using training rows ONLY.
% During CV call this separately inside each fold, never on all labeled data.
arguments
    X table
end
assert(height(X)>0, 'BuildingEnergy:EmptyFit', 'No training rows supplied.');
state.Version = 1;
state.InputNames = X.Properties.VariableNames;
state.ExcludedNames = intersect({'Year_Factor'}, state.InputNames, 'stable');
state.NumericNames = {};
state.CategoryNames = {};
state.DroppedNames = {};
state.Medians = struct;
state.Levels = struct;
state.Modes = struct;
state.MinFacilitySupport = 5;
state.FacilityLabels = strings(0,1);
state.FacilityMedians = zeros(0,1);
state.FacilitySupport = zeros(0,1);
for k = 1:width(X)
    name = state.InputNames{k};
    if ismember(name, state.ExcludedNames), continue; end
    column = X.(name);
    assert(iscolumn(column), 'BuildingEnergy:ColumnShape', ...
        'Predictor %s must have one column.', name);
    if isnumeric(column)
        values = cleanNumericColumn(column, name);
        if all(ismissing(values))
            state.DroppedNames{end+1} = name;
            continue;
        end
        state.NumericNames{end+1} = name;
        state.Medians.(name) = median(values, 'omitmissing');
    elseif iscategorical(column)
        observed = removecats(column);
        levels = categories(observed);
        assert(~isempty(levels), 'BuildingEnergy:EmptyCategory', ...
            'Categorical predictor %s has no observed training labels.', name);
        counts = countcats(observed);
        [~, largest] = max(counts);
        state.CategoryNames{end+1} = name;
        state.Levels.(name) = levels;
        state.Modes.(name) = levels{largest};
    else
        error('BuildingEnergy:UnsupportedType', ...
            'Predictor %s must be numeric or categorical.', name);
    end
end
% Facility-specific rating estimates, backed by the global training median.
if ismember('energy_star_rating', state.NumericNames) && ...
        ismember('facility_type', state.CategoryNames)
    labels = string(X.facility_type);
    rating = cleanNumericColumn(X.energy_star_rating, 'energy_star_rating');
    groups = unique(labels(~ismissing(labels)));
    medians = NaN(numel(groups),1);
    support = zeros(numel(groups),1);
    for k = 1:numel(groups)
        mask = ~ismissing(labels) & labels == groups(k);
        support(k) = nnz(mask & ~ismissing(rating));
        if support(k) >= state.MinFacilitySupport
            medians(k) = median(rating(mask), 'omitmissing');
        end
    end
    state.FacilityLabels = groups;
    state.FacilityMedians = medians;
    state.FacilitySupport = support;
end
% Fix and save output schema now so inference can enforce it.
[example, ~] = applyPreprocessor(X, state);
state.OutputNames = example.Properties.VariableNames;
end
