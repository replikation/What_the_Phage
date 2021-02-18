process sourmash_for_tax {
      publishDir "${params.output}/${name}/${category}/taxonomic-classification", mode: 'copy', pattern: "${name}_tax-class.tsv"
      label 'sourmash'
    //  errorStrategy 'ignore'
    input:
      tuple val(name), val(category), file(fasta_dir) 
      file(database)
    output:
      tuple val(name), val(category), file("${name}_tax-class.tsv")
    shell:
      """
      for fastafile in ${fasta_dir}/*.fa; do
        sourmash compute -p ${task.cpus} --scaled 100 -k 21 \${fastafile}
      done

      for signature in *.sig; do
        sourmash search -k 21 \${signature} phages.sbt.zip -o \${signature}.temporary
      done
    
      touch ${name}_tax-class.tsv

      for classfile in *.temporary; do
        phagename=\$(if [ \$(wc -l <\$classfile) == 1 ]
                     then
                      echo "no match found"
                     else 
                      grep -v "similarity,name,filename,md5" \$classfile \
                    | sort -nrk1,1 | head -1 \
                    | grep -o '".*"' \
                    | tr -d '"'
                    fi )
        
        similarity=\$(if [ \$(wc -l <\$classfile) == 1 ]
                      then
                        echo "0"
                      else          
                        grep -v "similarity,name,filename,md5" \$classfile \
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
}

/*
filtering criteria is at line 24 (awk part) with a current similiarity of 0.5 or higher to known phages
*/