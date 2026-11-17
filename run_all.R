# Run from the release repository root with Rscript run_all.R or source('run_all.R').
# Paths deliberately use the current project root, not commandArgs('--file').
local({
  root <- getwd()
  required <- file.path(root, "R", c("config.R", "data.R", "analysis.R"))
  if (!all(file.exists(required))) {
    stop("Run from the repository root containing run_all.R and R/. Open tpb-sem.Rproj in RStudio.")
  }
  environment <- new.env(parent = baseenv())
  for (file in required) sys.source(file, envir = environment)
  environment$tpb_require_packages()
  data_dir <- file.path(root, "data")
  data_path <- file.path(data_dir, "synthetic_tpb.csv")
  provenance_path <- file.path(data_dir, "synthetic_provenance.csv")
  if (!file.exists(data_path)) environment$tpb_generate_files(data_dir)
  environment$tpb_run(data_path = data_path, provenance_path = provenance_path,
                      output_dir = getOption("tpb.output_dir", "outputs"))
})
