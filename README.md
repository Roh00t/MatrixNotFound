<td>
<img src="/Images/Hackathons Banner.jpg" style="width:1275px;height:158.25px">
</td>

# Predict Building Energy Consumption with MATLAB&reg;
This repository contains code and instructions enable you to develop an algorithm that can predict how much energy a building will consume based on building characteristics, weather data for it's location, and more. Work like this can help determine which buildings are using and maybe wasting the most energy, which could be great candidates for retrofitting.

Click here to open the code and repository in MATLAB Online&trade;:

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=mathworks/predicting-building-energy-consumption)

## Pre-work
We recommend participants complete the following before the event if they are not familiar with these topics:
* [MATLAB Onramp](https://matlabacademy.mathworks.com/details/matlab-onramp/gettingstarted)
* [Machine Learning Onramp](https://matlabacademy.mathworks.com/details/machine-learning-onramp/machinelearning)

## Files### Building Regression Models.m
The code tutorial that will explain how to access the challenge dataset and how to get started on developing and presenting your own algorithms to predict building energy consumption. 

### exampleTrain.zip
The dummy dataset used in Building Regression Models.mlx, zipped into a compressed folder. To use this dataset, you must first extract the .CSV file from the folder.

### Scoring Rubric.pdf
Contains the scoring rubric that will be used by the judges to score your submission. 

### Instructions & Challenge Overview.pdf
Explains the challenge and provides some additional resources for the hackathon.

**Copyright 2025-2026 The MathWorks, Inc.**

## Run the MATLAB prediction pipeline

The end-to-end pipeline is in [`main.m`](./main.m), with data loading,
preprocessing, feature engineering, model selection, and submission writing
modularized under [`src/`](./src). It requires MATLAB and the Statistics and
Machine Learning Toolbox.

1. Make sure `data/train.csv` and `data/test.csv` are present.
2. Open the repository root in MATLAB and run `main.m`.
3. Review the printed Leave-One-Year-Out and random 5-fold RMSE results.
4. Find the generated `submission.csv` in the repository root.

The script uses a fixed random seed. Imputation and feature engineering are
fit separately inside each validation fold; final imputation statistics are
learned from the complete training set and reused unchanged for the test set.
`Year_Factor` is converted to a numeric value so the model can handle the
test-only year. The submission writer checks prediction finiteness and row
counts before writing `id,site_eui`.
