function figureFiles = makeHeatmaps(trainTbl, trainPrepared, yTrain, expectedEUI, radar, figuresDir)
%MAKEHEATMAPS Save matrix-style diagnostic figures as PNG files.
%
%   figureFiles = MAKEHEATMAPS(trainTbl, trainPrepared, yTrain, expectedEUI,
%   radar, figuresDir) writes four heatmaps to figuresDir:
%
%     6_feature_correlation.png  correlation between site_eui and the main
%                                building, climate and engineered features
%     7_prediction_heatmap.png   the regression version of a confusion
%                                matrix: counts of actual vs. predicted EUI
%                                (out-of-fold), with the y = x line
%     8_radar_state_facility.png median excess EUI by state and facility
%                                type: where to target energy audits
%     9_residual_year_state.png  mean residual by year and state: shows the
%                                drift that leave-one-year-out CV accounts for
%
%     trainTbl      - raw training predictors (Year_Factor, State_Factor, ...)
%     trainPrepared - training predictors after preprocessData/engineerFeatures
%     yTrain        - measured site_eui
%     expectedEUI   - out-of-fold predictions aligned with yTrain
%     radar         - full scored table returned by retrofitRadar

    arguments
        trainTbl      table
        trainPrepared table
        yTrain        (:,1) double
        expectedEUI   (:,1) double
        radar         table
        figuresDir    (1,1) string
    end

    if ~isfolder(figuresDir)
        mkdir(figuresDir);
    end

    figureFiles = [
        plotFeatureCorrelation()
        plotPredictionHeatmap()
        plotRadarByStateAndFacility()
        plotResidualByYearAndState()
    ];
    fprintf("Saved %d heatmaps to %s\n", numel(figureFiles), figuresDir);

    % ---------------------------------------------------------------------
    function file = plotFeatureCorrelation()
        file = fullfile(figuresDir, "6_feature_correlation.png");
        features = ["energy_star_rating", "floor_area", "year_built", "building_age", ...
                    "heating_degree_days", "cooling_degree_days", "ELEVATION", ...
                    "floor_area_x_hdd", "floor_area_x_cdd", "energy_star_x_floor_area"];
        labels = readable(["site_eui", features]);
        R = corrcoef([yTrain, trainPrepared{:, features}]);

        fig = newFigure([100 100 950 800]);
        h = heatmap(fig, labels, labels, round(R, 2), Colormap=diverging(), ...
            ColorLimits=[-1 1], FontSize=10);
        h.Title = "Correlation between site\_eui and key features (training data)";
        saveFigure(fig, file);
    end

    function file = plotPredictionHeatmap()
        file = fullfile(figuresDir, "7_prediction_heatmap.png");
        upper = ceil(prctile(yTrain, 99) / 50) * 50;
        edges = 0:20:upper;

        fig = newFigure([100 100 850 800]);
        ax = axes(fig);
        histogram2(ax, min(yTrain, upper), min(expectedEUI, upper), edges, edges, ...
            DisplayStyle="tile", ShowEmptyBins="off", Normalization="count");
        set(ax, ColorScale="log");
        cb = colorbar(ax);
        cb.Label.String = "Buildings (log scale)";
        hold(ax, "on");
        plot(ax, [0 upper], [0 upper], "k--", LineWidth=1.5);
        hold(ax, "off");
        axis(ax, "square");
        xlabel(ax, "Actual site\_eui");
        ylabel(ax, "Predicted site\_eui (out-of-fold)");
        title(ax, "Prediction error heatmap: mass on the diagonal = accurate");
        saveFigure(fig, file);
    end

    function file = plotRadarByStateAndFacility()
        file = fullfile(figuresDir, "8_radar_state_facility.png");
        % Restrict to the ten most common facility types so cells have support.
        [counts, types] = groupcounts(radar.facility_type);
        [~, order] = sort(counts, "descend");
        topTypes = types(order(1:min(10, numel(types))));
        subset = radar(ismember(radar.facility_type, topTypes), :);
        subset.facility_type = readableCats(subset.facility_type);
        subset.State_Factor  = readableCats(subset.State_Factor);

        fig = newFigure([100 100 1150 650]);
        h = heatmap(fig, subset, "facility_type", "State_Factor", ...
            ColorVariable="excess_eui", ColorMethod="median", Colormap=diverging(), FontSize=10);
        h.ColorLimits = [-1 1] * max(abs(h.ColorData(:)), [], "omitmissing");
        h.Title = "Retrofit Radar: median excess EUI (kBtu/ft²) vs. expected, latest year";
        h.XLabel = "Facility type (10 most common)";
        h.YLabel = "State";
        styleMissing(h);
        saveFigure(fig, file);
    end

    function file = plotResidualByYearAndState()
        file = fullfile(figuresDir, "9_residual_year_state.png");
        residuals = table(trainTbl.Year_Factor, trainTbl.State_Factor, yTrain - expectedEUI, ...
            VariableNames=["Year_Factor", "State_Factor", "residual"]);
        residuals.Year_Factor  = readableCats(residuals.Year_Factor);
        residuals.State_Factor = readableCats(residuals.State_Factor);

        fig = newFigure([100 100 900 600]);
        h = heatmap(fig, residuals, "Year_Factor", "State_Factor", ...
            ColorVariable="residual", ColorMethod="mean", Colormap=diverging(), FontSize=10);
        h.ColorLimits = [-1 1] * max(abs(h.ColorData(:)), [], "omitmissing");
        h.Title = "Mean residual (actual − predicted) by held-out year and state";
        h.XLabel = "Year Factor (each predicted by a model that never saw that year)";
        h.YLabel = "State";
        styleMissing(h);
        saveFigure(fig, file);
    end

    function styleMissing(h)
        % Light grey for state/type combinations with no buildings.
        h.MissingDataLabel = "no buildings";
        h.MissingDataColor = [0.93 0.93 0.93];
    end

    function fig = newFigure(position)
        fig = figure(Visible="off", Position=position, Theme="light");
    end

    function saveFigure(fig, file)
        exportgraphics(fig, file, Resolution=150);
        close(fig);
    end
end

function labels = readable(names)
%READABLE Replace underscores, which heatmap labels render as subscripts.
    labels = strrep(string(names), "_", " ");
end

function c = readableCats(c)
%READABLECATS Drop unused categories and make category names label-safe.
    c = removecats(c);
    c = renamecats(c, cellstr(readable(categories(c))));
end

function cmap = diverging()
%DIVERGING Blue-white-red colormap for signed values centred on zero.
    n = 128;
    ramp = linspace(0, 1, n)';
    blue = [0.13 0.40 0.67];
    red  = [0.70 0.09 0.17];
    cmap = [blue + (1 - blue) .* ramp; red + (1 - red) .* flip(ramp)];
end
