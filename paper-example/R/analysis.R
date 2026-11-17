paper_require_packages <- function() {
  packages <- c("lavaan", "semTools", "psych")
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) stop(paste("Install required packages explicitly before running:", paste(missing, collapse = ", ")))
  invisible(TRUE)
}

paper_fit_models <- function(data, config = paper_config()) {
  paper_require_packages()
  paper_validate_data(data, config)
  list(cfa_mlr = lavaan::cfa(config$measurement, data = data, estimator = "MLR",
                            std.lv = TRUE, missing = "listwise"),
       sem_mlr = lavaan::sem(config$structural, data = data, estimator = "MLR",
                            std.lv = TRUE, missing = "listwise", auto.cov.lv.x = FALSE,
                            auto.cov.y = FALSE),
       sem_wlsmv = lavaan::sem(config$structural, data = data, estimator = "WLSMV",
                              ordered = config$items, std.lv = TRUE, missing = "listwise",
                              auto.cov.lv.x = FALSE, auto.cov.y = FALSE))
}

paper_fit_gate <- function(fit, label) {
  if (!isTRUE(lavaan::lavInspect(fit, "converged"))) stop(paste(label, "did not converge."))
  parameters <- lavaan::parameterEstimates(fit)
  variances <- parameters[parameters$op == "~~" & parameters$lhs == parameters$rhs, "est"]
  if (!length(variances) || any(!is.finite(variances)) || any(variances <= 0)) {
    stop(paste(label, "has a nonpositive/nonfinite variance."))
  }
  matrices <- list(latent_covariance = lavaan::lavInspect(fit, "cov.lv"),
                   indicator_residual_covariance = lavaan::lavInspect(fit, "theta"),
                   implied_observed_covariance = lavaan::lavInspect(fit, "cov.ov"))
  rows <- lapply(names(matrices), function(name) {
    x <- matrices[[name]]
    if (!is.matrix(x) || any(!is.finite(x))) stop(paste(label, name, "is not finite."))
    minimum <- min(eigen(x, symmetric = TRUE, only.values = TRUE)$values)
    if (minimum <= 1e-8) stop(paste(label, name, "is not positive definite."))
    data.frame(model = label, gate = name, minimum_eigenvalue = minimum, passed = TRUE)
  })
  rbind(data.frame(model = label, gate = "convergence_and_positive_variances",
                   minimum_eigenvalue = NA_real_, passed = TRUE), do.call(rbind, rows))
}

paper_fit_table <- function(fit, label) {
  measures <- lavaan::fitMeasures(fit)
  conventional <- c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper", "srmr", "aic", "bic")
  scaled <- c("chisq.scaled", "df.scaled", "pvalue.scaled", "cfi.scaled", "tli.scaled", "rmsea.scaled", "rmsea.ci.lower.scaled", "rmsea.ci.upper.scaled")
  robust <- c("cfi.robust", "tli.robust", "rmsea.robust", "rmsea.ci.lower.robust", "rmsea.ci.upper.robust")
  do.call(rbind, lapply(c("conventional", "scaled", "robust"), function(family) {
    keys <- switch(family, conventional = conventional, scaled = scaled, robust = robust)
    available <- keys %in% names(measures)
    values <- rep(NA_real_, length(keys))
    values[available] <- unname(measures[keys[available]])
    data.frame(model = label, family = family, measure = keys, value = values,
               availability = ifelse(!available, "not returned by lavaan for this estimator",
                                     ifelse(is.na(values), "returned NA; no substitution", "returned")),
               stringsAsFactors = FALSE)
  }))
}

paper_parameter_tables <- function(fit, label) {
  raw <- lavaan::parameterEstimates(fit, standardized = FALSE, ci = TRUE, level = .95)
  raw <- raw[, c("lhs", "op", "rhs", "est", "se", "z", "pvalue", "ci.lower", "ci.upper")]
  raw$model <- label
  raw$scale <- "unstandardized; CI on unstandardized estimate"
  standardized <- lavaan::standardizedSolution(fit, type = "std.all", se = TRUE,
                                               zstat = TRUE, pvalue = TRUE, ci = TRUE, level = .95)
  standardized <- standardized[, c("lhs", "op", "rhs", "est.std", "se", "z", "pvalue", "ci.lower", "ci.upper")]
  standardized$model <- label
  standardized$scale <- "std.all; delta-method CI on standardized estimate"
  list(unstandardized = raw, standardized = standardized)
}

