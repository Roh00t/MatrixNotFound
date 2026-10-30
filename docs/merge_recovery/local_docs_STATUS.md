# Implementation status

Updated 30 October 2026 during the developer handoff.

| Component | Status |
| --- | --- |
| Starter review | BuildingRegressionModels.m and README reviewed |
| Local data audit | Row counts, columns, blank counts and year-factor shift inspected |
| Step 1 ingestion | Existing step01_ingest.m and src/loadBuildingData.m present |
| Ingestion runtime check | Passed in the user's MATLAB desktop session: 75,757 training rows, 9,705 test rows, 62 predictors |
| Year metadata preservation | Implemented as optional seventh loader output; categorical year excluded from Step 2 model inputs |
| Preprocessing | Passed in the user's desktop session: all rows retained, 122 model inputs, completion checks passed; unit tests not yet verified |
| Feature engineering | Passed in user's desktop session: five added features, 127 model inputs |
| Training/evaluation | Passed in user's MATLAB session; saved CSV confirms Bag OOF RMSE 42.2018, temporal RMSE 41.5379; LSBoost OOF 41.8071, temporal 45.0487 |
| Tuning | Planned after initial model scores |
| Final model/submission | Passed in user's MATLAB session in 262.6 seconds; final model saved, 9,705 predictions, bundle reload and CSV checks passed |
| Presentation | Storyboard and design specification written; rendered deck not created |

Do not treat documentation snippets as finished executable modules. The current
priority is publishing the checked release package and preparing the presentation.
Bag was selected for its stronger later-year validation score.

Packaging review: release/submission.csv and release/model_comparison.csv copy the
completed run outputs. IDs, schema, row counts and prediction finiteness were
independently checked; SHA-256 manifest saved. Large model stays local. README
now describes the evaluated step pipeline; alternate draft retained separately.

Both feature implementations are preserved with explicit calls. The alternate
main/trainModels workflow uses engineerLegacyFeatures; the evaluated step pipeline
uses engineerFeatures after cleaning. The alternate calendar mapping is not used
in Step 5. Packaging resolved the earlier Git conflicts.

Code revision: central buildingConfig shared by Steps 4/5; validation argument
guards; inference bundle-version checks; a synthetic five-fold/refit/reload/export
test; and demo_submission for showing saved evidence without retraining.
Revision runtime tests have been launched but have not returned a result. Historical
Step 1–5 run results remain valid evidence for the preceding code version; no new
accuracy claim is made for this revision. Settings and evaluated feature formulas
were preserved. See CODE_REVIEW.md for review scope and remaining limitations.

Runtime attempt: MATLAB R2026b with a workspace-local preferences directory;
batch command changed into this repository, ran step01_ingest, and would have
asserted 75,757 training rows and 9,705 test rows. MATLAB failed before those
assertions ran: `Unable to communicate with required MathWorks services (error 5201)`.
Try running the script in the team's already signed-in MATLAB desktop session.
This is an environment/service blocker, not proof that the loader passes or fails.
