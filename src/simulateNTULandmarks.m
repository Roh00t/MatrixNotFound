function scenario = simulateNTULandmarks(trainTbl, finalModel, yTrain, figuresDir)
%SIMULATENTULANDMARKS What-if: predicted energy use for two NTU landmarks.
%
%   scenario = SIMULATENTULANDMARKS(trainTbl, finalModel, yTrain, figuresDir)
%   describes The Hive and The Arc as new buildings, predicts their site EUI
%   with the final model, and saves figures/ntu_landmarks.png.
%
%   This is an illustrative scenario, not a measurement:
%     * The model was trained on anonymised US states, so Singapore's climate
%       is not in the data. The buildings are placed in the training state
%       with the most cooling degree days (the closest analogue to a hot,
%       humid climate) among states with at least 100 buildings, using that
%       state's median latest-year weather.
%     * Floor areas are rough public-scale estimates; edit LANDMARKS below.
%     * Energy Star ratings are unknown, so they are left missing and filled
%       by the same facility-type median as any other building.
%   The rows go through exactly the same preprocessData / engineerFeatures
%   steps as the real test set, fitted on all training rows.
%
%   scenario is a table with each building's inputs and predicted EUI, plus
%   the median measured EUI of US university buildings for comparison.

    arguments
        trainTbl   table
        finalModel
        yTrain     (:,1) double
        figuresDir (1,1) string
    end

    % --- Scenario inputs (illustrative estimates) ---------------------------
    landmarks = table( ...
        ["The Hive"; "The Arc"], ...
        [2015; 2018], ...                 % year completed
        [140000; 120000], ...             % floor area, sq ft (approximate)
        VariableNames=["name", "year_built", "floor_area"]);
    facilityType = "Education_College_or_university";

    % --- Climate analogue: hottest training state, latest year -------------
    yearIndex  = str2double(string(trainTbl.Year_Factor));
    latest     = trainTbl(yearIndex == max(yearIndex), :);
    % Only states with enough buildings to give a stable median climate.
    minBuildings = 100;
    coolingByState = groupsummary(latest, "State_Factor", "median", "cooling_degree_days");
    coolingByState = coolingByState(coolingByState.GroupCount >= minBuildings, :);
    [~, hottest] = max(coolingByState.median_cooling_degree_days);
    climateState = coolingByState.State_Factor(hottest);
    climateRows  = latest(latest.State_Factor == climateState, :);

    % Start from one real row (for column types and categories), then set
    % every numeric column to that state's median and apply the scenario.
    template = climateRows(1, :);
    isNumeric = varfun(@isnumeric, template, OutputFormat="uniform");
    template{1, isNumeric} = median(climateRows{:, isNumeric}, 1, "omitmissing");

    buildings = repmat(template, height(landmarks), 1);
    buildings.Year_Factor(:)    = categorical("7");     % predicted like the test year
    buildings.building_class(:) = categorical("Commercial");
    buildings.facility_type(:)  = categorical(facilityType);
    buildings.year_built         = landmarks.year_built;
    buildings.floor_area         = landmarks.floor_area;
    buildings.energy_star_rating = nan(height(landmarks), 1);

    % --- Same preprocessing and features as the real test set ---------------
    [~, prepared] = preprocessData(trainTbl, buildings);
    prepared = engineerLegacyFeatures(prepared);
    predicted = max(predict(finalModel, prepared), 0);

    isUniversity = trainTbl.facility_type == facilityType;
    universityMedian = median(yTrain(isUniversity));

    scenario = addvars(landmarks, predicted, ...
        predicted .* landmarks.floor_area * 0.29307107 / 1000, ...
        NewVariableNames=["predicted_eui", "predicted_MWh_per_year"]);
    scenario.climate_state = repmat(string(climateState), height(scenario), 1);
    scenario.us_university_median_eui = repmat(universityMedian, height(scenario), 1);

    fprintf("\nNTU landmark what-if (climate analogue: %s)\n", climateState);
    disp(scenario(:, ["name", "floor_area", "year_built", "predicted_eui", "predicted_MWh_per_year"]))

    plotLandmarks(scenario, universityMedian, string(climateState), figuresDir);
end

function plotLandmarks(scenario, universityMedian, climateState, figuresDir)
%PLOTLANDMARKS Bar chart of the two predictions against the US reference.
    if ~isfolder(figuresDir)
        mkdir(figuresDir);
    end
    names  = [scenario.name; "Typical US university building"];
    values = [scenario.predicted_eui; universityMedian];

    fig = figure(Visible="off", Position=[100 100 900 560], Theme="light");
    ax = axes(fig);
    b = bar(ax, categorical(names, names), values, 0.55, FaceColor="flat");
    b.CData = [0.11 0.45 0.62; 0.85 0.33 0.10; 0.70 0.72 0.75];
    text(ax, b.XEndPoints, b.YEndPoints, compose("%.0f kBtu/ft²/yr", values), ...
        HorizontalAlignment="center", VerticalAlignment="bottom", FontWeight="bold", FontSize=11);
    ylim(ax, [0, 1.2 * max(values)]);
    grid(ax, "on");
    ylabel(ax, "Predicted site EUI (kBtu/ft²/yr)");
    title(ax, "What-if: NTU's The Hive and The Arc through our model");
    subtitle(ax, "Illustrative: floor areas estimated; climate from the hottest training state (" + ...
        strrep(climateState, "_", " ") + ")");
    exportgraphics(fig, fullfile(figuresDir, "ntu_landmarks.png"), Resolution=150);
    close(fig);
end
