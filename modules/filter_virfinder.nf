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
       cat *.list | sort  -k5,5 | awk '\$5>=0.75' | awk '{ print \$2 }' > virfinder_\${rnd//0.}.txt
      """
}