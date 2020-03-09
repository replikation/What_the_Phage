#!/bin/sh


while getopts "c:p:a:" arg; do
      case "${arg}" in
        
        c)
            positive_contig_list=${OPTARG}
            ;;
       
        p)
            prodigal_out=${OPTARG}
            ;;
        
        a)
            hmmscan_result=${OPTARG}
            ;;
    esac
done


cat ${positive_contig_list} \
| awk '$0 ~ ">" {if (NR > 1) {print c;} c=0;printf substr($0,2,100) "\t"; } $0 !~ ">" {c+=length($0);} END { print c; }' \
| awk 'NR==0 {print}  NR>0 {printf("%s\t%s\n", $0, "1") }'\
| awk '{print $1, $3, $2}' OFS='\t' > chromosomefile.tbl

#prodigal.out get > contigname start end of predicted gene
grep '>' $prodigal_out | awk '{print $1, $3 ,$5}' OFS='\t' \
| tr -d '>' > predicted_gene_fromx_toy.tbl

## prepare hmmscan.out for merging with predicted_gene_fromx_toy.tbl
cat ${hmmscan_result}  \
| awk '{print $1, $4}' OFS='\t' \
| sed '/#/d' > tmp_hmmscan.tbl

# merging predicted_gene_fromx_toy.tbl and hmmscan to create the annotation file by matching ctg names
# # Walk through file2 (NR==FNR is only true for the first file argument). 
# Save column 1 in hash-array using column 2 as key: h[$2] = $1. 
# Then walk through file1 and output all three columns $1,$2,$3, 
# appending the corresponding saved column from hash-array h[$1].
awk 'NR==FNR {a[$2] = $1; ; next} {print $1,$2,$3,a[$1]}' OFS='\t' tmp_hmmscan.tbl predicted_gene_fromx_toy.tbl  \
| awk '$4!=""' OFS='\t' > tmp.tbl
# hmm not finding match for every predicted gene by prodigal wc -l tmp_hmmscan.tbl and predicted_gene_fromx_toy.tbl

# important #
# remove lines with empty fields where no pvog was assigned
# important #


awk '{print $4, $2, $3, $1}' OFS='\t' tmp.tbl \
| sed 's/_[^_]*$//g' \
| awk '{print $1, $4, $2, $3}' OFS='\t' > annotationfile.tbl 





# # create Chromosomefile1 for chromomap
# cat all_pos_phage_positive_contigs.fa \
# # first awk: results in name of contig an lenght
# | awk '$0 ~ ">" {if (NR > 1) {print c;} c=0;printf substr($0,2,100) "\t"; } $0 !~ ">" {c+=length($0);} END { print c; }' \
# # second awk: appends column with 1 for each line--> as start of a gene
# | awk 'NR==0 {print}  NR>0 {printf("%s\t%s\n", $0, "1") }'\
# # third awk: print contigname   start of contig end of contig as tabseparated file
# | awk '{print $1, $3, $2}' OFS='\t' > Chromosomefile.tbl


# # create Chromosomefile2
# # print needed fields
# cat all_pos_phage_pvogs_hmmscan.tbl \
# # print important field: start end pvog contigname
# | awk '{print $16, $17, $1, $4}' OFS='\t' \
# # remove lines with # from header
# | sed '/#/d' \
# # remove _1 from contigname
# | sed 's/_[^_]*$//g' \
# #print fields in correct order for annotationfile
# | awk '{print $3, $4, $1, $2}' OFS='\t' >newtmp.tbl
# create Chromosomefile2
# print needed fields


# Annotationfile_function_deprecated(){
# cat $hmmscan_result \
# | awk '{print $1, $4}' OFS='\t' \
# | sed '/#/d' \
# | sed 's/_[^_]*$//g' \
# | awk '{print $3, $4, $1, $2}' OFS='\t' > annotationfile1.tbl
# }