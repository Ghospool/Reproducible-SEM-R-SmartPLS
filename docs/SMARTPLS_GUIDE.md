# SmartPLS 4 learning guide

**Scope:** this walkthrough uses the generic 22-item, five-path example. For the paper's 20-item, 14-path model, use the separate [paper-specific SmartPLS guide](../paper-example/docs/SMARTPLS_PAPER_GUIDE.md). Do not mix indicator mappings or describe either manual walkthrough as an executed SmartPLS replication.
## What this guide does

This is a manual **educational synthetic example, not paper replication**. SmartPLS was not run here, and no SmartPLS results or project execution are claimed. Menu wording may vary across current v4 builds; record the exact installed version and the labels you actually see. A software license may be required.

The R workflow uses ordinal covariance-based SEM. This guide demonstrates a separate PLS-SEM workflow. SmartPLS 4 also offers other analysis families; choose a PLS-SEM model for these steps, not a CB-SEM/CFA model simply because those menu options are available.

## 1. Import the synthetic CSV

1. Use a clean copy of the public package. Locate `data/synthetic_tpb.csv` and `data/data_dictionary.csv`.
2. Start SmartPLS 4 and create a new, neutrally named project. Use the project's import-data action to select `synthetic_tpb.csv`.
3. Select comma as the delimiter and the first row as variable names. Inspect the preview before confirming. If the columns appear collapsed into one field, correct the delimiter rather than editing the data by hand.
4. Confirm every indicator is numeric, with the ordered integer codes and allowed range described in the dictionary. Reject text conversion problems, decimal-separator errors, or unexpected missing values. Numeric storage does not imply an interval scale.
5. Import only the synthetic indicator file. Do not append identifiers, demographics, questionnaire text, real observations, or private metadata. Do not assign the dictionary itself as an observation dataset.
6. Record missing-value codes and the selected missing-data handling. Zero must not silently become missing or a response category unless the dictionary says so. Do not invent a missing-value code for a complete synthetic file.

Save a neutral local project copy. Before sharing it, inspect embedded data, dataset labels, comments, export paths, and other metadata. A project file can disclose more than a screenshot.

## 2. Build and audit the model

Create six constructs and assign the indicators exactly as follows. Dragging selected indicators to a model canvas can create an indicator block; alternatively create the construct first and assign indicators through the available editor controls. Check the result rather than relying on a drag gesture alone.

| Construct | Reflective indicators |
| --- | --- |
| ATT | ATT_1, ATT_2, ATT_3 |
| PBC | PBC_1, PBC_2, PBC_3, PBC_4 |
| INT | INT_1, INT_2, INT_3, INT_4, INT_5, INT_6 |
| SUB_NORM | SUB_NORM_1, SUB_NORM_2, SUB_NORM_3 |
| KNOWLEDGE | KNOWLEDGE_1, KNOWLEDGE_2, KNOWLEDGE_3 |
| MORAL_NORM | MORAL_NORM_1, MORAL_NORM_2, MORAL_NORM_3 |

Set every measurement block to **reflective**, with arrows from construct to indicator; check the applicable Mode A setting. Do not reverse the arrows into a formative specification. The model has 22 indicators, each assigned once. No item wording was provided and no reverse coding is inferred. KNOWLEDGE and MORAL_NORM are extensions, not original Theory of Planned Behavior components.

Draw these five structural arrows, all pointing into INT:

```text
ATT        -> INT
PBC        -> INT
SUB_NORM   -> INT
KNOWLEDGE  -> INT
MORAL_NORM -> INT
```

Do not add reciprocal arrows, mediation, behavior outcomes, or extra paths. Save a full-model copy before running a sensitivity. These arrows are assumed conditional relationships, not proof of causation.

## 3. Choose ordinary PLS or PLSc deliberately

- **Ordinary PLS-SEM** estimates weighted composites and their relationships. Use it when the analysis target is explicitly composite-based. Reflective arrow direction alone does not make ordinary PLS a covariance-based common-factor estimator.
- **PLSc** applies a consistency correction to reflective-construct correlations for a common-factor interpretation. Because this example is reflectively specified, PLSc is a useful explicitly labeled learning comparison. It is not automatically interchangeable with ordinary PLS or with ordinal WLSMV.

