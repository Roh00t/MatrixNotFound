%[text] # Retrofit Radar: Predicting Building Energy Use with MATLAB
%[text] **Team MatrixNotFound** · Learn to Hack: MATLAB Edition 2026
%[text] **Project pages:** [Home](index.html) · [Results dashboard](dashboard/index.html) (interactive charts that update while `main.m` runs) · [3D simulator](dashboard/simulator.html) (click a building and the model runs in your browser) · Written report (this page)
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
%[text] The journey from baseline to final model: boosting removed a third of the error, shrinkage (v2) did not help, and feature selection (v3) gave the best result.
showFigure(fullfile(figuresDir, "11_model_journey.png"));
%[text] The full leave-one-year-out grid: every model against every held-out year. Year 1 is the hardest for every model, and it has by far the fewest buildings (2,117). v3 has the lightest cells in 5 of 6 years.
showFigure(fullfile(figuresDir, "10_iteration_heatmap.png"));
%%
%[text] ## 5. How accurate is it?
%[text] Out-of-fold predictions come from models that never saw the year being predicted, so this plot is an honest picture of accuracy on new data. The model tracks typical buildings well; the largest errors are the rare extreme consumers, which are exactly the buildings worth investigating.
fprintf("Out-of-fold RMSE of the selected model: %.2f\n", ...
    computeRMSE(yTrain, cvReport.outOfFoldPredictions));
%[text] RMSE is one view of accuracy. The full set, all computed on out-of-fold predictions:
metrics = readtable(fullfile(projectRoot, "results", "extended_metrics.csv"));
disp(metrics)
%[text] - **MAE ≈ 21 kBtu/ft²/yr:** the typical prediction misses by about 21, and half of all predictions miss by less than about 13 (median absolute error), against a median building EUI of about 75.
%[text] - **R² ≈ 0.53:** the model explains about half of the variation in energy intensity across buildings it has never seen, using only type, size, age, rating and climate. The rest reflects things the data cannot see, such as occupancy, equipment and operating hours.
%[text] - **RMSE (40) is about twice MAE (21)** because squared error is dominated by a small number of extreme consumers. Those are exactly the buildings Retrofit Radar is designed to surface.
%[text] The residual diagnostics confirm this: errors are centred close to zero for typical buildings, with a long tail of buildings that use far more than predicted.
diagnosticsDir = fullfile(projectRoot, "results", "loyo_diagnostics");
if isfile(fullfile(diagnosticsDir, "residual_diagnostics.png"))
    showFigure(fullfile(diagnosticsDir, "residual_diagnostics.png"));
end
showFigure(fullfile(figuresDir, "3_predicted_vs_actual.png"));
%[text] Facility type and Energy Star rating dominate, and our engineered features (efficiency × floor area, building age, floor area × degree days) are among the strongest predictors.
showFigure(fullfile(figuresDir, "4_feature_importance.png"));
%%
%[text] ## 6. Diagnostics in matrix form
%[text] **Prediction error heatmap.** A regression model has no confusion matrix, so this is the closest equivalent: each cell counts buildings by actual EUI (x) and predicted EUI (y). Mass on the diagonal means accurate predictions. The bright core sits on the line for typical buildings (50-120 kBtu/ft²); the cells far below the line at high actual EUI are the extreme consumers the model does not expect. Retrofit Radar is built around exactly those cases.
showFigure(fullfile(figuresDir, "7_prediction_heatmap.png"));
%[text] **Feature correlation matrix.** Energy Star rating is the strongest single linear signal (−0.37 with `site_eui`). The floor-area interactions are strongly correlated with floor area itself (0.92-0.97), which is why tree models, unlike linear ones, are a good fit: they use whichever split is most informative and are not destabilised by correlated inputs. Linear correlation also understates the engineered features, which rank highly in the non-linear model's importance.
showFigure(fullfile(figuresDir, "6_feature_correlation.png"));
%[text] **Residuals by year and state.** Each cell is the mean error for a state in a year, predicted by a model that never saw that year. The bias shifts from year to year (for example, State 10 swings from +15.7 in year 3 to −14.7 in year 5). That year-to-year drift is exactly why random cross-validation, which mixes years, is optimistic, and why we validate one held-out year at a time.
showFigure(fullfile(figuresDir, "9_residual_year_state.png"));
%[text] **Test-set correlation matrix (30 × 30).** The same view for the 9,705 test buildings, using our *predicted* `site_eui` (the test set has no measured values) and the 29 numeric features most correlated with it. Energy Star rating has the strongest link (−0.54): better-rated buildings are predicted to use less energy, consistent with it being the model's second most important predictor. The climate variables form two tight blocks: cold-winter measures correlate positively with predicted use, and mild-winter minimum temperatures negatively. Inside each block, features correlate at 0.9 or more with each other, which is why dropping the 36 monthly temperature columns (v3) lost no information. The wind correlations rest on only the ~12% of test rows that have wind data.
showFigure(fullfile(figuresDir, "12_test_correlation_30x30.png"));
%%
%[text] ## 7. Retrofit Radar: from prediction to action
%[text] For each building in the most recent year we compare its **actual** EUI with the **expected** EUI from the out-of-fold model, which is what similar buildings in a similar climate use. Multiplying the excess by floor area gives the excess energy in MWh per year, and ranking by it puts the biggest savings opportunities first.
shortlist = readtable(fullfile(projectRoot, "results", "retrofit_shortlist.csv"));
disp(shortlist(1:10, ["rank", "facility_type", "State_Factor", "floor_area", ...
    "actual_eui", "expected_eui", "excess_pct", "excess_MWh_per_year"]))
