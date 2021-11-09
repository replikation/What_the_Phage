#!/usr/bin/env bash

# combine prediction results in one file with toolnames
for x in *.tsv; do
    filename_simple=$(echo "${x}" | cut -f 1 -d "_")
    cat ${x} | cut -f1,2 > ${filename_simple}.txt
done
awk '{print $0"\t"FILENAME}' *.txt >  tmp_result.tsv
awk '{ gsub(/.txt/,"", $3); print }' OFS='\t' tmp_result.tsv > tmp_results2.tsv
rm *.txt
sed -e '1i\contig_name\tp_value\ttoolname' tmp_results2.tsv > contig_tool_p-value_overview.tsv

## which tools were used?
#cut -f3 tmp_results2.tsv | sort -u > tools_used_for_phage_prediction.tsv

## contig was found by how many tools
## creates X_tools_agree_files with the contigs in it
## and a overview file abount toolagreements per contig
## does not take p value into consideration
#cut -f1 tmp_results2.tsv | sort -u > contig_list.txt
#mkdir tool_agreements
#inputfile='contig_list.txt'
#while read line; do
#    toolcount=$(tail -n+2 contig_tool_p-value_overview.tsv | grep $line | cut -f3 | sort -u | wc -l)
#    ctg=$(tail -n+2 contig_tool_p-value_overview.tsv | grep $line | cut -f1 | sort -u)
#    touch tool_agreements/"$toolcount"_tools_agree.txt | echo "$ctg" >> tool_agreements/"$toolcount"_tools_agree.txt
#    echo "$line    $toolcount"
#done < $inputfile > toolagreement_per_contig.tsv





