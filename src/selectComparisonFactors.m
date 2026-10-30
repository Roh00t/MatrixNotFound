function selected = selectComparisonFactors(clean, factors)
%SELECTCOMPARISONFACTORS Keep approved factors and their own absence flags.
% Do not accidentally keep derived features from excluded source factors.
factors = cellstr(string(factors));
assert(~isempty(factors) && numel(unique(factors))==numel(factors) && ...
    all(ismember(factors,clean.Properties.VariableNames)), ...
    'BuildingEnergy:SelectedFactors', ...
    'Selected factors must be unique and present after fold-local cleaning.');
assert(~any(ismember(factors,{'id','site_eui','Year_Factor'})), ...
    'BuildingEnergy:ExcludedFactor','IDs, target and categorical year are excluded.');
names = factors;
for k = 1:numel(factors)
    flags = {[factors{k} '_was_missing'],[factors{k} '_was_unknown']};
    names = [names,intersect(flags,clean.Properties.VariableNames,'stable')]; %#ok<AGROW>
end
selected = clean(:,names);
end
