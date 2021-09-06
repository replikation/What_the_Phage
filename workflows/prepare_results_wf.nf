include { filter_tool_names } from './process/prepare_results/filter_tool_names'
include { upsetr_plot } from './process/prepare_results/upsetr'
include { hue_heatmap } from './process/prepare_results/hue_heatmap'

workflow prepare_results_wf {
    take:   results
    main: 
                        
        //plotting overview
            filter_tool_names(results)
            upsetr_plot(filter_tool_names.out[0])
            //contigs_by_tools(results)
            //hue_heatmap(results).view() 
            // module to      

    //emit: prepare_results_wf_output // val(name), path(fasta), path(scores_by_tools)
    //emit: output = fasta_validation_wf.out.join(results)  // val(name), path(fasta), path(scores_by_tools)
}