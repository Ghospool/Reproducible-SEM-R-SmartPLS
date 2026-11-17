# GitHub publication guide

## Destination and current status

The owner supplied [Ghospool/SEM---R-SmartPLS](https://github.com/Ghospool/SEM---R-SmartPLS) as the destination. Its clone address is:

```text
https://github.com/Ghospool/SEM---R-SmartPLS.git
```

**No push or upload has been performed.** The preparation environment could not execute Git, and unauthenticated web access returned 404. That can indicate a private or unavailable repository; it does not establish that the URL is wrong. Sign into the intended GitHub account to inspect the repository. Do not make it public merely to bypass an access problem.

The R verification status and known optional CLF failure are described in [VERIFICATION.md](../VERIFICATION.md). SmartPLS has not been executed.

## 1. Use only the clean package

Publish the reviewed public package, never the enclosing problem folder or workspace. The original participant files remain private outside it. The approved published PDF is an intentional public reference, not permission to upload any other private input.

1. Use the newly prepared paper-example export, or copy only the contents of `release/` into a clean directory outside the working workspace. Preserve earlier exports rather than overwriting them blindly.
2. Keep the root README, license texts, `CITATION.cff`, `THIRD_PARTY_NOTICES.md`, verification/contribution guides, R project and entry scripts, `R/`, `data/`, `docs/`, `example-results/`, **`paper-example/`**, `.gitignore` and `.gitattributes`.
3. Display hidden files. Exclude `.git/`, `input/`, private notes, extracted working OCR files, `.RData`, `.Rhistory`, credentials and unsanitized logs.
4. If using a ZIP, extract it first. The package files belong at repository root, not inside an extra `release/` directory. Uploading the ZIP alone does not expand it into a source repository.
5. Inspect existing remote contents and rights notices before uploading. Reconcile differences; do not discard history or overwrite unexpected files.

An ignore file does not sanitize tracked files or old commits. A clean export and reviewed file list are the main boundary. The paper PDF and published reference values must retain their article attribution and CC BY 4.0 notices.
## 2. Licenses and public attribution

The owner approved these scopes:

| Material | Terms |
|---|---|
| Original code, original guides and computed synthetic outputs | [MIT](../LICENSE), copyright label `Ghospool` |
| Independently synthetic input/metadata CSVs in both data directories | [CC0](../LICENSE-DATA) |
| Included article, published path reference and attributed article wording | CC BY 4.0; see [third-party notices](../THIRD_PARTY_NOTICES.md) |

MIT and CC0 do not relicense the article, private inputs or other third-party work. Preserve attribution and license links and identify adaptations.

The paper citation, DOI and reference PDF are now intentionally included with approval. They link the repository to the publication's named authors. The public account and Git author/committer metadata are also attribution channels; a noreply email hides an ordinary address, not account identity. Do not add participant names, private study details or unreviewed contact information.
## 3. Browser upload route

This route does not require a working local Git executable.

1. Sign into GitHub with the intended account and open the destination above. If it still returns 404, check the exact URL and account permissions; do not share an access token in chat.
2. Review the repository's visibility and existing files. On an empty repository, follow its **uploading an existing file** link; otherwise use **Add file → Upload files**.
3. Open the clean export directory locally. GitHub allows at most 100 files per browser upload. This expanded package has more than 100 files, so use two reviewed batches: first upload the root files and folders except `paper-example/`; then return to the repository root and upload the `paper-example/` folder with its hierarchy intact. Do not drag the enclosing workspace or upload the ZIP itself; a ZIP is not expanded automatically. Do not announce the release until both batches are present.
4. Check that `README.md`, both licenses and `run_all.R` are at the root, and that the R, data, docs and reference-result folders retain their relative structure.
5. Browser file pickers may omit hidden files. Include `.gitignore` and `.gitattributes`; if necessary create them separately from their reviewed contents. Browser uploads do not apply `.gitattributes` rules. Keep extracted CSV bytes unchanged and do not resave them in a spreadsheet, because provenance checks require the bundled content.
6. Inspect every pending filename. There must be no original inputs, private reports or logs.
7. Use a commit message such as `Add reproducible synthetic SEM tutorial`. Select the appropriate branch/PR route if the repository already has history or protection rules. Confirm the upload only after reviewing the exact set.
8. Inspect the online files and license display. Download a fresh ZIP and verify its layout before making a release announcement. Review visibility separately if the repository is currently private.

Do not add GitHub Actions, integrations or CI as part of this initial upload without separately reviewing their behavior and logs.

## 4. Optional local Git route

Use this route only where Git is permitted. Inspect the remote first:

```bash
git ls-remote --symref "https://github.com/Ghospool/SEM---R-SmartPLS.git" HEAD
```

An authentication error does not mean the repository is empty. For an existing repository, clone into a new directory, inspect its contents and history, then integrate the reviewed package without blindly overwriting conflicts:

```bash
git clone "https://github.com/Ghospool/SEM---R-SmartPLS.git"
```

For a confirmed empty remote, initialize only the separate clean export:

```bash
git init -b main
git remote add origin "https://github.com/Ghospool/SEM---R-SmartPLS.git"
```

Inside the reviewed clone or clean export, set local identity. Replace the email placeholder with the exact noreply address from the chosen account's settings; do not commit using the placeholder:

```bash
git config user.name "Ghospool"
git config user.email "YOUR_EXACT_GITHUB_NOREPLY_ADDRESS"
git config --get user.name
git config --get user.email
git status --short --untracked-files=all
```

Stage only the public package and inspect every path and diff:

```bash
git add README.md CONTRIBUTING.md VERIFICATION.md LICENSE LICENSE-DATA CITATION.cff THIRD_PARTY_NOTICES.md .gitignore .gitattributes tpb-sem.Rproj install_packages.R run_all.R R data docs example-results paper-example
git diff --cached --name-only
git diff --cached
```

Ensure generated run directories and private files are excluded, both examples remain distinct, and the article's attribution is preserved. If the exact set is correct:

```bash
git commit -m "Add published-paper SEM worked example"
git log --format=fuller
git remote -v
```

After checking branch, remote, identity, visibility and permissions, push the intended branch. For the confirmed-empty-remote `main` setup:

```bash
git push -u origin main
```

For an existing clone, use its actual reviewed branch and normal contribution process. Do not force-push, discard history or bypass protections to resolve a rejection. Never place passwords or tokens in commands or remote addresses. These instructions do not perform a commit or upload automatically.
## 5. Download ZIP: a beginner route for users

After publication, readers can select **Code → Download ZIP**, extract the archive and open `tpb-sem.Rproj`. They should follow [the R guide](R_GUIDE.md) from the directory containing `run_all.R`:

```bash
Rscript install_packages.R
Rscript run_all.R
```

Record the version tag or commit used. A moving-branch ZIP can change over time and contains only a snapshot, not the full Git history. Extraction does not certify that arbitrary files are safe to run.

## 6. Final review

- Include the full clean package, both original-work license texts, citation metadata and third-party notices.
- Keep generated observations and fitted outputs explicitly synthetic. Label the published PDF and reported path values as source references, not synthetic findings.
- Preserve the separate verification records, generic optional CLF limitation and unexecuted SmartPLS status.
- Keep the generic and paper indicator maps, estimators, data and output directories distinct.
- Inspect hidden files, archive entries, inherited history and account metadata. Permit only the approved paper/account attribution, never private participant details.
- Confirm destination, branch and visibility before uploading. Do not overwrite unexpected remote work or force-push around a conflict.
- Inspect the hosted result and a fresh download. Local preparation does not confirm remote publication.
## Sources

- [GitHub: File upload limits and browser workflow](https://docs.github.com/en/repositories/working-with-files/managing-files/adding-a-file-to-a-repository)
- [GitHub: Creating a new repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository)
- [GitHub: Setting your commit email address](https://docs.github.com/en/account-and-profile/how-tos/email-preferences/setting-your-commit-email-address)
- [GitHub: Licensing a repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
- [GitHub: Downloading source code archives](https://docs.github.com/en/repositories/working-with-files/using-files/downloading-source-code-archives)
