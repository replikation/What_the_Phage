process filter_virnet {
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("virnet_*.txt")
    script:
      """
      rnd=${Math.random()}

      tail -q  -n+2 *.csv | sed 's|,|\\t|g' | awk '{if(\$6==1){print \$2}}' | sort | uniq | tr -d '"' > virnet_\${rnd//0.}.txt
      """
}

