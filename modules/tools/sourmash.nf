process sourmash {
      label 'sourmash'
      errorStrategy 'ignore'
    input:
      tuple val(name), file(fasta_dir) 
      file(database)
    output:
      tuple val(name), file("${name}_*.list")
    shell:
      """
      tar xzf ${database}

      for fastafile in ${fasta_dir}/*.fa; do
        sourmash compute -p ${task.cpus} --scaled 100 -k 21 \${fastafile}
      done

      for signature in *.sig; do
        sourmash search -k 21 \${signature} phages.sbt.json -o \${signature}.temporary
      done
    
      touch ${name}_\${PWD##*/}.list

      for tempfile in *.temporary; do
        value=\$(grep -v "similarity,name,filename,md5" \${tempfile} | awk '\$1>=0.5'|wc -l)   # filtering criteria
        filename=\$(basename \${tempfile} .fa.sig.temporary)
      
        if [ \$value -gt 0 ] 
          then echo "\$filename" >> ${name}_\${PWD##*/}.list
        fi
      done
      """
}

/*
filtering criteria is at line 24 (awk part) with a current similiarity of 0.5 or higher to known phages
*/