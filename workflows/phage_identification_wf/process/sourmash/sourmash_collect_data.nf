process sourmash_collect_data {
    publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "sourmash_results_${name}.tar.gz"
    label 'ubuntu'
    input:
        tuple val(name), path(output_lists)
    output:
        tuple val(name), path("sourmash_results_${name}.tar.gz")
    script:
        """
        echo "similarity,name,filename,md5" > ${name}_overview.txt
        tail -q -n +2 ${output_lists} >> ${name}_overview.txt
        tar -czf sourmash_results_${name}.tar.gz ${name}_overview.txt
        """
    stub:
        """
        touch ${name}_overview.txt
        tar -czf sourmash_results_${name}.tar.gz ${name}_overview.txt
        """
}