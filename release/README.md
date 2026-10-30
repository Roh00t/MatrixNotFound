# Cross-check run package (step pipeline)

These are the outputs of the team's **independent cross-check pipeline**
(`step01`–`step05`, bagged trees). The **official submission is
`../submission.csv`**, produced by `main.m` (LSBoost v3, leave-one-year-out
RMSE 40.12). On the same year-6 holdout, the two pipelines score 41.31
(official) and 41.54 (this Bag model).

`crosscheck_bag_submission.csv` is a byte-for-byte copy from the successful Step 5 run.
`model_comparison.csv` is copied from the successful Step 4 evaluation.
`manifest.csv` records SHA-256 hashes, byte sizes and repository-relative paths.
The model path in the manifest is local, not a public download.

Checks: exactly 9,705 rows, exactly id/site_eui columns, IDs matching both test
and sample submission order, finite nonnegative predictions. Step 5 also checked
that saving/reloading the fitted model reproduces predictions. These checks
verify functionality and format; test labels are unavailable for accuracy scoring.

The local saved model is:
`artifacts/tp6fdff950_4339_476b_a3ac_2b3dcd686e45/final_bundle.mat`.
Keep this file safe. It is about 135 MB and is not included in ordinary Git commits.
Without it, run `step05_predict_submit` to reproduce a new model and submission.

## Demo without retraining

From the repository root in MATLAB:

```matlab
addpath('src');
saved = load(fullfile('artifacts', ...
    'tp6fdff950_4339_476b_a3ac_2b3dcd686e45','final_bundle.mat'),'bundle');
[~,~,XTest,~,testID] = loadBuildingData('data');
yHat = predictBuildingEnergy(saved.bundle,XTest);
disp(table(testID(1:5),yHat(1:5),'VariableNames',{'id','site_eui'}));
```

The local bundle and Statistics and Machine Learning Toolbox must be available.
For a fast presentation, show the existing release CSV and comparison table as
backup instead of waiting for training. No leaderboard or Devpost upload is
performed by these commands. Confirm the organizer's actual submission fields.
