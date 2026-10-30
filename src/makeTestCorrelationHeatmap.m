function [figureFile, R, labels] = makeTestCorrelationHeatmap(dataDir, submissionFile, figuresDir, nFeatures)
%MAKETESTCORRELATIONHEATMAP 30x30 correlation heatmap for the test set.
%
%   [figureFile, R, labels] = MAKETESTCORRELATIONHEATMAP(dataDir,
%   submissionFile, figuresDir) reads test.csv, joins the predicted site_eui
%   from submission.csv by id, and saves a correlation heatmap of site_eui
%   and the 29 numeric features most correlated with it to
%   figures/12_test_correlation_30x30.png.
%
%   test.csv has no measured site_eui (it is what the competition asks us
%   to predict), so the site_eui row/column is our model's prediction.
%   Columns that are constant in the test set (e.g. Year_Factor, always 7)
%   have no defined correlation and are skipped. Missing values are handled
%   pairwise, so sparse columns such as energy_star_rating still use every
%   row where both values exist.

    arguments
        dataDir        (1,1) string
        submissionFile (1,1) string
        figuresDir     (1,1) string
        nFeatures      (1,1) double {mustBeInteger, mustBePositive} = 29
    end

    test = readtable(fullfile(dataDir, "test.csv"));
    submission = readtable(submissionFile);
    test = innerjoin(test, submission, Keys="id");
    assert(height(test) == height(submission), ...
        "makeTestCorrelationHeatmap:join", "Every test id must have a prediction.");

    % Numeric, non-constant candidate features (ids and the target excluded).
    isNumeric = varfun(@isnumeric, test, OutputFormat="uniform");
    candidates = string(test.Properties.VariableNames(isNumeric));
    candidates = setdiff(candidates, ["id", "site_eui"], "stable");
    varies = arrayfun(@(c) numel(unique(test.(c)(~isnan(test.(c))))) > 1, candidates);
    candidates = candidates(varies);

    % Rank by absolute correlation with predicted site_eui; keep the top N.
    rWithTarget = corrcoef([test.site_eui, test{:, candidates}], Rows="pairwise");
    rWithTarget = rWithTarget(1, 2:end);
    [~, order] = sort(abs(rWithTarget), "descend");
    keep = order(1:min(nFeatures, numel(order)));
    [~, bySign] = sort(rWithTarget(keep), "descend");      % positive to negative
    features = candidates(keep(bySign));

    labels = ["site_eui (predicted)", features];
    R = corrcoef([test.site_eui, test{:, features}], Rows="pairwise");

    if ~isfolder(figuresDir)
        mkdir(figuresDir);
    end
    figureFile = fullfile(figuresDir, "12_test_correlation_30x30.png");
    fig = figure(Visible="off", Position=[100 100 1500 1300], Theme="light");
    readableLabels = strrep(labels, "_", " ");
    h = heatmap(fig, readableLabels, readableLabels, round(R, 2), ...
        Colormap=diverging(), ColorLimits=[-1 1], FontSize=8, CellLabelFormat="%.2f");
    h.Title = sprintf("Test set (%d buildings): correlation of predicted site\\_eui and the %d most related features", ...
        height(test), numel(features));
    exportgraphics(fig, figureFile, Resolution=150);
    close(fig);
    fprintf("Saved %dx%d test-set correlation heatmap to %s\n", numel(labels), numel(labels), figureFile);
end

function cmap = diverging()
%DIVERGING Blue-white-red colormap for signed values centred on zero.
    n = 128;
    ramp = linspace(0, 1, n)';
    blue = [0.13 0.40 0.67];
    red  = [0.70 0.09 0.17];
    cmap = [blue + (1 - blue) .* ramp; red + (1 - red) .* flip(ramp)];
end
