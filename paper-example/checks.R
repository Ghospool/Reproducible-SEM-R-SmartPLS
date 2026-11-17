# Separate behavioral checks; run from the repository root with Rscript.
# All generated fixtures/results stay in a fresh R temporary directory.
paper_run_checks <- local({
  isolated <- new.env(parent = baseenv())
  isolated$run <- function(root = ".") {
    if (!file.exists(file.path(root, "tpb-sem.Rproj"))) stop("Run checks from the repository root.")
    old_options <- options(c("paper.autorun", "paper.output_dir"))
    on.exit(options(old_options), add = TRUE)
    options(paper.autorun = FALSE)
    api <- new.env(parent = baseenv())
    sys.source(file.path(root, "paper-example", "run_paper_example.R"), envir = api)
    assert <- function(condition, label) {
      if (!isTRUE(condition)) stop(paste("FAILED:", label))
      message("PASS: ", label)
    }
    rejects <- function(expression, label) {
      failed <- tryCatch({ force(expression); FALSE }, error = function(e) TRUE)
      assert(failed, label)
    }
    csv <- function(path) utils::read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
    config <- api$paper_config()
    data <- api$paper_generate_data()
    assert(identical(data, api$paper_generate_data()), "deterministic synthetic observations")
    assert(nrow(data) == 500L && ncol(data) == 20L, "500 rows and exactly 20 columns")
    assert(identical(names(data), api$paper_dictionary()$item), "data columns follow public dictionary")
    assert(isTRUE(api$paper_validate_data(data)), "valid synthetic schema accepted")
    changed_seed <- config
    changed_seed$seed <- changed_seed$seed + 1L
    assert(!identical(data, api$paper_generate_data(changed_seed)), "seed is effective")
    assert(identical(api$paper_content_hash(data), api$paper_content_hash(api$paper_generate_data())), "deterministic content hash")
    bad <- data
    bad$extra <- 1L
    rejects(api$paper_validate_data(bad), "extra column rejected")
    rejects(api$paper_validate_data(data[, -1]), "missing column rejected")
    rejects(api$paper_validate_data(data[, rev(names(data))]), "reordered columns rejected")
    bad <- data
    names(bad)[2] <- names(bad)[1]
    rejects(api$paper_validate_data(bad), "duplicate column rejected")
    rejects(api$paper_validate_data(data[-1, ]), "incorrect sample size rejected")
    for (value in list(NA_real_, NaN, Inf, -Inf, 0, 6, 1.5, "wrong")) {
      bad <- data
      bad[1, 1] <- value
      rejects(api$paper_validate_data(bad), paste("malformed item rejected:", as.character(value)))
    }
    bad <- data
    bad[, 1] <- 3L
    rejects(api$paper_validate_data(bad), "constant item rejected")
    sandbox <- tempfile("paper-example-checks-")
    if (!dir.create(sandbox)) stop("Cannot create isolated checks directory.")
    message("Check fixtures retained in R's temporary directory only.")
    malformed_csv <- file.path(sandbox, "malformed.csv")
    bad <- data
    bad[1, 1] <- 6L
    utils::write.csv(bad, malformed_csv, row.names = FALSE)
    rejects(api$paper_validate_data(csv(malformed_csv)), "malformed CSV rejected after parsing")
    fixture <- file.path(sandbox, "repository")
    if (!dir.create(file.path(fixture, "paper-example", "R"), recursive = TRUE)) stop("Cannot create check repository.")
    if (!file.create(file.path(fixture, "tpb-sem.Rproj"))) stop("Cannot create fixture root marker.")
    code <- c("R/config_data.R", "R/analysis.R", "run_paper_example.R")
    for (name in code) {
      if (!file.copy(file.path(root, "paper-example", name), file.path(fixture, "paper-example", name), overwrite = FALSE)) stop("Cannot copy public check fixture code.")
    }
    if (!dir.create(file.path(fixture, "paper-example", "reference"))) stop("Cannot create fixture reference directory.")
    if (!file.copy(file.path(root, "paper-example", "reference", "published_paths.csv"),
                   file.path(fixture, "paper-example", "reference", "published_paths.csv"), overwrite = FALSE)) {
      stop("Checks require the parent-supplied approved published_paths.csv.")
    }
    bundle <- api$paper_materialize_data(fixture)
    hashes <- unname(tools::md5sum(bundle))
    api$paper_materialize_data(fixture)
    assert(identical(hashes, unname(tools::md5sum(bundle))), "bundled synthetic data idempotent without overwrite")
    assert(identical(api$paper_read_data(fixture), data), "CSV round trip preserves all synthetic responses")
    provenance <- csv(bundle[3])
    assert(all(c("generator", "seed", "n", "raw_coefficients", "loadings", "thresholds", "content_md5") %in% provenance$key), "provenance includes generation configuration and content hash")
    assert(identical(provenance$value[provenance$key == "content_md5"], unname(tools::md5sum(bundle[1]))), "provenance hash matches CSV bytes")
    altered <- csv(bundle[1])
    altered[1, 1] <- if (altered[1, 1] == 1L) 2L else 1L
    utils::write.csv(altered, bundle[1], row.names = FALSE)
    changed_hash <- unname(tools::md5sum(bundle[1]))
    rejects(api$paper_materialize_data(fixture), "modified bundled data refused")
    assert(identical(changed_hash, unname(tools::md5sum(bundle[1]))), "modified bundled data never overwritten")
    provenance_root <- file.path(sandbox, "provenance-repository")
    provenance_bundle <- api$paper_materialize_data(provenance_root)
    provenance <- csv(provenance_bundle[3])
    provenance$value[provenance$key == "seed"] <- "1"
    utils::write.csv(provenance, provenance_bundle[3], row.names = FALSE)
    changed_provenance_hash <- unname(tools::md5sum(provenance_bundle[3]))
    rejects(api$paper_materialize_data(provenance_root), "altered generation provenance refused")
    assert(identical(changed_provenance_hash, unname(tools::md5sum(provenance_bundle[3]))), "altered provenance preserved without repair")
    # Use a new fixture for fitting; never repair deliberately altered bundles.
    fit_root <- file.path(sandbox, "fit-repository")
    if (!dir.create(file.path(fit_root, "paper-example"), recursive = TRUE)) stop("Cannot create fit fixture.")
    if (!file.copy(file.path(fixture, "tpb-sem.Rproj"), fit_root)) stop("Cannot copy root marker.")
    if (!file.copy(file.path(fixture, "paper-example", "R"), file.path(fit_root, "paper-example"), recursive = TRUE)) stop("Cannot copy fit fixture code.")
    if (!file.copy(file.path(fixture, "paper-example", "reference"), file.path(fit_root, "paper-example"), recursive = TRUE)) stop("Cannot copy fit fixture reference.")
    partial_root <- file.path(sandbox, "partial")
    if (!dir.create(file.path(partial_root, "paper-example", "data"), recursive = TRUE)) stop("Cannot create partial fixture.")
    partial <- file.path(partial_root, "paper-example", "data", "synthetic_paper_tpb.csv")
    utils::write.csv(data, partial, row.names = FALSE)
    partial_hash <- unname(tools::md5sum(partial))
    rejects(api$paper_materialize_data(partial_root), "partial bundle refused")
    assert(identical(partial_hash, unname(tools::md5sum(partial))), "partial bundle preserved")
    output <- file.path(fit_root, "paper-example", "outputs")
    options(paper.output_dir = output)
    result <- api$paper_run_example(root = fit_root)
    assert(result$n == 500L && result$direct_edges == 14L && identical(result$output_dir, output), "n500 fit and output option contract")
    read_output <- function(name) csv(file.path(output, paste0(name, ".csv")))
    specification <- read_output("analysis_specification")
    assert(nrow(specification) == 3L && all(specification$n == 500L) && all(specification$std_lv), "all three fits use n500 and std.lv")
    ml <- specification[specification$model != "sem_wlsmv", ]
    ordinal <- specification[specification$model == "sem_wlsmv", ]
    assert(nrow(ml) == 2L && all(ml$requested_estimator == "MLR") && all(ml$engine_estimator == "ML") && all(ml$ordered_item_count == 0L), "primary MLR fits use numeric continuous approximation")
    assert(nrow(ordinal) == 1L && ordinal$requested_estimator == "WLSMV" && ordinal$engine_estimator == "DWLS" && ordinal$ordered_item_count == 20L, "WLSMV sensitivity uses all 20 ordered indicators separately")
    gates <- read_output("fit_gates")
    assert(nrow(gates) == 12L && all(gates$passed), "convergence variance and positive-definiteness gates passed")
    fit_indices <- read_output("fit_indices")
    assert(setequal(unique(fit_indices$family), c("conventional", "scaled", "robust")), "fit families separately exported")
    assert(all(is.na(fit_indices$value[fit_indices$availability != "returned"])), "unavailable fit indices remain NA rather than substituted")
    expected_source <- c("ATT", "MORAL_NORM", "SUB_NORM", "PBC", "KNOWLEDGE", "ATT", "KNOWLEDGE", "MORAL_NORM", "SUB_NORM", "KNOWLEDGE", "MORAL_NORM", "SUB_NORM", "KNOWLEDGE", "KNOWLEDGE")
    expected_target <- c(rep("INT", 5), rep("PBC", 4), rep("ATT", 3), "MORAL_NORM", "SUB_NORM")
    for (model in c("sem_mlr", "sem_wlsmv")) {
      effects <- read_output(paste0(model, "_effects"))
      direct <- effects[effects$is_direct_edge, ]
      assert(nrow(effects) == 36L && nrow(direct) == 14L && setequal(paste(direct$source, direct$target), paste(expected_source, expected_target)), paste(model, "exact 14 direct edges"))
      assert(max(abs(effects$total - effects$direct - effects$indirect)) < 1e-10, paste(model, "total equals direct plus indirect"))
      assert(all(effects$direct[!effects$is_direct_edge] == 0), paste(model, "no extra direct edges"))
      B <- as.matrix(read_output(paste0(model, "_direct_matrix"))[, -1])
      total <- as.matrix(read_output(paste0(model, "_total_matrix"))[, -1])
      indirect <- as.matrix(read_output(paste0(model, "_indirect_matrix"))[, -1])
      assert(max(abs(total - (solve(diag(6) - B) - diag(6)))) < 1e-10 && max(abs(total - B - indirect)) < 1e-10, paste(model, "public effect matrices obey recursive inverse identity"))
    }
    for (model in c("cfa_mlr", "sem_mlr", "sem_wlsmv")) {
      raw <- read_output(paste0(model, "_unstandardized_ci"))
      std <- read_output(paste0(model, "_standardized_ci"))
      assert("est" %in% names(raw) && !"est.std" %in% names(raw) && "est.std" %in% names(std) && !"est" %in% names(std), paste(model, "standardized and unstandardized exports distinct"))
      for (table in list(raw, std)) {
        selected <- table$op %in% c("=~", "~")
        estimate <- if ("est" %in% names(table)) table$est[selected] else table$est.std[selected]
        se <- table$se[selected]
        assert(all(is.finite(estimate)) && all(is.finite(se)) && all(is.finite(table$ci.lower[selected])) && all(is.finite(table$ci.upper[selected])), paste(model, "finite estimate and CI exports"))
        assert(max(abs(table$ci.lower[selected] - (estimate - stats::qnorm(.975) * se))) < 1e-7 && max(abs(table$ci.upper[selected] - (estimate + stats::qnorm(.975) * se))) < 1e-7, paste(model, "CI belongs to its own estimate and SE scale"))
      }
      key <- paste(raw$lhs, raw$op, raw$rhs)
      index <- match(paste(std$lhs, std$op, std$rhs), key)
      selected <- std$op %in% c("=~", "~")
      assert(any(abs(raw$est[index[selected]] - std$est.std[selected]) > 1e-5), paste(model, "scales not conflated"))
    }
    comparison <- read_output("reported_vs_synthetic_paths")
    assert(nrow(comparison) == 14L && all(is.finite(comparison$synthetic_standardized)), "published reference joined to all synthetic direct paths")
    reliability <- read_output("cfa_reliability")
    fornell <- as.matrix(read_output("cfa_fornell_larcker")[, -1])
    assert(nrow(reliability) == 6L && max(abs(diag(fornell) - sqrt(reliability$AVE))) < 1e-10, "Fornell-Larcker diagonal uses square root of AVE")
    for (name in c("observed_item_descriptives", "observed_scale_mean_descriptives", "observed_scale_mean_correlations")) assert(all(vapply(read_output(name)[, -1], is.numeric, logical(1))), paste(name, "numeric statistic cells"))
    output_paths <- list.files(output, full.names = TRUE)
    before <- unname(tools::md5sum(output_paths))
    rejects(api$paper_run_example(root = fit_root, output_dir = output), "nonempty analysis output refused")
    assert(identical(before, unname(tools::md5sum(output_paths))), "analysis output never overwritten")
    rejects(api$paper_run_example(root = fit_root, output_dir = output_paths[1]), "output file path refused")
    message("All paper-example behavioral checks passed.")
    invisible(TRUE)
  }
  environment(isolated$run) <- isolated
  isolated$run
})

if (isTRUE(getOption("paper.checks.autorun", TRUE))) paper_run_checks()
