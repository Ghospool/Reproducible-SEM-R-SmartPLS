# Generic tutorial verification and known limitations

**Scope:** the numerical checks below concern the original generic 22-item tutorial. Its R and CSV artifacts are preserved while a separate [paper worked example](paper-example/README.md) is added. See [paper-example/VERIFICATION.md](paper-example/VERIFICATION.md) for that example's checks. An approved published PDF and reference values are now included under their own CC BY 4.0 terms; they are not synthetic data or part of the generic fit tests.
## Summary

**The main synthetic R workflow passed execution and reproducibility checks.** The optional EFA also ran successfully. The optional free-loading CLF did not yield an admissible solution on the bundled sample and must not be interpreted. SmartPLS has not been executed.

All numerical results in this package concern independent synthetic observations, not participants or published findings. Tests used separate clean package copies and temporary synthetic files, never the private input dataset.

## Tested environment

| Component | Version |
|---|---|
| Operating system | Windows |
| R | 4.6.1 |
| lavaan | 0.7.3 |
| semTools | 0.5.10 |
| psych | 2.6.9 |

These are the versions actually tested, not minimum supported versions. macOS, Linux, other R/package versions, RStudio GUI interactions, and SmartPLS GUI execution were not tested. A recorded version table is not a dependency lockfile. Recreate these versions for the closest numerical comparison, or record and investigate differences when using newer versions.

## Checks performed

| Check | Outcome |
|---|---|
| Parse all eight R source/entry scripts | Passed |
| Explicit dependency installation into an isolated empty user library | Passed |
| Repeat dependency setup with installed packages | Passed; no upgrades performed |
| Source main entry point from the project root | Passed |
| Direct `Rscript run_all.R` from a clean package copy | Passed |
| Bundled synthetic input | Passed: 400 rows, 22 item columns, integer categories 1–5 |
| Fixed-seed generator repeat | Passed |
| Schema and malformed-value rejection, both in memory and after CSV import | Passed |
| Missing/tampered provenance rejection | Passed |
| Refusal to overwrite generated data or a nonempty output directory | Passed |
| Full six-factor ordinal CFA | Converged and passed admissibility checks |
| Main ordinal WLSMV SEM | Converged and passed admissibility checks |
| Continuous-treatment MLR SEM sensitivity | Converged and passed admissibility checks |
| WLSMV SEM without moral norm | Converged and passed admissibility checks |
| Common sample across all four fits | Passed; 400 observations in every fit |
| Two independent main runs versus bundled references | 22 byte-identical CSV tables in the tested environment |
| Optional polychoric/minres/promax EFA | Passed; parallel analysis retained six factors |
| Optional orthogonal free-loading CLF | Failed admissibility; no valid result tables supplied |
| SmartPLS project and bootstrap execution | Not run; manual guide only |

The standalone boundary checks cover extra, absent and duplicated columns; missing, constant, fractional, out-of-range, infinite and text item values; data/provenance integrity; and overwrite protection. They do not prove every possible failure mode is covered.

The bundled synthetic CSV MD5 is `2d4dbdff9c5e81863e58704edc88f343`. It is an integrity identifier, not a security signature, privacy certificate, or proof of scientific validity. Git attributes keep CSV line endings stable; manual spreadsheet re-saving can change file bytes and correctly trigger a mismatch.

## Reproduce the successful main check

From the clean public package root, in a terminal:

```sh
Rscript install_packages.R
Rscript run_all.R
Rscript R/checks.R
```

The main output destination must be new or empty. Preserve old runs; use `options(tpb.output_dir = "outputs_repeat")` in an R console before `source("run_all.R")` for another run. The checks script creates its own temporary synthetic data and cleans up only its temporary directory.

Compare generated `outputs/` tables with `example-results/main/`. Floating-point or package-version differences may prevent byte identity elsewhere; compare equivalent estimates using a justified numeric tolerance rather than ignoring changes. Missing estimator-specific indices are labeled unavailable, not replaced by zero. The usual parameter-table confidence limits are for unstandardized estimates; do not attach them to standardized coefficients.

For the optional EFA:

```r
source("R/efa.R")
run_optional_efa()
```

Reference EFA tables are in `example-results/efa/`. Normal-reference parallel analysis on a polychoric matrix is a heuristic, not category-preserving ordinal resampling or independent validation.

## Known CLF failure

The optional `run_optional_clf()` fits a measurement-level factor loading freely on all items, orthogonal to the six substantive factors. It is deliberately excluded from the default pipeline.

On this synthetic sample, lavaan warned that it could not invert the information matrix needed for the robust test statistic and that the latent covariance matrix was not positive definite. The explicit admissibility gate stopped with:

```text
Latent covariance is not positive definite (tolerance 1e-8).
```

No CLF estimate, loading-change table, or method-variance percentage from this run is endorsed. Such an augmented model can be weakly identified and unstable; the failure does not isolate a single cause, validate the baseline theory, or establish that method bias is present or absent. The simulation was not changed and the gates were not weakened to obtain a favorable optional fit. Any future constraints or alternative method-factor design must be justified and reported as a different sensitivity model.

## Release scope

Only the reviewed public package is intended for distribution. Private original scripts, participant records, raw factor scores, row-level demographics, full session dumps and terminal logs remain outside it. The approved article PDF and published reference values are intentionally included; the article contains its original public author information and published aggregate results, not a distributed respondent dataset.

The generic R scripts, synthetic inputs and numerical reference tables covered by this report are preserved. The additional 20-item, 14-path paper example has its own [execution record](paper-example/VERIFICATION.md) and does not replace this generic tutorial.

Original code/documentation and computed synthetic outputs use [MIT](LICENSE). Independently synthetic input/metadata CSVs in both data directories use [CC0](LICENSE-DATA). The article and attributed article-derived material retain CC BY 4.0; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). Public paper/account attribution is approved and intentional, not anonymous publication.

No exact-paper-replication claim, remote commit, push or upload has been made. Earlier Git execution was denied and unauthenticated repository access returned 404; remote contents and permissions have not been verified. A locally tested export is not confirmation of external publication.
