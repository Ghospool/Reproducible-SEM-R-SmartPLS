# Paper-to-code map

This example reconstructs the model logic from Iyioku, Gospel; Donkor, Ebenezer; Mazancova, Jana; Hejkrlik, Jiri (2024), *Understanding farmers' motivations for joining cashew marketing cooperatives in coastal Kenya: the moderating role of social capital*, *Cogent Food & Agriculture* 10(1), 2433600, DOI [10.1080/23311932.2024.2433600](https://doi.org/10.1080/23311932.2024.2433600). It does not recover the original data or every historical analysis setting.

[Example README](../README.md) · [Methods notes](./METHODS_NOTES.md) · [SmartPLS guide](./SMARTPLS_PAPER_GUIDE.md)

## Source anchors

Page numbers below are PDF page positions in [the reference article](../reference/published-paper.pdf), including its publisher cover. Table and section labels remain the authoritative anchors if a viewer numbers pages differently.

| PDF pages | Article anchor | Reconstruction use |
|---|---|---|
| 1–2 | Article metadata | Approved citation and DOI |
| 7–9 | §3.1 Data collection and processing | Context and mixed-method design; not public participant input |
| 9–10 | §3.2 Latent variables | Six constructs and reported EFA/refinement then CFA logic |
| 10–11 | §3.3; Table 1; Figure 2 | Normality discussion, reliability summaries, conceptual framework |
| 11 | Table 2, within §3.4 | Retained 20-item measurement map |
| 11–12 | §3.4 | CFA, reliability, AVE, discriminant-validity assessment |
| 12 | §3.5 | Harman single-factor diagnostic and its limitations |
| 13–15 | §4.1–4.2; Tables 3–5 | Descriptive and qualitative context; outside this synthetic SEM example |
| 15 | §4.3; Figure 3 | Structural-model narrative and fit reporting |
| 16 | Table 6 | Complete registry of 14 directed structural paths |
| 16 | Table 7; §4.3 robustness paragraph | Total-effects logic and separate PLS robustness motivation |

The article's robustness paragraph points to Appendix E. This documentation does not infer absent settings or numerical details from that reference.

## Measurement map: exactly 20 retained items

All six blocks are specified as reflective in this reconstruction. The source Table 2 uses these underscored item codes. The short phrases below are adapted descriptions, not a copied questionnaire or a newly validated instrument. They are article-derived material attributed to Iyioku et al. (2024), Table 2, under CC BY 4.0; wording has been shortened.

| Construct | Code | Short adapted indicator description |
|---|---|---|
| Attitude | `ATT_1` | Better marketing and price opportunities |
| Attitude | `ATT_2` | Helpful contacts with other farmers |
| Attitude | `ATT_3` | Access to information, training, and inputs |
| Attitude | `ATT_4` | Contribution to local cashew industry |
| Intention | `INT_1` | Joining soon for income opportunities |
| Intention | `INT_2` | Joining as an active member |
| Intention | `INT_3` | Joining with leadership interest |
| Subjective norm | `SUB_NORM_1` | Family encouragement |
| Subjective norm | `SUB_NORM_2` | Friends' encouragement |
| Subjective norm | `SUB_NORM_3` | Agricultural experts' recommendation |
| Perceived behavioral control | `PBC_1` | Affordable fees and requirements |
| Perceived behavioral control | `PBC_2` | Ability to meet membership criteria |
| Perceived behavioral control | `PBC_3` | Resources and knowledge of joining steps |
| Perceived behavioral control | `PBC_4` | Personal control and scheduling flexibility |
| Moral norm | `MORAL_NORM_1` | Guilt about not considering membership |
| Moral norm | `MORAL_NORM_2` | Legal and moral acceptability |
| Moral norm | `MORAL_NORM_3` | Duty toward industry development |
| Moral norm | `MORAL_NORM_4` | Responsibility toward fellow farmers |
| Knowledge | `KNOWLEDGE_1` | Understanding benefits and challenges |
| Knowledge | `KNOWLEDGE_2` | Understanding cooperative functioning |

The article discusses a larger initial item pool in §3.1; the executable map follows the retained Table 2 indicators, not that initial pool. Synthetic scores are integers 1–5, not reconstructed interviews. Do not infer reverse coding, add items, or use the generic tutorial's 22-item map. The two-indicator knowledge block needs identification from the broader model and its constraints; it is not a license to freely correlate indicator errors.

