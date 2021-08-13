process filter_sourmash {
    label 'ubuntu'
    input:
        tuple val(name), path(results)
    output:
        tuple val(name), path("sourmash_*.tsv")
    shell:
        """
        awk -F, '{print \$1, \$2}' OFS="\\t" *.list  > sourmash_\${PWD##*/}.tsv
        """
}

// filter im tool (awk - remove there and put here)