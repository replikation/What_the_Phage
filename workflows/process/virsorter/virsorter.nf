process virsorter {
    label 'virsorter'
    errorStrategy 'ignore'
    input:
        tuple val(name), file(fasta) 
        file(database) 
    output:
        tuple val(name), path("virsorter_*.list"), path("virsorter")
        // output collection stream
        tuple val(name), path("virsorter_results_*.tar")
    script:
        """
        wrapper_phage_contigs_sorter_iPlant.pl -f ${fasta} -db 2 --wdir virsorter --ncpu \$(( ${task.cpus} * 2 )) --data-dir ${database}
        cat virsorter/Predicted_viral_sequences/VIRSorter*.fasta | grep ">" > virsorter_categorized_contigs_\${PWD##*/}.list
        tar cf virsorter_results_\${PWD##*/}.tar virsorter
        """
    stub:
        """
        echo ">VIRSorter_pos_phage_7-cat_1" > virsorter_categorized_contigs_\${PWD##*/}.list
        echo "VIRSorter_pos_phage_7-cat_1" >> virsorter_categorized_contigs_\${PWD##*/}.list
        mkdir virsorter
        tar cf virsorter_results_\${PWD##*/}.tar virsorter
        """
}

process virsorter_virome {
    label 'virsorter'
    errorStrategy 'ignore'
    input:
        tuple val(name), file(fasta) 
        file(database) 
    output:
        tuple val(name), path("virsorter_*.list"), path("virsorter")
        // output collection stream
        tuple val(name), path("virsorter_results_*.tar")
    script:
        """
        wrapper_phage_contigs_sorter_iPlant.pl -f ${fasta} -db 2 --virome --wdir virsorter --ncpu \$(( ${task.cpus} * 2 )) --data-dir ${database}
        cat virsorter/Predicted_viral_sequences/VIRSorter*.fasta | grep ">" > virsorter_categorized_contigs_\${PWD##*/}.list
        tar cf virsorter_results_\${PWD##*/}.tar virsorter
        """
    stub:
        """
        echo ">VIRSorter_pos_phage_7-cat_1" > virsorter_categorized_contigs_\${PWD##*/}.list
        echo "VIRSorter_pos_phage_7-cat_1" >> virsorter_categorized_contigs_\${PWD##*/}.list
        mkdir virsorter
        tar cf virsorter_results_\${PWD##*/}.tar virsorter
        """
}