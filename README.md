# Reproducible SEM in R and SmartPLS

A reusable SEM tutorial with a separate worked example showing how a published study's measurement model, structural paths, and effect tables connect to code.

**All runnable observation datasets are independently synthetic. They reproduce the examples' calculations. ** No original participant records are included.
The approved paper reference retains its published author information; this is not an anonymous release.

## Choose a workflow

| Workflow | Purpose | Measurement model | Structural model | Main estimator |
|---|---|---|---|---|
| [Generic tutorial](docs/R_GUIDE.md) | Learn the reusable basics | 22 indicators, six factors | Five predictors into intention | Ordinal WLSMV |
| [Paper worked example](paper-example/README.md) | Trace Tables 2, 6, and 7 into an analysis | 20 published indicator assignments, six factors | 14 directed paths with indirect/total effects | Continuous-approximation MLR |

The examples have separate datasets, configuration, output directories and verification records. Do not interchange their CSVs. The paper example adds an ordinal WLSMV sensitivity; it does not silently treat WLSMV as the paper's primary estimator.

## Quick start

1. Install [R](https://cran.r-project.org/) and optionally [RStudio Desktop](https://posit.co/download/rstudio-desktop/).
2. Download and extract the repository ZIP, or clone it. Open `tpb-sem.Rproj` in a clean R session.
3. Run setup from the repository root. Setup explicitly installs missing dependencies; analysis never installs them implicitly.

```sh
Rscript install_packages.R
```

Choose the generic tutorial:

```sh
Rscript run_all.R
Rscript R/checks.R
```

Or run the paper worked example, also from the repository root:

```sh
Rscript paper-example/run_paper_example.R
Rscript paper-example/checks.R
```

In RStudio's R console, use `source("install_packages.R")` and then `source("run_all.R")` or `source("paper-example/run_paper_example.R")`. Do not paste terminal `Rscript` commands into the R console.

Keep previous results. Each workflow refuses to overwrite a nonempty output directory. The relevant guide explains rerun options and how to inspect warnings, measurement quality, and effect tables.

## The paper as a worked reference

Iyioku, G., Donkor, E., Mazancova, J., & Hejkrlik, J. (2024). *Understanding farmers' motivations for joining cashew marketing cooperatives in coastal Kenya: the moderating role of social capital*. **Cogent Food & Agriculture, 10**(1), 2433600. [DOI](https://doi.org/10.1080/23311932.2024.2433600).

- [Publisher's paper download](https://www.tandfonline.com/doi/epdf/10.1080/23311932.2024.2433600?needAccess=true)
- [Included article PDF](paper-example/reference/published-paper.pdf)
- [Paper-to-code map](paper-example/docs/PAPER_TO_CODE.md)
- [Implementation and methods notes](paper-example/docs/METHODS_NOTES.md)
- [Paper-specific SmartPLS instructions](paper-example/docs/SMARTPLS_PAPER_GUIDE.md)

Use the article to see how the analysis is applied. The tutorial does not copy ambiguous methodology prose as implementation fact or claim to correct the published findings. It distinguishes reported information, choices needed for a runnable demonstration, and historical details that remain unavailable.

Table 2 supplies the 20-item measurement map. Table 6 supplies the 14 directed relationships. Table 7 motivates the distinction between direct, indirect, and total effects. Reported coefficients are kept in an attributed reference file, separate from synthetic estimates, and are never used to tune the generator.

Although the title mentions moderation, the supplied article does not provide an explicit interaction specification in the displayed SEM. The example therefore does not invent a social-capital factor, interaction term, or moderation hypothesis. Descriptive bonding/bridging information is not itself a statistical interaction model.

## Generic tutorial model

| Construct | Role | Generic indicators |
|---|---|---|
| ATT | Attitude | ATT_1–ATT_3 |
| PBC | Perceived behavioral control | PBC_1–PBC_4 |
| SUB_NORM | Subjective norm | SUB_NORM_1–SUB_NORM_3 |
| KNOWLEDGE | Knowledge extension | KNOWLEDGE_1–KNOWLEDGE_3 |
| MORAL_NORM | Moral norm extension | MORAL_NORM_1–MORAL_NORM_3 |
| INT | Behavioral intention | INT_1–INT_6 |

The root tutorial fits `INT ~ ATT + PBC + SUB_NORM + KNOWLEDGE + MORAL_NORM`. This generic 22-item model is not the paper's final 20-item model. Both knowledge and moral norm are extensions to TPB, not original core components.

## Folder guide

| Path | Purpose |
|---|---|
| `run_all.R`, `R/`, `data/` | Generic tutorial, independent 400-row sample and checks |
| `example-results/` | Generic synthetic reference tables |
| `VERIFICATION.md` | Generic verification and release boundaries |
| `paper-example/` | Separate paper-logic example and guide |
| `paper-example/reference/` | Approved article and attributed published values |
| `paper-example/data/` | Independent 500-row synthetic paper-example sample |
| `paper-example/example-results/` | Computed synthetic paper-example reference outputs |
| `paper-example/VERIFICATION.md` | Paper-example execution checks and limits |
| `docs/R_GUIDE.md`, `docs/METHODS.md` | Generic R and methodological guidance |
| `docs/SMARTPLS_GUIDE.md` | Generic five-path SmartPLS walkthrough |
| `docs/DATA_AND_PRIVACY.md` | Publication boundaries and permitted references |
| `docs/GITHUB_GUIDE.md` | Upload steps for the supplied repository |
| `CONTRIBUTING.md` | Improvement and verification guidance |
| `CITATION.cff`, `THIRD_PARTY_NOTICES.md` | Citation metadata and mixed-license boundaries |

## Reuse and interpretation

For a new study, work in a separate private copy and specify the instrument, coding, missing-data handling and model before estimation. Do not rename real observations as synthetic or edit provenance merely to pass validation. Do not delete indicators automatically to improve fit or significance.

CFA evaluates a specified measurement model. SEM estimates relationships under assumptions; arrows and significance do not establish causality. EFA and CFA using the same observations do not provide independent confirmation. Harman's test and CLF models cannot establish the absence of common-method bias.

The R examples use covariance-based SEM. Ordinary PLS-SEM and PLSc have different targets and algorithms; SmartPLS results need not match MLR or ordinal WLSMV. The SmartPLS guides are manual instructions, not claims of executed SmartPLS analyses.

## Verification

The original generic workflow passed execution and input-boundary checks. Independent main runs reproduced its 22 reference CSV tables byte-for-byte in the tested environment. The optional generic EFA passed. Its optional free-loading CLF failed admissibility on the bundled sample and is excluded from the main workflow; no valid CLF result is endorsed. See [generic verification](VERIFICATION.md).

The new paper example has a [separate verification record](paper-example/VERIFICATION.md). Its synthetic coefficients, intervals and effect totals are teaching outputs, not recovered empirical results. Exact numerical replication still requires the original lawful analysis data, final scoring/exclusion decisions and historical software/project settings.

## Licenses and publication

- Original code, original documentation and computed synthetic reference outputs: [MIT](LICENSE), copyright label `Ghospool`.
- Independently synthetic CSV inputs/metadata in `data/` and `paper-example/data/`: [CC0 1.0 Universal](LICENSE-DATA).
- Included article and article-derived reference material: **CC BY 4.0**, with attribution and scope in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). These are not relicensed under MIT or CC0.

External packages, SmartPLS and other sources retain their own terms. Keep the article's notices and identify any adaptations. Public paper/account attribution is intentional; private participant data remain excluded.

Publish only this reviewed package, never its enclosing workspace or private `input/` folder. The intended destination is [Ghospool/SEM---R-SmartPLS](https://github.com/Ghospool/SEM---R-SmartPLS). No push or upload has been performed here, and remote contents/permissions have not been verified.

## Sources

- [Reference paper](https://doi.org/10.1080/23311932.2024.2433600)
- [lavaan categorical-data estimation](https://lavaan.ugent.be/tutorial/cat.html)
- [lavaan estimators and missing data](https://lavaan.ugent.be/tutorial/est.html)
- [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
