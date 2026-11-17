# SmartPLS paper-model guide

This manual learning workflow uses the paper example's **20 indicators and all 14 Table 6 arrows**. It is separate from the root tutorial's five-direct-path example and from the main covariance-based lavaan MLR analysis. No SmartPLS project execution is certified by this guide.

Reference: Iyioku, Gospel; Donkor, Ebenezer; Mazancova, Jana; Hejkrlik, Jiri (2024). Understanding farmers' motivations for joining cashew marketing cooperatives in coastal Kenya: the moderating role of social capital. *Cogent Food & Agriculture* 10(1), 2433600. DOI [10.1080/23311932.2024.2433600](https://doi.org/10.1080/23311932.2024.2433600). The article motivates a separate PLS robustness analysis (§4.3, PDF pp. 15–16); the settings proposed below are not recovered historical settings.

## 1. Prepare the synthetic input

From the repository root, install dependencies and run:

```sh
Rscript install_packages.R
Rscript paper-example/run_paper_example.R
```

Import `paper-example/data/synthetic_paper_tpb.csv` into a new SmartPLS project. Use its dictionary and provenance in `paper-example/data/`. Expect 500 independent synthetic cases, seed `20250309`, and exactly 20 indicator columns coded as integers 1–5. Verify the delimiter, header row, numeric coding, category frequencies, and absence of missing-value sentinel codes. Do not import the root `data/synthetic_tpb.csv`, reported path CSV, demographic records, or the PDF as data.

This example uses complete cases without imputation. The distributed synthetic input is complete. If using a private replacement dataset, explicitly reconcile the row set with R before comparing estimates; do not accept silent mean replacement or silently compare different samples.

## 2. Build six reflective measurement blocks

Create these construct names exactly and assign only the listed indicators. Draw reflective measurement arrows from each construct to its indicators. Do not add cross-loadings or residual correlations.

| Construct | Indicators | Count |
|---|---|---|
| ATT | `ATT_1`, `ATT_2`, `ATT_3`, `ATT_4` | 4 |
| INT | `INT_1`, `INT_2`, `INT_3` | 3 |
| SUB_NORM | `SUB_NORM_1`, `SUB_NORM_2`, `SUB_NORM_3` | 3 |
| PBC | `PBC_1`, `PBC_2`, `PBC_3`, `PBC_4` | 4 |
| MORAL_NORM | `MORAL_NORM_1`, `MORAL_NORM_2`, `MORAL_NORM_3`, `MORAL_NORM_4` | 4 |
| KNOWLEDGE | `KNOWLEDGE_1`, `KNOWLEDGE_2` | 2 |

The [paper-to-code map](./PAPER_TO_CODE.md) gives short attributed descriptions from Table 2, PDF p. 11. It is not a full questionnaire. The two-indicator knowledge factor deserves careful reliability and construct-validity assessment; software returning a score does not establish CB-SEM identification or substantive validity.

## 3. Draw all 14 structural arrows

Count the arrows before running the algorithm. These are Table 6 row numbers (PDF p. 16), not invented hypothesis labels.

| Table 6 row | Draw this arrow |
|---|---|
| 1 | ATT → INT |
| 2 | MORAL_NORM → INT |
| 3 | SUB_NORM → INT |
| 4 | PBC → INT |
| 5 | KNOWLEDGE → INT |
| 6 | ATT → PBC |
| 7 | KNOWLEDGE → PBC |
| 8 | MORAL_NORM → PBC |
| 9 | SUB_NORM → PBC |
| 10 | KNOWLEDGE → ATT |
| 11 | MORAL_NORM → ATT |
| 12 | SUB_NORM → ATT |
| 13 | KNOWLEDGE → MORAL_NORM |
| 14 | KNOWLEDGE → SUB_NORM |

A convenient left-to-right layout is knowledge → moral/subjective norms → attitude → perceived control → intention, with all additional direct arrows above retained. Layout does not change the registry. Do not add a moral-to-subjective arrow, reciprocal relationships, or a social-capital interaction. Bonding/bridging descriptions in the article do not specify a statistical moderator in the presented SEM. There is no interaction-term step in this guide.

## 4. Choose and record the algorithm

**Proposed baseline: ordinary PLS-SEM**, reflective Mode A blocks, path weighting, standardized results, and standard positive initial outer weights. This gives a clearly named composite-based robustness exercise. Record the SmartPLS version, selected settings, convergence report, and any sign-orientation settings. Menu names vary by version; select the PLS algorithm rather than assuming any procedure called SEM implements MLR.

**Optional separate sensitivity: PLSc.** Choose consistent PLS only when the reflective common-factor interpretation and its assumptions are justified. Save it as a distinctly labeled analysis with its own exports. Record the initial-calculation setting, including whether all constructs were connected internally for initial score calculation; that setting does not authorize adding new substantive structural arrows to the reported 14-edge model. Use the corresponding consistent bootstrap procedure for PLSc.

Ordinary PLS and PLSc are alternative algorithm choices, not interchangeable labels. Neither reproduces lavaan MLR or ordered-item WLSMV. The article's mixture of software/estimator wording does not establish that MLR was run through a PLS algorithm.

