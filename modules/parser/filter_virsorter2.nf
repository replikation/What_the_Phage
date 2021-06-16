process filter_virsorter2 {
    label 'ubuntu'
    input:
        tuple val(name), path(results)
    output:
        tuple val(name), path("virsorter2_*.txt")
    shell:
        """
        tail -n+2 *.tsv | awk '\$2>=${params.vs2_filter}' | awk '{ print \$1 }' | cut -d'|' -f1  > virsorter2_\${PWD##*/}.txt
        """
}



