process filter_virnet {
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("virnet_*.txt")
    script:
      """
      rnd=${Math.random()}

      tail -n+2 *.csv | sed 's|,|\\t|g' | awk '{if(\$5==1){print \$2}}' > virnet_\${rnd//0.}.txt
      
      """
}

