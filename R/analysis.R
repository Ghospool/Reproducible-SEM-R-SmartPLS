# Fit checks are hard gates: no exports of inadmissible fitted models.
tpb_assert_admissible <- function(fit) {
  if (!isTRUE(lavaan::lavInspect(fit, "converged"))) stop("Model did not converge.")
  parameters <- lavaan::parameterEstimates(fit)
  variances <- parameters$op == "~~" & parameters$lhs == parameters$rhs
  if (any(!is.finite(parameters$est[variances])) || any(parameters$est[variances] < 0)) {
    stop("Model has negative or nonfinite variance estimates.")
  }
  covariance <- lavaan::lavInspect(fit, "cov.lv")
  if (any(!is.finite(covariance)) ||
      min(eigen(covariance, symmetric = TRUE, only.values = TRUE)$values) <= 1e-8) {
    stop("Latent covariance is not positive definite (tolerance 1e-8).")
  }
  if (!isTRUE(lavaan::lavInspect(fit, "post.check"))) stop("lavaan post-estimation checks failed.")
  invisible(fit)
}

tpb_fit <- function(data, kind = c("cfa", "sem"), estimator = c("WLSMV", "MLR"),
                    include_moral = TRUE) {
  kind <- match.arg(kind)
  estimator <- match.arg(estimator)
  data <- tpb_validate_data(data)
  # Excluding a factor is a named sensitivity specification, never a CSV cleanup rule.
  items <- tpb_items()
  if (!include_moral) items <- setdiff(items, tpb_blocks()$MORAL_NORM)
  model <- if (kind == "cfa") tpb_measurement(include_moral) else tpb_sem_model(include_moral)
  args <- list(model = model, data = data[, items, drop = FALSE],
               estimator = estimator, std.lv = TRUE, mimic = "Mplus",
               missing = "listwise", meanstructure = TRUE)
  if (estimator == "WLSMV") args$ordered <- items
  fitter <- if (kind == "cfa") lavaan::cfa else lavaan::sem
  fit <- do.call(fitter, args)
  if (as.integer(lavaan::lavInspect(fit, "nobs")) != nrow(data)) {
    stop("Unexpected observation loss: every analysis must use the complete validated sample.")
  }
  tpb_assert_admissible(fit)
  fit
}

tpb_vector_table <- function(x, value_name = "estimate") {
  values <- unlist(x, use.names = TRUE)
  answer <- data.frame(term = names(values), value = as.numeric(values), stringsAsFactors = FALSE)
  names(answer)[2] <- value_name
  answer
}

tpb_export_fit <- function(fit, prefix, output_dir) {
  tpb_assert_admissible(fit)
  tpb_write_csv(lavaan::parameterEstimates(fit, standardized = TRUE, ci = TRUE),
                file.path(output_dir, paste0(prefix, "_parameters.csv")))
  measures <- lavaan::fitMeasures(fit)
  requested <- c("npar", "chisq", "df", "pvalue", "chisq.scaled", "df.scaled",
                 "pvalue.scaled", "cfi", "tli", "rmsea", "rmsea.ci.lower",
                 "rmsea.ci.upper", "srmr", "cfi.scaled", "tli.scaled", "rmsea.scaled",
                 "cfi.robust", "tli.robust", "rmsea.robust", "rmsea.ci.lower.robust",
                 "rmsea.ci.upper.robust", "aic", "bic")
  # Unavailable measures (e.g. WLSMV AIC/BIC) stay NA; no silent substitution.
  values <- unname(measures[requested])
  indices <- data.frame(metric = requested, value = values,
    availability = ifelse(is.na(values), "unavailable_for_this_fit", "returned_by_lavaan"))
  tpb_write_csv(indices, file.path(output_dir, paste0(prefix, "_fit.csv")))
  correlation <- lavaan::lavInspect(fit, "cor.lv")
  tpb_write_csv(data.frame(factor = rownames(correlation), correlation, check.names = FALSE),
                file.path(output_dir, paste0(prefix, "_latent_correlations.csv")))
  r2 <- lavaan::lavInspect(fit, "rsquare")
  tpb_write_csv(tpb_vector_table(r2, "r_squared"),
                file.path(output_dir, paste0(prefix, "_r2.csv")))
}

