# Devpost submission draft

## Try it out

- **Demo video (YouTube):** https://youtu.be/bKo0Yp50wDo
- **Live site (GitHub Pages):** https://roh00t.github.io/MatrixNotFound/ (landing page linking to all three pages)
  - Results dashboard: https://roh00t.github.io/MatrixNotFound/dashboard/
  - 3D building simulator: https://roh00t.github.io/MatrixNotFound/dashboard/simulator.html
  - Written report (MATLAB live script): https://roh00t.github.io/MatrixNotFound/ProjectReport.html
- **Code:** https://github.com/Roh00t/MatrixNotFound
- **Demo deck:** `presentation/MatrixNotFound_Hackathon_Presentation.pdf` (5-minute presentation, with speaker notes in the `.pptx`)

## Elevator pitch

Retrofit Radar predicts how much energy a building *should* use from its type, size, age and climate, then flags the buildings using far more than similar ones, so organisations know which buildings to audit and retrofit first.

## Inspiration

Buildings account for a large share of energy use and carbon emissions, but organisations have limited budgets for efficiency upgrades. We wanted to turn building and weather data into a practical shortlist: the buildings where a retrofit is most likely to cut waste.

## What it does

- Predicts a building's **site energy use intensity** (`site_eui`, kBtu/ft²/yr) from its characteristics and local climate, trained on 75,757 building-years from the WiDS Datathon 2022 data, and predicts all 9,705 test buildings (`results/submission.csv`).
- Powers **Retrofit Radar**: it compares each building's actual energy use with what the model expects for similar buildings, and ranks them by excess energy. In the latest year, **1,316 of 22,449 buildings** use at least 50% more energy than expected, and the top 50 account for **1,573 GWh/yr** of excess use.
- Ships three pages:
  - an **interactive results dashboard** that updates live while the MATLAB pipeline runs
  - a **3D simulator** of NTU's The Hive and The Arc, where clicking a building runs our trained model in the browser
  - a **written report** exported from a MATLAB live script

## How we built it

An end-to-end, reproducible pipeline in MATLAB (`main.m`), with one function per stage in `src/`:

1. **Load:** typed `readtable`, categorical predictors, and the same category levels for train and test.
2. **Clean:** `energy_star_rating` filled with the facility-type median, other gaps with the overall median, and "was missing" flags added. All fill values are learned from training rows only.
3. **Engineer:** building age, floor area × heating and cooling degree days, and Energy Star × floor area.
4. **Validate:** **leave-one-year-out CV**. The test set is a single unseen year (7), so we hold out one whole year at a time. Cleaning and feature engineering are refit inside every fold.
5. **Iterate:** four models, scored by leave-one-year-out RMSE (lower is better):

| Model | Change | LOYO RMSE |
| --- | --- | --- |
| Regression tree (`fitrtree`) | Baseline | 61.02 |
| LSBoost v1 (`fitrensemble`) | Gradient boosting, 300 trees: MATLAB's native XGBoost-family method | 41.06 (−33%) |
| LSBoost v2 | Shrinkage: lower learning rate, larger leaves, binning. It didn't help, and we kept it to show the iteration honestly | 41.85 |
| **LSBoost v3** | **Feature selection:** drop the 36 monthly temperature columns, which act as state-year fingerprints | **40.12 (−34%)** |

LSBoost v3 was the best model in 5 of 6 held-out years. On years it never saw, it scores **MAE 21.0** kBtu/ft²/yr (the median building uses about 75) and **R² 0.53**.

6. **Control experiment:** a second, independently built pipeline compared a tree on all factors, a tree on 8 selected factors, and LSBoost on the same 8 factors, using the same folds. LSBoost on selected factors won on every metric: five-fold RMSE 41.17 vs 45.21 for the tree, latest-year RMSE 42.92 vs 44.98. On the shared year-6 holdout, the two pipelines' best models agree within 0.25 RMSE (41.31 vs 41.54).
7. **Ship:** `writeSubmission` checks the file is exactly 9,705 × 2 `id,site_eui`, all values finite and non-negative, with ids matching the sample solution. MATLAB also writes the Retrofit Radar shortlist, 13 figures, the dashboard data and the HTML report.
8. **Browser model:** the 300-tree ensemble is exported from MATLAB to JavaScript. A Node.js test confirms the browser predictions match MATLAB's `predict()` exactly (difference 0 on 500 test rows and 9 full-pipeline scenarios).

## Challenges we ran into

- **The test set is a different year.** Training covers years 1–6 and testing is year 7, with no State 6 buildings. Random 5-fold CV reported RMSE 50.29 for our baseline tree, against 61.02 when a whole year is held out. Random folds hide 10.7 points of error, so we validate by year.
- **Hidden leakage.** Fitting preprocessing before the split let held-out rows influence the fill values, and hid 2.4 RMSE (58.6 → 61.0 once fixed). We moved all preprocessing inside each CV fold.
- **Messy, missing data.** Energy Star rating is 35% missing, and wind and fog data are about 90% missing in the test set. We filled gaps from training data only, kept missingness flags, and skipped wind features that would mostly encode filled-in values.
- **Shipping 3D on the web.** One AI-generated building model was 245 MB, too big for GitHub. We shrank it to 150k triangles (11 MB) with headless Blender.

## Accomplishments that we're proud of

- **Honest validation:** leave-one-year-out CV with leakage-free preprocessing, plus an independent cross-check pipeline that agrees with our result.
- **Real iteration:** four models with every attempt kept, including the one that didn't help.
- **Features that mattered:** our engineered features rank among the model's top nine predictors.
- **Reproducibility:** a clean-room rerun reproduced our submission byte for byte. `checkcode` reports 0 issues across 46 MATLAB files, and 11 unit tests pass.
- **From model to action:** Retrofit Radar turns predictions into a ranked audit list, plus a state × facility-type map for audit campaigns.
- **The model in your browser:** a 3D simulator where you click NTU's The Hive or The Arc. The prediction (energy intensity, annual MWh, average kW) and the response curves update live as you change floor area, age, Energy Star rating or climate.

## What we learned

- How you validate matters as much as which model you pick: random folds would have given us a flattering but wrong error estimate.
- Gradient boosting beats a single tree by a wide margin on tabular data, but more trees and slower learning (v2) do not always help.
- Removing redundant features (the monthly temperatures) can improve generalisation to an unseen year.
- A prediction becomes useful when it is turned into a decision. Here, that means which buildings to inspect first.

## What's next

- Add real metered data and occupancy information to explain more of the variation (R² 0.53 today).
- Bring local climate data for Singapore, so NTU buildings can be assessed with their own weather rather than a US climate analogue.
- Track buildings over time, so Retrofit Radar can show whether a retrofit actually reduced excess energy.

## Built with

MATLAB · Statistics and Machine Learning Toolbox (`fitrtree`, `fitrensemble` LSBoost, `cvpartition`, `predictorImportance`) · MATLAB live scripts · JavaScript · Chart.js · three.js · Blender · Node.js · GitHub Pages

## Team

- Yeong Sir Chung
- Matthew Roberto
- Rohit Panda

Data: WiDS Datathon 2022, provided by the hackathon organisers. Starter material © The MathWorks, Inc.
