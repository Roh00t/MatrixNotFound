# Presentation brief: glassmorphism

Yes: **glassmorphism** is the usual name for translucent, frosted-glass panels
over a layered background. This document specifies the slide design and script;
it is not a rendered slide deck. Shuan owns production, using real model evidence
as it becomes available. Aim for 4 minutes 30 seconds, leaving a 30-second margin.

## Visual direction

Use 16:9 slides, a dark navy background (#0B1220), restrained teal (#38B7C8) and
violet (#8B7CF6) gradient shapes, white primary text and muted blue-gray secondary
text. Place content on rounded translucent panels with a subtle light border.
For PowerPoint, emulate frosting with a pre-blurred background image and a
semi-transparent panel; do not depend on live browser backdrop-blur effects.

Keep titles around 34–44 pt, body text at least 24 pt, chart labels at least
18 pt, and one main claim per slide. Test on the actual presentation screen.
Keep solid dark areas beneath text, use high contrast, and avoid faint chart
axes. Glass is decoration around evidence, not a reason to make plots unreadable.
Use one font family such as Aptos or Arial and two weights. Avoid long code
screenshots, animated backgrounds, and paragraphs on cards.

## Six-slide storyboard and talk track

| Slide | Time | Content and visual | Spoken message |
| --- | --- | --- | --- |
| 1: Which buildings need attention? | 0:00–0:30 | Project name MatrixNotFound; simple building visual; one-sentence goal | We predict energy intensity from building and weather information to help prioritize investigation. |
| 2: Real data, real challenges | 0:30–1:10 | Cards: 75,757 training rows; 9,705 test rows; rating missingness 35.3%; years 1–6 to 7 | Missing information and a future-year shift make validation and cleaning important. |
| 3: How our pipeline learns | 1:10–1:55 | Five-node pipeline with a visible validation boundary | We fit cleaning on training folds, compare models on hidden answers, then refit for the unlabeled buildings. |
| 4: What improved the model? | 1:55–2:50 | `figures/1_rmse_by_year.png` plus `2_validation_gap.png`: tree 61.0 → LSBoost v1 41.1 → v2 41.8 → v3 40.1 | Boosting cut error by 33%; shrinkage didn't help; removing the monthly temperature columns that act as state-year fingerprints did. Lower RMSE is better. |
| 5: Show that it works | 2:50–3:50 | `figures/3_predicted_vs_actual.png`, `figures/5_retrofit_radar.png` and `ProjectReport.html` | The model learns what a building should use, so buildings far above that are the first to audit: 1,316 buildings use 50%+ more than expected. |
| 6: Impact, limitations, next step | 3:50–4:30 | Three short cards; public repository link or QR | This is a prioritization signal. Future-year uncertainty and unusual buildings remain challenges; next step is stronger temporal evaluation. |

## Verified results to use (full run of `main.m`, seed 42)

| Fact | Value |
| --- | --- |
| LOYO RMSE: tree / LSBoost v1 / v2 / v3 | 61.02 / 41.06 / 41.85 / **40.12** |
| Improvement, tree → v3 | 34% lower RMSE (`100*(61.02-40.12)/61.02`) |
| Tree, random 5-fold vs LOYO | 50.29 vs 61.02 (random folds understate error by 10.7) |
| Leakage fixed | Tree LOYO 58.6 → 61.0 once preprocessing moved inside the folds |
| Engineered features in the top 9 predictors | 4 (Energy Star × area, age, area × HDD, area × CDD) |
| Accuracy, out-of-fold (v3) | MAE 21.0 · median absolute error 12.6 · RMSE 40.1 · R² 0.53 (median EUI ≈ 75) |
| NTU what-if (illustrative) | The Hive ≈ 109, The Arc ≈ 102 kBtu/ft²/yr vs. US university median 91; see `figures/ntu_landmarks.png` |
| Retrofit Radar, latest year | 1,316 of 22,449 buildings use 50%+ more than expected; top 50 = 1,573 GWh/yr excess |

All figures are in `figures/`; the full narrative is in `ProjectReport.html`.

## Evidence checklist

Fill result fields only from the verified results above or the saved experiment
report; never invented scores. Include sample counts on error slices.
Compute relative RMSE improvement as
`100 * (baselineRMSE - selectedRMSE) / baselineRMSE`; label which baseline.
Do not describe that percentage as energy saved. Show the random CV and temporal
validation results separately and describe them as validation scores.

Export charts from MATLAB with consistent colors and solid/transparent backgrounds
that remain legible on the slide. Keep editable chart sources and PNG exports.
For a live demo, use a previously fitted bundle so the presentation does not
depend on lengthy training. Provide a backup recording and PDF export.

## Suggested demo sequence, under 60 seconds

1. Show the input building columns and one sentence explaining the target.
2. Run `ProjectReport` in MATLAB (seconds; it loads the saved results), or open
   `ProjectReport.html`.
3. Show the end of a `main` run log: "Wrote 9705 predictions", the passing
   submission checks and the model comparison table.
4. Open `results/retrofit_shortlist.csv` and the Retrofit Radar chart, then
   return to the slides.

Do not run `main` live: the full pipeline takes 25-35 minutes.

## Delivery checklist

Slides open correctly on a second machine; fonts/images are embedded or portable;
the deck and backup PDF are in the public deliverable location; repository links
open without signing in; the recording is shorter than five minutes; team roles
and data sources are credited; no private paths or credentials appear on screen.
Rehearse once with a timer and finish comfortably before the deadline.
