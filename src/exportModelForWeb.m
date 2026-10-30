function exportModelForWeb(finalModel, trainTbl, yTrain, testPrepared, scenarioFile, outFile, checkFile)
%EXPORTMODELFORWEB Export the trained ensemble so a browser can run it.
%
%   EXPORTMODELFORWEB(finalModel, trainTbl, yTrain, testPrepared,
%   scenarioFile, outFile, checkFile) writes outFile (dashboard/model.js) as
%   "window.EUI_MODEL = {...};" containing:
%
%     trees      every regression tree of the LSBoost ensemble as flat arrays
%                (split variable, threshold, children, leaf value, left-going
%                categories) plus the learner weights
%     levels     the category levels behind each categorical predictor's codes
%     baselines  a fully prepared feature vector of a median building for each
%                climate state, built with preprocessData/engineerLegacyFeatures
%     reference  facility-type Energy Star medians and EUI percentiles
%     buildings  the NTU landmark scenarios (from results/ntu_landmarks.csv)
%
%   Before writing, it walks the exported trees in MATLAB and checks the
%   result against predict() on the test set; any mismatch is an error, so a
%   wrong model can never be shipped. checkFile receives test rows and
%   scenario inputs with MATLAB's predictions for the Node.js check
%   (tests/web/checkPredict.mjs).

    arguments
        finalModel
        trainTbl     table
        yTrain       (:,1) double
        testPrepared table
        scenarioFile (1,1) string
        outFile      (1,1) string
        checkFile    (1,1) string
    end

    predictors = string(finalModel.PredictorNames);
    isCategorical = false(1, numel(predictors));
    isCategorical(finalModel.CategoricalPredictors) = true;
    levels = cell(1, numel(predictors));
    for j = find(isCategorical)
        levels{j} = string(finalModel.VariableRange{j});
    end

    % --- Trees as flat arrays (1-based node indices, 0 = leaf) -------------
    trees = cellfun(@exportTree, finalModel.Trained, UniformOutput=false);
    weights = finalModel.TrainedWeights(:)';

    % --- Self-check: exported trees must reproduce predict() ---------------
    Xtest = encodeTable(testPrepared, predictors, isCategorical, levels);
    expected = predict(finalModel, testPrepared);
    walked = walkEnsemble(trees, weights, isCategorical, Xtest);
    maxDiff = max(abs(walked - expected));
    assert(maxDiff < 1e-8, "exportModelForWeb:mismatch", ...
        "Exported trees differ from predict() by %g.", maxDiff);
    fprintf("Web export check: exported trees match predict() on %d test rows (max diff %.2g)\n", ...
        numel(expected), maxDiff);

    % --- Climate baselines and scenario defaults ----------------------------
    facilityType = "Education_College_or_university";
    [baselines, states] = climateBaselines(trainTbl, predictors, isCategorical, levels, facilityType);
    scenarios = readtable(scenarioFile, TextType="string");
    buildings = table(lower(erase(scenarios.name, ["The ", " "])), scenarios.name, ...
        scenarios.year_built, scenarios.floor_area, scenarios.climate_state, ...
        repmat(facilityType, height(scenarios), 1), scenarios.predicted_eui, ...
        VariableNames=["id", "name", "yearBuilt", "floorArea", "state", "facility", "matlabEUI"]);

    model = struct( ...
        "description", "LSBoost v3 (feature selection), exported from MATLAB", ...
        "predictors", predictors, ...
        "isCategorical", isCategorical, ...
        "levels", {levels}, ...
        "weights", weights, ...
        "trees", {trees}, ...
        "measurementYear", 2009 + 7, ...      % Year_Factor 7 = 2016 (see engineerLegacyFeatures)
        "maxAge", 100, ...
        "states", states, ...
        "baselines", baselines, ...
        "reference", facilityReference(trainTbl, yTrain), ...
        "buildings", buildings, ...
        "selfCheckMaxDiff", maxDiff);
    writeJs(outFile, "EUI_MODEL", model);

    % --- Cases for the Node.js check ----------------------------------------
    sample = round(linspace(1, height(testPrepared), 500));
    scenarioCases = scenarioChecks(trainTbl, finalModel, facilityType);
    check = struct("X", Xtest(sample, :), "expected", expected(sample), ...
        "scenarios", scenarioCases);
    writeJson(checkFile, check);
    fprintf("Wrote %s and %s\n", outFile, checkFile);
end

