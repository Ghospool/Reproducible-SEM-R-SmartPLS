# R beginner guide

**Scope:** this page covers the original generic 22-item tutorial run by `run_all.R`. For the separate 20-item, 14-path published-paper use case, follow [paper-example/README.md](../paper-example/README.md). Its data, MLR-first estimation plan, assumptions and outputs are different. Neither example numerically reproduces the study.
## What you will reproduce

You will run an **educational synthetic example, not a replication of a published paper**. The generated observations are independent simulations, not participant records. No questionnaire wording or complete paper-specific estimation settings are available. Successful execution reproduces this demonstration's workflow; it cannot establish equivalence to published numerical results.

The main analysis uses six reflective constructs and 22 ordinal indicators. INT is regressed on ATT, PBC, SUB_NORM, KNOWLEDGE, and MORAL_NORM. Knowledge and moral norm are extensions, not original Theory of Planned Behavior components. The exact indicator mapping and interpretation limits are in [Methods](METHODS.md).

## 1. Install the software

1. Install R for your operating system from [CRAN](https://cran.r-project.org/). R is the program that executes the analysis.
2. Optionally install RStudio Desktop using the links in the [official RStudio guide](https://docs.posit.co/ide/user/?ref=rstudio-legacy). RStudio is an editor and interface; installing it does not replace installing R.
3. Obtain the public package, extract it if compressed, and keep its directory structure intact. If using an approved hosted copy, see [Download ZIP](GITHUB_GUIDE.md#5-download-zip-a-beginner-route-for-users).
4. Open the package root: the directory containing `install_packages.R`, `run_all.R`, `R/`, and `data/` when generated or supplied. In the original staging layout this is `release/`; in a clean public export its contents are the repository root.

Use only the public package. Do not move private files into it or point the scripts at private records. If a script contains an unexpected command, understand it before running it.

### Why scripts and packages?

Scripts make the analysis reviewable and repeatable rather than dependent on undocumented clicks. Packages provide reusable functions: `lavaan` for CFA/SEM, `semTools` for measurement summaries, and `psych` for reliability and exploratory tools.

`install_packages.R` is an explicit setup script: when you choose to run it, it installs missing dependencies from CRAN into the configured writable user library. It does not upgrade packages already available. The analysis script never installs software implicitly. Installation requires internet access; institutional repository policies may require adapting the setup script's repository URL before running it.

Package versions can change. The exported version table records what ran; it is not an environment lockfile or a promise of identical future results. The tested versions and reference results are described in [verification](../VERIFICATION.md).
## 2. Open the correct directory

In RStudio, open the supplied project file if present, or use File > New Project > Existing Directory and choose the package root. Restart in a clean R session; do not restore an old workspace image. The R console interprets R expressions; the Terminal tab interprets shell commands. Do not paste `Rscript ...` directly into the R console.

In a system terminal or RStudio Terminal already opened in the package root, check:

```bash
Rscript --version
```

If the command is not found, R may not be installed or its command-line executable may not be on the terminal's search path. Reopen the terminal after installation and consult the R installer instructions. Do not solve this by hardcoding a personal installation path into a public script. An RStudio console can run the `source()` alternative below when it has access to R.

In the R console, this checks that the two entry scripts are visible without printing a machine path:

```r
file.exists("install_packages.R")
file.exists("run_all.R")
```

Both should be `TRUE`. If not, open the correct project directory; do not edit the code to include an absolute working directory.

## 3. Install dependencies, then run

From a terminal in the package root, run the commands separately and proceed only after setup succeeds:

```bash
Rscript install_packages.R
Rscript run_all.R
```

Setup downloads only missing packages and their required dependencies from CRAN into your configured user library, then verifies that all three packages can load and prints their versions. Existing packages are not upgraded. If setup fails, inspect the network/library/compatibility error before running the analysis. An institutional environment may require its approved package mirror instead of the repository URL in this script. Do not publish unsanitized installation logs because they can contain local paths.

Alternatively, in an RStudio console opened at the package root:

```r
source("install_packages.R")
source("run_all.R")
```

Use one route, not both in succession unless you intend another run. Setup is safe to repeat with packages already installed. `run_all.R` verifies the bundled synthetic CSV and provenance; if the data files are absent, it can generate them. The generator refuses to overwrite any existing destination, including a partial set of data files. Use a complete clean package if input files are missing or inconsistent rather than deleting files blindly.

Output writing requires a new or empty destination. See the rerun guidance for preserving previous results. No participant data are needed for any of these commands.
## 4. Inspect the synthetic inputs

The expected input is `data/synthetic_tpb.csv`; `data/data_dictionary.csv` gives the indicator contract. A synthetic provenance sidecar accompanies the generated data. Keep it with the dataset. It is used to check that the file and generation settings match rather than to authenticate private data.

You may inspect the inputs in R without displaying records:

```r
example <- read.csv("data/synthetic_tpb.csv", check.names = FALSE)
names(example)
dictionary <- read.csv("data/data_dictionary.csv", check.names = FALSE)
dictionary
```

The validator expects exactly the 22 canonical columns, with nonmissing integer codes from 1 through 5 and nonconstant items. The dictionary contains generic indicator labels, not question wording or validated anchors. Do not infer reverse coding. Numeric ordinal codes are treated as ordered in the main analysis, not as an assertion of equally spaced categories.

The bundled synthetic workflow rejects unsupported data rather than silently dropping rows, imputing values, or discarding unexpected columns. Do not replace the CSV with real data or edit its provenance to make checks pass. A hash match is an integrity check, not evidence of consent, anonymity, or scientific validity.

## 5. Understand the sequence

1. **Generate or verify the synthetic data.** The generator uses explicit reproducibility settings independent of participant observations.
2. **Validate the schema and categories.** Investigate any stop before proceeding.
3. **Fit a correlated six-factor CFA with ordinal WLSMV.** Confirm the measurement model before interpreting substantive relationships.
4. **Fit the main ordinal SEM.** All five predictors enter the INT regression together.
5. **Fit a continuous-treatment MLR sensitivity.** This changes the measurement approximation and estimator, not the substantive meaning of a result.
6. **Fit the omit-moral-norm sensitivity.** Remove that factor, its three indicators, and its predictor role while retaining the other blocks. Knowledge remains an extension.
7. **Export inspectable tables and sanitized provenance.** The main script can compute multiple fits automatically, but automatic completion does not remove the human measurement-review step.

The implementation explicitly uses standardized latent-variable scaling (`std.lv = TRUE`), a declared compatibility convention (`mimic = "Mplus"`), and a complete validated sample. The input checks reject missing responses; the fitting code's listwise setting is not an invitation to introduce missing data and silently lose cases. WLSMV does not offer ordinal full-information ML in lavaan. An alternative missing-data strategy requires a separately justified change.

## 6. Read CFA results before SEM paths

Begin with warnings and convergence checks, then the CFA tables. Inspect:

- Loading patterns, signs, standard errors, and uncertainty.
- Negative variances, implausible estimates, near-perfect factor correlations, and identification problems.
- Global fit alongside local residual patterns and substantive measurement assumptions.
- Reliability and AVE with their scale and calculation labels, not just a universal cutoff.

The fitting code gates exports on convergence and admissibility checks. Passing those checks does not by itself establish good fit, validity, or correct theory. Do not delete indicators automatically to improve loadings or fit. Without item wording, content validity and reverse-keying remain unresolved.

Only after reviewing CFA should you interpret the SEM's conditional paths and uncertainty. Path arrows do not establish causality, and synthetic estimates do not test real-world hypotheses. Similar signs across sensitivities are not published-results equivalence.

## 7. Read outputs carefully

The main workflow writes plain CSV outputs to `outputs/` by default. For each fitted-model prefix, the output families include:

| File family | How to use it |
| --- | --- |
| `*_parameters.csv` | Loadings, variances/covariances, thresholds or intercepts, and paths as applicable; filter by parameter type |
| `*_fit.csv` | Fit metrics with availability labels; distinguish conventional, scaled, and robust rows |
| `*_latent_correlations.csv` | Check construct overlap and unexpected dependence |
| `*_r2.csv` | Distinguish indicator explained variance from latent INT explained variance |
| `cfa_wlsmv_composite_reliability.csv` | CFA-based composite reliability on the labeled ordinal scale |
| `cfa_wlsmv_ave.csv` | AVE on the labeled latent-response scale |
| `observed_category_alpha.csv` | Pearson-based alpha on numeric category scores, not ordinal alpha or a validity test |
| `analysis_manifest.csv` | Estimator, indicator treatment, and specification labels |
| `versions.csv` | Relevant R and package versions |
| `provenance.csv` | Allowlisted synthetic-generation and analysis provenance |

The fitted-model prefixes distinguish `cfa_wlsmv`, `sem_wlsmv`, `sem_mlr_continuous`, and `sem_wlsmv_without_moral`. Keep them separate. WLSMV likelihood criteria such as AIC/BIC may be unavailable; an unavailable value is not zero and should not be silently replaced.

In a lavaan parameter table, `=~` identifies loadings, `~` regression paths, `~~` variances/covariances, and `|` ordinal thresholds. Standardized estimate columns and unstandardized estimates are not interchangeable. In these exports, the usual parameter confidence limits accompany the unstandardized estimates; the presence of a standardized column does not mean the interval has been standardized. Read column definitions before quoting a coefficient and interval together.

Open CSV files as data, not as instructions. Spreadsheet programs can autoformat values; keep the original CSV and review imports. Do not publish an unreviewed terminal transcript just because the generated provenance is sanitized. See [Data and privacy](DATA_AND_PRIVACY.md).

## 8. Reruns and optional investigations

The output helper refuses to overwrite a nonempty destination. Preserve the previous run and choose a new empty directory in an R console at the package root:

```r
options(tpb.output_dir = "outputs_repeat")
source("run_all.R")
```

Use another neutral relative name if that directory contains files. This reuses the verified synthetic input. Alternatively use a clean package copy with no generated `outputs/` directory.

Optional modules are excluded from `run_all.R`. Run each separately from the package root:

```r
source("R/efa.R")
run_optional_efa()
```

The EFA uses polychoric correlations, minimum-residual extraction, oblique promax rotation, and normal-reference parallel analysis on the estimated correlation matrix. The reference simulation is not category-preserving ordinal resampling. Reference tables are in `example-results/efa/`. EFA on the same observations does not independently confirm CFA. Harman's single-factor screening cannot prove absence of method bias.

The CLF is for advanced sensitivity investigation only:

```r
source("R/clf.R")
run_optional_clf()
```

**Known outcome: this optional CLF failed admissibility checks on the bundled sample.** The information matrix could not be inverted for the robust test, and the latent covariance matrix was not positive definite. The function stops rather than exporting invalid results. See [verification](../VERIFICATION.md). This failure is not evidence that method bias is present or absent; do not remove checks to obtain a table.

The CLF is measurement-level WLSMV, not the structural INT regression. METHOD loads freely on all indicators and is explicitly uncorrelated with every substantive factor. Orthogonality is an assumption, not lavaan's default or an empirical discovery. Scaling and local checks do not guarantee global identification. Revisions require methodological justification, not merely a desire for convergence.

Default destinations are `outputs_efa/` and `outputs_clf/`, both new or empty. Repeat with a fresh path, such as `run_optional_efa(output_dir = "outputs_efa_repeat")`. `Rscript R/efa.R` and `Rscript R/clf.R` alone load definitions but do not call the functions.

Run the standalone reproducibility and boundary checks with:

```bash
Rscript R/checks.R
```

They use temporary synthetic files, not private inputs.
## 9. Troubleshooting without hiding problems

| Message or symptom | Safe next step |
| --- | --- |
| `Rscript` not found | Verify R installation and terminal search path, or use the R console route |
| Package unavailable | Read the installation failure; check network, writable library, and compatible R version |
| File not found | Confirm package-root working directory and extracted directory structure |
| Nonempty output directory | Preserve it and use a new empty destination or clean package copy |
| Synthetic provenance mismatch | Stop; restore a consistent clean synthetic package or intentionally regenerate through supported entry points |
| Invalid columns, categories, or missing values | Inspect schema/dictionary; do not force conversion or silent deletion |
| Nonconvergence or inadmissible solution | Do not interpret paths; inspect the model, data validation, identification, and versions |
| Missing fit index | Check estimator support and availability labels rather than fabricating a value |

Record a minimal, sanitized error description and relevant software versions when asking for help. Do not paste records, machine paths, usernames, or private filenames into an issue. This guide is not evidence that numerical execution succeeded in the preparation environment; consult the package's reported verification status.

## Sources

- [CRAN: R distributions and packages](https://cran.r-project.org/)
- [RStudio IDE: Official user guide and installation links](https://docs.posit.co/ide/user/?ref=rstudio-legacy)
- [lavaan: Categorical data](https://lavaan.ugent.be/tutorial/cat.html)
- [lavaan: Estimators and more](https://lavaan.ugent.be/tutorial/est.html)
