#!/bin/bash

if [ "$#" != "1" ]; then
    echo -e "\n   usage: deliver.sh /path/to/delivery/folder/r_00x\n"
    exit
fi

ODIR=$1
mkdir -p $ODIR/forte
mkdir -p $ODIR/post

rsync -avP  out/* $ODIR/forte
cp post/* $ODIR/post

