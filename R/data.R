# Source R/config.R first. No empirical observations or fitted statistics are used.
tpb_simulate <- function() {
  config <- tpb_config()
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) old_seed <- get(".Random.seed", envir = .GlobalEnv)
  old_kind <- RNGkind()
  on.exit({
    do.call(RNGkind, as.list(old_kind))
    if (had_seed) assign(".Random.seed", old_seed, envir = .GlobalEnv)
    else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  set.seed(config$seed)
  sigma <- matrix(config$exogenous_correlation, 5, 5)
  diag(sigma) <- 1
  exogenous <- matrix(stats::rnorm(config$n * 5), config$n, 5) %*% chol(sigma)
  colnames(exogenous) <- names(config$intention_coefficients)
  beta <- config$intention_coefficients
  residual_variance <- 1 - drop(t(beta) %*% sigma %*% beta)
  if (residual_variance <= 0) stop("Invalid generator intention variance.")
  intention <- drop(exogenous %*% beta) +
    sqrt(residual_variance) * stats::rnorm(config$n)
  traits <- cbind(INT = intention, exogenous)
  blocks <- tpb_blocks()
  result <- vector("list", length(tpb_items()))
  names(result) <- tpb_items()
  k <- 0L
  for (factor in names(blocks)) {
    for (item in blocks[[factor]]) {
      k <- k + 1L
      loading <- config$loadings[(k - 1L) %% length(config$loadings) + 1L]
      response <- loading * traits[, factor] +
        sqrt(1 - loading^2) * stats::rnorm(config$n)
      result[[item]] <- as.integer(cut(response,
        breaks = c(-Inf, config$thresholds, Inf), labels = FALSE))
    }
  }
  as.data.frame(result, check.names = FALSE)
}

tpb_validate_data <- function(data) {
  expected <- tpb_items()
  if (!is.data.frame(data) || nrow(data) < 2L) stop("Expected a data frame with at least two rows.")
  if (anyDuplicated(names(data)) || length(names(data)) != length(expected) ||
      !setequal(names(data), expected)) {
    stop("CSV columns must contain exactly the 22 canonical items; no extras, omissions or duplicates.")
  }
  for (item in expected) {
    values <- data[[item]]
    if (!is.numeric(values) || anyNA(values) || any(!is.finite(values)) ||
        any(values != trunc(values)) || any(values < 1 | values > 5)) {
      stop("Item ", item, " must contain only nonmissing integer values from 1 to 5.")
    }
    if (length(unique(values)) < 2L) stop("Constant item: ", item)
  }
  data[, expected, drop = FALSE]
}

tpb_generate_files <- function(data_dir = "data") {
  files <- file.path(data_dir, c("synthetic_tpb.csv", "data_dictionary.csv",
                                 "synthetic_provenance.csv"))
  if (any(file.exists(files))) stop("Synthetic generator will not overwrite any existing destination.")
  dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)
  data <- tpb_validate_data(tpb_simulate())
  config <- tpb_config()
  blocks <- tpb_blocks()
  dictionary <- do.call(rbind, lapply(names(blocks), function(factor) {
    data.frame(item = blocks[[factor]], construct = factor,
               label = paste(factor, "indicator", seq_along(blocks[[factor]])),
               minimum = 1L, maximum = 5L, type = "ordinal_integer",
               note = "Generic identifier; questionnaire wording not supplied.",
               stringsAsFactors = FALSE)
  }))
  tpb_write_csv(data, files[1])
  tpb_write_csv(dictionary, files[2])
  provenance <- data.frame(
    key = c("data_type", "schema_version", "generator_version", "seed", "n",
            "data_md5", "generator_config"),
    value = c("independent_synthetic", config$schema_version, config$generator_version,
              as.character(config$seed), as.character(config$n),
              unname(tools::md5sum(files[1])), tpb_config_text()),
    stringsAsFactors = FALSE)
  tpb_write_csv(provenance, files[3])
  invisible(files)
}

tpb_read_data <- function(path = "data/synthetic_tpb.csv",
                          provenance_path = "data/synthetic_provenance.csv",
                          require_synthetic = TRUE) {
  data <- utils::read.csv(path, check.names = FALSE, stringsAsFactors = FALSE,
    na.strings = c("", "NA"), strip.white = TRUE, fill = FALSE,
    blank.lines.skip = FALSE, row.names = NULL, comment.char = "")
  data <- tpb_validate_data(data)
  if (require_synthetic) {
    if (!file.exists(provenance_path)) stop("Synthetic provenance sidecar is required.")
    p <- utils::read.csv(provenance_path, check.names = FALSE, stringsAsFactors = FALSE,
      colClasses = "character", fill = FALSE, blank.lines.skip = FALSE,
      row.names = NULL, comment.char = "")
    required <- c("data_type", "schema_version", "generator_version", "seed", "n",
                  "data_md5", "generator_config")
    if (!identical(names(p), c("key", "value")) || anyNA(p) ||
        anyDuplicated(p$key) || !setequal(p$key, required)) stop("Invalid provenance schema.")
    p <- stats::setNames(p$value, p$key)
    config <- tpb_config()
    expected <- c(data_type = "independent_synthetic", schema_version = config$schema_version,
                  generator_version = config$generator_version, seed = as.character(config$seed),
                  n = as.character(config$n), data_md5 = unname(tools::md5sum(path)),
                  generator_config = tpb_config_text())
    if (!identical(unname(p[names(expected)]), unname(expected)) || nrow(data) != config$n) {
      stop("Synthetic provenance does not match the file or current generator configuration.")
    }
  } else {
    warning("Synthetic provenance disabled explicitly; this run is not the bundled synthetic demonstration.")
  }
  data
}
