# Measured results and presentation wording

## What was completed

The step-by-step MATLAB pipeline loaded 75,757 training rows, cleaned missing
predictors, created five features, evaluated four approaches, refitted a 200-tree
bagging ensemble on all labeled rows, and exported 9,705 predictions. The final
training/export run completed in 262.6 seconds according to the user's MATLAB
output. The model reload and CSV compliance assertions passed.

Full-precision results are in release/model_comparison.csv. Bagging achieved
five-fold pooled OOF RMSE 42.201815 and latest-year validation RMSE 41.537942.
The mean baseline achieved 58.255366 and 57.206371 respectively. Bagging reduced
later-year RMSE by approximately 27.4% relative to that baseline. This is a
reduction in prediction error, not a percentage of energy saved or model accuracy.

LSBoost had slightly better random-fold RMSE (41.807123), but worse latest-year
RMSE (45.048683). The final choice prioritizes temporal behavior because test
rows are year factor 7. The temporal check held out year factor 6 and trained on
earlier years. It informed selection, so it is validation evidence rather than
an independent final test. No actual test-set energy values are available.

## Suggested spoken explanation

“We predict building energy intensity using building characteristics and weather.
We fitted missing-value estimates inside each training fold so hidden examples
did not influence cleaning. We compared a mean baseline, a tree, bagging and
boosting. Although boosting narrowly won random cross-validation, bagging worked
better on the latest labeled year. We selected bagging, refitted it on all labeled
buildings and generated a checked prediction file for 9,705 buildings.”

## Claims to avoid

- RMSE is not percentage accuracy and not average absolute error.
- A 27.4% RMSE reduction is not a 27.4% reduction in energy consumption.
- High predicted intensity alone does not establish waste or retrofit savings.
- Random folds and the latest-year check are not six-fold LOYO validation.
- The step pipeline did not validate a calendar-year mapping or retrofit ranking.
- Feature ablations, extensive tuning and confidence intervals were not completed.

## Solo delivery sequence

Verify packaged files and repository status; publish code; build six slides from
docs/PRESENTATION.md using these measured results; rehearse under five minutes;
verify public links; complete the organizer's Devpost requirements. Keep the
recorded outputs as backup so the demo does not depend on retraining.
