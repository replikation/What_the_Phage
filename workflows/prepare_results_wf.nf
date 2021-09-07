include { filter_tool_names } from './process/prepare_results/filter_tool_names'
include { upsetr_plot } from './process/prepare_results/upsetr'
include { hue_heatmap } from './process/prepare_results/hue_heatmap'
include { contigs_by_tools } from './process/prepare_results/contigs_by_tools'

workflow prepare_results_wf {
    take:   results
    main:                         
        //plotting overview
            filter_tool_names(results)
            upsetr_plot(filter_tool_names.out[0])
            contigs_by_tools(results)
            heatmap_input = contigs_by_tools.out.map {it -> tuple(it[0],it[1])}.view() 
            hue_heatmap(heatmap_input)
            // module to      

    //emit: prepare_results_wf_output // val(name), path(fasta), path(scores_by_tools)
    //emit: output = fasta_validation_wf.out.join(results)  // val(name), path(fasta), path(scores_by_tools)
}