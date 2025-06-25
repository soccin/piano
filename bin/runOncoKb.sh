#!/bin/bash

set -eu

SDIR="$( cd "$( dirname "$0" )" && pwd )"

INPUT=$1

source ~/.credentials/oncokb_api_bearer_token

. $SDIR/../ve.oncokb/bin/activate
python3 $SDIR/../oncokb-annotator/FusionAnnotator.py \
    -b $ONCOKB_API_BEARER_TOKEN \
    -i $INPUT \
    -o ${INPUT/.tsv/.oncokb.tsv}

deactivate
