process samtools {
      publishDir "${params.output}/${name}/Positive_ctg", mode: 'copy', pattern: "${name}_positive_ctg.fa"
      label 'samtools'
    input:
      tuple val(name), file(read) 
      tuple val(name_list), file(list)
    output:
      tuple val(name), file("${name}_positive_ctg.fa")
    script:
      """
      cat ${list} >allctgs.txt
      sort allctgs.txt | uniq > uniq_allctgs2.txt
      rm allctgs.txt
      xargs samtools faidx ${read} < uniq_allctgs2.txt > ${name_list}_positive_ctg.fa
      """
}

// ${name_list}.....dont know why but this way it works.... should be name of the read ${name} but than the file is empty...