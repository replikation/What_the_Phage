process filter_marvel {
      publishDir "${params.output}/${name}/marvel", mode: 'copy', pattern: "marvel.txt"
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("marvel.txt")
    shell:
      """
        grep '>' !{results} |awk '\$4>=75.0' |awk '{print \$2 }' | cut -f1 -d "_" > marvel.txt
      """
}