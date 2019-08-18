process marvel {
      publishDir "${params.output}/${name}/marvel", mode: 'copy', pattern: "${name}.txt"
      label 'marvel'
      echo true
    input:
      set val(name), file(fasta) 
    output:
      set val(name), file("${name}.txt")
    script:
      """
      mkdir fasta_dir_${name} && cp ${fasta} fasta_dir_${name}
      marvel_bins.py -i fasta_dir_${name} -t ${params.cpus} > results.txt
      grep "**" results.txt > ${name}.txt
      """
}