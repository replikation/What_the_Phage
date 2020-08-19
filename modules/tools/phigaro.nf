process phigaro {
      label 'phigaro'
      errorStrategy 'ignore'
    input:
      tuple val(name), path(fasta) 
    output:
      tuple val(name), path("output/phigaro_*.txt")
      tuple val(name), path("output/", type: 'dir')
    script:
      """
      /root/miniconda3/bin/phigaro -f ${fasta} -o output -t ${task.cpus} --wtp --config /root/.phigaro/config.yml
      mv output/phigaro.txt output/phigaro_\${PWD##*/}.txt

      """
}