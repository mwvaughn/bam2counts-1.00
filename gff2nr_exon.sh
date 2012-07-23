#!/bin/bash 

# PATH extension
# BEDtools
export PATH=/usr/local3/bin/BEDTools-Version-2.15.0/bin:${PATH}
# SAMTools
export PATH=/usr/local3/bin/samtools-0.1.16:${PATH}
# This script
export PATH=/usr/local3/bin/bam2counts-1.00:${PATH}

ANNO="/usr/local3/bin/bam2counts-1.00/ZmB73_5a_WGS.gff"
LOCUS_REGEX='GRMZM[0-9]+G[0-9]+|[AE][A-Z][0-9]+\.[0-9]+_FG[0-9]+'
OUTPUT="ZmB73_5a_WGS_nr_exon.bed"

while getopts “?ha:r:o:” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         a)
             ANNO=$OPTARG
             ANNO=${ANNO/gtf/gff}
             ;;
         r)
             LOCUS_REGEX="$OPTARG"
             ;;

         o)
             OUTPUT=$OPTARG
             ;;
         ?)
             usage
             exit 1
             ;;
     esac
done

egrep -o -e "${LOCUS_REGEX}" ${ANNO} | sort | uniq > mrna.manifest

while read l; do
echo ${l}
egrep ${l} ${ANNO} | egrep "exon" | sortBed | mergeBed > merged.bed
egrep ${l} ${ANNO} | egrep "gene" > genes.gff
intersectBed -b genes.gff -a merged.bed -wa -wb -bed | cut -f 1,2,3,12 >> nr_exons.bed
done < mrna.manifest
sortBed -i nr_exons.bed > ${OUTPUT}

rm nr_exons.bed mrna.manifest merged.bed genes.gff

