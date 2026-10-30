# Retrofit Radar: Predicting Building Energy Consumption with MATLAB

# Predict Building Energy Consumption with MATLAB&reg;

## Team developer handoff

Start here: [Pipeline deep dive](pipeline.md) · [Architecture and function contracts](architecture.md)
· [Resources](docs/RESOURCES.md) · [Execution plan](docs/HACKATHON_PLAN.md)
· [Glassmorphism presentation brief](docs/PRESENTATION.md) · [Implementation status](docs/STATUS.md).

The repository implements ingestion, preprocessing, feature engineering, and
model training/evaluation, and final prediction/export (Step 5).
Step 4 validation is complete (Bag OOF RMSE 42.2018; temporal RMSE 41.5379).
Step 5 runtime verification and the final submission are still pending.

Run `step01_ingest` from this repository in MATLAB to load the supplied data.
The data includes a year-factor shift from training years 1–6 to test year 7;
read the pipeline's year-handling policy before building models.

Run `step02_preprocess` for a cleaning preview. It produces `XTrainClean`,
`XTestClean`, `preprocessor`, `yearMetadata`, and `cleaningReport` without
changing the CSVs. Nonfinite numeric values and nonpositive construction years
are treated as missing; other sentinel rules require dictionary verification.
Numeric columns get missingness flags, including columns complete in training.
All-missing training columns are dropped and logged. Categorical gaps/unseen
labels use the training mode plus an unknown flag. Year_Factor is excluded
instead of assigning test year 7 to an observed year.

**For cross-validation, fit a new preprocessor inside each fold.** Do not train
cross-validated models on the full-training cleaning preview: that would leak
validation statistics. Preprocessing tests: `runtests('tests/testPreprocessor.m')`.

Run `step03_features` to rerun cleaning and add five features: log floor area,
area × heating degree days, area × cooling degree days, total degree days, and
heating's fraction of total degree days (zero when both loads are zero).
Outputs: `XTrainFeatures`, `XTestFeatures`, `trainFeatureReport` and
`testFeatureReport`. With the current dataset, expect 127 model inputs.
Age and wind components remain deferred pending verified source definitions.
These are candidate features, not proven accuracy improvements. Feature tests:
`runtests('tests/testEngineerFeatures.m')`.

Run `step04_train_evaluate` to compare Mean, Tree, Bag (200 trees) and LSBoost
(300 trees). It fits cleaning separately in each of five shared folds and checks
training years 1–5 against year 6. Progress prints after each model fit; expect
a longer run than earlier steps. New local `artifacts/` folders contain pooled
OOF scores, fold scores, temporal scores and row-aligned validation predictions.
Those folders are ignored by Git. CVModelSeconds covers model fitting/prediction
in random CV, excluding preprocessing and temporal evaluation. All predictions
are clipped to zero or above, a policy that final inference must also apply.
The lowest pooled OOF score is listed first; review temporal performance before
selecting a model. This step does not produce a final model or submission CSV.

Run `step05_predict_submit` to refit the selected 200-tree Bag model on all labels
and export predictions. It does not rerun validation. It creates a fresh folder
under `artifacts/` containing `final_bundle.mat` and `submission.csv`, prints the
exact paths, verifies reloaded bundle predictions, and checks the CSV against
`data/sample_solution.csv`. Bag was selected based on the observed later-year
validation results. This script saves files locally; it does not upload them.

For later inference without retraining: add `src` to the MATLAB path, load the
saved `bundle` from `final_bundle.mat`, and call
`predictBuildingEnergy(bundle,XTest)` using the raw predictor table returned by
`loadBuildingData`, not the already cleaned/engineered preview.

This repository contains code and instructions enable you to develop an algorithm that can predict how much energy a building will consume based on building characteristics, weather data for it's location, and more. Work like this can help determine which buildings are using and maybe wasting the most energy, which could be great candidates for retrofitting.
**Team MatrixNotFound** · Learn to Hack: MATLAB Edition 2026

We predict a building's **site energy use intensity** (`site_eui`) from its type, size, age and local climate using the WiDS Datathon 2022 data. Then we use those predictions to find the buildings that use the most energy beyond what similar buildings use. Those are the buildings an organisation should audit and retrofit first.

![Retrofit Radar](figures/5_retrofit_radar.png)

## Results

Leave-one-year-out cross-validation (LOYO): hold out one whole year, train on the other five, repeat for all six years. This mirrors the test set, which is a single year never seen in training.

{{RESULTS_TABLE}}

**Selected model:** {{BEST_MODEL}}, refit on all 75,757 training rows to predict the 9,705 test buildings (`submission.csv`).

**Why not random k-fold?** For the baseline tree, random 5-fold CV reports RMSE {{KFOLD}} against {{LOYO_TREE}} under LOYO. Random folds mix years, and the same building appears in several years, so they flatter the model.

## How it works

1. **Load** (`src/loadData.m`): typed `readtable`, categorical predictors, and the same category levels for train and test.
2. **Clean** (`src/preprocessData.m`):
   - `year_built = 0` is treated as missing.
   - `energy_star_rating` is filled by facility-type median, and other gaps by the overall median.
   - `<name>_missing` flags record where data was absent.
   - All statistics come from training rows only.
3. **Engineer** (`src/engineerFeatures.m`): building age, floor area × heating and cooling degree days (seasonal thermal load), and Energy Star × floor area.
4. **Select** (`src/trainModels.m`): a regression tree baseline and three LSBoost iterations, scored by LOYO. Preprocessing is refit inside every fold.
5. **Submit** (`src/writeSubmission.m`): finite, non-negative predictions, checked as exactly 9,705 × 2 `id,site_eui`, with ids matched to the sample solution.
6. **Act** (`src/retrofitRadar.m`): actual vs expected EUI for the latest year, ranked by excess MWh per year, saved to `results/retrofit_shortlist.csv`.

Details and diagrams: [ARCHITECTURE.md](ARCHITECTURE.md). Integrity, security and responsible-use rules: [GUARDRAILS.md](GUARDRAILS.md).

## Run it

Requires MATLAB (R2024b or newer) and the **Statistics and Machine Learning Toolbox**.

```matlab
main            % full pipeline, ~35 min (mostly LSBoost cross-validation)
ProjectReport   % walkthrough of the saved results, seconds
```

`main.m` writes `submission.csv`, `results/retrofit_shortlist.csv`, `figures/*.png` and `results/pipelineResults.mat`. The seed is fixed with `rng(42)`.

## Repository

| Path | Contents |
| --- | --- |
| `main.m` | Entry point |
| `src/` | Pipeline functions (one responsibility each) |
| `ProjectReport.m` / `ProjectReport.html` | Live-script report (our written demo) |
| `figures/` | Presentation figures |
| `results/retrofit_shortlist.csv` | Top 50 retrofit candidates |
| `submission.csv` | Test-set predictions |
| `data/` | WiDS Datathon 2022 train/test/sample files |
| `BuildingRegressionModels.m`, PDFs | MathWorks starter material |

## Credits

- Data: [WiDS Datathon 2022](https://www.kaggle.com/competitions/widsdatathon2022), provided by the hackathon organisers.
- Starter material: Copyright 2025-2026 The MathWorks, Inc. (see `license.txt`).
- Team: Rohit, Matt, Shuan.
