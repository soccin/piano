---
mainfont: "CMU Concrete"
mathfont: "Concrete-Math"
monofont: "Fira Code"
fontsize: 11pt
geometry: margin=1in
---

# Piano: RNA-Seq Fusion Calling Pipeline Output

## Introduction

The Piano pipeline (v2.3.3) is a wrapper around the [Forte](https://github.com/mskcc/forte)
pipeline (v1.0.0, commit `0b3d927`) for RNA-Seq fusion calling. It runs three independent
fusion callers, merges and filters their predictions, annotates results against the
[OncoKB](https://www.oncokb.org/) knowledge base, and produces a consolidated report.

The working version of Forte used here includes patch `01-forte-3071d5b-250807` (commit
`20d39a1`), which applies the upstream bugfix for per-core memory allocation
(forte PR #162, `bugfix/percore_mem_alloc`).

## Output Structure

The pipeline generates two main output directories:

```
{outdir}/
├── forte/          # Primary analysis results (per-sample and batch)
└── post/           # Post-processing results and final reports
```

## Forte Directory

The `forte/` directory (located under `out/{ProjectID}/`) contains all standard Forte
pipeline outputs excluding BAM files. It is organized by sample:

```
forte/
├── analysis/
│   └── {SampleID}/
│       ├── arriba/           # Arriba fusion calls and visualizations
│       ├── fusioncatcher/    # FusionCatcher fusion calls
│       ├── starfusion/       # STAR-Fusion fusion calls
│       ├── metafusion/       # Merged/consolidated CFF files
│       ├── agfusion/         # Fusion protein domain visualizations
│       ├── agfusion_clinical/# Visualizations for clinically relevant fusions
│       └── multiqc/          # Per-sample QC report
├── multiqc/                  # Batch-level QC report
├── pipeline_info/            # Nextflow execution metadata
└── runlog/                   # Input files and execution log
```

For a full description of the Forte outputs, refer to the
[Forte output documentation](https://github.com/mskcc/forte/blob/main/docs/output.md).

## Post Directory

The `post/` directory contains the consolidated fusion analysis report produced by
Piano's post-processing scripts (`runPost.sh`). Post-processing performs two steps:

1. **OncoKB annotation** — unique gene-pair fusions are submitted to the OncoKB annotator
   (`FusionAnnotator.py`) to retrieve oncogenicity, mutation effect, and actionability levels.
2. **Report generation** — the R script `reportFusion01.R` reads the per-sample MetaFusion
   output (`.final.cff` files), merges OncoKB annotations, applies quality filters, and
   writes the final Excel and CSV reports.

### Delivered Files

| File                                          | Description                            |
|:----------------------------------------------|:---------------------------------------|
| `{ProjectNo}__FusionTableV5.xlsx`             | Main fusion report workbook (two sheets) |
| `{ProjectNo}__FusionTableV5__allEvents.csv`   | All detected fusion events (CSV)       |

An additional QC plot is generated in the working directory:

| File                    | Description                                               |
|:------------------------|:----------------------------------------------------------|
| `qcCallerOverlap.pdf`   | UpSet plot showing overlap among the three fusion callers |

## FusionTable Excel Workbook

The workbook `{ProjectNo}__FusionTableV5.xlsx` contains two sheets.

### HC.Events (High Confidence Events)

Fusion events that pass both of the following filters:

- Detected by **at least 2** of the 3 callers (`nCallers >= 2`)
- Combined read support: `max_split_cnt + max_span_cnt >= 5`

These represent the most reliable fusion predictions and are the recommended starting
point for analysis.

### AllEvents

The complete set of all detected fusion events, including single-caller predictions.
This is the full unfiltered table and is useful for exploratory analysis or when
investigating fusions in specific genes of interest. This sheet is also exported as the
CSV file `{ProjectNo}__FusionTableV5__allEvents.csv`.

\newpage
## Column Descriptions

| Column | Description |
|--------|-------------|
| `Sample` | Sample identifier |
| `Fusion` | Fusion gene pair in the form `Gene5--Gene3` |
| `Junction` | Genomic breakpoint coordinates (`chr:pos:strand`) for both partners |
| `max_split_cnt` | Maximum split-read count supporting the junction across callers |
| `max_span_cnt` | Maximum spanning-read count supporting the junction across callers |
| `FusionType` | Structural class of the fusion (e.g., `INTERCHROMOSOMAL`, `INTRACHROMOSOMAL`, `READ_THROUGH`) |
| `Fusion_effect` | Predicted effect on the reading frame (e.g., `in-frame`, `out-of-frame`, `frameshift`) |
| `Tools` | Semicolon-delimited list of callers that detected this event |
| `nCallers` | Number of callers that detected this event (1, 2, or 3) |
| `gene5_seq` | Junction sequence from the 5' gene partner |
| `gene3_seq` | Junction sequence from the 3' gene partner |
| `closest_exon5` | Nearest exon boundary for the 5' gene partner |
| `closest_exon3` | Nearest exon boundary for the 3' gene partner |
| `MUTATION_EFFECT` | OncoKB mutation effect classification (e.g., `Gain-of-function`, `Loss-of-function`) |
| `ONCOGENIC` | OncoKB oncogenicity classification (e.g., `Oncogenic`, `Likely Oncogenic`, `Unknown`) |
| `HIGHEST_LEVEL` | Highest OncoKB therapeutic actionability level (Levels 1-4, R1-R2) |
| `HIGHEST_SENSITIVE_LEVEL` | Highest level of sensitivity to a therapeutic agent |
| `HIGHEST_RESISTANCE_LEVEL` | Highest level of resistance to a therapeutic agent |
| `HIGHEST_DX_LEVEL` | Highest OncoKB diagnostic actionability level (Dx1-Dx3) |
| `HIGHEST_PX_LEVEL` | Highest OncoKB prognostic actionability level (Px1-Px3) |

### OncoKB Actionability Levels

OncoKB levels reflect the strength of clinical evidence supporting the annotation:

- **Level 1**: FDA-recognized biomarker predictive of response to an FDA-approved drug
- **Level 2**: Standard care biomarker recommended by professional guidelines
- **Level 3A/3B**: Clinical evidence from trials or other tumor types
- **Level 4**: Compelling biological evidence
- **R1/R2**: Standard care or investigational resistance biomarker
- **Dx1-Dx3**: Diagnostic levels (1 = FDA/guideline-approved)
- **Px1-Px3**: Prognostic levels (1 = FDA/guideline-approved)

Empty cells in OncoKB columns indicate no annotation is available in the current
OncoKB database for that gene pair.
