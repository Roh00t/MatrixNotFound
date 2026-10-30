function [trainTbl, testTbl, yTrain, testIds] = loadData(dataDir)
%LOADDATA Load the WiDS 2022 building-energy data and cast column types.
%
%   [trainTbl, testTbl, yTrain, testIds] = LOADDATA(dataDir) reads
%   train.csv and test.csv from dataDir and returns:
%
%     trainTbl - training predictors (table), target and id removed
%     testTbl  - test predictors (table), id removed, same columns as trainTbl
%     yTrain   - training target site_eui (double column vector)
%     testIds  - test row identifiers, needed for submission.csv
%
%   Categorical columns (Year_Factor, State_Factor, building_class,
%   facility_type) are imported as categorical, and every categorical
%   column is given an identical category list in train and test so that
%   downstream models see one consistent encoding.
%
%   All remaining columns are forced to double so that a column that
%   happens to be mostly empty in one file cannot be auto-detected as text.

    arguments
        dataDir (1,1) string {mustBeFolder}
    end

    trainFile = fullfile(dataDir, "train.csv");
    testFile  = fullfile(dataDir, "test.csv");

    categoricalVars = ["Year_Factor", "State_Factor", "building_class", "facility_type"];
    targetVar = "site_eui";
    idVar     = "id";

    % --- Read both files with explicit, matching column types -------------
    trainTbl = readtable(trainFile, buildImportOptions(trainFile, categoricalVars));
    testTbl  = readtable(testFile,  buildImportOptions(testFile,  categoricalVars));

    % --- Separate target and identifiers from the predictors -------------
    yTrain  = trainTbl.(targetVar);
    testIds = testTbl.(idVar);

    % The training id is just a row counter, so it carries no signal.
    trainTbl = removevars(trainTbl, [targetVar, idVar]);
    testTbl  = removevars(testTbl,  idVar);

    % --- Give train and test the same category levels ---------------------
    % The union keeps levels that appear in only one file (e.g. Year_Factor
    % 7 exists only in test), so nothing is silently turned into <undefined>.
    for v = categoricalVars
        sharedLevels = union(categories(trainTbl.(v)), categories(testTbl.(v)));
        trainTbl.(v) = setcats(trainTbl.(v), sharedLevels);
        testTbl.(v)  = setcats(testTbl.(v),  sharedLevels);
    end

    % --- Sanity checks: fail fast if the files are not what we expect -----
    assert(isequal(trainTbl.Properties.VariableNames, testTbl.Properties.VariableNames), ...
        "loadData:columnMismatch", "train.csv and test.csv predictor columns differ.");
    assert(~anymissing(yTrain), ...
        "loadData:missingTarget", "site_eui contains missing values.");
    assert(numel(unique(testIds)) == numel(testIds), ...
        "loadData:duplicateIds", "test.csv contains duplicate ids.");

    fprintf("Loaded train: %d rows x %d predictors\n", height(trainTbl), width(trainTbl));
    fprintf("Loaded test:  %d rows x %d predictors\n", height(testTbl),  width(testTbl));
end

function opts = buildImportOptions(csvFile, categoricalVars)
%BUILDIMPORTOPTIONS Import options with categorical and double columns fixed.
    opts = detectImportOptions(csvFile);
    numericVars = setdiff(opts.VariableNames, categoricalVars, "stable");
    opts = setvartype(opts, numericVars, "double");
    opts = setvartype(opts, categoricalVars, "categorical");
end
