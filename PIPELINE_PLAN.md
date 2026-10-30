# Building energy regression

Step 1 is implemented. The repository contains data/train.csv and data/test.csv.
BuildingRegressionModels.m was reviewed as the starter baseline: import tables,
inspect missingness, separate the response, validate, and train models. This
implementation preserves categorical predictors and defers imputation to folds.
No trained models, accuracy scores, or submission predictions are claimed.

## Run Step 1

Put `train.csv` and `test.csv` in a `data` folder beside `step01_ingest.m`.
Open and run that script in MATLAB, or set `dataDir` to your dataset folder
before running it. It produces `XTrain`, `yTrain`, `XTest`, `trainID`, `testID`,
and `ingestionReport` in the workspace. No source data is modified.

The loader uses `readtable`, explicitly casts the four requested categorical
columns, aligns predictor order, removes IDs from predictors, checks targets
and IDs, and reports missing values. Category levels come only from training
data; unseen test labels become undefined for later handling. Imputation is
deliberately deferred to prevent fitting statistics on validation rows.

## Architecture plan (remaining files are not implemented)

| File | Responsibility |
| --- | --- |
| `step01_ingest.m` | Entry script for data loading (implemented) |
| `src/loadBuildingData.m` | Schema validation, category casting, target/ID separation (implemented) |
| `run_pipeline.m` | Seed, configuration, orchestration, artifact saving |
| `src/fitPreprocessor.m` | Learn facility medians for energy ratings and overall year-built median; missing indicators |
| `src/applyPreprocessor.m` | Apply saved statistics with `fillmissing`, global fallback for sparse/unseen groups |
| `src/engineerFeatures.m` | Building age, floor-area/degree-day interactions, optional wind components |
| `src/crossValidateModels.m` | Shared 5-fold `cvpartition`; fit preprocessing inside each training fold; compare tree, LSBoost, Bag |
| `src/rmse.m` | Finite-value-checked RMSE on the original target scale |
| `src/trainFinalModel.m` | Refit selected settings on all training rows; save preprocessing and model |
| `src/writeSubmission.m` | Validate finite predictions and ID order; write exactly `id,site_eui` |

Use `fitrtree` for the baseline and `fitrensemble` with `LSBoost` or `Bag`
(the regression boosting method is `LSBoost`, not `Boost`). Tune against the
same folds and report pooled out-of-fold RMSE. Statistics and Machine Learning
Toolbox will be required for modeling.

Before implementing age, verify the data dictionary's mapping of Year_Factor
to calendar year; subtracting year_built directly from an encoded factor is
invalid. Verify wind-direction units and sentinel values before computing
components. Random folds satisfy the requested benchmark; also consider a
year holdout if the verified data chronology warrants it.

## Team handoff

- Rohit: pipeline implementation, reproducibility, and readable documentation.
- Matt: verify the dictionary, missingness/sentinels, features, and validation results.
- Shuan: prepare a demo under five minutes explaining the problem, evidence, and impact.
- Fourth member (not named in the request): integration, clean-run verification,
  submission checks, and public repository/Devpost packaging.

The attached slides specify a 4:00 PM deadline on 30 October 2026, a public
code link, and one Devpost submission per team. These are supplied reference
requirements; this Step 1 implementation does not publish or submit anything.

