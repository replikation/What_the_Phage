process filter_virsorter2 {
    label 'ubuntu'
    input:
        tuple val(name), path(results)
    output:
        tuple val(name), path("virsorter2_*.tsv")
    script:
        """
        tail -n+2 *.tsv |  awk '{ print \$1, \$2 }' OFS='\\t' | awk '{ print \$1, \$2 }' OFS='||' | cut -d "|" -f1,5 | awk -F"|" '{ print \$1, \$2 }' OFS='\t' > virsorter2_\${PWD##*/}.tsv
        sed -i 's/nan/0/g' virsorter2_\${PWD##*/}.tsv
        """
}

//needs to be trimmed away( seqname)
/* seqname dsDNAphage      ssDNA   max_score       max_score_group length  hallmark        viral   cellular
ctg1_len=102949||full   0.993   0.153   0.993   dsDNAphage      101294  64      75.800  0.600
ctg2_len=44018||full    0.980   0.140   0.980   dsDNAphage      44015   6       32.900  1.400
ctg3_len=25734||full    0.973   0.253   0.973   dsDNAphage      25304   24      85.500  0.000
ctg6_len=5303||full     0.967   0.733   0.967   dsDNAphage      3585    1       40.000  0.000 */

//awk '{ gsub(/||full/,"", $3); print }' OFS='\t' tmp_result.tsv > tmp_results2.tsv
//awk '{ print \$1, \$2 }' OFS='||' virsorter2_\${PWD##*/}.tsv

// nan  if row contains nan make to 0
// GT1_27252	0.840	virsorter2
// GT1_27276	0.640	virsorter2
// GT1_27283	0.560	virsorter2
// GT1_27330	0.633	virsorter2
// GT1_27380	0.180	virsorter2
// GT1_1	0.840	virsorter2
// GT1_396	0.567	virsorter2
// GT1_2577	nan	virsorter2
// GT1_5431	nan	virsorter2
// GT1_5765	nan	virsorter2
// GT1_7346	nan	virsorter2
//sed -i 's/nan/0/g' virsorter2_test_nan.txt