## Structural registry: Table 6

Numbers in the first column are the published Table 6 row numbers, **not invented hypothesis labels**. Every listed arrow is a direct structural regression, even when it contributes to an indirect route to intention. There are five direct predictors of intention and nine other directed edges.

| Table 6 row | Source | Destination |
|---|---|---|
| 1 | ATT | INT |
| 2 | MORAL_NORM | INT |
| 3 | SUB_NORM | INT |
| 4 | PBC | INT |
| 5 | KNOWLEDGE | INT |
| 6 | ATT | PBC |
| 7 | KNOWLEDGE | PBC |
| 8 | MORAL_NORM | PBC |
| 9 | SUB_NORM | PBC |
| 10 | KNOWLEDGE | ATT |
| 11 | MORAL_NORM | ATT |
| 12 | SUB_NORM | ATT |
| 13 | KNOWLEDGE | MORAL_NORM |
| 14 | KNOWLEDGE | SUB_NORM |

The equivalent regression specification is:

```r
INT ~ ATT + MORAL_NORM + SUB_NORM + PBC + KNOWLEDGE
PBC ~ ATT + KNOWLEDGE + MORAL_NORM + SUB_NORM
ATT ~ KNOWLEDGE + MORAL_NORM + SUB_NORM
MORAL_NORM ~ KNOWLEDGE
SUB_NORM ~ KNOWLEDGE
```

There is no `MORAL_NORM → SUB_NORM` arrow, reciprocal arrow, or interaction in this registry. The article's social-capital narrative and bonding/bridging descriptions do not define a statistically estimated moderator. Figure 2 is useful conceptual context; Table 6 supplies the explicit executable edge list.

## Effects: Table 6 versus Table 7

Table 6 is the reference for direct edge estimates. Table 7 concerns total effects, not simply the same regressions copied into another table. For a recursive linear graph, sum the products along every directed route between two constructs. Use coefficients from one fitted model and one consistent scale.

For example, let `K`, `M`, `S`, `A`, `P`, and `I` stand for knowledge, moral norm, subjective norm, attitude, perceived behavioral control, and intention. Let `b_XY` denote the coefficient for `X → Y`. Knowledge's indirect effect on intention comprises these 11 routes:

```text
K → M → I                  K → S → I
K → A → I                  K → P → I
K → M → A → I              K → S → A → I
K → M → P → I              K → S → P → I
K → A → P → I
K → M → A → P → I          K → S → A → P → I
```

For instance, `K → M → A → P → I` contributes `b_KM * b_MA * b_AP * b_PI`.

```text
indirect(K,I) = sum(products over all 11 indirect routes)
total(K,I)    = b_KI + indirect(K,I)
```

This is a model-implied decomposition, not a calculation intended to force agreement with published rounded values. Obtain uncertainty for an indirect effect jointly from its fitted parameters (or a clearly separate, justified bootstrap); do not multiply edge p-values or combine published stars. Cross-sectional paths alone do not identify causal mediation.

## Numerical reference boundary

`../reference/published_paths.csv` transcribes the article's Table 6 reported values. It must remain separate from `../data/` and generated `../outputs/`. Published estimates, reported uncertainty, T-values, and significance markings are preserved as reference information, never used to calibrate the independent simulation or judge whether code passes.

The publication mixes estimator terminology and does not give every historical setting. Some Table 6 standardized coefficients, parenthetical uncertainty values, and T-values are not arithmetically consistent. Do not silently repair entries, derive missing p-values, recompute stars, or label any reported significance pattern a gold standard. Table 7 totals should likewise be read as reported reference values, not a numerical checksum against newly fitted synthetic data. These limitations do not amount to a correction or independent verification of the paper.

## Sources

- Iyioku et al. (2024), including Tables 2, 6, and 7: https://doi.org/10.1080/23311932.2024.2433600
- Supplied publisher PDF: https://www.tandfonline.com/doi/epdf/10.1080/23311932.2024.2433600?needAccess=true
- Article-material license, CC BY 4.0: http://creativecommons.org/licenses/by/4.0/
