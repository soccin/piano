# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

PIANO is a wrapper around the [Forte](https://github.com/mskcc/forte) Nextflow
pipeline for RNA-Seq fusion calling, plus custom post-processing that annotates
fusions with [OncoKB](https://github.com/oncokb/oncokb-annotator) and produces
delivery reports. It runs on the MSKCC IRIS and JUNO HPC clusters (SLURM).

The repo is designed to be checked out **per project** (the working directory is
expected to contain a `Proj_<NUMBER>_<LETTER>` component in its path — many
scripts derive the project number from `$PWD`). See the current checkout path
under `Proj_16840_O/`.

## Pipeline flow

The pipeline runs in two stages driven by two entry-point scripts, then a
delivery step:

1. **`runForte.sh PROJECT_NO INPUT.csv`** — runs the Forte Nextflow pipeline.
   - Auto-detects the cluster via `bin/getClusterName.sh` and selects a Nextflow
     profile (`eos` for IRIS, `juno` for JUNO), setting cluster-specific
     `TMPDIR`, `WORKDIR`, and `NXF_SINGULARITY_CACHEDIR`.
   - Hardcoded to `--genome GRCh37`.
   - Writes results to `out/${PROJECT_NO}/`, and provenance (input csv, git tag,
     command) to `out/${PROJECT_NO}/runlog/`.
   - Designed to be submitted with `sbatch` (has `#SBATCH` headers). Relies on a
     custom `~/bin/sbatch` wrapper that exports `SBATCH_SCRIPT_DIR` so relative
     paths survive SLURM's temp-copy behavior.

2. **`runPost.sh`** — post-processes Forte output into fusion reports. Two phases:
   - **Phase I** (`R/getPreAnnotationFile.R` → `bin/runOncoKb.sh`): reads the
     `*.final.cff` files under `out/**/analysis/*/metafusion/`, builds a unique
     fusion list `${PROJNO}__UniqueFusions.tsv`, and runs OncoKB
     `FusionAnnotator.py` to produce `${PROJNO}__UniqueFusions.oncokb.tsv`.
   - **Phase II** (`R/reportFusion01.R`): joins CFF calls with the OncoKB
     annotations and writes `${PROJNO}__FusionTableV5.xlsx` (sheets `HC.Events`
     and `AllEvents`) plus `${PROJNO}__FusionTableV5__allEvents.csv`, then copies
     them into `post/`.

3. **`deliver.sh /path/to/delivery/folder/r_00x`** — rsyncs `out/*` (excluding
   `STAR/` and fastqs) to `<dest>/forte/`, copies `post/*` to `<dest>/post/`, and
   generates a `delivery.<PROJNO>.md` from `docs/delivery.tmpl.md` via
   `bin/makeDelivery.sh`.

Manifest helpers (for building the `INPUT.csv` Forte expects, columns
`sample,strand,fastq_1,fastq_2`): `fastqDirToBICMap.R` turns fastq sample dirs
into a `*_sample_mapping.txt`, and `makeForteManifest.R strand mapping.txt`
turns that into the Forte input CSV.

## Setup

First-time setup is `00.SETUP.sh` (run once, top-level, on each cluster). It:
- installs Nextflow into `bin/` (gitignored),
- creates a per-checkout working branch `local/<YYMMDD>` off master,
- copies `conf/eos.config` into `forte/conf/` and applies
  `patches/01-forte-3071d5b-250807` to the Forte submodule (then commits it),
- downloads and unpacks oncokb-annotator v3.4.1 into `oncokb-annotator/`
  (gitignored) and builds a `ve.oncokb` virtualenv from its requirements.

`forte/` is a git **submodule** (github.com/mskcc/forte). `oncokb-annotator/`,
`ve.oncokb/`, and `bin/nextflow` are gitignored and created by setup — they are
not tracked. OncoKB requires a token at `~/.credentials/oncokb_api_bearer_token`
(sourced by `bin/runOncoKb.sh`); `runOncoKb.sh` detects and reports an expired
token.

## Conventions and gotchas

- **Run each shell command separately.** Do not chain with `&&`, `;`, or `|`.
- **No emoji anywhere** — commits, docs, comments, code.
- **Project number extraction**: most scripts (shell and R) derive `PROJNO` by
  splitting `$PWD`/`getwd()` on `/` and taking the last `Proj_*` component. Code
  must be run from inside the per-project checkout for this to work.
- **The R scripts depend on `~/.Rprofile`** being auto-loaded. They use custom
  helpers defined there, notably `cc(...)` (paste with `sep="_"`), `len()`, and
  `halt()`. Because of this, `cc(projNo, "_UniqueFusions.tsv")` yields a
  **double** underscore (`Proj_..__UniqueFusions.tsv`) — this is intentional and
  is why `runPost.sh` globs `${PROJNO}__...`.
- **Fusion table version is wildcarded**: `runPost.sh` copies
  `${PROJNO}__FusionTableV?.xlsx` (note the `?`), so bumping the version suffix
  in `reportFusion01.R` (currently `V5`) does not require touching `runPost.sh`.
- Multi-sample reporting in `reportFusion01.R` is a known TODO — it currently
  falls back to the single-sample code path.

## R style

Follow the tidyverse-first conventions in the user's global CLAUDE.md (dplyr
verbs, `purrr::map`, `stringr`/`glue` for strings, base pipe `|>`, `readr`/`fs`).
Note the **existing** scripts predate this and mix `%>%`, base subsetting, and
`grep`/`gsub`; match the surrounding style when editing an existing script, but
prefer the tidyverse idioms for new code. `.lintr` disables several default
linters (assignment, infix spaces, commas, `T`/`F` symbol). Editor config
(`.vscode-settings.json`): 2-space indent for R/Rmd, no tab detection.

## Commit messages

Conventional Commits: `type(scope): description`, subject (with type/scope) ≤ 50
chars, body wrapped to ~60–72 chars. Common scopes here: `tempo`, `pipeline`,
`docs`, `scripts`, `conf`, `deliver`, `setup`, `R`, `post`. For pipeline changes
mention the affected workflow; for config changes name the config file. See
`.cursorrules` for the full spec and examples. Only commit when explicitly asked.

## Configs

Nextflow profiles live in `conf/` (`eos.config` for IRIS/production,
`neo.config`/`neo.config.v2` for the neo cluster). `eos.config` must be copied
into `forte/conf/` to take effect (done by `00.SETUP.sh`). These set the SLURM
executor, per-label resource limits, reference/igenomes base paths, and
Singularity options.
