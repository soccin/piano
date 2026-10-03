#!/usr/bin/env Rscript
#
# Summarize Nextflow execution_trace.txt files from Forte runs, per
# process: task counts, requested resources, realtime and peak RSS
# quantiles, and the fraction finishing inside the IRIS 2h (cpushort)
# and 3h (cmobic_short) walltime caps. Used to tune conf/eos.config.
#
# usage: Rscript R/forteTraceSummary.R OUT_PREFIX trace1.txt [trace2.txt ...]
#
# Writes OUT_PREFIX.summary.tsv (per process) and OUT_PREFIX.tasks.tsv
# (one row per task) and prints the summary.
#
suppressPackageStartupMessages({
  library(tidyverse)
  library(glue)
})

args <- commandArgs(trailingOnly=TRUE)
if (length(args) < 2) {
  cat("\nusage: Rscript R/forteTraceSummary.R OUT_PREFIX trace1.txt [trace2.txt ...]\n\n")
  quit(status=1)
}
out_prefix <- args[1]
files <- args[-1]

# Nextflow human durations: "2d 2h", "1h 23m 4s", "347ms", "10.5s"
parse_dur <- function(x) {
  unit_s <- c(ms=1e-3, s=1, m=60, h=3600, d=86400)
  map_dbl(x, function(s) {
    if (is.na(s) || s == "-") return(NA_real_)
    toks <- str_split_1(s, " ")
    sum(map_dbl(toks, function(t) {
      v <- as.numeric(str_extract(t, "^[0-9.]+"))
      u <- str_extract(t, "[a-z]+$")
      v * unit_s[[u]]
    }))
  })
}

# Nextflow memory strings: "570.1 MB", "16 GB"; returns GB
parse_mem <- function(x) {
  unit_gb <- c(B=1/2^30, KB=1/2^20, MB=1/2^10, GB=1, TB=2^10)
  map_dbl(x, function(s) {
    if (is.na(s) || s == "-") return(NA_real_)
    v <- as.numeric(str_extract(s, "^[0-9.]+"))
    u <- str_extract(s, "[A-Za-z]+$")
    v * unit_gb[[u]]
  })
}

tasks <- map_dfr(files, function(f) {
  read_tsv(f, show_col_types=FALSE, col_types=cols(.default="c")) |>
    mutate(trace=f)
}) |>
  mutate(
    proc    = str_remove(process, "^MSKCC_FORTE:FORTE:"),
    real_h  = parse_dur(realtime) / 3600,
    peak_gb = parse_mem(peak_rss),
    req_gb  = parse_mem(memory),
    cpus    = as.integer(cpus),
    pcpu    = suppressWarnings(as.numeric(str_remove(`%cpu`, "%"))),
    attempt = as.integer(attempt)
  )

cat(glue("\nTrace files: {length(files)}; tasks: {nrow(tasks)}\n\n"))

cat("Status counts:\n")
tasks |> count(status, exit) |> print()

cat("\nRetries (attempt > 1):\n")
tasks |> filter(attempt > 1) |> count(proc, attempt) |> print(n=Inf)

summary_tbl <- tasks |>
  filter(status == "COMPLETED") |>
  group_by(proc) |>
  summarize(
    n        = n(),
    cpus     = str_c(sort(unique(cpus)), collapse="/"),
    req_gb   = str_c(sort(unique(round(req_gb))), collapse="/"),
    rt_p50   = median(real_h),
    rt_p90   = quantile(real_h, .9),
    rt_max   = max(real_h),
    lt2h     = mean(real_h < 2),
    lt3h     = mean(real_h < 3),
    rss_p50  = median(peak_gb, na.rm=TRUE),
    rss_p95  = quantile(peak_gb, .95, na.rm=TRUE),
    rss_max  = max(peak_gb, na.rm=TRUE),
    pcpu_p50 = median(pcpu, na.rm=TRUE),
    .groups="drop"
  ) |>
  arrange(desc(rt_max))

cat("\nPer-process summary (COMPLETED only; times in h, memory in GB):\n")
options(width=250)
summary_tbl |>
  mutate(across(where(is.numeric), ~round(.x, 2))) |>
  print(n=Inf)

write_tsv(summary_tbl, glue("{out_prefix}.summary.tsv"))
tasks |>
  select(trace, proc, status, exit, attempt, cpus, memory, time,
         realtime, real_h, peak_rss, peak_gb, pcpu) |>
  write_tsv(glue("{out_prefix}.tasks.tsv"))
