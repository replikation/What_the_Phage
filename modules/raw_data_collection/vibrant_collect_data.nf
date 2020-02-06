process vibrant_collect_data {
      publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "vibrant_results_${name}.tar.gz"
      label 'ubuntu'
    input:
      tuple val(name), file(output_lists), file(dirs)
    output:
      tuple val(name), file("vibrant_results_${name}.tar.gz")
    script:
      """
      mkdir -p vibrant/results
      cp ${dirs} vibrant/results/
      cat ${output_lists} | head -1 > vibrant/${name}_overview.txt
      tail -q -n +2 ${output_lists} >> vibrant/${name}_overview.txt
      tar -czf vibrant_results_${name}.tar.gz vibrant
      """
}
