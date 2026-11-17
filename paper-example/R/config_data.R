# Independent teaching reconstruction, not participant data or numerical replication.
paper_config <- function() {
  blocks <- list(ATT = paste0("ATT_", 1:4), INT = paste0("INT_", 1:3),
                 SUB_NORM = paste0("SUB_NORM_", 1:3), PBC = paste0("PBC_", 1:4),
                 MORAL_NORM = paste0("MORAL_NORM_", 1:4), KNOWLEDGE = paste0("KNOWLEDGE_", 1:2))
  order <- c("KNOWLEDGE", "SUB_NORM", "MORAL_NORM", "ATT", "PBC", "INT")
  edges <- data.frame(
    source = c("ATT", "MORAL_NORM", "SUB_NORM", "PBC", "KNOWLEDGE",
               "ATT", "KNOWLEDGE", "MORAL_NORM", "SUB_NORM", "KNOWLEDGE",
               "MORAL_NORM", "SUB_NORM", "KNOWLEDGE", "KNOWLEDGE"),
    target = c(rep("INT", 5), rep("PBC", 4), rep("ATT", 3), "MORAL_NORM", "SUB_NORM"),
    coefficient = c(.22, .18, .20, .24, .16, .20, .18, .16, .14, .24, .18, .20, .26, .32),
    stringsAsFactors = FALSE)
  items <- unlist(blocks, use.names = FALSE)
  measurement <- paste(vapply(names(blocks), function(x) {
    paste(x, "=~", paste(blocks[[x]], collapse = " + "))
  }, character(1)), collapse = "\n")
  structural <- paste(vapply(c("INT", "PBC", "ATT", "MORAL_NORM", "SUB_NORM"), function(x) {
    paste(x, "~", paste(edges$source[edges$target == x], collapse = " + "))
  }, character(1)), collapse = "\n")
  # Zero indicator residual covariances are lavaan's default. Explicitly fix
  # every between-factor disturbance covariance to zero in this reconstruction.
  pairs <- utils::combn(order, 2)
  zero_covariances <- paste(pairs[1, ], "~~ 0*", pairs[2, ], sep = "", collapse = "\n")
  list(n = 500L, seed = 20250309L, blocks = blocks, items = items, order = order,
       edges = edges, loadings = rep(c(.70, .75, .80), length.out = length(items)),
       thresholds = c(-.9, -.3, .3, .9),
       measurement = measurement,
       structural = paste(measurement, structural, zero_covariances, sep = "\n"),
       residual_covariance = 0, std.lv = TRUE,
       generator = "independent-raw-normal-recursive-v1;handchosen-not-paper-calibrated",
       rng = "Mersenne-Twister;Inversion;Rejection")
}

paper_dictionary <- function(config = paper_config()) {
  labels <- c("Marketing prospects", "Peer connections", "Learning access", "Sector contribution",
              "Joining plans", "Active participation", "Leadership interest",
              "Family encouragement", "Peer encouragement", "Adviser encouragement",
              "Entry affordability", "Entry feasibility", "Resource readiness", "Time autonomy",
              "Personal obligation", "Cooperation values", "Sector duty", "Mutual responsibility",
              "Membership awareness", "Operating awareness")
  data.frame(item = config$items,
             construct = rep(names(config$blocks), lengths(config$blocks)),
             short_label = labels, minimum = 1L, maximum = 5L,
             response_type = "synthetic ordered category", reverse_scored = FALSE,
             generating_loading = config$loadings,
             generating_thresholds = paste(config$thresholds, collapse = ";"),
             stringsAsFactors = FALSE)
}

paper_generation_config <- function(config = paper_config()) {
  data.frame(key = c("generator", "n", "seed", "rng", "items", "loadings", "thresholds",
                     "latent_order", "raw_coefficients", "disturbance_variances",
                     "residual_covariance", "response_scaling", "purpose"),
             value = c(config$generator, config$n, config$seed, config$rng,
                       paste(config$items, collapse = ";"), paste(config$loadings, collapse = ";"),
                       paste(config$thresholds, collapse = ";"), paste(config$order, collapse = ";"),
                       paste(paste(config$edges$source, config$edges$target,
                                   config$edges$coefficient, sep = ":"), collapse = ";"),
                       "all raw independent normal disturbances have variance 1", "0",
                       "loading * raw_latent / sqrt(theoretical_Sigma_diagonal) + independent_error",
                       "synthetic teaching only; no paper calibration; no participant input"),
             stringsAsFactors = FALSE)
}

