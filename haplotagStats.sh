#!/bin/bash

while getopts "i:r:" option; do
    case $option in 
        i) INPUT=$OPTARG ;;
        r) TARGET=$OPTARG ;;
    esac
done

RUSTSCRIPT="/n/scripts/haplotagParse"
HEADER="File\tRegion\tCoords\tDepth\tHP1\tHP2\tPercentAssigned"

FMR="chrX:147900000-148000000"
COL1A1="chr17:50150000-50250000"


# make temp for FMR
coord="${FMR##*:}"
chr="${FMR%:*}"
seq ${coord%-*} 1000 ${coord##*-} | awk -v chrom=$chr '{print chrom,$1,$1+1}' | tr ' ' '\t' > temp.positions

region=$FMR

samtools mpileup -r $region --positions temp.positions --ff SUPPLEMENTARY,UNMAP,SECONDARY,QCFAIL,DUP -q 1 -Q 1 --output-extra "PS,HP" $INPUT > temp.pileup.tsv

FMR_RESULTS=$( cut -f8 temp.pileup.tsv | $RUSTSCRIPT )

rm temp.positions
rm temp.pileup.tsv

###make temp for COL1A1

coord="${COL1A1##*:}"
chr="${COL1A1%:*}"
seq ${coord%-*} 1000 ${coord##*-} | awk -v chr=$chr '{print chr,$1,$1+1}' | tr ' ' '\t' > temp2.positions

region=$COL1A1

samtools mpileup -r $region --positions temp2.positions --ff SUPPLEMENTARY,UNMAP,SECONDARY,QCFAIL,DUP -q 1 -Q 1 --output-extra "PS,HP" $INPUT > temp2.pileup.tsv

COL1A1_RESULTS=$( cut -f8 temp2.pileup.tsv | $RUSTSCRIPT )

#rm temp.positions
#rm temp.pileup.tsv

###make temp for $TARGET

coord="${TARGET##*:}"
chr="${TARGET%:*}"
seq ${coord%-*} 1000 ${coord##*-} | awk -v chr=$chr '{print chr,$1,$1+1}' | tr ' ' '\t' > temp3.positions

region=$TARGET

samtools mpileup -r $region --positions temp3.positions --ff SUPPLEMENTARY,UNMAP,SECONDARY,QCFAIL,DUP -q 1 -Q 1 --output-extra "PS,HP" $INPUT > temp3.pileup.tsv

TARGET_RESULTS=$( cut -f8 temp3.pileup.tsv | $RUSTSCRIPT )

#rm temp.positions
#rm temp.pileup.tsv


###output results

echo -e "$HEADER"
echo -e "$INPUT\tFMR\t$FMR\t"${FMR_RESULTS[@]} | tr ' ' '\t'
echo -e "$INPUT\tCOL1A1\t$COL1A1\t"${COL1A1_RESULTS[@]} | tr ' ' '\t'
echo -e "$INPUT\tTARGET\t$TARGET\t"${TARGET_RESULTS[@]} | tr ' ' '\t'
