process sourmash_tax {
      publishDir "${params.output}/${name}/taxonomic-classification", mode: 'copy', pattern: "${name}_tax-class.tsv"
      label 'sourmash'
    //  errorStrategy 'ignore'
    input:
      tuple val(name), path(fasta_dir) 
      file(database)
      file(metadata)
    output:
      tuple val(name), path("${name}_tax-class.tsv"), emit: tax_class_ch optional true
    shell:
      """
     ###set -euxo pipefail
      
      for fastafile in ${fasta_dir}/*.fa; do
        sourmash sketch dna -p k=21,scaled=100 \${fastafile}
      done

      for signature in *.sig; do
        sourmash search -k 21 \${signature} phages.sbt.zip -o \${signature}.temporary
      done
    
      touch ${name}_tax-class.tsv


      ## phagescope-result-parsing
      touch all_pos_phage_tax-class.tsv

      for taxfile in *.temporary; do

                      
        similarity_and_name=\$(if [ \$(wc -l < \$taxfile) == 0 ]
                    then
                      echo "0\tno match found"
                    else 
                        grep -v "similarity,md5,filename,name,query_filename,query_name,query_md5,ani" \$taxfile | sort -t',' -k1,1r |head -1 |  cut -d"," -f1,4 | tr ',' '\\t'
                    fi )
                

          filename=\$(basename \${taxfile} .fa.sig.temporary)
          phage_tax_name=\$(echo "\$similarity_and_name" |cut -f2)
          phagemetadata=\$(if [[ "\$similarity_and_name" == *"no match found" ]]
                              then
                                echo "no match found\tno match found\tno match found"
                              else          
                                grep "\$phage_tax_name" ${metadata} | cut -f4,6,7
                              fi )
          

        #printf "%s\\t%s\\t%s\\t%s\\n" "\$filename" "\$similarity_and_name" "\$phagemetadata" >> ${name}_tax-class.tsv
        echo "\$filename\t\$similarity_and_name\t\$phagemetadata" >> ${name}_tax-class.tsv
      done
      sed -i 1i"Contig\\tPrediction_value\\tPredicted_accession_number\\tTaxonomy\\tHost_of_Predicted_accession_number\\tLifestyle_of_Predicted_accession_number" ${name}_tax-class.tsv


      """

    stub:
        """
        touch ${name}_tax-class.tsv
        """
}



//  touch name_tax-class.tsv

//  for taxfile in *.temporary; do
//         phagename=$(if [ $(wc -l <$taxfile) == 0 ]
//                      then
//                       echo "no match found"
//                      else 
//                       grep -v "similarity,md5,filename,name,query_filename,query_name,query_md5,ani" $taxfile \
//                     | sort -nrk1,1 | head -1 | cut -d"," -f4
//                     fi )

        
//         similarity=$(if [ $(wc -l <$taxfile) == 0 ]
//                       then
//                         echo "0"
//                       else          
//                         grep -v "similarity,md5,filename,name,query_filename,query_name,query_md5,ani" $taxfile \
//                         | sort -nrk1,1 | head -1 \
//                         | tr -d '"' \
//                         | tr "|" "," \
//                         | tr -s _ \
//                         | awk -F "\"*,\"*" '{print $1}' \
//                         | awk '{printf "%.2f\\n",$1}' 
//                       fi )
        
//         filename=$(basename ${taxfile} .fa.sig.temporary)

//         metadata=$(grep "$phagename" refseq_phage_meta_data.tsv )
                
                
//         echo "$filename    $similarity    ${phagename}    $metadata" >> name_tax-class.tsv
//       done
//       sed -i 1i"contig    prediction_value    predicted_organism_name    Phage_ID    Length    GC_content    Taxonomy    Completeness    Host    Lifestyle    Cluster" name_tax-class.tsv
      
      
                   
// Phage_ID	Length	GC_content	Taxonomy	Completeness	Host	Lifestyle	Cluster	Subcluster

// NC_052655.1	147009	37.51062860097001	Caudovirales	High-quality	Escherichia coli str. K-12 substr. MG1655	virulent	cluster_22505	subcluster_28196








      // for taxfile in *.temporary; do
      //   phage_tax_name=\$(if [ \$(wc -l <\$taxfile) == 0 ]
      //                then
      //                 echo "no match found"
      //                else 
      //                #grep -v "similarilsty,md5,filename,name,query_filename,query_name,query_md5,ani" \$taxfile | sort -nrk1,1 | head -1 | cut -d"," -f4
      //                 grep -v "similarilsty,md5,filename,name,query_filename,query_name,query_md5,ani" \$taxfile \
      //               | sort -nrk1,1 | head -1 \
      //               | grep -o '".*"' \
      //               | tr -d '"'
      //               fi )
        
      //   similarity=\$(if [ \$(wc -l <\$taxfile) == 0 ]
      //                 then
      //                   echo "0"
      //                 else          
      //                   grep -v "similarity,md5,filename,name,query_filename,query_name,query_md5,ani" \$taxfile \
      //                   | sort -nrk1,1 | head -1 \
      //                   | tr -d '"' \
      //                   | tr "|" "," \
      //                   | tr -s _ \
      //                   | awk -F "\\"*,\\"*" '{print \$1}' \
      //                   | awk '{printf "%.2f\\n",\$1}' 
      //                 fi )
        
      //   filename=\$(basename \${taxfile} .fa.sig.temporary)

      //   phagemetadata=\$(grep "\$phagename" ${metadata} )
                
      //   echo "\$filename\t\$similarity\t\${phagename}\t\$phagemetadata " >> ${name}_tax-class.tsv
      // done
      // sed -i 1i"contig    prediction_value    predicted_organism_name    Phage_ID    Length    GC_content    Taxonomy    Completeness    Host    Lifestyle    Cluster" ${name}_tax-class.tsv






















/*
filtering criteria is at line 24 (awk part) with a current similiarity of 0.5 or higher to known phages
*/


// touch test_tax-class.tsv

//       for classfile in *.temporary; do
//         phagename=$(if [ $(wc -l <$classfile) == 1 ]
//                      then
//                       echo "no match found"
//                      else 
//                       grep -v "similarity,name,filename,md5" $classfile \
//                     | sort -nrk1,1 | head -1 \
//                     | grep -o '".*"' \
//                     | tr -d '"'
//                     fi )
        
//         similarity=$(if [ $(wc -l <$classfile) == 1 ]
//                       then
//                         echo "0"
//                       else          
//                         grep -v "similarity,name,filename,md5" $classfile \
//                         | sort -nrk1,1 | head -1 \
//                         | tr -d '"' \
//                         | tr "|" "," \
//                         | tr -s _ \
//                         | awk -F "\"*,\"*" '{print $1}' \
//                         | awk '{printf "%.2f\n",$1}' 
//                       fi )
        
//         filename=$(basename ${classfile} .fa.sig.temporary)
                
//         echo "$filename\t${similarity}\t${phagename} " >> test_tax-class.tsv
//       done
//       sed -i 1i"contig\tprediction_value\tpredicted_organism_name" test_tax-class.tsv

// working tax extraction
// /media/mike/6tb_1/work/30/b1b307858548c9f39f95cb77da2d0a

// failing tax extraction
// /media/mike/6tb_1/work/7c/aa7ff6b51803eb24cc67c5063f41ff