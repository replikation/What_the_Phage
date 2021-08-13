process filter_PPRmeta {
    label 'ubuntu'
    input:
        tuple val(name), path(results) 
    output:
        tuple val(name), path("PPRmeta_*.tsv")
    script:
        """
        tail -n+2 *.csv | awk -F, '{print \$1, \$3}' OFS="\\t" > PPRmeta_\${PWD##*/}.tsv
        """
}