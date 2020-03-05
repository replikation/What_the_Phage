#!/bin/sh

Chromosomefile_fuction(){
cat $positive_contig_list \
| awk '$0 ~ ">" {if (NR > 1) {print c;} c=0;printf substr($0,2,100) "\t"; } $0 !~ ">" {c+=length($0);} END { print c; }' \
| awk 'NR==0 {print}  NR>0 {printf("%s\t%s\n", $0, "1") }'\
| awk '{print $1, $3, $2}' OFS='\t' > chromosomefile.tbl
}

# create Chromosomefile2
# print needed fields
Annotationfile_function(){
cat $hmmscan_result \
| awk '{print $16, $17, $1, $4}' OFS='\t' \
| sed '/#/d' \
| sed 's/_[^_]*$//g' \
| awk '{print $3, $4, $1, $2}' OFS='\t' > annotationfile.tbl
}


while getopts "c:a:" arg; do
      case "${arg}" in
        c)
            positive_contig_list=${OPTARG}
            Chromosomefile_fuction
            ;;
        a)
            hmmscan_result=${OPTARG}
            Annotationfile_function
            ;;
      : ) Programm
            exit 1
            ;;
    esac
done


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