paper_effects <- function(standardized, config = paper_config()) {
  paths <- standardized[standardized$op == "~", , drop = FALSE]
  expected <- paste(config$edges$source, config$edges$target, sep = "->")
  actual <- paste(paths$rhs, paths$lhs, sep = "->")
  if (nrow(paths) != 14L || anyDuplicated(actual) || !setequal(expected, actual)) {
    stop("Structural output must contain exactly the 14 Table 6 directed edges.")
  }
  B <- matrix(0, 6, 6, dimnames = list(config$order, config$order))
  B[cbind(match(paths$lhs, config$order), match(paths$rhs, config$order))] <- paths$est.std
  if (any(!is.finite(B)) || any(B[upper.tri(B, diag = TRUE)] != 0)) stop("Effects require a finite recursive DAG.")
  total <- solve(diag(6) - B) - diag(6)
  indirect <- total - B
  power <- diag(6)
  expansion <- matrix(0, 6, 6)
  for (i in 1:5) {
    power <- power %*% B
    expansion <- expansion + power
  }
  if (max(abs(total - expansion)) > 1e-10 || max(abs(total - B - indirect)) > 1e-10) stop("Direct/indirect/total effect arithmetic failed.")
  grid <- expand.grid(target = config$order, source = config$order, stringsAsFactors = FALSE)
  grid$direct <- as.vector(B)
  grid$indirect <- as.vector(indirect)
  grid$total <- as.vector(total)
  grid$is_direct_edge <- paste(grid$source, grid$target, sep = "->") %in% expected
  grid$scale <- "std.all; inverse(I-B)-I; effects have no interval estimates"
  list(table = grid, direct = B, indirect = indirect, total = total)
}

paper_reference_comparison <- function(standardized, root, config = paper_config()) {
  path <- file.path(root, "paper-example", "reference", "published_paths.csv")
  if (!file.exists(path)) stop("Missing paper-example/reference/published_paths.csv; provide the approved published reference first.")
  reference <- utils::read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
  columns <- c("source", "target", "published_standardized", "published_se", "published_t", "source_table")
  if (!identical(names(reference), columns) || nrow(reference) != 14L) stop("Published path reference must have the six contract columns and 14 rows.")
  key <- paste(reference$source, reference$target, sep = "->")
  if (anyDuplicated(key) || !setequal(key, paste(config$edges$source, config$edges$target, sep = "->"))) stop("Published reference edge set differs from Table 6.")
  for (column in c("published_standardized", "published_se", "published_t")) {
    if (!is.numeric(reference[[column]]) || any(!is.finite(reference[[column]]))) stop("Published numeric reference values must be finite.")
  }
  if (any(reference$published_se < 0) || anyNA(reference$source_table) || any(!nzchar(reference$source_table))) stop("Invalid published reference metadata.")
  paths <- standardized[standardized$op == "~", , drop = FALSE]
  selected <- match(key, paste(paths$rhs, paths$lhs, sep = "->"))
  reference$synthetic_standardized <- paths$est.std[selected]
  reference$synthetic_standardized_ci_lower <- paths$ci.lower[selected]
  reference$synthetic_standardized_ci_upper <- paths$ci.upper[selected]
  reference$comparison <- "Published reference versus independent synthetic input; NOT numerical replication or a matching test"
  reference
}

paper_matrix_table <- function(x) {
  data.frame(construct = rownames(x), as.data.frame(x, check.names = FALSE), row.names = NULL, check.names = FALSE)
}

paper_measurement_diagnostics <- function(cfa, data, config = paper_config()) {
  correlations <- lavaan::lavInspect(cfa, "cor.lv")[names(config$blocks), names(config$blocks)]
  cr <- semTools::compRelSEM(cfa, tau.eq = FALSE, return.total = FALSE)
  ave <- semTools::AVE(cfa)
  if (!all(names(config$blocks) %in% names(cr)) || !all(names(config$blocks) %in% names(ave))) stop("Reliability/AVE output does not cover every factor.")
  reliability <- data.frame(construct = names(config$blocks),
                            composite_reliability = as.numeric(cr[names(config$blocks)]),
                            AVE = as.numeric(ave[names(config$blocks)]),
                            alpha = vapply(config$blocks, function(items) {
                              psych::alpha(data[, items, drop = FALSE], check.keys = FALSE, warnings = FALSE)$total$raw_alpha
                            }, numeric(1)), stringsAsFactors = FALSE)
  if (any(!is.finite(as.matrix(reliability[, -1])))) stop("Nonfinite measurement reliability result.")
  htmt <- as.matrix(semTools::htmt(config$measurement, data = data, absolute = TRUE, htmt2 = FALSE))
  htmt <- htmt[names(config$blocks), names(config$blocks)]
  if (any(!is.finite(htmt[lower.tri(htmt)]))) stop("Nonfinite numeric Pearson HTMT result.")
  fornell <- correlations
  diag(fornell) <- sqrt(reliability$AVE)
  flags <- do.call(rbind, lapply(seq_len(nrow(reliability)), function(i) {
    data.frame(construct = reliability$construct[i], alpha_below_070 = reliability$alpha[i] < .70,
               composite_below_070 = reliability$composite_reliability[i] < .70,
               AVE_below_050 = reliability$AVE[i] < .50,
               sqrt_AVE_not_above_absolute_latent_correlations = any(sqrt(reliability$AVE[i]) <= abs(correlations[i, -i])),
               note = "Contextual heuristic only; no automatic item deletion or validity verdict")
  }))
  pairs <- utils::combn(names(config$blocks), 2)
  htmt_flags <- data.frame(source = pairs[1, ], target = pairs[2, ],
                           HTMT_Pearson = vapply(seq_len(ncol(pairs)), function(i) {
                             a <- match(pairs[1, i], rownames(htmt))
                             b <- match(pairs[2, i], colnames(htmt))
                             htmt[max(a, b), min(a, b)]
                           }, numeric(1)))
  htmt_flags$above_085 <- htmt_flags$HTMT_Pearson > .85
  htmt_flags$above_090 <- htmt_flags$HTMT_Pearson > .90
  htmt_flags$note <- "Pearson observed-item HTMT, not latent correlation; thresholds contextual, no deletion"
  list(reliability = reliability, latent_correlations = paper_matrix_table(correlations),
       fornell_larcker = paper_matrix_table(fornell), htmt = paper_matrix_table(htmt),
       measurement_flags = flags, htmt_flags = htmt_flags)
}

