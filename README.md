<td>
<img src="/Images/Hackathons Banner.jpg" style="width:1275px;height:158.25px">
</td>

# Predict Building Energy Consumption with MATLAB&reg;

## Team developer handoff

Start here: [Pipeline deep dive](pipeline.md) · [Architecture and function contracts](architecture.md)
· [Resources](docs/RESOURCES.md) · [Execution plan](docs/HACKATHON_PLAN.md)
· [Glassmorphism presentation brief](docs/PRESENTATION.md) · [Implementation status](docs/STATUS.md).

The repository currently implements Step 1 ingestion. Training, evaluation,
prediction and export are specified in the handoff and still need development.
No model accuracy score or completed submission is claimed.

Run `step01_ingest` from this repository in MATLAB to load the supplied data.
The data includes a year-factor shift from training years 1–6 to test year 7;
read the pipeline's year-handling policy before building models.

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
