process phigaro_collect_data {
    label 'ubuntu'
    input:
        tuple val(name), path(rawdir)
    output:
        tuple val(name), path("phigaro_results_${name}.tar.gz")
    script:
        """
        mkdir phigaro
        cp -r ${rawdir}/* phigaro
        tar -czf phigaro_results_${name}.tar.gz phigaro
        """
    stub:
        """
        mkdir phigaro
        tar -czf phigaro_results_${name}.tar.gz phigaro
        """
}
