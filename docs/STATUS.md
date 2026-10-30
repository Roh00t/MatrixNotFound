# Implementation status

Updated 30 October 2026 during the developer handoff.

| Component | Status |
| --- | --- |
| Starter review | BuildingRegressionModels.m and README reviewed |
| Local data audit | Row counts, columns, blank counts and year-factor shift inspected |
| Step 1 ingestion | Existing step01_ingest.m and src/loadBuildingData.m present |
| Ingestion runtime check | Blocked: MATLAB batch startup reports MathWorks services error 5201; ingestion has not been runtime-verified |
| Year metadata preservation | Planned; current loader makes unseen test year 7 undefined |
| Preprocessing/features | Specified, not implemented |
| Training/evaluation/tuning | Specified, not implemented; no measured RMSE |
| Final model/submission | Not generated |
| Presentation | Storyboard and design specification written; rendered deck not created |

Do not treat documentation snippets as finished executable modules. The current
priority is a successful ingestion run and the explicit year handling described
in pipeline.md, followed by the preprocessing and baseline gates.

Runtime attempt: MATLAB R2026b with a workspace-local preferences directory;
batch command changed into this repository, ran step01_ingest, and would have
asserted 75,757 training rows and 9,705 test rows. MATLAB failed before those
assertions ran: `Unable to communicate with required MathWorks services (error 5201)`.
Try running the script in the team's already signed-in MATLAB desktop session.
This is an environment/service blocker, not proof that the loader passes or fails.