Record the chosen algorithm before examining results. For PLSc, record the initial-calculations option, including whether all latent variables are connected for initial score estimation. Such an internal initialization choice is not permission to change the hypothesized structural graph. If you run both algorithms, preserve separate results and use the matching consistent bootstrap for PLSc. Never select a method because it gives a preferred p-value.

## 4. Run the algorithm and record settings

Open the calculation dialog for the selected PLS or consistent PLS algorithm. Review the settings and run it. Inspect convergence before interpretation.

| Setting | Official current v4 documentation | Proposed practice for this example |
| --- | --- | --- |
| Weighting scheme | Path weighting is documented as default | Retain path weighting and record it |
| Type of results | Standardized is documented as default | Retain standardized and label coefficients |
| Initial outer weights | Standard +1 is documented as default | Retain unless a justified change is recorded |
| Maximum iterations | Documented as fixed at 3,000 in v4 | Record displayed behavior; do not seek an obsolete v3 control |
| Stop criterion | Documented as fixed at 10^-7 in v4 | Confirm convergence rather than merely reaching the iteration limit |
| Missing-data handling | Inspect the installed dialog | Record the actual policy; do not assume a universal default |
| Algorithm family | Ordinary PLS and PLSc are different choices | Record choice and, for PLSc, initialization |

These are documentation-based descriptions, not settings verified by executing SmartPLS here. If a newer build differs, record the build and its actual settings. Save a sanitized settings record or cropped screenshot without account names, file locations, or unrelated windows.

## 5. Evaluate measurement first

In the results' quality-criteria and measurement sections, review the following before structural paths.

| Evidence | What to inspect | Interpretation caution |
| --- | --- | --- |
| Outer loadings | Magnitude, sign, uncertainty, unexpected pattern | Around .70 is a common heuristic, not an automatic deletion rule |
| Reliability | Alpha, rho_A, composite reliability where available | High values alone do not prove validity; extreme values may signal redundancy |
| Convergent validity | Average variance extracted (AVE) | .50 is a common reference, not a substitute for content evidence |
| Discriminant validity | HTMT for every construct pair | .85 or .90 are contextual reference choices; justify the chosen criterion |
| Collinearity | Relevant VIF tables and their model location | Distinguish inner predictor VIF from indicator VIF; do not apply formative rules blindly |

Retain all planned indicators unless a theoretically justified, transparently reported revision is necessary. Do not repeatedly drop indicators until report colors turn green. Without item wording, content validity and reverse-keying cannot be established.

The official HTMT page describes absolute-correlation-based computation in current SmartPLS and a separate one-sided HTMT inference procedure. The two-sided percentile path-bootstrap plan below is not automatically that one-sided HTMT test. If formal HTMT inference is desired, run and label a separate procedure using the documented result scope, test direction, interval method, and justified upper-bound criterion. Do not silently change the path-testing plan to obtain it.

## 6. Bootstrap with an explicit plan

Use Calculate > Bootstrapping, or the matching consistent-bootstrap action for PLSc. These are **proposed settings for this example**, not claims about every installed default:

- Subsamples: **10,000**.
- Seed: choose a fixed seed if the installed version provides the option; use `20250301` for this tutorial and record it. This is a proposed tutorial seed, not a paper setting or a required match to the R simulation seed.
- Test type: two-tailed.
- Significance level: .05.
- Confidence interval: percentile, 95%.
- Result scope: include all results needed for loadings, paths, and requested quality criteria; record the chosen scope.
- Sign handling: record the exact sign-change/alignment option if exposed, or state that it was not exposed in the installed build. Do not invent a setting name or assume a hidden default.
- Record parallel-processing and missing-data options and any failed or inadmissible bootstrap solutions.

Official documentation currently lists 10,000 subsamples and percentile intervals as defaults. The two-tailed test, alpha level, tutorial seed, and recording plan above are deliberate proposed choices. Confirm all dialog values instead of assuming defaults. If fixed seeds are unavailable, state that limitation and retain the outputs; do not promise exact bootstrap reproducibility.

