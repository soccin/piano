#!/bin/bash

SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$#" != "1" ]; then
    echo -e "\n   usage: deliver.sh /path/to/delivery/folder/r_00x\n"
    exit
fi

ODIR=$1
mkdir -p $ODIR/forte
mkdir -p $ODIR/post

rsync -avP  --exclude "STAR" --exclude="*.fastq.gz" out/* $ODIR/forte
cp post/* $ODIR/post

echo $ODIR
PROJNO=${ODIR##*/Proj_}
PROJNO=${PROJNO%%/*}
echo $PROJNO

echo
echo
cat $SDIR/docs/deliveryEmailTemplate.txt | sed "s/{PROJNO}/$PROJNO/g" | tee DELIVERY_EMAIL_$(date +%y%m%d)
echo
echo