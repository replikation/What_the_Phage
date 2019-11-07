process filter_marvel {
      publishDir "${params.output}/${name}/marvel", mode: 'copy', pattern: "marvel_*.txt"
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("marvel_*.txt")
    script:
      """
      rnd=${Math.random()}
      cat *.list | grep '>' | tr -d ">"  > marvel_\${rnd//0.}.txt
      """
}