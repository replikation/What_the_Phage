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
      xargs samtools faidx ${file} < tmp_allctgs.txt > ${name}_pos_ctg.fa
      """
}

