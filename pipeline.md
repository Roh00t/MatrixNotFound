# Building energy prediction: implementation pipeline

Developer specification, 30 October 2026. Start with [architecture.md](docs/STEP_ARCHITECTURE.md)
for module contracts and [docs/RESOURCES.md](docs/RESOURCES.md) for references.
Only ingestion is implemented today; model code below is illustrative design,
not an already executable end-to-end system. No measured model score exists yet.

## 1. Goal and acceptance criteria

Predict `site_eui`, energy consumption per unit of floor area, using building
characteristics and weather. This is regression, not classification. Units and
weather conventions must be checked against the original data dictionary before
being stated in slides. Predictions can help prioritize investigation of high
energy intensity; they do not establish retrofit savings or causal effects.

Deliver a repeatable MATLAB run that produces a validated CSV with exactly
`id,site_eui`, a saved model/preprocessor bundle, evaluation evidence, and a demo
under five minutes. The hackathon brief specifies Devpost and a public code link;
it does not establish that a Kaggle leaderboard entry is mandatory. Confirm the
organizer's exact upload destination. Deadline: 30 October 2026, 4:00 PM,
Asia/Kuala_Lumpur, as supplied in the briefing.

## 2. Verified local data and current status

| Item | Observed locally |
| --- | --- |
| Training rows | 75,757 |
| Test rows | 9,705 |
| Raw predictors, excluding ID and target | 62 |
| Training Year_Factor | 1, 2, 3, 4, 5, 6 |
| Test Year_Factor | 7 only |
| Blank training energy_star_rating | 26,709, approximately 35.3% |
| Blank training year_built | 1,837, approximately 2.4% |
| Sample output header | id,site_eui |

Counts were obtained from local CSVs, not inferred from competition examples.
Blank counts do not include numeric sentinel values, which need separate review.
`BuildingRegressionModels.m` is the supplied starter tutorial in this repository;
it imports dummy data, explores missingness, separates the response, and trains
models. Adapt its sequence, but retain informative categories and fit cleaning
statistics inside validation folds rather than deleting all incomplete columns
or normalizing before splitting.

Run existing ingestion by opening MATLAB and executing:

```matlab
% from the repository root
step01_ingest
```

Run the saved script by name. Pasting its body into the Command Window changes
how `mfilename` resolves paths. Inspect `ingestionReport.MissingPredictors` and
`ingestionReport.UnseenTestCategories`. Runtime validation status is recorded in
[docs/STATUS.md](docs/STATUS.md), not implied by the existence of code.

## 3. Ingestion and exploratory analysis

Use `readtable` and explicit schema checks. Keep source tables unchanged. Save IDs
before excluding `id` and `site_eui` from predictors. Require a numeric finite
nonnegative target, nonempty tables, unique nonmissing IDs per file, compatible
predictor names/types, and identical predictor order after alignment.

Report distributions and missingness by facility, state, and year. Inspect area,
construction year, weather extremes, wind sentinels, rating range, target tail,
and duplicate predictor rows. Distinguish an impossible measurement from a rare
valid building. Do not remove high-energy examples using an arbitrary standard
deviation cutoff: original-scale RMSE is particularly sensitive to these rows.
Do not infer repeated-building identity from the row ID; verify any identity key
before choosing grouped validation.

### The year-category issue must be handled explicitly

The loader casts Year_Factor to categorical as requested and aligns test levels
to training. Therefore all test year-7 labels become undefined. This is reported,
but it is not a usable temporal model feature by itself.

Before that conversion, preserve raw numeric year factor in an optional loader
metadata output (recommended field: `meta.TrainYearFactor`, `meta.TestYearFactor`).
Use that raw metadata for temporal splits and optional numeric temporal features.
Keep the public categorical field for compatibility, but exclude it from the
first modeling feature set. Compare a numeric factor feature through validation.
An unseen year should never silently become a fabricated observed year. Tree
models also cannot extrapolate a trend beyond their learned numeric split range;
weather and temporal validation remain essential.

Do not compute `building_age = Year_Factor - year_built`: factors 1–7 are not
verified calendar years. Add age only after a documented calendar mapping is
confirmed. Otherwise keep cleaned year_built and omit age, with the reason logged.

## 4. Validation design before cleaning

Set `rng(2026,'twister')`; create and save `cvpartition(height(XTrain),'KFold',5)`
once, along with an explicit ID-to-fold table. Reuse these folds for every
candidate. Each row must have one out-of-fold prediction made by a model that did
not train on its target. All medians, categorical policies, scaling, feature
selection, and target encoding are learned on the fold's training rows only.

Also evaluate a temporal check: train on year factors 1–5, validate on 6. This
better resembles the observed 1–6 to 7 shift. If time permits, use earlier
forward checks such as 1–4 to 5. Report these separately from random five-fold
scores. Random CV is a benchmark, not evidence of future-year accuracy.

