#!/bin/bash

set -eu

SDIR="$( cd "$( dirname "$0" )" && pwd )"

if [ $# -lt 2 ]; then
    echo "Usage: $(basename $0) <PROJ_NO> <SAMPLE1,SAMPLE2,...>"
    echo "Example: $(basename $0) 17929_I CTCL_HH_CL_R,CTCL_Hut78_CL_R"
    exit 1
fi

PROJ_NO=$1
SAMPLES_CSV=$2

TMPL=$SDIR/../docs/delivery.tmpl.md
OUT=$(pwd)/delivery.${PROJ_NO}.md

# Build bullet list from comma-delimited samples
SAMPLE_LIST=$(echo "$SAMPLES_CSV" | tr ',' '\n' | sed 's/^/- /')

sed \
    -e "s/{{PROJ_NO}}/${PROJ_NO}/g" \
    -e "/{{SAMPLE_LIST}}/{
        r /dev/stdin
        d
    }" "$TMPL" <<< "$SAMPLE_LIST" > "$OUT"

echo "Wrote $OUT"
