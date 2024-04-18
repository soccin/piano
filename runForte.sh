#!/bin/bash

set -ue

OPWD=$PWD
SDIR="$( cd "$( dirname "$0" )" && pwd )"
ADIR=$(realpath $SDIR)

PROFILE=neo

export NXF_SINGULARITY_CACHEDIR=/rtsess01/compute/juno/bic/ROOT/opt/singularity/cachedir_socci
export TMPDIR=/scratch/socci
export PATH=$ADIR/bin:$PATH

if [ "$#" -lt "2" ]; then
    echo
    echo usage: runForte.sh PROJECT_NO INPUT.csv
    echo
    exit
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

echo nextflow run $ADIR/ -ansi-log false \
    -profile $PROFILE \
    --outDir $ODIR \
    >> $LOG 2> ${LOG/.log/.err}

mkdir -p $ODIR/runlog

cp $INPUT $ODIR/runlog

GTAG=$(git --git-dir=$ADIR/.git --work-tree=$ADIR describe --all --long --tags --dirty="-UNCOMMITED" --always)
GURL=$(git --git-dir=$ADIR/.git --work-tree=$ADIR config --get remote.origin.url)

cat <<-END_VERSION > $ODIR/runlog/cmd.sh.log
ADIR: $ADIR
GURL: $GURL
GTAG: $GTAG
PWD: $OPWD
RDIR: $RDIR

Script: $0 $*

END_VERSION
