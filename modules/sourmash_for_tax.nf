process sourmash_for_tax {
      publishDir "${params.output}/${name}/taxonomic-classification", mode: 'copy', pattern: "${name}_*.tax-class.csv"
      label 'sourmash'
    //  errorStrategy 'ignore'
    input:
      tuple val(name), file(fasta_dir) 
      file(database)
    output:
      tuple val(name), file("${name}_*.tax-class.csv")
    shell:
      """
      tar xzf ${database}

      for fastafile in ${fasta_dir}/*.fa; do
        sourmash compute -p ${task.cpus} --scaled 100 -k 21 \${fastafile}
      done

      for signature in *.sig; do
        sourmash search -k 21 \${signature} phages.sbt.json -o \${signature}.temporary
      done
    
      touch ${name}_\${PWD##*/}.tax-class.csv
      sed -i 1i"contig, prediction_value, predicted-organism-name" ${name}_\${PWD##*/}.tax-class.csv

      for classfile in *.temporary; do
        phagename=\$(grep -v "similarity,name,filename,md5" \$classfile \
        | sort -nrk1,1 | head -1 \
        | tr -d '"' \
        | tr "|" "," \
        | tr -s _ \
        | awk -F "\\"*,\\"*" '{print \$6 \$7}' )
        
        similarity=\$(grep -v "similarity,name,filename,md5" \$classfile \
        | sort -nrk1,1 | head -1 \
        | tr -d '"' \
        | tr "|" "," \
        | tr -s _ \
        | awk -F "\\"*,\\"*" '{print \$1}' \
        | awk '{printf "%.2f\\n",\$1}' )
        
        filename=\$(basename \${classfile} .fa.sig.temporary)
        
        
        echo "\$filename,\$similarity,\${phagename:1} " >> ${name}_\${PWD##*/}.tax-class.csv
      done
      """
}

/*
filtering criteria is at line 24 (awk part) with a current similiarity of 0.5 or higher to known phages
*/