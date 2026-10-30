%[text] # Retrofit Radar: Predicting Building Energy Use with MATLAB
%[text] **Team MatrixNotFound** · Learn to Hack: MATLAB Edition 2026
%[text] This report walks through our solution using the results saved by `main.m`. It does not retrain anything, so it runs in seconds. Run `main.m` first to create `results/pipelineResults.mat`, `results/retrofit_shortlist.csv` and the figures in `figures/`.
%%
%[text] ## 1. The problem
%[text] Buildings are a major source of energy use and carbon emissions. If we can predict how much energy a building *should* use from its type, size, age and local climate, then buildings that use far more than that are the first candidates for an energy audit or a retrofit.
%[text] We predict **site energy use intensity** (`site_eui`, kBtu per square foot per year) for 9,705 buildings from the WiDS Datathon 2022 data, training on 75,757 building-years.
projectRoot = fileparts(which("ProjectReport"));
addpath(fullfile(projectRoot, "src"));
load(fullfile(projectRoot, "results", "pipelineResults.mat"), "finalModel", "cvReport", "yTrain");
figuresDir = fullfile(projectRoot, "figures");
%%
%[text] ## 2. What the data told us
%[text] Three findings shaped every later decision:
%[text] - **The test set is one unseen year.** Every test row is `Year_Factor` 7; training covers years 1 to 6. As a category, year 7 would be meaningless to a model, so we treat the year as a number.
%[text] - **The test set has no State\_6 buildings,** although State\_6 is 67% of the training data. The test distribution is shifted.
%[text] - **Key fields are missing.** `energy_star_rating` is missing for 35% of training rows, and wind and fog readings are missing for 88-94% of test rows.
%[text] Our responses:
%[text] - `energy_star_rating` is filled with the median of the building's facility type; `year_built = 0` is treated as missing.
%[text] - Every fill value is learned from training rows only, and a `<name>_missing` flag records where data was absent, because missingness itself is informative.
%[text] - We skipped wind-vector features: with 88% of test values missing they would mostly encode filled-in medians.
%[text] - New features with a physical meaning: building age, floor area × heating degree days, floor area × cooling degree days (seasonal heating and cooling load) and Energy Star rating × floor area (the scale of efficiency).
%%
%[text] ## 3. Validating the way the test set is built
%[text] Random k-fold cross-validation mixes years, and the same building appears in several years, so a model can "recognise" buildings it has already seen. We instead use **leave-one-year-out (LOYO)** cross-validation: hold out one entire year, train on the other five, repeat for all six years. Imputation and feature engineering are refit inside every training fold, so held-out rows never leak into preprocessing.
%[text] The baseline tree shows why this matters: random folds report a noticeably lower error than holding out a year.
disp(cvReport.validationGap)
showFigure(fullfile(figuresDir, "2_validation_gap.png"));
%%
%[text] ## 4. Iterating on the model
%[text] We compared four models under LOYO, keeping every attempt in the table:
%[text] 1. **Regression tree** (`fitrtree`): a single interpretable baseline.
%[text] 2. **LSBoost v1** (`fitrensemble`, 300 trees, learning rate 0.1): gradient-boosted trees handle mixed numeric and categorical predictors without scaling and capture non-linear interactions such as size × climate × building type.
%[text] 3. **LSBoost v2 (shrinkage)**: learning rate 0.05, 400 trees, minimum leaf of 50 buildings and histogram binning, to reduce over-fitting to year-specific patterns.
%[text] 4. **LSBoost v3 (feature selection)**: v1 without the 36 monthly temperature columns. Those values are identical for every building in a state-year, so trees can memorise them as a fingerprint that never matches an unseen year.
%[text] The model with the lowest LOYO RMSE is refit on all training data and used for the submission.
disp(cvReport.results)
disp(cvReport.perYearRMSE)
fprintf("Selected model: %s\n", cvReport.bestModelName);
showFigure(fullfile(figuresDir, "1_rmse_by_year.png"));
%%
%[text] ## 5. How accurate is it?
%[text] Out-of-fold predictions come from models that never saw the year being predicted, so this plot is an honest picture of accuracy on new data. The model tracks typical buildings well; the largest errors are the rare extreme consumers, which are exactly the buildings worth investigating.
fprintf("Out-of-fold RMSE of the selected model: %.2f\n", ...
    computeRMSE(yTrain, cvReport.outOfFoldPredictions));
showFigure(fullfile(figuresDir, "3_predicted_vs_actual.png"));
%[text] Facility type and Energy Star rating dominate, and our engineered features (efficiency × floor area, building age, floor area × degree days) are among the strongest predictors.
showFigure(fullfile(figuresDir, "4_feature_importance.png"));
%%
%[text] ## 6. Retrofit Radar: from prediction to action
%[text] For each building in the most recent year we compare its **actual** EUI with the **expected** EUI from the out-of-fold model, which is what similar buildings in a similar climate use. Multiplying the excess by floor area gives the excess energy in MWh per year, and ranking by it puts the biggest savings opportunities first.
shortlist = readtable(fullfile(projectRoot, "results", "retrofit_shortlist.csv"));
disp(shortlist(1:10, ["rank", "facility_type", "State_Factor", "floor_area", ...
    "actual_eui", "expected_eui", "excess_pct", "excess_MWh_per_year"]))
showFigure(fullfile(figuresDir, "5_retrofit_radar.png"));
%[text] The radar flags buildings for inspection rather than delivering a verdict: a hospital may legitimately run hot, and the anonymised data cannot tell us why a building is high. The most extreme cases (several times the expected EUI) may also be metering or data-entry errors, which are worth catching too. Either way, it tells an energy manager where to look first.
%%
%[text] ## 7. Summary
%[text] - **Data:** leakage-safe imputation fitted inside every fold, missingness flags and physically meaningful features.
%[text] - **Validation:** leave-one-year-out cross-validation that mirrors the unseen test year.
%[text] - **Model:** gradient-boosted trees, improved over a single tree and iterated with shrinkage and feature selection.
%[text] - **Impact:** a ranked shortlist of the buildings that use the most energy beyond what their peers use.
%%
function showFigure(file)
%SHOWFIGURE Display a saved PNG figure inline in the report.
    figure(Theme="light");
    image(imread(file));
    axis image off
end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