tpb_export_reliability <- function(cfa, data, output_dir) {
  reliability <- semTools::compRelSEM(cfa, tau.eq = FALSE, ord.scale = TRUE)
  ave <- semTools::AVE(cfa)
  tpb_write_csv(tpb_vector_table(reliability, "composite_reliability_ordinal_scale"),
                file.path(output_dir, "cfa_wlsmv_composite_reliability.csv"))
  tpb_write_csv(tpb_vector_table(ave, "ave_latent_response_scale"),
                file.path(output_dir, "cfa_wlsmv_ave.csv"))
  alpha <- do.call(rbind, lapply(names(tpb_blocks()), function(factor) {
    items <- tpb_blocks()[[factor]]
    result <- psych::alpha(data[, items, drop = FALSE], check.keys = FALSE,
                           warnings = TRUE, n.iter = 1)
    data.frame(factor = factor, n_items = length(items),
               raw_alpha = result$total$raw_alpha, standardized_alpha = result$total$std.alpha,
               caveat = "Pearson alpha treats ordinal categories as numeric; not ordinal alpha, validity evidence, or a unidimensionality test.")
  }))
  tpb_write_csv(alpha, file.path(output_dir, "observed_category_alpha.csv"))
}

tpb_export_metadata <- function(data_path, output_dir, analysis) {
  packages <- c("lavaan", "semTools", "psych")
  versions <- data.frame(component = c("R", packages),
    version = c(as.character(getRversion()),
                vapply(packages, function(x) as.character(utils::packageVersion(x)), character(1))))
  tpb_write_csv(versions, file.path(output_dir, "versions.csv"))
  config <- tpb_config()
  provenance <- data.frame(
    key = c("data_type", "warning", "schema_version", "generator_version", "seed",
            "n", "data_md5", "generator_config", "analysis", "estimation_config", "rng"),
    value = c("independent_synthetic", "Synthetic demonstration only; never paper reproduction.",
      config$schema_version, config$generator_version, as.character(config$seed),
      as.character(config$n), unname(tools::md5sum(data_path)), tpb_config_text(), analysis,
      "std.lv=TRUE; mimic=Mplus; complete validated sample; no missing values or automatic deletion",
      "Mersenne-Twister; Inversion; Rejection"))
  # Explicit allowlisted fields: never serialize sessionInfo(), calls, or local paths.
  tpb_write_csv(provenance, file.path(output_dir, "provenance.csv"))
}

tpb_run <- function(data_path = "data/synthetic_tpb.csv",
                     provenance_path = "data/synthetic_provenance.csv",
                     output_dir = "outputs") {
  warning("SYNTHETIC DEMONSTRATION ONLY: these results never reproduce the published paper.",
          call. = FALSE, immediate. = TRUE)
  tpb_require_packages()
  data <- tpb_read_data(data_path, provenance_path, require_synthetic = TRUE)
  tpb_output_dir(output_dir)
  # Estimate all four fits before exporting any model results.
  fits <- list(cfa_wlsmv = tpb_fit(data, "cfa", "WLSMV"),
               sem_wlsmv = tpb_fit(data, "sem", "WLSMV"),
               sem_mlr_continuous = tpb_fit(data, "sem", "MLR"),
               sem_wlsmv_without_moral = tpb_fit(data, "sem", "WLSMV", include_moral = FALSE))
  for (name in names(fits)) tpb_export_fit(fits[[name]], name, output_dir)
  tpb_export_reliability(fits$cfa_wlsmv, data, output_dir)
  specification <- data.frame(
    analysis = names(fits),
    estimator = c("WLSMV", "WLSMV", "MLR", "WLSMV"),
    item_treatment = c("ordered", "ordered", "continuous_approximation", "ordered"),
    n = nrow(data), n_items = c(22L, 22L, 22L, 19L),
    note = c("Six-factor correlated CFA", "Main five-predictor intention SEM",
             "Same rows/items as main SEM; different estimator and measurement approximation",
             "Distinct sensitivity: removes MORAL_NORM measurement and predictor, not original main model"))
  tpb_write_csv(specification, file.path(output_dir, "analysis_manifest.csv"))
  tpb_export_metadata(data_path, output_dir, "CFA WLSMV; main SEM WLSMV; continuous MLR; no-moral WLSMV")
  message("Completed synthetic demonstration. Outputs: ", output_dir)
  invisible(fits)
}
