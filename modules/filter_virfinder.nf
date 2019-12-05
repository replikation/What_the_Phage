process filter_virfinder {
      publishDir "${params.output}/${name}/virfinder", mode: 'copy', pattern: "virfinder_*.txt"
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("virfinder_*.txt")
    script:
      """
      rnd=${Math.random()}
       cat *.list | sed '1d'| sort  -k5,5 | awk '\$4>=0.9' | awk '{ print \$2 }' > virfinder_\${rnd//0.}.txt
      """
}