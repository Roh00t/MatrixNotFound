function figureFiles = makeIterationFigures(cvReport, figuresDir)
%MAKEITERATIONFIGURES Save figures that show how the model improved.
%
%   figureFiles = MAKEITERATIONFIGURES(cvReport, figuresDir) writes:
%
%     10_iteration_heatmap.png  RMSE for every model (columns) on every
%                               held-out year (rows): the full LOYO grid
%     11_model_journey.png      overall LOYO RMSE per model, baseline to
%                               final, with the improvement over the tree
%
%   Both use only the cross-validation scores stored in cvReport, so no
%   model needs to be retrained.

    arguments
        cvReport   (1,1) struct
        figuresDir (1,1) string
    end

    if ~isfolder(figuresDir)
        mkdir(figuresDir);
    end

    names   = cvReport.results.Model;
    rmse    = cvReport.results.LOYO_RMSE;
    perYear = cvReport.perYearRMSE;
    years   = "Year " + erase(string(perYear.Properties.VariableNames), "Year_");
    isBest  = names == cvReport.bestModelName;

    figureFiles = [plotIterationHeatmap(); plotJourney()];
    fprintf("Saved %d iteration figures to %s\n", numel(figureFiles), figuresDir);

    % ---------------------------------------------------------------------
    function file = plotIterationHeatmap()
        file = fullfile(figuresDir, "10_iteration_heatmap.png");
        fig = figure(Visible="off", Position=[100 100 950 560], Theme="light");
        h = heatmap(fig, shortName(names), years, round(perYear{:, :}', 1), ...
            Colormap=flipud(hot(256)) * 0.85 + 0.15, FontSize=11, CellLabelFormat="%.1f");
        h.Title = "Held-out RMSE for every model and every year (lower is better)";
        h.XLabel = "Model iteration";
        h.YLabel = "Held-out year (leave-one-year-out fold)";
        exportgraphics(fig, file, Resolution=150);
        close(fig);
    end

    function file = plotJourney()
        file = fullfile(figuresDir, "11_model_journey.png");
        fig = figure(Visible="off", Position=[100 100 1000 560], Theme="light");
        ax = axes(fig);
        b = bar(ax, categorical(shortName(names), shortName(names)), rmse, 0.6, FaceColor="flat");
        b.CData = repmat([0.55 0.65 0.78], numel(rmse), 1);
        b.CData(isBest, :) = [0.85 0.33 0.10];
        labels = compose("%.2f", rmse);
        labels(2:end) = labels(2:end) + compose(" (−%.0f%%)", 100 * (rmse(1) - rmse(2:end)) / rmse(1));
        text(ax, b.XEndPoints, b.YEndPoints, labels, HorizontalAlignment="center", ...
            VerticalAlignment="bottom", FontWeight="bold", FontSize=11);
        ylim(ax, [0, 1.15 * max(rmse)]);
        grid(ax, "on");
        ylabel(ax, "Leave-one-year-out RMSE");
        title(ax, "Model journey: from a single tree to tuned gradient boosting");
        exportgraphics(fig, file, Resolution=150);
        close(fig);
    end
end

function short = shortName(names)
%SHORTNAME Two-line labels such as "LSBoost v3" + "(feature selection)".
    short = replace(string(names), " (", newline + "(");
end
