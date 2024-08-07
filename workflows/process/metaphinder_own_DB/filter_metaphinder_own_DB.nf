process filter_metaphinder_own_DB {
    label 'ubuntu'
    input:
        tuple val(name), path(results) 
    output:
        tuple val(name), path("metaphinder-own-DB_*.tsv")
    script:
        """
        #cat *.list | sort -g -k4,4 | tail -n+2 | awk '{if(\$2=="phage" && \$3>${params.mp_filter}){print \$1}}'  > metaphinder-own-DB_\${PWD##*/}.txt
        tail -n+2 *.list | awk -v div="100" '{print \$1, \$3/div}' OFS='\\t' > metaphinder-own-DB_\${PWD##*/}.tsv
        """
}
