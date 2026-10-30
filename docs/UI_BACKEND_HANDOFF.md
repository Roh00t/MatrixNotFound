# Evaluation data for the UI developer

The latest fetched GitHub main is 4ebe612 (merge of the 563d174 updates). It
includes a dashboard, extended metrics and existing actual-versus-predicted PNGs.
This revision adds backend exports; it does not edit the dashboard UI.

Integration repairs: main.m now retains the newer dashboard/heatmap flow while
calling engineerLegacyFeatures explicitly for both prepared tables. The NTU
scenario uses that same explicit feature function. The refreshed upstream README
and status are retained; conflicting step-pipeline drafts are preserved under
docs/merge_recovery. The demo accepts the new crosscheck_bag_submission.csv name.
New diagnostics tests and PNG generation remain pending in the licensed MATLAB
session; existing LOYO figures and scores were inspected, not rerun here.

## Two experiment families must stay distinct

- `results/extended_metrics.csv` belongs to the main.m LOYO workflow. Recorded
  values: MSE 1609.8312, RMSE 40.1227, MAE 21.0376, R2 0.5256, MedianAE 12.5652.
  Its row-level predictions are stored in the local pipelineResults.mat when
  that workflow completes; this file is not present in this checkout, so these
  existing scores have not been independently recomputed in this revision.
- `release/validation_metrics.csv` belongs to the step pipeline. Bag random OOF
  RMSE is 42.2018 and latest-year RMSE is 41.5379. This revision can reproduce
  those metrics from the available saved CSV predictions.

Never combine the main workflow's 40.12 score with the Bag model name or Bag
submission. Label the validation method, model name and row count beside scores.

## Generate without retraining

Run `step07_diagnostics` for the completed step-pipeline run. It checks source
IDs/targets through Step 6, then exports two independent datasets under the run's
`diagnostics` directory: `bag_oof` and `bag_latest_year`.

For an existing main.m saved result, without rerunning training:

```matlab
addpath('src');
saved = load('results/pipelineResults.mat','cvReport','yTrain');
exportValidationDiagnostics(saved.yTrain,saved.cvReport.outOfFoldPredictions, ...
    'results/loyo_diagnostics','Model',string(saved.cvReport.bestModelName), ...
    'Validation','Leave-one-year-out OOF');
```

Future main.m runs export their LOYO diagnostics automatically. The step command
does not modify the UI or overwrite the other workflow's metrics or figures.

## Files and contract

- `metrics.csv`: MAE, MSE, RMSE, R2, MedianAE, P90AE, MeanBias. All use every
  validation row. Lower absolute errors are better. Bias closer to zero is better.
- `validation_summary.json`: SchemaVersion, Model, Validation, N, Metrics,
  MetricRows, ResidualConvention, DisplaySampleRows, DisplaySampleMethod,
  R2Definition, MeasuredTestAccuracy and Points.
- `Points`: objects with SourceRow, Actual, Predicted and Residual. Up to 2,000 evenly
  spaced row indices for DISPLAY only; row indices are not building IDs. Use this
  to render a responsive scatter chart. This sample may miss rare outliers; use
  full CSV predictions for detailed analysis.
- `plot_points.csv`: the same display sample in tabular form.
- `predicted_vs_actual.png`: actual on x, predicted on y, identity line. Full-range
  view alongside a labeled central view that reports excluded point counts.
- `residual_diagnostics.png`: predicted vs residual and residual histogram, both
  using all validation rows.

Residual is predicted minus actual. Negative means underprediction. R2 is
1-SSE/SST, not squared correlation or percentage accuracy; undefined R2 for a
constant actual target serializes as null. Do not turn null into zero.

Use RMSE, MAE and R2 as headline evidence; show MSE, median error, P90 error and
bias as supporting diagnostics. Avoid MAPE as a headline here because small/zero
targets make percentage errors unstable. Do not use classification accuracy,
confusion matrices or adjusted linear-model R2 for these tree ensembles.

## Highest-value next model experiments

1. Remove wind/fog columns and their indicators, compare on identical splits.
2. Ablate engineered feature families rather than deleting by correlation alone.
3. Run chronological forward checks in addition to LOYO (early LOYO folds train
   on later years and are not future-only forecasts).
4. Inspect error by facility/state/year and target quantile; show sample counts.
5. Tune a small number of leaf sizes, tree counts and boosting rates against the
   same splits, preserving an incumbent. Evaluate improvements before replacing
   the release submission. Do not select using training error or unlabeled test.

Metrics and model changes are separate tasks. Adding diagnostics does not improve
the model's measured accuracy. Existing submission files are retained unchanged.
