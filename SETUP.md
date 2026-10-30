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

- `submission.csv` — test-set predictions in the competition submission format.
- Generated figures — model or feature-analysis visualizations produced by the pipeline.

Review the command-window output for validation metrics and any completion messages. Do not edit the source CSV files when preparing a run.

