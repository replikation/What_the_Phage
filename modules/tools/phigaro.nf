process phigaro {
    label 'phigaro'
    errorStrategy 'ignore'
    input:
        tuple val(name), path(fasta) 
    output:
        tuple val(name), path("output/phigaro_*.txt")
        tuple val(name), path("output/", type: 'dir')
    script:
        """
        /root/miniconda3/bin/phigaro -f ${fasta} -o output -t ${task.cpus} --wtp --config /root/.phigaro/config.yml
        cat output/phigaro.txt > output/phigaro_\${PWD##*/}.txt 
        echo "" >> output/phigaro_\${PWD##*/}.txt
      """
}

// echo "" will attach  the new line to the last line 
// this way, it will produce no error when we collect all results in with samtools
// pos_phage_0$
// pos_phage_3$
// pos_phage_4$
// pos_phage_5$
// pos_phage_6$
// pos_phage_7$
// pos_phage_8$
// pos_phage_9
//