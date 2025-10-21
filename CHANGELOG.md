# Changelog

## Version 2.3.3

### Features
- Enable forte pipeline execution on JUNO cluster with proper configuration
- Update reportFusion01.R to version 5 output with additional columns for matching exon and sequence patterns
- Enhanced filtering criteria for fusion tables requiring minimum combined split and span counts

### Bug Fixes
- Use wildcard pattern for fusion table version numbers instead of hardcoded versions in runPost.sh

### Configuration
- Update eos.config for production cluster with direct scratch directory and new partition settings
- Update iris.config for new executor (SLURM) and resource settings
- Copy iris.config to forte/conf for proper configuration setup
- Switch to -profile config approach for IRIS branch

### Documentation
- Update README to reflect new development branch for IRIS

### Maintenance
- Remove obsolete iris.config backup file
- Remove obsolete forte nextflow config patch
- Apply additional patch in forte folder for setup completion

## Version 2.3.1

### Bug Fixes
- Fixed project number extraction in R scripts and runPost.sh to correctly retrieve the last project number from the current working directory

### Features
- Enhanced 00.SETUP.sh script to create local branch and copy eos.config based on current date
- Added fastqDirToBICMap.R script for creating mapping files from fastq sample directories

### Scripts
- Updated getPreAnnotationFile.R, reportFusion01.R, and reportKEJFusion.R with corrected project number extraction logic
- Modified runPost.sh to use proper project number extraction method

## Version 2.3.0

### Features
- Enhanced runForte.sh with dynamic cluster configuration and improved directory management
- Added getClusterName.sh script for dynamic cluster identification
- Enhanced runForte.sh to dynamically set configuration based on local network IP
- Enhanced runForte.sh for improved temporary directory management
- Enhanced clean_cff function for sample processing
- Updated runOncoKb.sh to use dynamic API bearer token
- Replaced iris.config with eos.config for improved configuration management
- Updated SETUP script to make necessary changes to forte module

### Configuration
- Added singularity configuration to iris.config
- Updated neo.config with new genome directory paths and executor settings
- Updated iris.config for executor and genome paths
- Explicitly set partition in iris.config
- Added configuration files for linters and VSCode
- Updated forte submodule to latest dev branch (3071d5b)

### Documentation
- Added README for configuration directory
- Updated README for devs-eos branch
- Marked README as development branch version

### Refactoring
- Renamed RDIR to WORKDIR and ODIR in runForte.sh for clarity

### Maintenance
- Applied patch to forte module in setup script
- Updated forte subproject commit references

## Version 2.2.1

- Added setup script for Nextflow and oncokb-annotator installation
- Fixed type issues
- Simplified sample ID generation in makeForteManifest.R
- Updated delivery email template to version 2.1.2
- Added PDF/HTML version of output

## Version 2.1.2
- Added delivery email template and script
- Output documentation created

## Version 2.1.1
- Add new fusion report
- Organization into 'post' directory
- Copy final fusion tables to output location

## Version 2.0.2
- Forte: Version 0b3d927 (main-241113) v-1.0.1-pre

---

See previous versions in README.md 