showFigure(fullfile(figuresDir, "5_retrofit_radar.png"));
%[text] **Where to send auditors.** The heatmap shows the median excess EUI for each state and facility type. We use the median rather than the mean so that one extreme building cannot colour a whole cell. Most cells are blue, because the typical building uses a little less than predicted: the excess is concentrated in a minority of buildings. Red cells mark combinations where even the typical building runs above expectation, for example retail in State 2, lodging and commercial buildings in State 4, and warehouses in State 1. These are the best targets for a programme-level audit campaign, while the shortlist above targets individual buildings.
showFigure(fullfile(figuresDir, "8_radar_state_facility.png"));
%[text] The radar flags buildings for inspection rather than delivering a verdict: a hospital may legitimately run hot, and the anonymised data cannot tell us why a building is high. The most extreme cases (several times the expected EUI) may also be metering or data-entry errors, which are worth catching too. Either way, it tells an energy manager where to look first.
%%
%[text] ## 8. Local impact: NTU campus (what-if)
%[text] What would our model say about two NTU landmarks, The Hive (completed 2015) and The Arc (2018)? Each is described as a university building and run through exactly the same preprocessing and final model as the test set.
%[text] This is an illustration, not a measurement. The training data covers anonymised US states, so Singapore's climate is not in it. We use the median weather of the hottest training state, among states with at least 100 buildings, as the closest analogue. Floor areas are rough estimates, and Energy Star ratings are unknown, so they are filled the same way as for any other building.
ntu = readtable(fullfile(projectRoot, "results", "ntu_landmarks.csv"), TextType="string");
disp(ntu(:, ["name", "year_built", "floor_area", "predicted_eui", "predicted_MWh_per_year", "climate_state"]))
showFigure(fullfile(figuresDir, "ntu_landmarks.png"));
%[text] Both come out above the median measured US university building. In a hot climate, cooling load pushes intensity up, and new buildings get no age discount in the model. The practical use is the same as Retrofit Radar: once a building's real metered EUI is known, comparing it with this expected value shows whether it is performing better or worse than its peers.
%%
%[text] ## 9. Summary
%[text] - **Data:** leakage-safe imputation fitted inside every fold, missingness flags and physically meaningful features.
%[text] - **Validation:** leave-one-year-out cross-validation that mirrors the unseen test year.
%[text] - **Model:** gradient-boosted trees, improved over a single tree and iterated with shrinkage and feature selection (LOYO RMSE 61.0 → 40.1; MAE 21.0; R² 0.53).
%[text] - **Impact:** a ranked shortlist of the buildings that use the most energy beyond what their peers use, plus a state × facility-type map for audit campaigns.
%[text] - **Explore:** open `dashboard/index.html` for the interactive results page.
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
