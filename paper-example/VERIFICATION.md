# Paper-example verification

## Verdict and scope

**The paper-linked R example and its behavioral checks passed in the tested environment.** Two independent command-line runs produced 35 byte-identical reference output files: 33 CSV tables and two lavaan model-specification files.

These checks validate an executable teaching reconstruction of the paper's measurement assignments and directed graph. They do not establish numerical replication, independently verify the published findings, or reconstruct unreported historical settings. All fitted results use independent synthetic observations. Published numbers are separately attributed reference values.

## Tested environment

| Component | Version |
|---|---|
| Operating system | Windows |
| R | 4.6.1 |
| lavaan | 0.7.3 |
| semTools | 0.5.10 |
| psych | 2.6.9 |

The existing root installer supplied the same three packages in an isolated user library. No new package dependency was needed. Other operating systems and package versions were not tested; the version table is not an environment lockfile. RStudio GUI interaction, SmartPLS execution and mutation testing were not performed.

## Executed checks

| Check | Result |
|---|---|
| Parse four paper-example R files | Passed |
| First CLI run: generate synthetic bundle and estimate models | Passed |
| Fresh-copy CLI run with bundled data/provenance | Passed |
| Independently repeated numerical files | 35 byte-identical outputs |
| Synthetic input schema | 500 rows, exactly 20 dictionary-ordered columns, integer categories 1–5 |
| Fixed seed and seed-change behavior | Passed |
| Invalid, duplicate, absent, extra and reordered columns | Rejected |
| Incorrect sample size; missing, nonfinite, constant, text, fractional and out-of-range values | Rejected |
| CSV round trip and malformed CSV boundary | Passed |
| Generation/dictionary/provenance hashes | Verified |
| Changed/partial input bundles | Refused without overwriting or repairing user files |
| MLR CFA, MLR SEM and ordinal WLSMV SEM | Converged and passed implemented admissibility checks |
| Sample consistency | All three fits used 500 observations |
| Model gates | Positive variances and positive-definite latent, indicator-residual and implied observed covariance matrices |
| Structural paths | Exactly the 14 Table 6 directed edges in both SEM outputs |
| Effect arithmetic | Total = direct + indirect; inverse and finite recursive path expansion agree |
| Parameter intervals | Standardized and unstandardized estimates/SEs/intervals exported separately and checked on their own scales |
| Fit-index availability | Conventional, scaled and robust families separate; unavailable values remain NA |
| Published reference join | All 14 reported paths remain distinct from synthetic estimates |
| Fornell–Larcker construction | Diagonal equals square root of the corresponding AVE |
| Descriptive statistic cells | Numeric, with variable labels kept separate |
| Existing output paths | Refused without overwriting files |
| Original generic tutorial regression | Main workflow, behavior checks and its 22 reference CSV tables passed unchanged |

An initial execution exposed an R dispatch issue in the model-implied covariance check. It was corrected to use the namespaced lavaan inspection API, not by attaching packages or removing a check. No structural assumptions, simulation parameters or acceptance gates were weakened. Final execution and behavioral checks passed after that correction.

## Estimation and output interpretation

The primary `cfa_mlr` and `sem_mlr` fits treat the five-category scores as a continuous approximation. The tested lavaan configuration reports an ML engine with `robust.huber.white` standard errors and `yuan.bentler.mplus` robust testing. This is not a claim that Mplus software generated the output or that MLR equals Satorra–Bentler MLM.

The separate `sem_wlsmv` fit declares all 20 indicators ordered. The engine reports DWLS parameter estimation with robust SEM standard errors and a scaled/shifted test. It is an ordinal sensitivity, not the paper's claimed historical primary estimator.

Direct, indirect and total-effect matrices use fully standardized SEM coefficients and the reported recursive graph. They include serial routes, including the 11 indirect routes from knowledge to intention. **Indirect and total effects are point estimates only: no intervals, bootstrap results or significance claims for those effects are supplied.** Parameter-table intervals for individual paths are scale-labelled separately.

Reliability, AVE, latent correlations, observed Pearson HTMT, contextual diagnostic flags and observed-scale summaries describe the synthetic CFA/input only. They do not recover the paper's original rho_A estimates, instrument validity or item-selection history. The legacy one-factor ML EFA is a Harman screening demonstration, not proof of absence of common-method bias.

## Reproduce

From the repository root:

```sh
Rscript install_packages.R
Rscript paper-example/run_paper_example.R
Rscript paper-example/checks.R
```

The default run directory is `paper-example/outputs/` and must be new or empty. To preserve a previous run and choose another destination in an R console:

```r
options(paper.output_dir = "paper-example/outputs-repeat")
source("paper-example/run_paper_example.R")
```

The reference files are in `paper-example/example-results/`. Cross-version/platform comparison may require a justified numerical tolerance; do not suppress material differences. Do not resave bundled CSVs in a spreadsheet or alter their provenance to force a run.

The synthetic response-file MD5 is `04ec16f59702120ff5e857f693c3f562`. This identifies content, not consent, privacy certification or scientific validity.

## Remaining boundaries

- Original respondent data, discarded-item pool, reverse-coding/exclusion history and complete historical project/software settings were not reconstructed.
- The provided SEM contains no explicitly specified social-capital interaction. No moderation term was invented from the title.
- The main reconstruction fixes structural disturbance covariances to zero and uses `std.lv = TRUE`; those are explicit tutorial choices, not recovered historical facts.
- Published coefficient/SE/T columns and significance annotations are not acceptance targets. The reference transcription preserves reported numbers without silently recalculating or correcting them.
- No new demographic, interview or focus-group findings are generated.
- SmartPLS steps remain a manual guide with proposed settings, not an executed robustness analysis.
- The generic optional CLF limitation remains documented separately; that model is not part of this paper-example runner.
- No external commit, push or upload was performed.

## Article and licensing

The approved [article reference](reference/README.md) and unmodified PDF retain CC BY 4.0. Original code and original guide prose use MIT; independent synthetic input/metadata use CC0. See [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md). The public citation intentionally identifies the paper's authors; private respondent records remain excluded.
