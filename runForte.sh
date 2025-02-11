#!/bin/bash

set -ue

OPWD=$PWD
SDIR="$( cd "$( dirname "$0" )" && pwd )"
ADIR=$(realpath $SDIR)

CONFIG=neo

export NXF_SINGULARITY_CACHEDIR=/rtsess01/compute/juno/bic/ROOT/opt/singularity/cachedir_socci
export NXF_OPTS='-Xms1g -Xmx4g'
export TMPDIR=/scratch/socci
export PATH=$ADIR/bin:$PATH

if [ "$#" -lt "2" ]; then
    echo
    echo usage: runForte.sh PROJECT_NO INPUT.csv
    echo
    exit
fi

if ! command -v nextflow &> /dev/null
then
    echo -e "\n   Need to install nextflow"
    echo -e "   Read piano/docs/install.md\n"
    exit 1
fi

PROJECT_ID=$1
INPUT=$(realpath $2)

ODIR=$(pwd -P)/out/${PROJECT_ID}

#
# Need each instance to run in its own directory
#
TUID=$(date +"%Y%m%d_%H%M%S")_$(uuidgen | sed 's/-.*//')
RDIR=run/$PROJECT_ID/$TUID

mkdir -p $RDIR
cd $RDIR

LOG=${PROJECT_ID}_runForte.log

echo \$RDIR=$(realpath .) >$LOG
echo \$ODIR=$ODIR >>$LOG

#
# If the script is running in a terminal, then set ANSI_LOG to true
#
case $(ps -o stat= -p $$) in
  *+*) ANSI_LOG="true" ;;
  *) ANSI_LOG="false" ;;
esac

nextflow run $ADIR/forte/ \
    -ansi-log $ANSI_LOG -resume \
    -profile juno \
    -config $ADIR/conf/${CONFIG}.config \
    --genome GRCh37 \
    --cosmic_usr soccin@mskcc.org \
    --run_oncokb_fusionannotator \
    --input $INPUT \
    --outdir $ODIR \
    2> ${LOG/.log/.err} \
    | tee -a $LOG

mkdir -p $ODIR/runlog

cp $INPUT $ODIR/runlog

GTAG=$(git --git-dir=$ADIR/.git --work-tree=$ADIR describe --long --tags --dirty="-UNCOMMITED" --always)
GURL=$(git --git-dir=$ADIR/.git --work-tree=$ADIR config --get remote.origin.url)

cat <<-END_VERSION > $ODIR/runlog/cmd.sh.log
ADIR: $ADIR
GURL: $GURL
GTAG: $GTAG
PWD: $OPWD
RDIR: $RDIR

Script: $0 $*

nextflow run $ADIR/forte/ \
    -ansi-log $ANSI_LOG -resume \
    -profile juno \
    -config $ADIR/conf/${CONFIG}.config \
    --genome GRCh37 \
    --cosmic_usr soccin@mskcc.org \
    --run_oncokb_fusionannotator \
    --input $INPUT \
    --outdir $ODIR

END_VERSION