Candidate selection uses pooled five-fold RMSE as the requested primary metric,
with a temporal degradation guardrail: flag a candidate if year-6 RMSE is over
5% worse than the incumbent, and retain the incumbent unless the team records a
reason for accepting the regression. This 5% is a project decision threshold,
not a competition rule. Do not repeatedly tune on the year-6 check and then call
it an unbiased final test; tuning makes it validation data. A truly untouched
holdout or nested CV would be needed for an unbiased post-selection estimate.

## 5. Fit and apply preprocessing

1. Apply documented, deterministic validity rules to numeric measurements. Mark
   confirmed invalid values as missing; never treat zero as universally invalid.
2. Before filling, create missing indicators for rating, construction year, and
   other substantially incomplete predictors. Preserve original missingness.
3. Fit median energy_star_rating per facility_type on fold-training rows.
   Require at least five observed values per group; otherwise use the fold's
   overall median. This support threshold is configurable and recorded.
4. Fit the overall year_built median on valid fold-training observations.
5. Fit numeric fallback medians for other predictors. If an entire training-fold
   column is missing, drop it consistently using the saved schema and log it.
6. Apply saved medians with `fillmissing(column,'constant',savedMedian)`;
   grouped application loops over facility groups rather than individual rows.
   Never recompute a median from validation or test rows.
7. Save category levels and modal fallback labels per fold. Map missing/unseen
   categorical values to the saved mode for the initial robust implementation,
   and add an unknown/missing indicator so the model can distinguish fallback
   cases. Report fallback counts. Unknown Year_Factor uses the special policy
   above, not the general categorical mode rule.
8. Check that final numeric predictors are finite and categorical predictors have
   a defined supported fallback. Check identical names, types, and ordering.

Use native categorical table predictors for tree models. For SVM/kernel
comparisons, fit one-hot schema and numeric standardization on the training fold;
apply the saved schema and parameters to validation/test. Do not assume all
estimators accept the same table representation. Scaling is unnecessary for the
initial tree models. Avoid target encoding under the deadline; it requires an
additional cross-fitting layer even within each training fold.

## 6. Feature engineering and ablations

| Feature family | Definition or decision | Expected rationale |
| --- | --- | --- |
| Structure | log1p(floor_area), cleaned year_built | Represent skewed area and construction era |
| Thermal interactions | floor_area .* heating_degree_days; area .* cooling_degree_days | Proxy for seasonal building load, not a physical prediction of total energy |
| Weather range | monthly max minus min, after validating column meanings | Temperature variability |
| Extreme weather | existing hot/cold day counts, snowfall and snowdepth | Exposure and winter conditions |
| Wind | Optional components after units/convention/sentinels verified | Directional weather signal |
| Missing indicators | One flag per chosen incomplete source | Preserve informative absence |
| Age | calendarYear - year_built only with verified mapping | Building vintage relative to observation |

For verified meteorological direction in degrees (direction wind comes from),
eastward `u = -speed .* sind(direction)` and northward
`v = -speed .* cosd(direction)`. Verify that speed and direction refer to the same
event; max speed and peak speed directions are not automatically interchangeable.
If units or convention remain unresolved, omit components. Never turn wind
sentinels into valid angles by blindly applying modulo 360.

Test feature families one at a time using identical folds and model settings.
Keep a family only when its measured gain justifies complexity and temporal
behavior. No label-dependent aggregates may use validation targets. Area is an
input predictor; do not multiply predictions by area in the submission because
the target is intensity.

## 7. Training: baseline to advanced models

First fit a mean predictor using only training-fold targets. The mean minimizes
squared error among constant predictions. Then fit a regression tree for a
transparent baseline. Compare ensembles on the same processed folds:

| Candidate | Initial settings | Improvement budget |
| --- | --- | --- |
| Mean | mean(yFit) | Mandatory sanity baseline |
| Tree | MinLeafSize=20, MaxNumSplits=100 | Try leaf sizes 10, 20, 50 |
| Bag | 200 trees, MinLeafSize=10 | Try 100/300 trees; feature subsampling p or max(1,floor(p/3)) |
| LSBoost | 300 trees, LearnRate=0.05, MaxNumSplits=20, MinLeafSize=10 | Try 100/300/600 cycles; 0.03/0.1 learning rate; 10/30 splits |

These are starting candidates, not optimal settings or a request for a full
Cartesian search. Screen at most six candidate configurations initially. Use a
single fold or a fixed training subset for timing only, label screening scores,
then run full five-fold evaluation for finalists. Record actual runtime before
committing to expensive searches. Use fold loops for parallel execution only
when Parallel Computing Toolbox is available; save deterministic seeds per run.

MATLAB example for one already preprocessed fold:

