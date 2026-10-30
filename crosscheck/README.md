# Independent cross-check pipeline

A second, separately built pipeline used to cross-check the official result
(`../main.m`, LSBoost v3, leave-one-year-out RMSE 40.12). On the shared year-6
holdout the two agree closely: 41.31 (official) vs 41.54 (this pipeline's Bag model).

Run any script from the repository root in MATLAB; each one locates the root itself:

```matlab
run crosscheck/run_project_tests.m        % unit tests + packaged-results demo
run crosscheck/step01_ingest.m            % load and inspect data
run crosscheck/step02_preprocess.m        % preview fitted cleaning
run crosscheck/step03_features.m          % preview engineered features
run crosscheck/step04_train_evaluate.m    % five-fold comparison + temporal check (~13 min)
run crosscheck/step05_predict_submit.m    % refit Bag and export
run crosscheck/step06_metrics.m           % metrics from saved predictions
run crosscheck/step07_diagnostics.m       % diagnostics from saved predictions
run crosscheck/step08_compare_three_models.m  % controlled tree vs. LSBoost comparison
run crosscheck/demo_submission.m          % check the packaged cross-check submission
```

Shared helper functions are in `../src/`, tests in `../tests/`, and packaged outputs in
`../release/`. Steps 06–07 read a local `artifacts/` folder from a previous step 04/05 run.
See [`../docs/START_HERE.md`](../docs/START_HERE.md) and
[`../docs/STEP_ARCHITECTURE.md`](../docs/STEP_ARCHITECTURE.md).
