# Hackathon execution and definition of done

Deadline supplied in the briefing: **30 October 2026, 4:00 PM,
Asia/Kuala_Lumpur**. The team has three members: Rohit, Matt, and Shuan.
This schedule is a proposed team plan, not an automated reminder or submission.

## Ownership

| Owner | Scope | Handoff evidence |
| --- | --- | --- |
| Rohit | Architecture, interfaces, pipeline integration, final fit/export, GitHub publishing | Clean run, saved bundle, validated submission, pushed code |
| Matt | Dictionary audit, missingness, feature hypotheses, model comparisons, independent clean-run and CSV checks | Data audit, experiment log, random/temporal metrics, verification results |
| Shuan | Glassmorphism slides, narrative, demo recording, Devpost packaging and public-link checks | Deck/PDF, timed demo under five minutes, reviewed submission links |

These are human team assignments, not messages sent to members or delegated agent
tasks. Developers should read pipeline.md and architecture.md before parallel work.

## Suggested cutoffs

| By local time | Deliverable |
| --- | --- |
| 12:15 PM | Ingestion checked; dictionary unknowns logged; preprocessing contracts agreed |
| 1:00 PM | Mean/tree baseline; first valid export; missingness charts |
| 2:00 PM | Bag and LSBoost five-fold results; temporal check; slide draft |
| 2:45 PM | Freeze features and candidate selection; stop broad tuning |
| 3:15 PM | Full-data refit, bundle reload, final CSV checks; charts handed to Shuan |
| 3:30 PM | Clean-session verification, public repository, demo rehearsal |
| 3:45 PM | Devpost fields and links reviewed; submit with buffer |
| 4:00 PM | Organizer deadline |

If a cutoff has passed, prioritize an honest complete baseline over unfinished
tuning. Keep the best validated export and bundle while evaluating improvements.

## Rubric-to-evidence mapping

| Criterion | Points | Evidence to provide |
| --- | --- | --- |
| Data mastery | 20 | Missingness/sentinel audit, category policy, year shift and fold-local cleaning |
| Use of ML | 20 | Baselines, ensemble comparison, original-scale OOF RMSE, temporal check, ablations |
| Functionality | 10 | Clean run, serialization check, compliant CSV |
| MATLAB proficiency | 10 | Tables, categorical predictors, fillmissing, cvpartition, native estimators |
| Readability | 10 | Small documented functions, config, reproducible commands |
| Presentation creativity | 10 | Coherent glassmorphism visual story and meaningful visuals |
| Presentation quality | 10 | Legible charts, polished delivery, backup demo |
| Presentation concept | 10 | Clear problem, supported claims, limitations and practical relevance |

## Release and submission review

- Code and documentation are pushed to the intended GitHub repository.
- README identifies what runs now and what remains planned.
- Actual metrics, parameters and data fingerprints accompany the selected model.
- Final predictions align exactly to test IDs and the sample template.
- The public code link works in a signed-out browser or is otherwise confirmed public.
- Demo and code links are present in the Devpost project; one submission per team.
- Required files are accessible; no claim implies causation or measured energy savings.
- A teammate verifies the final organizer confirmation before the deadline.

The user's request authorizes pushing this documentation to GitHub. Creating or
submitting the Devpost entry is a separate team action and is not performed by
this documentation handoff.
