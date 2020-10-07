process virfinder_modEPV_k8_collect_data {
      publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "virfinder_modEPV_k8_results_${name}.tar.gz"
      label 'ubuntu'
    input:
      tuple val(name), file(output_lists)
    output:
      tuple val(name), file("virfinder_modEPV_k8_results_${name}.tar.gz")
    script:
      """
      mkdir -p virfinder_modEPV_k8
      cp ${output_lists} virfinder_modEPV_k8
      tar -czf virfinder_modEPV_k8_results_${name}.tar.gz virfinder_modEPV_k8
      """
}
