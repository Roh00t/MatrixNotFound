# Building energy regression pipeline

The repository includes an end-to-end MATLAB workflow in `main.m`. It loads
the WiDS building energy CSVs, compares a regression-tree baseline with an
LSBoost ensemble, refits the winner, and writes `submission.csv`.

## Pipeline

| File | Responsibility |
| --- | --- |
| `main.m` | Seed the random generator and run the complete workflow |
| `src/loadData.m` | Read CSVs, separate target and IDs, align predictor columns and categorical levels |
| `src/preprocessData.m` | Convert year to numeric, add missingness indicators, and impute from the training partition |
| `src/engineerFeatures.m` | Add building age and floor-area/degree-day interactions |
| `src/crossValidateModel.m` | Calculate pooled out-of-fold RMSE with optional fold-local preparation |
| `src/trainModels.m` | Compare a regression tree and LSBoost using year holdout and random 5-fold validation |
| `src/writeSubmission.m` | Check prediction values and write `id,site_eui` |

For cross-validation, each fold fits its imputation values on that fold's
training rows and applies them to the held-out rows. The final model is fit
after selection; imputation statistics for the test set are learned from all
training rows only. `Year_Factor` is treated as numeric to support the
test-only year 7. Missingness indicators preserve information about sparse
weather and building fields.

## Run

Use MATLAB with the Statistics and Machine Learning Toolbox. Ensure
`data/train.csv` and `data/test.csv` exist, open the repository root in MATLAB,
and run `main.m`. The script reports both validation RMSE results and creates
`submission.csv` in the repository root.
