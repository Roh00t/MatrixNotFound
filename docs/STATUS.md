# Implementation status

Updated 30 October 2026 after the verified runs (MATLAB R2026b, Statistics and Machine Learning Toolbox).

## Official pipeline (`main.m`)

| Component | Status |
| --- | --- |
| Ingestion (`src/loadData.m`) | Done: 75,757 train / 9,705 test rows, 62 predictors, categories aligned |
| Preprocessing and features | Done: train-only imputation inside every fold, missingness flags, four engineered features |
| Validation | Done: leave-one-year-out CV (6 folds); random 5-fold shown for contrast |
| Model iteration | Done: tree 61.02 → LSBoost v1 41.06 → v2 41.85 → **v3 40.12** (LOYO RMSE) |
| Submission | Done: `results/submission.csv`, 9,705 × 2, finite and non-negative, ids match the sample |
| Reproducibility | Done: clean-room rerun reproduced `results/submission.csv` byte for byte |
| Retrofit Radar, figures, heatmaps | Done: `results/retrofit_shortlist.csv`, `figures/1-12_*.png` (12 = 30 × 30 test-set correlation) |
| Extended accuracy metrics | Done: MAE 21.0, RMSE 40.1, R² 0.53 (`results/extended_metrics.csv`) |
| NTU what-if | Done: `figures/ntu_landmarks.png`, `results/ntu_landmarks.csv` (illustrative inputs) |
| Dashboard | Done: `dashboard/index.html`, updated live by `main.m` |
| Report | Done: `ProjectReport.html` |

## Independent cross-check pipeline (`step01`–`step05`)

| Component | Status |
| --- | --- |
| Steps 1–5 | Passed in the team's MATLAB session; Bag selected (random 5-fold OOF 42.20, year-6 RMSE 41.54) |
| Unit tests (`tests/`) | Earlier seven tests passed in MATLAB; more metric/diagnostic/comparison tests have since been added. Use `run crosscheck/run_project_tests.m` for the current suite. |
| Outputs | `release/model_comparison.csv`, `release/crosscheck_bag_submission.csv`, `release/manifest.csv` |
| Saved 135 MB model | Local only (`artifacts/`, gitignored); rerun `crosscheck/step05_predict_submit.m` to regenerate |

## Controlled three-model comparison

Completed in the user's MATLAB session. Model 1 (all factors/tree) has OOF RMSE
45.2147 and latest-year RMSE 44.9802; Model 2 (selected/tree) 44.9971 and
44.7641; Model 3 (selected/LSBoost) 41.1704 and 42.9221. The experiment exported
metrics, actual-versus-predicted plots, residual plots and UI JSON for all models.
Stable shareable copies are in release/three_model_experiment/. No existing final
model or submission was replaced by that experiment.

## Repository organization

See START_HERE.md for commands and experiment ownership. The large model bundles
and raw checkpoints stay in ignored artifacts/. Recovery drafts are archived under
docs/archive/; the fixed diagnostics troubleshooting script lives under tools/debug/.
The dashboard and simulator were not reorganized. Cleanup did not retrain models.

## Remaining delivery work

- Presentation deck and demo recording (Shuan): see [PRESENTATION.md](PRESENTATION.md)
- Devpost entry and public repository link (Rohit): see [DEVPOST_DRAFT.md](DEVPOST_DRAFT.md)
