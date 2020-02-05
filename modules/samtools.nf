process samtools {
      publishDir "${params.output}/${name}/Positive_ctg_samtools", mode: 'copy', pattern: "${name}_pos_ctg.fa"
      label 'samtools'
    input:
      tuple val(name), file(file), file(list)
    output:
      tuple val(name), file(list), file("${name}_pos_ctg.fa")
    script:
      """
      cat ${list} | sort | uniq > tmp_allctgs.txt
      cat ${file} > all.fasta
      xargs samtools faidx all.fasta < tmp_allctgs.txt > ${name}_pos_ctg.fa
      """
}

