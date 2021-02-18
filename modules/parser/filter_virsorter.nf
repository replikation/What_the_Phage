process filter_virsorter {
    label 'ubuntu'
    input:
        tuple val(name), file(results), file(dir)
    output:
        tuple val(name), file("virsorter_*.txt")
    shell:
        """
        cat *.list  > virsorter_\${PWD##*/}.txt
        """
}

process filter_virsorter_virome {
    label 'ubuntu'
    input:
        tuple val(name), file(results), file(dir)
    output:
        tuple val(name), file("virsorter-virome_*.txt")
    shell:
        """
        cat *.list  > virsorter-virome_\${PWD##*/}.txt
        """
}

// filter needs to be added