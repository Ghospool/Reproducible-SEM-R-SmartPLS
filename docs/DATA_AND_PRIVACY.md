# Data and privacy

The owner has approved public inclusion of the article's citation, author names, DOI, download link, unmodified published PDF and attributed published reference values. Those specific published references are an intentional exception to the identity-neutral source-provenance guidance below; they are not private participant data or independently synthetic results. All original respondent records, raw study files and private machine paths remain excluded. See [third-party notices](../THIRD_PARTY_NOTICES.md) for article attribution and CC BY 4.0 licensing.

The root `data/` files belong to the generic 22-item example. The separate `paper-example/data/` files use 20 indicators and independently simulated observations. Never interchange them or replace them with real records.
## Synthetic, not de-identified participant data

`data/synthetic_tpb.csv` is an independently simulated educational dataset. It is not a masked, shuffled, perturbed, resampled, or de-identified participant dataset. `data/data_dictionary.csv` documents the synthetic columns and allowed codes, not a recovered questionnaire.

Simulation parameters, response frequencies, sample size, loadings, correlations, and paths are illustrative design choices. They must not be interpreted as original descriptive statistics or calibrated estimates from a published study. Do not describe this package as reproducing a paper's numerical results.

The release contains no question wording. Construct and indicator labels alone do not establish the content, validity, permission to reuse a scale, or reverse-coding rules. No reverse coding is inferred. Read [Methods](METHODS.md) before adapting the example.

## Public data contract

The canonical model uses only these 22 reflective indicators:

| Block | Column names |
| --- | --- |
| ATT | ATT_1, ATT_2, ATT_3 |
| PBC | PBC_1, PBC_2, PBC_3, PBC_4 |
| INT | INT_1, INT_2, INT_3, INT_4, INT_5, INT_6 |
| SUB_NORM | SUB_NORM_1, SUB_NORM_2, SUB_NORM_3 |
| KNOWLEDGE | KNOWLEDGE_1, KNOWLEDGE_2, KNOWLEDGE_3 |
| MORAL_NORM | MORAL_NORM_1, MORAL_NORM_2, MORAL_NORM_3 |

INT is regressed on all five other constructs. Knowledge and moral norm are extensions to the original theoretical framework. Numeric response codes represent ordered categories; their storage type does not establish equal distances between categories. Consult the dictionary and generator for the implemented range and simulation choices.

Do not add identifiers, free text, location fields, demographic records, survey timestamps, device identifiers, or links to real records. Do not add any original response rows, covariance matrices, summary tables, or sample-size information. Even aggregate outputs can disclose private information or link the release to its source.

## Publication boundary

Only the reviewed **contents of `release/`** are candidates for public distribution. Before initializing Git, copy those contents offline into a new clean directory outside the working workspace. Never publish the entire problem node, workspace, or any `input/` directory. Do not copy parent folders, private audits, source documents, hidden histories, editor state, or unrelated artifacts.

An ignore file is a convenience, not a privacy boundary. It does not remove files that were already tracked, erase earlier commits, or prevent manual uploads. A clean export must be independently reviewed.

## Review before sharing

Check every public file and each archive's expanded contents, including hidden files.

- **Code and configuration:** remove absolute machine paths, local library paths, account names, organization identifiers, private file references, embedded tokens, and credentials.
- **Data:** confirm the generation process is independent simulation. Check column names, labels, factor levels, comments, and metadata for leakage. A neutral filename is not enough.
- **Results:** publish synthetic output only. Prefer plain CSV tables that are easy to inspect. Binary model objects, workspace images, spreadsheets, and project containers can embed raw observations or hidden metadata.
- **Provenance:** keep relative script/data references, relevant seeds, package versions, model labels, estimator choices, and synthetic-input integrity information. Do not include operating-system login details, hostnames, full environment dumps, absolute working directories, or private-input hashes.
- **Screenshots:** crop or redact title bars, account menus, file dialogs, terminal prompts, recent-file lists, notifications, and other open windows. Inspect the final image, not just the source document.
- **Logs:** review console output, stack traces, installation messages, session reports, and exported reports. These can reveal local paths or identifying values even when source code is clean.
- **Archives:** inspect archive filenames and directory names as well as contents. Avoid hidden `.git/`, editor backups, `.Rhistory`, `.RData`, and unsanitized generated reports.
- **Git history:** inspect all commits and author/committer metadata before any remote upload. Removing a file from the current view does not remove its history.

Do not assume a script's sanitized provenance makes every separate terminal log safe. A full `sessionInfo()` dump can contain machine-specific library paths; record the necessary reproducibility fields without sharing unreviewed environment details.

## Attribution is a separate disclosure channel

A neutral repository and sanitized data do not provide anonymity. Hosting accounts, commit metadata, organization membership, profile links, issue activity, and publication timing can link a release to an identity. A GitHub-provided noreply email hides an ordinary email address but can still link commits to the hosting account. It is not an anonymity service.

Citing a paper can directly break identity unlinkability by identifying its authors and linking the code to the publication. Omitting a citation must not be used to make misleading ownership or novelty claims. Resolve the publication, attribution, rights, and privacy requirements together before release. No author, paper citation, DOI, or persistent identifier is fabricated here.

## Reproducibility without private provenance

A useful public record describes the independently generated input, model, random seed, software versions, estimation choices, output format, and known limitations. It need not expose private source paths or participant records. Package-version recording improves auditability but does not itself freeze an environment; installation from a live package repository can resolve to newer versions later.

This package cannot establish exact paper replication without the actual analysis specification, scoring key, permitted data, and paper-specific estimator, missingness, identification, and software settings. Keep the distinction visible even if a future demonstration runs without errors.

## Licensing decision

The owner confirmed rights and approved these distinct scopes:

- Original code, original documentation and computed synthetic reference outputs: [MIT](../LICENSE), with `Ghospool` as the copyright label.
- Independently synthetic input/metadata CSV files under `data/` and `paper-example/data/`: [CC0 1.0 Universal](../LICENSE-DATA).
- The approved published PDF and article-derived reference material under `paper-example/reference/`, plus attributed article wording elsewhere: **CC BY 4.0**, as detailed in [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md).

MIT and CC0 do not relicense the article, third-party questionnaire content or private inputs. Preserve the article's attribution and license link and indicate adaptations. R packages, SmartPLS and other external sources retain their own terms. Licensing does not establish anonymity, measurement validity or numerical replication.

The public account and paper citation are intentional, approved attribution. They do not justify releasing respondent names, unpublished records or private provenance. Do not remove legally required notices to imply anonymity. This is practical publication guidance, not legal advice.
## If exposure is suspected

Stop distribution and notify the appropriate data owner through an approved private channel. Do not paste the material into a public issue. If secrets were exposed, follow the applicable credential-response process. Deleting a public file, making a repository private, or rewriting history cannot guarantee removal of copies, forks, caches, or previous downloads. Get explicit approval before any destructive history changes.

## Sources

- [GitHub Docs: Setting your commit email address](https://docs.github.com/en/account-and-profile/how-tos/email-preferences/setting-your-commit-email-address)
- [GitHub Docs: Licensing a repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
- [GitHub Docs: Source code archives and history](https://docs.github.com/en/repositories/working-with-files/using-files/downloading-source-code-archives)
