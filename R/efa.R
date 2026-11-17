# Optional exploration, not part of run_all.R. Run from the repository root:
# source('R/efa.R'); run_optional_efa()
source("R/config.R", local = TRUE)
source("R/data.R", local = TRUE)
source("R/analysis.R", local = TRUE)

run_optional_efa <- function(data_path = "data/synthetic_tpb.csv",
                             provenance_path = "data/synthetic_provenance.csv",
                             output_dir = "outputs_efa") {
  warning("Synthetic-only exploratory analysis; not a CFA confirmation or paper reproduction.", call. = FALSE)
  tpb_require_packages()
  data <- tpb_read_data(data_path, provenance_path)
  tpb_output_dir(output_dir)
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) old_seed <- get(".Random.seed", envir = .GlobalEnv)
  old_kind <- RNGkind()
  old_options <- options(mc.cores = 1L)
  on.exit({
    options(old_options)
    do.call(RNGkind, as.list(old_kind))
    if (had_seed) assign(".Random.seed", old_seed, envir = .GlobalEnv)
    else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) rm(".Random.seed", envir = .GlobalEnv)
  }, add = TRUE)
  set.seed(tpb_config()$seed + 1L, kind = "Mersenne-Twister",
           normal.kind = "Inversion", sample.kind = "Rejection")
  poly <- psych::polychoric(data, smooth = FALSE, progress = FALSE)
  rho <- poly$rho
  if (any(!is.finite(rho)) || min(eigen(rho, symmetric = TRUE, only.values = TRUE)$values) <= 1e-8) {
    stop("Polychoric correlation is non-PD; do not smooth it silently.")
  }
  # Normal random-reference parallel analysis of the estimated polychoric matrix.
  # This is NOT category-preserving ordinal resampling; interpret heuristically.
  parallel <- psych::fa.parallel(rho, n.obs = nrow(data), fa = "fa", fm = "minres",
                                 n.iter = 50, plot = FALSE, error.bars = FALSE)
  factors <- parallel$nfact
  if (length(factors) != 1L || !is.finite(factors) || factors < 1L) {
    stop("Parallel analysis retained no valid positive factor count; no forced EFA solution.")
  }
  # Promax avoids adding a separate rotation-package requirement.
  efa <- psych::fa(rho, nfactors = factors, n.obs = nrow(data),
                   fm = "minres", rotate = "promax")
  if ((!is.null(efa$converged) && !isTRUE(efa$converged)) ||
      any(!is.finite(efa$uniquenesses)) || any(efa$uniquenesses <= 0)) {
    stop("EFA failed convergence/admissibility checks.")
  }
  if (!is.null(efa$Phi) &&
      min(eigen(efa$Phi, symmetric = TRUE, only.values = TRUE)$values) <= 1e-8) {
    stop("EFA factor correlation is non-PD.")
  }
  loadings <- unclass(efa$loadings)
  tpb_write_csv(data.frame(item = rownames(loadings), loadings, check.names = FALSE),
                file.path(output_dir, "efa_loadings.csv"))
  tpb_write_csv(data.frame(item = names(efa$uniquenesses), uniqueness = efa$uniquenesses),
                file.path(output_dir, "efa_uniquenesses.csv"))
  tpb_write_csv(data.frame(item = rownames(rho), rho, check.names = FALSE),
                file.path(output_dir, "polychoric_correlations.csv"))
  tpb_write_csv(data.frame(component = seq_along(parallel$fa.values),
                          observed_factor_eigenvalue = parallel$fa.values),
                file.path(output_dir, "parallel_observed_eigenvalues.csv"))
  tpb_write_csv(data.frame(retained_factors = factors, iterations = 50L,
    seed = tpb_config()$seed + 1L,
    caveat = "Normal-reference parallel analysis on polychoric matrix; not ordinal category-preserving resampling; same synthetic sample as CFA."),
    file.path(output_dir, "efa_specification.csv"))
  tpb_export_metadata(data_path, output_dir, "Optional polychoric minres/promax EFA; normal-reference parallel analysis")
  invisible(efa)
}
