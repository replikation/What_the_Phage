process filter_metaphinder {
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("metaphinder_*.txt")
    script:
      """
      cat *.list | sort -g -k4,4 | awk '{if(\$2=="phage"){print \$1}}' | tail -n+2 > metaphinder_\${PWD##*/}.txt
      """
}

process filter_metaphinder_own_DB {
      label 'ubuntu'
    input:
      tuple val(name), file(results) 
    output:
      tuple val(name), file("metaphinder-own-DB_*.txt")
    script:
      """
      cat *.list | sort -g -k4,4 | awk '{if(\$2=="phage"){print \$1}}' | tail -n+2 > metaphinder-own-DB_\${PWD##*/}.txt
      """
}