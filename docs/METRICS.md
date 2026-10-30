# Presentation metrics: evaluated Bag model

Calculated from the saved Step 4 row-level validation predictions. No retraining
and no test labels are involved. Target values and ordered IDs were checked
against train.csv; RMSE agrees with the previously recorded scores to 1e-8.

| Scheme | Buildings | MSE | RMSE | MAE | R2 |
| --- | ---: | ---: | ---: | ---: | ---: |
| Five-fold pooled OOF | 75,757 | 1780.993 | 42.202 | 20.988 | 0.4752 |
| Latest-year holdout | 22,449 | 1725.401 | 41.538 | 21.193 | 0.4693 |

- MSE averages squared prediction errors; lower is better. Its units are squared
  site_eui units, so do not compare its numerical magnitude directly to MAE/RMSE.
- RMSE is the square root of MSE, in site_eui units; lower is better. Larger
  mistakes contribute disproportionately.
- MAE is the average absolute prediction error, also in site_eui units; lower
  is better. On later-year validation, absolute error averages about 21.19.
- R2 is 1 - SSE/SST, where SST is variation around the evaluated set's mean.
  Higher is better, 1 is perfect, and negative values are possible. It is not
  percentage accuracy or squared Pearson correlation. It is undefined for a
  constant actual target, which the MATLAB helper reports as NaN.

Suggested wording: “On the held-out latest year, bagging achieved RMSE 41.54,
MAE 21.19 and R-squared 0.469. This indicates useful predictive signal, with
substantial remaining variation.” MSE is available in the results table; prioritize
RMSE and MAE when speaking because their scale is easier to interpret.

R2 here uses each validation set's overall mean in the denominator; it is not
computed relative to the model trained as the Mean candidate. Pooled OOF metrics
use all OOF rows together, not the average of individual-fold metrics.

Full-precision data: release/validation_metrics.csv. Source hashes and definitions:
release/metrics_provenance.json. The release was independently calculated from CSVs
with Python standard-library arithmetic. MATLAB reproduces it via step06_metrics;
the added MATLAB helper test has not yet been run in the user's session.

The latest-year score informed model choice. It is a validation estimate, and
the unlabeled test data still has no measured MSE/MAE/R2.
