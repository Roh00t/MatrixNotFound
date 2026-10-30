function tbl = engineerLegacyFeatures(tbl)
%ENGINEERFEATURES Add physically motivated features to a predictor table.
%
%   tbl = ENGINEERFEATURES(tbl) takes a table returned by preprocessData
%   (no missing values, numeric Year_Factor) and appends:
%
%     building_age             - age in years at the time of measurement,
%                                clipped to [0, 100] so a handful of very
%                                old buildings (some built in the 1600s)
%                                cannot dominate tree splits
%     floor_area_x_hdd         - floor_area * heating_degree_days, a proxy
%                                for total seasonal heating load
%     floor_area_x_cdd         - floor_area * cooling_degree_days, a proxy
%                                for total seasonal cooling load
%     energy_star_x_floor_area - energy_star_rating * floor_area, the scale
%                                of a building's efficiency rating
%
%   The function is row-wise and stateless, so the same call is applied to
%   train and test without any risk of leakage.
%
%   Wind and fog vectors are deliberately NOT synthesised: those columns
%   are 88-94% missing in the test set, so derived features would mostly
%   encode imputed medians. Their <name>_missing flags from preprocessData
%   are kept instead.

    arguments
        tbl table
    end

    % Year_Factor is an anonymised year index. In every year the newest
    % building is exactly 2009 + Year_Factor (2010 for year 1 ... 2016 for
    % year 7), so that offset recovers the calendar year of measurement.
    yearOffset = 2009;
    maxAge     = 100;

    measurementYear   = tbl.Year_Factor + yearOffset;
    tbl.building_age  = min(max(measurementYear - tbl.year_built, 0), maxAge);

    tbl.floor_area_x_hdd = tbl.floor_area .* tbl.heating_degree_days;
    tbl.floor_area_x_cdd = tbl.floor_area .* tbl.cooling_degree_days;

    tbl.energy_star_x_floor_area = tbl.energy_star_rating .* tbl.floor_area;

end
