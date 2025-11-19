#!/bin/bash
#SBATCH -J PIANO
#SBATCH -o SLM/piano.%j.out
#SBATCH -c 4
#SBATCH -t 7-00:00:00
#SBATCH --partition cmobic_cpu,cmobic_pipeline

# bsub -o LSF/ -J CTRL-17495_D -W 3-00:00:00 -n 4

OPWD=$PWD

# Vanilla sbatch runs scripts from a temp folder copy, breaking
# relative paths. I have an sbatch wrapper (~/bin/sbatch) that
# preserves the original directory via:
#   sbatch --export=SBATCH_SCRIPT_DIR="$SCRIPT_DIR"
# allowing jobs to access their original location through
# $SBATCH_SCRIPT_DIR for proper path resolution.
#
if [ -n "$SBATCH_SCRIPT_DIR" ]; then
    SDIR="$SBATCH_SCRIPT_DIR"
else
    SDIR="$( cd "$( dirname "$0" )" && pwd )"
fi

ADIR=$(realpath $SDIR)
export PATH=$SDIR/bin:$PATH

if ! command -v nextflow &> /dev/null
then
    echo -e "\n   Need to install nextflow"
    echo -e "   Read piano/docs/install.md\n"
    exit 1
fi

if [ "$#" -lt "2" ]; then
    echo
    echo usage: runForte.sh PROJECT_NO INPUT.csv
    echo
    exit
fi

set -eu

PROJECT_ID=$1
INPUT=$(realpath $2)

export NXF_OPTS='-Xms1g -Xmx4g'
DS=$(date +%Y%m%d_%H%M%S)
UUID=${DS}_${RANDOM}

. $ADIR/bin/getClusterName.sh
echo \$CLUSTER=$CLUSTER
if [ "$CLUSTER" == "IRIS" ]; then

    CONFIG=eos
    export NXF_SINGULARITY_CACHEDIR=/scratch/core001/bic/socci/opt/singularity/cachedir
    export TMPDIR=/scratch/core001/bic/socci/Piano/$UUID
    export WORKDIR=/scratch/core001/bic/socci/Piano/$UUID/work

elif [ "$CLUSTER" == "JUNO" ]; then

    CONFIG=juno
    export NXF_SINGULARITY_CACHEDIR=/rtsess01/compute/juno/bic/ROOT/opt/singularity/cachedir_socci
    export TMPDIR=/scratch/socci
    export WORKDIR=work/$UUID

else

    echo -e "\nUnknown cluster: $CLUSTER\n"
    exit 1

fi

mkdir -p $TMPDIR
mkdir -p $NXF_SINGULARITY_CACHEDIR
mkdir -p $WORKDIR

ODIR=$(pwd -P)/out/${PROJECT_ID}

# #
# # Need each instance to run in its own directory
# #
# TUID=$(date +"%Y%m%d_%H%M%S")_$(uuidgen | sed 's/-.*//')
# RDIR=run/$PROJECT_ID/$TUID

# mkdir -p $RDIR
# cd $RDIR

LOG=${PROJECT_ID}_runForte.log

echo \$WORKDIR=$(realpath $WORKDIR) >$LOG
echo \$ODIR=$ODIR >>$LOG

#
# If the script is running in a terminal, then set ANSI_LOG to true
#
case $(ps -o stat= -p $$) in
  *+*) ANSI_LOG="true" ;;
  *) ANSI_LOG="false" ;;
esac

ANSI_LOG=false

nextflow run $ADIR/forte/ \
    -ansi-log $ANSI_LOG -resume \
    -profile $CONFIG \
    -work-dir $WORKDIR \
    --genome GRCh37 \
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
CLUSTER: $CLUSTER
PWD: $OPWD
WORKDIR: $WORKDIR
ODIR: $ODIR
CONFIG: $CONFIG

Script: $0 $*

nextflow run $ADIR/forte/ \
    -ansi-log $ANSI_LOG -resume \
    -profile $CONFIG \
    -work-dir $WORKDIR \
    --genome GRCh37 \
    --input $INPUT \
    --outdir $ODIR

END_VERSION
