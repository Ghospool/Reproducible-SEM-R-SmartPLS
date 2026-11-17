# Run from the release/repository root, either with Rscript or source().
# Set options(paper.autorun = FALSE) before sourcing for the public functions only.
paper_example <- local({
  root <- "."
  if (!file.exists(file.path(root, "tpb-sem.Rproj")) ||
      !file.exists(file.path(root, "paper-example", "R", "config_data.R"))) {
    stop("Working directory must be the repository root containing tpb-sem.Rproj and paper-example/.")
  }
  isolated <- new.env(parent = baseenv())
  sys.source(file.path(root, "paper-example", "R", "config_data.R"), envir = isolated)
  sys.source(file.path(root, "paper-example", "R", "analysis.R"), envir = isolated)
  isolated
})

# Public entry points share a private namespace and do not attach packages.
paper_config <- paper_example$paper_config
paper_dictionary <- paper_example$paper_dictionary
paper_generate_data <- paper_example$paper_generate_data
paper_validate_data <- paper_example$paper_validate_data
paper_content_hash <- paper_example$paper_content_hash
paper_materialize_data <- paper_example$paper_materialize_data
paper_read_data <- paper_example$paper_read_data
paper_run_example <- paper_example$paper_run_example

if (isTRUE(getOption("paper.autorun", TRUE))) paper_run_example()
