process filter_virfinder_modEPV_k8 {
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("virfinder-modEPVk8_*.txt")
    script:
      """
      tail -q -n+2 *.list | awk '\$3>=${params.vf_modEPV_k8_filter}' | awk '{ print \$1 }' > virfinder-modEPVk8_\${PWD##*/}.txt
      """
}