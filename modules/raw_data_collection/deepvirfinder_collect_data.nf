process deepvirfinder_collect_data {
      publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "deepvirfinder_results_${name}.tar.gz"
      label 'ubuntu'
    input:
      tuple val(name), file(output_lists)
    output:
      tuple val(name), file("deepvirfinder_results_${name}.tar.gz")
    script:
      """
      mkdir -p deepvirfinder
      cat ${output_lists} | head -1 > deepvirfinder/${name}_overview.txt
      tail -q -n+2 ${output_lists} >> deepvirfinder/${name}_overview.txt
      tar -czf deepvirfinder_results_${name}.tar.gz deepvirfinder
      """
}
