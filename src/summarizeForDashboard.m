function dash = summarizeForDashboard(dash, cvReport, yTrain, shortlist, radar, submission, crossCheckFile, finalModel)
%SUMMARIZEFORDASHBOARD Add the finished-run results to the dashboard struct.
%
%   dash = SUMMARIZEFORDASHBOARD(dash, cvReport, yTrain, shortlist, radar,
%   submission, crossCheckFile, finalModel) fills in everything the dashboard
%   displays after a complete run: model comparison, per-year RMSE, the
%   validation gap, feature importance, an actual-vs-predicted count grid,
%   Retrofit Radar summaries, the submission profile, and (if the file
%   exists) the independent step-pipeline cross-check scores. The page draws
%   these as interactive charts.

    arguments
        dash           (1,1) struct
        cvReport       (1,1) struct
        yTrain         (:,1) double
        shortlist      table
        radar          table
        submission     table
        crossCheckFile (1,1) string
        finalModel
    end

    results = cvReport.results;
    perYear = cvReport.perYearRMSE;
    best    = results.Model == cvReport.bestModelName;

    % --- Headline numbers ---------------------------------------------------
    treeRMSE = results.LOYO_RMSE(1);
    bestRMSE = results.LOYO_RMSE(best);
    gap      = cvReport.validationGap.Tree_RMSE;
    isFlagged = radar.excess_pct >= 50;

    dash.headline = struct( ...
        "bestModel",          cvReport.bestModelName, ...
        "bestRMSE",           bestRMSE, ...
        "baselineRMSE",       treeRMSE, ...
        "improvementPct",     100 * (treeRMSE - bestRMSE) / treeRMSE, ...
        "kfoldRMSE",          gap(1), ...
        "kfoldOptimism",      gap(2) - gap(1), ...
        "oofRMSE",            computeRMSE(yTrain, cvReport.outOfFoldPredictions), ...
        "radarBuildings",     height(radar), ...
        "radarFlagged",       nnz(isFlagged), ...
        "radarFlaggedPct",    100 * mean(isFlagged), ...
        "shortlistGWh",       sum(shortlist.excess_MWh_per_year) / 1000);

    % --- Model comparison and per-year matrix ------------------------------
    % Same shape trainModels reports during the run (see main.m ProgressFcn).
    dash.modelTable    = results;
    dash.perYear       = perYear{:, :};
    dash.years         = erase(string(perYear.Properties.VariableNames), "Year_");
    dash.validationGap = cvReport.validationGap;

    % --- Feature importance (top 15) and actual-vs-predicted grid ----------
    importance = predictorImportance(finalModel);
    [importance, order] = sort(importance, "descend");
    nTop = min(15, numel(importance));
    dash.importance = table(string(finalModel.PredictorNames(order(1:nTop)))', ...
        importance(1:nTop)', VariableNames=["feature", "importance"]);

    gridEdges = 0:20:400;                                  % kBtu/ft²/yr bins
    clip = @(v) min(v, gridEdges(end) - eps);
    dash.errorGrid = struct("edges", gridEdges, "counts", ...
        histcounts2(clip(yTrain), clip(cvReport.outOfFoldPredictions), gridEdges, gridEdges));

    % --- Retrofit Radar -----------------------------------------------------
    % Per state: share of buildings 50%+ over expected, and total excess energy
    % (only buildings above expected contribute to the excess).
    perBuilding = table(radar.State_Factor, radar.excess_pct >= 50, ...
        max(radar.excess_MWh_per_year, 0), VariableNames=["state", "flagged", "excessMWh"]);
    byState = groupsummary(perBuilding, "state", {"mean", "sum"}, ["flagged", "excessMWh"]);
    dash.radarByState = table(string(byState.state), byState.GroupCount, ...
        100 * byState.mean_flagged, byState.sum_excessMWh / 1000, ...
        VariableNames=["state", "buildings", "flaggedPct", "excessGWh"]);

    dash.shortlist = convertvars(shortlist(:, ["rank", "train_id", "facility_type", ...
        "State_Factor", "floor_area", "year_built", "actual_eui", "expected_eui", ...
        "excess_pct", "excess_MWh_per_year"]), @iscategorical, "string");

    % --- Submission profile (year-7 predictions) ---------------------------
    edges  = 0:25:300;
    counts = histcounts(min(submission.site_eui, edges(end) - eps), edges);
    dash.submission = struct( ...
        "rows",  height(submission), ...
        "min",   min(submission.site_eui), ...
        "median", median(submission.site_eui), ...
        "max",   max(submission.site_eui), ...
        "binEdges", edges, ...
        "binCounts", counts);

    % --- Independent cross-check (step pipeline), if present ---------------
    if isfile(crossCheckFile)
        crossCheck = readtable(crossCheckFile, TextType="string");
        dash.crossCheck = struct( ...
            "models", crossCheck, ...
            "ourYear6", perYear{best, end}, ...
            "ourModel", cvReport.bestModelName);
    end
end
