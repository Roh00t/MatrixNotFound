# Start here

## Open the project

In MATLAB, set the current folder to the repository root. This is the folder
containing main.m, run_project_tests.m, data/, src/ and dashboard/.

The active UI is dashboard/index.html; the simulator is dashboard/simulator.html.
The separate six-slide draft is presentation/retrofit-radar-ntu.html. These are
different deliverables. The UI teammate owns the dashboard and simulator.

## Which workflow should I run?

| Goal | Command or file | Retrains? |
| --- | --- | --- |
| Check backend tests and show bagging cross-check evidence | run_project_tests | Small synthetic fits only |
| Show packaged bagging metrics and predictions | demo_submission | No |
| Run the official LOYO/LSBoost pipeline | main | Yes, full data |
| Read the official report | ProjectReport.html | No |
| Refit the earlier bagging model and export | step05_predict_submit | Yes, one final fit |
| Recompute earlier bagging metrics from saved predictions | step06_metrics | No |
| Export earlier bagging diagnostics from saved predictions | step07_diagnostics | No |
| Rerun all/selected/tree/boost comparison | step08_compare_three_models | Yes, validation fits |
| Browse the completed three-model results | ../release/three_model_experiment/ | No |

Steps 01–03 load, clean and engineer preview data. Step 04 validates the original
cross-check candidates. Scripts remain in the root so familiar commands keep working.
No need to run training to rehearse a presentation or inspect the completed results.

## Three experiment families

| Experiment | Selected/best model | Validation evidence | Submission |
| --- | --- | --- | --- |
| Official pipeline | LSBoost v3 | Recorded pooled LOYO RMSE 40.1227 | Root submission.csv |
| Original cross-check | Bag, 200 trees | OOF RMSE 42.2018; year-6 RMSE 41.5379 | release/crosscheck_bag_submission.csv |
| Controlled three-model comparison | Model 3, selected factors + LSBoost | OOF RMSE 41.1704; year-6 RMSE 42.9221 | No replacement submission generated |

Keep model names and validation methods attached to every score. LOYO and random
five-fold scores answer different questions and must not be ranked as if they
were the same experiment. Model 3 wins within the new three-model comparison;
that result did not replace either existing submission.

## Where files belong

- src/: reusable MATLAB functions. main uses engineerLegacyFeatures; the step
  pipeline uses engineerFeatures. Both are explicit to preserve their schemas.
- tests/: backend function tests; tests/web/: simulator prediction checks.
- tools/: build/export utilities; tools/debug/: troubleshooting utilities.
- dashboard/: active UI, simulator and web model exports. Preserve teammate work.
- presentation/: slide-style browser draft, separate from the dashboard.
- release/: shareable cross-check and comparison evidence, with stable filenames.
- results/ and figures/: official workflow outputs referenced by the dashboard/report.
- artifacts/: ignored local model bundles, checkpoints and raw validation predictions.
- docs/: active handoff/reference documents; docs/archive/: preserved recovery drafts.
- data/: original train, test and sample CSVs. Do not edit to tidy the project.

## Documentation guide

- [UI/backend contract](UI_BACKEND_HANDOFF.md): JSON fields and chart data.
- [Three-model experiment](THREE_MODEL_EXPERIMENT.md): factors and fair comparison.
- [Metrics](METRICS.md): MSE, RMSE, MAE and R2 definitions for the cross-check.
- [Presentation](PRESENTATION.md): storyboard and design direction.
- [Resources](archive/RESOURCES.md): data dictionary and MATLAB references.
- [Status](STATUS.md): recorded runs and remaining checks.

Keep the large local model bundle safe; it is not in an ordinary Git clone.
Publishing code does not upload a Devpost entry or competition submission.
