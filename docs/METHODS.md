# Methods and interpretation

**Scope:** the specification on this page is the generic 22-item teaching model, not the paper's final model. The separate [paper-to-code map](../paper-example/docs/PAPER_TO_CODE.md) explains the article's 20 indicators and 14 directed paths. The [paper-specific methods notes](../paper-example/docs/METHODS_NOTES.md) distinguish reported information, reproducible reconstruction choices and unresolved historical details. The article is a worked reference, not a numerical target for simulation.
## Purpose and limits

This is an **educational synthetic example, not a replication of a published paper**. It demonstrates a transparent analysis workflow and a model specification. No questionnaire wording, published numerical results, or complete paper-specific estimation settings are available. Similar construct labels do not establish identical measures, samples, identification choices, or analyses. Reproducing this example cannot establish equivalence to published results.

The synthetic observations are independently simulated. Any fitted coefficients, fit indices, reliability estimates, or descriptive summaries describe the simulation only. They provide no evidence about people, populations, or substantive hypotheses.

## Canonical model

The model has six reflectively measured constructs and 22 indicators. The labels describe conceptual roles, not validated questionnaire content.

| Construct | Conceptual label | Indicators |
| --- | --- | --- |
| ATT | Attitude | ATT_1, ATT_2, ATT_3 |
| PBC | Perceived behavioral control | PBC_1, PBC_2, PBC_3, PBC_4 |
| INT | Intention | INT_1, INT_2, INT_3, INT_4, INT_5, INT_6 |
| SUB_NORM | Subjective norm | SUB_NORM_1, SUB_NORM_2, SUB_NORM_3 |
| KNOWLEDGE | Knowledge | KNOWLEDGE_1, KNOWLEDGE_2, KNOWLEDGE_3 |
| MORAL_NORM | Moral norm | MORAL_NORM_1, MORAL_NORM_2, MORAL_NORM_3 |

Knowledge and moral norm are **extensions**, not original Theory of Planned Behavior components. This example models intention, not an observed behavior outcome; it is not a complete test of the original theory. All five other constructs predict INT simultaneously.

```r
ATT =~ ATT_1 + ATT_2 + ATT_3
PBC =~ PBC_1 + PBC_2 + PBC_3 + PBC_4
INT =~ INT_1 + INT_2 + INT_3 + INT_4 + INT_5 + INT_6
SUB_NORM =~ SUB_NORM_1 + SUB_NORM_2 + SUB_NORM_3
KNOWLEDGE =~ KNOWLEDGE_1 + KNOWLEDGE_2 + KNOWLEDGE_3
MORAL_NORM =~ MORAL_NORM_1 + MORAL_NORM_2 + MORAL_NORM_3
INT ~ ATT + PBC + SUB_NORM + KNOWLEDGE + MORAL_NORM
```

Reflective measurement means the latent construct is specified as explaining variation in its indicators. It is not evidence that these unnamed items truly have that interpretation. No question wording was supplied, and **no reverse coding is inferred** from a column name or loading sign. Substantive reuse requires the actual questionnaire, scale anchors, permissions, and a documented scoring key.

## Measurement before structure

1. Validate indicator names, numeric categories, allowed ranges, missingness, and category frequencies.
2. Fit the correlated six-factor CFA before interpreting structural paths. In the CFA, factors may covary; the SEM explains INT through five predictors and permits predictor covariances.
3. Check convergence, warnings, identification, standard errors, factor correlations, residual variances, loadings, and residual patterns. A numerical solution with inadmissible estimates is not acceptable.
4. Review global fit and local diagnostics together. Report whether statistics are conventional, scaled, or robust; do not silently mix versions.
5. Only then inspect structural estimates, intervals, collinearity, and explained variance.

With five freely correlated predictors and all five paths into INT, the latent structural part is covariance-saturated. The correlated-factor CFA and full SEM can therefore have identical global fit: they re-express the same latent covariance structure. Fit chiefly evaluates measurement restrictions here; it does not establish arrow direction or causal theory. Identical fit is not a software error.

CFI, TLI, RMSEA with its interval, SRMR, and the model test describe different aspects of fit. Cutoffs are contextual heuristics, not universal rules. TLI may exceed one in a well-fitting sample; preserve the returned value and explain its convention rather than silently capping it. A good fit does not prove a model true. Poor fit requires investigation, not searching for a favorable estimator.

Do not automatically delete indicators to improve loadings or fit. Investigate coding, content coverage, uncertainty, and assumptions. Modification indices suggest statistical changes, not theory. Label defensible revisions as exploratory, preserve the original specification, and evaluate independently where possible.
## Estimation plan

| Analysis | Treatment | Interpretation |
| --- | --- | --- |
| Main CFA and SEM | Ordered indicators, WLSMV | Primary ordinal common-factor demonstration |
| Continuous sensitivity | Numeric scores treated as continuous, MLR | Assesses sensitivity to a different measurement approximation |
| Omit moral norm sensitivity | Remove its factor, indicators, and incoming path to INT | Assesses dependence on one extension |
| Optional EFA | Exploratory measurement investigation | Not independent confirmation on the same observations |
| Optional common latent factor | Explicit extra method-factor assumptions | Sensitivity exercise, not a diagnosis of bias |

