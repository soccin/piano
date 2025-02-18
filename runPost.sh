#!/bin/bash

set -ue

export SDIR="$( cd "$( dirname "$0" )" && pwd )"

PROJNO=$(echo $(pwd -P) | tr '/' '\n' | fgrep Proj_)

echo -e "\nPhase-I: Get OncoKb Annotations\n"
Rscript $SDIR/R/getPreAnnotationFile.R
$SDIR/bin/runOncoKb.sh ${PROJNO}__UniqueFusions.tsv


echo -e "\nPhase-II: Generate fusion report\n"
Rscript $SDIR/R/reportFusion01.R

mkdir -p post

cp ${PROJNO}__FusionTableV4.xlsx post/
cp ${PROJNO}__FusionTableV4__allEvents.csv post/


