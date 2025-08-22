process seeker_collect_data {
    publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "seeker_results_${name}.tar.gz"
    label 'ubuntu'
    input:
        tuple val(name), path(raw_list)
    output:
        tuple val(name), path("seeker_results_${name}.tar.gz")
    script:
        """
        mkdir seeker
        cp ${raw_list} seeker/
        tar -czf seeker_results_${name}.tar.gz seeker
        """
}