```matlab
tree = fitrtree(XFit, yFit, 'MinLeafSize',20,'MaxNumSplits',100);
weak = templateTree('MinLeafSize',10,'MaxNumSplits',20);
boost = fitrensemble(XFit,yFit,'Method','LSBoost', ...
    'Learners',weak,'NumLearningCycles',300,'LearnRate',0.05);
bagTree = templateTree('MinLeafSize',10);
bag = fitrensemble(XFit,yFit,'Method','Bag', ...
    'Learners',bagTree,'NumLearningCycles',200);
yHat = predict(boost,XValidation);
```

`LSBoost` is the regression boosting method; do not pass `Method='Boost'`.
Boosting sequentially fits remaining errors; bagging averages trees trained on
bootstrap samples to reduce variance. Avoid SVM/kernel work until the tree
pipeline is complete: encoding, scaling and dataset size add cost. Models trained
on log1p(target) optimize a different loss; if explored, invert predictions and
score on original-scale RMSE, recognizing potential retransformation bias.

## 8. Evaluation, error analysis, and improvement

Compute `sqrt(mean((y - yHat).^2))` after asserting equal column shapes, nonempty
inputs and finite values. Do not silently omit NaN predictions. Pooled OOF RMSE
is calculated over all rows; it is not the arithmetic average of fold RMSEs.
Save individual fold scores and their mean/std as descriptive variability.

Save OOF predictions in original row order with id, actual, prediction, fold,
signed residual, and squared error. Report MAE as a supporting metric, plus
counts and RMSE by facility, state, year, target quantile, and missing-rating
status. Tiny groups need their sample sizes shown. Inspect the largest errors:
are they rare facilities, high targets, missing information, or data issues?
Create observed-vs-predicted scatter with identity line, residual plot, group
error chart, missingness chart and model comparison chart from real outputs.

Maintain an experiment log including run ID, commit, seed, feature flags, target
transform, parameters, fold scores, pooled RMSE, temporal RMSE and seconds.
Change one hypothesis at a time. Keep the best validated candidate as an
incumbent; do not select using training error or unlabeled test distributions.
Limit tuning to avoid validation overfitting and disclose selection bias.

An optional blend uses `alpha * boostOOF + (1-alpha) * bagOOF`, with
alpha in {0.25,0.5,0.75}. Compare against individual models on the same OOF rows
and temporal check. If chosen, refit both models and save weights. Weight tuning
on OOF targets adds selection optimism; describe the result as a validation
score, not a fresh independent test. Never average already rounded predictions.

## 9. Refit and predict the unlabeled data

Freeze the winning feature policy, settings, postprocessing and blend weights.
Fit a new preprocessor on all labeled rows, then refit the selected model(s) on
all labeled rows. Do not deploy an arbitrary fold model as the final model.
Apply saved preprocessing/feature logic to test rows without fitting anything
on them. Preserve original test ordering and IDs. Save the complete bundle,
reload it in a clean workspace, and compare predictions before/after reload.

If nonnegative clipping `max(0,yHat)` is adopted, evaluate that exact policy on
validation too. Reject NaN/Inf outputs; investigate the cause instead of filling
them with zero. An explicitly labeled emergency mean-predictor submission is a
separate fallback and must not masquerade as a successful ensemble.

## 10. Export and final checks

```matlab
assert(iscolumn(yHat) && numel(yHat)==numel(testID));
assert(all(isfinite(yHat)) && all(yHat>=0));
submission = table(testID,yHat,'VariableNames',{'id','site_eui'});
writetable(submission,fullfile(outputDir,'submission.csv'));
```

Reload the exported CSV. Require exactly two columns in that order, 9,705 rows
for the current files, unique IDs, no index column, IDs exactly matching input
test order and the sample template, and finite nonnegative values. Hardcoded
row counts belong in a dataset-specific audit; the reusable writer derives the
count from testID. Check a round-trip numeric tolerance instead of exact binary
equality after CSV text serialization. Store the config and evaluation report
beside the output. A valid file format does not establish predictive accuracy.

## 11. Delivery gates

- Gate A: ingestion checks pass on supplied CSVs; missingness report saved.
- Gate B: year metadata preserved; preprocessing fit/apply contracts work on a
  fixture with unseen categories, all-missing groups and sentinel measurements.
- Gate C: mean, tree, Bag and LSBoost OOF scores saved; temporal check reported.
- Gate D: feature experiments and selection rationale recorded; final bundle
  reload reproduces predictions; exported CSV passes compliance checks.
- Gate E: a teammate runs the documented commands from a clean MATLAB session;
  real charts and scores populate the demo; public links and Devpost are checked.

Use [docs/HACKATHON_PLAN.md](docs/HACKATHON_PLAN.md) for owners and cutoff times,
and [docs/PRESENTATION.md](docs/PRESENTATION.md) for the glassmorphism demo brief.
