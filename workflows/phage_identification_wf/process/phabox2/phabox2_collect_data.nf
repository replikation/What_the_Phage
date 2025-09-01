process phabox2_identify_collect_data {
    publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "seeker_results_${name}.tar.gz"
    label 'ubuntu'
    input:
        tuple val(name), path(raw_list)
    output:
        tuple val(name), path("seeker_results_${name}.tar.gz")
    script:
        """
        mkdir phabox2_phamer
        cp ${raw_list} phabox2_phamer/
        tar -czf phabox2_phamer_results_${name}.tar.gz seeker
        """
}