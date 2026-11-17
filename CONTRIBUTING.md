# Contributing

## Scope

Improve the reusable tutorial or its separate paper worked example without claiming that synthetic observations numerically replicate a study. Explain each change and distinguish reported source information, reconstruction decisions and verified software behavior. Manual SmartPLS instructions do not establish an executed SmartPLS analysis.

Read [the generic methods guide](docs/METHODS.md), [the paper-to-code map](paper-example/docs/PAPER_TO_CODE.md), [privacy guidance](docs/DATA_AND_PRIVACY.md) and [third-party notices](THIRD_PARTY_NOTICES.md) before contributing.

## Privacy and attribution

Use independently simulated observation data only. Never submit real respondent records, demographics, free text, factor scores, credentials, private filenames, local paths or unsanitized logs. The approved paper, citation and transcribed published reference values are explicit exceptions to the rule against sharing original source material. They are not permission to disclose unpublished study data.

Keep author and publisher notices on the article. Public author/account attribution is intentional; it does not provide anonymity. Do not add private contact details, affiliations or unrelated identity links. Report suspected leaks through an appropriate private channel, not by copying sensitive content into a public issue.

Publish only reviewed package files. Never upload the parent workspace, `input/`, editor history, full session dumps or fitted binary objects that may contain observations or calls. Inspect author and committer metadata; a noreply email hides an ordinary address, not account attribution.

## Two model contracts

| Contract | Generic tutorial | Paper worked example |
|---|---|---|
| Indicators | 22 | 20, from Table 2 |
| Structural paths | Five predictors into INT | 14 directed paths from Table 6 |
| Main estimation | Ordered WLSMV | Continuous-approximation MLR |
| Sensitivity | MLR and without moral norm | Separate ordinal WLSMV |
| Source of data | Independent simulation, n=400 | Independent simulation, n=500 |
| Main command | `Rscript run_all.R` | `Rscript paper-example/run_paper_example.R` |
| Checks | `Rscript R/checks.R` | `Rscript paper-example/checks.R` |

Keep the contracts separate. Do not interchange datasets or silently change item assignments, missing-value rules, reflective measurement, estimator, residual restrictions or structural arrows. Knowledge and moral norm extend the original TPB. Do not infer reverse coding from item names or loading signs.

The paper example follows its published graph and computes direct, indirect and total effects. It does not invent a social-capital interaction because the title uses the word moderation. Adding a statistical moderation model requires its own justified specification, data contract and clearly labeled scope.

## Changes and verification

1. Explain the issue and intended behavior without private context.
2. Keep relative paths and explicit package setup. Do not silently install software during analysis.
3. Keep simulation independent of participant observations and published coefficients. Do not tune paths or significance to make synthetic results resemble reported findings.
4. Update dictionaries, provenance versions and affected guides when interfaces or generation choices change. Preserve prior results; do not bypass overwrite guards.
5. Run the affected example and its behavior checks. Inspect warnings, sample retention, admissibility, measurement diagnostics, effect arithmetic and output schemas, not just the exit code.
6. Preserve separately labeled standardized and unstandardized estimates and intervals. Check recursive effects against the documented graph; total must include all permitted directed paths.
7. Keep reported reference values distinct from computed outputs. If source columns disagree, retain accurate transcription and report the ambiguity instead of silently changing the publication or deriving unsupported significance claims.
8. Inspect outputs and archive contents for privacy and licensing. Do not attach unsanitized console transcripts or binary model objects.
9. Record the software versions and commands actually run. If execution is blocked, state the blocker; static review is not numerical verification. Compare repeated outputs in the same environment and investigate material differences.

Never weaken a test, drop a planned indicator or suppress an important warning merely to obtain a desired result. EFA and CFA on the same sample are not independent confirmation. A good fit does not prove theory or causality. Harman's one-factor analysis and a CLF cannot establish absence of method bias. Preserve the documented failure of the generic optional CLF unless a separately justified methodological change is made and verified.

## SmartPLS changes

Identify the model and actual SmartPLS build. Keep ordinary PLS, PLSc and covariance-based MLR/ordinal WLSMV distinct. Record algorithm, bootstrap, sign-handling and prediction settings. Distinguish historical settings reported in the article from suggested tutorial choices. Do not claim PLS fit displays are interchangeable with CB-SEM fit, or that instructions alone verify a run.

## Licenses and external actions

Original code, original guide prose and computed synthetic outputs use [MIT](LICENSE). Independent synthetic inputs/metadata in both data directories use [CC0](LICENSE-DATA). The article and attributed article-derived material retain [CC BY 4.0](THIRD_PARTY_NOTICES.md). Contribute only material you may share under the applicable terms; preserve all required notices and mark adaptations.

Do not add CI, external publishing, integrations or dependencies with new licensing implications without owner approval. Do not force-push, overwrite unexpected remote contents or discard history to route around a conflict. No guide performs an upload automatically.
