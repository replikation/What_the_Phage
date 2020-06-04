process filter_vibrant {
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("vibrant_*.txt")
    script:
      """
      tail -q  -n+2 *.tsv | awk '{if(\$2=="virus"){print \$1}}' | sed -r 's/_fragment_[0-9]//' > vibrant_\${PWD##*/}.txt
      """
}