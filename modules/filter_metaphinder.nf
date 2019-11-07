process filter_metaphinder {
      publishDir "${params.output}/${name}/metaphinder", mode: 'copy', pattern: "metaphinder_*.txt"
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("metaphinder_*.txt")
    script:
      """
      rnd=${Math.random()}
      cat *.list | sort -g -k4,4 | awk '{if(\$2=="phage"){print \$1}}' | tail -n+2 > metaphinder_\${rnd//0.}.txt
      """
}