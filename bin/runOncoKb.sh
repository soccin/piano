#!/bin/bash

set -eu

SDIR="$( cd "$( dirname "$0" )" && pwd )"

INPUT=$1

source ~/.credentials/oncokb_api_bearer_token

. $SDIR/../ve.oncokb/bin/activate
python3 $SDIR/../oncokb-annotator/FusionAnnotator.py \
  -b $ONCOKB_API_BEARER_TOKEN \
  -i $INPUT \
  -o ${INPUT/.tsv/.oncokb.tsv} 2> oncokb.errors.log
deactivate

if grep -q "ERROR:AnnotatorCore:Error when validating token" oncokb.errors.log; then
  echo -e "\n   OncoKb token has expired"
  echo -e "\n   You need to update '~/.credentials/oncokb_api_bearer_token'"
  echo -e "\n   Remember to do this on all clusters\n"
  exit 1
fi
