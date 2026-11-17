# Methods notes

**This is a transparent reconstruction on independent synthetic data, not an exact historical replication.** Read the [source-page map](./PAPER_TO_CODE.md) alongside these notes. Reported article results remain reference-only; no new empirical claims about farmers are made.

## Scope and historical uncertainty

The source article is Iyioku, Gospel; Donkor, Ebenezer; Mazancova, Jana; Hejkrlik, Jiri (2024), *Understanding farmers' motivations for joining cashew marketing cooperatives in coastal Kenya: the moderating role of social capital*, *Cogent Food & Agriculture* 10(1), 2433600, DOI [10.1080/23311932.2024.2433600](https://doi.org/10.1080/23311932.2024.2433600).

The article reports EFA/refinement, CFA, validity checks, structural estimation, total effects, and a PLS robustness analysis. It also mixes terminology: §3.1 associates robust maximum likelihood with SmartPLS, whereas §3.2 names R/lavaan, §§3.3 and 4.3 discuss MLR, and §4.3 describes PLS as robustness. These passages do not uniquely establish a full historical software recipe.

For methodological clarity, this release specifies covariance-based CFA/SEM with **lavaan MLR** as its main reconstruction and a **separate SmartPLS PLS workflow** as robustness learning. The PLS algorithm and its bootstrap are not MLR, and the text's mixed labels should not be repeated as an estimator equivalence. SmartPLS software capabilities may evolve; the algorithm selected, rather than the application name alone, defines the analysis.

The publication's Table 6 includes standardized coefficients, parenthetical uncertainty, and T-values that do not always match arithmetically. Complete historical estimation and bootstrap settings are not given. Preserve the reported figures as reference material; do not silently repair them or infer unreported p-values or significance stars. This release does not declare the published results corrected or independently verified.

## Explicit reconstruction choices

These settings are choices for this executable example, **not assertions about undocumented historical settings**.

| Component | Reconstruction choice |
|---|---|
| Input | Independent synthetic sample, `n = 500`, seed `20250309`; 20 scores coded 1–5 |
| Measurement | Six reflective factors using exactly Table 2's retained item map |
| Main estimator | lavaan `MLR`; five-category scores treated as a continuous approximation |
| CFA factor relations | All six factors allowed to covary in the measurement-only model |
| Structural model | Exactly the 14 Table 6 regressions; no social-capital interaction |
| Indicator structure | Simple structure: no cross-loadings; distinct indicator residual covariances fixed to zero |
| Structural disturbances | Distinct endogenous disturbance covariances fixed to zero; no additional residual links |
| Scaling | `std.lv = TRUE`, rather than first-loading marker scaling; record the fitted parameterization |
| Missingness | Strictly complete synthetic input; missing values rejected, with no row deletion or imputation |
| Ordinal sensitivity | Separately labeled ordered-item WLSMV using the same item/edge registry |
| Exploratory analysis | Illustrative refinement logic; not recovery of the original discarded-item decisions |
| SmartPLS | Separate explicitly selected PLS algorithm and bootstrap; proposed settings documented in its guide |

With `std.lv = TRUE`, lavaan scales exogenous latent variables by their variances and endogenous latent variables by their residual variances. This is a model-identification convention; it does not imply that every fitted latent variable's total variance is one. Interpret fully standardized output separately from unstandardized coefficients.

The knowledge factor has only two indicators. Its identification depends on the broader measurement/structural model and imposed constraints; two indicators alone are not an automatic identification guarantee. Check identification, convergence, standard errors, residual variances, and admissibility. Freely correlating its indicator errors can undermine identification and is not part of this recipe.

The distributed synthetic input is complete, and the validator rejects missing values. The code does not silently discard rows or impute responses. A real study needs a separately justified missing-data policy and documented exclusions; neither complete-case analysis nor imputation is universally unbiased.

## Analysis sequence

### Exploration and refinement

Inspect coding, category frequencies, missingness, variance, and correlation structure before fitting. EFA explores whether indicators support a proposed structure; it does not confirm a theory. The article reports refinement and six-factor exploration (§§3.2–3.4), but the release cannot reconstruct the original larger item pool, every exclusion, or every analysis setting. An EFA on these already selected synthetic indicators is an educational demonstration, not independent validation or a historical rerun. Do not drop indicators merely to reproduce published loadings or stars.

### CFA, reliability, and validity

Fit the six-factor CFA first. Examine convergence and admissibility before fit indices: finite estimates and uncertainty, nonnegative residual variances, and plausible factor correlations matter. Inspect standardized loadings, uncertainty, residuals, and potential construct overlap. Do not modify residual correlations solely to obtain attractive fit.

Assess internal consistency together with measurement assumptions. Alpha is not proof of unidimensionality. For a standardized congeneric block with uncorrelated indicator errors, a commonly used composite-reliability expression is `(sum(lambda))^2 / ((sum(lambda))^2 + sum(theta))`, and AVE is `sum(lambda^2) / (sum(lambda^2) + sum(theta))`. State how loadings and residual variances were obtained. Do not copy a malformed printed formula or treat CFA-based reliability and PLS `rho_A` as automatically identical.

Examine AVE, factor correlations, and HTMT jointly. Conventional values such as reliability around 0.70, AVE around 0.50, and HTMT below 0.85 or 0.90 are interpretation aids, not universal proofs or automatic deletion rules. Discriminant validity does not require theoretically related constructs to have zero correlations. The two-item knowledge block deserves particular caution.

