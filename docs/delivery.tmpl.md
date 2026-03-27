Subject: RNA-Seq Fusion Calling Results

We have completed RNA-Seq fusion calling analysis for project {{PROJ_NO}} using the Piano pipeline (v2.3.3), which integrates three independent fusion callers (Arriba, FusionCatcher, and STAR-Fusion) and annotates results against the OncoKB knowledge base.

Samples Analyzed

{{SAMPLE_LIST}}

Delivered Files

The primary results are attached below:

- Proj_{{PROJ_NO}}__FusionTableV5.xlsx: Main fusion report (Excel workbook, two sheets)

Results Summary

The Excel workbook contains two sheets:

HC.Events (High Confidence) — Fusion events supported by at least two of the three callers and with a combined split-read + spanning-read count of 5 or more. These are the recommended primary results.

AllEvents — The complete set of all fusion events detected by any caller, including single-caller predictions. Useful for exploratory review or follow-up on specific genes of interest.

Both sheets include OncoKB annotations indicating oncogenicity, mutation effect, and actionability levels (therapeutic, diagnostic, and prognostic).

Full details on the output format and column descriptions are in docs/output.md.

Nicholas Socci
Bioinformatics Core
MSKCC
soccin@mskcc.org