Read the interval for each path. For a two-sided 95% interval for a coefficient, exclusion of **zero** supports a nonzero association under the model and resampling assumptions. Do not compare the original point estimate with its own interval as a significance rule. A bootstrap does not correct poor measurement, confounding, selection, or invalid observational independence.

## 7. Evaluate the structural and prediction results

- **Inner VIF:** inspect collinearity among the five INT predictors before interpreting their partial effects. Values near common reference levels such as 3 or 5 warrant context-specific investigation, not mechanical acceptance or rejection.
- **Paths and intervals:** report direction, standardized magnitude, interval, and uncertainty. A nonsignificant path does not demonstrate that an association is exactly zero.
- **R2 and adjusted R2:** describe in-sample explained variance in INT, not causal explanatory power or future predictive accuracy.
- **f2:** inspect each predictor's incremental contribution. The usual formula is `(R2_included - R2_excluded) / (1 - R2_included)` for a comparable omitted-predictor calculation. Context matters more than labeling small/medium/large bins. Distinguish this from deleting a factor and changing the full measurement system.
- **PLSpredict:** if available for the chosen workflow, run the prediction procedure separately. Record folds, repetitions, seed availability, prediction targets, error metric, and benchmark. Current documentation lists 10 folds and 10 repetitions as defaults; check feasibility and retain the actual choices.
- **Held-out performance:** inspect indicator-level Q2_predict and RMSE or MAE against the mean-based benchmark and, where reported, the linear-model benchmark. Beating the mean alone is not evidence of outperforming the stronger benchmark. Choose the error criterion with a reason, not after searching for a favorable result.

Cross-validation within independently simulated observations demonstrates mechanics, not real-world external validity. Reusing holdout results to tune indicators or paths compromises the holdout assessment. If PLSpredict is not supported for a chosen algorithm/build, report that limitation rather than substituting in-sample R2 or blindfolding as if they were equivalent out-of-sample validation.

PLS model-fit displays are not interchangeable with global covariance-based CFA/SEM fit. Do not import lavaan cutoff rules wholesale, describe a single PLS index as proof of model validity, or claim numerical equivalence between the two programs.

## 8. Omit moral norm sensitivity

1. Duplicate the full model locally under a neutral sensitivity label.
2. Remove the MORAL_NORM construct, its three indicators, and its arrow to INT from this duplicate. The underlying CSV can retain those columns, but they must not be assigned in this reduced model.
3. Retain ATT, PBC, SUB_NORM, KNOWLEDGE, INT, and their original indicators and four paths into INT. KNOWLEDGE remains an extension.
4. Use the same algorithm family and recorded settings. Re-run the algorithm and matching bootstrap rather than editing full-model tables.
5. Compare remaining paths, intervals, measurement diagnostics, and INT R2; label the changed measurement system. Do not claim a causal effect of removing moral norm or treat this as a generic nested CB-SEM chi-square test.

## 9. Save a transparent record

Export measurement tables, HTMT, VIF, paths and intervals, R2, f2, and any prediction outputs actually produced. Keep full and reduced models and ordinary PLS/PLSc outputs separate. Record software version, synthetic dataset identity, indicator map, all selected options, bootstrap settings, and deviations. Sanitize project metadata and exports before sharing; no SmartPLS output is prevalidated by this guide.

## Sources

- [SmartPLS: PLS-SEM algorithm and current v4 settings](https://smartpls.com/documentation/algorithms-and-techniques/core-algorithm/pls/)
- [SmartPLS: Consistent PLS-SEM](https://smartpls.com/documentation/algorithms-and-techniques/core-algorithm/consistent-pls/)
- [SmartPLS: Bootstrapping](https://smartpls.com/documentation/algorithms-and-techniques/resampling-and-inference/bootstrapping/)
- [SmartPLS: Discriminant validity and HTMT](https://smartpls.com/documentation/algorithms-and-techniques/validity-and-model-fit/discriminant-validity-assessment/)
- [SmartPLS: PLSpredict](https://smartpls.com/documentation/algorithms-and-techniques/prediction-and-segmentation/predict/)
- [SmartPLS: Result thresholds and their interpretation](https://smartpls.com/documentation/functionalities/thresholds/)
