# Devpost submission draft

## Elevator Pitch

Retrofit Radar helps building owners spot properties that consume more energy than expected for their type and climate, so they can prioritize retrofits that reduce waste and carbon emissions.

## Inspiration

Buildings account for a significant share of energy use and carbon emissions, but organizations often have limited resources to decide where efficiency upgrades will make the greatest difference. We wanted to turn building and weather data into a practical way to identify high-use properties and help target retrofit efforts where they are needed most.

## What it does

Retrofit Radar predicts a building's site energy use intensity (`site_eui`) from its characteristics, location, and climate. It uses those predictions to flag buildings whose energy use is higher than expected for their building type and climate, helping teams focus investigation and retrofit planning on potential outliers.

## How we built it

We built a reproducible, end-to-end machine-learning pipeline in MATLAB and iterated through three model stages:

1. **Model 1 — Baseline:** trained a baseline model using the available features to establish a performance reference.
2. **Model 2 — Feature selection and reduction:** tested whether selecting or reducing features could improve generalization and simplify the model.
3. **Model 3 — LSBoost:** deployed MATLAB's native least-squares boosting (`LSBoost`), a gradient-boosted tree approach in the same broad family as XGBoost, to pursue the strongest predictive performance.

We compared models using validation designed around the dataset's time split and used the selected model to produce building-level predictions.

## Challenges we ran into

The training data covers Years 1–6, while the test data is from Year 7. A random split would not reflect that temporal gap, so we used Leave-One-Year-Out Cross-Validation to evaluate how well models generalize to a year they have not seen.

We also found **2.4 RMSE of hidden data leakage** in validation: preprocessing had been fit before the cross-validation split, allowing information from held-out rows to influence preprocessing. We eliminated this leakage by fitting preprocessing separately inside each CV training fold and applying those learned transformations to that fold's held-out data.

## Accomplishments that we're proud of

- Engineered physical features—including efficiency rating × floor area, floor area × heating and cooling degree days, and building age—ranked among the top eight features by importance.
- Built the implementation using native MATLAB tools, without external machine-learning dependencies.
- Designed validation to reflect the real temporal shift from training years to the test year.

