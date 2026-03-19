process compare_annotation {
        publishDir "${params.output}/${name}/annotation_results/summary/", mode: 'copy'
        label 'ubuntu_minimal'
    input:
        tuple val(name), path(bed_files)
    output:
        tuple val(name), path("${name}_*.bed"), emit: bedfile_ch, optional: true
    script:
        """


        #scripts for uniform bed file
        if [ -f ${name}_annotation_pharokka.gff ]; then
            pharokka_to_bed.sh ${name}_annotation_pharokka.gff ${name}_pharokka.bed
        else
            touch ${name}_pharokka.bed
        fi

        if [ -f ${name}_gene_annotation_phabox2.tsv ]; then    
            phabox2_to_bed.sh ${name}_gene_annotation_phabox2.tsv ${name}_phabox2.bed
        else
            touch ${name}_phabox2.bed
        fi

        if [ -f ${name}_filtered_genes_annotation_genomad.tsv ]; then
            genomad_to_bed.sh ${name}_filtered_genes_annotation_genomad.tsv ${name}_genomad.bed
         else
            touch ${name}_genomad.bed
        fi
        
        if [ -f annotationfile_combined.tbl ]; then
        prodigal_to_bed.sh annotationfile_combined.tbl ${name}_prodigal.bed
         else
            touch ${name}_prodigal.bed
        fi


        """
    stub:
        """
        touch ${name}_pharokka.bed
        touch ${name}_phabox2.bed
        touch ${name}_genomad.bed
        touch ${name}_prodigal.bed
        """
}
