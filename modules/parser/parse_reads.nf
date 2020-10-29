process parse_reads {
    publishDir "${params.output}/${name}", mode: 'copy', pattern: "${name}_summary.csv"
    label 'ubuntu'
    input:
        tuple val(name), file(files)
    output:
        tuple val(name), file("${name}_summary.csv")
    script:
        """
        printf "type;amount;group\\n" > ${name}_summary.csv

        for x in *_*.txt; do
          toolname=\$(echo \${x} | cut -f1 -d"_")
          amount=\$(wc -l \${x} | cut -f1 -d " ")     
          printf "\${toolname};\${amount};\${toolname}\\n" >> ${name}_summary.csv
        done
        """
}



