process taxmyphage {
        publishDir "${params.output}/${name}/taxonomic-classification/sourmash", mode: 'copy', pattern: "${name}_taxonomy_sourmash.tsv"
        label 'taxmyphage'
        //  errorStrategy 'ignore'
        input:
          tuple val(name), path(fasta_dir) 

        output:
          tuple val(name), path("${name}_Summary_taxonomy.tsv"), emit: taxmyphage_ch , optional: true
        script:
        """
        taxmyphage run -i all_pos_phage.fa -t ${task.cpus} > taxmyphage.out
        mv taxmyphage_results/Summary_taxonomy.tsv .
        mv Summary_taxonomy.tsv ${name}_taxonomy_sourmash.tsv

        """
        
        stub:
        """
        touch ${name}_taxonomy_sourmash.tsv
        """
}