With `ordered` indicators, lavaan's WLSMV uses diagonally weighted least squares for parameter estimation and the full weight matrix for robust standard errors and the mean- and variance-adjusted model test. Declare the indicators and estimator explicitly so the intended analysis is auditable.

MLR uses robust standard errors and a scaled test statistic while treating the scores as continuous. It does not make ordinal data continuous or recover information lost by discretization. Compare estimates and their uncertainty with the ordinal results; discrepancies are findings about assumptions, not a license to select favorable significance levels.

Missing-data treatment must be stated separately from estimator choice. lavaan does not support full-information maximum likelihood for ordered WLSMV indicators. MLR can support full-information ML for incomplete continuous data when explicitly requested and justified. Do not assume an estimator automatically selects the correct missingness mechanism or policy. The scripts are the authority for the implemented policy; changing it changes the analysis.

Identification requires an explicit factor scale, such as fixing a loading or standardizing a latent variance. Record the script's choice. Changes in scaling can change unstandardized estimates without changing the substantive model. Compare like-for-like standardized or unstandardized parameters and document conventions.

## Sensitivities

### Omit moral norm

Remove `MORAL_NORM =~ ...`, remove `MORAL_NORM` from the INT regression, and exclude `MORAL_NORM_1` through `MORAL_NORM_3` from that analysis. Retain KNOWLEDGE as an extension and keep all remaining indicator assignments unchanged. This is not an original-theory-only model. Keep the full-model results separate.

Compare remaining paths, uncertainty, factor diagnostics, and INT explained variance. The indicator set has changed: do not subtract the two global chi-square statistics as if this were automatically a valid nested-model test. Information criteria from different observed-variable sets or estimation frameworks are not a simple model-selection contest. Any formal comparison requires an appropriate common-data specification and justified test.

### Exploratory factor analysis

EFA can examine how indicators cluster without fixing the entire CFA loading pattern. For ordinal items, consider ordinal-appropriate correlations and extraction; justify factor retention using multiple sources such as parallel analysis, interpretability, and theory. An oblique rotation allows related constructs. PCA is a data-reduction procedure, not the same as a common-factor model.

A one-factor or Harman screening analysis cannot prove the absence of common-method bias, regardless of a variance-percentage cutoff. A low first-factor share is not evidence that all method effects are negligible. Reusing the same observations for discovery and confirmation must be disclosed.

### Common latent factor

A common latent factor adds a shared factor across indicators while retaining their substantive factors. It is assumption-heavy and can be weakly identified, unstable, or confounded with substantive overlap. A large change in loadings is not a calibrated bias estimate; a small change is not proof of no bias.

If the intended method factor is orthogonal to substantive factors, every required method-to-trait covariance must be explicitly fixed to zero, for example `METHOD ~~ 0*ATT`, with the corresponding restriction for every other substantive factor. **Orthogonality is not lavaan's default** for a newly added factor. Also document factor scaling, any equal-loading constraints, residual assumptions, estimator, identification checks, and convergence. The exact covariance restrictions require care in a structural model containing an endogenous factor. Never silently treat an inadmissible method-factor solution as a valid comparison.

## CB-SEM and PLS-SEM are different workflows

The R main analysis is covariance-based ordinal common-factor SEM. Ordinary PLS-SEM estimates weighted construct scores and relationships between composites. PLSc corrects reflective-construct correlations toward common-factor consistency, but does not make SmartPLS output identical to lavaan WLSMV. Objectives, ordinal treatment, scaling, uncertainty estimation, and fit measures can differ.

Report which estimator and algorithm were actually run. Do not equate PLS fit displays with global CB-SEM fit or infer replication from similar path signs. See [the SmartPLS guide](SMARTPLS_GUIDE.md) for a separate manual learning workflow. SmartPLS has not been executed as part of preparing these instructions.

## Reporting checklist

- Label all output as synthetic educational output.
- State indicator mapping, model version, factor scaling, estimator, missing-data treatment, and any deviations.
- Report convergence and inadmissibility before numerical interpretation.
- Inspect CFA evidence before structural inference; retain the complete planned model.
- Report estimates with uncertainty, not significance alone.
- Distinguish in-sample explanation from held-out prediction.
- Make no causal claims: arrows encode modeling assumptions, not an identified intervention effect.
- Record software/package versions, random seeds, and sanitized provenance without identities or machine paths.
- State which optional procedures were not run and which paper-specific details remain unavailable.

## Sources

- [lavaan: Categorical data](https://lavaan.ugent.be/tutorial/cat.html)
- [lavaan: Estimators and more](https://lavaan.ugent.be/tutorial/est.html)
- [SmartPLS: Consistent PLS-SEM](https://smartpls.com/documentation/algorithms-and-techniques/core-algorithm/consistent-pls/)
- [SmartPLS: PLS-SEM algorithm](https://smartpls.com/documentation/algorithms-and-techniques/core-algorithm/pls/)
