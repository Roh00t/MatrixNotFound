function values = cleanNumericColumn(values, name)
%CLEANNUMERICCOLUMN Shared deterministic rules, with no learned statistics.
values = double(values);
values(~isfinite(values)) = NaN;
% Nonpositive construction years cannot be calendar construction years.
if strcmp(name, 'year_built')
    values(values <= 0) = NaN;
end
% Other sentinels require dictionary verification; do not guess their meaning.
end
