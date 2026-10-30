function [trainTbl, testTbl] = preprocessData(trainTbl, testTbl)
%PREPROCESSDATA Clean, impute and align the train and test predictor tables.
%
%   [trainTbl, testTbl] = PREPROCESSDATA(trainTbl, testTbl) takes the
%   tables returned by loadData and returns copies with no missing values.
%
%   Every imputation statistic is learned from the TRAINING table only and
%   then applied unchanged to both tables, so no information from test.csv
%   leaks into training and both tables are filled identically.
%
%   Steps:
%     1. Year_Factor is converted from categorical to an ordinal number.
%        Every test row is year 7, a level never seen in training, so as a
%        categorical it carries no usable signal; as a number, tree models
%        can treat year 7 as "later than year 6".
%     2. year_built == 0 is treated as missing (it is a placeholder value).
%     3. Missing-value indicator columns (<name>_missing) are added before
%        filling, because whether a value was recorded is itself predictive.
%     4. energy_star_rating is filled with the median of its facility_type,
%        falling back to the overall median for types with no ratings.
%     5. All remaining numeric gaps use the overall training median.

    arguments
        trainTbl table
        testTbl  table
    end

    trainTbl = cleanRawValues(trainTbl);
    testTbl  = cleanRawValues(testTbl);

    imputer  = fitImputer(trainTbl);
    trainTbl = applyImputer(trainTbl, imputer);
    testTbl  = applyImputer(testTbl,  imputer);

    % --- Sanity checks -----------------------------------------------------
    assert(~any(ismissing(trainTbl), "all") && ~any(ismissing(testTbl), "all"), ...
        "preprocessData:missingRemain", "Missing values remain after imputation.");

    catVars = trainTbl.Properties.VariableNames(varfun(@iscategorical, trainTbl, OutputFormat="uniform"));
    for v = string(catVars)
        assert(isequal(categories(trainTbl.(v)), categories(testTbl.(v))), ...
            "preprocessData:categoryMismatch", "Category levels differ for %s.", v);
    end

    fprintf("Preprocessed: %d predictors, 0 missing values in train and test\n", width(trainTbl));
end

function tbl = cleanRawValues(tbl)
%CLEANRAWVALUES Fix encodings that are wrong before any statistics are taken.
    tbl.Year_Factor = str2double(string(tbl.Year_Factor));
    tbl.year_built  = standardizeMissing(tbl.year_built, 0);
end

function imputer = fitImputer(trainTbl)
%FITIMPUTER Learn every fill value from the training table.

    imputer.flagVars = ["year_built", "energy_star_rating", ...
        "direction_max_wind_speed", "direction_peak_wind_speed", ...
        "max_wind_speed", "days_with_fog"];

    % Median energy_star_rating for each facility_type category. Categories
    % are aligned between train and test (see loadData), so the category
    % code can index straight into this vector. Types without any rating
    % stay NaN here and fall through to the overall median.
    typeCode = double(trainTbl.facility_type);
    assert(all(isfinite(typeCode)), ...
        "preprocessData:missingFacilityType", ...
        "facility_type must be present in the training rows.");
    nTypes   = numel(categories(trainTbl.facility_type));
    imputer.energyStarByType = accumarray(typeCode, trainTbl.energy_star_rating, [nTypes 1], ...
        @(x) median(x, "omitmissing"), NaN);

    % Overall median of every numeric column, used for remaining gaps and
    % as the fallback for facility types with no observed ratings.
    isNumericVar = varfun(@isnumeric, trainTbl, OutputFormat="uniform");
    imputer.numericVars    = string(trainTbl.Properties.VariableNames(isNumericVar));
    imputer.numericMedians = median(trainTbl{:, imputer.numericVars}, 1, "omitmissing");
    assert(all(isfinite(imputer.numericMedians)), ...
        "preprocessData:noObservedValues", ...
        "At least one numeric predictor has no finite training values.");
end

function tbl = applyImputer(tbl, imputer)
%APPLYIMPUTER Fill missing values using statistics learned by fitImputer.

    % 1) Record where values were missing, before anything is filled.
    for v = imputer.flagVars
        tbl.(v + "_missing") = ismissing(tbl.(v));
    end

    % 2) energy_star_rating: median rating of the building's facility type.
    typeCode = double(tbl.facility_type);
    assert(all(isfinite(typeCode)), ...
        "preprocessData:missingFacilityType", ...
        "facility_type must be present for every row.");
    groupMedian = imputer.energyStarByType(typeCode);
    isGap = ismissing(tbl.energy_star_rating);
    tbl.energy_star_rating(isGap) = groupMedian(isGap);

    % 3) Every other gap, plus facility types with no ratings: overall median.
    for k = 1:numel(imputer.numericVars)
        variable = imputer.numericVars(k);
        values = tbl.(variable);
        values(ismissing(values)) = imputer.numericMedians(k);
        tbl.(variable) = values;
    end
end
