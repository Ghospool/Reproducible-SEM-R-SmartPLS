# Explicit setup only. run_all.R never downloads or installs packages.
# Run this script deliberately from an R console or with Rscript.
local({
  packages <- c("lavaan", "semTools", "psych")
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    message("Installing missing dependencies from CRAN: ", paste(missing, collapse = ", "))
    user_library <- path.expand(Sys.getenv("R_LIBS_USER"))
    if (!nzchar(user_library)) {
      stop("R_LIBS_USER is not set. Configure a writable user library before setup.", call. = FALSE)
    }
    dir.create(user_library, recursive = TRUE, showWarnings = FALSE)
    if (!dir.exists(user_library) || file.access(user_library, 2L) != 0L) {
      stop("The configured user library is not writable. Resolve library permissions before setup.", call. = FALSE)
    }
    .libPaths(c(user_library, .libPaths()))
    utils::install.packages(missing, lib = user_library, repos = "https://cloud.r-project.org")
  }
  unavailable <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(unavailable)) {
    stop("Setup incomplete: ", paste(unavailable, collapse = ", "),
         ". Read the installation messages before running the analysis.", call. = FALSE)
  }
  versions <- vapply(packages, function(package) {
    as.character(utils::packageVersion(package))
  }, character(1))
  print(data.frame(package = packages, version = unname(versions)), row.names = FALSE)
  message("Dependencies are ready. Existing packages were not upgraded.")
})
