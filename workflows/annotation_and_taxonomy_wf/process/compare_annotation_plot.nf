process compare_annotation_plot {
        publishDir "${params.output}/${name}/annotation_results/compare/", mode: 'copy'
        label 'geneviewer'
    input:
        tuple val(name_bed), path(bed_files)
        tuple val(name), path(fasta)
        tuple val(name_checkv), path(checkv)
    output:
        tuple val(name), path("*.html"), optional: true

    script:
        """

        #compare_annotation.R ${fasta} \
         #                    ${name_bed}_pharokka.bed \
          #                   ${name_bed}_phabox2.bed \
           #                  ${name_bed}_genomad.bed \
            #                 ${name_bed}_prodigal.bed \
             #                ${checkv} \
              #               90.00 # completeness to filter for
        compare_annotation.R ${fasta} ${name_bed}_pharokka.bed ${name_bed}_phabox2.bed ${name_bed}_genomad.bed ${name_bed}_prodigal.bed ${checkv} 90.00 # completeness to filter for

        """
    stub:
        """
        touch ${name}_gene_annotation_.tsv
        """
}
