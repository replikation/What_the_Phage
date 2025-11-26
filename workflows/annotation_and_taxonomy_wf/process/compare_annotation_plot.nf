process compare_annotation_plot {
        publishDir "${params.output}/${name}/annotation_results/compare/", mode: 'copy'
        label 'geneviewer'
    input:
        tuple val(name), path(bed_files), path(fasta), path(checkv)
    output:
        tuple val(name), path("*.html"), emit: annotation_plot_ch, optional: true
        tuple val(name), path("log.txt"), optional: true

    script:
        """

        compare_annotation.R ${fasta} \
                             ${name}_pharokka.bed \
                             ${name}_phabox2.bed \
                             ${name}_genomad.bed \
                             ${name}_prodigal.bed \
                             ${checkv} \
                             ${params.plot_completeness} # completeness to filter for
        #compare_annotation.R ${fasta} ${name}_pharokka.bed ${name}_phabox2.bed ${name}_genomad.bed ${name}_prodigal.bed ${checkv} 90.00 # completeness to filter for

        # need solution for no html file created because of too strict filter -- or if it doesnt make sense to plot anything
        [ -z "\$(ls -1 *.html 2>/dev/null)" ] && touch "log.txt"
        echo "no html file created. --plot_completeness filter too strict" >> log.txt
        """
    stub:
        """
        touch ${name}_gene_annotation_.tsv
        """
}
