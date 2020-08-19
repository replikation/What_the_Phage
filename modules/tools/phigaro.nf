process phigaro {
      label 'phigaro'
      errorStrategy 'ignore'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("output/phigaro_*.txt")
    script:
      """
      /root/miniconda3/bin/phigaro -f ${fasta} -o output -t ${task.cpus} --wtp --config /root/.phigaro/config.yml
      mv output/phigaro.txt output/phigaro__\${PWD##*/}.txt

      """
}