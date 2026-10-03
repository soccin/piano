#!/bin/bash

SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# All writes to the delivery area run as the service account
BOT_USER=svc_core001_bot01
asbot() {
    dzdo -u "$BOT_USER" "$@"
}

# Default delivery path from .../Users/Aa/BBB/Proj_nnnnn/...
# -> aa/bbb/Proj_nnnnn (first two folders lowercased; project as-is)
CWD=$(pwd)
if [[ "$CWD" != *"/Users/"* ]]; then
    DPATH=""
else
    rest="${CWD#*/Users/}"
    IFS=/ read -r u1 u2 proj _ <<< "$rest"
    if [[ -n "$u1" && -n "$u2" && -n "$proj" ]]; then
        DPATH="$(printf '%s' "$u1" | tr '[:upper:]' '[:lower:]')/$(printf '%s' "$u2" | tr '[:upper:]' '[:lower:]')/$proj"
    else
        DPATH=""
    fi
fi

usage() {
    echo -e "\n   usage: deliver.sh /path/to/delivery/folder[/r_00x]"
    echo -e "          deliver.sh -d|--default"
    echo -e "\n   default: ${DPATH:-"(none)"}\n"
}

ODIR=""
USE_DEFAULT=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--default)
            USE_DEFAULT=1
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            ODIR="$1"
            shift
            ;;
    esac
done

DROOT=/data1/core002/res/bic/results

if [[ "$USE_DEFAULT" -eq 1 && -z "$ODIR" ]]; then
    if [[ -z "$DPATH" ]]; then
        echo "Error: no default delivery path for current directory"
        usage
        exit 1
    fi
    ODIR="$DROOT/$DPATH"
fi

if [[ -z "$ODIR" ]]; then
    usage
    exit
fi

# CURRDIR: trailing /r_NNN on ARG1 as-is; else next after latest in ODIR; else r_001
CURRDIR=r_001
if [[ "$ODIR" =~ /r_[0-9]+$ ]]; then
    CURRDIR="${ODIR##*/}"
    ODIR="${ODIR%/*}"
elif [[ -d "$ODIR" ]]; then
    last=$(ls -1 "$ODIR" | grep -E '^r_[0-9]+$' | sort | tail -1)
    if [[ "$last" =~ ^r_([0-9]+)$ ]]; then
        CURRDIR=$(printf 'r_%03d' $((10#${BASH_REMATCH[1]} + 1)))
    fi
fi

echo "ODIR=$ODIR"
echo "CURRDIR=$CURRDIR"

asbot mkdir -p "$ODIR/$CURRDIR/forte"
asbot mkdir -p "$ODIR/$CURRDIR/post"

asbot rsync -avP --exclude "STAR" --exclude="*.fastq.gz" out/ "$ODIR/$CURRDIR/forte"
asbot rsync -avP post/ "$ODIR/$CURRDIR/post"

PROJNO=$(ls -d out/* | cut -d/ -f2)
echo $PROJNO
SAMPLES=$(cat out/*/runlog/*_forte_input.csv | fgrep -v sample, | cut -f1 -d, | sort -V | uniq | paste -sd ',')

# Doc version is the release tag the run was built from
GTAG=$(sed -n 's/^GTAG: //p' out/*/runlog/cmd.sh.log | head -1)
if [[ "$GTAG" =~ ^(.+)-[0-9]+-g[0-9a-f]+(-UNCOMMITED)?$ ]]; then
    VERSION="${BASH_REMATCH[1]}"
else
    VERSION="UNKNOWN"
    echo "WARNING: cannot get version from GTAG=$GTAG; fix version in delivery doc"
fi

$SDIR/bin/makeDelivery.sh $PROJNO $SAMPLES $VERSION

# Import the project/run into bicdelivery. Genome is b37 because
# runForte.sh is hardcoded to GRCh37; root is the folder written above.
BIC_DELIVERY=$HOME/Code/BIC/Delivery/Version2j
if ! Rscript $SDIR/bin/readme2yaml.R piano $PROJNO $CURRDIR "$(realpath -s "$ODIR")" b37; then
    echo "ERROR: cannot write project.yaml; project not imported into bicdelivery"
    exit 1
fi

module purge
module load python/3.8.0
PYTHON38=$(which python3.8)
module load py-python-ldap/3.4.2
$PYTHON38 $BIC_DELIVERY/authorization_db/init_impact_project_permissions.py -p project.yaml

# echo
# echo
# cat $SDIR/docs/deliveryEmailTemplate.txt | sed "s/{PROJNO}/$PROJNO/g" | tee DELIVERY_EMAIL_$(date +%y%m%d)
# echo
# echo
