# Standalone behavioural smoke/boundary checks: Rscript R/checks.R from root.
# Uses only dedicated temporary synthetic files. Requires installed dependencies.
local({
  for (file in c("R/config.R", "R/data.R", "R/analysis.R")) source(file, local = TRUE)
  tpb_require_packages()
  temporary <- tempfile("tpb_synthetic_checks_")
  dir.create(temporary)
  # All cleanup targets were created in this unique temporary directory.
  run_checks <- function() {
    on.exit(unlink(temporary, recursive = TRUE), add = TRUE)
    expect_error <- function(expression, pattern) {
      result <- tryCatch({ force(expression); NULL }, error = function(error) conditionMessage(error))
      if (is.null(result) || !grepl(pattern, result, fixed = TRUE)) {
        stop("Expected failure containing: ", pattern,
             "; observed: ", if (is.null(result)) "no error" else result)
      }
    }
    first <- tpb_simulate()
    second <- tpb_simulate()
    stopifnot(identical(first, second), nrow(first) == 400L, ncol(first) == 22L,
              identical(names(first), tpb_items()), identical(first, tpb_validate_data(first)))
    shuffled <- first[, rev(names(first))]
    stopifnot(identical(first, tpb_validate_data(shuffled)))
    cases <- list()
    cases$extra <- first; cases$extra$unexpected <- 1L
    cases$missing_column <- first[, -1]
    cases$missing_value <- first; cases$missing_value[1, 1] <- NA
    cases$constant <- first; cases$constant[, 1] <- 3L
    cases$fraction <- first; cases$fraction[1, 1] <- 2.5
    cases$range_low <- first; cases$range_low[1, 1] <- 0L
    cases$range_high <- first; cases$range_high[1, 1] <- 6L
    cases$infinite <- first; cases$infinite[1, 1] <- Inf
    cases$text <- first; cases$text[, 1] <- "invalid"
    cases$duplicate <- first; names(cases$duplicate)[2] <- names(first)[1]
    for (name in names(cases)) {
      pattern <- if (name %in% c("extra", "missing_column", "duplicate")) "CSV columns"
                 else if (name == "constant") "Constant item" else "must contain"
      expect_error(tpb_validate_data(cases[[name]]), pattern)
      invalid_path <- file.path(temporary, paste0(name, ".csv"))
      tpb_write_csv(cases[[name]], invalid_path)
      expect_error(tpb_read_data(invalid_path, require_synthetic = FALSE), pattern)
    }
    data_dir <- file.path(temporary, "data")
    tpb_generate_files(data_dir)
    data_path <- file.path(data_dir, "synthetic_tpb.csv")
    provenance_path <- file.path(data_dir, "synthetic_provenance.csv")
    before <- unname(tools::md5sum(data_path))
    stopifnot(isTRUE(all.equal(first, tpb_read_data(data_path, provenance_path), check.attributes = FALSE)))
    expect_error(tpb_generate_files(data_dir), "will not overwrite")
    stopifnot(identical(before, unname(tools::md5sum(data_path))))
    expect_error(tpb_read_data(data_path, file.path(temporary, "absent.csv")), "sidecar is required")
    tampered <- first
    tampered[1, 1] <- if (first[1, 1] == 5L) 4L else first[1, 1] + 1L
    tampered_path <- file.path(temporary, "tampered.csv")
    tpb_write_csv(tampered, tampered_path)
    expect_error(tpb_read_data(tampered_path, provenance_path), "provenance does not match")
    output_dir <- file.path(temporary, "outputs")
    fits <- tpb_run(data_path, provenance_path, output_dir)
    stopifnot(all(vapply(fits, function(fit) {
      isTRUE(lavaan::lavInspect(fit, "converged")) &&
        as.integer(lavaan::lavInspect(fit, "nobs")) == 400L
    }, logical(1))))
    manifest <- utils::read.csv(file.path(output_dir, "analysis_manifest.csv"))
    stopifnot(identical(manifest$n_items, c(22L, 22L, 22L, 19L)), all(manifest$n == 400L))
    for (name in names(fits)) {
      estimates <- utils::read.csv(file.path(output_dir, paste0(name, "_parameters.csv")))
      stopifnot(nrow(estimates) > 0, all(is.finite(estimates$est)))
    }
    provenance <- utils::read.csv(file.path(output_dir, "provenance.csv"))
    stopifnot(!any(grepl(temporary, provenance$value, fixed = TRUE)),
              provenance$value[provenance$key == "data_md5"] == before)
    expect_error(tpb_output_dir(output_dir), "must be empty")
    message("PASS: deterministic generation, strict boundaries, provenance, overwrite guards, and four-model smoke checks.")
  }
  run_checks()
})
