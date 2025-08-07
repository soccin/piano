# PIANO: RNA-Seq Fusion Calling Pipeline

> *"Forte-Piano, orchestrating the symphony of RNA-Seq fusion 
detection."*

PIANO is a convience wrapper around the [Forte](https://github.com/mskcc/forte) pipeline for RNAseq fusion calling. It also collects a set of custom post-processing scripts for enhanced fusion annotation using the [OncoKb-Annotator](https://github.com/oncokb/oncokb-annotator) and custom reporting.

## Branch *devs-eos* (Ver: 2.2.1)

Development branch to try to get things working on IRIS. Eos is my code name for the new iris cluster. Will use this going forward to help prevent any file name or config name collisions with future developments on forte.

## Table of Contents
- [Overview](#overview)
- [Pipeline Structure](#pipeline-structure)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Directory and File Structure](#directory-and-file-structure)
- [Output Description](#output-description)
- [Scripts and Utilities](#scripts-and-utilities)
- [Documentation and References](#documentation-and-references)
- [Credits and Support](#credits-and-support)

---

## Overview

Piano orchestrates RNA-Seq fusion analysis by:
- Running the [Forte](https://github.com/mskcc/forte) pipeline for alignment, quantification, and fusion calling.
- Post-processing Forte outputs with custom R and shell scripts to generate detailed fusion reports and OncoKB annotations.
- Organizing results into structured output directories for easy delivery and review.

For details on the underlying methods, see [docs/method.md](docs/method.md).

---

## Pipeline Structure

1. **Primary Analysis:**
   - Performed by the Forte submodule (Nextflow-based pipeline).
   - Includes read preprocessing, alignment (STAR), quantification (featureCounts, Kallisto), and fusion calling (Arriba, FusionCatcher, STAR-Fusion).
2. **Post-processing:**
   - R scripts and shell utilities further annotate and summarize fusion results.
   - Generates Excel and CSV reports, and OncoKB fusion annotations.

---

## Installation

1. **Clone the repository with submodules:**
   ```bash
   git clone --recurse-submodules git@github.com:soccin/piano.git
   cd piano
   ```
2. **Install Nextflow:**
   ```bash
   cd bin
   curl -s https://get.nextflow.io | bash
   ```
   See [docs/install.md](docs/install.md) for more details.
3. **Install other dependencies:**
   - R (with required packages)
   - Python 3
   - Singularity or Docker (for containerized execution)
   - OncoKB annotator (see [oncokb-annotator](https://github.com/oncokb/oncokb-annotator))

---

## Quick Start

1. **Prepare your input CSV file.**
2. **Run the Forte pipeline:**
   ```bash
   ./runForte.sh <PROJECT_NO> <INPUT.csv>
   ```
   - This will execute the Forte pipeline and organize outputs in the `out/` directory.
3. **Run post-processing:**
   ```bash
   ./runPost.sh
   ```
   - This will generate the final fusion report and OncoKB annotations.
4. **Deliver results:**
   ```bash
   ./deliver.sh /path/to/delivery/folder/r_00x
   ```
   - Copies results to the specified delivery folder.

---

## Directory and File Structure

- `forte/` — Forte submodule (primary analysis pipeline)
- `R/` — Custom R scripts for post-processing and reporting
- `bin/` — Utility scripts (Nextflow, OncoKB runner)
- `conf/` — Configuration files for pipeline execution
- `docs/` — Documentation (installation, output, methods)
- `out/` — Output directory (created during pipeline run)
- `post/` — Post-processed results (created by runPost.sh)

---

## Output Description

The pipeline generates two main output directories:

```
{outdir}
├── forte/     # Primary analysis results (see Forte docs)
└── post/      # Post-processing results and reports
```

- **forte/**: Contains all standard Forte outputs (except BAM files). See [Forte output documentation](https://github.com/mskcc/forte/blob/main/docs/output.md).
- **post/**: Contains the consolidated fusion analysis report as `{ProjectNumber}_FusionTableV4.xlsx` (with high-confidence and all-events sheets) and `{ProjectNumber}_FusionTableV4__allEvents.csv`.

See [docs/output.md](docs/output.md) for more details.

---

## Scripts and Utilities

- **runForte.sh**: Main entry point to run the Forte pipeline with project and input CSV.
- **runPost.sh**: Runs post-processing R scripts and OncoKB annotation.
- **deliver.sh**: Copies results to a delivery folder, organizing forte and post outputs.
- **bin/runOncoKb.sh**: Runs OncoKB fusion annotation on the results.
- **R/**: Contains R scripts for report generation and data processing.

---

## Documentation and References

- [docs/install.md](docs/install.md): Installation instructions
- [docs/output.md](docs/output.md): Output file descriptions
- [docs/method.md](docs/method.md): Methods and pipeline details
- [forte/README.md](forte/README.md): Forte pipeline documentation
- [forte/docs/output.md](https://github.com/mskcc/forte/blob/main/docs/output.md): Forte output details

---

## Credits and Support

- The Forte pipeline was developed by Anne Marie Noronha in the Center for Molecular Oncology at MSKCC (see forte/README.md for full credits).
- Piano was developed by Nicholas Socci (soccin@mskcc.org) and the Bioinformatics Core at MSKCC.
- For questions or support, please contact the authors or open an issue on GitHub.

---

## Version

See [CHANGELOG.md](CHANGELOG.md) and [VERSION.md](VERSION.md) for release history and version details.
