process filter_vibrant {
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("vibrant_*.txt")
    script:
      """
      rnd=${Math.random()}
      tail -q  -n+2 *.tsv | awk '{if(\$2=="virus"){print \$1}}' > vibrant_\${rnd//0.}.txt
      
      """
}