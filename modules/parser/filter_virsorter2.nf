process filter_virsorter2 {
    label 'ubuntu'
    input:
        tuple val(name), path(results)
    output:
        tuple val(name), path("virsorter2_*.tsv")
    script:
        """
        tail -n+2 *.tsv |  awk '{ print \$1, \$2 }' OFS='\\t' > virsorter2_\${PWD##*/}.tsv
        """
}
