process sourmash_for_tax {
      publishDir "${params.output}/${name}/taxonomic-classification", mode: 'copy', pattern: "${name}_tax-class.tsv"
      label 'sourmash'
    //  errorStrategy 'ignore'
    input:
      tuple val(name), path(fasta_dir) 
      file(database)
    output:
      tuple val(name), path("${name}_tax-class.tsv"), emit: tax_class_ch optional true
    shell:
      """
      ###//set -euxo pipefail
      for fastafile in ${fasta_dir}/*.fa; do
        sourmash sketch dna -p k=21,scaled=100 \${fastafile}
      done

      for signature in *.sig; do
        sourmash search -k 21 \${signature} phages.sbt.zip -o \${signature}.temporary
      done
    
      touch ${name}_tax-class.tsv

      for classfile in *.temporary; do
        phagename=\$(if [ \$(wc -l <\$classfile) == 0 ]
                     then
                      echo "no match found"
                     else 
                      grep -v "similarilsty,md5,filename,name,query_filename,query_name,query_md5,ani" \$classfile \
                    | sort -nrk1,1 | head -1 \
                    | grep -o '".*"' \
                    | tr -d '"'
                    fi )
        
        similarity=\$(if [ \$(wc -l <\$classfile) == 0 ]
                      then
                        echo "0"
                      else          
                        grep -v "similarity,md5,filename,name,query_filename,query_name,query_md5,ani" \$classfile \
                        | sort -nrk1,1 | head -1 \
                        | tr -d '"' \
                        | tr "|" "," \
                        | tr -s _ \
                        | awk -F "\\"*,\\"*" '{print \$1}' \
                        | awk '{printf "%.2f\\n",\$1}' 
                      fi )
        
        filename=\$(basename \${classfile} .fa.sig.temporary)
                
        echo "\$filename\t\$similarity\t\${phagename} " >> ${name}_tax-class.tsv
      done
      sed -i 1i"contig\tprediction_value\tpredicted_organism_name" ${name}_tax-class.tsv
      """
    stub:
        """
        touch ${name}_tax-class.tsv
        """
}

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