Use the convergence controls exposed by your installed version and record them. The current official SmartPLS 4 documentation describes fixed controls of 3,000 iterations and a `10^-7` stopping criterion; verify the algorithm met its convergence criterion rather than exhausting iterations. Do not invent historical control settings or claim a GUI option exists in every version.

## 5. Assess measurement and structural quality

Before interpreting paths, inspect:

- Outer loadings, their signs and uncertainty, and whether each item belongs to its intended block. Loadings around 0.70 are a conventional guide, not an automatic rule for dropping Table 2 indicators.
- Alpha, `rho_A`, composite reliability, and AVE together. Reliability around 0.70 and AVE around 0.50 are common reference values, not proof of validity. Very high reliability can reflect redundant content.
- HTMT for every construct pair, with bootstrap intervals where available. Interpret conventional 0.85/0.90 thresholds in context and inspect overlap rather than changing the model until a color turns favorable.
- Inner VIF for each predictor set: the five predictors of INT, four of PBC, and three of ATT. Report collinearity diagnostics; VIF values around 3 or 5 are contextual warning guides, not universal validity gates.
- R-squared for each endogenous construct, path signs and magnitudes, and effect sizes where reported. Apparent predictive performance on the fitted sample is not out-of-sample prediction evidence.

PLS fit diagnostics do not have automatic equivalence to CB-SEM CFA/SEM chi-square, CFI, TLI, or RMSEA. Do not compare identically named outputs without checking their definitions. Do not change indicators or paths to chase the article's reference coefficients.

## 6. Bootstrap the selected model

The following are **proposed reproducibility settings**, not the paper's reported historical settings:

| Setting | Proposed choice |
|---|---|
| Resamples | 10,000 case-resampling bootstrap samples |
| Resample size | Same number of cases as the analysis sample |
| Test | Two-tailed |
| Confidence level | 95% |
| Interval method | Percentile |
| Randomness | Fixed seed `20250309`, where supported |
| Algorithm | Same explicitly selected PLS or PLSc procedure as the point estimates |

Record actual settings and any failed or inadmissible resamples. A software version without a fixed-seed option must be disclosed; do not promise bitwise reproducibility across versions or platforms. A smaller pilot bootstrap can diagnose a setup problem, but label it preliminary and do not substitute it for the stated final settings.

Export point estimates, bootstrap standard errors, intervals, T-values, and p-values actually supplied by the run. For a two-sided test against zero, inspect whether the interval includes zero; do not compare the point estimate to its own interval to decide significance. Never transfer the publication's stars onto synthetic output or recompute stars in the reference CSV.

## 7. Inspect indirect and total effects

Request specific indirect effects, total indirect effects, and total effects, not only the five paths into INT. A serial route such as `KNOWLEDGE → MORAL_NORM → ATT → PBC → INT` contributes the product of all four path coefficients.

The graph contains 11 indirect routes from KNOWLEDGE to INT through moral norm, subjective norm, attitude, and/or perceived control. Their sum is the total indirect effect; adding `KNOWLEDGE → INT` gives the total effect. See the [full route list and equation](./PAPER_TO_CODE.md#effects-table-6-versus-table-7). Use bootstrap inference for the indirect-effect statistic itself, not products of individual-path p-values. Do not treat a nonsignificant component or a significant total effect as proof of causal mediation.

Table 6 gives direct edges and Table 7 gives reported totals. The publication's rounded or inconsistent numerical entries are not a checksum for your synthetic decomposition.

## 8. Compare transparently and save separately

Keep manual SmartPLS exports separate, for example under `paper-example/outputs/smartpls/`, without overwriting R results or the reference CSV. Record the input provenance, actual sample, algorithm, reflective measurement specification, 14-arrow registry, standardization, bootstrap settings, software version, convergence, and limitations with the exports.

Compare with R only after confirming the same cases, columns, and directed graph. Report differences in estimator targets and uncertainty procedures before comparing signs or effect rankings. Agreement is not independent verification of the article; disagreement does not itself correct the article. This release makes no new farmer-population claims.

No account-specific path, screenshot, login instruction, or completed SmartPLS run is implied here. The repository's verification record should distinguish actual R execution from unperformed manual SmartPLS steps.

## Licensing

Original guide text is MIT-licensed except clearly attributed article material, which retains CC BY 4.0. The independent generic synthetic input and metadata are CC0; the reference article and its reported tables are not. See [reference attribution](../reference/README.md).

## Sources

- Iyioku et al. (2024), Tables 2, 6, 7 and §4.3: https://doi.org/10.1080/23311932.2024.2433600
- SmartPLS PLS algorithm: https://smartpls.com/documentation/algorithms-and-techniques/core-algorithm/pls/
- SmartPLS consistent PLS: https://smartpls.com/documentation/algorithms-and-techniques/core-algorithm/consistent-pls/
- SmartPLS bootstrapping: https://smartpls.com/documentation/algorithms-and-techniques/resampling-and-inference/bootstrapping/
