function [XTrain, yTrain, XTest, trainID, testID, report] = loadBuildingData(dataDir)
%LOADBUILDINGDATA Read WiDS CSVs without learning preprocessing statistics.
% Missing predictor values are preserved for subsequent fold-local imputation.
% Test-only category labels become undefined and are counted in REPORT.
arguments
    dataDir (1,1) string
end

trainFile = fullfile(dataDir, 'train.csv');
testFile = fullfile(dataDir, 'test.csv');
assert(isfile(trainFile), 'BuildingEnergy:MissingFile', ...
    'Training file not found: %s', trainFile);
assert(isfile(testFile), 'BuildingEnergy:MissingFile', ...
    'Test file not found: %s', testFile);

categoryNames = {'Year_Factor', 'State_Factor', 'building_class', 'facility_type'};
% Import these columns as strings first so identifiers have consistent labels
% even when CSV type inference differs between the two datasets.
trainOptions = detectImportOptions(trainFile, 'VariableNamingRule', 'preserve');
testOptions = detectImportOptions(testFile, 'VariableNamingRule', 'preserve');
requireColumns(trainOptions.VariableNames, ...
    [{'id', 'site_eui'}, categoryNames], 'train.csv');
requireColumns(testOptions.VariableNames, [{'id'}, categoryNames], 'test.csv');
trainOptions = setvartype(trainOptions, categoryNames, 'string');
testOptions = setvartype(testOptions, categoryNames, 'string');
trainTable = readtable(trainFile, trainOptions);
testTable = readtable(testFile, testOptions);
assert(height(trainTable) > 0 && height(testTable) > 0, ...
    'BuildingEnergy:EmptyData', 'Both CSVs must contain data rows.');
assert(~ismember('site_eui', testTable.Properties.VariableNames), ...
    'BuildingEnergy:UnexpectedTarget', 'test.csv must not contain site_eui.');

yTrain = trainTable.site_eui;
assert(isnumeric(yTrain) && iscolumn(yTrain) && ...
    all(isfinite(yTrain)) && all(yTrain >= 0), ...
    'BuildingEnergy:InvalidTarget', ...
    'site_eui must be a finite, nonnegative numeric column.');
trainID = trainTable.id;
testID = testTable.id;
assert(~any(ismissing(trainID)) && ~any(ismissing(testID)) && ...
    numel(unique(trainID)) == height(trainTable) && ...
    numel(unique(testID)) == height(testTable), ...
    'BuildingEnergy:InvalidID', 'IDs must be present and unique within each CSV.');

XTrain = removevars(trainTable, {'id', 'site_eui'});
XTest = removevars(testTable, 'id');
predictorNames = XTrain.Properties.VariableNames;
assert(isequal(sort(predictorNames), sort(XTest.Properties.VariableNames)), ...
    'BuildingEnergy:SchemaMismatch', 'Train and test predictors must match.');
XTest = XTest(:, predictorNames);

unseenCounts = zeros(numel(categoryNames), 1);
for k = 1:numel(categoryNames)
    name = categoryNames{k};
    XTrain.(name) = categorical(XTrain.(name));
    levels = categories(XTrain.(name));
    testLabels = XTest.(name);
    unseenCounts(k) = nnz(~ismissing(testLabels) & ~ismember(testLabels, levels));
    XTest.(name) = categorical(testLabels, levels);
    % Explicitly retain training vocabulary, including unused levels in test.
    XTest.(name) = reordercats(XTest.(name), levels);
end

% Reject silent numeric/text mismatches rather than passing them to a model.
for k = 1:numel(predictorNames)
    name = predictorNames{k};
    assert(strcmp(class(XTrain.(name)), class(XTest.(name))), ...
        'BuildingEnergy:TypeMismatch', ...
        'Predictor %s has different train/test types.', name);
end
report = struct;
report.TrainRows = height(XTrain);
report.TestRows = height(XTest);
report.MissingPredictors = table(string(predictorNames(:)), ...
    sum(ismissing(XTrain), 1)', sum(ismissing(XTest), 1)', ...
    'VariableNames', {'Predictor', 'TrainMissing', 'TestMissing'});
report.UnseenTestCategories = table(string(categoryNames(:)), unseenCounts, ...
    'VariableNames', {'Predictor', 'UnseenCount'});
end

function requireColumns(actual, required, fileName)
missing = setdiff(required, actual);
assert(isempty(missing), 'BuildingEnergy:MissingColumns', ...
    '%s is missing required columns: %s', fileName, strjoin(missing, ', '));
end
