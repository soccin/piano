# RNAseq Fusion Pipeline

### Version 1.0.1

## Overview

RNAseq fusion calling were done using the FORTE pipeline [Forte2024], which is an nf-core/nextflow-based pipeline [Ewels2020]. The output was then post-processed using custom R scripts. These scripts, along with the code to run the pipeline and a link to the specific version of the FORTE code that was used, is available at this link: https://github.com/soccin/piano/tree/1.0.1

## Details

The FORTE pipeline is implemented using Nextflow and consists of five main steps: read preprocessing, alignment, quantification, fusion calling, and fusion merging and annotation.

Read preprocessing is performed using FastP, which provides quality metrics for the sequenced reads and trims them based on base quality and adapter sequence presence. For alignment, STAR, an ultrafast universal RNA-seq aligner, is utilized.

Quantification is carried out using two tools: featureCounts, which counts reads mapping to genomic features, and Kallisto, which quantifies transcript abundances from the RNA-Seq data. Fusion calling employs three different tools: Arriba, FusionCatcher, and STAR-Fusion. Arriba and STAR-Fusion both utilize the STAR aligner to detect gene fusions, while FusionCatcher searches for novel and known somatic fusion genes, translocations, and chimeras. The outputs are converted to CommonFusionFormat (CFF) files for compatibility with subsequent analysis tools.

In the final step, fusion merging and annotation are performed using a custom fork of MetaFusion to filter, cluster, and annotate the fusion calls. Fusion effect information is added using a modified version of AGFusion. Additionally, FusionAnnotator.py from the oncokb-annotator [OncoKb 2024] is employed to further annotate the final CFF file.

## References

Ewels, PA, Peltzer, A, Fillinger, S, et al. The nf-core framework for community-curated bioinformatics pipelines. Nat Biotechnol 38, 276--278 (2020). (https://doi.org/10.1038/s41587-020-0439-x)

Forte2024, version 1.0.0 (commit: e5df6ee) (https://github.com/mskcc/forte)

OncoKb2024, version 3.4.1 (https://github.com/oncokb/oncokb-annotator)
