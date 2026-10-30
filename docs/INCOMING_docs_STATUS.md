# Implementation status

Updated 30 October 2026 after the full verified run of `main.m` (MATLAB R2026b, Statistics and Machine Learning Toolbox).

| Component | Status |
| --- | --- |
| Ingestion (`src/loadData.m`) | Done: 75,757 train / 9,705 test rows, 62 predictors, categories aligned |
| Year handling | Done: `Year_Factor` is numeric; test year 7 is handled without becoming undefined |
| Preprocessing (`src/preprocessData.m`) | Done: train-only imputation, missingness flags, `year_built = 0` treated as missing |
| Feature engineering (`src/engineerFeatures.m`) | Done: building age, floor area × HDD/CDD, Energy Star × floor area |
| Validation | Done: leave-one-year-out CV with preprocessing inside each fold; random 5-fold shown for contrast |
| Model iteration (`src/trainModels.m`) | Done: tree 61.02 → LSBoost v1 41.06 → v2 41.85 → **v3 40.12** (LOYO RMSE) |
| Submission | Done: `submission.csv`, 9,705 × 2, finite and non-negative, ids match `sample_solution.csv` |
| Retrofit Radar (`src/retrofitRadar.m`) | Done: `results/retrofit_shortlist.csv` |
| Figures (`src/makeFigures.m`) | Done: `figures/1-5_*.png` |
| Report (`ProjectReport.m`) | Done: exported to `ProjectReport.html` |
| Presentation | In progress (Shuan): see [PRESENTATION.md](PRESENTATION.md) and use the figures in `figures/` |
| Devpost / public repo | In progress (Rohit): see [../DEVPOST_DRAFT.md](../DEVPOST_DRAFT.md) |

Run `main` from the repository root to reproduce everything (~25-35 min).