% =========================================================================
function tree = exportTree(t)
%EXPORTTREE Flatten one CompactRegressionTree.
    n = t.NumNodes;
    % Categorical splits list the codes for each side. A code in neither list
    % (a level that never reached this node in training) stops at the node
    % and takes its mean, so both sides are exported.
    catNodes = find(strcmp(t.CutType, "categorical"));
    catLeft  = strings(numel(catNodes), 1);
    catRight = strings(numel(catNodes), 1);
    for k = 1:numel(catNodes)
        catLeft(k)  = strjoin(string(t.CutCategories{catNodes(k), 1}), ",");
        catRight(k) = strjoin(string(t.CutCategories{catNodes(k), 2}), ",");
    end
    tree = struct( ...
        "cutVar",   t.CutPredictorIndex(:)', ...      % 0 at leaves
        "cutPoint", t.CutPoint(:)', ...               % NaN at leaves / categorical
        "left",     t.Children(:, 1)', ...
        "right",    t.Children(:, 2)', ...
        "value",    t.NodeMean(:)', ...
        "catNodes", catNodes(:)', ...
        "catLeft",  catLeft', ...
        "catRight", catRight');
    assert(numel(tree.value) == n);
end

function X = encodeTable(tbl, predictors, isCategorical, levels)
%ENCODETABLE Predictor matrix with categorical values replaced by codes.
    X = zeros(height(tbl), numel(predictors));
    for j = 1:numel(predictors)
        values = tbl.(predictors(j));
        if isCategorical(j)
            % Flags are logical, so their levels are "false"/"true".
            [found, X(:, j)] = ismember(string(values), levels{j});
            assert(all(found), "exportModelForWeb:unknownLevel", ...
                "Unknown level in %s.", predictors(j));
        else
            X(:, j) = double(values);
        end
    end
end

function prediction = walkEnsemble(trees, weights, isCategorical, X)
%WALKENSEMBLE Reference tree walk over the exported arrays (vectorised).
    prediction = zeros(height(X), 1);
    rows = (1:height(X))';
    toCodes = @(list) cellfun(@(s) str2double(split(s, ",")), num2cell(list), UniformOutput=false);
    for t = 1:numel(trees)
        tree = trees{t};
        leftCodes  = containers.Map(KeyType="double", ValueType="any");
        rightCodes = containers.Map(KeyType="double", ValueType="any");
        if ~isempty(tree.catNodes)
            leftCodes  = containers.Map(num2cell(tree.catNodes), toCodes(tree.catLeft));
            rightCodes = containers.Map(num2cell(tree.catNodes), toCodes(tree.catRight));
        end
        node = ones(height(X), 1);
        active = tree.left(node)' > 0;
        while any(active)
            idx = rows(active);
            current = node(idx);
            next = current;                       % unchanged = stop at this node
            for k = 1:numel(idx)
                variable = tree.cutVar(current(k));
                value = X(idx(k), variable);
                if isCategorical(variable)
                    if ismember(value, leftCodes(current(k)))
                        next(k) = tree.left(current(k));
                    elseif ismember(value, rightCodes(current(k)))
                        next(k) = tree.right(current(k));
                    end
                elseif value < tree.cutPoint(current(k))   % MATLAB rule: x < cut goes left
                    next(k) = tree.left(current(k));
                else
                    next(k) = tree.right(current(k));
                end
            end
            node(idx) = next;
            active(idx) = next ~= current;        % rows that stopped are done
            active = active & tree.left(node)' > 0;
        end
        prediction = prediction + weights(t) * tree.value(node)';
    end
end

function [baselines, states] = climateBaselines(trainTbl, predictors, isCategorical, levels, facilityType)
%CLIMATEBASELINES Prepared median-building vector for each climate state.
    minBuildings = 100;
    yearIndex = str2double(string(trainTbl.Year_Factor));
    latest = trainTbl(yearIndex == max(yearIndex), :);
    [counts, stateList] = groupcounts(latest.State_Factor);
    stateList = stateList(counts >= minBuildings);

    baselines = zeros(numel(stateList), numel(predictors));
    [cooling, heating] = deal(zeros(numel(stateList), 1));
    for s = 1:numel(stateList)
        row = scenarioRow(trainTbl, latest(latest.State_Factor == stateList(s), :), ...
            facilityType, 2000, 100000);
        [~, prepared] = preprocessData(trainTbl, row);
        prepared = engineerLegacyFeatures(prepared);
        baselines(s, :) = encodeTable(prepared, predictors, isCategorical, levels);
        cooling(s) = row.cooling_degree_days;
        heating(s) = row.heating_degree_days;
    end
    states = table(string(stateList), strrep(string(stateList), "_", " "), cooling, heating, ...
        VariableNames=["name", "label", "coolingDegreeDays", "heatingDegreeDays"]);
end

function row = scenarioRow(trainTbl, climateRows, facilityType, yearBuilt, floorArea)
%SCENARIOROW One raw building row with a state's median latest-year climate
%   (same construction as simulateNTULandmarks).
    row = climateRows(1, :);
    isNumeric = varfun(@isnumeric, row, OutputFormat="uniform");
    row{1, isNumeric} = median(climateRows{:, isNumeric}, 1, "omitmissing");
    row.Year_Factor(1)    = categorical("7");
    row.building_class(1) = categorical("Commercial");
    row.facility_type(1)  = categorical(facilityType);
    row.year_built        = yearBuilt;
    row.floor_area        = floorArea;
    row.energy_star_rating = NaN;
    row = row(:, trainTbl.Properties.VariableNames);
end

function cases = scenarioChecks(trainTbl, finalModel, facilityType)
%SCENARIOCHECKS Input combinations run through the full MATLAB pipeline, so
%   the browser's encode() step is checked as well as the tree walk.
    yearIndex = str2double(string(trainTbl.Year_Factor));
    latest = trainTbl(yearIndex == max(yearIndex), :);
    stateList = ["State_2", "State_6", "State_11"];
    facilities = [facilityType, "Office_Uncategorized", "Multifamily_Uncategorized"];
    yearsBuilt = [1925, 1990, 2015];
    areas = [20000, 140000, 900000];
    ratings = [NaN, 35, 90];
    classes = ["Commercial", "Residential"];

    k = 0;
    cases = struct("state", {}, "facility", {}, "buildingClass", {}, "yearBuilt", {}, ...
        "floorArea", {}, "energyStar", {}, "expected", {});
    for s = stateList
        for f = 1:numel(facilities)
            k = k + 1;
            row = scenarioRow(trainTbl, latest(latest.State_Factor == s, :), facilities(f), ...
                yearsBuilt(f), areas(f));
            row.energy_star_rating = ratings(f);
            row.building_class(1) = categorical(classes(1 + (f == 3)));
            [~, prepared] = preprocessData(trainTbl, row);
            prepared = engineerLegacyFeatures(prepared);
            cases(k) = struct("state", s, "facility", facilities(f), ...
                "buildingClass", classes(1 + (f == 3)), "yearBuilt", yearsBuilt(f), ...
                "floorArea", areas(f), "energyStar", ratings(f), ...
                "expected", max(predict(finalModel, prepared), 0));
        end
    end
end

function reference = facilityReference(trainTbl, yTrain)
%FACILITYREFERENCE Energy Star fill values and EUI percentiles per type,
%   matching preprocessData's facility-type median imputation.
    types = string(categories(removecats(trainTbl.facility_type)));
    overallRating = median(trainTbl.energy_star_rating, "omitmissing");
    [rating, count] = deal(zeros(numel(types), 1));
    percentiles = zeros(numel(types), 21);
    for k = 1:numel(types)
        inType = trainTbl.facility_type == types(k);
        rating(k) = median(trainTbl.energy_star_rating(inType), "omitmissing");
        count(k) = nnz(inType);
        percentiles(k, :) = prctile(yTrain(inType), 0:5:100);
    end
    rating(isnan(rating)) = overallRating;
    reference = table(types, rating, count, percentiles, ...
        VariableNames=["facility", "energyStarMedian", "count", "euiPercentiles"]);
end

function writeJs(file, variable, value)
%WRITEJS Write value as "window.<variable> = <json>;".
    fid = fopen(file, "w", "n", "UTF-8");
    assert(fid > 0, "exportModelForWeb:openFailed", "Cannot write %s.", file);
    cleanup = onCleanup(@() fclose(fid));
    fprintf(fid, "window.%s = %s;\n", variable, jsonencode(value));
end

function writeJson(file, value)
%WRITEJSON Write value as a JSON file.
    folder = fileparts(file);
    if ~isfolder(folder)
        mkdir(folder);
    end
    fid = fopen(file, "w", "n", "UTF-8");
    assert(fid > 0, "exportModelForWeb:openFailed", "Cannot write %s.", file);
    cleanup = onCleanup(@() fclose(fid));
    fprintf(fid, "%s", jsonencode(value));
end
