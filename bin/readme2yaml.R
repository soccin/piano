#
# Write project.yaml for the bicdelivery import
# (init_impact_project_permissions.py). PI and investigator
# usernames come from the request README; the rest is passed in
# by deliver.sh.
#

suppressPackageStartupMessages(library(tidyverse))

argv <- commandArgs(trailingOnly=TRUE)
if(length(argv) != 5) {
  cat("\n   usage: readme2yaml.R PIPELINE PROJNO RUNFOLDER ROOT GENOME\n\n")
  quit(status=1)
}
names(argv) <- c("pipeline", "project", "runfolder", "root", "genome")

# Request README is in the project folder (or its parent); skip any
# README (e.g. the repo one) that is not a request form
readmeFile <- crossing(name=c("README.md", "README.txt"), dir=c(".", "..")) |>
  mutate(path=fs::path(dir, name)) |>
  pull(path) |>
  keep(fs::file_exists) |>
  keep(\(f) any(str_detect(read_lines(f), "^Lab head / PI email:"))) |>
  head(1)
if(length(readmeFile) == 0) {
  cat("\n\nCan not find request README in current or parent folder\n\n")
  quit(status=1)
}

cat(str_glue("Processing {readmeFile} ...\n\n"))

readme <- read_lines(readmeFile) |>
  str_subset(": ") |>
  tibble(line=_) |>
  separate_wider_delim(line, ": ", names=c("key", "val"), too_many="merge") |>
  deframe()

emailUser <- function(key) {
  user <- readme[key] |> str_remove("@.*$") |> str_trim() |> str_to_lower()
  if(is.na(user) || user == "") {
    cat(str_glue("\n\nNo '{key}' in {readmeFile}\n\n"))
    quit(status=1)
  }
  unname(user)
}

project <- list(
  root=argv[["root"]],
  runfolder=argv[["runfolder"]],
  project=argv[["project"]],
  pi=emailUser("Lab head / PI email"),
  invest=emailUser("Your email"),
  genome=argv[["genome"]],
  pipeline=argv[["pipeline"]]
)

yaml::write_yaml(project, "project.yaml")
cat(yaml::as.yaml(project))

cat("\nDone.\n")
