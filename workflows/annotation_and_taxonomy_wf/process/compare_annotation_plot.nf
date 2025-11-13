process compare_annotation_plot {
        publishDir "${params.output}/${name}/annotation_results/compare/", mode: 'copy'
        label 'geneviewer'
    input:
        tuple val(name), path(bed_files), path(fasta), path(checkv)
    output:
        tuple val(name), path("*.html")

    script:
        """

        #compare_annotation.R ${fasta} \
         #                    ${name}_pharokka.bed \
          #                   ${name}_phabox2.bed \
           #                  ${name}_genomad.bed \
            #                 ${name}_prodigal.bed \
             #                ${checkv} \
              #               99.90 # completeness to filter for
        compare_annotation.R ${fasta} ${name}_pharokka.bed ${name}_phabox2.bed ${name}_genomad.bed ${name}_prodigal.bed ${checkv} 90.00 # completeness to filter for

        """
    stub:
        """
        touch ${name}_gene_annotation_.tsv
        """
}
