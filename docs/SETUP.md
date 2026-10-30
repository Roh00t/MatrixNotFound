# Setup and reproducibility

## Prerequisites

- MATLAB R2026b
- The **Statistics and Machine Learning Toolbox** (required for the regression models and validation)
- The repository's training and test data in `data/train.csv` and `data/test.csv`

## Run the pipeline

1. Open the repository root in MATLAB.
2. Confirm that `data/train.csv` and `data/test.csv` are present.
3. Run `main.m` from the repository root.

Running `main.m` executes the full pipeline end to end: it loads the data, prepares predictors, trains and validates the candidate models, selects the best model, and generates `submission.csv` and figures.

## Outputs

- `results/submission.csv`: test-set predictions in the competition format (9,705 rows, `id,site_eui`).
- `results/retrofit_shortlist.csv`: the top 50 Retrofit Radar candidates.
- `figures/*.png`: five presentation figures (RMSE by year, validation gap, predicted vs actual, feature importance, Retrofit Radar).
- `ProjectReport.html`: the exported live-script report.
- `dashboard/data.js`: data for `dashboard/index.html`. Open that page in a browser while `main` runs to watch progress; it refreshes itself until the run completes.
- `figures/6-9_*.png`: four heatmaps (feature correlation, prediction error, excess EUI by state × facility type, residuals by year × state).
- `results/pipelineResults.mat`: the compact final model, CV results and out-of-fold predictions (gitignored).

The full run takes about 25-35 minutes. To review results without retraining, run `ProjectReport` after `main` has run once.

Review the command-window output for validation metrics and any completion messages. Do not edit the source CSV files when preparing a run.

