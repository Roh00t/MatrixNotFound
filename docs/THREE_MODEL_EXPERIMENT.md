# Three-model experiment

The team approved this selected set: floor_area, energy_star_rating, year_built,
heating_degree_days, cooling_degree_days, State_Factor, building_class and
facility_type. It is motivated by the correlation heatmap AND building context;
the heatmap does not measure categorical or nonlinear usefulness. No automatic
correlation threshold is asserted to be optimal.

| Model | Algorithm | Inputs |
| --- | --- | --- |
| Model 1 | Regression tree | All cleaned source predictors and their missingness flags |
| Model 2 | Same regression tree settings | Eight approved factors and only their associated flags |
| Model 3 | LSBoost | Exactly the same input columns as Model 2 |

All excludes target, row ID and categorical Year_Factor. Raw year metadata is
retained for validation. No engineered interaction/age features are added to this
experiment, making the feature reduction easy to explain. Cleaning is learned
from each training split separately; both selected models receive identical
prepared matrices. Nonnegative clipping matches the existing pipeline policy.

Run `step08_compare_three_models`. It creates a unique artifacts folder and
compares the models on five shared random folds and an earlier-years-to-latest-year
holdout. The two trees use MinLeafSize=20 and MaxNumSplits=100. LSBoost uses
300 cycles, learning rate 0.05 and the existing shallow-tree template. Only the
selected boost settings differ between Model 2 and Model 3; the input set stays
fixed. Settings come from buildingConfig and trainCandidate.

Outputs: three_model_metrics.csv with MSE/RMSE/MAE/R2/MedianAE/P90AE/MeanBias,
OOF and temporal prediction CSVs, checkpoints, feature counts and six diagnostics
folders (three models times two evaluation methods). The UI developer can consume
each validation_summary.json independently. Graphs include actual versus predicted
and residual diagnostics. Existing model bundles/submissions remain untouched.

Interpret M1 vs M2 as a feature-set ablation and M2 vs M3 as an estimator
comparison. Feature selection came from an exploratory view of the full dataset;
the CV score is not an unbiased assessment of the entire feature-selection process.
Record that limitation and avoid repeatedly adjusting features to the same held-out
year. An untouched future holdout or nested selection is required for a stronger
generalization estimate. Keep the validated incumbent unless results justify a
replacement. Correlation alone is not a reason to remove a feature.

Runtime and results have not yet been verified for this new experiment. The small
test in testSelectedFactors checks schema equality and complete prediction output
without running the full competition dataset.
