include { filter_tool_names } from './process/prepare_results/filter_tool_names'
include { upsetr_plot } from './process/prepare_results/upsetr'
include { hue_heatmap } from './process/prepare_results/hue_heatmap'
include { contigs_by_tools } from './process/prepare_results/contigs_by_tools'
include { seqkit_tool_agreements } from './process/prepare_results/seqkit_tool_agreements'


workflow prepare_results_wf {
    take:   results
            fasta
    main:                         
        //plotting overview
            filter_tool_names(results)
            upsetr_plot(filter_tool_names.out[0])

            contigs_by_tools(results)
            samtools_input = contigs_by_tools.out.map {it -> tuple(it[0], it[3])}.join(fasta) // sample input name ,toolagreement_per_contig, fasta
            seqkit_tool_agreements(samtools_input)

            heatmap_input = contigs_by_tools.out.map {it -> tuple(it[0],it[1])}
            hue_heatmap(heatmap_input)

    

    emit: fasta // val(name), path(fasta), path(scores_by_tools)
}