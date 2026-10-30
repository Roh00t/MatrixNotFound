# Implementation status

Updated 30 October 2026 after the verified runs (MATLAB R2026b, Statistics and Machine Learning Toolbox).

## Official pipeline (`main.m`)

| Component | Status |
| --- | --- |
| Ingestion (`src/loadData.m`) | Done: 75,757 train / 9,705 test rows, 62 predictors, categories aligned |
| Preprocessing and features | Done: train-only imputation inside every fold, missingness flags, four engineered features |
| Validation | Done: leave-one-year-out CV (6 folds); random 5-fold shown for contrast |
| Model iteration | Done: tree 61.02 → LSBoost v1 41.06 → v2 41.85 → **v3 40.12** (LOYO RMSE) |
| Submission | Done: `submission.csv`, 9,705 × 2, finite and non-negative, ids match the sample |
| Reproducibility | Done: clean-room rerun reproduced `submission.csv` byte for byte |
| Retrofit Radar, figures, heatmaps | Done: `results/retrofit_shortlist.csv`, `figures/1-11_*.png` |
| Extended accuracy metrics | Done: MAE 21.0, RMSE 40.1, R² 0.53 (`results/extended_metrics.csv`) |
| NTU what-if | Done: `figures/ntu_landmarks.png`, `results/ntu_landmarks.csv` (illustrative inputs) |
| Dashboard | Done: `dashboard/index.html`, updated live by `main.m` |
| Report | Done: `ProjectReport.html` |

## Independent cross-check pipeline (`step01`–`step05`)

| Component | Status |
| --- | --- |
| Steps 1–5 | Passed in the team's MATLAB session; Bag selected (random 5-fold OOF 42.20, year-6 RMSE 41.54) |
| Unit tests (`tests/`) | 6/6 pass (`runtests('tests')`) |
| Outputs | `release/model_comparison.csv`, `release/crosscheck_bag_submission.csv`, `release/manifest.csv` |
| Saved 135 MB model | Local only (`artifacts/`, gitignored); rerun `step05_predict_submit` to regenerate |

## Remaining (team)

- Presentation deck and demo recording (Shuan): see [PRESENTATION.md](PRESENTATION.md)
- Devpost entry and public repository link (Rohit): see [../DEVPOST_DRAFT.md](../DEVPOST_DRAFT.md)