paper_validate_data <- function(data, config = paper_config()) {
  if (!is.data.frame(data) || !identical(names(data), config$items) || ncol(data) != 20L) {
    stop("Data must have exactly the 20 dictionary columns in dictionary order, without extras.")
  }
  if (nrow(data) != config$n) stop("This teaching example requires exactly 500 synthetic rows.")
  valid <- vapply(data, function(x) is.numeric(x) && all(is.finite(x)) &&
                    all(x == floor(x)) && all(x >= 1 & x <= 5) && length(unique(x)) > 1L,
                  logical(1))
  if (!all(valid)) stop("Items must be finite, nonconstant integers 1..5, with no missing values.")
  invisible(TRUE)
}

paper_generate_data <- function(config = paper_config()) {
  old_kind <- RNGkind()
  had_seed <- exists(".Random.seed", envir = globalenv(), inherits = FALSE)
  if (had_seed) old_seed <- get(".Random.seed", envir = globalenv(), inherits = FALSE)
  on.exit({
    do.call(RNGkind, as.list(old_kind))
    if (had_seed) assign(".Random.seed", old_seed, envir = globalenv())
    else if (exists(".Random.seed", envir = globalenv(), inherits = FALSE))
      rm(list = ".Random.seed", envir = globalenv())
  }, add = TRUE)
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  set.seed(config$seed)
  B <- matrix(0, 6, 6, dimnames = list(config$order, config$order))
  B[cbind(match(config$edges$target, config$order), match(config$edges$source, config$order))] <- config$edges$coefficient
  A <- solve(diag(6) - B)
  Sigma <- A %*% t(A)
  disturbances <- matrix(stats::rnorm(config$n * 6), nrow = config$n)
  latent <- disturbances %*% t(A)
  colnames(latent) <- config$order
  dictionary <- paper_dictionary(config)
  response <- matrix(0L, config$n, length(config$items))
  for (j in seq_along(config$items)) {
    k <- match(dictionary$construct[j], config$order)
    continuous <- config$loadings[j] * latent[, k] / sqrt(Sigma[k, k]) +
      sqrt(1 - config$loadings[j]^2) * stats::rnorm(config$n)
    response[, j] <- as.integer(cut(continuous, breaks = c(-Inf, config$thresholds, Inf), labels = FALSE))
  }
  data <- as.data.frame(response)
  names(data) <- config$items
  paper_validate_data(data, config)
  data
}

paper_write_csv <- function(data, path) {
  utils::write.table(data, file = path, sep = ",", row.names = FALSE, col.names = TRUE,
                     quote = TRUE, na = "NA", eol = "\n", dec = ".", fileEncoding = "UTF-8")
}

paper_content_hash <- function(data) {
  path <- tempfile(fileext = ".csv")
  on.exit(unlink(path), add = TRUE)
  paper_write_csv(data, path)
  unname(tools::md5sum(path))
}

paper_materialize_data <- function(root = ".") {
  config <- paper_config()
  generated <- paper_generate_data(config)
  directory <- file.path(root, "paper-example", "data")
  paths <- file.path(directory, c("synthetic_paper_tpb.csv", "data_dictionary.csv", "synthetic_provenance.csv"))
  provenance <- rbind(paper_generation_config(config),
                      data.frame(key = "content_md5", value = paper_content_hash(generated)))
  expected <- list(generated, paper_dictionary(config), provenance)
  present <- file.exists(paths)
  if (any(present) && !all(present)) stop("Partial synthetic bundle exists; refusing overwrite or repair.")
  if (all(present)) {
    actual <- utils::read.csv(paths[1], check.names = FALSE)
    paper_validate_data(actual, config)
    for (j in seq_along(paths)) {
      if (!identical(unname(tools::md5sum(paths[j])), paper_content_hash(expected[[j]]))) {
        stop("Bundled synthetic content/configuration hash mismatch; refusing overwrite.")
      }
    }
    return(invisible(paths))
  }
  if (!dir.exists(directory) && !dir.create(directory, recursive = TRUE)) stop("Cannot create synthetic data directory.")
  # A pre-existing file is never replaced; this also catches a concurrent writer.
  for (j in seq_along(paths)) {
    con <- file(paths[j], open = "wx", encoding = "UTF-8")
    tryCatch(paper_write_csv(expected[[j]], con), finally = close(con))
  }
  invisible(paths)
}

paper_read_data <- function(root = ".") {
  paper_materialize_data(root)
  data <- utils::read.csv(file.path(root, "paper-example", "data", "synthetic_paper_tpb.csv"), check.names = FALSE)
  paper_validate_data(data)
  data
}
