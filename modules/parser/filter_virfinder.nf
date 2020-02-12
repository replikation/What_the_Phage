process filter_virfinder {
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("virfinder_*.txt")
    script:
      """
      rnd=${Math.random()}

      tail -q -n+2 *.list | awk '\$4>=0.9' | awk '{ print \$2 }' > virfinder_\${rnd//0.}.txt
      """
}