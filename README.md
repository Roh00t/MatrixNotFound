# Retrofit Radar — Team MatrixNotFound

MATLAB regression pipeline for WiDS Datathon 2022 building energy intensity
(`site_eui`). Team: Rohit, Matt, Shuan.

## Completed results

The step-by-step pipeline ran successfully in MATLAB R2026b with Statistics
and Machine Learning Toolbox. It trained on 75,757 labeled buildings and
exported predictions for 9,705 test buildings. Final fitting and export took
262.6 seconds in the recorded run.

| Model | Five-fold OOF RMSE | Later-year RMSE |
| --- | ---: | ---: |
| Mean | 58.2554 | 57.2064 |
| Tree | 45.2569 | 44.8910 |
| Bag (selected) | 42.2018 | 41.5379 |
| LSBoost | 41.8071 | 45.0487 |

Lower RMSE is better. OOF means every training row was predicted by a model
that did not learn from its target. The temporal check fits years 1–5 and
validates on year factor 6; test data is entirely year factor 7. Bagging was
selected for its stronger temporal result. These are validation scores, not
accuracy measured on the unlabeled test data. The temporal score informed
selection and is not an untouched final-test estimate.

## Ready-to-use files

- [Final submission](release/submission.csv): exactly `id,site_eui`, 9,705 rows.
- [Model comparison](release/model_comparison.csv): full-precision measured scores.
- [Manifest](release/manifest.csv): SHA-256 hashes, sizes and artifact paths.
- [Release instructions](release/README.md): local model location and demo commands.
- [Results narrative](docs/RESULTS.md): evidence and limitations for the presentation.

The saved model remains under local `artifacts/`; it is about 135 MB and is
excluded from Git. Reproduce it with Step 5 or distribute it separately when
needed. No competition upload or Devpost submission has been performed here.

## Run the verified workflow

Open MATLAB in this repository folder. Run saved scripts by name:

```matlab
step01_ingest            % load and inspect data
step02_preprocess        % preview fitted cleaning
step03_features          % preview five engineered features
step04_train_evaluate    % five-fold comparison and temporal check
step05_predict_submit    % refit Bag and export; does not rerun CV
```

Each later step loads what it needs; earlier workspace variables are not required.
Step 4 took approximately 13 minutes for random-fold model fits in the recorded
run, plus cleaning and temporal validation. Runtime varies by machine. Step 5
prints the precise new folder containing `submission.csv` and `final_bundle.mat`.
Run `results = runtests('tests'); assertSuccess(results)` for function tests;
these tests have not yet been verified in the team's MATLAB session.

## How the evaluated pipeline works

Training-only facility medians fill energy ratings, with an overall fallback;
numeric medians fill other missing values. Missing/unknown flags preserve absence.
Nonpositive construction years are treated as missing. Cleaning is fitted
separately in every validation split. The unseen categorical Year_Factor is
excluded from model inputs; raw year codes remain available for temporal splits.

Five extra features represent log area, area × heating/cooling degree days,
total degree days, and the heating fraction. Native categorical predictors and
200 bagged trees form the final model. Outputs are clipped to nonnegative values,
as during validation. Model serialization and CSV round-trip checks passed in
the completed Step 5 run; the packaged CSV was independently checked again.

Unverified calendar-year mapping and wind conventions are not assumed in this
workflow. Features are hypotheses: their separate accuracy contribution was not
measured through ablations. Predictions support further investigation, not
causal claims or proven retrofit savings.

## Other team work and references

`main.m`, `ProjectReport.m` and related functions are a separate teammate workflow.
They are preserved, but their LOYO scores and retrofit outputs were not validated
by the completed step-by-step run above. Numeric-year inputs to engineerFeatures
use the preserved engineerLegacyFeatures implementation; cleaned step-pipeline
inputs use the five evaluated features. The former README draft is retained in
[docs/ALTERNATE_README_DRAFT.md](docs/ALTERNATE_README_DRAFT.md).

Developer references: [Pipeline](pipeline.md), [Step architecture](docs/STEP_ARCHITECTURE.md),
[Resources](docs/RESOURCES.md), [Presentation brief](docs/PRESENTATION.md),
[Hackathon plan](docs/HACKATHON_PLAN.md), [Status](docs/STATUS.md).
Starter: `BuildingRegressionModels.m`; dataset: WiDS Datathon 2022 supplied by
organizers. Retain `LICENSE` and `license.txt` and verify dataset redistribution
conditions. Model-estimated high intensity is not evidence of energy waste.
