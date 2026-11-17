# Paper-linked TPB SEM example

**Reproduce the analysis logic, not the published numerical results.** This separate example uses 500 independently simulated five-category response patterns (seed `20250309`), the paper's 20 retained indicators, and the 14 directed relationships listed in its Table 6. It contains no participant records and is not an exact replication, correction, or independent verification of the article.

The [root tutorial](../README.md) remains an independent 22-item, five-direct-path learning example. Its primary ordinal WLSMV analysis, data, and outputs must not be substituted for this example's model or main estimator.

## Reference article

Iyioku, Gospel; Donkor, Ebenezer; Mazancova, Jana; Hejkrlik, Jiri (2024). Understanding farmers' motivations for joining cashew marketing cooperatives in coastal Kenya: the moderating role of social capital. *Cogent Food & Agriculture*, 10(1), 2433600. [DOI: 10.1080/23311932.2024.2433600](https://doi.org/10.1080/23311932.2024.2433600).

Use the [supplied publisher download](https://www.tandfonline.com/doi/epdf/10.1080/23311932.2024.2433600?needAccess=true) or the reference copy at `reference/published-paper.pdf`. See [reference attribution and limitations](./reference/README.md).

The citation and public article reference are intentionally included with author approval. This does not authorize release of confidential research records.

## Run from the repository root

The repository root means the public release folder containing `install_packages.R`, not the parent problem workspace.

```sh
Rscript install_packages.R
Rscript paper-example/run_paper_example.R
Rscript paper-example/checks.R
```

The paper example uses the root dependency installer; it does not require running the generic `run_all.R`. Use separate R sessions if switching between examples. Package installation needs network access; the subsequent example uses local synthetic input.

For an alternate output directory, run from the repository root in R:

```r
options(paper.output_dir = "paper-example/outputs-alternative")
source("paper-example/run_paper_example.R")
```

This changes the output destination, not the model, sample, or data directory. Preserve reference material separately from generated results.

## Files and workflow

| Path | Role |
|---|---|
| `run_paper_example.R` | Paper-specific analysis entry point |
| `checks.R` | Paper-specific behavioral checks |
| `data/synthetic_paper_tpb.csv` | Independent synthetic responses; 500 rows, 20 indicators |
| `data/data_dictionary.csv` | Paper-specific item map, coding, and generator metadata |
| `data/synthetic_provenance.csv` | Independent simulation settings and content hash |
| `outputs/` | Generated paper-example results, separate from root tutorial outputs |
| `example-results/` | Tested synthetic reference outputs: 33 CSV tables and two model specifications |
| `VERIFICATION.md` | Execution record and limitations; consult after verification is completed |
| `reference/published-paper.pdf` | Published article, retained under CC BY 4.0 |
| `reference/published_paths.csv` | Table 6 reported values for reference only |
| `docs/PAPER_TO_CODE.md` | Source-page anchors, measurement map, and complete path registry |
| `docs/METHODS_NOTES.md` | Estimators, identification, diagnostics, effects, and reconstruction choices |
| `docs/SMARTPLS_PAPER_GUIDE.md` | Separate, manual PLS robustness learning workflow |

Read the [paper-to-code map](./docs/PAPER_TO_CODE.md) before interpreting the outputs. The article's sequence is exploration/refinement → CFA → reliability and validity → MLR SEM → direct, indirect, and total effects → separate PLS robustness. The executable runner starts with the fixed retained-item map and covers CFA, measurement summaries, structural/effect calculations, ordinal sensitivity and the one-factor Harman screen. It does not rerun historical multi-factor item selection, normality-test selection, qualitative analysis or SmartPLS; those roles are explained rather than presented as executed steps. This release does not reconstruct demographic tables, interviews or focus groups.
## Model at a glance

| Construct | Indicators |
|---|---|
| ATT | `ATT_1`–`ATT_4` |
| INT | `INT_1`–`INT_3` |
| SUB_NORM | `SUB_NORM_1`–`SUB_NORM_3` |
| PBC | `PBC_1`–`PBC_4` |
| MORAL_NORM | `MORAL_NORM_1`–`MORAL_NORM_4` |
| KNOWLEDGE | `KNOWLEDGE_1`–`KNOWLEDGE_2` |

The structural graph is:

```text
INT        ~ ATT + MORAL_NORM + SUB_NORM + PBC + KNOWLEDGE
PBC        ~ ATT + KNOWLEDGE + MORAL_NORM + SUB_NORM
ATT        ~ KNOWLEDGE + MORAL_NORM + SUB_NORM
MORAL_NORM ~ KNOWLEDGE
SUB_NORM   ~ KNOWLEDGE
```

Despite the title's reference to moderation, the presented SEM does not specify a statistical social-capital moderator or interaction. Bonding and bridging social capital are discussed descriptively. Do not add an interaction, a seventh latent variable, or unreported hypothesis labels.

## Interpretation boundaries

- Main analysis: covariance-based CFA and SEM in lavaan using `MLR`, treating scores 1–5 as a continuous approximation. Ordered-item WLSMV is a separately labeled sensitivity analysis, not the historical primary method claimed here.
- SmartPLS: an explicitly chosen PLS or PLSc algorithm with bootstrap inference is a different analysis, not an implementation of lavaan MLR.
- Missing historical details: scaling, residual constraints, missing-data handling, software settings, and full bootstrap settings cannot be recovered completely from the article. Explicit settings here are reconstruction choices.
- Published numbers: the reference CSV preserves reported values, not targets, priors, simulation parameters, or acceptance criteria. Do not recompute its stars or silently derive missing p-values. Some coefficient, standard-error, and T-value entries do not arithmetically match.
- Synthetic results: differences from the article are expected. Fit, significance, and effect rankings do not establish new findings about farmers or demonstrate that the article is correct or incorrect.

The R entry point and behavioral checks were executed successfully in the tested environment. See [VERIFICATION.md](VERIFICATION.md) for the actual run record and limits. Indirect and total effects are point estimates without interval/significance inference. SmartPLS instructions are not evidence that a SmartPLS project was executed.

## Licensing

Original code and documentation are MIT-licensed except clearly attributed article material, which retains CC BY 4.0. Generic independently generated synthetic input and metadata are CC0; CC0 does not apply to article-derived reference tables, item descriptions, or the PDF. Short adapted indicator descriptions in the map are attributed to the article under CC BY 4.0. The article is not relicensed by the repository's root MIT or CC0 notices. See [reference licensing](./reference/README.md).

## Sources

- Iyioku et al. (2024), reference article: https://doi.org/10.1080/23311932.2024.2433600
- Publisher download supplied for this example: https://www.tandfonline.com/doi/epdf/10.1080/23311932.2024.2433600?needAccess=true
- Creative Commons Attribution 4.0: http://creativecommons.org/licenses/by/4.0/
