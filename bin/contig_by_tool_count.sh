

# combine prediction results in one file with toolnames
for x in *.tsv; do
    filename_simple=$(echo "${x}" | cut -f 1 -d "_")
    cat ${x} | cut -f1,2 > ${filename_simple}.txt
done
awk '{print $0"\t"FILENAME}' *.txt >  tmp_result.tsv
awk '{ gsub(/.txt/,"", $3); print }' OFS='\t' tmp_result.tsv > tmp_results2.tsv
rm *.txt

sed -e '1i\contig_name\tp-value\ttoolname' tmp_results2.tsv > all_overview.tsv



## which tools were used?
cut -f3 tmp_results2.tsv | sort -u > tools_used_for_phage_prediction.txt

## contig was found by how many tools
cut -f1 tmp_results2.tsv | sort -u > contig_list.txt
grep -f contig_list.txt tmp_results2.tsv ## pigaro baut hier noch die outputfile falsch
inputfile='contig2_list.txt'
while read line; do
    toolcount=$(grep $line tmp_results2.tsv | cut -f3 | sort -u | wc -l)
    echo "$line    $toolcount"
done < $inputfile


