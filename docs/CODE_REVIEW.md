# Rubric-focused code revision

## Changes

The step pipeline's model settings now come from buildingConfig.m in both
validation and final refitting. The seed, 200 bagging trees, 300 boosting cycles,
five folds and clipping policy are unchanged.

The alternate pipeline calls engineerLegacyFeatures explicitly. engineerFeatures
now requires cleaned step-pipeline inputs instead of silently selecting different
feature logic based on the presence of numeric year codes. A mistaken raw input
produces an actionable error. Existing saved step bundles remain supported.

Cross-validation validates fold count, seed, target values and output directory.
Inference checks the bundle schema before using the model. Newly saved bundles
identify the workflow and feature version.

testPipelineSmoke uses 60 synthetic rows and three-tree ensembles to test the
complete validation/refit/reload/export path quickly. It checks the per-fold mean
baseline against the actual training-only mean, complete OOF coverage, latest-year
row alignment, saved-model reproducibility, and submission IDs. Existing cleaning,
feature, metric and export tests remain in place.

demo_submission reads the packaged metrics and validates the packaged submission
without fitting any model. This is useful for a short, reliable judging demo.

## What this establishes

These are correctness, reproducibility and readability changes. They do not
establish a better RMSE. Original release predictions, model and metric CSVs were
not regenerated or overwritten. Run the test suite in the licensed MATLAB session
before relying on the revised source in a live demonstration:

```matlab
testResults = runtests('tests');
assertSuccess(testResults);
demo_submission
```

## Remaining modeling limits

The step pipeline excludes year codes as features and uses them for temporal
validation. Its latest-year score informed model selection and is not an untouched
test score. Five engineered features have not been separately ablated. Wind/fog
imputation is heavily used in test data and deserves a keep/drop comparison.

The alternate workflow uses a proposed calendar-year offset in its own feature
function. Its source comments do not replace external dictionary verification.
LOYO validation holds out each year while training on all other years, including
later years for early folds; it is not purely forward temporal validation.
Do not interchange its metrics/model with the step pipeline's artifacts. Historical
reports are preserved; scientific claims in those reports should be reviewed
against the actual experiment that produced them.

Do not claim repeated-building leakage without a verified building identity key,
or treat a reduction in RMSE as a reduction in energy consumption. No new model
optimization, causal analysis, or external leaderboard scoring was performed here.
