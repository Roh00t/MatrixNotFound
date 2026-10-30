function figureFiles = makeFigures(cvReport, finalModel, yTrain, shortlist, figuresDir)
%MAKEFIGURES Save the presentation figures as PNG files.
%
%   figureFiles = MAKEFIGURES(cvReport, finalModel, yTrain, shortlist, figuresDir)
%   writes five figures to figuresDir and returns their paths:
%
%     1_rmse_by_year.png        held-out RMSE per year for every model
%     2_validation_gap.png      random 5-fold vs leave-one-year-out (tree)
%     3_predicted_vs_actual.png out-of-fold predictions of the chosen model
%     4_feature_importance.png  top 15 predictors of the chosen model
%     5_retrofit_radar.png      top 20 buildings by excess energy use
%
%   Figures are created invisibly, so this also runs in matlab -batch.

    arguments
        cvReport   struct
        finalModel
        yTrain     (:,1) double
        shortlist  table
        figuresDir (1,1) string
    end

    if ~isfolder(figuresDir)
        mkdir(figuresDir);
    end

    figureFiles = [
        plotRMSEByYear(cvReport.perYearRMSE)
        plotValidationGap(cvReport.validationGap)
        plotPredictedVsActual(yTrain, cvReport.outOfFoldPredictions, cvReport.bestModelName)
        plotFeatureImportance(finalModel, cvReport.bestModelName)
        plotRetrofitRadar(shortlist)
    ];
    fprintf("Saved %d figures to %s\n", numel(figureFiles), figuresDir);

    % ---------------------------------------------------------------------
    % Each nested plotter draws one figure and writes it to its file.
    % ---------------------------------------------------------------------
    function file = plotRMSEByYear(perYear)
        file = fullfile(figuresDir, "1_rmse_by_year.png");
        [fig, ax] = newFigure();
        years = erase(string(perYear.Properties.VariableNames), "Year_");
        bar(ax, categorical(years), perYear{:, :}');
        legend(ax, perYear.Properties.RowNames, Location="northeast", Interpreter="none");
        xlabel(ax, "Held-out Year\_Factor");
        ylabel(ax, "RMSE (site\_eui)");
        title(ax, "Leave-one-year-out RMSE by model (lower is better)");
        saveFigure(fig, file);
    end

    function file = plotValidationGap(gap)
        file = fullfile(figuresDir, "2_validation_gap.png");
        [fig, ax] = newFigure();
        b = bar(ax, categorical(gap.Scheme, gap.Scheme), gap.Tree_RMSE, 0.5);
        b.FaceColor = "flat";
        b.CData = [0.60 0.60 0.60; 0.85 0.33 0.10];
        text(ax, b.XEndPoints, b.YEndPoints, compose("%.1f", gap.Tree_RMSE), ...
            HorizontalAlignment="center", VerticalAlignment="bottom", FontWeight="bold");
        ylabel(ax, "RMSE of baseline tree");
        title(ax, sprintf("Random folds understate error by %.1f: we validate by year", ...
            diff(gap.Tree_RMSE)));
        ylim(ax, [0, 1.15 * max(gap.Tree_RMSE)]);
        saveFigure(fig, file);
    end

    function file = plotPredictedVsActual(actual, predicted, modelName)
        file = fullfile(figuresDir, "3_predicted_vs_actual.png");
        [fig, ax] = newFigure();
        scatter(ax, actual, predicted, 4, "filled", MarkerFaceAlpha=0.08);
        hold(ax, "on");
        limits = [0, prctile(actual, 99.5)];
        plot(ax, limits, limits, "k--", LineWidth=1.5);
        hold(ax, "off");
        xlim(ax, limits); ylim(ax, limits); axis(ax, "square");
        xlabel(ax, "Actual site\_eui");
        ylabel(ax, "Out-of-fold predicted site\_eui");
        title(ax, sprintf("%s: RMSE %.1f on unseen years", modelName, ...
            computeRMSE(actual, predicted)), Interpreter="none");
        saveFigure(fig, file);
    end

    function file = plotFeatureImportance(model, modelName)
        file = fullfile(figuresDir, "4_feature_importance.png");
        [fig, ax] = newFigure();
        importance = predictorImportance(model);
        [importance, order] = sort(importance, "descend");
        nTop = min(15, numel(importance));
        names = string(model.PredictorNames(order(1:nTop)));
        barh(ax, categorical(names, flip(names)), importance(1:nTop));
        ax.TickLabelInterpreter = "none";
        xlabel(ax, "Predictor importance");
        title(ax, "Top predictors: " + modelName, Interpreter="none");
        saveFigure(fig, file);
    end

    function file = plotRetrofitRadar(list)
        file = fullfile(figuresDir, "5_retrofit_radar.png");
        [fig, ax] = newFigure();
        nTop = min(20, height(list));
        top = list(1:nTop, :);
        labels = compose("#%d %s (%s, +%.0f%%)", top.rank, ...
            strrep(string(top.facility_type), "_", " "), string(top.State_Factor), top.excess_pct);
        barh(ax, categorical(labels, flip(labels)), top.excess_MWh_per_year, ...
            FaceColor=[0.85 0.33 0.10]);
        ax.TickLabelInterpreter = "none";
        ax.FontSize = 8;
        xlabel(ax, "Excess energy vs. similar buildings (MWh per year)");
        title(ax, "Retrofit Radar: top 20 buildings using more than expected");
        saveFigure(fig, file);
    end

    function [fig, ax] = newFigure()
        % Light theme regardless of the desktop setting, for slide contrast.
        fig = figure(Visible="off", Position=[100 100 1000 600], Theme="light");
        ax = axes(fig);
        grid(ax, "on");
    end

    function saveFigure(fig, file)
        exportgraphics(fig, file, Resolution=150);
        close(fig);
    end
end
