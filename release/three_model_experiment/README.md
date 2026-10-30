# Controlled three-model comparison

Completed in the user's MATLAB session. This package copies the recorded outputs
from artifacts/tp97d455ef_4ec6_4783_a03e_0e16578d0c62 without rerunning training.

| Model | Five-fold RMSE | Latest-year RMSE | Latest-year MAE | Latest-year R2 |
| --- | ---: | ---: | ---: | ---: |
| Model 1: all cleaned factors, tree | 45.2147 | 44.9802 | 22.7927 | 0.3777 |
| Model 2: selected factors, tree | 44.9971 | 44.7641 | 22.7324 | 0.3836 |
| Model 3: selected factors, LSBoost | 41.1704 | 42.9221 | 21.0440 | 0.4333 |

metrics.csv contains every recorded metric at full precision. Each model folder
has oof/ and latest_year/ subfolders with metrics.csv, validation_summary.json,
plot_points.csv, predicted_vs_actual.png and residual_diagnostics.png.

Use the JSON for UI integration and PNGs for slides. Each JSON records its model,
validation scheme, full metric row count and display-sample information. Metrics
use all validation rows; interactive point samples contain up to 2,000 rows.

Models 2 and 3 share eight source factors plus their missingness flags: floor_area,
energy_star_rating, year_built, heating_degree_days, cooling_degree_days,
State_Factor, building_class and facility_type. Model 1 uses all cleaned source
factors and flags. IDs, target and categorical Year_Factor are excluded from
model inputs. No additional engineered features are introduced here.

This experiment did not create a final fitted model or replace any submission.
The official root submission belongs to the separate LOYO/LSBoost workflow.