paper_descriptives <- function(data, config = paper_config()) {
  scores <- as.data.frame(lapply(config$blocks, function(items) rowMeans(data[, items, drop = FALSE])))
  describe <- function(x) data.frame(n = length(x), mean = mean(x), sd = stats::sd(x),
                                    minimum = min(x), maximum = max(x), median = stats::median(x))
  list(items = do.call(rbind, lapply(data, describe)), observed_scale_means = do.call(rbind, lapply(scores, describe)),
       observed_scale_correlations = stats::cor(scores))
}

paper_harman_screen <- function(data) {
  efa <- psych::fa(data, nfactors = 1, rotate = "none", fm = "ml", scores = "none")
  share <- sum(as.matrix(efa$loadings)^2) / ncol(data)
  if (!is.finite(share)) stop("Legacy one-factor ML EFA screen failed.")
  data.frame(factors = 1L, variance_share = share, percent_total_standardized_item_variance = 100 * share,
             estimator = "legacy numeric Pearson ML EFA; no rotation",
             interpretation = "Descriptive Harman screen only; cannot establish absence of common-method bias")
}

paper_run_example <- function(root = ".", output_dir = getOption("paper.output_dir", file.path(root, "paper-example", "outputs"))) {
  if (!file.exists(file.path(root, "tpb-sem.Rproj")) || !file.exists(file.path(root, "paper-example", "R", "config_data.R"))) stop("Run from the repository root containing tpb-sem.Rproj and paper-example/.")
  paper_require_packages()
  if (!is.character(output_dir) || length(output_dir) != 1L || is.na(output_dir) || !nzchar(output_dir)) stop("paper.output_dir must be one nonempty path.")
  if (file.exists(output_dir) && !dir.exists(output_dir)) stop("Output path is a file; refusing overwrite.")
  if (dir.exists(output_dir) && length(list.files(output_dir, all.files = TRUE, no.. = TRUE))) stop("Output directory must be absent or completely empty; refusing overwrite.")
  config <- paper_config()
  if (!file.exists(file.path(root, "paper-example", "reference", "published_paths.csv"))) stop("Approved published_paths.csv is required before running.")
  data <- paper_read_data(root)
  models <- paper_fit_models(data, config)
  gates <- do.call(rbind, lapply(names(models), function(name) paper_fit_gate(models[[name]], name)))
  parameters <- lapply(names(models), function(name) paper_parameter_tables(models[[name]], name))
  names(parameters) <- names(models)
  effects <- list(sem_mlr = paper_effects(parameters$sem_mlr$standardized, config),
                  sem_wlsmv = paper_effects(parameters$sem_wlsmv$standardized, config))
  comparison <- paper_reference_comparison(parameters$sem_mlr$standardized, root, config)
  diagnostics <- paper_measurement_diagnostics(models$cfa_mlr, data, config)
  descriptive <- paper_descriptives(data, config)
  harman <- paper_harman_screen(data)
  specifications <- do.call(rbind, lapply(names(models), function(name) {
    options <- lavaan::lavInspect(models[[name]], "options")
    data.frame(model = name, requested_estimator = if (name == "sem_wlsmv") "WLSMV" else "MLR",
               engine_estimator = options$estimator, standard_errors = options$se,
               tests = paste(options$test, collapse = ";"),
               ordered_item_count = length(lavaan::lavNames(models[[name]], type = "ov.ord")),
               n = as.integer(lavaan::lavInspect(models[[name]], "nobs")), std_lv = options$std.lv,
               role = if (name == "sem_wlsmv") "separate ordinal sensitivity" else "primary continuous approximation")
  }))
  # No output is written until all numerical gates and summaries have completed.
  if (!dir.exists(output_dir) && !dir.create(output_dir, recursive = TRUE)) stop("Cannot create output directory.")
  if (length(list.files(output_dir, all.files = TRUE, no.. = TRUE))) stop("Output directory changed during fitting; refusing overwrite.")
  write <- function(x, name) {
    con <- file(file.path(output_dir, paste0(name, ".csv")), open = "wx", encoding = "UTF-8")
    tryCatch(paper_write_csv(x, con), finally = close(con))
  }
  write(gates, "fit_gates")
  write(specifications, "analysis_specification")
  write(do.call(rbind, lapply(names(models), function(name) paper_fit_table(models[[name]], name))), "fit_indices")
  for (name in names(models)) {
    write(parameters[[name]]$unstandardized, paste0(name, "_unstandardized_ci"))
    write(parameters[[name]]$standardized, paste0(name, "_standardized_ci"))
    r2 <- lavaan::lavInspect(models[[name]], "r2")
    write(data.frame(variable = names(r2), R_squared = as.numeric(r2)), paste0(name, "_r_squared"))
  }
  for (name in names(effects)) {
    write(effects[[name]]$table, paste0(name, "_effects"))
    for (kind in c("direct", "indirect", "total")) write(paper_matrix_table(effects[[name]][[kind]]), paste0(name, "_", kind, "_matrix"))
  }
  write(comparison, "reported_vs_synthetic_paths")
  for (name in names(diagnostics)) write(diagnostics[[name]], paste0("cfa_", name))
  # Row labels identify variables; descriptive statistic/correlation cells are numeric.
  write(data.frame(item = rownames(descriptive$items), descriptive$items, row.names = NULL), "observed_item_descriptives")
  write(data.frame(construct = rownames(descriptive$observed_scale_means), descriptive$observed_scale_means, row.names = NULL), "observed_scale_mean_descriptives")
  write(paper_matrix_table(descriptive$observed_scale_correlations), "observed_scale_mean_correlations")
  write(harman, "legacy_harman_one_factor_screen")
  write(data.frame(component = c("R", "lavaan", "semTools", "psych"),
                    version = c(as.character(getRversion()), vapply(c("lavaan", "semTools", "psych"), function(x) as.character(utils::packageVersion(x)), character(1)))), "versions")
  settings <- data.frame(key = c("purpose", "primary", "sensitivity", "measurement", "structural_disturbances",
                                "factor_scaling", "moderation", "Fornell_Larcker", "HTMT", "reliability",
                                "effects", "published_comparison", "data_content_md5"),
                         value = c("Paper-aligned teaching reconstruction; not exact numerical replication",
                                   "CFA and SEM MLR; integer categories treated as continuous approximation",
                                   "Separate WLSMV SEM; all 20 items declared ordered; not pooled with MLR",
                                   "Six factors, 20 reflective indicators; no residual indicator covariances",
                                   "All between-factor disturbance covariances fixed at zero: explicit reconstruction, not recovered original settings",
                                   "std.lv=TRUE; endogenous latent disturbance variances, not total latent variances, fixed to one",
                                   "No social-capital interaction specified or invented",
                                   "Diagonal sqrt(AVE), off-diagonal CFA latent correlations; compare absolute correlations on same scale, not squared correlations",
                                   "semTools::htmt on numeric items: Pearson item associations, not polychoric or CFA latent correlations",
                                   "semTools::compRelSEM congeneric model-based composite reliability and AVE from MLR CFA; raw alpha from numeric items",
                                   "std.all recursive DAG effects; point estimates only; total=direct+indirect verified by finite path expansion",
                                   "Source Tables 6/7 are reference context; Table 6 direct paths joined without matching tests or calibration",
                                   paper_content_hash(data)), stringsAsFactors = FALSE)
  write(rbind(paper_generation_config(config), settings), "sanitized_provenance")
  for (name in c("cfa", "sem")) {
    con <- file(file.path(output_dir, paste0(name, "_model.lav")), open = "wx", encoding = "UTF-8")
    tryCatch(writeLines(if (name == "cfa") config$measurement else config$structural, con, useBytes = TRUE), finally = close(con))
  }
  message("Paper-aligned synthetic teaching analysis completed; no numerical replication claim.")
  invisible(list(output_dir = output_dir, n = nrow(data), models = names(models),
                 direct_edges = nrow(config$edges), data_hash = paper_content_hash(data)))
}
