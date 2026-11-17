# Optional common-latent-factor sensitivity, excluded from run_all.R.
# From root: source('R/clf.R'); run_optional_clf()
source("R/config.R", local = TRUE)
source("R/data.R", local = TRUE)
source("R/analysis.R", local = TRUE)

run_optional_clf <- function(data_path = "data/synthetic_tpb.csv",
                             provenance_path = "data/synthetic_provenance.csv",
                             output_dir = "outputs_clf") {
  warning(paste("Synthetic-only CLF sensitivity: a common factor is not proof of method bias.",
    "The model may be weakly identified, unstable, nonconvergent or inadmissible.",
    "Orthogonality is an assumption, not an empirical finding.",
    "Failure is reported as an error; success never establishes 'bias absent'."), call. = FALSE)
  tpb_require_packages()
  data <- tpb_read_data(data_path, provenance_path)
  tpb_output_dir(output_dir)
  # A measurement-level CLF sensitivity: six correlated traits plus an orthogonal
  # all-item method factor. No SEM regressions here, unlike the main analysis.
  method_model <- paste(tpb_measurement(),
    paste("METHOD =~", paste(tpb_items(), collapse = " + ")),
    paste("METHOD ~~", paste(paste0("0*", names(tpb_blocks())), collapse = " + ")),
    sep = "\n")
  baseline <- tpb_fit(data, "cfa", "WLSMV")
  clf <- lavaan::cfa(method_model, data = data, estimator = "WLSMV",
                      ordered = tpb_items(), std.lv = TRUE, mimic = "Mplus",
                      meanstructure = TRUE, missing = "listwise")
  if (as.integer(lavaan::lavInspect(clf, "nobs")) != nrow(data)) stop("Unexpected CLF observation loss.")
  tpb_assert_admissible(clf)
  covariance <- stats::vcov(clf)
  if (any(!is.finite(covariance)) ||
      min(eigen(covariance, symmetric = TRUE, only.values = TRUE)$values) <= 1e-10) {
    stop("CLF parameter covariance is singular/non-PD: possible weak identification.")
  }
  tpb_export_fit(baseline, "baseline_cfa_wlsmv", output_dir)
  tpb_export_fit(clf, "orthogonal_clf_wlsmv", output_dir)
  baseline_loadings <- lavaan::standardizedSolution(baseline)
  baseline_loadings <- baseline_loadings[baseline_loadings$op == "=~", c("lhs", "rhs", "est.std")]
  clf_loadings <- lavaan::standardizedSolution(clf)
  clf_loadings <- clf_loadings[clf_loadings$op == "=~" & clf_loadings$lhs != "METHOD",
                               c("lhs", "rhs", "est.std")]
  comparison <- merge(baseline_loadings, clf_loadings, by = c("lhs", "rhs"),
                       suffixes = c("_baseline", "_clf"), all = TRUE, sort = TRUE)
  if (nrow(comparison) != length(tpb_items()) || anyNA(comparison)) stop("Incomplete CLF loading comparison.")
  comparison$change <- comparison$est.std_clf - comparison$est.std_baseline
  tpb_write_csv(comparison, file.path(output_dir, "clf_trait_loading_sensitivity.csv"))
  tpb_write_csv(data.frame(
    assumption = c("method_factor", "identification", "interpretation", "comparison"),
    statement = c("METHOD loads on all 22 indicators; variance fixed to one; zero covariance with every trait",
      "Local checks do not prove global identification; weak identification remains possible",
      "No causal attribution, no automatic bias-absent conclusion, no universal loading-change cutoff",
      "Measurement-level sensitivity, not main structural SEM; no naive WLSMV chi-square subtraction")),
    file.path(output_dir, "clf_caveats.csv"))
  tpb_export_metadata(data_path, output_dir, "Optional orthogonal measurement CLF sensitivity; no bias-absence claim")
  invisible(list(baseline = baseline, clf = clf))
}
