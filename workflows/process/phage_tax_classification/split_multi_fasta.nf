process split_multi_fasta_2 {
      label 'ubuntu'
    input:
      tuple val(name), val(category), path(fasta) 
    output:
      tuple val(name), val(category), path("${name}_contigs/") 
    shell:
      """
      mkdir ${name}_contigs/

      while read line
        do
      if [[ \${line:0:1} == '>' ]]
      then
        outfile=\${line#>}.fa
        echo "\${line}" > ${name}_contigs/\${outfile}
      else
        echo "\${line}" >> ${name}_contigs/\${outfile}
      fi
        done < ${fasta}
      """
    stub:
      """
      mkdir ${name}_contigs/
      """
}