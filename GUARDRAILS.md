# Guardrails

Rules this project follows to keep results trustworthy, the repository safe and the model used responsibly. Where a rule is enforced in code, the file is named.

## 1. Data integrity (no leakage)

| Rule | Enforced by |
| --- | --- |
| Imputation statistics (medians, facility-type medians) are learned from training rows only and applied unchanged to held-out or test rows. | `src/preprocessData.m` (`fitImputer` / `applyImputer`) |
| During cross-validation, preprocessing and feature engineering are refit inside **every training fold**. | `src/trainModels.m` (`preparePredictors`) and `src/crossValidateModel.m` |
| Model selection uses leave-one-year-out CV, because the test set is a single unseen year. Random k-fold is reported only as evidence of its optimism. | `src/trainModels.m` |
| Feature engineering is row-wise and stateless, so it cannot leak across rows. | `src/engineerFeatures.m` |
| The training `id` column is dropped; it is a row counter with no signal. | `src/loadData.m` |
| Train and test must have identical predictor columns and category levels. | `assert`s in `loadData.m` and `preprocessData.m` |
| No missing values may remain after imputation. | `assert` in `preprocessData.m` |
| Runs are reproducible: one fixed seed at the top of the pipeline. | `rng(42, "twister")` in `main.m` |

## 2. Submission integrity

- Predictions must be finite. Energy use cannot be negative, so predictions are clamped at 0.
- `submission.csv` is read back from disk and must be exactly **9,705 rows × 2 columns** (`id`, `site_eui`).
- Submission ids must match `data/sample_solution.csv` exactly and in order.

Enforced by `src/writeSubmission.m` and `main.m`. A run that breaks any of these stops with an error instead of writing a bad file.

## 3. Robust execution

- Each candidate model is cross-validated inside `try/catch`. A failing candidate is reported and skipped, and the final refit falls back to the next-best model, so a valid submission is produced as long as one model succeeds.
- The final model is saved with `compact`, which strips the training data. The results file stays small, and `*.mat` is gitignored so nothing near GitHub's 100 MB file limit is committed.
- The report and figures load saved results and never retrain, so they cannot fail in the middle of a long run.

## 4. Security and supply chain

- **No secrets in the repository.** No API keys, passwords, tokens or MathWorks credentials in code, commits or notebooks. `.gitignore` excludes local clutter and generated binaries.
- **No third-party models or code in the ML pipeline.** We do not download pretrained models or scripts from GitHub or elsewhere. All modelling uses MATLAB and the Statistics and Machine Learning Toolbox from MathWorks. This avoids executing untrusted code and keeps the work our own.
- **One UI-only dependency, pinned.** The 3D simulator loads three.js **0.170.0** from jsDelivr through an import map with an exact version. It only draws the scene. The prediction code (`dashboard/predict.js`) has no dependencies, and the page still works if the CDN is unreachable.
- **The browser model is verified, not trusted.** `exportModelForWeb` refuses to write `model.js` unless its own tree walk equals MATLAB's `predict()`, and `tests/web/checkPredict.mjs` re-checks the JavaScript against MATLAB.
- **3D assets are AI-generated.** The Hive and The Arc models were generated with Meshy AI from images and are labelled as such in the simulator. The 245 MB original export is gitignored; only decimated copies are committed.
- **No network access at runtime.** The pipeline reads only the local `data/` folder and writes only to `results/`, `figures/` and `submission.csv`.
- **Read-only inputs.** Source CSVs are never modified.

## 5. Data licensing and privacy

- The data comes from the WiDS Datathon 2022 (Kaggle) and was provided by the organisers. It is committed so judges can run `main.m` immediately. Credit: WiDS Datathon 2022 / Climate Change AI.
- The data is anonymised (states and years are coded), and we make no attempt to re-identify buildings or locations.
- No additional external datasets are added.
- MathWorks starter material (`starter/`, plus the PDFs in `docs/hackathon/`) remains under its own license (`license.txt`).

## 6. Responsible use of predictions

- Retrofit Radar **flags buildings for inspection; it is not a verdict.** A building may use a lot of energy for legitimate reasons, such as a hospital, a lab or a data-heavy office.
- The expected EUI comes from out-of-fold predictions. Because the same building can appear in other training years, the excess shown is conservative.
- Reported accuracy is leave-one-year-out RMSE, the honest estimate for a new year, not the more flattering random-split number.

## 7. Working with AI assistants

AI coding assistants were used during development under these rules:

- **One editor at a time.** Never run two agents that edit the same files at once.
- **Verify by running.** AI-written code counts as done only after it runs in MATLAB and its outputs are checked.
- **Human review.** A team member reviews every commit. No force-pushes and no history rewrites on `main`.
- **No credentials to agents.** Assistants never receive passwords or tokens.
