# Changelog

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