function [clean, audit] = applyPreprocessor(X, state)
%APPLYPREPROCESSOR Apply frozen training statistics without fitting on X.
% Year_Factor is deliberately excluded: unseen future years are not imputed.
arguments
    X table
    state struct
end
assert(isequal(sort(X.Properties.VariableNames), sort(state.InputNames)), ...
    'BuildingEnergy:SchemaMismatch', 'Predictor names differ from fitted schema.');
clean = X(:, state.InputNames);
clean = removevars(clean, [state.ExcludedNames, state.DroppedNames]);
auditNames = [state.NumericNames, state.CategoryNames];
repairCounts = zeros(numel(auditNames),1);
for k = 1:numel(state.NumericNames)
    name = state.NumericNames{k};
    assert(isnumeric(X.(name)), 'BuildingEnergy:TypeMismatch', ...
        'Expected numeric predictor %s.', name);
    values = cleanNumericColumn(X.(name), name);
    missing = ismissing(values);
    repairCounts(k) = nnz(missing);
    flag = [name '_was_missing'];
    assert(~ismember(flag, state.InputNames), 'BuildingEnergy:NameCollision', ...
        'Generated feature name already exists: %s.', flag);
    clean.(flag) = double(missing);
    if strcmp(name, 'energy_star_rating') && ~isempty(state.FacilityLabels)
        labels = string(X.facility_type);
        for g = 1:numel(state.FacilityLabels)
            if isfinite(state.FacilityMedians(g))
                rows = ~ismissing(labels) & labels == state.FacilityLabels(g);
                values(rows) = fillmissing(values(rows), 'constant', ...
                    state.FacilityMedians(g));
            end
        end
    end
    clean.(name) = fillmissing(values, 'constant', state.Medians.(name));
    assert(all(isfinite(clean.(name))), 'BuildingEnergy:Nonfinite', ...
        'Nonfinite values remain in %s.', name);
end
for k = 1:numel(state.CategoryNames)
    name = state.CategoryNames{k};
    assert(iscategorical(X.(name)), 'BuildingEnergy:TypeMismatch', ...
        'Expected categorical predictor %s.', name);
    labels = string(X.(name));
    unknown = ismissing(labels) | ~ismember(labels, state.Levels.(name));
    repairCounts(numel(state.NumericNames)+k) = nnz(unknown);
    labels(unknown) = string(state.Modes.(name));
    clean.(name) = categorical(labels, state.Levels.(name));
    flag = [name '_was_unknown'];
    assert(~ismember(flag, state.InputNames), 'BuildingEnergy:NameCollision', ...
        'Generated feature name already exists: %s.', flag);
    clean.(flag) = double(unknown);
end
assert(~any(ismissing(clean), 'all'), 'BuildingEnergy:MissingOutput', ...
    'Cleaning left missing values.');
if isfield(state, 'OutputNames')
    assert(isequal(clean.Properties.VariableNames, state.OutputNames), ...
        'BuildingEnergy:OutputSchema', 'Clean feature schema changed.');
end
audit = table(string(auditNames(:)), repairCounts, ...
    'VariableNames', {'Predictor','ValuesFilledOrMapped'});
end
