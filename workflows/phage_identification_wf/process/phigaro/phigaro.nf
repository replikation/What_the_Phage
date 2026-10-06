process phigaro {
    label 'phigaro'
    errorStrategy 'ignore'
    input:
        tuple val(name), path(fasta) 
    output:
        tuple val(name), path("output/phigaro_*.tsv")
        tuple val(name), path("output/", type: 'dir')
    script:
        """
        phigaro -f ${fasta} -o output -t ${task.cpus} --wtp --config /root/.phigaro/config.yml
        cat output/phigaro.txt | awk -v score="1" -F"," 'BEGIN { OFS = "\\t" } {\$2=score; print}' > output/tmp_phigaro_\${PWD##*/}.tsv
        echo "" >> output/phigaro_\${PWD##*/}.tsv
        sed '\${/^\$/d}' output/tmp_phigaro_\${PWD##*/}.tsv > output/phigaro_\${PWD##*/}.tsv
        """
    stub:
        """
        mkdir output
        touch output/phigaro_\${PWD##*/}.tsv
        echo "#contigID       classification  ANI [%] merged coverage [%]     number of hits  size[bp]" > ${name}_\${PWD##*/}.list
        echo "pos_phage_0     phage   80.754  96.97   172     146647" >> ${name}_\${PWD##*/}.list
        touch ${name}_\${PWD##*/}_blast.out
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

// removes empty line : sed '${/^$/d}'


//awk -v score="1" -F"," 'BEGIN { OFS = "\\t" } {$2=score; print}'