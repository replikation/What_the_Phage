process vibrant_collect_data {
    publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "vibrant_results_${name}.tar.gz"
    label 'ubuntu'
    input:
        tuple val(name), path(output_lists), path(dirs)
    output:
        tuple val(name), path("vibrant_results_${name}.tar.gz")
    script:
        """
        mkdir -p vibrant/results
        cp ${dirs} vibrant/results/
        cat ${output_lists} | head -1 > vibrant/${name}_overview.txt
        tail -q -n +2 ${output_lists} >> vibrant/${name}_overview.txt
        tar -czf vibrant_results_${name}.tar.gz vibrant
        """
    stub:
        """
        mkdir vibrant
        tar -czf vibrant_results_${name}.tar.gz vibrant
        """
}


process vibrant_virome_collect_data {
    publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "vibrant_virome_results_${name}.tar.gz"
    label 'ubuntu'
    input:
        tuple val(name), path(output_lists), path(dirs)
    output:
        tuple val(name), path("vibrant_virome_results_${name}.tar.gz")
    script:
        """
        mkdir -p vibrant/results
        cp ${dirs} vibrant/results/
        cat ${output_lists} | head -1 > vibrant/${name}_overview.txt
        tail -q -n +2 ${output_lists} >> vibrant/${name}_overview.txt
        tar -czf vibrant_virome_results_${name}.tar.gz vibrant
        """
    stub:
        """
        mkdir vibrant
        tar -czf vibrant_virome_results_${name}.tar.gz vibrant
        """
}