process filter_virfinder {
    label 'ubuntu'
    input:
        tuple val(name), file(results) 
    output:
        tuple val(name), file("virfinder_*.tsv")
    script:
        """
        tail -q -n+2 *.list | awk '{ print \$2, \$4}' OFS='\\t' > virfinder_\${PWD##*/}.tsv
        """
}

// filter included