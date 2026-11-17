# Demonstration settings are chosen independently of participant observations.
tpb_config <- function() {
  list(schema_version = "1", generator_version = "1.0.0", seed = 20250308L,
       n = 400L, thresholds = c(-1.2, -0.4, 0.4, 1.2),
       exogenous_correlation = 0.30,
       intention_coefficients = c(ATT = .28, PBC = .25, SUB_NORM = .18,
                                  KNOWLEDGE = .15, MORAL_NORM = .20),
       loadings = c(.72, .78, .84))
}

tpb_blocks <- function() {
  list(INT = paste0("INT_", 1:6), ATT = paste0("ATT_", 1:3),
       SUB_NORM = paste0("SUB_NORM_", 1:3), PBC = paste0("PBC_", 1:4),
       KNOWLEDGE = paste0("KNOWLEDGE_", 1:3),
       MORAL_NORM = paste0("MORAL_NORM_", 1:3))
}

tpb_items <- function() unlist(tpb_blocks(), use.names = FALSE)

tpb_measurement <- function(include_moral = TRUE) {
  blocks <- tpb_blocks()
  if (!include_moral) blocks$MORAL_NORM <- NULL
  paste(vapply(names(blocks), function(nm) {
    paste(nm, "=~", paste(blocks[[nm]], collapse = " + "))
  }, character(1)), collapse = "\n")
}

tpb_sem_model <- function(include_moral = TRUE) {
  predictors <- c("ATT", "PBC", "SUB_NORM", "KNOWLEDGE")
  if (include_moral) predictors <- c(predictors, "MORAL_NORM")
  paste(tpb_measurement(include_moral),
        paste("INT ~", paste(predictors, collapse = " + ")), sep = "\n")
}

tpb_require_packages <- function(packages = c("lavaan", "semTools", "psych")) {
  absent <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(absent)) {
    stop("Missing packages: ", paste(absent, collapse = ", "),
         ". Read install_packages.R; installation is manual.", call. = FALSE)
  }
}

tpb_config_text <- function(config = tpb_config()) {
  paste(c(paste0("n=", config$n), paste0("seed=", config$seed),
          paste0("thresholds=", paste(config$thresholds, collapse = ";")),
          paste0("exogenous_correlation=", config$exogenous_correlation),
          paste0("betas=", paste(names(config$intention_coefficients),
                                config$intention_coefficients, sep = ":", collapse = ";")),
          paste0("loadings_cycle=", paste(config$loadings, collapse = ";")),
          "item_residual_sd=sqrt(1-loading^2)", "latent_scale=unit_population_variance"),
        collapse = " | ")
}

tpb_write_csv <- function(x, path) {
  utils::write.table(x, file = path, sep = ",", row.names = FALSE,
                     col.names = TRUE, quote = TRUE, na = "", eol = "\n",
                     fileEncoding = "UTF-8")
}

tpb_output_dir <- function(path) {
  if (file.exists(path) && !dir.exists(path)) stop("Output path is not a directory.")
  if (dir.exists(path) && length(list.files(path, all.files = TRUE, no.. = TRUE))) {
    stop("Output directory must be empty; choose a new output_dir to avoid overwriting files.")
  }
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  if (!dir.exists(path)) stop("Could not create output directory.")
  invisible(path)
}
