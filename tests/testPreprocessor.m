function tests = testPreprocessor
tests = functiontests(localfunctions);
end

function testFrozenStatisticsAndFallbacks(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'src'));
X = table(categorical([1;1;2;2;3;3]), ...
    categorical(["Office";"Office";"Office";"Office";"Office";"School"]), ...
    [10;20;30;40;50;NaN], [2000;2000;2000;2000;2000;0], ...
    NaN(6,1), 'VariableNames', ...
    {'Year_Factor','facility_type','energy_star_rating','year_built','empty'});
state = fitPreprocessor(X);
V = X(1:2,:);
V.facility_type = categorical(["Office";"NewFacility"]);
V.energy_star_rating = [NaN;NaN];
V.year_built = [0;9999];
[actual, ~] = applyPreprocessor(V,state);
verifyEqual(testCase, actual.energy_star_rating, [30;30]);
verifyEqual(testCase, actual.year_built, [2000;9999]);
verifyEqual(testCase, actual.facility_type_was_unknown, [0;1]);
verifyFalse(testCase, ismember('Year_Factor',actual.Properties.VariableNames));
verifyFalse(testCase, ismember('empty',actual.Properties.VariableNames));
verifyEqual(testCase, state.Medians.year_built, 2000);
verifyFalse(testCase, any(ismissing(actual),'all'));
end

function testGroupMedianAndGlobalFallback(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'src'));
X = table(categorical([repmat("A",5,1);repmat("B",5,1);"C"]), ...
    [10;10;10;10;10;100;100;100;100;100;NaN], ...
    'VariableNames', {'facility_type','energy_star_rating'});
state = fitPreprocessor(X);
V = X([1;11],:);
V.energy_star_rating(:) = NaN;
actual = applyPreprocessor(V,state);
verifyEqual(testCase, actual.energy_star_rating, [10;55]);
end
