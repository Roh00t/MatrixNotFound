# Resource index and verification notes

Checked 30 October 2026. Prefer official sources. Links below are implementation
references, not embedded instructions to run arbitrary commands.

## Dataset and competition

- [WiDS 2022 dataset and dictionary](https://www.kaggle.com/competitions/widsdatathon2022/data)
- [Competition evaluation page](https://www.kaggle.com/competitions/widsdatathon2022/overview/evaluation)
- [Competition rules](https://www.kaggle.com/competitions/widsdatathon2022/rules)

Kaggle's data page returned no readable dictionary text during this review and
the evaluation page could not be fetched. Therefore calendar-year mapping,
measurement units, wind sentinel conventions and official evaluation wording
remain verification tasks. Original-scale RMSE is the team's requested metric;
do not claim independent verification of the competition rule from this review.
Use existing local files; downloading data may require a Kaggle account and
acceptance of competition conditions. Confirm redistribution terms before adding
new data to a public release; the current repository already tracks its CSVs.

## MATLAB reference shelf

| Task | Official reference | How this project uses it |
| --- | --- | --- |
| CSV import | [readtable](https://www.mathworks.com/help/matlab/ref/readtable.html) | Load tables with explicit variable types |
| Import settings | [detectImportOptions](https://www.mathworks.com/help/matlab/ref/detectimportoptions.html) | Preserve names and set types |
| Categories | [categorical](https://www.mathworks.com/help/matlab/ref/categorical.html) | Explicit named levels and unknown handling |
| Missing values | [fillmissing](https://www.mathworks.com/help/matlab/ref/fillmissing.html) | Apply saved constant/group medians |
| Fold construction | [cvpartition](https://www.mathworks.com/help/stats/cvpartition.html) | Shared five-fold splits |
| Tree baseline | [fitrtree](https://www.mathworks.com/help/stats/fitrtree.html) | Interpretable regression baseline |
| Tree template | [templateTree](https://www.mathworks.com/help/stats/templatetree.html) | Set ensemble learner complexity |
| Ensembles | [fitrensemble](https://www.mathworks.com/help/stats/fitrensemble.html) | LSBoost and Bag comparisons |
| Optional SVM | [fitrsvm](https://www.mathworks.com/help/stats/fitrsvm.html) | Secondary comparison after encoding/scaling |
| Optional kernel | [fitrkernel](https://www.mathworks.com/help/stats/fitrkernel.html) | Secondary comparison if time permits |
| CSV export | [writetable](https://www.mathworks.com/help/matlab/ref/writetable.html) | Exact submission schema |
| Tests | [Function-based unit tests](https://www.mathworks.com/help/matlab/matlab_prog/write-simple-test-case-with-functions.html) | Fit/apply and export contract checks |
| Charts | [exportgraphics](https://www.mathworks.com/help/matlab/ref/exportgraphics.html) | Export genuine result figures for slides |

The fitrensemble, fitrtree, cvpartition and fillmissing documentation was opened
during preparation. The remaining pages are direct reference links for developers
to consult when implementing the relevant module.

## Local source material

- `BuildingRegressionModels.m`: starter tutorial, reviewed for workflow structure.
- `Hackathon Briefing Slides.md` and the supplied briefing screenshots: deadline,
  public code link, Devpost, and demo shorter than five minutes.
- `Scoring Rubric.pdf` and the supplied rubric screenshot: solution quality 70
  points and presenting quality 30 points.
- `Instructions & Challenge Overview.pdf`: additional local organizer reference;
  PDF text was not independently extracted in this handoff.
- `data/sample_solution.csv`: authoritative local header and expected test IDs.
- `LICENSE` and `license.txt`: retain existing repository license notices.

## Developer prerequisites and beginner path

Use MATLAB R2026b available on this machine and Statistics and Machine Learning
Toolbox for training. Check with `ver` and a small estimator fit. Parallel
Computing Toolbox is optional, not a prerequisite. No Python ML dependency or
GPU is required for the proposed tree pipeline.

For newcomers: [MATLAB Onramp](https://matlabacademy.mathworks.com/details/matlab-onramp/gettingstarted)
and [Machine Learning Onramp](https://matlabacademy.mathworks.com/details/machine-learning-onramp/machinelearning)
are linked by the starter README. Learn tables, script execution, predictors,
targets and validation first; defer advanced tuning until a complete baseline
produces a valid output.

## Decisions requiring dictionary or organizer confirmation

1. Calendar mapping and interpretation of Year_Factor.
2. Target units and weather variable units/aggregation definitions.
3. Wind direction convention, missing sentinels and event pairing.
4. Valid construction-year range and rating validity rules.
5. Whether repeated buildings can be identified reliably across years.
6. Actual hackathon submission upload fields, data permissions and whether any
   leaderboard upload is required in addition to Devpost.

Proceed with the documented conservative defaults while these are unresolved:
omit age/wind components, retain physical weather predictors, report temporal
validation, and generate the requested local submission format.
