process sourmash {
    label 'sourmash'
    errorStrategy 'ignore'
    input:
        tuple val(name), path(fasta_dir) 
        path(database)
    output:
        tuple val(name), path("${name}_*.list")
    script:
        """
        for fastafile in ${fasta_dir}/*.fa; do
          sourmash compute -p ${task.cpus} --scaled 100 -k 21 \${fastafile}
        done

        for signature in *.sig; do
          sourmash search -k 21 \${signature} phages.sbt.zip -o \${signature}.temporary
        done
    
        touch ${name}_\${PWD##*/}.list

        for tempfile in *.temporary; do
          value=\$(grep -v "similarity,name,filename,md5" \${tempfile} | wc -l)   # filtering criteria
          filename=\$(basename \${tempfile} .fa.sig.temporary)
          prediction_value=\$(grep -v "similarity,name,filename,md5" \${tempfile} |sort -r -k1 | awk 'NR == 1' | cut -d "," -f1 )
      
          if [ \$value -gt 0 ] 
            then echo "\$filename,\$prediction_value" >> ${name}_\${PWD##*/}.list
          fi
        done
        """
    stub:
        """
        echo "similarity,name,filename,md5" > ${name}_\${PWD##*/}.list
        echo "pos_phage_1,1.0" >> ${name}_\${PWD##*/}.list
        """
}

/*
filtering criteria is at line 24 (awk part) with a current similiarity of 0.5 or higher to known phages
*/