### Normality diagnostics and estimator choice

Use distributions and normality summaries diagnostically. Five-category items are discrete, so a normality-test rejection is not surprising and is not a universal test gate that selects the only valid estimator. Sample size, category use, skewness, measurement assumptions, and the intended estimand also matter.

The main MLR analysis uses a continuous-score approximation. In lavaan, MLR provides robust Huber–White standard errors and a scaled statistic asymptotically equivalent to Yuan–Bentler. It is **not interchangeable with `MLM`**, the lavaan option associated with a Satorra–Bentler scaled statistic. The article's wording should not erase that distinction. Robust inference does not fix misspecification or establish causality.

The ordered-item WLSMV sensitivity treats indicators as ordinal, estimates thresholds and an underlying-response model, and uses a different estimation/inference approach. It is not labeled the paper's historical primary estimator. Keep its fit and estimates separate from MLR; differences are sensitivity information, not evidence that one software package failed. Report the actual robust/scaled fit measures available from each model without mixing labels.

### Structural model and fit

After measurement assessment, fit the exact [14-edge model](./PAPER_TO_CODE.md#structural-registry-table-6). This graph is restricted: knowledge predicts moral and subjective norms; those constructs, knowledge, and attitude feed the later stages. In particular, moral and subjective norm disturbances are not freely correlated conditional on knowledge.

A six-factor covariance CFA freely estimates factor covariances; this SEM instead imposes structural restrictions. Their global fit need not coincide. In contrast, a generic five-predictor → intention model with all predictor covariances free can be covariance-saturated at the latent structural level and inherit its measurement-model fit. Do not apply that generic equivalence to this 14-edge graph, and do not confuse structural saturation with perfect item-level fit.

Report chi-square with its actual model degrees of freedom, CFI, TLI, RMSEA (with interval where available), and SRMR alongside diagnostics, not as a checklist proving truth. Do not treat the article's printed degrees-of-freedom or fit values as expected synthetic outputs. Fit cutoffs are heuristics; small p-values do not validate a substantive theory.

### Direct, indirect, and total effects

Table 6 supplies direct edges; Table 7 motivates total-effect reporting. Derive effects from the same fitted graph and coefficient scale. The [knowledge example](./PAPER_TO_CODE.md#effects-table-6-versus-table-7) lists all 11 indirect routes to intention. Total effect equals the direct coefficient plus every indirect path product, including serial chains through moral/subjective norms, attitude, and perceived control.

This implementation exports direct, indirect and total effects as point estimates only. It does not supply uncertainty intervals or significance claims for the indirect or total effects. Separate path-parameter tables provide scale-labelled standardized and unstandardized intervals. To add inference for indirect effects, account for joint parameter uncertainty with a justified delta-method or separately specified resampling procedure; robust MLR path inference is not a bootstrap. Never attach an unstandardized estimate's standard error or interval to a standardized coefficient.

These are model-implied associations. Without additional design and identification assumptions, cross-sectional SEM does not establish causal mediation or treatment effects.

### PLS robustness

Use the [SmartPLS guide](./SMARTPLS_PAPER_GUIDE.md) to estimate the same item map and 14 arrows with a different, explicitly selected estimator. Ordinary PLS targets composite-based relations. PLSc adds corrections under reflective common-factor assumptions; it is not automatically identical to lavaan MLR. Separate algorithm effects from sample and graph changes. Differences in paths, indirect effects, and uncertainty are reportable; matching stars are neither required nor a test of successful reproduction.

## Common-method-bias boundary

The article reports Harman's unrotated single-factor check (§3.5). Its reported first-factor share is a reference statement, not a synthetic target. A single-factor diagnostic can reveal concentration of item covariance, but a share below a conventional cutoff cannot establish absence of common-method bias. Measurement design, multiple methods/sources, temporal separation, and appropriately identified sensitivity models address different concerns. Do not equate a one-factor check, good CFA fit, or a significant path with proof that method effects are absent.

## What verification can establish

The entry point is `Rscript paper-example/run_paper_example.R`; the checks are `Rscript paper-example/checks.R`, both run from the repository root after `Rscript install_packages.R`. Keep data under `paper-example/data/` and outputs under `paper-example/outputs/`, or a separately specified `paper.output_dir`.

Execution can establish that code ran, files were produced, and specified behavioral checks passed. It cannot independently verify the original article without its original data and complete settings. Consult `../VERIFICATION.md` for the actual run record; these notes do not certify that tests or a SmartPLS run were performed.

## Licensing

Original explanatory documentation is MIT-licensed. Clearly attributed article-derived material retains CC BY 4.0; independently generated generic synthetic input and metadata are CC0. The reference PDF and reported tables are not relicensed by those root notices. See [reference attribution](../reference/README.md).

## Sources

- Iyioku et al. (2024), methods and results: https://doi.org/10.1080/23311932.2024.2433600
- lavaan estimators and robust variants: https://lavaan.ugent.be/tutorial/est.html
- lavaan categorical-data handling: https://lavaan.ugent.be/tutorial/cat.html
- SmartPLS PLS algorithm: https://smartpls.com/documentation/algorithms-and-techniques/core-algorithm/pls/
- SmartPLS consistent PLS: https://smartpls.com/documentation/algorithms-and-techniques/core-algorithm/consistent-pls/
