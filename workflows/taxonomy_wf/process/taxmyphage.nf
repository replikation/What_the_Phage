process taxmyphage {
        publishDir "${params.output}/${name}/taxonomic-classification/taxmyphage", mode: 'copy', pattern: "${name}_taxonomy_sourmash.tsv"
        label 'taxmyphage'
        //  errorStrategy 'ignore'
        input:
          tuple val(name), path(fasta_dir) 

        output:
          tuple val(name), path("${name}_Summary_taxonomy_taxmyphage.tsv"), emit: taxmyphage_ch , optional: true
        script:
        """
        taxmyphage run -i ${fasta_dir} -t ${task.cpus} > ${name}_taxmyphage.out
        cp taxmyphage_results/Summary_taxonomy.tsv .
        mv Summary_taxonomy.tsv ${name}_Summary_taxonomy_taxmyphage.tsv
        cp ${name}_taxmyphage.out taxmyphage_results/

        """
        
        stub:
        """
        touch ${name}_Summary_taxonomy_taxmyphage.tsv
        """
}