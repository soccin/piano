#!/bin/bash

set -eu

SDIR="$( cd "$( dirname "$0" )" && pwd )"

INPUT=$1

. $SDIR/../ve.oncokb/bin/activate
python3 $SDIR/../oncokb-annotator/FusionAnnotator.py \
    -b 0f2476ae-6157-44a8-9f36-56718dce7864 \
    -i $INPUT \
    -o ${INPUT/.tsv/.oncokb.tsv}

deactivate
