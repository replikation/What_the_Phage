process samtools {
      publishDir "${params.output}/${name}/phage_positive_contigs", mode: 'copy', pattern: "${name}_positive_contigs.fa"
      label 'samtools'
    input:
      tuple val(name), file(file), file(list)
    output:
      tuple val(name), file("${name}_positive_contigs.fa")
    script:
      """
      cat ${list} | sort | uniq > tmp_allctgs.txt
      cat ${file} > all.fasta
      xargs samtools faidx all.fasta < tmp_allctgs.txt > ${name}_positive_contigs.fa
      """
}

process samtools_fastq {
      publishDir "${params.output}/${name}/phage_positive_contigs", mode: 'copy', pattern: "${name}_positive_contigs.fa"
      label 'samtools'
    input:
      tuple val(name), file(file), file(list)
    output:
      tuple val(name), file("${name}_positive_contigs.fa")
    script:
      """
      cat ${list} | sort | uniq > tmp_allctgs.txt
      cat ${file} > all.fasta
      xargs samtools faidx all.fasta < tmp_allctgs.txt > ${name}_positive_contigs.fa
      """
}