process metaphinder_collect_data {
    publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "metaphinder_results_${name}.tar.gz"
    label 'ubuntu'
    input:
        tuple val(name), path(output_lists), path(output_blasts)
    output:
        tuple val(name), path("metaphinder_results_${name}.tar.gz")
    script:
        """
        mkdir -p metaphinder/blast_results
        cat ${output_lists} | head -1 > metaphinder/${name}_overview.txt
        tail -q -n +2 ${output_lists} >> metaphinder/${name}_overview.txt
        cp ${output_blasts} metaphinder/blast_results
        tar -czf metaphinder_results_${name}.tar.gz metaphinder
        """
    stub:
        """
        mkdir metaphinder
        tar -czf metaphinder_results_${name}.tar.gz metaphinder
        """
}

process metaphinder_collect_data_ownDB {
    publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "metaphinder_ownDB_results_${name}.tar.gz"
    label 'ubuntu'
    input:
        tuple val(name), path(output_lists), path(output_blasts)
    output:
        tuple val(name), path("metaphinder_ownDB_results_${name}.tar.gz")
    script:
        """
        mkdir -p metaphinder_ownDB/blast_results
        cat ${output_lists} | head -1 > metaphinder_ownDB/${name}_overview.txt
        tail -q -n +2 ${output_lists} >> metaphinder_ownDB/${name}_overview.txt
        cp ${output_blasts} metaphinder_ownDB/blast_results
        tar -czf metaphinder_ownDB_results_${name}.tar.gz metaphinder_ownDB
        """
    stub:
        """
        mkdir metaphinder_ownDB
        tar -czf metaphinder_ownDB_results_${name}.tar.gz metaphinder_ownDB
        """
}