process filter_deepvirfinder {
    label 'ubuntu'
    input:
        tuple val(name), path(results) 
    output:
        tuple val(name), path("deepvirfinder_*.tsv")
    shell:
        """
        tail -n+2 *.list | sort -g  -k4,4  | awk '{ print \$1, \$3 }' OFS='\\t' > deepvirfinder_\${PWD##*/}.tsv
        """
}