#!/usr/bin/env bash

cpus=8

for x in *.txt; do cp $x ${x%.txt}.fileR; done

contiglist=$(cat *.fileR | sort | uniq ) 
cat *.fileR | sort | uniq > contiglist.tmp
fileList=$(ls *.fileR | cut -f1 -d".")

# file header
cat *.fileR | sort | uniq | tr "\n" "," > summary.csv
printf "x.values\n" >> summary.csv

# xargs each file

echo "$fileList" | xargs -I% -P ${cpus} \
sh -c   'cat contiglist.tmp | while IFS= read -r contigname ; do \
        if grep -q "$contigname" "%.fileR" ; then printf "1," >> "%.dataR" ; else printf "0," >> "%.dataR"; fi ; done && \
        printf "%\n" >> "%.dataR"'

cat *.dataR >> summary.csv

#echo "$contiglist" | while IFS= read -r contigname ; do 
#if grep -q "$contigname" CRC_meta-deepvirfinder.txt ; then printf "1,"  ; else printf "0," ; fi ; done