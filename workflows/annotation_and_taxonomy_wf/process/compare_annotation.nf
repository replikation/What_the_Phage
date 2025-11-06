process compare_annotation {
        publishDir "${params.output}/${name}/annotation_results/compare/", mode: 'copy'
        label 'ubuntu_minimal'
    input:
        tuple val(name), path(bed_files)
    output:
        tuple val(name), path("${name}_*.bed"), emit: bedfile_ch, optional: true
    script:
        """

        #scripts for uniform bed file
        pharokka_to_bed.sh ${name}_annotation_pharokka.gff ${name}_pharokka.bed
        phabox2_to_bed.sh ${name}_gene_annotation_phabox2.tsv ${name}_phabox2.bed
        genomad_to_bed.sh ${name}_filtered_genes_annotation_genomad.tsv ${name}_genomad.bed
        prodigal_to_bed.sh annotationfile_combined.tbl ${name}_prodigal.bed

        """
    stub:
        """
        touch ${name}_pharokka.bed
        touch ${name}_phabox2.bed
        touch ${name}_genomad.bed
        touch ${name}_prodigal.bed
        """
}
