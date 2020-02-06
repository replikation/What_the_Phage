process marvel_collect_data {
      publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "marvel_results_${name}.tar.gz"
      label 'ubuntu'
    input:
      tuple val(name), file(results_files)
    output:
      tuple val(name), file("marvel_results_${name}.tar.gz")
    script:
      """
      mkdir -p marvel
      cp ${results_files} marvel
      tar -czf marvel_results_${name}.tar.gz marvel
      """
}
