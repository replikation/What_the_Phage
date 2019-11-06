process filter_metaphinder {
      publishDir "${params.output}/${name}/metaphinder", mode: 'copy', pattern: "metaphinder.txt"
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("metaphinder.txt")
    shell:
      """
      sort -g -k4,4 !{results} | awk '{if(\$2=="phage"){print \$1}}' | tail -n+2 > metaphinder.txt
      """
}