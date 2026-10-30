function [shortlist, radar] = retrofitRadar(trainTbl, yTrain, expectedEUI, outFile, topN)
%RETROFITRADAR Rank buildings by how much more energy they use than expected.
%
%   [shortlist, radar] = RETROFITRADAR(trainTbl, yTrain, expectedEUI, outFile)
%   turns the prediction model into a retrofit tool. For every building in
%   the most recent training year it compares:
%
%     actual EUI   - the measured site_eui (kBtu per sq ft per year)
%     expected EUI - the model's out-of-fold prediction: what a building of
%                    this type, size, age and climate typically uses, made
%                    by a model that never saw this building-year
%
%   A building far above its expected EUI is using more energy than its
%   peers, which makes it a strong candidate for an energy audit or retrofit.
%   Ranking by total excess energy (excess EUI x floor area) puts the
%   biggest absolute savings opportunities first.
%
%     trainTbl    - raw training predictors from loadData
%     yTrain      - measured site_eui
%     expectedEUI - out-of-fold predictions aligned with yTrain (cvReport)
%     outFile     - CSV path for the shortlist
%     topN        - shortlist length (default 50)
%
%   Returns the top-N shortlist and the full scored table for that year.
%
%   Caveat: the same building can appear in other training years, so the
%   model may partly "remember" it and the excess shown is conservative.
%   The radar flags candidates for inspection; it is not a verdict.

    arguments
        trainTbl    table
        yTrain      (:,1) double
        expectedEUI (:,1) double {mustBeEqualLength(expectedEUI, yTrain)}
        outFile     (1,1) string
        topN        (1,1) double {mustBeInteger, mustBePositive} = 50
    end

    kBtuToMWh = 0.29307107 / 1000;   % 1 kBtu = 0.293 kWh
    minExpectedEUI = 1;              % avoid dividing by near-zero predictions

    % --- Score the most recent year (closest to the year-7 test set) ------
    yearIndex  = str2double(string(trainTbl.Year_Factor));
    latestYear = max(yearIndex);
    inYear     = yearIndex == latestYear;

    radar = trainTbl(inYear, ["facility_type", "State_Factor", "building_class", ...
                              "floor_area", "year_built", "energy_star_rating"]);
    radar = addvars(radar, find(inYear) - 1, Before=1, NewVariableNames="train_id");

    radar.actual_eui   = yTrain(inYear);
    radar.expected_eui = max(expectedEUI(inYear), minExpectedEUI);
    radar.excess_eui   = radar.actual_eui - radar.expected_eui;
    radar.excess_pct   = 100 * radar.excess_eui ./ radar.expected_eui;
    radar.excess_MWh_per_year = radar.excess_eui .* radar.floor_area * kBtuToMWh;

    radar = sortrows(radar, "excess_MWh_per_year", "descend");
    radar = addvars(radar, (1:height(radar))', Before=1, NewVariableNames="rank");

    shortlist = radar(1:min(topN, height(radar)), :);
    writetable(shortlist, outFile);

    % --- Headline numbers for the presentation ----------------------------
    isOver     = radar.excess_eui > 0;
    totalExcessGWh = sum(radar.excess_MWh_per_year(isOver)) / 1000;
    shortlistGWh   = sum(shortlist.excess_MWh_per_year) / 1000;

    fprintf("\nRetrofit Radar (Year_Factor %d, %d buildings)\n", latestYear, height(radar));
    fprintf("  %d buildings (%.0f%%) use at least 50%% more energy than expected\n", ...
        nnz(radar.excess_pct >= 50), 100 * mean(radar.excess_pct >= 50));
    fprintf("  Top %d candidates: %.1f GWh/yr excess (%.0f%% of all excess use)\n", ...
        height(shortlist), shortlistGWh, 100 * shortlistGWh / totalExcessGWh);
    fprintf("  Shortlist written to %s\n", outFile);
end

function mustBeEqualLength(a, b)
    if numel(a) ~= numel(b)
        error("retrofitRadar:lengthMismatch", "expectedEUI must have one entry per row of yTrain.");
    end
end
