# Devpost submission draft

## Elevator Pitch

Retrofit Radar helps building owners spot properties that consume more energy than expected for their type and climate, so they can prioritize retrofits that reduce waste and carbon emissions.

## Inspiration

Buildings account for a significant share of energy use and carbon emissions, but organizations often have limited resources to decide where efficiency upgrades will make the greatest difference. We wanted to turn building and weather data into a practical way to identify high-use properties and help target retrofit efforts where they are needed most.

## What it does

Retrofit Radar predicts a building's site energy use intensity (`site_eui`) from its characteristics, location, and climate. It uses those predictions to flag buildings whose energy use is higher than expected for their building type and climate, helping teams focus investigation and retrofit planning on potential outliers.

## How we built it

We built a reproducible, end-to-end machine-learning pipeline in MATLAB and iterated through four models, scored by leave-one-year-out RMSE (lower is better):

1. **Regression tree baseline** (`fitrtree`): 61.02.
2. **LSBoost v1** (`fitrensemble`, 300 trees): MATLAB's native least-squares gradient boosting, in the same family as XGBoost. 41.06, a 33% improvement.
3. **LSBoost v2, shrinkage** (lower learning rate, larger leaves, binning): 41.85. It didn't help, and we kept the result to show the iteration honestly.
4. **LSBoost v3, feature selection** (dropped the 36 monthly temperature columns, which are identical for every building in a state-year and let the trees memorise those combinations): **40.12, our best**. It was the best model in 5 of 6 held-out years and is used for the submission.

The selected model then powers **Retrofit Radar**. It compares each building's actual energy use with what the model expects for similar buildings, and ranks buildings by excess energy. In the latest year, 1,316 of 22,449 buildings use at least 50% more energy than expected.

## Challenges we ran into

The training data covers Years 1–6, while the test data is from Year 7. A random split would not reflect that temporal gap, so we used Leave-One-Year-Out Cross-Validation to evaluate how well models generalize to a year they have not seen. The difference is large: random 5-fold CV reported RMSE 50.29 for our baseline tree, against 61.02 when a whole year is held out.

We also found **2.4 RMSE of hidden data leakage** in validation: preprocessing had been fit before the cross-validation split, allowing information from held-out rows to influence preprocessing. We eliminated this leakage by fitting preprocessing separately inside each CV training fold and applying those learned transformations to that fold's held-out data.

## Accomplishments that we're proud of

- Engineered physical features (efficiency rating × floor area, floor area × heating and cooling degree days, and building age) all rank among the top nine predictors of the final model.
- Built the implementation using native MATLAB tools, without external machine-learning dependencies.
- Designed validation to reflect the real temporal shift from training years to the test year.

